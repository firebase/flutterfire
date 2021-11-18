import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_example/stories/screens/register_screen.dart';
import 'package:firebase_ui_example/stories/screens/sign_in_screen.dart';
import 'package:firebase_ui_example/stories/widgets/email_form.dart';
import 'package:flutter/material.dart';

import 'stories/stories_lib/story.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const StoriesApp());
}

class StoriesApp extends StatelessWidget {
  const StoriesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        canvasColor: Colors.white,
      ),
      home: const Stories(
        stories: [
          SignInScreenStory(),
          RegisterScreenStory(),
          EmailFormWidgetStory(),
        ],
      ),
    );
  }
}
