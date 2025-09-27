// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'converted_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConvertedFileAdapter extends TypeAdapter<ConvertedFile> {
  @override
  final int typeId = 0;

  @override
  ConvertedFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConvertedFile(
      originalPath: fields[0] as String,
      convertedPath: fields[1] as String,
      outputFormat: fields[2] as String,
      convertedAt: fields[3] as DateTime,
      originalSize: fields[4] as int,
      convertedSize: fields[5] as int,
      keepExif: fields[6] as bool,
      resizePercentage: fields[7] as double,
      fileName: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ConvertedFile obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.originalPath)
      ..writeByte(1)
      ..write(obj.convertedPath)
      ..writeByte(2)
      ..write(obj.outputFormat)
      ..writeByte(3)
      ..write(obj.convertedAt)
      ..writeByte(4)
      ..write(obj.originalSize)
      ..writeByte(5)
      ..write(obj.convertedSize)
      ..writeByte(6)
      ..write(obj.keepExif)
      ..writeByte(7)
      ..write(obj.resizePercentage)
      ..writeByte(8)
      ..write(obj.fileName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConvertedFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
