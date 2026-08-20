// Copyright 2020 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import AuthenticationServices
import CommonCrypto
import FirebaseAuth
import FirebaseCore
import Foundation
import Security

#if canImport(firebase_core)
  import firebase_core
#else
  import firebase_core_shared
#endif

#if os(iOS)
  import Flutter
  import UIKit
#elseif os(macOS)
  import AppKit
  import FlutterMacOS
#endif

@objc(FLTFirebaseAuthPlugin)
public class FLTFirebaseAuthPlugin: NSObject, FlutterPlugin, FLTFirebasePluginProtocol,
  FirebaseAuthHostApi, ASAuthorizationControllerDelegate,
  ASAuthorizationControllerPresentationContextProviding
{
  var messenger: FlutterBinaryMessenger
  var authProvider: OAuthProvider?
  var linkWithAppleUser: User?
  var signInWithAppleAuth: Auth?
  var isReauthenticatingWithApple = false
  var currentNonce: String?
  var appleCompletion: ((Result<InternalUserCredential, Error>) -> Void)?
  var appleArguments: AuthPigeonFirebaseApp?
  var appleSignInRequestInFlight = false

  var multiFactorSessionMap: [String: MultiFactorSession] = [:]
  var multiFactorResolverMap: [String: MultiFactorResolver] = [:]
  var multiFactorAssertionMap: [String: MultiFactorAssertion] = [:]
  var multiFactorTotpSecretMap: [String: TOTPSecret] = [:]
  var emulatorConfigs: [String: [String: Any]] = [:]
  var eventChannels: [String: FlutterEventChannel] = [:]
  var streamHandlers: [String: any FlutterStreamHandler] = [:]
  var apnsToken: Data?

  static var credentialsMap: [NSNumber: AuthCredential] = [:]

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger
    super.init()
    FLTFirebasePluginRegistry.sharedInstance().register(self)
  }

  @objc
  public static func register(with registrar: FlutterPluginRegistrar) {
    #if os(macOS)
      let binaryMessenger = registrar.messenger
    #else
      let binaryMessenger = registrar.messenger()
    #endif

    let channel = FlutterMethodChannel(
      name: kFLTFirebaseAuthChannelName, binaryMessenger: binaryMessenger)
    let instance = FLTFirebaseAuthPlugin(messenger: binaryMessenger)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.publish(instance)
    registrar.addApplicationDelegate(instance)
    #if os(iOS)
      if registrar.responds(to: Selector(("addSceneDelegate:"))) {
        registrar.perform(Selector(("addSceneDelegate:")), with: instance)
      }
    #endif

    FirebaseAuthHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    FirebaseAuthUserHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    MultiFactorUserHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    MultiFactoResolverHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    MultiFactorTotpHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
    MultiFactorTotpSecretHostApiSetup.setUp(binaryMessenger: binaryMessenger, api: instance)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result(FlutterMethodNotImplemented)
  }

  static func storeAuthCredentialIfPresent(_ error: NSError) -> NSNumber? {
    if let authCredential = error.userInfo[AuthErrorUserInfoUpdatedCredentialKey] as? AuthCredential
    {
      let authCredentialHash = NSNumber(value: authCredential.hash)
      credentialsMap[authCredentialHash] = authCredential
      return authCredentialHash
    }
    return nil
  }

  func cleanup(completion: (() -> Void)?) {
    Self.credentialsMap.removeAll()
    for channel in eventChannels.values {
      channel.setStreamHandler(nil)
    }
    eventChannels.removeAll()
    for handler in streamHandlers.values {
      _ = handler.onCancel(withArguments: nil)
    }
    streamHandlers.removeAll()
    completion?()
  }

  public func detachFromEngine(for registrar: FlutterPluginRegistrar) {
    cleanup(completion: nil)
  }

  public func didReinitializeFirebaseCore(_ completion: @escaping () -> Void) {
    cleanup(completion: completion)
  }

  public func firebaseLibraryName() -> String {
    kFirebaseAuthLibraryName
  }

  public func firebaseLibraryVersion() -> String {
    kFirebaseAuthLibraryVersion
  }

  public func flutterChannelName() -> String {
    kFLTFirebaseAuthChannelName
  }

  public func pluginConstants(for firebaseApp: FirebaseApp) -> [AnyHashable: Any] {
    let auth = Auth.auth(app: firebaseApp)
    var constants: [AnyHashable: Any] = [
      "APP_LANGUAGE_CODE": auth.languageCode as Any
    ]
    if let currentUser = auth.currentUser {
      constants["APP_CURRENT_USER"] = PigeonParser.getManualList(
        PigeonParser.getPigeonDetails(currentUser))
    } else {
      constants["APP_CURRENT_USER"] = NSNull()
    }
    return constants
  }

  func getFIRAuthFromPigeon(_ pigeonApp: AuthPigeonFirebaseApp) -> Auth {
    let app = FLTFirebasePlugin.firebaseAppNamed(pigeonApp.appName)!
    let auth = Auth.auth(app: app)
    auth.tenantID = pigeonApp.tenantId
    auth.customAuthDomain = FLTFirebasePlugin.getCustomDomain(app.name)
    if let customAuthDomain = pigeonApp.customAuthDomain {
      auth.customAuthDomain = customAuthDomain
    }
    return auth
  }

  func getAppMultiFactorFromPigeon(_ app: AuthPigeonFirebaseApp) -> MultiFactor? {
    getFIRAuthFromPigeon(app).currentUser?.multiFactor
  }

  #if os(iOS)
    #if !canImport(FirebaseMessaging)
      public func application(
        _ application: UIApplication,
        didReceiveRemoteNotification notification: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
      ) -> Bool {
        if Auth.auth().canHandleNotification(notification) {
          completionHandler(.noData)
          return true
        }
        return false
      }
    #endif

    public func application(
      _ application: UIApplication,
      didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
      apnsToken = deviceToken
    }

    public func application(
      _ application: UIApplication,
      open url: URL,
      options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
      Auth.auth().canHandle(url)
    }

    public func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) -> Bool
    {
      for urlContext in urlContexts where Auth.auth().canHandle(urlContext.url) {
        return true
      }
      return false
    }
  #endif

  func ensureAPNSTokenSetting() {
    #if os(iOS)
      if FirebaseApp.app() != nil {
        if Auth.auth().apnsToken == nil, let apnsToken {
          Auth.auth().setAPNSToken(apnsToken, type: .unknown)
          self.apnsToken = nil
        }
      }
    #endif
  }

  func randomNonce(_ length: Int) -> String {
    precondition(length > 0)
    let characterSet = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
    var result = ""
    var remainingLength = length
    while remainingLength > 0 {
      var randoms = [UInt8](repeating: 0, count: 16)
      let errorCode = SecRandomCopyBytes(kSecRandomDefault, randoms.count, &randoms)
      precondition(errorCode == errSecSuccess, "Unable to generate nonce: OSStatus \(errorCode)")
      for random in randoms {
        if remainingLength == 0 { break }
        if Int(random) < characterSet.count {
          result.append(characterSet[Int(random)])
          remainingLength -= 1
        }
      }
    }
    return result
  }

  func stringBySha256HashingString(_ input: String) -> String {
    let data = Data(input.utf8)
    var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
    data.withUnsafeBytes { buffer in
      _ = CC_SHA256(buffer.baseAddress, CC_LONG(data.count), &hash)
    }
    return hash.map { String(format: "%02x", $0) }.joined()
  }

  func handleMultiFactorError(
    app: AuthPigeonFirebaseApp,
    error: Error,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let nsError = error as NSError
    guard
      let resolver = nsError.userInfo[AuthErrorUserInfoMultiFactorResolverKey]
        as? MultiFactorResolver
    else {
      completion(.failure(AuthErrors.convertToFlutterError(error)))
      return
    }

    let sessionId = UUID().uuidString
    multiFactorSessionMap[sessionId] = resolver.session
    let resolverId = UUID().uuidString
    multiFactorResolverMap[resolverId] = resolver

    let pigeonHints: [[Any?]] = resolver.hints.map { info in
      var phoneNumber: String?
      if let phoneInfo = info as? PhoneMultiFactorInfo {
        phoneNumber = phoneInfo.phoneNumber
      }
      return InternalMultiFactorInfo(
        displayName: info.displayName,
        enrollmentTimestamp: info.enrollmentDate.timeIntervalSince1970,
        factorId: info.factorID,
        uid: info.uid,
        phoneNumber: phoneNumber
      ).toList()
    }

    let output: [String: Any] = [
      "appName": app.appName,
      "multiFactorHints": pigeonHints,
      "multiFactorSessionId": sessionId,
      "multiFactorResolverId": resolverId,
    ]
    completion(
      .failure(
        FlutterError(
          code: "second-factor-required", message: nsError.description, details: output)))
  }

  func handleInternalError(
    error: Error,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let nsError = error as NSError
    if let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
      let details = underlyingError.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"]
    {
      completion(
        .failure(
          FlutterError(code: "internal-error", message: nsError.description, details: details)))
      return
    }
    completion(
      .failure(FlutterError(code: "internal-error", message: nsError.description, details: nil)))
  }

  func handleAppleAuthResult(
    app: AuthPigeonFirebaseApp,
    auth: Auth,
    credentials: AuthCredential?,
    error: Error?,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    if let error {
      let nsError = error as NSError
      if nsError.code == AuthErrorCode.secondFactorRequired.rawValue {
        handleMultiFactorError(app: app, error: error, completion: completion)
      } else {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
      return
    }
    guard let credentials else { return }
    auth.signIn(with: credentials) { authResult, error in
      if let error {
        let nsError = error as NSError
        let userInfo = nsError.userInfo
        let underlyingError = userInfo[NSUnderlyingErrorKey] as? NSError
        let firebaseDictionary =
          underlyingError?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"] as? [String: Any]
        let errorCode = userInfo[AuthErrorUserInfoNameKey] as? String

        if firebaseDictionary == nil, let errorCode {
          if errorCode == "ERROR_ACCOUNT_EXISTS_WITH_DIFFERENT_CREDENTIAL" {
            completion(.failure(AuthErrors.convertToFlutterError(error)))
            return
          }
          var mutableUserInfo = userInfo
          mutableUserInfo.removeValue(forKey: AuthErrorUserInfoUpdatedCredentialKey)
          completion(
            .failure(
              FlutterError(
                code: "sign-in-failed",
                message: userInfo[NSLocalizedDescriptionKey] as? String,
                details: mutableUserInfo
              )))
        } else if let message = firebaseDictionary?["message"] {
          completion(
            .failure(
              FlutterError(
                code: "sign-in-failed",
                message: nsError.localizedDescription,
                details: message
              )))
        } else {
          completion(
            .failure(
              FlutterError(
                code: "sign-in-failed",
                message: nsError.localizedDescription,
                details: userInfo
              )))
        }
      } else if let authResult {
        completion(
          .success(
            PigeonParser.getPigeonUserCredentialFromAuthResult(
              authResult, authorizationCode: nil)))
      }
    }
  }

  func launchAppleSignInRequest(
    app: AuthPigeonFirebaseApp,
    signInProvider: InternalSignInProvider,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    if appleSignInRequestInFlight {
      completion(
        .failure(
          FlutterError(
            code: "operation-not-allowed",
            message: "A Sign in with Apple request is already in progress.",
            details: nil)))
      return
    }

    let nonce = randomNonce(32)
    currentNonce = nonce
    appleCompletion = completion
    appleArguments = app
    appleSignInRequestInFlight = true

    let appleIDProvider = ASAuthorizationAppleIDProvider()
    let request = appleIDProvider.createRequest()
    var requestedScopes: [ASAuthorization.Scope] = []
    if signInProvider.scopes?.contains("name") == true {
      requestedScopes.append(.fullName)
    }
    if signInProvider.scopes?.contains("email") == true {
      requestedScopes.append(.email)
    }
    request.requestedScopes = requestedScopes
    request.nonce = stringBySha256HashingString(nonce)

    let authorizationController = ASAuthorizationController(authorizationRequests: [request])
    authorizationController.delegate = self
    authorizationController.presentationContextProvider = self
    authorizationController.performRequests()
  }

  public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor
  {
    #if os(macOS)
      return NSApplication.shared.keyWindow ?? ASPresentationAnchor()
    #else
      if #available(iOS 15.0, *) {
        for scene in UIApplication.shared.connectedScenes {
          if scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene,
            let keyWindow = windowScene.keyWindow
          {
            return keyWindow
          }
        }
      } else if #available(iOS 13.0, *) {
        for scene in UIApplication.shared.connectedScenes {
          if scene.activationState == .foregroundActive, let windowScene = scene as? UIWindowScene {
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
              return keyWindow
            }
          }
        }
      }
      return UIApplication.shared.keyWindow ?? ASPresentationAnchor()
    #endif
  }

  public func authorizationController(
    controller: ASAuthorizationController,
    didCompleteWithAuthorization authorization: ASAuthorization
  ) {
    guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
    else {
      let completion = appleCompletion
      appleCompletion = nil
      appleSignInRequestInFlight = false
      completion?(.failure(AuthErrors.invalidCredential()))
      return
    }

    guard let rawNonce = currentNonce else {
      return
    }

    guard let identityToken = appleIDCredential.identityToken else {
      let completion = appleCompletion
      appleCompletion = nil
      appleSignInRequestInFlight = false
      completion?(.failure(AuthErrors.invalidCredential()))
      return
    }

    let idToken = String(data: identityToken, encoding: .utf8)
    var authorizationCode: String?
    if let code = appleIDCredential.authorizationCode {
      authorizationCode = String(data: code, encoding: .utf8)
    }

    guard let idToken else { return }
    let credential = OAuthProvider.appleCredential(
      withIDToken: idToken, rawNonce: rawNonce, fullName: appleIDCredential.fullName)

    if isReauthenticatingWithApple {
      isReauthenticatingWithApple = false
      Auth.auth().currentUser?.reauthenticate(with: credential) { authResult, error in
        self.handleSignInWithApple(
          authResult: authResult, authorizationCode: authorizationCode, error: error)
      }
    } else if let userToLink = linkWithAppleUser {
      userToLink.link(with: credential) { authResult, error in
        self.linkWithAppleUser = nil
        self.handleSignInWithApple(
          authResult: authResult, authorizationCode: authorizationCode, error: error)
      }
    } else {
      let signInAuth = signInWithAppleAuth ?? Auth.auth()
      signInAuth.signIn(with: credential) { authResult, error in
        self.signInWithAppleAuth = nil
        self.handleSignInWithApple(
          authResult: authResult, authorizationCode: authorizationCode, error: error)
      }
    }
  }

  public func authorizationController(
    controller: ASAuthorizationController, didCompleteWithError error: Error
  ) {
    let completion = appleCompletion
    appleCompletion = nil
    appleSignInRequestInFlight = false
    guard let completion else { return }

    let nsError = error as NSError
    switch nsError.code {
    case ASAuthorizationError.canceled.rawValue:
      completion(
        .failure(
          FlutterError(
            code: "canceled", message: "The user canceled the authorization attempt.", details: nil)
        ))
    case ASAuthorizationError.invalidResponse.rawValue:
      completion(
        .failure(
          FlutterError(
            code: "invalid-response",
            message: "The authorization request received an invalid response.", details: nil)))
    case ASAuthorizationError.notHandled.rawValue:
      completion(
        .failure(
          FlutterError(
            code: "not-handled", message: "The authorization request wasn’t handled.", details: nil)
        ))
    case ASAuthorizationError.failed.rawValue:
      completion(
        .failure(
          FlutterError(
            code: "failed", message: "The authorization attempt failed.", details: nil)))
    default:
      completion(.failure(AuthErrors.convertAppleAuthorizationErrorToFlutterError(error)))
    }
  }

  func handleSignInWithApple(
    authResult: AuthDataResult?, authorizationCode: String?, error: Error?
  ) {
    guard let completion = appleCompletion else {
      appleSignInRequestInFlight = false
      return
    }
    if let error {
      if (error as NSError).code == AuthErrorCode.secondFactorRequired.rawValue,
        let appleArguments
      {
        appleCompletion = nil
        appleSignInRequestInFlight = false
        handleMultiFactorError(app: appleArguments, error: error, completion: completion)
      } else {
        appleCompletion = nil
        appleSignInRequestInFlight = false
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
      return
    }
    appleCompletion = nil
    appleSignInRequestInFlight = false
    if let authResult {
      completion(
        .success(
          PigeonParser.getPigeonUserCredentialFromAuthResult(
            authResult, authorizationCode: authorizationCode)))
    }
  }

  func getFIRAuthCredentialFromArguments(
    _ arguments: [String?: Any?],
    app: AuthPigeonFirebaseApp,
    completion: @escaping (AuthCredential?, Error?) -> Void
  ) {
    if let token = arguments["token"], !(token is NSNull) {
      let credentialHashCode = token as? NSNumber ?? NSNumber(value: (token as? Int) ?? 0)
      if let stored = Self.credentialsMap[credentialHashCode] {
        completion(stored, nil)
        return
      }
    }

    let signInMethod = arguments["signInMethod"] as? String
    if signInMethod == kSignInMethodGameCenter {
      GameCenterAuthProvider.getCredential { credential, error in
        completion(credential, error)
      }
      return
    }

    func str(_ key: String) -> String? {
      guard let value = arguments[key], !(value is NSNull) else { return nil }
      return value as? String
    }

    let secret = str("secret")
    let idToken = str("idToken")
    let accessToken = str("accessToken")
    let rawNonce = str("rawNonce")

    switch signInMethod {
    case kSignInMethodPassword:
      completion(
        EmailAuthProvider.credential(withEmail: str("email") ?? "", password: secret ?? ""), nil)
    case kSignInMethodEmailLink:
      completion(
        EmailAuthProvider.credential(withEmail: str("email") ?? "", link: str("emailLink") ?? ""),
        nil)
    case kSignInMethodFacebook:
      completion(FacebookAuthProvider.credential(withAccessToken: accessToken ?? ""), nil)
    case kSignInMethodGoogle:
      completion(
        GoogleAuthProvider.credential(withIDToken: idToken ?? "", accessToken: accessToken ?? ""),
        nil)
    case kSignInMethodTwitter:
      completion(
        TwitterAuthProvider.credential(withToken: accessToken ?? "", secret: secret ?? ""), nil)
    case kSignInMethodGithub:
      completion(GitHubAuthProvider.credential(withToken: accessToken ?? ""), nil)
    case kSignInMethodPhone:
      #if os(iOS)
        completion(
          PhoneAuthProvider.provider(auth: getFIRAuthFromPigeon(app)).credential(
            withVerificationID: str("verificationId") ?? "",
            verificationCode: str("smsCode") ?? ""), nil)
      #else
        print(
          "The Firebase Phone Authentication provider is not supported on the MacOS platform.")
        completion(nil, nil)
      #endif
    case kSignInMethodApple:
      if let idToken, let rawNonce {
        var fullName = PersonNameComponents()
        fullName.givenName = str("givenName")
        fullName.familyName = str("familyName")
        fullName.nickname = str("nickname")
        fullName.namePrefix = str("namePrefix")
        fullName.nameSuffix = str("nameSuffix")
        fullName.middleName = str("middleName")
        completion(
          OAuthProvider.appleCredential(
            withIDToken: idToken, rawNonce: rawNonce, fullName: fullName), nil)
      } else {
        completion(nil, nil)
      }
    case kSignInMethodOAuth:
      let provider = AuthProviderID.custom(str("providerId") ?? "")
      let token = idToken ?? ""
      if let rawNonce {
        completion(
          OAuthProvider.credential(
            providerID: provider, idToken: token, rawNonce: rawNonce, accessToken: accessToken),
          nil)
      } else {
        completion(
          OAuthProvider.credential(providerID: provider, idToken: token, accessToken: accessToken),
          nil)
      }
    default:
      print(
        "Support for an auth provider with identifier '\(signInMethod ?? "")' is not implemented.")
      completion(nil, nil)
    }
  }

  func completeUserCredential(
    app: AuthPigeonFirebaseApp,
    authResult: AuthDataResult?,
    error: Error?,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    if let error {
      let nsError = error as NSError
      if nsError.code == AuthErrorCode.secondFactorRequired.rawValue {
        handleMultiFactorError(app: app, error: error, completion: completion)
      } else if nsError.code == AuthErrorCode.internalError.rawValue {
        handleInternalError(error: error, completion: completion)
      } else {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
    } else if let authResult {
      completion(
        .success(
          PigeonParser.getPigeonUserCredentialFromAuthResult(authResult, authorizationCode: nil)))
    }
  }

  func completeVoid(_ error: Error?, completion: @escaping (Result<Void, Error>) -> Void) {
    if let error {
      completion(.failure(AuthErrors.convertToFlutterError(error)))
    } else {
      completion(.success(()))
    }
  }

  // MARK: - FirebaseAuthHostApi

  func registerIdTokenListener(
    app: AuthPigeonFirebaseApp, completion: @escaping (Result<String, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    let name = "\(kFLTFirebaseAuthChannelName)/id-token/\(auth.app!.name)"
    let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
    let handler = FLTIdTokenChannelStreamHandler(auth: auth)
    channel.setStreamHandler(handler)
    eventChannels[name] = channel
    streamHandlers[name] = handler
    completion(.success(name))
  }

  func registerAuthStateListener(
    app: AuthPigeonFirebaseApp, completion: @escaping (Result<String, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    let name = "\(kFLTFirebaseAuthChannelName)/auth-state/\(auth.app!.name)"
    let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
    let handler = FLTAuthStateChannelStreamHandler(auth: auth)
    channel.setStreamHandler(handler)
    eventChannels[name] = channel
    streamHandlers[name] = handler
    completion(.success(name))
  }

  func useEmulator(
    app: AuthPigeonFirebaseApp, host: String, port: Int64,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    auth.useEmulator(withHost: host, port: Int(port))
    emulatorConfigs[app.appName] = ["host": host, "port": Int(port)]
    completion(.success(()))
  }

  func applyActionCode(
    app: AuthPigeonFirebaseApp, code: String, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).applyActionCode(code) { error in
      self.completeVoid(error, completion: completion)
    }
  }

  func checkActionCode(
    app: AuthPigeonFirebaseApp, code: String,
    completion: @escaping (Result<InternalActionCodeInfo, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).checkActionCode(code) { info, error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else if let info {
        let result = self.parseActionCode(info)
        if result.operation == .unknown {
          self.resolveActionCodeOperation(
            app: app, code: code, fallbackInfo: result, completion: completion)
        } else {
          completion(.success(result))
        }
      }
    }
  }

  func parseActionCode(_ info: ActionCodeInfo) -> InternalActionCodeInfo {
    let data = InternalActionCodeInfoData(email: info.email, previousEmail: info.previousEmail)
    let operation: ActionCodeInfoOperation
    switch info.operation {
    case .passwordReset: operation = .passwordReset
    case .verifyEmail: operation = .verifyEmail
    case .recoverEmail: operation = .recoverEmail
    case .emailLink: operation = .emailSignIn
    case .verifyAndChangeEmail: operation = .verifyAndChangeEmail
    case .revertSecondFactorAddition: operation = .revertSecondFactorAddition
    default: operation = .unknown
    }
    return InternalActionCodeInfo(operation: operation, data: data)
  }

  func operationFromRequestType(_ requestType: String?) -> ActionCodeInfoOperation {
    switch requestType {
    case "PASSWORD_RESET", "resetPassword": return .passwordReset
    case "VERIFY_EMAIL", "verifyEmail": return .verifyEmail
    case "RECOVER_EMAIL", "recoverEmail": return .recoverEmail
    case "EMAIL_SIGNIN", "signIn": return .emailSignIn
    case "VERIFY_AND_CHANGE_EMAIL", "verifyAndChangeEmail": return .verifyAndChangeEmail
    case "REVERT_SECOND_FACTOR_ADDITION", "revertSecondFactorAddition":
      return .revertSecondFactorAddition
    default: return .unknown
    }
  }

  func resolveActionCodeOperation(
    app: AuthPigeonFirebaseApp, code: String, fallbackInfo: InternalActionCodeInfo,
    completion: @escaping (Result<InternalActionCodeInfo, Error>) -> Void
  ) {
    guard let firebaseApp = FLTFirebasePlugin.firebaseAppNamed(app.appName),
      let apiKey = firebaseApp.options.apiKey
    else {
      completion(.success(fallbackInfo))
      return
    }

    let baseURL: String
    if let emulatorConfig = emulatorConfigs[app.appName],
      let host = emulatorConfig["host"], let port = emulatorConfig["port"]
    {
      baseURL = "http://\(host):\(port)/identitytoolkit.googleapis.com"
    } else {
      baseURL = "https://identitytoolkit.googleapis.com"
    }

    guard let url = URL(string: "\(baseURL)/v1/accounts:resetPassword?key=\(apiKey)") else {
      completion(.success(fallbackInfo))
      return
    }
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = try? JSONSerialization.data(withJSONObject: ["oobCode": code])

    URLSession.shared.dataTask(with: request) { data, _, error in
      guard error == nil, let data,
        let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        json["error"] == nil
      else {
        completion(.success(fallbackInfo))
        return
      }
      let operation = self.operationFromRequestType(json["requestType"] as? String)
      if operation != .unknown {
        completion(.success(InternalActionCodeInfo(operation: operation, data: fallbackInfo.data)))
      } else {
        completion(.success(fallbackInfo))
      }
    }.resume()
  }

  func confirmPasswordReset(
    app: AuthPigeonFirebaseApp, code: String, newPassword: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).confirmPasswordReset(withCode: code, newPassword: newPassword) {
      error in
      self.completeVoid(error, completion: completion)
    }
  }

  func createUserWithEmailAndPassword(
    app: AuthPigeonFirebaseApp, email: String, password: String,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).createUser(withEmail: email, password: password) {
      authResult, error in
      self.completeUserCredential(
        app: app, authResult: authResult, error: error, completion: completion)
    }
  }

  func signInAnonymously(
    app: AuthPigeonFirebaseApp,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).signInAnonymously { authResult, error in
      self.completeUserCredential(
        app: app, authResult: authResult, error: error, completion: completion)
    }
  }

  func signInWithCredential(
    app: AuthPigeonFirebaseApp, input: [String?: Any?],
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    getFIRAuthCredentialFromArguments(input, app: app) { credential, error in
      if credential == nil {
        completion(.failure(AuthErrors.invalidCredential()))
        return
      }
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      }
      guard let credential else { return }
      auth.signIn(with: credential) { authResult, error in
        if let error {
          let nsError = error as NSError
          let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError
          let firebaseDictionary =
            underlyingError?.userInfo["FIRAuthErrorUserInfoDeserializedResponseKey"]
            as? [String: Any]
          if let firebaseDictionary, firebaseDictionary["message"] != nil {
            if firebaseDictionary["code"] is NSNumber {
              self.handleInternalError(error: error, completion: completion)
            } else {
              completion(
                .failure(
                  FlutterError(
                    code: firebaseDictionary["code"] as? String ?? "sign-in-failed",
                    message: firebaseDictionary["message"] as? String,
                    details: nil)))
            }
          } else if nsError.code == AuthErrorCode.secondFactorRequired.rawValue {
            self.handleMultiFactorError(app: app, error: error, completion: completion)
          } else if nsError.code == AuthErrorCode.internalError.rawValue {
            self.handleInternalError(error: error, completion: completion)
          } else {
            completion(.failure(AuthErrors.convertToFlutterError(error)))
          }
        } else if let authResult {
          completion(
            .success(
              PigeonParser.getPigeonUserCredentialFromAuthResult(
                authResult, authorizationCode: nil)))
        }
      }
    }
  }

  func signInWithCustomToken(
    app: AuthPigeonFirebaseApp, token: String,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).signIn(withCustomToken: token) { authResult, error in
      self.completeUserCredential(
        app: app, authResult: authResult, error: error, completion: completion)
    }
  }

  func signInWithEmailAndPassword(
    app: AuthPigeonFirebaseApp, email: String, password: String,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).signIn(withEmail: email, password: password) { authResult, error in
      self.completeUserCredential(
        app: app, authResult: authResult, error: error, completion: completion)
    }
  }

  func signInWithEmailLink(
    app: AuthPigeonFirebaseApp, email: String, emailLink: String,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).signIn(withEmail: email, link: emailLink) { authResult, error in
      self.completeUserCredential(
        app: app, authResult: authResult, error: error, completion: completion)
    }
  }

  func signInWithProvider(
    app: AuthPigeonFirebaseApp, signInProvider: InternalSignInProvider,
    completion: @escaping (Result<InternalUserCredential, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    if signInProvider.providerId == kSignInMethodGameCenter {
      completion(
        .failure(
          FlutterError(
            code: "sign-in-failure",
            message:
              "Game Center sign-in requires signing in with 'signInWithCredential()' API.",
            details: [:])))
      return
    }
    if signInProvider.providerId == kSignInMethodApple {
      signInWithAppleAuth = auth
      launchAppleSignInRequest(app: app, signInProvider: signInProvider, completion: completion)
      return
    }
    #if os(macOS)
      print("signInWithProvider is not supported on the MacOS platform.")
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform", message: "signInWithProvider is not supported on macOS",
            details: nil)))
    #else
      authProvider = OAuthProvider(providerID: signInProvider.providerId, auth: auth)
      if let scopes = signInProvider.scopes {
        authProvider?.scopes = scopes.compactMap { $0 }
      }
      if let customParameters = signInProvider.customParameters {
        var converted: [String: String] = [:]
        for (key, value) in customParameters {
          if let key, let value { converted[key] = value }
        }
        authProvider?.customParameters = converted
      }
      authProvider?.getCredentialWith(nil) { credential, error in
        self.handleAppleAuthResult(
          app: app, auth: auth, credentials: credential, error: error, completion: completion)
      }
    #endif
  }

  func signOut(app: AuthPigeonFirebaseApp, completion: @escaping (Result<Void, Error>) -> Void) {
    let auth = getFIRAuthFromPigeon(app)
    if auth.currentUser == nil {
      completion(.success(()))
      return
    }
    do {
      try auth.signOut()
      completion(.success(()))
    } catch {
      completion(.failure(AuthErrors.convertToFlutterError(error)))
    }
  }

  func fetchSignInMethodsForEmail(
    app: AuthPigeonFirebaseApp, email: String,
    completion: @escaping (Result<[String], Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).fetchSignInMethods(forEmail: email) { providers, error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else {
        completion(.success(providers ?? []))
      }
    }
  }

  func sendPasswordResetEmail(
    app: AuthPigeonFirebaseApp, email: String, actionCodeSettings: InternalActionCodeSettings?,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    if let actionCodeSettings,
      let settings = PigeonParser.parseActionCodeSettings(actionCodeSettings)
    {
      auth.sendPasswordReset(withEmail: email, actionCodeSettings: settings) { error in
        self.completeVoid(error, completion: completion)
      }
    } else {
      auth.sendPasswordReset(withEmail: email) { error in
        self.completeVoid(error, completion: completion)
      }
    }
  }

  func sendSignInLinkToEmail(
    app: AuthPigeonFirebaseApp, email: String, actionCodeSettings: InternalActionCodeSettings,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    guard let settings = PigeonParser.parseActionCodeSettings(actionCodeSettings) else {
      completion(.success(()))
      return
    }
    getFIRAuthFromPigeon(app).sendSignInLink(toEmail: email, actionCodeSettings: settings) {
      error in
      if let error {
        if (error as NSError).code == AuthErrorCode.internalError.rawValue {
          self.handleInternalError(error: error) { result in
            if case .failure(let internalError) = result {
              completion(.failure(internalError))
            }
          }
        } else {
          completion(.failure(AuthErrors.convertToFlutterError(error)))
        }
      } else {
        completion(.success(()))
      }
    }
  }

  func setLanguageCode(
    app: AuthPigeonFirebaseApp, languageCode: String?,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    if let languageCode {
      auth.languageCode = languageCode
    } else {
      auth.useAppLanguage()
    }
    completion(.success(auth.languageCode ?? ""))
  }

  func setSettings(
    app: AuthPigeonFirebaseApp, settings: InternalFirebaseAuthSettings,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    let auth = getFIRAuthFromPigeon(app)
    if let userAccessGroup = settings.userAccessGroup {
      do {
        try auth.useUserAccessGroup(userAccessGroup)
      } catch {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
        return
      }
    }
    #if os(iOS)
      if settings.appVerificationDisabledForTesting {
        auth.settings?.isAppVerificationDisabledForTesting =
          settings.appVerificationDisabledForTesting
      }
    #else
      print("FIRAuthSettings.appVerificationDisabledForTesting is not supported on MacOS.")
    #endif
    completion(.success(()))
  }

  func verifyPasswordResetCode(
    app: AuthPigeonFirebaseApp, code: String, completion: @escaping (Result<String, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).verifyPasswordResetCode(code) { email, error in
      if let error {
        completion(.failure(AuthErrors.convertToFlutterError(error)))
      } else {
        completion(.success(email ?? ""))
      }
    }
  }

  func verifyPhoneNumber(
    app: AuthPigeonFirebaseApp, request: InternalVerifyPhoneNumberRequest,
    completion: @escaping (Result<String, Error>) -> Void
  ) {
    #if os(macOS)
      print("The Firebase Phone Authentication provider is not supported on the MacOS platform.")
      completion(
        .failure(
          FlutterError(
            code: "unsupported-platform",
            message: "Phone authentication is not supported on macOS", details: nil)))
    #else
      let auth = getFIRAuthFromPigeon(app)
      let name = "\(kFLTFirebaseAuthChannelName)/phone/\(UUID().uuidString)"
      let channel = FlutterEventChannel(name: name, binaryMessenger: messenger)
      var multiFactorSession: MultiFactorSession?
      if let multiFactorSessionId = request.multiFactorSessionId {
        multiFactorSession = multiFactorSessionMap[multiFactorSessionId]
      }
      var multiFactorInfo: PhoneMultiFactorInfo?
      if let multiFactorInfoId = request.multiFactorInfoId {
        for resolver in multiFactorResolverMap.values {
          for info in resolver.hints {
            if info.uid == multiFactorInfoId, let phoneInfo = info as? PhoneMultiFactorInfo {
              multiFactorInfo = phoneInfo
              break
            }
          }
        }
      }
      let handler = FLTPhoneNumberVerificationStreamHandler(
        auth: auth, request: request, session: multiFactorSession, factorInfo: multiFactorInfo)
      channel.setStreamHandler(handler)
      eventChannels[name] = channel
      streamHandlers[name] = handler
      completion(.success(name))
    #endif
  }

  func revokeTokenWithAuthorizationCode(
    app: AuthPigeonFirebaseApp, authorizationCode: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    getFIRAuthFromPigeon(app).revokeToken(withAuthorizationCode: authorizationCode) { error in
      self.completeVoid(error, completion: completion)
    }
  }

  func revokeAccessToken(
    app: AuthPigeonFirebaseApp, accessToken: String,
    completion: @escaping (Result<Void, Error>) -> Void
  ) {
    completion(
      .failure(
        FlutterError(
          code: "unsupported-platform-operation",
          message:
            "revokeAccessToken is not supported on iOS/macOS. Use revokeTokenWithAuthorizationCode instead.",
          details: nil)))
  }

  func initializeRecaptchaConfig(
    app: AuthPigeonFirebaseApp, completion: @escaping (Result<Void, Error>) -> Void
  ) {
    #if os(macOS)
      print("initializeRecaptchaConfigWithCompletion is not supported on the MacOS platform.")
      completion(.success(()))
    #else
      getFIRAuthFromPigeon(app).initializeRecaptchaConfig { error in
        self.completeVoid(error, completion: completion)
      }
    #endif
  }
}

#if os(iOS)
  extension FLTFirebaseAuthPlugin: FlutterSceneLifeCycleDelegate {}
#endif
