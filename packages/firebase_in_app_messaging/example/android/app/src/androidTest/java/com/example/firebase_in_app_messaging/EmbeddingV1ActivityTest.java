package com.example.firebase_in_app_messaging;

import androidx.test.rule.ActivityTestRule;
import com.example.firebase_in_app_messaging_example.EmbeddingV1Activity;
import dev.flutter.plugins.e2e.FlutterRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;

@RunWith(FlutterRunner.class)
public class EmbeddingV1ActivityTest {
  @Rule
  public ActivityTestRule<EmbeddingV1Activity> rule =
      new ActivityTestRule<>(EmbeddingV1Activity.class);
}
