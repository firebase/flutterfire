// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

part of firebase_auth_platform_interface;

class MethodChannelFirebaseAuth extends FirebaseAuthPlatform {
  MethodChannelFirebaseAuth() {
    channel.setMethodCallHandler(_callHandler);
  }

  @visibleForTesting
  static const MethodChannel channel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );

  final Map<int, StreamController<PlatformUser>> _authStateChangedControllers =
      <int, StreamController<PlatformUser>>{};

  static int _nextHandle = 0;
  final Map<int, Map<String, dynamic>> _phoneAuthCallbacks =
      <int, Map<String, dynamic>>{};

  @override
  Future<PlatformUser> getCurrentUser(String app) async {
    final Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>(
            'currentUser', <String, String>{'app': app});
    final PlatformUser currentUser = data == null ? null : _decodeUser(data);
    return currentUser;
  }

  @override
  Future<PlatformAuthResult> signInAnonymously(String app) async {
    final Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>(
            'signInAnonymously', <String, String>{'app': app});
    final PlatformAuthResult authResult = _decodeAuthResult(data);
    return authResult;
  }

  @override
  Future<PlatformAuthResult> createUserWithEmailAndPassword(
    String app,
    String email,
    String password,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'createUserWithEmailAndPassword',
      <String, String>{'email': email, 'password': password, 'app': app},
    );
    final PlatformAuthResult authResult = _decodeAuthResult(data);
    return authResult;
  }

  @override
  Future<List<String>> fetchSignInMethodsForEmail(String app, String email) {
    return channel.invokeListMethod<String>(
      'fetchSignInMethodsForEmail',
      <String, String>{'email': email, 'app': app},
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String app, String email) {
    return channel.invokeMethod<void>(
      'sendPasswordResetEmail',
      <String, String>{'email': email, 'app': app},
    );
  }

  @override
  Future<void> sendLinkToEmail(
    String app, {
    @required String email,
    @required String url,
    @required bool handleCodeInApp,
    @required String iOSBundleID,
    @required String androidPackageName,
    @required bool androidInstallIfNotAvailable,
    @required String androidMinimumVersion,
  }) {
    return channel.invokeMethod<void>(
      'sendLinkToEmail',
      <String, dynamic>{
        'email': email,
        'url': url,
        'handleCodeInApp': handleCodeInApp,
        'iOSBundleID': iOSBundleID,
        'androidPackageName': androidPackageName,
        'androidInstallIfNotAvailable': androidInstallIfNotAvailable,
        'androidMinimumVersion': androidMinimumVersion,
        'app': app,
      },
    );
  }

  @override
  Future<bool> isSignInWithEmailLink(String app, String link) {
    return channel.invokeMethod<bool>(
      'isSignInWithEmailLink',
      <String, String>{'link': link, 'app': app},
    );
  }

  @override
  Future<PlatformAuthResult> signInWithEmailAndLink(
    String app,
    String email,
    String link,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'signInWithEmailAndLink',
      <String, dynamic>{
        'app': app,
        'email': email,
        'link': link,
      },
    );
    final PlatformAuthResult authResult = _decodeAuthResult(data);
    return authResult;
  }

  @override
  Future<void> sendEmailVerification(String app) {
    return channel.invokeMethod<void>(
        'sendEmailVerification', <String, String>{'app': app});
  }

  @override
  Future<void> reload(String app) {
    return channel.invokeMethod<void>('reload', <String, String>{'app': app});
  }

  @override
  Future<void> delete(String app) {
    return channel.invokeMethod<void>('delete', <String, String>{'app': app});
  }

  @override
  Future<PlatformAuthResult> signInWithCredential(
    String app,
    AuthCredential credential,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'signInWithCredential',
      <String, dynamic>{
        'app': app,
        'provider': credential.providerId,
        'data': credential._asMap(),
      },
    );
    final PlatformAuthResult authResult = _decodeAuthResult(data);
    return authResult;
  }

  @override
  Future<PlatformAuthResult> signInWithCustomToken(
    String app,
    String token,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'signInWithCustomToken',
      <String, String>{'token': token, 'app': app},
    );
    final PlatformAuthResult authResult = _decodeAuthResult(data);
    return authResult;
  }

  @override
  Future<void> signOut(String app) {
    return channel.invokeMethod<void>('signOut', <String, String>{'app': app});
  }

  @override
  Future<PlatformIdTokenResult> getIdToken(String app, bool refresh) async {
    final Map<String, dynamic> data = await channel
        .invokeMapMethod<String, dynamic>('getIdToken', <String, dynamic>{
      'refresh': refresh,
      'app': app,
    });

    return _decodeIdTokenResult(data);
  }

  @override
  Future<PlatformAuthResult> reauthenticateWithCredential(
    String app,
    AuthCredential credential,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'reauthenticateWithCredential',
      <String, dynamic>{
        'app': app,
        'provider': credential.providerId,
        'data': credential._asMap(),
      },
    );
    return _decodeAuthResult(data);
  }

  @override
  Future<PlatformAuthResult> linkWithCredential(
    String app,
    AuthCredential credential,
  ) async {
    final Map<String, dynamic> data =
        await channel.invokeMapMethod<String, dynamic>(
      'linkWithCredential',
      <String, dynamic>{
        'app': app,
        'provider': credential.providerId,
        'data': credential._asMap(),
      },
    );
    final PlatformAuthResult result = _decodeAuthResult(data);
    return result;
  }

  @override
  Future<void> unlinkFromProvider(String app, String provider) {
    return channel.invokeMethod<void>(
      'unlinkFromProvider',
      <String, String>{'provider': provider, 'app': app},
    );
  }

  @override
  Future<void> updateEmail(String app, String email) {
    return channel.invokeMethod<void>(
      'updateEmail',
      <String, String>{'email': email, 'app': app},
    );
  }

  @override
  Future<void> updatePhoneNumber(
    String app,
    PhoneAuthCredential phoneAuthCredential,
  ) {
    return channel.invokeMethod<void>(
      'updatePhoneNumberCredential',
      <String, dynamic>{
        'app': app,
        'provider': phoneAuthCredential.providerId,
        'data': phoneAuthCredential._asMap(),
      },
    );
  }

  @override
  Future<void> updatePassword(String app, String password) {
    return channel.invokeMethod<void>(
      'updatePassword',
      <String, String>{'password': password, 'app': app},
    );
  }

  @override
  Future<void> updateProfile(
    String app, {
    String displayName,
    String photoUrl,
  }) {
    final Map<String, String> arguments = <String, String>{'app': app};
    if (displayName != null) {
      arguments['displayName'] = displayName;
    }
    if (photoUrl != null) {
      arguments['photoUrl'] = photoUrl;
    }
    return channel.invokeMethod<void>(
      'updateProfile',
      arguments,
    );
  }

  @override
  Future<void> setLanguageCode(String app, String language) {
    return channel.invokeMethod<void>('setLanguageCode', <String, String>{
      'language': language,
      'app': app,
    });
  }

  @override
  Stream<PlatformUser> onAuthStateChanged(String app) {
    Future<int> _handle;

    StreamController<PlatformUser> controller;
    controller = StreamController<PlatformUser>.broadcast(onListen: () {
      _handle = channel.invokeMethod<int>('startListeningAuthState',
          <String, String>{'app': app}).then<int>((dynamic v) => v);
      _handle.then((int handle) {
        _authStateChangedControllers[handle] = controller;
      });
    }, onCancel: () {
      _handle.then((int handle) async {
        await channel.invokeMethod<void>('stopListeningAuthState',
            <String, dynamic>{'id': handle, 'app': app});
        _authStateChangedControllers.remove(handle);
      });
    });

    return controller.stream;
  }

  @override
  Future<void> verifyPhoneNumber(
    String app, {
    @required String phoneNumber,
    @required Duration timeout,
    int forceResendingToken,
    @required PhoneVerificationCompleted verificationCompleted,
    @required PhoneVerificationFailed verificationFailed,
    @required PhoneCodeSent codeSent,
    @required PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout,
  }) {
    final Map<String, dynamic> callbacks = <String, dynamic>{
      'PhoneVerificationCompleted': verificationCompleted,
      'PhoneVerificationFailed': verificationFailed,
      'PhoneCodeSent': codeSent,
      'PhoneCodeAuthRetrievalTimeout': codeAutoRetrievalTimeout,
    };
    _nextHandle += 1;
    _phoneAuthCallbacks[_nextHandle] = callbacks;

    final Map<String, dynamic> params = <String, dynamic>{
      'handle': _nextHandle,
      'phoneNumber': phoneNumber,
      'timeout': timeout.inMilliseconds,
      'forceResendingToken': forceResendingToken,
      'app': app,
    };

    return channel.invokeMethod<void>('verifyPhoneNumber', params);
  }

  Future<void> _callHandler(MethodCall call) async {
    switch (call.method) {
      case 'onAuthStateChanged':
        _onAuthStageChangedHandler(call);
        break;
      case 'phoneVerificationCompleted':
        final int handle = call.arguments['handle'];
        final PhoneVerificationCompleted verificationCompleted =
            _phoneAuthCallbacks[handle]['PhoneVerificationCompleted'];
        verificationCompleted(PhoneAuthCredential._fromDetectedOnAndroid(
            jsonObject: call.arguments['phoneAuthCredential'].toString()));
        break;
      case 'phoneVerificationFailed':
        final int handle = call.arguments['handle'];
        final PhoneVerificationFailed verificationFailed =
            _phoneAuthCallbacks[handle]['PhoneVerificationFailed'];
        final Map<dynamic, dynamic> exception = call.arguments['exception'];
        verificationFailed(
            AuthException(exception['code'], exception['message']));
        break;
      case 'phoneCodeSent':
        final int handle = call.arguments['handle'];
        final String verificationId = call.arguments['verificationId'];
        final int forceResendingToken = call.arguments['forceResendingToken'];

        final PhoneCodeSent codeSent =
            _phoneAuthCallbacks[handle]['PhoneCodeSent'];
        if (forceResendingToken == null) {
          codeSent(verificationId);
        } else {
          codeSent(verificationId, forceResendingToken);
        }
        break;
      case 'phoneCodeAutoRetrievalTimeout':
        final int handle = call.arguments['handle'];
        final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
            _phoneAuthCallbacks[handle]['PhoneCodeAuthRetrievalTimeout'];
        final String verificationId = call.arguments['verificationId'];
        codeAutoRetrievalTimeout(verificationId);
        break;
    }
  }

  void _onAuthStageChangedHandler(MethodCall call) {
    final Map<dynamic, dynamic> data = call.arguments['user'];
    final int id = call.arguments['id'];

    final PlatformUser currentUser = data != null ? _decodeUser(data) : null;
    _authStateChangedControllers[id].add(currentUser);
  }
}

PlatformUser _decodeUser(Map<dynamic, dynamic> data) {
  final List<dynamic> rawProviderData = data['providerData'];
  final List<Map<dynamic, dynamic>> castProviderData =
      rawProviderData.cast<Map<dynamic, dynamic>>();
  final List<PlatformUserInfo> providerData =
      castProviderData.map<PlatformUserInfo>(_decodeUserInfo).toList();
  return PlatformUser(
    providerId: data['providerId'],
    uid: data['uid'],
    displayName: data['displayName'],
    photoUrl: data['photoUrl'],
    email: data['email'],
    phoneNumber: data['phoneNumber'],
    isAnonymous: data['isAnonymous'],
    isEmailVerified: data['isEmailVerified'],
    creationTimestamp: data['creationTimestamp'],
    lastSignInTimestamp: data['lastSignInTimestamp'],
    providerData: providerData,
  );
}

PlatformUserInfo _decodeUserInfo(Map<dynamic, dynamic> data) {
  return PlatformUserInfo(
    providerId: data['providerId'],
    uid: data['uid'],
    displayName: data['displayName'],
    photoUrl: data['photoUrl'],
    email: data['email'],
    phoneNumber: data['phoneNumber'],
  );
}

PlatformAuthResult _decodeAuthResult(Map<dynamic, dynamic> data) {
  final PlatformUser user = _decodeUser(data['user']);
  final PlatformAdditionalUserInfo additionalUserInfo =
      _decodeAdditionalUserInfo(data['additionalUserInfo']);
  return PlatformAuthResult(user: user, additionalUserInfo: additionalUserInfo);
}

PlatformAdditionalUserInfo _decodeAdditionalUserInfo(
    Map<dynamic, dynamic> data) {
  return PlatformAdditionalUserInfo(
    isNewUser: data['isNewUser'],
    username: data['username'],
    providerId: data['providerId'],
    profile: data['profile']?.cast<String, dynamic>(),
  );
}

PlatformIdTokenResult _decodeIdTokenResult(Map<String, dynamic> data) {
  return PlatformIdTokenResult(
    token: data['token'],
    expirationTimestamp: data['expirationTimestamp'],
    authTimestamp: data['authTimestamp'],
    issuedAtTimestamp: data['issuedAtTimestamp'],
    signInProvider: data['signInProvider'],
    claims: data['claims'],
  );
}
