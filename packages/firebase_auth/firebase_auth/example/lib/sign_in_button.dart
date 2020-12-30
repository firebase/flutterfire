import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// A simple widget which displays a button with an icon.
class SignInButtonBuilder extends StatelessWidget {
  /// Icon displayed next to the button
  final IconData icon;

  /// The background color of the button
  final MaterialColor backgroundColor;

  /// Text displayed next to the icon
  final String text;

  /// The callback trigggered when the button is pressed
  final VoidCallback onPressed;

  /// SignInButtonBuilder
  SignInButtonBuilder(
      {this.icon, this.backgroundColor, this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return (RaisedButton(
      onPressed: onPressed,
      color: backgroundColor,
      child: Container(
        child: Row(
          children: [
            Icon(icon),
            Padding(padding: EdgeInsets.only(left: 16), child: Text(text))
          ],
        ),
      ),
    ));
  }
}

/// A class to render a pre-defined Button
class SignInButton extends StatelessWidget {
  // ignore: public_member_api_docs
  final String provider;
  // ignore: public_member_api_docs
  final VoidCallback onPressed;

  /// Accepts a provider & onPressed callback
  SignInButton(this.provider, this.onPressed);

  /// Renders a GitHub button widget
  static Widget GitHub(VoidCallback onPressed) {
    return SignInButtonBuilder(
      icon: FontAwesomeIcons.github,
      backgroundColor: Colors.grey,
      text: 'Sign in with GitHub',
      onPressed: onPressed,
    );
  }

  /// Renders a Facebook button widget
  static Widget Facebook(VoidCallback onPressed) {
    return SignInButtonBuilder(
      icon: FontAwesomeIcons.facebook,
      backgroundColor: Colors.blue,
      text: 'Sign in with Facebook',
      onPressed: onPressed,
    );
  }

  /// Renders a Twitter button widget
  static Widget Twitter(VoidCallback onPressed) {
    return SignInButtonBuilder(
      icon: FontAwesomeIcons.twitter,
      backgroundColor: Colors.lightBlue,
      text: 'Sign in with Twitter',
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (provider == 'GitHub') {
      return SignInButton.GitHub(onPressed);
    }

    if (provider == 'Facebook') {
      return SignInButton.Facebook(onPressed);
    }

    if (provider == 'Twitter') {
      return SignInButton.Twitter(onPressed);
    }

    return Container();
  }
}
