import 'package:flutter/material.dart';

class BuildUiOverlay extends StatefulWidget {
  const BuildUiOverlay({super.key});

  @override
  State<BuildUiOverlay> createState() => _BuildUiOverlayState();
}

class _BuildUiOverlayState extends State<BuildUiOverlay> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState(){
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 0.85, // Esto permite ver un poco de la siguiente tarjeta
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: MediaQuery.of(context).padding.top + 10,
          left: 20,
          right: 20,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Indicador de Estado
              _buildGlassCapsule(
                child: InkWell(
                  onTap: () {
                   
                      // Correcto: Usar showDialog para "empujar" el widget a la pantalla
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // Usamos StatefulBuilder para que el setState del PageView funcione dentro del diálogo
                          return StatefulBuilder(
                            builder: (context, setDialogState) {
                              return AlertDialog(
                                backgroundColor: Colors.white.withValues(alpha: 0.9),
                                // Quitamos el Flexible y usamos un Container o SizedBox con ancho definido
                                content: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width *
                                      0.9, // 90% del ancho de pantalla
                                  child: Column(
                                    mainAxisSize: MainAxisSize
                                        .min, // Importante: que la columna no ocupe toda la pantalla
                                    children: [
                                      const SizedBox(height: 12),
                                      Text(
                                        textAlign: .center,
                                        'No hay usuarios visibles en el área actual. Acércate o muévete para descubrir exploradores cercanos.',
                                        style: TextStyle(
                                          background: Paint()
                                            ..color = Colors.white.withValues(alpha: 
                                              0.8,
                                            ),
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        textAlign: .center,
                                        'Proyectos que te podrían interesar',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 350,
                                        child: PageView.builder(
                                          controller: _pageController,
                                          itemCount: 12,
                                          onPageChanged: (index) {
                                            // IMPORTANTE: Usar el setDialogState del StatefulBuilder
                                            setDialogState(() {
                                              _currentPage = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {

                                            return AnimatedBuilder(
                                              animation: _pageController,
                                              builder: (context, child) {
                                                double value = 1.0;
                                                if (_pageController
                                                    .position
                                                    .haveDimensions) {
                                                  value =
                                                      (_pageController.page! -
                                                              index)
                                                          .abs();
                                                  value = (1 - (value * 0.1))
                                                      .clamp(0.9, 1.0);
                                                }
                                                return Transform.scale(
                                                  scale: value,
                                                  child: child,
                                                );
                                              },
                                              child: Container(color: Colors.deepOrange,));
                                          },
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      // Indicador de puntos (Dots)
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: List.generate(
                                            50, // Numero total de puntos en el mock (ajusta según tu lógica real)
                                            (index) => AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              margin:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 4,
                                                  ),
                                              height: 8,
                                              width: _currentPage == index
                                                  ? 24
                                                  : 8,
                                              decoration: BoxDecoration(
                                                color: _currentPage == index
                                                    ? const Color.fromARGB(
                                                        255,
                                                        90,
                                                        156,
                                                        156,
                                                      )
                                                    : Colors.grey,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                  },

                  child: Row(
                    children: [
                      const Icon(
                        Icons.public,
                        color: Colors.cyanAccent,
                        size: 22,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "{} usuarios visibles",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Botón de Ayuda o Filtro
              _buildGlassCapsule(
                child: SizedBox(
                  height: 24,
                  width: 24,
                  child: PopupMenuButton<String>(
                    splashRadius:
                        28, // Controla el tamaño del círculo al tocar el icono
                    popUpAnimationStyle: AnimationStyle(
                      curve: Curves.easeInOutQuart, // Efecto de ... al abrir
                      duration: const Duration(milliseconds: 500),
                      reverseCurve: Curves.easeIn, // Efecto al cerrar
                      reverseDuration: const Duration(milliseconds: 200),
                    ),
                    // 1. Bordes redondeados para el menú desplegable
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(7),
                    ),
                    // 2. Reducir el tamaño del botón (el área de toque)
                    padding: EdgeInsets.zero,
                    icon: Container(
                      padding: const EdgeInsets.all(
                        0,
                      ), // Espacio interno del icono
                      decoration: BoxDecoration(
                        color: Colors
                            .transparent, // Fondo opcional para visibilidad
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.filter_list,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onSelected: (value) {
                      // Manejo de las opciones del menú
                      switch (value) {
                        case 'tema':
                          setState(() {
                          });
                          break;
                        case 'amigos':
                          // Tu lógica de amigos aquí
                          break;
                        // ... otras opciones
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      // Opción Dinámica: Cambia texto e icono según el estado
                      PopupMenuItem(
                        padding: EdgeInsets.only(left: 8),
                        value: 'tema',
                        child: Row(
                          children: [
                            Icon(
                              Icons.light_mode,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 10),
                            Text("Modo Claro : Modo Oscuro"),
                          ],
                        ),
                      ),
                      const PopupMenuDivider(), // Una línea divisoria estética
                      PopupMenuItem(
                        value: 'amigos',
                        child: ListTile(
                          onTap: () {
                            // Lógica para mostrar amigos
                          },
                          leading: Icon(Icons.people),
                          title: Text("Amigos"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'favoritos',
                        child: ListTile(
                          onTap: () {
                            // Lógica para mostrar favoritos
                            Navigator.pop(
                              context,
                            ); // Cierra el menú después de seleccionar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Container(
                                  color: Colors.deepOrange,
                                  child: Text('Por definir'),
                                ),
                              ),
                            );
                          },
                          leading: Icon(Icons.favorite),
                          title: Text("Favoritos"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'guardados',
                        child: ListTile(
                          onTap: () {
                            // Lógica para mostrar guardados
                            Navigator.pop(
                              context,
                            ); // Cierra el menú después de seleccionar
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Placeholder(color: Colors.deepOrange, child: Text('Por definir')), 
                              ),
                            );
                          },
                          leading: Icon(Icons.bookmark),
                          title: Text("Guardados"),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget utilitario para el estilo "Glassmorphism" del Overlay
  Widget _buildGlassCapsule({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withValues(alpha: 0.1),
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: child,
    );
  }
}
