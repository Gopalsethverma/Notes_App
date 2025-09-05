import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notes/AddNewPagee.dart';
import 'package:notes/note.dart';
import 'package:notes/providers/noteProvider.dart';
import 'package:notes/style.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String getCurrentTimeFromDateTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        backgroundColor: Colors.blue,
        title: const Text("Notes App"),
        centerTitle: true,
        actions: [
          Consumer<NotesProvider>(
            builder: (context, notesProvider, _) {
              return IconButton(
                onPressed: () {
                  notesProvider.refreshNotes();
                },
                icon: Icon(
                  notesProvider.isOnline ? Icons.cloud_done : Icons.cloud_off,
                  color: notesProvider.isOnline ? Colors.green : Colors.red,
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Consumer<NotesProvider>(
            builder: (context, notesProvider, _) {
              if (notesProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (NotesProvider.notes.length > 0) {
                return GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemCount: NotesProvider.notes.length,
                  itemBuilder: (context, index) {
                    Note currentNote = NotesProvider.notes[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => AddNewPage(
                                      isUpdate: true,
                                      note: currentNote,
                                    )));
                      },
                      onLongPress: () {
                        notesProvider.deleteNote(currentNote);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            color: AppStyle.cardColor[index % 7],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Colors.black, width: 1)),
                        margin: const EdgeInsets.all(5),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentNote.title!,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(currentNote.content!,
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.grey),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(getCurrentTimeFromDateTime(
                                      currentNote.dateadded!))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              } else {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Add New Note",
                          style: TextStyle(fontSize: 20)),
                      const SizedBox(height: 10),
                      Text(
                        notesProvider.isOnline ? "Online" : "Offline",
                        style: TextStyle(
                          fontSize: 14,
                          color: notesProvider.isOnline
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: const CircleBorder(),
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => const AddNewPage(
                      isUpdate: false,
                    )),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
