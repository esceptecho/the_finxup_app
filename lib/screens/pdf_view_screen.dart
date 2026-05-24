import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart'; // Importación de pdfrx

class PdfViewScreen extends StatelessWidget {
  final String path;
  final String title;

  const PdfViewScreen({super.key, required this.path, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.black),
      // PdfViewer.file es el widget principal de pdfrx
      body: PdfViewer.file(
        path,
      ),
    );
  }
}
