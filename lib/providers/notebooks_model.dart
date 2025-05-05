import 'package:flutter/material.dart';
import '../models/notebook.dart';

class NotebooksModel extends ChangeNotifier{
  final List<Notebook> _notebooks = [];
  List<Notebook> get notebooks => _notebooks;

  void addNotebook(Notebook notebook) {
    _notebooks.add(notebook);
    notifyListeners();
  }
}