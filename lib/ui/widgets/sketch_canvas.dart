import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

class SketchCanvas extends StatefulWidget {
  final String? initialData;
  final Function(String) onSave;

  const SketchCanvas({super.key, this.initialData, required this.onSave});

  @override
  State<SketchCanvas> createState() => _SketchCanvasState();
}

class _SketchCanvasState extends State<SketchCanvas> {
  late SignatureController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.white,
      exportBackgroundColor: Colors.transparent,
    );
    // Note: Signature package doesn't easily restore from JSON without custom logic,
    // for this demo we'll just handle new sketches or simple clearing.
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Sketch', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.red),
              onPressed: () => _controller.clear(),
            ),
          ],
        ),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white24),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Signature(
            controller: _controller,
            backgroundColor: Colors.white.withOpacity(0.05),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
