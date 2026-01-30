import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';

class StorageService {
  static const String _boxName = 'notesBox';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(NoteAdapter());
    }
    await Hive.openBox<Note>(_boxName);
  }

  Box<Note> get _box => Hive.box<Note>(_boxName);

  List<Note> getAllNotes() {
    final notes = _box.values.toList();
    notes.sort((a, b) {
      if (a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  Future<void> saveNote(Note note) async {
    if (note.isInBox) {
      await note.save();
    } else {
      await _box.add(note);
    }
  }

  Future<void> deleteNote(Note note) async {
    await note.delete();
  }

  Future<void> togglePin(Note note) async {
    note.isPinned = !note.isPinned;
    await note.save();
  }

  Future<void> cleanupSelfDestructingNotes() async {
    final now = DateTime.now();
    final toDelete = _box.values.where((note) => 
      note.selfDestructAt != null && note.selfDestructAt!.isBefore(now)
    ).toList();

    for (var note in toDelete) {
      await note.delete();
    }
  }
}
