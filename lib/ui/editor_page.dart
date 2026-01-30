import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note.dart';
import '../services/storage_service.dart';
import '../services/auth_service.dart';
import '../services/export_service.dart';
import 'models/note_mood.dart';
import 'widgets/sketch_canvas.dart';

class EditorPage extends StatefulWidget {
  final StorageService storageService;
  final Note note;

  const EditorPage({super.key, required this.storageService, required this.note});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late QuillController _controller;
  late TextEditingController _titleController;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final AuthService _authService = AuthService();
  final ExportService _exportService = ExportService();
  bool _isSketchVisible = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    
    final doc = widget.note.content.isEmpty || widget.note.content == '[]' 
      ? Document() 
      : Document.fromJson(jsonDecode(widget.note.content));
      
    _controller = QuillController(
      document: doc,
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  Future<void> _saveNote() async {
    widget.note.title = _titleController.text;
    widget.note.content = jsonEncode(_controller.document.toDelta().toJson());
    widget.note.updatedAt = DateTime.now();
    await widget.storageService.saveNote(widget.note);
  }

  void _toggleLock() async {
    bool authenticated = await _authService.authenticate();
    if (authenticated) {
      setState(() {
        widget.note.isLocked = !widget.note.isLocked;
      });
      // Force save on lock toggle
      await _saveNote();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mood = NoteMood.getMood(widget.note.mood);
    
    return WillPopScope(
      onWillPop: () async {
        await _saveNote();
        return true;
      },
      child: Theme(
        data: ThemeData(
          brightness: mood.primaryColor.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
          primaryColor: mood.accentColor,
          textTheme: GoogleFonts.getTextTheme(
            mood.fontFamily,
            Theme.of(context).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
          ),
        ),
        child: Scaffold(
          backgroundColor: mood.primaryColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () async {
                await _saveNote();
                Navigator.pop(context);
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.palette_outlined),
                onPressed: _showMoodPicker,
              ),
              IconButton(
                icon: Icon(
                  widget.note.isLocked ? Icons.lock : Icons.lock_open,
                  color: widget.note.isLocked ? Colors.cyanAccent : Colors.white,
                ),
                onPressed: _toggleLock,
              ),
              IconButton(
                icon: Icon(
                  widget.note.selfDestructAt == null ? Icons.timer_outlined : Icons.timer,
                  color: widget.note.selfDestructAt == null ? Colors.white : Colors.redAccent,
                ),
                onPressed: _showSelfDestructPicker,
              ),
              IconButton(
                icon: const Icon(Icons.picture_as_pdf_outlined),
                onPressed: () => _exportService.exportNoteToPdf(widget.note),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () async {
                  await widget.storageService.deleteNote(widget.note);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: Column(
            children: [
              if (widget.note.selfDestructAt != null)
                Container(
                  width: double.infinity,
                  color: Colors.redAccent.withOpacity(0.1),
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Center(
                    child: Text(
                      'Note will self-destruct on ${widget.note.selfDestructAt}',
                      style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _titleController,
                  style: GoogleFonts.getFont(
                    mood.fontFamily,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: mood.primaryColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Title',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              QuillSimpleToolbar(
                controller: _controller,
                config: QuillSimpleToolbarConfig(
                  showListCheck: true,
                  embedButtons: FlutterQuillEmbeds.toolbarButtons(
                    imageButtonOptions: QuillToolbarImageButtonOptions(
                      imageButtonConfig: QuillToolbarImageConfig(
                        onImageInsertCallback: (image, controller) async {
                          controller.replaceText(
                            controller.selection.baseOffset,
                            0,
                            BlockEmbed.image(image),
                            controller.selection,
                          );
                        },
                      ),
                    ),
                  ),
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: const Icon(Icons.brush_outlined),
                      tooltip: 'Sketch',
                      onPressed: () => setState(() => _isSketchVisible = !_isSketchVisible),
                    ),
                  ],
                ),
              ),
              if (_isSketchVisible)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SketchCanvas(
                    onSave: (data) => widget.note.sketchData = data,
                  ),
                ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: mood.secondaryColor.withOpacity(0.3),
                  child: QuillEditor.basic(
                    controller: _controller,
                    focusNode: _focusNode,
                    scrollController: _scrollController,
                    config: QuillEditorConfig(
                      autoFocus: false,
                      expands: true,
                      padding: EdgeInsets.zero,
                      embedBuilders: FlutterQuillEmbeds.editorBuilders(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMoodPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1F),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Mood', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: NoteMood.moods.map((m) {
                  return GestureDetector(
                    onTap: () {
                      setState(() => widget.note.mood = m.name);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: m.secondaryColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: widget.note.mood == m.name ? m.accentColor : Colors.transparent, width: 2),
                      ),
                      child: Text(m.name, style: TextStyle(color: m.accentColor, fontWeight: FontWeight.bold)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showSelfDestructPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1F),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Self-Destruction Timer', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                title: const Text('None', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => widget.note.selfDestructAt = null);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('1 Minute (Testing)', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => widget.note.selfDestructAt = DateTime.now().add(const Duration(minutes: 1)));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('1 Hour', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => widget.note.selfDestructAt = DateTime.now().add(const Duration(hours: 1)));
                  Navigator.pop(context);
                },
              ),
              ListTile(
                title: const Text('1 Day', style: TextStyle(color: Colors.white)),
                onTap: () {
                  setState(() => widget.note.selfDestructAt = DateTime.now().add(const Duration(days: 1)));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    super.dispose();
  }
}
