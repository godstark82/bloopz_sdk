package com.bloopz.bloopz_sdk

import android.content.Context
import androidx.annotation.NonNull
import com.android.installreferrer.api.InstallReferrerClient
import com.android.installreferrer.api.InstallReferrerStateListener
import com.android.installreferrer.api.ReferrerDetails
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.net.URLDecoder

class BloopzSdkPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, EventChannel.StreamHandler {
  private lateinit var applicationContext: Context
  private lateinit var methodChannel: MethodChannel
  private lateinit var eventChannel: EventChannel

  private var referrerClient: InstallReferrerClient? = null
  private var events: EventChannel.EventSink? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    applicationContext = flutterPluginBinding.applicationContext

    methodChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "bloopz_sdk/methods")
    methodChannel.setMethodCallHandler(this)

    eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "bloopz_sdk/referrer")
    eventChannel.setStreamHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    methodChannel.setMethodCallHandler(null)
    eventChannel.setStreamHandler(null)
    disconnect()
  }

  override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
    this.events = events
    // Try to fetch immediately so apps can just "listen at startup".
    fetchReferrer { payload ->
      if (payload != null) {
        events.success(payload)
      }
    }
  }

  override fun onCancel(arguments: Any?) {
    events = null
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
    when (call.method) {
      "getInstallReferrer" -> {
        fetchReferrer { payload ->
          result.success(payload)
        }
      }
      else -> result.notImplemented()
    }
  }

  private fun fetchReferrer(done: (Map<String, Any?>?) -> Unit) {
    try {
      val client = InstallReferrerClient.newBuilder(applicationContext).build()
      referrerClient = client

      client.startConnection(object : InstallReferrerStateListener {
        override fun onInstallReferrerSetupFinished(responseCode: Int) {
          when (responseCode) {
            InstallReferrerClient.InstallReferrerResponse.OK -> {
              try {
                val details: ReferrerDetails = client.installReferrer
                val raw = details.installReferrer ?: ""
                val decoded = safeDecode(raw)
                val params = parseQueryParams(decoded)
                val payload: Map<String, Any?> = mapOf(
                  "rawReferrer" to decoded,
                  "params" to params
                )

                // Stream it too (if someone is listening)
                events?.success(payload)
                done(payload)
              } catch (e: Exception) {
                done(null)
              } finally {
                disconnect()
              }
            }
            else -> {
              done(null)
              disconnect()
            }
          }
        }

        override fun onInstallReferrerServiceDisconnected() {
          // No-op; caller can retry later.
          disconnect()
        }
      })
    } catch (e: Exception) {
      done(null)
      disconnect()
    }
  }

  private fun disconnect() {
    try {
      referrerClient?.endConnection()
    } catch (_: Exception) {
    } finally {
      referrerClient = null
    }
  }

  private fun safeDecode(s: String): String {
    return try {
      URLDecoder.decode(s, "UTF-8")
    } catch (_: Exception) {
      s
    }
  }

  private fun parseQueryParams(queryLike: String): Map<String, String> {
    val out = HashMap<String, String>()
    val q = if (queryLike.startsWith("?")) queryLike.substring(1) else queryLike
    val parts = q.split("&")
    for (p in parts) {
      val idx = p.indexOf("=")
      if (idx <= 0) continue
      val k = safeDecode(p.substring(0, idx))
      val v = safeDecode(p.substring(idx + 1))
      out[k] = v
    }
    return out
  }
}

