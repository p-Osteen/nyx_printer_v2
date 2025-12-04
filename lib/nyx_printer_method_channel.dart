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

  /// Retrieves the version of the printer.
  ///
  /// Returns an [int] representing the version, or null if the operation fails.
  @override
  Future<int?> getVersion() async {
    final version = await methodChannel.invokeMethod<int?>('getVersion');
    return version;
  }

  /// Prints the provided text with the given format.
  ///
  /// [text] The text to print.
  /// [textFormat] The formatting options for the text.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  @override
  Future<int?> printText(String text, NyxTextFormat textFormat) async {
    // Prepare the data to be sent to the native platform
    Map<String, dynamic> data = {"text": text};
    data.addAll(textFormat.toMap()); // Add the formatting options

    // Invoke the native method to print the text
    final result = await methodChannel.invokeMethod<int?>('printText', data);
    return result;
  }

  /// Prints a barcode with the provided parameters.
  ///
  /// [text] The data to encode in the barcode.
  /// [width] The width of the barcode.
  /// [height] The height of the barcode.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  @override
  Future<int?> printBarcode(String text, int width, int height) async {
    final result = await methodChannel.invokeMethod<int?>('printBarcode', {
      "text": text,
      "width": width,
      "height": height,
    });
    return result;
  }

  /// Prints a QR code with the provided parameters.
  ///
  /// [text] The data to encode in the QR code.
  /// [width] The width of the QR code.
  /// [height] The height of the QR code.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  @override
  Future<int?> printQrCode(String text, int width, int height) async {
    final result = await methodChannel.invokeMethod<int?>('printQrCode', {
      "text": text,
      "width": width,
      "height": height,
    });
    return result;
  }

  /// Prints an image (bitmap) provided as a byte array.
  ///
  /// [bytes] The byte data representing the image to print.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  @override
  Future<int?> printBitmap(Uint8List bytes) async {
    final result =
        await methodChannel.invokeMethod<int?>('printBitmap', {"bytes": bytes});
    return result;
  }

  @override

  /// Invokes the 'paperOut' method on the platform's method channel to check paper status.
  ///
  /// Returns an [int?], where 0 indicates paper is present, any other value indicates
  /// paper is out, or null if the operation fails or encounters an error.
  Future<int?> paperOut() async {
    final result = await methodChannel.invokeMethod<int?>('paperOut');
    return result;
  }
}
