package com.olsps.oltrace

import android.os.Bundle
import io.flutter.app.FlutterActivity
import io.flutter.plugins.GeneratedPluginRegistrant
import com.facebook.stetho.Stetho

class MainActivity: FlutterActivity() {
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    Stetho.initializeWithDefaults(this);
    GeneratedPluginRegistrant.registerWith(this)
  }
}
