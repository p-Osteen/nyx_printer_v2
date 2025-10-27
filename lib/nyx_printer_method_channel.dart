import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'nyx_printer_platform_interface.dart';
import 'nyx_text_format.dart';

/// A platform-specific implementation of [NyxPrinterPlatform] using method channels.
/// This class communicates with the native platform to perform printing tasks.
class MethodChannelNyxPrinter extends NyxPrinterPlatform {
  @visibleForTesting

  /// The method channel used to communicate with the native platform for printer-related operations.
  /// It allows sending method calls and receiving results from the native platform.
  final methodChannel = const MethodChannel('nyx_printer');

  /// Timeout duration for method calls
  static const Duration _methodTimeout = Duration(seconds: 10);

  /// Retrieves the version of the printer.
  ///
  /// Returns an [int] representing the version, or null if the operation fails.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> getVersion() async {
    try {
      final version = await methodChannel
          .invokeMethod<int?>('getVersion')
          .timeout(_methodTimeout);
      return version;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('getVersion timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message:
            'Operation timed out after ${_methodTimeout.inSeconds} seconds',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('getVersion failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Prints the provided text with the given format.
  ///
  /// [text] The text to print.
  /// [textFormat] The formatting options for the text.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  /// Throws [ArgumentError] if text is empty.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> printText(String text, NyxTextFormat textFormat) async {
    if (text.isEmpty) {
      throw ArgumentError('Text cannot be empty');
    }

    try {
      // Prepare the data to be sent to the native platform
      Map<String, dynamic> data = {"text": text};
      data.addAll(textFormat.toMap()); // Add the formatting options

      // Invoke the native method to print the text
      final result = await methodChannel
          .invokeMethod<int?>('printText', data)
          .timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('printText timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message:
            'Print operation timed out after ${_methodTimeout.inSeconds} seconds',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('printText failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Prints a barcode with the provided parameters.
  ///
  /// [text] The data to encode in the barcode.
  /// [width] The width of the barcode.
  /// [height] The height of the barcode.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  /// Throws [ArgumentError] if parameters are invalid.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> printBarcode(String text, int width, int height) async {
    if (text.isEmpty) {
      throw ArgumentError('Barcode text cannot be empty');
    }
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Barcode width and height must be positive values');
    }

    try {
      final result = await methodChannel.invokeMethod<int?>('printBarcode', {
        "text": text,
        "width": width,
        "height": height,
      }).timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('printBarcode timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Barcode print operation timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('printBarcode failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Prints a QR code with the provided parameters.
  ///
  /// [text] The data to encode in the QR code.
  /// [width] The width of the QR code.
  /// [height] The height of the QR code.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  /// Throws [ArgumentError] if parameters are invalid.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> printQrCode(String text, int width, int height) async {
    if (text.isEmpty) {
      throw ArgumentError('QR code text cannot be empty');
    }
    if (width <= 0 || height <= 0) {
      throw ArgumentError('QR code width and height must be positive values');
    }

    try {
      final result = await methodChannel.invokeMethod<int?>('printQrCode', {
        "text": text,
        "width": width,
        "height": height,
      }).timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('printQrCode timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'QR code print operation timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('printQrCode failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Prints an image (bitmap) provided as a byte array.
  ///
  /// [bytes] The byte data representing the image to print.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  /// Throws [ArgumentError] if bytes is empty.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> printBitmap(Uint8List bytes) async {
    if (bytes.isEmpty) {
      throw ArgumentError('Image bytes cannot be empty');
    }

    try {
      final result = await methodChannel.invokeMethod<int?>(
          'printBitmap', {"bytes": bytes}).timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('printBitmap timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Bitmap print operation timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('printBitmap failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Invokes the 'paperOut' method on the platform's method channel to check paper status.
  ///
  /// Returns an [int?], where 0 indicates paper is present, any other value indicates
  /// paper is out, or null if the operation fails or encounters an error.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> paperOut() async {
    try {
      final result = await methodChannel
          .invokeMethod<int?>('paperOut')
          .timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('paperOut timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Paper status check timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('paperOut failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Gets the printer service version.
  ///
  /// Returns a [String] representing the service version, or null if it fails.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<String?> getServiceVersion() async {
    try {
      final result = await methodChannel
          .invokeMethod<String?>('getServiceVersion')
          .timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('getServiceVersion timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Service version check timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('getServiceVersion failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Gets the printer model information.
  ///
  /// Returns a [String] representing the printer model, or null if it fails.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<String?> getPrinterModel() async {
    try {
      final result = await methodChannel
          .invokeMethod<String?>('getPrinterModel')
          .timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('getPrinterModel timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Printer model check timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('getPrinterModel failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Gets the printer status.
  ///
  /// Returns an [int] representing the printer status, or null if it fails.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> getPrinterStatus() async {
    try {
      final result = await methodChannel
          .invokeMethod<int?>('getPrinterStatus')
          .timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('getPrinterStatus timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Printer status check timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('getPrinterStatus failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }

  /// Feeds paper by the specified number of pixels.
  ///
  /// [pixels] The number of pixels to feed the paper.
  /// Returns an [int] representing the result of the operation, or null if it fails.
  /// Throws [ArgumentError] if pixels is negative.
  /// Throws [PlatformException] if the service is not bound or other errors occur.
  @override
  Future<int?> paperFeed(int pixels) async {
    if (pixels < 0) {
      throw ArgumentError('Paper feed pixels must be non-negative');
    }

    try {
      final result = await methodChannel.invokeMethod<int?>('paperFeed', {
        'pixels': pixels,
      }).timeout(_methodTimeout);
      return result;
    } on TimeoutException catch (e) {
      if (kDebugMode) {
        print('paperFeed timed out: $e');
      }
      throw PlatformException(
        code: 'TIMEOUT',
        message: 'Paper feed operation timed out',
      );
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print('paperFeed failed: ${e.code} - ${e.message}');
      }
      rethrow;
    }
  }
}
