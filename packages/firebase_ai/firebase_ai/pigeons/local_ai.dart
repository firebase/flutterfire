import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(PigeonOptions(
  dartOut: 'lib/src/generated/local_ai.g.dart',
  dartOptions: DartOptions(),
  kotlinOut: 'android/src/main/kotlin/io/flutter/plugins/firebase/ai/GeneratedLocalAI.kt',
  kotlinOptions: KotlinOptions(),
  swiftOut: 'ios/Classes/GeneratedLocalAI.swift',
  swiftOptions: SwiftOptions(),
  dartPackageName: 'firebase_ai',
))

@HostApi()
abstract class LocalAIApi {
  @async
  bool isAvailable();
  
  @async
  String generateContent(String prompt);
  
  @async
  void warmup();
}
