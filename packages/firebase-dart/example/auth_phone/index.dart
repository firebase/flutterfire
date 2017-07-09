import 'dart:convert';
import 'dart:html';

import 'package:firebase/firebase.dart' as fb;
import 'package:firebase/src/assets/assets.dart';

main() async {
  //Use for firebase package development only
  await config();

  try {
    fb.initializeApp(
        apiKey: apiKey,
        authDomain: authDomain,
        databaseURL: databaseUrl,
        storageBucket: storageBucket);

    new PhoneAuthApp();
  } on fb.FirebaseJsNotLoadedException catch (e) {
    print(e);
  }
}

class PhoneAuthApp {
  final fb.Auth auth;
  final FormElement registerForm, verificationForm;
  final InputElement phone, code;
  final AnchorElement logout;
  final TableElement authInfo;
  final ParagraphElement error;

  fb.RecaptchaVerifier verifier;
  fb.ConfirmationResult confirmationResult;

  PhoneAuthApp()
      : this.auth = fb.auth(),
        this.logout = querySelector("#logout_btn"),
        this.error = querySelector(".error"),
        this.authInfo = querySelector("#auth_info"),
        this.phone = querySelector("#phone"),
        this.code = querySelector("#code"),
        this.registerForm = querySelector("#register_form"),
        this.verificationForm = querySelector("#verification_form") {
    logout.onClick.listen((e) {
      e.preventDefault();
      auth.signOut();
      _resetVerifier();
    });

    this.registerForm.onSubmit.listen((e) {
      e.preventDefault();
      var phoneValue = phone.value.trim();
      _registerUser(phoneValue);
    });

    this.verificationForm.onSubmit.listen((e) {
      e.preventDefault();
      var codeValue = code.value.trim();
      _verifyUser(codeValue);
    });

    // After opening
    if (auth.currentUser != null) {
      _setLayout(auth.currentUser);
    } else {
      _initVerifier();
    }

    // When auth state changes
    auth.onAuthStateChanged.listen((e) => _setLayout(e));
  }

  _initVerifier() {
    // This is anonymous recaptcha - size must be defined
    verifier = new fb.RecaptchaVerifier("register", {
      "size": "invisible",
      "callback": (resp) {
        print("reCAPTCHA solved, allow signInWithPhoneNumber.");
      },
      "expired-callback": () {
        print("Response expired. Ask user to solve reCAPTCHA again.");
      }
    });

    // Use this if you want to use recaptcha widget directly
    //verifier = new fb.RecaptchaVerifier("recaptcha-container")..render();
  }

  _resetVerifier() {
    verifier.clear();
    _initVerifier();
  }

  _registerUser(String phone) async {
    if (phone.isNotEmpty) {
      try {
        confirmationResult = await auth.signInWithPhoneNumber(phone, verifier);
        verificationForm.style.display = "block";
        registerForm.style.display = "none";
      } catch (e) {
        error.text = e.toString();
      }
    } else {
      error.text = "Please fill correct phone number.";
    }
  }

  _verifyUser(String code) async {
    if (code.isNotEmpty && confirmationResult != null) {
      try {
        await confirmationResult.confirm(code);
      } catch (e) {
        error.text = e.toString();
      }
    } else {
      error.text = "Please fill correct verification code.";
    }
  }

  void _setLayout(fb.User user) {
    if (user != null) {
      registerForm.style.display = "none";
      verificationForm.style.display = "none";
      logout.style.display = "block";
      phone.value = "";
      code.value = "";
      error.text = "";
      authInfo.style.display = "block";

      var data = <String, dynamic>{
        "email": user.email,
        "emailVerified": user.emailVerified,
        "isAnonymous": user.isAnonymous,
        "phoneNumber": user.phoneNumber
      };

      data.forEach((k, v) {
        if (v != null) {
          var row = authInfo.addRow();

          row.addCell()
            ..text = k
            ..classes.add("header");
          row.addCell()..text = "$v";
        }
      });

      print("User.toJson:");
      print(const JsonEncoder.withIndent(' ').convert(user));
    } else {
      registerForm.style.display = "block";
      authInfo.style.display = "none";
      logout.style.display = "none";
      authInfo.children.clear();
    }
  }
}
