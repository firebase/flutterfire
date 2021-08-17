import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';

class FirebaseUIAppInitializer extends FirebaseUIInitializer {
  final String? name;
  final FirebaseOptions? options;

  FirebaseUIAppInitializer({
    this.name,
    this.options,
  }) : super();

  late FirebaseApp app;

  @override
  Future<void> initialize() async {
    app = await Firebase.initializeApp(
      name: name,
      options: options,
    );
  }
}
