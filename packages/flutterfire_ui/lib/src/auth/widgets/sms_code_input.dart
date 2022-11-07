// Copyright 2022, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart' show PhoneAuthCredential;
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../widgets/internal/universal_text_form_field.dart';

class _NumberDecorationPainter extends BoxPainter {
  final InputBorder inputBorder;
  final Color color;

  _NumberDecorationPainter({
    VoidCallback? onChanged,
    required this.inputBorder,
    required this.color,
  }) : super(onChanged);

  final rect = const Rect.fromLTWH(0, 0, NUMBER_SLOT_WIDTH, NUMBER_SLOT_HEIGHT);

  @override
  void paint(Canvas canvas, Offset offset, ImageConfiguration configuration) {
    canvas.save();
    canvas.translate(offset.dx, offset.dy);
    inputBorder
        .copyWith(borderSide: BorderSide(color: color, width: 2))
        .paint(canvas, rect);
    canvas.restore();
  }
}

class _NumberSlotDecoration extends Decoration {
  final InputBorder inputBorder;
  final Color color;

  _NumberSlotDecoration({
    required this.inputBorder,
    required this.color,
  });

  @override
  BoxPainter createBoxPainter([VoidCallback? onChanged]) {
    return _NumberDecorationPainter(
      onChanged: onChanged,
      inputBorder: inputBorder,
      color: color,
    );
  }
}

const NUMBER_SLOT_WIDTH = 44.0;
const NUMBER_SLOT_HEIGHT = 55.0;
const NUMBER_SLOT_MARGIN = 5.5;

class _NumberSlot extends StatefulWidget {
  final String number;

  const _NumberSlot({Key? key, this.number = ''}) : super(key: key);

  @override
  _NumberSlotState createState() => _NumberSlotState();
}

class _NumberSlotState extends State<_NumberSlot>
    with SingleTickerProviderStateMixin {
  bool hasError = false;

  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
  );

  @override
  void didUpdateWidget(covariant _NumberSlot oldWidget) {
    if (oldWidget.number.isEmpty && widget.number.isNotEmpty) {
      controller.animateTo(1);
    }

    if (oldWidget.number.isNotEmpty && widget.number.isEmpty) {
      controller.animateBack(0);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    final inputBorder = Theme.of(context).inputDecorationTheme.border;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final errorColor = Theme.of(context).errorColor;

    final color = hasError ? errorColor : primaryColor;

    return Container(
      width: NUMBER_SLOT_WIDTH,
      height: NUMBER_SLOT_HEIGHT,
      decoration: _NumberSlotDecoration(
        inputBorder: inputBorder ?? const UnderlineInputBorder(),
        color: color,
      ),
      margin: const EdgeInsets.all(NUMBER_SLOT_MARGIN),
      child: Center(
        child: AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return Transform.scale(
              scale: controller.value,
              child: child,
            );
          },
          child: Text(
            widget.number,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
    );
  }
}

typedef SMSCodeSubmitCallback = void Function(String smsCode);

class SMSCodeInput extends StatefulWidget {
  final bool autofocus;
  final Widget? text;
  final SMSCodeSubmitCallback? onSubmit;

  const SMSCodeInput({
    Key? key,
    this.autofocus = true,
    this.text,
    this.onSubmit,
  }) : super(key: key);

  @override
  SMSCodeInputState createState() => SMSCodeInputState();
}

class SMSCodeInputState extends State<SMSCodeInput> {
  String code = '';
  late final controller = TextEditingController()..addListener(onChange);
  final focusNode = FocusNode();

  void onChange() {
    setState(() {
      code = controller.text;
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    final authState = AuthState.maybeOf(context);

    if (authState is PhoneVerified) {
      if (authState.credential is PhoneAuthCredential) {
        controller.text =
            (authState.credential as PhoneAuthCredential).smsCode!;
      }
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final l = FlutterFireUILocalizations.labelsOf(context);

    final state = AuthState.maybeOf(context);

    Widget? text;
    if (state is CredentialReceived ||
        state is SigningIn ||
        state is SignedIn) {
      text = Text(l.verifyingSMSCodeText);
    }

    if (state is AuthFailed) {
      text = ErrorText(exception: state.exception);
    }

    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: NUMBER_SLOT_WIDTH * 6 + NUMBER_SLOT_MARGIN * 12,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(NUMBER_SLOT_MARGIN),
                child: Text(
                  l.enterSMSCodeText,
                  style: TextStyle(color: primaryColor),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < 6; i++)
                    _NumberSlot(number: code.length > i ? code[i] : ''),
                ],
              ),
              if (widget.text != null || text != null)
                Padding(
                  padding: const EdgeInsets.all(6),
                  child: widget.text ?? text,
                ),
            ],
          ),
          Opacity(
            opacity: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 30),
              child: UniversalTextFormField(
                autofillHints: const [AutofillHints.oneTimeCode],
                autofocus: true,
                focusNode: focusNode,
                controller: controller,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onSubmitted: (v) {
                  if (v == null) return;
                  if (v.length < 6) return;
                  widget.onSubmit?.call(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
