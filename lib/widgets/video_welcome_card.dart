import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

// Enum para identificar de dónde viene el video
enum VideoSourceType { network, asset, file }

class VideoWelcomeCard extends StatefulWidget {
  final String userName;
  final String videoPath; // URL, ruta del asset o ruta local
  final VideoSourceType videoType;
  final VoidCallback? onActionTap;
  final VoidCallback? onTap;

  const VideoWelcomeCard({
    super.key,
    required this.userName,
    required this.videoPath,
    this.videoType = VideoSourceType.network, // Por defecto usa URL
    this.onActionTap,
    this.onTap,
  });

  @override
  State<VideoWelcomeCard> createState() => _VideoWelcomeCardState();
}

class _VideoWelcomeCardState extends State<VideoWelcomeCard> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  void _initializeVideo() {
    // Inicializamos el controlador dependiendo del tipo de fuente
    switch (widget.videoType) {
      case VideoSourceType.network:
        _videoController = VideoPlayerController.networkUrl(
          Uri.parse(widget.videoPath),
          videoPlayerOptions: VideoPlayerOptions(
            allowBackgroundPlayback: false,
          ),
        );
        break;
      case VideoSourceType.asset:
        _videoController = VideoPlayerController.asset(widget.videoPath);
        break;
      case VideoSourceType.file:
        _videoController = VideoPlayerController.file(File(widget.videoPath));
        break;
    }

    _videoController
        .initialize()
        .then((_) {
          // Nos aseguramos de que el widget siga montado antes de actualizar el estado
          if (mounted) {
            setState(() {
              _isVideoInitialized = true;
            });
            // Opcional: Reproducción automática y en bucle
            _videoController.setLooping(false);
            _videoController.play();
          }
        })
        .catchError((error) {
          debugPrint("Error al cargar el video: $error");
        });
  }

  @override
  void dispose() {
    // Es vital liberar el controlador cuando el widget se destruye
    _videoController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Buenos días';
    if (hour < 19) return 'Buenas tardes';
    return 'Buenas noches';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap, // onTap general para toda la tarjeta
      child: Container(
        // margin: const EdgeInsets.all(16.0),
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppThemeHSL.accentGold, AppThemeHSL.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección Superior: Avatar y Saludo (Se mantiene igual)
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 12, top: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    child: const Icon(
                      Icons.info_outline,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_getGreeting()},',
                          style: TextStyle(
                            color: Colors.blue[100],
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (widget.onActionTap != null)
                    InkWell(
                      onTap: widget.onActionTap,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Sección Inferior: Video de Bienvenida
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(
                  alpha: 0.2,
                ), // Fondo por si el video tarda
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isVideoInitialized
                    ? AspectRatio(
                        aspectRatio:
                            16 / 9, // O usa _videoController.value.aspectRatio
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            VideoPlayer(_videoController),
                            // Botón de Play/Pause superpuesto
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _videoController.value.isPlaying
                                      ? _videoController.pause()
                                      : _videoController.play();
                                });
                              },
                              child: AnimatedOpacity(
                                opacity: _videoController.value.isPlaying
                                    ? 0.0
                                    : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.play_arrow,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            // Botón de mute/unmute en la esquina inferior derecha
                            Positioned(
                              bottom: 10,
                              right: 10,
                              child: IconButton(
                                icon: Icon(
                                  _videoController.value.volume == 0
                                      ? Icons.volume_off
                                      : Icons.volume_up,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  setState(() {
                                    final currentVolume =
                                        _videoController.value.volume;
                                    _videoController.setVolume(
                                      currentVolume == 0 ? 1.0 : 0.0,
                                    );
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Padding(
                        padding: EdgeInsets.all(40.0),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
