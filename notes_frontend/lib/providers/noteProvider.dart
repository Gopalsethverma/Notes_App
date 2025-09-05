import 'package:flutter/material.dart';
import 'package:notes/api_services/api_service.dart';
import 'package:notes/note.dart';
import 'package:notes/services/hive_service.dart';
import 'package:notes/services/connectivity_service.dart';

class NotesProvider with ChangeNotifier {
  static List<Note> notes = [];
  bool _isLoading = false;
  bool _isOnline = false;

  bool get isLoading => _isLoading;
  bool get isOnline => _isOnline;

  NotesProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    await _checkConnectivity();
    await fetchNotes();
  }

  Future<void> _checkConnectivity() async {
    _isOnline = await ConnectivityService.isConnected();
    notifyListeners();
  }

  void sortNotes() {
    notes.sort((a, b) => b.dateadded!.compareTo(a.dateadded!));
  }

  Future<void> addNote(Note note) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Always save to local storage first
      await HiveService.addNote(note);
      notes.add(note);
      sortNotes();
      notifyListeners();

      // Try to sync with API if online
      if (_isOnline) {
        try {
          await ApiService.addNote(note);
        } catch (e) {
          print('Failed to sync note to server: $e');
          // Note is still saved locally, so we continue
        }
      }
    } catch (e) {
      print('Error adding note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateNote(Note note) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Update in local storage
      await HiveService.updateNote(note);
      int indexOfNote = notes.indexWhere((element) => element.id == note.id);
      if (indexOfNote != -1) {
        notes[indexOfNote] = note;
        sortNotes();
        notifyListeners();
      }

      // Try to sync with API if online
      if (_isOnline) {
        try {
          await ApiService.addNote(note);
        } catch (e) {
          print('Failed to sync note update to server: $e');
        }
      }
    } catch (e) {
      print('Error updating note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteNote(Note note) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Delete from local storage
      await HiveService.deleteNote(note.id!);
      notes.removeWhere((element) => element.id == note.id);
      notifyListeners();

      // Try to sync with API if online
      if (_isOnline) {
        try {
          await ApiService.deleteNote(note);
        } catch (e) {
          print('Failed to sync note deletion to server: $e');
        }
      }
    } catch (e) {
      print('Error deleting note: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchNotes() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Always load from local storage first
      notes = HiveService.getAllNotes();
      sortNotes();
      notifyListeners();

      // Try to fetch from API if online and sync
      if (_isOnline) {
        try {
          List<Note> serverNotes = await ApiService.fetchNotes("gopalverma123");

          // Merge server notes with local notes
          await _mergeNotes(serverNotes);
        } catch (e) {
          print('Failed to fetch notes from server: $e');
          // Continue with local notes
        }
      }
    } catch (e) {
      print('Error fetching notes: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _mergeNotes(List<Note> serverNotes) async {
    // Create a map of local notes for quick lookup
    Map<String, Note> localNotesMap = {for (var note in notes) note.id!: note};

    // Process server notes
    for (var serverNote in serverNotes) {
      if (localNotesMap.containsKey(serverNote.id)) {
        // Note exists locally, check if server version is newer
        var localNote = localNotesMap[serverNote.id]!;
        if (serverNote.dateadded!.isAfter(localNote.dateadded!)) {
          // Server version is newer, update local
          await HiveService.updateNote(serverNote);
          localNotesMap[serverNote.id!] = serverNote;
        }
      } else {
        // New note from server, add to local
        await HiveService.addNote(serverNote);
        localNotesMap[serverNote.id!] = serverNote;
      }
    }

    // Update the notes list
    notes = localNotesMap.values.toList();
    sortNotes();
    notifyListeners();
  }

  Future<void> refreshNotes() async {
    await _checkConnectivity();
    await fetchNotes();
  }
}
