package io.flutter.plugins.firebaseauth;

import android.util.SparseArray;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;

import androidx.test.core.app.ApplicationProvider;

import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.MockitoAnnotations;
import org.robolectric.RobolectricTestRunner;

import java.util.HashMap;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.view.FlutterMain;

import static org.mockito.Mockito.when;

@RunWith(RobolectricTestRunner.class)
public class FirebaseAuthPluginTest {
  @Mock PluginRegistry.Registrar mockRegistrar;
  @Mock BinaryMessenger mockBinaryMessenger;
  @Mock FlutterPlugin.FlutterPluginBinding mockFlutterPluginBinding;
  @Mock MethodChannel.Result mockResult;

  private String testFirebaseAppName = "[DEFAULT]";

  FirebaseAuthPlugin plugin;

  @BeforeClass()
  public static void BeforeClass() {
    FlutterMain.setIsRunningInRobolectricTest(true);
  }

  @Before
  public void setUp() {
    MockitoAnnotations.initMocks(this);
    when(mockRegistrar.messenger()).thenReturn(mockBinaryMessenger);
    when(mockRegistrar.context()).thenReturn(ApplicationProvider.getApplicationContext());
    plugin = new FirebaseAuthPlugin(mockRegistrar);
  }

  @Test
  public void onMethodCall_StartListeningToAuthState_ShouldAddListenerNotRemoved() {
    SparseArray<FirebaseAuthPlugin.PluginAuthStateListener> listeners = plugin.authStateListeners;
    assertEquals("The size of authStateListeners should be of size 0", 0, listeners.size());
    plugin.onMethodCall(buildMethodCall("startListeningAuthState"), mockResult);
    assertEquals("The size of authStateListeners should be of size 1", 1, listeners.size());
    FirebaseAuthPlugin.PluginAuthStateListener listener = listeners.get(listeners.keyAt(0));
    assertFalse("The only listener should not be removed.", listener.getIsRemoved());
  }

  @Test
  public void onDetachedFromEngine_WhenPluginAuthStateListenerExists_ShouldRemoveListeners() {
    SparseArray<FirebaseAuthPlugin.PluginAuthStateListener> listeners = plugin.authStateListeners;
    plugin.onMethodCall(buildMethodCall("startListeningAuthState"), mockResult);
    FirebaseAuthPlugin.PluginAuthStateListener listener = listeners.get(listeners.keyAt(0));
    plugin.onDetachedFromEngine(mockFlutterPluginBinding);
    assertNull("The authStateListeners should be null", plugin.authStateListeners);
    assertTrue("The only listener should be removed", listener.getIsRemoved());
  }

  private MethodCall buildMethodCall(String method) {
    final Map<String, Object> arguments = new HashMap<>();
    arguments.put("app", testFirebaseAppName);

    return new MethodCall(method, arguments);
  }
}
