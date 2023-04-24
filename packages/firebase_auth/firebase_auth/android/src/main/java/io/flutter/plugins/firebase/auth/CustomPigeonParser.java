package io.flutter.plugins.firebase.auth;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugins.firebase.auth.GeneratedAndroidFirebaseAuth.PigeonUserInfo;

// Parser class to convert Pigeon manually when using StreamChannels
public class CustomPigeonParser {

  static Object preparePigeonUserDetails(GeneratedAndroidFirebaseAuth.PigeonUserDetails user) {
    final ArrayList<Object> parsedUser = user.toList();
    final ArrayList<Object> providerData = new ArrayList<>();
    for (PigeonUserInfo provider : (List<PigeonUserInfo>) parsedUser.get(1)) {
      providerData.add(provider.toList());
    }
    ArrayList<Object> toListResult = new ArrayList<Object>(2);
    toListResult.add(parsedUser.get(0));
    toListResult.add(providerData);
    return toListResult;
  }
}
