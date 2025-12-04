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
}
