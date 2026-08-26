// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import FirebaseAuth
import Foundation

enum PigeonParser {
  static func getPigeonUserCredentialFromAuthResult(
    _ authResult: AuthDataResult,
    authorizationCode: String?
  ) -> InternalUserCredential {
    InternalUserCredential(
      user: getPigeonDetails(authResult.user),
      additionalUserInfo: getPigeonAdditionalUserInfo(
        authResult.additionalUserInfo, authorizationCode: authorizationCode),
      credential: getPigeonAuthCredential(authResult.credential, token: nil)
    )
  }

  static func getPigeonUserCredentialFromFIRUser(_ user: User) -> InternalUserCredential {
    InternalUserCredential(user: getPigeonDetails(user), additionalUserInfo: nil, credential: nil)
  }

  static func getPigeonDetails(_ user: User) -> InternalUserDetails {
    InternalUserDetails(
      userInfo: getPigeonUserInfo(user),
      providerData: getProviderData(user.providerData)
    )
  }

  static func getPigeonUserInfo(_ user: User) -> InternalUserInfo {
    let photoUrlString = user.photoURL?.absoluteString
    return InternalUserInfo(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: (photoUrlString?.isEmpty == false) ? photoUrlString : nil,
      phoneNumber: user.phoneNumber,
      isAnonymous: user.isAnonymous,
      isEmailVerified: user.isEmailVerified,
      providerId: user.providerID,
      tenantId: user.tenantID,
      refreshToken: user.refreshToken,
      creationTimestamp: Int64((user.metadata.creationDate?.timeIntervalSince1970 ?? 0) * 1000),
      lastSignInTimestamp: Int64((user.metadata.lastSignInDate?.timeIntervalSince1970 ?? 0) * 1000)
    )
  }

  static func getProviderData(_ providerData: [UserInfo]) -> [[AnyHashable?: Any?]?] {
    providerData.map { userInfo in
      let photoUrlStr = userInfo.photoURL?.absoluteString
      return [
        "providerId": userInfo.providerID,
        "uid": userInfo.uid.isEmpty ? "" : userInfo.uid,
        "displayName": userInfo.displayName as Any,
        "email": userInfo.email as Any,
        "phoneNumber": userInfo.phoneNumber as Any,
        "photoURL": photoUrlStr as Any,
        "isAnonymous": false,
        "isEmailVerified": true,
      ]
    }
  }

  static func getPigeonAdditionalUserInfo(
    _ userInfo: AdditionalUserInfo?,
    authorizationCode: String?
  ) -> InternalAdditionalUserInfo? {
    guard let userInfo else { return nil }
    return InternalAdditionalUserInfo(
      isNewUser: userInfo.isNewUser,
      providerId: userInfo.providerID,
      username: userInfo.username,
      authorizationCode: authorizationCode,
      profile: pigeonMap(userInfo.profile)
    )
  }

  static func getPigeonTotpSecret(_ secret: TOTPSecret) -> InternalTotpSecret {
    InternalTotpSecret(secretKey: secret.sharedSecretKey())
  }

  static func getPigeonAuthCredential(_ authCredential: AuthCredential?, token: NSNumber?)
    -> InternalAuthCredential?
  {
    guard let authCredential else { return nil }

    var accessToken: String?
    if let oauth = authCredential as? OAuthCredential {
      accessToken = oauth.accessToken ?? oauth.idToken
    }

    let hashId = token?.int64Value ?? Int64(authCredential.hash)

    return InternalAuthCredential(
      providerId: authCredential.provider,
      signInMethod: authCredential.provider,
      nativeId: hashId,
      accessToken: accessToken
    )
  }

  static func parseActionCodeSettings(_ settings: InternalActionCodeSettings?)
    -> ActionCodeSettings?
  {
    guard let settings else { return nil }
    let codeSettings = ActionCodeSettings()
    codeSettings.url = URL(string: settings.url)
    if let linkDomain = settings.linkDomain {
      codeSettings.linkDomain = linkDomain
    }
    codeSettings.handleCodeInApp = settings.handleCodeInApp
    if let iOSBundleId = settings.iOSBundleId {
      codeSettings.iOSBundleID = iOSBundleId
    }
    return codeSettings
  }

  static func parseIdTokenResult(_ tokenResult: AuthTokenResult) -> InternalIdTokenResult {
    InternalIdTokenResult(
      token: tokenResult.token,
      expirationTimestamp: Int64(tokenResult.expirationDate.timeIntervalSince1970 * 1000),
      authTimestamp: Int64(tokenResult.authDate.timeIntervalSince1970 * 1000),
      issuedAtTimestamp: Int64(tokenResult.issuedAtDate.timeIntervalSince1970 * 1000),
      signInProvider: tokenResult.signInProvider,
      claims: pigeonMap(tokenResult.claims),
      signInSecondFactor: tokenResult.signInSecondFactor
    )
  }

  static func getManualList(_ userDetails: InternalUserDetails) -> [Any] {
    [userDetails.userInfo.toList(), userDetails.providerData]
  }

  static func pigeonMap(_ map: [String: Any]?) -> [String?: Any?]? {
    guard let map else { return nil }
    var result: [String?: Any?] = [:]
    for (key, value) in map {
      result[key] = value
    }
    return result
  }
}
