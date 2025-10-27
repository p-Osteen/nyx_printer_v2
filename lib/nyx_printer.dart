import 'package:flutter/services.dart';
import 'nyx_printer_platform_interface.dart';
import 'nyx_text_format.dart';
import 'dart:typed_data'; // Make sure to import this for Uint8List

export 'nyx_text_format.dart';

/// The [NyxPrinter] class provides methods to interact with the printer and perform various print operations.
///
/// This class uses the platform interface [NyxPrinterPlatform] to send print commands to the native platform
/// (iOS or Android). The class abstracts the platform-specific details, allowing you to call common methods
/// such as printing text, barcodes, QR codes, and bitmaps, without worrying about platform implementation details.
class NyxPrinter {
  /// [getVersion] will return printer version number.
  /// success result is 0.
  Future<int?> getVersion() {
    return NyxPrinterPlatform.instance.getVersion();
  }

  /// [printText] will print text
  /// to format text you can use [NyxTextFormat] to set font size or font style ...etc
  /// success result is 0.
  Future<int?> printText(String text, {NyxTextFormat? textFormat}) {
    return NyxPrinterPlatform.instance
        .printText(text, textFormat ?? NyxTextFormat());
  }

  /// [printBarcode] will print barcode and you can set width and height.
  /// default width is 300
  /// default height is 160
  /// success result is 0.
  Future<int?> printBarcode(String text, {int? width, int? height}) {
    return NyxPrinterPlatform.instance
        .printBarcode(text, width ?? 300, height ?? 160);
  }

  /// [printQrCode] will print QR code and you can set width and height.
  /// default width is 300
  /// default height is 300
  /// success result is 0.
  Future<int?> printQrCode(String text, {int? width, int? height}) {
    return NyxPrinterPlatform.instance
        .printQrCode(text, width ?? 300, height ?? 300);
  }

  /// [printImage] will print only png images.
  /// success result is 0.
  Future<int?> printImage(Uint8List bytes) {
    return NyxPrinterPlatform.instance.printBitmap(bytes);
  }

  /// Checks if the printer is out of paper.
  ///
  /// Returns 0 if paper is present, or an error code if paper is out.
  ///
  /// This function communicates with the NyxPrinter platform to determine
  /// the printer's paper status. A `null` result indicates an unexpected issue.
  Future<int?> paperOut() {
    return NyxPrinterPlatform.instance.paperOut();
  }

  /// Gets the printer service version.
  ///
  /// Returns a [String] representing the service version, or null if it fails.
  /// This is useful for debugging and ensuring compatibility.
  Future<String?> getServiceVersion() {
    return NyxPrinterPlatform.instance.getServiceVersion();
  }

  /// Gets the printer model information.
  ///
  /// Returns a [String] representing the printer model, or null if it fails.
  /// This helps identify which printer is currently connected.
  Future<String?> getPrinterModel() {
    return NyxPrinterPlatform.instance.getPrinterModel();
  }

  /// Gets the current printer status.
  ///
  /// Returns an [int] representing the printer status:
  /// - 0: Ready/Normal
  /// - Other values indicate specific error conditions
  /// - null: Operation failed or service unavailable
  Future<int?> getPrinterStatus() {
    return NyxPrinterPlatform.instance.getPrinterStatus();
  }

  /// Feeds paper by the specified number of pixels.
  ///
  /// [pixels] The number of pixels to feed the paper. Must be non-negative.
  /// Returns 0 on success, or an error code on failure.
  ///
  /// This is useful for creating spacing between print jobs or
  /// positioning the paper for optimal cutting.
  Future<int?> paperFeed(int pixels) {
    if (pixels < 0) {
      throw ArgumentError('Paper feed pixels must be non-negative');
    }
    return NyxPrinterPlatform.instance.paperFeed(pixels);
  }

  /// Checks if the printer is ready for printing.
  ///
  /// Returns `true` if the printer is ready, `false` otherwise.
  /// This combines multiple status checks for convenience.
  Future<bool> isReady() async {
    try {
      final status = await getPrinterStatus();
      final paperStatus = await paperOut();
      
      // Status 0 means ready, paper status 0 means paper present
      return status == 0 && paperStatus == 0;
    } catch (e) {
      // If any check fails, consider the printer not ready
      return false;
    }
  }

  /// Checks if the printer service is currently connected and available.
  ///
  /// Returns `true` if the service is connected and ready to use, `false` otherwise.
  /// This should be called before attempting any print operations to ensure availability.
  Future<bool> isServiceConnected() {
    return NyxPrinterPlatform.instance.isServiceConnected();
  }

  /// Validates printer connection and basic functionality.
  ///
  /// Returns a [Map] with diagnostic information about the printer.
  /// Useful for troubleshooting connection issues.
  Future<Map<String, dynamic>> getDiagnostics() async {
    final diagnostics = <String, dynamic>{};
    
    try {
      diagnostics['serviceConnected'] = await isServiceConnected();
    } catch (e) {
      diagnostics['serviceConnected'] = false;
    }
    
    try {
      diagnostics['version'] = await getVersion();
    } catch (e) {
      diagnostics['version'] = 'Error: $e';
    }
    
    try {
      diagnostics['serviceVersion'] = await getServiceVersion();
    } catch (e) {
      diagnostics['serviceVersion'] = 'Error: $e';
    }
    
    try {
      diagnostics['model'] = await getPrinterModel();
    } catch (e) {
      diagnostics['model'] = 'Error: $e';
    }
    
    try {
      diagnostics['status'] = await getPrinterStatus();
    } catch (e) {
      diagnostics['status'] = 'Error: $e';
    }
    
    try {
      diagnostics['paperOut'] = await paperOut();
    } catch (e) {
      diagnostics['paperOut'] = 'Error: $e';
    }
    
    try {
      diagnostics['isReady'] = await isReady();
    } catch (e) {
      diagnostics['isReady'] = false;
    }
    
    return diagnostics;
  }
}
