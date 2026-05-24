import 'package:flutter/material.dart';

class AnimatedContainerApp extends StatefulWidget {
  const AnimatedContainerApp({super.key});

  @override
  State<AnimatedContainerApp> createState() => _AnimatedContainerAppState();
}

class _AnimatedContainerAppState extends State<AnimatedContainerApp> {
  bool _isFullScreen = false;
  String media = 'https://imgs.search.brave.com/o4yYsEae7wnnJmqfPywGPuSJYVQHmQPdS3aEeR18Qw0/rs:fit:500:0:0:0/g:ce/aHR0cHM6Ly93d3cu/aXN0b2NrcGhvdG8u/Y29tL3Jlc291cmNl/cy9pbWFnZXMvRnJl/ZVBob3Rvcy9GcmVl/LVBob3RvLTcwMHg4/NjAtMjE2MTQ3ODY1/Ny5qcGc';
    String media2 =
      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double width = _isFullScreen ? screenWidth : 350;
    double height = _isFullScreen ? screenHeight : 550;
    BorderRadiusGeometry borderRadius =
        BorderRadius.circular(_isFullScreen ? 0 : 8);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('AnimatedContainer Demo')),
        body: Center(
          child: AnimatedContainer(
            width: width,
            height: height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(media),
                fit: BoxFit.fitHeight,
              ),
              color: Colors.cyanAccent,
              borderRadius: borderRadius,
            ),
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            child: Center(
              child: Text(
                _isFullScreen ? 'Full Screen' : 'Miniature',
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            setState(() {
              _isFullScreen = !_isFullScreen;
            });
          },
          child: Icon(_isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen),
        ),
      ),
    );
  }
}