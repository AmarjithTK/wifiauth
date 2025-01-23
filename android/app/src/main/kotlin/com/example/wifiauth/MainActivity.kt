package com.example.wifiauth

import android.content.Context
import android.net.ConnectivityManager
import android.net.Network
import android.net.NetworkCapabilities
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity // Correct import
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.wifiauth/network"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "useNetworkAsIs" -> {
                    markNetworkAsValidated()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun markNetworkAsValidated() {
        val connectivityManager = getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            // For Android M and above
            val network = connectivityManager.activeNetwork
            if (network != null) {
                val networkCapabilities = connectivityManager.getNetworkCapabilities(network)
                if (networkCapabilities != null) {
                    // Mark the network as validated
                    connectivityManager.reportNetworkConnectivity(network, true)
                }
            }
        } else {
            // For older Android versions
            println("Marking network as validated is not supported on this Android version.")
        }
    }
}