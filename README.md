
# NyxPrinter Flutter Plugin

The **NyxPrinter** package is a Flutter plugin that allows you to interact with printers, enabling functionalities such as printing text, barcodes, QR codes, and images. It leverages platform-specific code to communicate with the printer and perform various tasks.

## Features

- **Print Text**: Allows printing formatted text.
- **Print Barcode**: Enables printing of barcodes with customizable dimensions.
- **Print QR Code**: Enables printing of QR codes with customizable dimensions.
- **Print Image**: Allows printing PNG images.

## Installation

To use **NyxPrinter** in your Flutter project, add the following dependency to your `pubspec.yaml` file:

```yaml
dependencies:
  nyx_printer: ^latest_version
```

Then, run the following command in your terminal to install the package:

```bash
flutter pub get
```

## Android Setup

### Package Visibility (Android 11 / API 30+)

Android 11 (API level 30) introduces package visibility restrictions. If your app targets Android 11 or higher, you must declare the printer package visibility in your app's `android/app/src/main/AndroidManifest.xml` inside the `<manifest>` tag:

```xml
<queries>
    <package android:name="net.nyx.printerservice"/>
</queries>
```

## Importing the Package

In your Dart file, import the necessary classes:

```dart
import 'package:nyx_printer/nyx_printer.dart';
```

## Usage

Below is an overview of how to use the **NyxPrinter** package:

### 1. Get Printer Version

Use the `getVersion` method to retrieve the printer's version number. A successful result will return `0`.

```dart
int? version = await NyxPrinter().getVersion();
```

### 2. Print Text

To print text with specific formatting, use the `printText` method. You can optionally provide a `NyxTextFormat` object to define the text style, alignment, size, and more.

```dart
int? result = await NyxPrinter().printText(
  "Hello, World!", 
  textFormat: NyxTextFormat(
    textSize: 20, 
    style: NyxFontStyle.bold, 
    align: NyxAlign.center
  )
);
```

### 3. Print Barcode

To print a barcode, use the `printBarcode` method. You can set the barcode's width and height.

```dart
int? result = await NyxPrinter().printBarcode(
  "1234567890", 
  width: 400, 
  height: 200
);
```

### 4. Print QR Code

To print a QR code, use the `printQrCode` method. Like the barcode, you can adjust the width and height of the QR code.

```dart
int? result = await NyxPrinter().printQrCode(
  "https://flutter.dev", 
  width: 300, 
  height: 300
);
```

### 5. Print Image

To print an image, convert your image to a `Uint8List` (PNG format), and pass it to the `printImage` method.

```dart
Uint8List imageBytes = await getImageBytes();  // Retrieve your PNG image as bytes
int? result = await NyxPrinter().printImage(imageBytes);
```

## NyxTextFormat

The **NyxTextFormat** class provides options for formatting text that is printed.

### Properties:

- `textSize`: Defines the font size (default is 24).
- `underline`: Specifies if the text should be underlined (default is false).
- `textScaleX`: Horizontal text scaling (default is 1.0).
- `textScaleY`: Vertical text scaling (default is 1.0).
- `letterSpacing`: Defines the spacing between letters (default is 0).
- `lineSpacing`: Defines the spacing between lines (default is 0).
- `topPadding`: Padding at the top (default is 0).
- `leftPadding`: Padding on the left (default is 0).
- `align`: Text alignment, can be left, center, or right (default is left).
- `style`: Font style, can be normal, bold, italic, or boldItalic (default is normal).
- `font`: Font family, can be defaultFont, defaultBold, sansSerif, serif, or monospace (default is defaultFont).

### Example:

```dart
NyxTextFormat(
  textSize: 30, 
  underline: true, 
  textScaleX: 1.5, 
  textScaleY: 1.5, 
  align: NyxAlign.center
);
```

### Methods:

The **NyxTextFormat** class provides the `toMap` method to convert the formatting options into a `Map<String, dynamic>`, which can be passed to platform-specific code.

```dart
Map<String, dynamic> formatMap = textFormat.toMap();
```

## Enumerations

### NyxFontStyle

Defines the style of the font:

- `normal`: Regular text.
- `bold`: Bold text.
- `italic`: Italic text.
- `boldItalic`: Bold and italic text.

### NyxFont

Defines the font family:

- `defaultFont`: The default font.
- `defaultBold`: Bold default font.
- `sansSerif`: Sans-serif font.
- `serif`: Serif font.
- `monospace`: Monospace font.

### NyxAlign

Defines text alignment:

- `left`: Left-aligned text.
- `center`: Center-aligned text.
- `right`: Right-aligned text.

## Error Handling

If any operation fails, the `Future<int?>` will return a non-zero error code. Ensure you handle errors appropriately.

### Example Error Handling:

```dart
int? result = await NyxPrinter().printText("Sample Text");
if (result != 0) {
  print("Failed to print text, error code: $result");
} else {
  print("Text printed successfully");
}
```

## Contribution

Feel free to fork the repository, submit issues, or pull requests. Contributions are welcome!

## License

This package is open-source and available under the MIT License.

Based on https://github.com/yyzz2333/NyxPrinterClient
