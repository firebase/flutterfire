package io.flutter.plugins.firebaseadmob;

import io.flutter.plugin.common.StandardMessageCodec;
import java.nio.ByteBuffer;

class FirebaseAdMobMessageCodec extends StandardMessageCodec {
  private static final byte AD_REQUEST = (byte) 128;
  private static final byte AD_SIZE = (byte) 129;
  private static final byte ANCHOR_TYPE = (byte) 130;

  @Override
  protected Object readValueOfType(byte type, ByteBuffer buffer) {
    switch (type) {
      case AD_REQUEST:
        return new AdRequest();
      case AD_SIZE:
        return new AdSize(
            (Integer) readValueOfType(buffer.get(), buffer),
            (Integer) readValueOfType(buffer.get(), buffer));
      case ANCHOR_TYPE:
        return AnchorType.fromName((String) readValueOfType(buffer.get(), buffer));
      default:
        return super.readValueOfType(type, buffer);
    }
  }
}
