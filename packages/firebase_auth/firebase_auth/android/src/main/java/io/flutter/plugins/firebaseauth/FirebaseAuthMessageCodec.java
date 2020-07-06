package io.flutter.plugins.firebaseauth;

import java.io.ByteArrayOutputStream;

import io.flutter.plugin.common.StandardMessageCodec;

public class FirebaseAuthMessageCodec extends StandardMessageCodec {
    public static final FirebaseAuthMessageCodec INSTANCE = new FirebaseAuthMessageCodec();

    @Override
    protected void writeValue(ByteArrayOutputStream stream, Object value) {
        super.writeValue(stream, value);
    }
}
