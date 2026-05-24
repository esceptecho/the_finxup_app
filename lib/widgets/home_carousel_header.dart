import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomeCarouselHeader extends StatefulWidget {
  const HomeCarouselHeader({super.key});

  @override
  State<HomeCarouselHeader> createState() => _HomeCarouselHeaderState();
}

class _HomeCarouselHeaderState extends State<HomeCarouselHeader> {
  int _currentIndex = 0;

  // Datos de ejemplo para el carrusel
  final List<Map<String, dynamic>> _statusData = [
    {
      'title': 'Estado Financiero',
      'subtitle': 'Tu saldo está balanceado. No hay deudas pendientes.',
      'icon': Icons.account_balance_wallet_rounded,
      'color': [Colors.blue[700]!, Colors.blue[900]!],
    },
    {
      'title': 'Tareas de Hoy',
      'subtitle': 'Tienes 4 facturas listas para ser aprobadas.',
      'icon': Icons.assignment_rounded,
      'color': [Colors.teal[600]!, Colors.teal[800]!],
    },
    {
      'title': 'Seguridad',
      'subtitle': 'Tu última sesión fue hace 2 horas desde Web.',
      'icon': Icons.security_rounded,
      'color': [Colors.indigo[700]!, Colors.indigo[900]!],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            viewportFraction: 0.92, // Muestra un pedacito de la siguiente tarjeta
            enlargeCenterPage: true,
            enableInfiniteScroll: false,
            onPageChanged: (index, reason) {
              setState(() => _currentIndex = index);
            },
          ),
          items: _statusData.map((data) {
            return Builder(
              builder: (BuildContext context) {
                return _buildCarouselItem(data);
              },
            );
          }).toList(),
        ),
        
        // Indicadores (puntos) debajo del carrusel
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _statusData.asMap().entries.map((entry) {
            return Container(
              width: _currentIndex == entry.key ? 18.0 : 7.0,
              height: 7.0,
              margin: const EdgeInsets.symmetric(horizontal: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: _currentIndex == entry.key 
                    ? Colors.blue[800] 
                    : Colors.grey[300],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Widget de la tarjeta individual dentro del carrusel
  Widget _buildCarouselItem(Map<String, dynamic> data) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data['color'],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (data['color'][0] as Color).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data['icon'], color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Text(
                data['title'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            data['subtitle'],
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: Icon(
              Icons.arrow_forward_rounded,
              color: Colors.white.withOpacity(0.5),
            ),
          )
        ],
      ),
    );
  }
}