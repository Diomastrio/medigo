package com.example.medigo

import android.content.pm.PackageManager
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.medigo/automotive"
    private var isAutomotiveMode = false

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Check if launched from Android Auto
        isAutomotiveMode = intent.getBooleanExtra("AUTOMOTIVE_MODE", false) ||
                          packageManager.hasSystemFeature(PackageManager.FEATURE_AUTOMOTIVE)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAutomotive" -> {
                    result.success(isAutomotiveMode)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
