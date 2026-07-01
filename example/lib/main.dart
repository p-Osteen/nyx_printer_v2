import 'package:flutter/material.dart';
import 'package:nyx_printer_v2/nyx_printer.dart';
import 'package:example/receipt_data.dart';

void main() {
  runApp(const MyApp());
}

/// The root widget of the example application.
class MyApp extends StatelessWidget {
  /// Creates the [MyApp] widget.
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NyxPrinter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00BFA5),
          secondary: Color(0xFF2979FF),
          surface: Color(0xFF1E1E1E),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          elevation: 0,
        ),
      ),
      home: const MyHomePage(),
    );
  }
}

/// The main user interface page of the demo application.
class MyHomePage extends StatefulWidget {
  /// Creates the [MyHomePage] widget.
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final NyxPrinter _nyxPrinter = NyxPrinter();
  String _paperStatus = "Checking...";
  String _printerVersion = "Unknown";
  final List<String> _logs = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  // Appends formatted action feedback/errors to the in-app console logs
  void _addLog(String message) {
    final time = DateTime.now().toString().split(' ')[1].substring(0, 8);
    setState(() {
      _logs.insert(0, "[$time] $message");
      if (_logs.length > 30) {
        _logs.removeLast();
      }
    });
  }

  // Queries the native printer hardware for version info and paper presence
  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final version = await _nyxPrinter.getVersion();
      final paperOutResult = await _nyxPrinter.paperOut();
      setState(() {
        _printerVersion = version?.toString() ?? "Unavailable";
        if (paperOutResult == 0) {
          _paperStatus = "Paper OK";
        } else if (paperOutResult != null) {
          _paperStatus = "Out of Paper ($paperOutResult)";
        } else {
          _paperStatus = "Error / Unknown";
        }
      });
      _addLog("Status checked (Version: $_printerVersion, Paper: $_paperStatus)");
    } catch (e) {
      setState(() {
        _paperStatus = "Error";
        _printerVersion = "Error";
      });
      _addLog("Failed to check status: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Executes a printer transaction asynchronously and reports the outcome code
  Future<void> _runPrintJob(String jobName, Future<dynamic> Function() printAction) async {
    _addLog("Starting print: $jobName...");
    try {
      final result = await printAction();
      if (result == 0 || result == null) {
        _addLog("Success: $jobName completed.");
      } else {
        _addLog("Failed: $jobName returned code $result.");
      }
    } catch (e) {
      _addLog("Error: $jobName failed: $e");
    } finally {
      // Re-verify paper status after print execution
      final paperOutResult = await _nyxPrinter.paperOut();
      setState(() {
        if (paperOutResult == 0) {
          _paperStatus = "Paper OK";
        } else if (paperOutResult != null) {
          _paperStatus = "Out of Paper ($paperOutResult)";
        } else {
          _paperStatus = "Unknown";
        }
      });
    }
  }

  // Maps the paper status text to its respective indicator color
  Color _getPaperStatusColor() {
    if (_paperStatus.contains("Paper OK")) {
      return const Color(0xFF00C853);
    } else if (_paperStatus.contains("Out of Paper") || _paperStatus == "Error") {
      return const Color(0xFFFF1744);
    }
    return const Color(0xFFFFAB00);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Nyx Printer Control Panel",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00BFA5)),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00BFA5)),
              tooltip: "Refresh status",
              onPressed: _checkStatus,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Display device specifications and current status
              Card(
                elevation: 0,
                color: const Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "PRINTER VERSION",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _printerVersion,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: _getPaperStatusColor().withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _getPaperStatusColor(),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _getPaperStatusColor(),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _paperStatus.toUpperCase(),
                              style: TextStyle(
                                color: _getPaperStatusColor(),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Main print actions
              Expanded(
                flex: 3,
                child: ListView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                      child: Text(
                        "PRINT OPERATIONS",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                    _buildOperationTile(
                      icon: Icons.text_snippet_outlined,
                      title: "Print Standard Text",
                      subtitle: "Prints a standard text string to test basic feed",
                      onTap: () => _runPrintJob("Standard Text", () => _nyxPrinter.printText("Standard Sample Text\n")),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationTile(
                      icon: Icons.receipt_long_outlined,
                      title: "Print POS Receipt",
                      subtitle: "Prints a formatted sample POS transaction receipt",
                      onTap: () => _runPrintJob("POS Receipt", () => printSampleReceipt(_nyxPrinter)),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationTile(
                      icon: Icons.format_paint_outlined,
                      title: "Print Styled Text",
                      subtitle: "Prints bold, centered text with underlines",
                      onTap: () => _runPrintJob(
                        "Styled Text",
                        () => _nyxPrinter.printText(
                          "Styled Sample Text",
                          textFormat: NyxTextFormat(
                            align: NyxAlign.center,
                            style: NyxFontStyle.bold,
                            textSize: 20,
                            underline: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationTile(
                      icon: Icons.qr_code_2_outlined,
                      title: "Print QR Code",
                      subtitle: "Prints a standard 300x300 QR code",
                      onTap: () => _runPrintJob("QR Code", () => _nyxPrinter.printQrCode('https://pub.dev/packages/nyx_printer_v2')),
                    ),
                    const SizedBox(height: 8),
                    _buildOperationTile(
                      icon: Icons.barcode_reader,
                      title: "Print Barcode",
                      subtitle: "Prints a standard barcode image",
                      onTap: () => _runPrintJob("Barcode", () => _nyxPrinter.printBarcode('1122334455')),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Console log panel for execution tracking
              const Padding(
                padding: EdgeInsets.only(left: 4.0, bottom: 8.0),
                child: Text(
                  "CONSOLE LOGS",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade900, width: 0.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: _logs.isEmpty
                            ? const Center(
                                child: Text(
                                  "No logs recorded yet.",
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(8.0),
                                itemCount: _logs.length,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 2.0),
                                    child: Text(
                                      _logs[index],
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10,
                                        color: Color(0xFFCFD8DC),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_logs.isNotEmpty) ...[
                        Divider(height: 1, color: Colors.grey.shade900),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _logs.clear();
                            });
                          },
                          style: TextButton.styleFrom(
                            minimumSize: const Size.fromHeight(32),
                            padding: EdgeInsets.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            "Clear Logs",
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOperationTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Colors.grey.shade900, width: 0.5),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2979FF)),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
        onTap: onTap,
        dense: true,
      ),
    );
  }
}
