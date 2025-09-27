import 'dart:io';
import 'dart:typed_data';
// Removed heic_to_jpg dependency; decode HEIC directly via image library fallback when available
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../models/conversion_model.dart';
import '../utils/app_constants.dart';

class HEICConversionService {
  static final HEICConversionService _instance = HEICConversionService._internal();
  factory HEICConversionService() => _instance;
  HEICConversionService._internal();

  final _uuid = const Uuid();

  /// Convert HEIC file to specified format
  Future<ConversionModel?> convertFile({
    required String inputPath,
    required String outputFormat,
    required bool keepExif,
    required double resizePercentage,
    required String userId,
    int compressionQuality = 90,
    bool rotate = false,
    bool crop = false,
    Map<String, double>? cropArea,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!inputFile.existsSync()) {
        throw Exception(AppConstants.errorFileNotFound);
      }

      final originalSize = inputFile.lengthSync();
      final fileName = path.basenameWithoutExtension(inputPath);
      final conversionId = _uuid.v4();
      
      // Get output directory
      final outputDir = await _getOutputDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final outputFileName = '${fileName}_$timestamp.$outputFormat';
      final outputPath = path.join(outputDir.path, outputFileName);

      File? convertedFile;

      if (outputFormat.toLowerCase() == 'pdf') {
        convertedFile = await _convertToPDF(inputPath, outputPath, resizePercentage);
      } else {
        convertedFile = await _convertToImage(
          inputPath, 
          outputPath, 
          outputFormat, 
          keepExif, 
          resizePercentage, 
          compressionQuality,
          rotate,
          crop,
          cropArea,
        );
      }

      if (convertedFile == null || !convertedFile.existsSync()) {
        throw Exception(AppConstants.errorConversionFailed);
      }

      final convertedSize = convertedFile.lengthSync();
      final thumbnailPath = await _generateThumbnail(outputPath);

      return ConversionModel(
        id: conversionId,
        userId: userId,
        originalPath: inputPath,
        convertedPath: outputPath,
        outputFormat: outputFormat.toLowerCase(),
        convertedAt: DateTime.now(),
        originalSize: originalSize,
        convertedSize: convertedSize,
        keepExif: keepExif,
        resizePercentage: resizePercentage,
        fileName: outputFileName,
        thumbnailPath: thumbnailPath,
      );
    } catch (e) {
      print('Conversion error: $e');
      return null;
    }
  }

  /// Convert multiple files in batch
  Future<List<ConversionModel>> convertBatch({
    required List<String> inputPaths,
    required String outputFormat,
    required bool keepExif,
    required double resizePercentage,
    required String userId,
    int compressionQuality = 90,
    Function(int, int)? onProgress,
    Function(String, String)? onFileComplete,
  }) async {
    final results = <ConversionModel>[];
    
    for (int i = 0; i < inputPaths.length; i++) {
      onProgress?.call(i + 1, inputPaths.length);
      
      final result = await convertFile(
        inputPath: inputPaths[i],
        outputFormat: outputFormat,
        keepExif: keepExif,
        resizePercentage: resizePercentage,
        userId: userId,
        compressionQuality: compressionQuality,
      );
      
      if (result != null) {
        results.add(result);
        onFileComplete?.call(inputPaths[i], result.fileName);
      }
    }
    
    return results;
  }

  /// Convert HEIC to image format (JPG, PNG)
  Future<File?> _convertToImage(
    String inputPath,
    String outputPath,
    String format,
    bool keepExif,
    double resizePercentage,
    int compressionQuality,
    bool rotate,
    bool crop,
    Map<String, double>? cropArea,
  ) async {
    try {
      // Read input bytes (HEIC/HEIF supported on some environments via image package; otherwise, this may fail)
      final bytes = await File(inputPath).readAsBytes();
      
      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Apply edits
      img.Image editedImage = image;
      
      // Rotate if needed
      if (rotate) {
        editedImage = img.copyRotate(editedImage, angle: 90);
      }
      
      // Crop if needed
      if (crop && cropArea != null) {
        final x = (cropArea['x']! * editedImage.width).round();
        final y = (cropArea['y']! * editedImage.height).round();
        final width = (cropArea['width']! * editedImage.width).round();
        final height = (cropArea['height']! * editedImage.height).round();
        
        editedImage = img.copyCrop(
          editedImage,
          x: x,
          y: y,
          width: width,
          height: height,
        );
      }

      // Resize if needed
      if (resizePercentage < 100) {
        final newWidth = (editedImage.width * resizePercentage / 100).round();
        final newHeight = (editedImage.height * resizePercentage / 100).round();
        editedImage = img.copyResize(editedImage, width: newWidth, height: newHeight);
      }

      // Convert to target format
      Uint8List? outputBytes;
      switch (format.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          outputBytes = Uint8List.fromList(img.encodeJpg(editedImage, quality: compressionQuality));
          break;
        case 'png':
          outputBytes = Uint8List.fromList(img.encodePng(editedImage));
          break;
        default:
          throw Exception('Unsupported output format: $format');
      }

      // Write the output file
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

      // No temp cleanup needed

      return outputFile;
    } catch (e) {
      print('Image conversion error: $e');
      return null;
    }
  }

  /// Convert to PDF format
  Future<File?> _convertToPDF(
    String inputPath,
    String outputPath,
    double resizePercentage,
  ) async {
    try {
      // Read input bytes directly
      final bytes = await File(inputPath).readAsBytes();
      
      // Decode and resize image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      img.Image resizedImage = image;
      if (resizePercentage < 100) {
        final newWidth = (image.width * resizePercentage / 100).round();
        final newHeight = (image.height * resizePercentage / 100).round();
        resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
      }

      // Create PDF
      final pdf = pw.Document();
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            resizedImage.width.toDouble(),
            resizedImage.height.toDouble(),
          ),
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                pw.MemoryImage(img.encodePng(resizedImage)),
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Save PDF
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(await pdf.save());

      // No temp cleanup needed

      return outputFile;
    } catch (e) {
      print('PDF conversion error: $e');
      return null;
    }
  }

  /// Generate thumbnail for converted file
  Future<String?> _generateThumbnail(String filePath) async {
    try {
      final file = File(filePath);
      if (!file.existsSync()) return null;

      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image == null) return null;

      // Create thumbnail (max 200x200)
      final thumbnail = img.copyResize(
        image,
        width: 200,
        height: 200,
        maintainAspect: true,
      );

      final thumbnailBytes = img.encodeJpg(thumbnail, quality: 70);
      
      // Save thumbnail
      final outputDir = await _getOutputDirectory();
      final thumbnailFileName = 'thumb_${path.basename(filePath)}.jpg';
      final thumbnailPath = path.join(outputDir.path, thumbnailFileName);
      
      final thumbnailFile = File(thumbnailPath);
      await thumbnailFile.writeAsBytes(thumbnailBytes);
      
      return thumbnailPath;
    } catch (e) {
      print('Thumbnail generation error: $e');
      return null;
    }
  }

  /// Get the output directory for converted files
  Future<Directory> _getOutputDirectory() async {
    final documentsDir = await getApplicationDocumentsDirectory();
    final outputDir = Directory(path.join(documentsDir.path, AppConstants.outputFolderName));
    
    if (!outputDir.existsSync()) {
      await outputDir.create(recursive: true);
    }
    
    return outputDir;
  }

  /// Get list of recent converted files
  Future<List<File>> getRecentConvertedFiles() async {
    try {
      final outputDir = await _getOutputDirectory();
      final files = outputDir.listSync()
          .where((file) => file is File)
          .cast<File>()
          .toList();
      
      // Sort by modification date (newest first)
      files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
      
      // Return only the first 20 files
      return files.take(20).toList();
    } catch (e) {
      print('Error getting recent files: $e');
      return [];
    }
  }

  /// Delete converted file
  Future<bool> deleteFile(String filePath) async {
    try {
      final file = File(filePath);
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  /// Get file size in bytes
  int getFileSize(String filePath) {
    try {
      final file = File(filePath);
      return file.existsSync() ? file.lengthSync() : 0;
    } catch (e) {
      return 0;
    }
  }

  /// Check if file is a supported HEIC format
  bool isSupportedFormat(String filePath) {
    final extension = path.extension(filePath).toLowerCase().substring(1);
    return AppConstants.supportedInputFormats.contains(extension);
  }

  /// Get file info
  Map<String, dynamic> getFileInfo(String filePath) {
    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        return {};
      }

      final stat = file.statSync();
      return {
        'size': stat.size,
        'modified': stat.modified,
        'created': stat.changed,
        'path': filePath,
        'name': file.path.split('/').last,
        'extension': path.extension(filePath),
      };
    } catch (e) {
      return {};
    }
  }

  /// Check if user has reached file limit
  bool checkFileLimit(int currentFileCount, bool isPro) {
    if (isPro) {
      return true; // Pro users have unlimited conversions
    }
    return currentFileCount < AppConstants.freeUserFileLimit;
  }

  /// Get remaining conversions for free users
  int getRemainingConversions(int currentFileCount, bool isPro) {
    if (isPro) {
      return -1; // Unlimited
    }
    return AppConstants.freeUserFileLimit - currentFileCount;
  }
}
