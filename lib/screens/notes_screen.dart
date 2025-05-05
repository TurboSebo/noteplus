import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notebook.dart';
import '../providers/notebooks_model.dart';

class NotesScreen extends StatelessWidget{
final String notebookId;
const NotesScreen({super.key, required this.notebookId});

@override
Widget build(BuildContext context) {
  final model = context.read<NotebooksModel>();
  final notebook = model.notebooks.firstWhere((notebook) => notebook.id == notebookId);

  return Scaffold(
    appBar: AppBar(title: Text(notebook.title)),
    body: const Center(child: Text('tu będzie lista notatek')),


  );

  }
}