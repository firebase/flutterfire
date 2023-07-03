// Copyright 2023, the Chromium project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_shared/firebase_ui_shared.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// A builder that is invoked for each progress event.
typedef TaskProgressBuilder = Widget Function(
  BuildContext context,
  double progress,
);

/// A builder that is invoked when an error occurs.
typedef ErrorBuilder = Widget Function(
  BuildContext context,
  Object? error,
);

class _BindTaskWidget extends StatelessWidget {
  final Task task;
  final TaskProgressBuilder builder;
  final ErrorBuilder? errorBuilder;

  const _BindTaskWidget({
    required this.task,
    required this.builder,
    this.errorBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TaskSnapshot>(
      stream: task.snapshotEvents,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return errorBuilder?.call(context, snapshot.error) ??
              const SizedBox();
        }

        double progress;

        if (!snapshot.hasData) {
          progress = 0;
        } else {
          final taskSnapshot = snapshot.requireData;
          progress = taskSnapshot.bytesTransferred / taskSnapshot.totalBytes;
        }

        return builder(context, progress);
      },
    );
  }
}

/// An abstract widget that simplifies building custom progress indicators for
/// upload and download tasks.
///
/// Example implementation:
///
/// ```dart
/// class MyProgressIndicator extends TaskProgressWidget {
///   final Task task;
///
///   const MyProgressIndicator({super.key, required this.task});
///
///   @override
///   Widget buildProgressIndicator(BuildContext context, double progress) {
///     return Text('Progress: ${progress.toStringAsFixed(2)}');
///   }
/// }
/// ```
abstract class TaskProgressWidget extends StatelessWidget {
  const TaskProgressWidget({super.key});

  /// The task to track.
  Task get task;

  /// A builder that is called when an error occurs.
  ErrorBuilder? get errorBuilder;

  /// A builder that is called for each progress event.
  Widget buildProgressIndicator(BuildContext context, double progress);

  @override
  Widget build(BuildContext context) {
    return _BindTaskWidget(
      task: task,
      errorBuilder: errorBuilder,
      builder: (context, progress) {
        return CircularProgressIndicator(value: progress);
      },
    );
  }
}

/// Material/Cupertino app aware task progress indicator widget.
///
/// Uses [LinearProgressIndicator] under MaterialApp and a custom
/// iOS-style progress bar under [CupertinoApp].
class TaskProgressIndicator extends PlatformWidget {
  /// The task to track.
  final Task task;

  /// A builder that is called when an error occurs.
  final Widget Function(BuildContext context, Object? error)? errorBuilder;

  const TaskProgressIndicator({
    super.key,
    required this.task,
    this.errorBuilder,
  });

  @override
  Widget buildCupertino(BuildContext context) {
    return _BindTaskWidget(
      task: task,
      errorBuilder: errorBuilder,
      builder: (context, progress) {
        return _CupertinoProgressBar(progress: progress);
      },
    );
  }

  @override
  Widget buildMaterial(BuildContext context) {
    return _BindTaskWidget(
      task: task,
      errorBuilder: errorBuilder,
      builder: (context, progress) {
        return LinearProgressIndicator(value: progress);
      },
    );
  }
}

class _CupertinoProgressBar extends StatelessWidget {
  final double progress;

  const _CupertinoProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final cupertinoTheme = CupertinoTheme.of(context);

    return _CupertinoProgressBarBackground(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 100),
                left: 0,
                top: 0,
                bottom: 0,
                width: constraints.maxWidth * progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: cupertinoTheme.primaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CupertinoProgressBarBackground extends StatelessWidget {
  final Widget child;

  const _CupertinoProgressBarBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 8, maxHeight: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemFill,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }
}
