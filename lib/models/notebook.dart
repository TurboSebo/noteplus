import 'package:uuid/uuid.dart';

class Notebook {
  final String id;
  final String title;

  Notebook({
    required this.id,
    required this.title,
  });

  // Metoda fabryczna do tworzenia obiektu Notebook z unikatowym ID.
  factory Notebook.create(String title) {
    return Notebook(
      id: const Uuid().v4(),
      title: title,
    );
  }
}