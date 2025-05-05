import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/notes_screen.dart';

RouteFactory generateRoute = (settings){
  switch(settings.name){
    case '/':
      return MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      );
    case '/notes':
      final notebookId = settings.arguments as String;
      return MaterialPageRoute(
        builder: (_) => NotesScreen(notebookId: notebookId),
      );
    default:
      return null;
  }
};
