package com.example.nyx_printer

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.graphics.BitmapFactory
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.RemoteException
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import net.nyx.printerservice.print.IPrinterService
import net.nyx.printerservice.print.PrintTextFormat
import java.io.ByteArrayInputStream
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class NyxPrinterPlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel: MethodChannel
  private var printerService: IPrinterService? = null
  private lateinit var appContext: Context
  private val version = arrayOfNulls<String>(1)
  private val singleThreadExecutor: ExecutorService = Executors.newSingleThreadExecutor()
  private val handler = Handler(Looper.getMainLooper())

  private val connService = object: ServiceConnection {
    override fun onServiceDisconnected(name: ComponentName?) {
      printerService = null
      handler.postDelayed({
        startService(appContext)
      }, 5000)
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
      printerService = IPrinterService.Stub.asInterface(service)
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    appContext = flutterPluginBinding.applicationContext
    startService(appContext)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nyx_printer")
    channel.setMethodCallHandler(this)
  }

  private fun startService(context: Context) {
    val intent = Intent().apply {
      if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
        setPackage("com.incar.printerservice")
        action = "com.incar.printerservice.IPrinterService"
      } else {
        setPackage("net.nyx.printerservice")
        action = "net.nyx.printerservice.IPrinterService"
      }
    }
    context.bindService(intent, connService, Context.BIND_AUTO_CREATE)
  }

  private fun stopService(context: Context) {
    context.unbindService(connService)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (printerService == null) {
      result.error("SERVICE_NOT_BOUND", "Printer service is not bound", null)
      return
    }

    try {
      when(call.method) {
        "getVersion" -> {
          val ret = printerService?.getPrinterVersion(version) ?: -1
          result.success(ret)
        }
        "paperOut" ->{
          val ret = printerService?.paperOut(80) ?: -1
          result.success(ret)
        }
        "printText" -> {
          val textFormat = PrintTextFormat().apply {
            ali = call.argument<Int>("align") ?: 0
            textSize = call.argument("textSize") ?: 80
            textScaleX = call.argument<Double>("textScaleX")?.toFloat() ?: 1f
            textScaleY = call.argument<Double>("textScaleY")?.toFloat() ?: 1f
            letterSpacing = call.argument<Double>("letterSpacing")?.toFloat() ?: 0f
            lineSpacing = call.argument<Double>("lineSpacing")?.toFloat() ?: 0f
            topPadding = call.argument("topPadding") ?: 0
            leftPadding = call.argument("leftPadding") ?: 0
            style = call.argument<Int>("style") ?: 0
            font = call.argument<Int>("font") ?: 0
          }

          val ret = printerService?.printText(call.argument<String>("text") ?: "", textFormat) ?: -1
          result.success(ret)
        }
        "printBarcode" -> {
          val ret = printerService?.printBarcode(
            call.argument("text") ?: "",
            call.argument("width") ?: 100,
            call.argument("height") ?: 50,
            1, 1
          ) ?: -1
          result.success(ret)
        }
        "printQrCode" -> {
          val ret = printerService?.printQrCode(
            call.argument("text") ?: "",
            call.argument("width") ?: 100,
            call.argument("height") ?: 100,
            1
          ) ?: -1
          result.success(ret)
        }
        "printBitmap" -> {
          val byteArray = call.argument<ByteArray>("bytes")
          if (byteArray != null) {
            val decoded = BitmapFactory.decodeStream(ByteArrayInputStream(byteArray))
            val ret = printerService?.printBitmap(decoded, 1, 1) ?: -1
            result.success(ret)
          } else {
            result.error("INVALID_ARGUMENT", "Bytes are null", null)
          }
        }
        else -> result.notImplemented()
      }
    } catch (e: RemoteException) {
      result.error("REMOTE_EXCEPTION", "RemoteException occurred", e.message)
    }
  }

  private fun paperOut() {
    singleThreadExecutor.submit {
      try {
        printerService?.paperOut(80)
      } catch (e: RemoteException) {
        e.printStackTrace()
      }
    }
  }

  private fun paperOutText(size: Int) {
    singleThreadExecutor.submit {
      try {
        printerService?.paperOut(size)
      } catch (e: RemoteException) {
        e.printStackTrace()
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    stopService(binding.applicationContext)
    channel.setMethodCallHandler(null)
  }
}