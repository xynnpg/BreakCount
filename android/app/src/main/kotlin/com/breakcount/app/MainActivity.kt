package com.breakcount.app

import android.content.Intent
import android.os.Build
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

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.breakcount/live_activity"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "start" -> {
                    if (Build.VERSION.SDK_INT >= 34) {
                        val intent = Intent(this, BreakCountdownService::class.java)
                        startForegroundService(intent)
                        result.success(true)
                    } else {
                        result.success(false)
                    }
                }
                "stop" -> {
                    stopService(Intent(this, BreakCountdownService::class.java))
                    result.success(true)
                }
                "isRunning" -> {
                    result.success(BreakCountdownService.isRunning)
                }
                "isAvailable" -> {
                    result.success(Build.VERSION.SDK_INT >= 34)
                }
                else -> result.notImplemented()
            }
        }
    }
}
