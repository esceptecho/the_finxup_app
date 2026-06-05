import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_finxup_app/providers/debt_provider.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

class BuildUiOverlay extends ConsumerStatefulWidget {
  const BuildUiOverlay({super.key});

  @override
  ConsumerState<BuildUiOverlay> createState() => _BuildUiOverlayState();
}

class _BuildUiOverlayState extends ConsumerState<BuildUiOverlay> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction:
          0.85, // Esto permite ver un poco de la siguiente tarjeta
    );
  }

  @override
  Widget build(BuildContext context) {
    final debts = ref.watch(debtListProvider);
    final totalDeudas = ref.watch(totalDeudasProvider);
    final totalPrestamos = ref.watch(totalPrestamosProvider);

    return Expanded(
      child: Stack(
        children: [
          Positioned(
            top: MediaQuery.of(context).padding.top + 5,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: .center,
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
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.9,
                                ),
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
                                        'No hay deudas disponibles.',
                                        style: TextStyle(
                                          background: Paint()
                                            ..color = Colors.white.withValues(
                                              alpha: 0.8,
                                            ),
                                          color: Colors.black54,
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Text(
                                        textAlign: .center,
                                        'Planes que te podrían interesar',
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
                                          itemCount: 5,
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
                                              child: Container(
                                                color: Colors.grey,
                                              ),
                                            );
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
                                            5, // Numero total de puntos en el mock (ajusta según tu lógica real)
                                            (index) => AnimatedContainer(
                                              duration: const Duration(
                                                milliseconds: 300,
                                              ),
                                              margin: const EdgeInsets.symmetric(
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
                        Icon(
                          Icons.change_circle_outlined,
                          color: AppThemeHSL.accentGoldBright,
                          size: 22,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${debts.length} registros',
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
                            setState(() {});
                            break;
                          case 'Por Cobrar':
                            // Tu lógica de Por Cobrar aquí
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
                              Icon(Icons.light_mode, color: Colors.white70),
                              const SizedBox(width: 10),
                              Text("Modo Claro : Modo Oscuro"),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(), // Una línea divisoria estética
                        PopupMenuItem(
                          value: 'Por Cobrar',
                          child: ListTile(
                            onTap: () {
                              // Lógica para mostrar Por Cobrar
                            },
                            leading: Icon(Icons.people),
                            title: Text("Por Cobrar"),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'Por Pagar',
                          child: ListTile(
                            onTap: () {
                              // Lógica para mostrar Por Pagar
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
                            leading: Icon(Icons.money),
                            title: Text("Por Pagar"),
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
                                  builder: (context) => Placeholder(
                                    color: Colors.deepOrange,
                                    child: Text('Por definir'),
                                  ),
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
      ),
    );
  }

  // Widget utilitario para el estilo "Glassmorphism" del Overlay
  Widget _buildGlassCapsule({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppThemeHSL.surfaceLighter.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white10),
        // boxShadow: [
        //   BoxShadow(
        //     color: AppThemeHSL.accentGoldBright.withValues(alpha: 0.1),
        //     blurRadius: 10,
        //     spreadRadius: 2,
        //   ),
        // ],
      ),
      child: child,
    );
  }
}
