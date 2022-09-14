import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide PhoneAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_auth/src/widgets/internal/universal_page_route.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

Future<UserCredential> startMFAVerification({
  required BuildContext context,
  required MultiFactorResolver resolver,
}) async {
  if (resolver.hints.first is PhoneMultiFactorInfo) {
    return startPhoneMFAVerification(
      context: context,
      resolver: resolver,
    );
  } else {
    throw Exception('Unsupported MFA type');
  }
}

Future<UserCredential> startPhoneMFAVerification({
  required BuildContext context,
  required MultiFactorResolver resolver,
  FirebaseAuth? auth,
}) async {
  final session = resolver.session;
  final hint = resolver.hints.first;
  final completer = Completer<UserCredential>();
  final navigator = Navigator.of(context);

  final provider = PhoneAuthProvider();
  provider.auth = auth ?? FirebaseAuth.instance;

  final flow = PhoneAuthFlow(
    auth: auth ?? FirebaseAuth.instance,
    action: AuthAction.none,
    provider: PhoneAuthProvider(),
  );

  provider.authListener = flow;

  final flowKey = Object();

  SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
    provider.sendVerificationCode(
      hint: hint as PhoneMultiFactorInfo,
      multiFactorSession: session,
      action: AuthAction.none,
    );
  });

  navigator.push(
    createPageRoute(
      context: context,
      builder: (context) {
        return AuthFlowBuilder<PhoneAuthController>(
          flow: flow,
          flowKey: flowKey,
          child: SMSCodeInputScreen(
            flowKey: flowKey,
            action: AuthAction.none,
            auth: auth,
            actions: [
              AuthStateChangeAction<CredentialReceived>((context, inner) {
                final cred = inner.credential as PhoneAuthCredential;
                final assertion = PhoneMultiFactorGenerator.getAssertion(cred);
                try {
                  final cred = resolver.resolveSignIn(assertion);
                  completer.complete(cred);
                } catch (e) {
                  completer.completeError(e);
                }
              }),
            ],
          ),
        );
      },
    ),
  );

  final cred = await completer.future;

  navigator.pop();
  return cred;
}
