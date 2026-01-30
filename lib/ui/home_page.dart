import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import 'widgets/note_card.dart';
import 'editor_page.dart';

class HomePage extends StatefulWidget {
  final StorageService storageService;

  const HomePage({super.key, required this.storageService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> _notes = [];
  String _searchQuery = '';
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    await widget.storageService.cleanupSelfDestructingNotes();
    _refreshNotes();
  }

  void _refreshNotes() {
    setState(() {
      _notes = widget.storageService.getAllNotes();
      if (_searchQuery.isNotEmpty) {
        _notes = _notes.where((note) {
          return note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              note.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()));
        }).toList();
      }
    });
  }

  Future<void> _openNote(Note note) async {
    if (note.isLocked) {
      bool authenticated = await _authService.authenticate();
      if (!authenticated) return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditorPage(
          storageService: widget.storageService,
          note: note,
        ),
      ),
    );
    _refreshNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F12),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text(
                'My Notes',
                style: GoogleFonts.outfit(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (value) {
                  _searchQuery = value;
                  _refreshNotes();
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                  prefixIcon: Icon(Icons.search, color: Colors.white.withOpacity(0.3)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _notes.isEmpty
                    ? Center(
                        child: Text(
                          'No notes found',
                          style: TextStyle(color: Colors.white.withOpacity(0.3)),
                        ),
                      )
                    : MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                        itemCount: _notes.length,
                        itemBuilder: (context, index) {
                          final note = _notes[index];
                          return Stack(
                            children: [
                              NoteCard(
                                note: note,
                                onTap: () => _openNote(note),
                              ),
                              if (note.isLocked)
                                Positioned(
                                  top: 12,
                                  right: 12,
                                  child: Icon(Icons.lock, size: 14, color: Colors.cyanAccent.withOpacity(0.5)),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNote(Note(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '',
          content: '[]',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        )),
        backgroundColor: Colors.deepPurpleAccent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
