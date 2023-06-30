import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/widgets.dart';

class DefaultLoadingIndicator extends StatelessWidget {
  const DefaultLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: LoadingIndicator(
        size: 32,
        borderWidth: 2,
      ),
    );
  }
}
