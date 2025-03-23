// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class MessageAdapter extends TypeAdapter<Message> {
  @override
  final int typeId = 0;

  @override
  Message read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Message(
      tags: (fields[0] as Map).cast<String, bool>(),
      sender: fields[1] as String,
      text: fields[2] as String,
      time: fields[3] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Message obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.tags)
      ..writeByte(1)
      ..write(obj.sender)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MessageAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 1;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Task(
      sender: fields[0] as String,
      numberOfPersons: (fields[1] as num).toInt(),
      persons: (fields[2] as Map?)?.cast<String, bool>(),
      description: fields[3] as String,
      tags: (fields[4] as Map).cast<String, bool>(),
      time: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Task obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.sender)
      ..writeByte(1)
      ..write(obj.numberOfPersons)
      ..writeByte(2)
      ..write(obj.persons)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.tags)
      ..writeByte(5)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is TaskAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}

class PdfAdapter extends TypeAdapter<Pdf> {
  @override
  final int typeId = 2;

  @override
  Pdf read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read()};
    return Pdf(base64String: fields[0] as String, time: fields[1] as DateTime?);
  }

  @override
  void write(BinaryWriter writer, Pdf obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.base64String)
      ..writeByte(1)
      ..write(obj.time);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is PdfAdapter && runtimeType == other.runtimeType && typeId == other.typeId;
}
