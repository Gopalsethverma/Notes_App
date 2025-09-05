import 'package:flutter/material.dart';
import 'package:notes/note.dart';
import 'package:notes/providers/noteProvider.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/v1.dart';

class AddNewPage extends StatefulWidget {
  final bool isUpdate;
  final Note? note;
  const AddNewPage({super.key, required this.isUpdate, this.note});

  @override
  State<AddNewPage> createState() => _AddNewPageState();
}

class _AddNewPageState extends State<AddNewPage> {
  FocusNode noteFocus = FocusNode();
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Future<void> addNewNote(BuildContext context) async {
    Note NewNote = Note(
        id: const Uuid().v1(),
        userid: "gopalverma123",
        title: titleController.text,
        content: contentController.text,
        dateadded: DateTime.now());
    await Provider.of<NotesProvider>(context, listen: false).addNote(NewNote);
    Navigator.pop(context);
  }

  Future<void> updateNote() async {
    widget.note!.title = titleController.text;
    widget.note!.content = contentController.text;
    await Provider.of<NotesProvider>(context, listen: false)
        .updateNote(widget.note!);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUpdate) {
      titleController.text = widget.note!.title!;
      contentController.text = widget.note!.content!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () async {
                if (widget.isUpdate) {
                  await updateNote();
                } else {
                  await addNewNote(context);
                }
              },
              icon: const Icon(Icons.check)),
        ],
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              autofocus: (widget.isUpdate == true) ? false : true,
              onSubmitted: (val) {
                if (val != "") {
                  noteFocus.requestFocus();
                }
              },
              style: const TextStyle(fontSize: 25),
              decoration: const InputDecoration(
                  hintText: "Title", border: InputBorder.none),
            ),
            Expanded(
              child: TextField(
                controller: contentController,
                focusNode: noteFocus,
                style: const TextStyle(fontSize: 20),
                maxLines: null,
                decoration: const InputDecoration(
                    hintText: "Note", border: InputBorder.none),
              ),
            )
          ],
        ),
      )),
    );
  }
}
