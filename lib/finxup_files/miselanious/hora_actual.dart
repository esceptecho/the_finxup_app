import 'dart:async';

import 'package:flutter/material.dart';

class HoraActual extends StatefulWidget {
  const HoraActual({ super.key });

  @override
  State <HoraActual>createState() => _HoraActualState();
}

class _HoraActualState extends State<HoraActual> {
    // Variables de estado.
  int _contador = 0;
  String _mensaje = "Presiona el botón para incrementar";  
  
  
  String _horaActual = "";

  void _actualizarHora() {
    setState(() {
      _horaActual = DateTime.now().toLocal().toString().split(' ')[1].substring(0, 8); // formatea y actualiza la hora cada segundo.
    });
  }

  @override
  void initState() {
    super.initState();
    _actualizarHora(); // Inicializa la hora al iniciar la app
    Timer.periodic(Duration(seconds: 1), (timer) {
      _actualizarHora();
    });
  }
  
    Future<String> _obtenerDatosDelServidor() async {
    await Future.delayed(Duration(seconds: 2)); // Simula una operación lenta
    return "Datos recibidos del servidor";
  }

  
    void _incrementarContador() async {
      setState(() {
        _contador++;
        _mensaje = _contador > 5 ? "Contador mayor a 5" : "Contador en progreso...";
      });

      // Si el contador es par, se simula una operación asíncrona.
      if (_contador % 2 == 0) {
        String datos = await _obtenerDatosDelServidor();
        setState(() {
          _mensaje = "$datos - Contador: $_contador";
        });
      }
    }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hora: $_horaActual'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 20),
            Text(
              'Contador: $_contador',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            // Luego agregaremos un botón para incrementar.
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: _incrementarContador,
              child: Text('Incrementar'),
            ),
          ],
        ),
      ),
    );
  }
}