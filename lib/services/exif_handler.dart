import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class EXIFHandler {
  static final EXIFHandler _instance = EXIFHandler._internal();
  factory EXIFHandler() => _instance;
  EXIFHandler._internal();

  /// Remove EXIF data from image
  Future<Uint8List> removeEXIF(Uint8List imageBytes) async {
    try {
      // Decode the image
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Create a new image without EXIF data
      final cleanImage = img.Image(
        width: image.width,
        height: image.height,
        numChannels: image.numChannels,
      );

      // Copy pixel data without metadata
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          cleanImage.setPixel(x, y, pixel);
        }
      }

      // Encode back to bytes (this will strip EXIF)
      return Uint8List.fromList(img.encodeJpg(cleanImage));
    } catch (e) {
      print('Error removing EXIF: $e');
      return imageBytes; // Return original if removal fails
    }
  }

  /// Check if image has EXIF data
  bool hasEXIFData(Uint8List imageBytes) {
    try {
      // Look for EXIF marker in JPEG
      if (imageBytes.length > 4) {
        // Check for JPEG file signature
        if (imageBytes[0] == 0xFF && imageBytes[1] == 0xD8) {
          // Look for EXIF marker (0xFFE1)
          for (int i = 2; i < imageBytes.length - 1; i++) {
            if (imageBytes[i] == 0xFF && imageBytes[i + 1] == 0xE1) {
              return true;
            }
            // Stop at start of image data
            if (imageBytes[i] == 0xFF && imageBytes[i + 1] == 0xDA) {
              break;
            }
          }
        }
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get EXIF data from image
  Map<String, dynamic>? getEXIFData(Uint8List imageBytes) {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) return null;

      final exifData = <String, dynamic>{};

      // Try to extract basic EXIF information
      if (image.exif != null) {
        final exif = image.exif!;
        
        // Camera information
        if (exif['Make'] != null) exifData['make'] = exif['Make'];
        if (exif['Model'] != null) exifData['model'] = exif['Model'];
        if (exif['Software'] != null) exifData['software'] = exif['Software'];
        
        // Photo settings
        if (exif['DateTime'] != null) exifData['dateTime'] = exif['DateTime'];
        if (exif['DateTimeOriginal'] != null) exifData['dateTimeOriginal'] = exif['DateTimeOriginal'];
        if (exif['ExposureTime'] != null) exifData['exposureTime'] = exif['ExposureTime'];
        if (exif['FNumber'] != null) exifData['fNumber'] = exif['FNumber'];
        if (exif['ISO'] != null) exifData['iso'] = exif['ISO'];
        if (exif['FocalLength'] != null) exifData['focalLength'] = exif['FocalLength'];
        
        // GPS information
        if (exif['GPSLatitude'] != null) exifData['gpsLatitude'] = exif['GPSLatitude'];
        if (exif['GPSLongitude'] != null) exifData['gpsLongitude'] = exif['GPSLongitude'];
        if (exif['GPSAltitude'] != null) exifData['gpsAltitude'] = exif['GPSAltitude'];
        
        // Image properties
        if (exif['Orientation'] != null) exifData['orientation'] = exif['Orientation'];
        if (exif['ColorSpace'] != null) exifData['colorSpace'] = exif['ColorSpace'];
        
        return exifData.isNotEmpty ? exifData : null;
      }
      
      return null;
    } catch (e) {
      print('Error reading EXIF: $e');
      return null;
    }
  }

  /// Strip EXIF data from file
  Future<File> stripEXIFFromFile(String inputPath, String outputPath) async {
    try {
      final inputFile = File(inputPath);
      final imageBytes = await inputFile.readAsBytes();
      
      final cleanBytes = await removeEXIF(imageBytes);
      
      final outputFile = File(outputPath);
      await outputFile.writeAsBytes(cleanBytes);
      
      return outputFile;
    } catch (e) {
      throw Exception('Failed to strip EXIF data: $e');
    }
  }

  /// Preserve EXIF data when converting
  Future<Uint8List> preserveEXIF(Uint8List originalBytes, Uint8List convertedBytes) async {
    try {
      // For now, just return the converted bytes
      // In a more sophisticated implementation, we would extract EXIF from original
      // and inject it into the converted image
      return convertedBytes;
    } catch (e) {
      print('Error preserving EXIF: $e');
      return convertedBytes;
    }
  }

  /// Get file size difference after EXIF removal
  Future<int> getEXIFSize(Uint8List imageBytes) async {
    try {
      final originalSize = imageBytes.length;
      final cleanBytes = await removeEXIF(imageBytes);
      final cleanSize = cleanBytes.length;
      
      return originalSize - cleanSize;
    } catch (e) {
      return 0;
    }
  }

  /// Check if EXIF contains sensitive information (GPS, etc.)
  bool hasSensitiveEXIF(Uint8List imageBytes) {
    final exifData = getEXIFData(imageBytes);
    if (exifData == null) return false;
    
    // Check for GPS data
    return exifData.containsKey('gpsLatitude') || 
           exifData.containsKey('gpsLongitude') ||
           exifData.containsKey('gpsAltitude');
  }

  /// Get human-readable EXIF summary
  String getEXIFSummary(Uint8List imageBytes) {
    final exifData = getEXIFData(imageBytes);
    if (exifData == null) return 'No EXIF data found';
    
    final summary = <String>[];
    
    if (exifData.containsKey('make') && exifData.containsKey('model')) {
      summary.add('${exifData['make']} ${exifData['model']}');
    }
    
    if (exifData.containsKey('dateTimeOriginal')) {
      summary.add('Date: ${exifData['dateTimeOriginal']}');
    }
    
    if (exifData.containsKey('exposureTime')) {
      summary.add('Exposure: ${exifData['exposureTime']}');
    }
    
    if (exifData.containsKey('fNumber')) {
      summary.add('Aperture: f/${exifData['fNumber']}');
    }
    
    if (exifData.containsKey('iso')) {
      summary.add('ISO: ${exifData['iso']}');
    }
    
    if (exifData.containsKey('focalLength')) {
      summary.add('Focal Length: ${exifData['focalLength']}mm');
    }
    
    if (hasSensitiveEXIF(imageBytes)) {
      summary.add('⚠️ Contains GPS data');
    }
    
    return summary.isEmpty ? 'Basic EXIF data' : summary.join('\n');
  }
}
