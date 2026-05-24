import 'package:flutter/material.dart';

class DynamicProfileScreen extends StatefulWidget {
  const DynamicProfileScreen({super.key});

  @override
  State<DynamicProfileScreen> createState() => _DynamicProfileScreenState();
}

class _DynamicProfileScreenState extends State<DynamicProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  
  // Estado para la interactividad
  String _name = "";
  bool _isConfirmed = false;
  
  // Paleta de colores dinámica basada en el largo del nombre
  final List<Color> _brandColors = [
    Colors.indigo,
    Colors.teal,
    Colors.amber.shade700,
    Colors.deepOrange,
    Colors.pinkAccent,
  ];

  Color get _activeColor => _name.isEmpty 
      ? Colors.grey 
      : _brandColors[_name.length % _brandColors.length];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleConfirm() {
    if (_name.isNotEmpty) {
      setState(() => _isConfirmed = true);
      // Feedback visual rápido
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("¡Perfil de $_name actualizado!"),
          backgroundColor: _activeColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Fondo sutil que reacciona al color activo
      backgroundColor: _activeColor.withOpacity(0.05),
      appBar: AppBar(
        title: const Text("Editor de Perfil"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // --- PARTE 1: LA TARJETA DINÁMICA (Visualización) ---
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: _activeColor,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: _activeColor.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: Column(
                children: [
                  // Avatar animado que crece con el nombre
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: _name.isEmpty ? 80 : 100,
                    width: _name.isEmpty ? 80 : 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                        radius: 50,
                      backgroundImage: AssetImage(
                        'assets/arees_profile.jpeg',
                       
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Texto animado (del primer widget)
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: (_name.length * 0.8 + 22).clamp(22, 32),
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    child: Text(
                      _name.isEmpty ? "Tu Nombre Aquí" : _name,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _isConfirmed ? "ID VERIFICADO" : "EDITANDO PERFIL",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      letterSpacing: 1.2,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // --- PARTE 2: INPUT INTERACTIVO ---
            TextField(
              controller: _nameController,
              onChanged: (val) {
                setState(() {
                  _name = val;
                  _isConfirmed = false; // Si edita, pierde la "confirmación"
                });
              },
              cursorColor: _activeColor,
              decoration: InputDecoration(
                labelText: "Nombre del titular", 
                hintText: "Ej. Alex Smith",
                prefixIcon: Icon(Icons.badge, color: _activeColor),
                filled: true,
                fillColor: Colors.black45,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: _activeColor, width: 2),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // --- PARTE 3: BOTÓN DE ACCIÓN (del segundo widget) ---
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton.icon(
                onPressed: _name.isEmpty ? null : _handleConfirm,
                icon: const Icon(Icons.check_circle),
                label: const Text("CONFIRMAR CAMBIOS", 
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // --- PARTE 4: MENSAJE DE BIENVENIDA (Feedback final) ---
            AnimatedOpacity(
              duration: const Duration(milliseconds: 600),
              opacity: _isConfirmed ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("👋", style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 10),
                    Text(
                      "¡Bienvenido, $_name!",softWrap: true,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}