// ignore_for_file: public_member_api_docs

import 'package:example/extension.dart';
import 'package:flutter/material.dart';
import 'package:nyx_printer_v2/nyx_printer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'NyxPrinter Demo',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NyxPrinter nyxPrinter = NyxPrinter();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text("Nyx Printer Sample"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Sample Text').onTap(
            () => nyxPrinter.printText("Sample Text"),
          ),
          const SizedBox(height: 12),
          const Text('Sample Text with Styling').onTap(
            () => nyxPrinter.printText(
              "Sample Text",
              textFormat: NyxTextFormat(
                align: NyxAlign.center,
                style: NyxFontStyle.bold,
                textSize: 18,
                underline: true,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Print QR Code').onTap(
            () {
              nyxPrinter.printQrCode('Sample QR Code');
            },
          ),
          const SizedBox(height: 12),
          const Text('Print BarCode').onTap(
            () {
              nyxPrinter.printBarcode('Sample Print Code');
            },
          ),
        ],
      ),
    );
  }
}
