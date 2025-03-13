import 'package:flutter/material.dart';

class XemThemScreen extends StatelessWidget {
  const XemThemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Xem thêm'),
        backgroundColor: const Color(0xFF2F3D85),
      ),
      body: Center(
        child: Text(
          'This is the Xem thêm feature screen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
    );
  }
}
