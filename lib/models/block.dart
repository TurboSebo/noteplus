import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'block.g.dart';

//nieużywane
//początkowo planowano różne typy bloków, ale obecnie mam tylko tekst i audio

@HiveType(typeId: 2)
enum BlockType {
  @HiveField(0)
  text,
  @HiveField(1)
  image,
}

// Dodajemy klasę Block do obsługi tekstu i obrazów
@HiveType(typeId: 3)
class Block extends HiveObject {
  @HiveField(0)
  BlockType type;

  // Dane bloku (tekst lub ścieżka do obrazu).
  // Jeśli blok jest typu 'text', data przechowuje treść tekstu.
  // Jeśli blok jest typu 'image', data przechowuje URI lub ścieżkę do pliku.
  @HiveField(1)
  String data;

  Block({
    required this.type,
    required this.data,
  });

  /// Fabryka do tworzenia bloku tekstowego
  factory Block.textBlock(String textContent) {
    return Block(
      type: BlockType.text,
      data: textContent,
    );
  }

  /// Fabryka do tworzenia bloku graficznego
  factory Block.imageBlock(String imagePath) {
    return Block(
      type: BlockType.image,
      data: imagePath,
    );
  }
}

