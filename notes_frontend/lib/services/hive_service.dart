import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:notes/note.dart';

class HiveService {
  static const String _notesBoxName = 'notes_box';
  static Box<Note>? _notesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteAdapter());
    _notesBox = await Hive.openBox<Note>(_notesBoxName);
  }

  static Box<Note> get notesBox {
    if (_notesBox == null) {
      throw Exception(
          'HiveService not initialized. Call HiveService.init() first.');
    }
    return _notesBox!;
  }

  // Get all notes
  static List<Note> getAllNotes() {
    return _notesBox?.values.toList() ?? [];
  }

  // Add a note
  static Future<void> addNote(Note note) async {
    await _notesBox?.put(note.id, note);
  }

  // Update a note
  static Future<void> updateNote(Note note) async {
    await _notesBox?.put(note.id, note);
  }

  // Delete a note
  static Future<void> deleteNote(String noteId) async {
    await _notesBox?.delete(noteId);
  }

  // Get a specific note by ID
  static Note? getNoteById(String noteId) {
    return _notesBox?.get(noteId);
  }

  // Clear all notes
  static Future<void> clearAllNotes() async {
    await _notesBox?.clear();
  }

  // Get notes count
  static int getNotesCount() {
    return _notesBox?.length ?? 0;
  }

  // Check if a note exists
  static bool noteExists(String noteId) {
    return _notesBox?.containsKey(noteId) ?? false;
  }

  // Close the box
  static Future<void> close() async {
    await _notesBox?.close();
  }
}
