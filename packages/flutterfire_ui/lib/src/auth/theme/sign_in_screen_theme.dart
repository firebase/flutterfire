import 'package:flutter/material.dart';
import 'package:flutterfire_ui/auth.dart';


///Provides a theme to style the [SignInScreen] and [LoginView]
///Does not change the the [InputDecoration], this is still managed by your [ThemeData]
class SignInScreenTheme {
  ///Changes the background color
  Color? backgroundColor;
  ///Updates the text color on the [SignInScreen] and [LoginView]
  Color? textColor;

  SignInScreenTheme({
    this.backgroundColor = Colors.white,
    this.textColor = Colors.black,
  });
}
