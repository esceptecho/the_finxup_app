import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:the_finxup_app/theme/app_themeHSL.dart';

// --- MODELO DE NOTA ---
class QuickNote {
  final String id;
  final String text;
  final int colorValue;

  QuickNote({required this.id, required this.text, required this.colorValue});

  // Convertir a Map para guardar en JSON
  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'colorValue': colorValue,
  };

  // Crear desde Map
  factory QuickNote.fromMap(Map<String, dynamic> map) => QuickNote(
    id: map['id'],
    text: map['text'],
    colorValue: map['colorValue'],
  );
}

// --- PANTALLA PRINCIPAL: GRID DE NOTAS ---
class NotesGridScreen extends StatefulWidget {
  const NotesGridScreen({super.key});

  @override
  State<NotesGridScreen> createState() => _NotesGridScreenState();
}

class _NotesGridScreenState extends State<NotesGridScreen> {
  List<QuickNote> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  // Cargar notas de SharedPreferences
  Future<void> _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesJson = prefs.getString('user_notes');
    if (notesJson != null) {
      List<dynamic> decoded = jsonDecode(notesJson);
      setState(() {
        _notes = decoded.map((item) => QuickNote.fromMap(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Mis Notas"), centerTitle: true),
      body: _notes.isEmpty
          ? const Center(child: Text("No hay notas. ¡Crea una!"))
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return Transform(
                  transform: Matrix4.skewX( 
                    (index % 2 == 0 ? -1 : 1) * 0.05,
                  ), // Pequeña rotación alternada
                  child: InkWell(
                    // TODO: Agregar opción de editar nota al ar clic la tarjeta pasandole la nota al editor
                    // TODO: Agregar opción de eliminar nota al mantener presionada la tarjeta
                    // Al tocar la nota, navegar al editor con esa nota
                    onTap: () {
                      // Navegar al editor con la nota actual
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NoteEditorScreen(note: note),
                        ),
                      ).then((_) => _loadNotes()); // Refrescar al volver
                    },
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Color(note.colorValue),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        note.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppThemeHSL.primary,
        onPressed: () async {
          // Navegar al editor y esperar a que regrese para refrescar la lista
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const NoteEditorScreen()),
          );
          _loadNotes();
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

// --- PANTALLA: EDITOR DINÁMICO ---
class NoteEditorScreen extends StatefulWidget {
  final QuickNote? note; // Si es null, es una nueva nota

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final TextEditingController _controller = TextEditingController();
  String _text = "";

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.indigo,
    Colors.red,
  ];

  Color get _activeColor =>
      _text.isEmpty ? Colors.grey : _colors[_text.length % _colors.length];

  Future<void> _saveNote() async {
    if (_text.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();

    // 1. Obtener notas actuales
    final String? existingNotes = prefs.getString('user_notes');
    List<dynamic> notesList = existingNotes != null
        ? jsonDecode(existingNotes)
        : [];

    // 2. Crear nueva nota con el color actual
    final newNote = QuickNote(
      id: DateTime.now().toString(),
      text: _text,
      colorValue: _activeColor.value,
    );

    // 3. Guardar
    notesList.add(newNote.toMap());
    await prefs.setString('user_notes', jsonEncode(notesList));

    if (mounted) Navigator.pop(context); // Volver atrás
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _activeColor.withOpacity(0.1),
      appBar: AppBar(
        title: const Text("Nueva Nota"),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Preview Animada
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              height: 200,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _activeColor,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: _activeColor.withOpacity(0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: (_text.length * 0.3 + 20).clamp(20, 30),
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                child: Center(
                  child: Text(
                    _text.isEmpty
                        ? "Contenido de la nota aparecerá aquí ✍️"
                        : _text,
                    softWrap: true,
                    textAlign: .center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              cursorColor: Colors.white,
              controller: _controller,
              contextMenuBuilder: (context, editableTextState) {
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: [
                    ...editableTextState.contextMenuButtonItems,
                    ContextMenuButtonItem(
                      label: 'Limpiar',
                      onPressed: () {
                        editableTextState.hideToolbar();
                        _controller.clear();
                        setState(() => _text = "");
                      },
                    ),
                  ],
                );
              },
              maxLines: 1,
              maxLength: 90,
              onChanged: (val) => setState(() => _text = val),
              decoration: InputDecoration(
                isDense: true,
                hintText: "Escribe tu idea...",
                filled: true,
                fillColor: Colors.white30,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: _text.isEmpty ? null : _saveNote,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _activeColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: const Text(
                  "GUARDAR NOTA",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
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
