import 'package:hive/hive.dart';

part 'converted_file.g.dart';

@HiveType(typeId: 0)
class ConvertedFile extends HiveObject {
  @HiveField(0)
  final String originalPath;
  
  @HiveField(1)
  final String convertedPath;
  
  @HiveField(2)
  final String outputFormat;
  
  @HiveField(3)
  final DateTime convertedAt;
  
  @HiveField(4)
  final int originalSize;
  
  @HiveField(5)
  final int convertedSize;
  
  @HiveField(6)
  final bool keepExif;
  
  @HiveField(7)
  final double resizePercentage;
  
  @HiveField(8)
  final String fileName;

  ConvertedFile({
    required this.originalPath,
    required this.convertedPath,
    required this.outputFormat,
    required this.convertedAt,
    required this.originalSize,
    required this.convertedSize,
    required this.keepExif,
    required this.resizePercentage,
    required this.fileName,
  });

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

  Map<String, dynamic> toJson() {
    return {
      'originalPath': originalPath,
      'convertedPath': convertedPath,
      'outputFormat': outputFormat,
      'convertedAt': convertedAt.toIso8601String(),
      'originalSize': originalSize,
      'convertedSize': convertedSize,
      'keepExif': keepExif,
      'resizePercentage': resizePercentage,
      'fileName': fileName,
    };
  }

  factory ConvertedFile.fromJson(Map<String, dynamic> json) {
    return ConvertedFile(
      originalPath: json['originalPath'],
      convertedPath: json['convertedPath'],
      outputFormat: json['outputFormat'],
      convertedAt: DateTime.parse(json['convertedAt']),
      originalSize: json['originalSize'],
      convertedSize: json['convertedSize'],
      keepExif: json['keepExif'],
      resizePercentage: json['resizePercentage'].toDouble(),
      fileName: json['fileName'],
    );
  }

  ConvertedFile copyWith({
    String? originalPath,
    String? convertedPath,
    String? outputFormat,
    DateTime? convertedAt,
    int? originalSize,
    int? convertedSize,
    bool? keepExif,
    double? resizePercentage,
    String? fileName,
  }) {
    return ConvertedFile(
      originalPath: originalPath ?? this.originalPath,
      convertedPath: convertedPath ?? this.convertedPath,
      outputFormat: outputFormat ?? this.outputFormat,
      convertedAt: convertedAt ?? this.convertedAt,
      originalSize: originalSize ?? this.originalSize,
      convertedSize: convertedSize ?? this.convertedSize,
      keepExif: keepExif ?? this.keepExif,
      resizePercentage: resizePercentage ?? this.resizePercentage,
      fileName: fileName ?? this.fileName,
    );
  }
}
