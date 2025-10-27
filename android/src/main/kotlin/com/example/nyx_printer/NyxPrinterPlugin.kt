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
  private var isServiceConnected = false
  private var reconnectAttempts = 0
  private val maxReconnectAttempts = 5

  private val connService = object: ServiceConnection {
    override fun onServiceDisconnected(name: ComponentName?) {
      printerService = null
      isServiceConnected = false
      
      // Attempt to reconnect with exponential backoff
      if (reconnectAttempts < maxReconnectAttempts) {
        val delay = (1000 * Math.pow(2.0, reconnectAttempts.toDouble())).toLong()
        handler.postDelayed({
          reconnectAttempts++
          startService(appContext)
        }, delay)
      }
    }

    override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
      printerService = IPrinterService.Stub.asInterface(service)
      isServiceConnected = true
      reconnectAttempts = 0 // Reset counter on successful connection
    }
  }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    appContext = flutterPluginBinding.applicationContext
    startService(appContext)
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "nyx_printer")
    channel.setMethodCallHandler(this)
  }

  private fun startService(context: Context) {
    try {
      val intent = Intent().apply {
        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
          setPackage("com.incar.printerservice")
          action = "com.incar.printerservice.IPrinterService"
        } else {
          setPackage("net.nyx.printerservice")
          action = "net.nyx.printerservice.IPrinterService"
        }
      }
      
      val success = context.bindService(intent, connService, Context.BIND_AUTO_CREATE)
      if (!success) {
        // Service binding failed, try the alternative package
        val alternativeIntent = Intent().apply {
          if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.TIRAMISU) {
            setPackage("net.nyx.printerservice")
            action = "net.nyx.printerservice.IPrinterService"
          } else {
            setPackage("com.incar.printerservice")
            action = "com.incar.printerservice.IPrinterService"
          }
        }
        context.bindService(alternativeIntent, connService, Context.BIND_AUTO_CREATE)
      }
    } catch (e: Exception) {
      // Log the error or handle appropriately
      e.printStackTrace()
    }
  }

  private fun stopService(context: Context) {
    try {
      if (isServiceConnected) {
        context.unbindService(connService)
        isServiceConnected = false
      }
    } catch (e: Exception) {
      // Service might already be unbound
      e.printStackTrace()
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (printerService == null) {
      result.error("SERVICE_NOT_BOUND", "Printer service is not bound", null)
      return
    }

    try {
      when(call.method) {
        "getVersion" -> {
          singleThreadExecutor.submit {
            try {
              val ret = printerService?.getPrinterVersion(version) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to get printer version", e.message) 
              }
            }
          }
        }
        "getServiceVersion" -> {
          singleThreadExecutor.submit {
            try {
              val serviceVersion = printerService?.serviceVersion
              handler.post { result.success(serviceVersion) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to get service version", e.message) 
              }
            }
          }
        }
        "getPrinterModel" -> {
          singleThreadExecutor.submit {
            try {
              val model = arrayOfNulls<String>(1)
              val ret = printerService?.getPrinterModel(model) ?: -1
              handler.post { 
                if (ret == 0) {
                  result.success(model[0])
                } else {
                  result.success(null)
                }
              }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to get printer model", e.message) 
              }
            }
          }
        }
        "getPrinterStatus" -> {
          singleThreadExecutor.submit {
            try {
              val status = printerService?.printerStatus ?: -1
              handler.post { result.success(status) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to get printer status", e.message) 
              }
            }
          }
        }
        "paperOut" -> {
          singleThreadExecutor.submit {
            try {
              val ret = printerService?.paperOut(80) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to check paper status", e.message) 
              }
            }
          }
        }
        "paperFeed" -> {
          singleThreadExecutor.submit {
            try {
              val pixels = call.argument<Int>("pixels") ?: 0
              val ret = printerService?.paperOut(pixels) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to feed paper", e.message) 
              }
            }
          }
        }
        "printText" -> {
          singleThreadExecutor.submit {
            try {
              val text = call.argument<String>("text")
              if (text.isNullOrEmpty()) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "Text cannot be null or empty", null) 
                }
                return@submit
              }

              val textFormat = PrintTextFormat().apply {
                ali = call.argument<Int>("align") ?: 0
                textSize = call.argument("textSize") ?: 24
                isUnderline = call.argument<Boolean>("underline") ?: false
                textScaleX = call.argument<Double>("textScaleX")?.toFloat() ?: 1f
                textScaleY = call.argument<Double>("textScaleY")?.toFloat() ?: 1f
                letterSpacing = call.argument<Double>("letterSpacing")?.toFloat() ?: 0f
                lineSpacing = call.argument<Double>("lineSpacing")?.toFloat() ?: 0f
                topPadding = call.argument("topPadding") ?: 0
                leftPadding = call.argument("leftPadding") ?: 0
                style = call.argument<Int>("style") ?: 0
                font = call.argument<Int>("font") ?: 0
                path = call.argument<String>("path")
              }

              val ret = printerService?.printText(text, textFormat) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to print text", e.message) 
              }
            }
          }
        }
        "printBarcode" -> {
          singleThreadExecutor.submit {
            try {
              val text = call.argument<String>("text")
              val width = call.argument<Int>("width") ?: 300
              val height = call.argument<Int>("height") ?: 160
              
              if (text.isNullOrEmpty()) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "Barcode text cannot be null or empty", null) 
                }
                return@submit
              }
              
              if (width <= 0 || height <= 0) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "Barcode width and height must be positive", null) 
                }
                return@submit
              }

              val ret = printerService?.printBarcode(text, width, height, 1, 1) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to print barcode", e.message) 
              }
            }
          }
        }
        "printQrCode" -> {
          singleThreadExecutor.submit {
            try {
              val text = call.argument<String>("text")
              val width = call.argument<Int>("width") ?: 300
              val height = call.argument<Int>("height") ?: 300
              
              if (text.isNullOrEmpty()) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "QR code text cannot be null or empty", null) 
                }
                return@submit
              }
              
              if (width <= 0 || height <= 0) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "QR code width and height must be positive", null) 
                }
                return@submit
              }

              val ret = printerService?.printQrCode(text, width, height, 1) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to print QR code", e.message) 
              }
            }
          }
        }
        "printBitmap" -> {
          singleThreadExecutor.submit {
            try {
              val byteArray = call.argument<ByteArray>("bytes")
              if (byteArray == null || byteArray.isEmpty()) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "Image bytes cannot be null or empty", null) 
                }
                return@submit
              }

              val decoded = BitmapFactory.decodeStream(ByteArrayInputStream(byteArray))
              if (decoded == null) {
                handler.post { 
                  result.error("INVALID_ARGUMENT", "Failed to decode image bytes", null) 
                }
                return@submit
              }

              val ret = printerService?.printBitmap(decoded, 0, 1) ?: -1
              handler.post { result.success(ret) }
            } catch (e: RemoteException) {
              handler.post { 
                result.error("REMOTE_EXCEPTION", "Failed to print bitmap", e.message) 
              }
            } catch (e: Exception) {
              handler.post { 
                result.error("DECODE_ERROR", "Failed to decode image", e.message) 
              }
            }
          }
        }
        "isServiceConnected" -> {
          result.success(isServiceConnected && printerService != null)
        }
        else -> result.notImplemented()
      }
    } catch (e: RemoteException) {
      result.error("REMOTE_EXCEPTION", "RemoteException occurred", e.message)
    } catch (e: Exception) {
      result.error("UNEXPECTED_ERROR", "An unexpected error occurred", e.message)
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
