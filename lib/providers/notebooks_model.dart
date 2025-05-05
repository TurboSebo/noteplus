import 'package:flutter/material.dart';
import '../models/notebook.dart';
import 'package:flutter/foundation.dart';

class NotebooksModel extends ChangeNotifier{
  final List<Notebook> _notebooks = [];

  List<Notebook> get notebooks => List.unmodifiable(_notebooks);

  void addNotebook(String title) {
    final notebook = Notebook.create(title);
    _notebooks.add(notebook);
    notifyListeners();
  }
    
  void removeNotebook(String id) {
      _notebooks.removeWhere((notebook) => notebook.id == id);
      notifyListeners();
    }

}
