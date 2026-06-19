package com.example.uni_control

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.unicontrol.app/system_bridge"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "executeCommand") {
                val arguments = call.argument<Map<String, Any>>("arguments") ?: emptyMap()
                val command = call.argument<String>("command") ?: ""

                if (command == "getMetrics") {
                    // TODO: Implement actual Android system metric gathering here
                    val response = mapOf(
                        "status" to "success",
                        "os" to "Android",
                        "battery" to "85%", // Example mock data
                        "message" to "Mocked Android Metrics"
                    )
                    result.success(response)
                } else {
                    val response = mapOf(
                        "status" to "error",
                        "message" to "Unknown command"
                    )
                    result.success(response)
                }
            } else {
                result.notImplemented()
            }
        }
    }
}
