import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui/src/firebase_ui_initializer.dart';

class FirebaseUIAppOptions {
  final String? name;
  final FirebaseOptions? options;

  FirebaseUIAppOptions({this.name, this.options});
}

class FirebaseUIAppInitializer
    extends FirebaseUIInitializer<FirebaseUIAppOptions> {
  FirebaseUIAppInitializer([FirebaseUIAppOptions? params]) : super(params);

  late FirebaseApp app;

  @override
  Future<void> initialize([params]) async {
    app = await Firebase.initializeApp(
      name: params?.name,
      options: params?.options,
    );
  }
}
