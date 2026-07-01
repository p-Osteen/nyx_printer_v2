// ignore_for_file: public_member_api_docs

import 'package:nyx_printer_v2/nyx_printer.dart';

/// Represents a single item listed on the purchase receipt.
class ReceiptItem {
  /// The display name of the item.
  final String name;

  /// The quantity of the item purchased.
  final int qty;

  /// The unit price of the item.
  final double price;

  /// Creates a new receipt item instance.
  const ReceiptItem(this.name, this.qty, this.price);

  /// Calculates the total cost for this item based on the quantity and price.
  double get total => qty * price;
}

/// Formats and prints a structured sample POS receipt using sequential print operations.
/// Optimized for standard 58mm thermal receipt paper (32 character width).
Future<void> printSampleReceipt(NyxPrinter printer) async {
  const int paperWidth = 32;

  // Helper to format a two-column row (left-aligned label, right-aligned value)
  String formatRow(String label, String value) {
    final spacesCount = paperWidth - label.length - value.length;
    final spacing = " " * (spacesCount > 0 ? spacesCount : 1);
    return "$label$spacing$value\n";
  }

  // Helper to format item details (e.g. "  2 x $3.50        $7.00")
  String formatItemDetails(int qty, double price, double total) {
    final details = "  $qty x \$${price.toStringAsFixed(2)}";
    final totalStr = "\$${total.toStringAsFixed(2)}";
    final spacesCount = paperWidth - details.length - totalStr.length;
    final spacing = " " * (spacesCount > 0 ? spacesCount : 1);
    return "$details$spacing$totalStr\n";
  }

  const divider = "--------------------------------\n";

  // 1. Store Header Info
  await printer.printText(
    "LOREM IPSUM\n",
    textFormat: NyxTextFormat(
      align: NyxAlign.center,
      style: NyxFontStyle.bold,
      textSize: 26,
    ),
  );
  await printer.printText(
    "Lorem Ipsum Dolor Sit Amet\nTel: +1 (112) 233-4455\n",
    textFormat: NyxTextFormat(
      align: NyxAlign.center,
      textSize: 20,
    ),
  );

  // Section Divider
  await printer.printText(
    divider,
    textFormat: NyxTextFormat(align: NyxAlign.center, textSize: 20),
  );

  // 2. Transaction Metadata
  await printer.printText(
    "Date: 2026-07-01  12:30 PM\n"
    "Receipt No: #TRX-1122334455\n"
    "Cashier: Lorem Ipsum\n",
    textFormat: NyxTextFormat(
      align: NyxAlign.left,
      textSize: 20,
    ),
  );

  // Section Divider
  await printer.printText(
    divider,
    textFormat: NyxTextFormat(align: NyxAlign.center, textSize: 20),
  );

  const items = [
    ReceiptItem("Lorem Ipsum A", 2, 3.50),
    ReceiptItem("Lorem Ipsum B", 1, 2.80),
    ReceiptItem("Lorem Ipsum C", 3, 3.00),
  ];

  // 3. Print Item Rows
  for (final item in items) {
    // Print item name
    await printer.printText(
      "${item.name}\n",
      textFormat: NyxTextFormat(
        align: NyxAlign.left,
        style: NyxFontStyle.bold,
        textSize: 20,
      ),
    );

    // Print item quantity, unit price, and item total right-aligned
    await printer.printText(
      formatItemDetails(item.qty, item.price, item.total),
      textFormat: NyxTextFormat(
        align: NyxAlign.left,
        textSize: 20,
      ),
    );
  }

  // Section Divider
  await printer.printText(
    divider,
    textFormat: NyxTextFormat(align: NyxAlign.center, textSize: 20),
  );

  // 4. Total Summary Calculations
  final subtotal = items.fold<double>(0, (sum, item) => sum + item.total);
  final tax = subtotal * 0.08;
  final total = subtotal + tax;

  await printer.printText(
    formatRow("Subtotal:", "\$${subtotal.toStringAsFixed(2)}") +
    formatRow("Tax (8%):", "\$${tax.toStringAsFixed(2)}"),
    textFormat: NyxTextFormat(
      align: NyxAlign.left,
      textSize: 20,
    ),
  );
  await printer.printText(
    formatRow("TOTAL:", "\$${total.toStringAsFixed(2)}"),
    textFormat: NyxTextFormat(
      align: NyxAlign.left,
      style: NyxFontStyle.bold,
      textSize: 22,
    ),
  );

  // Section Divider
  await printer.printText(
    divider,
    textFormat: NyxTextFormat(align: NyxAlign.center, textSize: 20),
  );

  // 5. Footer loyalty message
  await printer.printText(
    "Thank you for your visit!\nScan to view your loyalty points.\n",
    textFormat: NyxTextFormat(
      align: NyxAlign.center,
      style: NyxFontStyle.italic,
      textSize: 20,
    ),
  );

  // 6. QR Code for the receipt URL
  await printer.printQrCode(
    "https://example.com/receipt/1122334455",
    width: 200,
    height: 200,
  );

  // 7. Extra feeding space to allow tearing off cleanly
  await printer.printText("\n\n\n", textFormat: NyxTextFormat(textSize: 24));
}
