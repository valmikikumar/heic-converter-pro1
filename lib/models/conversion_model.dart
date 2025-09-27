import 'package:json_annotation/json_annotation.dart';

part 'conversion_model.g.dart';

@JsonSerializable()
class ConversionModel {
  final String id;
  final String userId;
  final String originalPath;
  final String convertedPath;
  final String outputFormat;
  final DateTime convertedAt;
  final int originalSize;
  final int convertedSize;
  final bool keepExif;
  final double resizePercentage;
  final String fileName;
  final String? thumbnailPath;

  const ConversionModel({
    required this.id,
    required this.userId,
    required this.originalPath,
    required this.convertedPath,
    required this.outputFormat,
    required this.convertedAt,
    required this.originalSize,
    required this.convertedSize,
    required this.keepExif,
    required this.resizePercentage,
    required this.fileName,
    this.thumbnailPath,
  });

  factory ConversionModel.fromJson(Map<String, dynamic> json) => _$ConversionModelFromJson(json);
  Map<String, dynamic> toJson() => _$ConversionModelToJson(this);

  String get fileSizeFormatted {
    if (convertedSize < 1024) {
      return '${convertedSize}B';
    } else if (convertedSize < 1024 * 1024) {
      return '${(convertedSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(convertedSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get originalSizeFormatted {
    if (originalSize < 1024) {
      return '${originalSize}B';
    } else if (originalSize < 1024 * 1024) {
      return '${(originalSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(originalSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  double get compressionRatio {
    if (originalSize == 0) return 0.0;
    return (1 - (convertedSize / originalSize)) * 100;
  }

  ConversionModel copyWith({
    String? id,
    String? userId,
    String? originalPath,
    String? convertedPath,
    String? outputFormat,
    DateTime? convertedAt,
    int? originalSize,
    int? convertedSize,
    bool? keepExif,
    double? resizePercentage,
    String? fileName,
    String? thumbnailPath,
  }) {
    return ConversionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      originalPath: originalPath ?? this.originalPath,
      convertedPath: convertedPath ?? this.convertedPath,
      outputFormat: outputFormat ?? this.outputFormat,
      convertedAt: convertedAt ?? this.convertedAt,
      originalSize: originalSize ?? this.originalSize,
      convertedSize: convertedSize ?? this.convertedSize,
      keepExif: keepExif ?? this.keepExif,
      resizePercentage: resizePercentage ?? this.resizePercentage,
      fileName: fileName ?? this.fileName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConversionModel &&
        other.id == id &&
        other.userId == userId &&
        other.originalPath == originalPath &&
        other.convertedPath == convertedPath &&
        other.outputFormat == outputFormat &&
        other.convertedAt == convertedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        originalPath.hashCode ^
        convertedPath.hashCode ^
        outputFormat.hashCode ^
        convertedAt.hashCode;
  }

  @override
  String toString() {
    return 'ConversionModel(id: $id, fileName: $fileName, outputFormat: $outputFormat)';
  }
}
