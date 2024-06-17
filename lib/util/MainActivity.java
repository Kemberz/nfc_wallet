package com.example.nfcwallet;

import android.os.Bundle;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;

public class MainActivity extends FlutterActivity {
  public static final String CHANNEL = "com.example.nfcwallet/nfc";

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);

    new MethodChannel(getFlutterEngine().getDartExecutor().getBinaryMessenger(), CHANNEL)
      .setMethodCallHandler(
        new MethodCallHandler() {
          @Override
          public void onMethodCall(MethodCall call, MethodChannel.Result result) {
            if (call.method.equals("replicateNfc")) {
              String tagId = call.argument("tagId");
              startNfcEmulation(tagId);
              result.success(null);
            } else {
              result.notImplemented();
            }
          }
        }
      );
  }

  private void startNfcEmulation(String tagId) {
    // Start your HCE service with the tag ID
  }
}
