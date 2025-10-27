import 'package:flutter/services.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'nyx_printer_method_channel.dart';
import 'nyx_text_format.dart';

/// Abstract class that serves as the platform interface for the Nyx Printer.
///
/// This class defines the common methods for interacting with the Nyx printer
/// across different platforms (iOS, Android). Platform-specific implementations
/// should extend this class and override the methods to perform actual printer
/// operations.
abstract class NyxPrinterPlatform extends PlatformInterface {
  /// The constructor for [NyxPrinterPlatform].
  ///
  /// This constructor calls the superclass constructor with a token to verify the platform interface's integrity.
  /// It ensures that any platform-specific implementation correctly adheres to the interface token validation.
  NyxPrinterPlatform() : super(token: _token);

  // Token used to verify the instance of the platform interface.
  static final Object _token = Object();

  // The current instance of the platform interface. This is initialized with the default implementation.
  static NyxPrinterPlatform _instance = MethodChannelNyxPrinter();

  /// Gets the current instance of the platform interface.
  ///
  /// This provides access to platform-specific methods for printing operations.
  static NyxPrinterPlatform get instance => _instance;

  /// Sets a custom instance for the platform interface.
  ///
  /// This method is used for testing purposes or when swapping the platform
  /// interface with a different implementation.
  static set instance(NyxPrinterPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Retrieves the version of the connected printer.
  ///
  /// Returns an [int] representing the printer's version, or null if the operation fails.
  Future<int?> getVersion() {
    return instance.getVersion();
  }

  /// Prints the provided text with the specified text format.
  ///
  /// [text] The text to be printed.
  /// [textFormat] The formatting options to apply to the text.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  Future<int?> printText(String text, NyxTextFormat textFormat) {
    return instance.printText(text, textFormat);
  }

  /// Prints a barcode with the specified data and dimensions.
  ///
  /// [text] The data to encode in the barcode.
  /// [width] The width of the barcode.
  /// [height] The height of the barcode.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  Future<int?> printBarcode(String text, int width, int height) {
    return instance.printBarcode(text, width, height);
  }

  /// Prints a QR code with the specified data and dimensions.
  ///
  /// [text] The data to encode in the QR code.
  /// [width] The width of the QR code.
  /// [height] The height of the QR code.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  Future<int?> printQrCode(String text, int width, int height) {
    return instance.printQrCode(text, width, height);
  }

  /// Prints a bitmap image provided as a byte array.
  ///
  /// [bytes] The byte data representing the image to print.
  ///
  /// Returns an [int] representing the result of the print operation, or null if it fails.
  Future<int?> printBitmap(Uint8List bytes) {
    return instance.printBitmap(bytes);
  }

  /// Checks if the printer is out of paper.
  ///
  /// Returns an [int] where 0 indicates paper is present,
  /// any other value signifies paper is out, or null if the operation fails.
  Future<int?> paperOut() {
    return instance.paperOut();
  }

  /// Gets the printer service version.
  ///
  /// Returns a [String] representing the service version, or null if it fails.
  Future<String?> getServiceVersion() {
    return instance.getServiceVersion();
  }

  /// Gets the printer model information.
  ///
  /// Returns a [String] representing the printer model, or null if it fails.
  Future<String?> getPrinterModel() {
    return instance.getPrinterModel();
  }

  /// Gets the printer status.
  ///
  /// Returns an [int] representing the printer status, or null if it fails.
  Future<int?> getPrinterStatus() {
    return instance.getPrinterStatus();
  }

  /// Feeds paper by the specified number of pixels.
  ///
  /// [pixels] The number of pixels to feed the paper.
  /// Returns an [int] representing the result of the operation, or null if it fails.
  Future<int?> paperFeed(int pixels) {
    return instance.paperFeed(pixels);
  }

  /// Checks if the printer service is currently connected.
  ///
  /// Returns `true` if the service is connected and ready to use, `false` otherwise.
  Future<bool> isServiceConnected() {
    return instance.isServiceConnected();
  }
}
