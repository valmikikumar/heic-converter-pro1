import 'dart:io';
import 'dart:typed_data';
import 'package:heic_to_jpg/heic_to_jpg.dart';
import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/converted_file.dart';
import '../utils/app_constants.dart';

class HEICConverterService {
  static final HEICConverterService _instance = HEICConverterService._internal();
  factory HEICConverterService() => _instance;
  HEICConverterService._internal();

  /// Convert HEIC file to specified format
  Future<ConvertedFile?> convertFile({
    required String inputPath,
    required String outputFormat,
    required bool keepExif,
    required double resizePercentage,
    int compressionQuality = 90,
  }) async {
    try {
      final inputFile = File(inputPath);
      if (!inputFile.existsSync()) {
        throw Exception(AppConstants.errorFileNotFound);
      }

      final originalSize = inputFile.lengthSync();
      final fileName = path.basenameWithoutExtension(inputPath);
      
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
          compressionQuality
        );
      }

      if (convertedFile == null || !convertedFile.existsSync()) {
        throw Exception(AppConstants.errorConversionFailed);
      }

      final convertedSize = convertedFile.lengthSync();

      return ConvertedFile(
        originalPath: inputPath,
        convertedPath: outputPath,
        outputFormat: outputFormat.toLowerCase(),
        convertedAt: DateTime.now(),
        originalSize: originalSize,
        convertedSize: convertedSize,
        keepExif: keepExif,
        resizePercentage: resizePercentage,
        fileName: outputFileName,
      );
    } catch (e) {
      print('Conversion error: $e');
      return null;
    }
  }

  /// Convert multiple files in batch
  Future<List<ConvertedFile>> convertBatch({
    required List<String> inputPaths,
    required String outputFormat,
    required bool keepExif,
    required double resizePercentage,
    int compressionQuality = 90,
    Function(int, int)? onProgress,
  }) async {
    final results = <ConvertedFile>[];
    
    for (int i = 0; i < inputPaths.length; i++) {
      onProgress?.call(i + 1, inputPaths.length);
      
      final result = await convertFile(
        inputPath: inputPaths[i],
        outputFormat: outputFormat,
        keepExif: keepExif,
        resizePercentage: resizePercentage,
        compressionQuality: compressionQuality,
      );
      
      if (result != null) {
        results.add(result);
      }
    }
    
    return results;
  }

  /// Convert HEIC to image format (JPG, PNG, BMP, WebP)
  Future<File?> _convertToImage(
    String inputPath,
    String outputPath,
    String format,
    bool keepExif,
    double resizePercentage,
    int compressionQuality,
  ) async {
    try {
      // First convert HEIC to JPG using the native library
      final jpgPath = await HeicToJpg.convert(inputPath);
      if (jpgPath == null) {
        throw Exception('Failed to convert HEIC to JPG');
      }

      final jpgFile = File(jpgPath);
      final bytes = jpgFile.readAsBytesSync();
      
      // Decode the image
      final image = img.decodeImage(bytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Resize if needed
      img.Image resizedImage = image;
      if (resizePercentage < 100) {
        final newWidth = (image.width * resizePercentage / 100).round();
        final newHeight = (image.height * resizePercentage / 100).round();
        resizedImage = img.copyResize(image, width: newWidth, height: newHeight);
      }

      // Convert to target format
      Uint8List? outputBytes;
      switch (format.toLowerCase()) {
        case 'jpg':
        case 'jpeg':
          outputBytes = Uint8List.fromList(img.encodeJpg(resizedImage, quality: compressionQuality));
          break;
        case 'png':
          outputBytes = Uint8List.fromList(img.encodePng(resizedImage));
          break;
        case 'bmp':
          outputBytes = Uint8List.fromList(img.encodeBmp(resizedImage));
          break;
        case 'webp':
          outputBytes = Uint8List.fromList(img.encodeWebP(resizedImage, quality: compressionQuality));
          break;
        default:
          throw Exception('Unsupported output format: $format');
      }

      // Write the output file
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(outputBytes);

      // Clean up temporary JPG file
      if (jpgFile.existsSync()) {
        await jpgFile.delete();
      }

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
      // Convert to JPG first
      final jpgPath = await HeicToJpg.convert(inputPath);
      if (jpgPath == null) {
        throw Exception('Failed to convert HEIC to JPG');
      }

      final jpgFile = File(jpgPath);
      final bytes = jpgFile.readAsBytesSync();
      
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

      // Clean up temporary JPG file
      if (jpgFile.existsSync()) {
        await jpgFile.delete();
      }

      return outputFile;
    } catch (e) {
      print('PDF conversion error: $e');
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
      
      // Return only the first 12 files for home screen grid
      return files.take(12).toList();
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
}
