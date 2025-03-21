import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:url_launcher/url_launcher.dart';
import '../headers/header_child.dart';

class MaQRScreen extends StatefulWidget {
  const MaQRScreen({Key? key}) : super(key: key);

  @override
  State<MaQRScreen> createState() => _MaQRScreenState();
}

class _MaQRScreenState extends State<MaQRScreen> {
  final MobileScannerController _controller = MobileScannerController();
  String? scannedData;
  bool isProcessing = false;

  void _onDetect(BarcodeCapture barcodeCapture) async {
    if (isProcessing) return;
    setState(() {
      isProcessing = true;
    });
    // Get the first detected barcode.
    final List<Barcode> barcodes = barcodeCapture.barcodes;
    if (barcodes.isNotEmpty) {
      final code = barcodes.first.rawValue;
      debugPrint("Scanned code: $code");
      setState(() {
        scannedData = code;
      });
      if (scannedData != null) {
        if (scannedData!.toLowerCase().contains("momo")) {
          _showMoMoDialog(scannedData!);
        } else {
          Uri? uri = Uri.tryParse(scannedData!);
          if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
            _showURLDialog(scannedData!, uri);
          } else {
            _showResultDialog(scannedData!);
          }
        }
      }
    }
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      isProcessing = false;
    });
  }

  void _showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kết quả Mã QR"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showURLDialog(String result, Uri uri) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Kết quả Mã QR"),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () async {
              if (await canLaunchUrl(uri)) {
                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              }
            },
            child: const Text("Open Browser"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showMoMoDialog(String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("MoMo Payment QR"),
        content: Text("Detected MoMo payment QR:\n\n$result"),
        actions: [
          TextButton(
            onPressed: () {
              // Process MoMo QR further if needed.
              Navigator.pop(context);
            },
            child: const Text("Proceed"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Build the QR scanner view using MobileScanner, with a custom overlay.
  Widget _buildQRScanner() {
    return Expanded(
      flex: 5,
      child: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Custom overlay widget for scanning area.
          Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.orange, width: 10),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build a display area for the scanned result.
  Widget _buildResultArea() {
    return Expanded(
      flex: 1,
      child: Center(
        child: Text(
          scannedData != null ? "Scanned Data: $scannedData" : "Scan a QR code",
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderChild(
              title: "Mã QR",
            ),
            Expanded(
              child: Column(
                children: [
                  _buildQRScanner(),
                  _buildResultArea(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
