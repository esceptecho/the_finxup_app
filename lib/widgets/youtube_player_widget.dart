import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubePlayerWidget extends StatefulWidget {
  final String videoUrl;
  final String? title;
  final String? description;
  final bool showInfo;

  const YoutubePlayerWidget({
    super.key,
    required this.videoUrl,
    this.title,
    this.description,
    this.showInfo = true,
  });

  @override
  State<YoutubePlayerWidget> createState() => _YoutubePlayerWidgetState();
}

class _YoutubePlayerWidgetState extends State<YoutubePlayerWidget> {
  YoutubePlayerController? _controller;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  void _initializePlayer() {
    try {
      // SOLUCIÓN 1: En la nueva versión, convertUrlToId pertenece a YoutubePlayerController
      final videoId = YoutubePlayerController.convertUrlToId(widget.videoUrl);

      if (videoId == null) {
        setState(() {
          _errorMessage = 'URL de YouTube no válida';
        });
        return;
      }

      // SOLUCIÓN 2: Ahora se usa .fromVideoId y YoutubePlayerParams en lugar de flags
      _controller = YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: false,
          mute: false,
          loop: false,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al inicializar el reproductor';
      });
    }
  }

  @override
  void dispose() {
    // SOLUCIÓN 3: En la nueva versión, el controlador ya no requiere (ni tiene) el método dispose()
    // ya que se limpia de manera interna o automática. Lo dejamos vacío.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Reproductor de YouTube
          AspectRatio(
            aspectRatio: 16 / 9,
            child: _errorMessage != null
                ? Container(
                    color: Colors.black,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 32,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _errorMessage!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                : _controller != null
                // SOLUCIÓN 4: El nuevo widget YoutubePlayer es ultra simple.
                // Ya no lleva indicadores de progreso ni parámetros estéticos aquí;
                // todo lo maneja el reproductor nativo de YouTube de manera automática.
                ? YoutubePlayer(controller: _controller!)
                : const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2,
                    ),
                  ),
          ),

          // Información del video
          if (widget.showInfo &&
              (widget.title != null || widget.description != null))
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.title != null) ...[
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 18,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.title!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  if (widget.description != null)
                    Text(
                      widget.description!,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
