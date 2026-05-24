import 'dart:io';
import 'package:flutter/material.dart';
import 'package:the_finxup_app/screens/pdf_view_screen.dart';

class AttachmentFullScreenViewer extends StatefulWidget {
  final List<String> paths;
  final int initialIndex;

  const AttachmentFullScreenViewer({
    super.key,
    required this.paths,
    this.initialIndex = 0,
  });

  @override
  State<AttachmentFullScreenViewer> createState() =>
      _AttachmentFullScreenViewerState();
}

class _AttachmentFullScreenViewerState
    extends State<AttachmentFullScreenViewer> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Archivo ${_pageController.hasClients ? (_pageController.page!.toInt() + 1) : (widget.initialIndex + 1)} / ${widget.paths.length}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.paths.length,
        itemBuilder: (context, index) {
          final path = widget.paths[index];
          final isImage = [
            '.jpg',
            '.jpeg',
            '.png',
          ].any((ext) => path.toLowerCase().endsWith(ext));

          return InteractiveViewer(
            // Permite hacer zoom manual
            clipBehavior: Clip.none,
            maxScale: 5.0,
            child: Center(
              child: isImage
                  ? Image.file(File(path), fit: BoxFit.contain)
                  : _buildPdfPlaceholder(context, path),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPdfPlaceholder(BuildContext context, String path) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.picture_as_pdf, size: 80, color: Colors.redAccent),
        const SizedBox(height: 20),
        Text(
          path.split('/').last,
          style: const TextStyle(color: Colors.white, fontSize: 14),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    PdfViewScreen(path: path, title: "Documento PDF"),
              ),
            );
          },
          icon: const Icon(Icons.remove_red_eye, color: Colors.white),
          label: const Text(
            "Visualizar PDF",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
