package com.breakcount.app

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.breakcount.app/timezone"
        ).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                result.success(java.util.TimeZone.getDefault().id)
            } else {
                result.notImplemented()
            }
        }
    }
}
