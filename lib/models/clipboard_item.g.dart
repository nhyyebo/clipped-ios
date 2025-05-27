// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clipboard_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClipboardItemAdapter extends TypeAdapter<ClipboardItem> {
  @override
  final int typeId = 0;

  @override
  ClipboardItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ClipboardItem(
      id: fields[0] as String?,
      content: fields[1] as String,
      createdAt: fields[2] as DateTime?,
      lastUsed: fields[3] as DateTime?,
      type: fields[4] as ClipboardItemType,
      category: fields[5] as String?,
      isFavorite: fields[6] as bool,
      title: fields[7] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ClipboardItem obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.createdAt)
      ..writeByte(3)
      ..write(obj.lastUsed)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.isFavorite)
      ..writeByte(7)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ClipboardItemTypeAdapter extends TypeAdapter<ClipboardItemType> {
  @override
  final int typeId = 1;

  @override
  ClipboardItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ClipboardItemType.text;
      case 1:
        return ClipboardItemType.url;
      case 2:
        return ClipboardItemType.email;
      case 3:
        return ClipboardItemType.phone;
      case 4:
        return ClipboardItemType.other;
      default:
        return ClipboardItemType.text;
    }
  }

  @override
  void write(BinaryWriter writer, ClipboardItemType obj) {
    switch (obj) {
      case ClipboardItemType.text:
        writer.writeByte(0);
        break;
      case ClipboardItemType.url:
        writer.writeByte(1);
        break;
      case ClipboardItemType.email:
        writer.writeByte(2);
        break;
      case ClipboardItemType.phone:
        writer.writeByte(3);
        break;
      case ClipboardItemType.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClipboardItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
