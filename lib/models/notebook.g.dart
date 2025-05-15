// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notebook.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NotebookAdapter extends TypeAdapter<Notebook> {
  @override
  final int typeId = 0;

  @override
  Notebook read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Notebook(
      id: fields[0] as String,
      title: fields[1] as String,
      colorValue: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Notebook obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.colorValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NotebookAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
