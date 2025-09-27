import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/converted_file.dart';
import '../utils/app_constants.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  late Box<ConvertedFile> _convertedFilesBox;
  late SharedPreferences _prefs;

  /// Initialize storage service
  Future<void> initialize() async {
    _convertedFilesBox = Hive.box<ConvertedFile>(AppConstants.convertedFilesBox);
    _prefs = await SharedPreferences.getInstance();
  }

  /// Save converted file to history
  Future<void> saveConvertedFile(ConvertedFile file) async {
    await _convertedFilesBox.add(file);
  }

  /// Get all converted files
  List<ConvertedFile> getAllConvertedFiles() {
    return _convertedFilesBox.values.toList()
      ..sort((a, b) => b.convertedAt.compareTo(a.convertedAt));
  }

  /// Get converted files by date range
  List<ConvertedFile> getConvertedFilesByDateRange(DateTime start, DateTime end) {
    return _convertedFilesBox.values
        .where((file) => file.convertedAt.isAfter(start) && file.convertedAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.convertedAt.compareTo(a.convertedAt));
  }

  /// Delete converted file from history
  Future<void> deleteConvertedFile(ConvertedFile file) async {
    await file.delete();
  }

  /// Delete all converted files
  Future<void> clearAllConvertedFiles() async {
    await _convertedFilesBox.clear();
  }

  /// Get recent converted files (last 12)
  List<ConvertedFile> getRecentConvertedFiles() {
    final allFiles = getAllConvertedFiles();
    return allFiles.take(12).toList();
  }

  /// Search converted files by name
  List<ConvertedFile> searchConvertedFiles(String query) {
    final lowerQuery = query.toLowerCase();
    return _convertedFilesBox.values
        .where((file) => file.fileName.toLowerCase().contains(lowerQuery))
        .toList()
      ..sort((a, b) => b.convertedAt.compareTo(a.convertedAt));
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    final allFiles = getAllConvertedFiles();
    final totalFiles = allFiles.length;
    final totalOriginalSize = allFiles.fold<int>(0, (sum, file) => sum + file.originalSize);
    final totalConvertedSize = allFiles.fold<int>(0, (sum, file) => sum + file.convertedSize);
    
    // Group by format
    final formatStats = <String, int>{};
    for (final file in allFiles) {
      formatStats[file.outputFormat] = (formatStats[file.outputFormat] ?? 0) + 1;
    }

    return {
      'totalFiles': totalFiles,
      'totalOriginalSize': totalOriginalSize,
      'totalConvertedSize': totalConvertedSize,
      'spaceSaved': totalOriginalSize - totalConvertedSize,
      'formatStats': formatStats,
    };
  }

  // Settings management
  String getDefaultOutputFormat() {
    return _prefs.getString(AppConstants.keyDefaultOutputFormat) ?? AppConstants.defaultOutputFormat;
  }

  Future<void> setDefaultOutputFormat(String format) async {
    await _prefs.setString(AppConstants.keyDefaultOutputFormat, format);
  }

  bool getKeepExifByDefault() {
    return _prefs.getBool(AppConstants.keyKeepExifByDefault) ?? AppConstants.defaultKeepExif;
  }

  Future<void> setKeepExifByDefault(bool keep) async {
    await _prefs.setBool(AppConstants.keyKeepExifByDefault, keep);
  }

  double getDefaultResizePercentage() {
    return _prefs.getDouble(AppConstants.keyDefaultResizePercentage) ?? AppConstants.defaultResizePercentage;
  }

  Future<void> setDefaultResizePercentage(double percentage) async {
    await _prefs.setDouble(AppConstants.keyDefaultResizePercentage, percentage);
  }

  int getCompressionQuality() {
    return _prefs.getInt(AppConstants.keyCompressionQuality) ?? AppConstants.defaultCompressionQuality;
  }

  Future<void> setCompressionQuality(int quality) async {
    await _prefs.setInt(AppConstants.keyCompressionQuality, quality);
  }

  bool getDarkMode() {
    return _prefs.getBool(AppConstants.keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool isDark) async {
    await _prefs.setBool(AppConstants.keyDarkMode, isDark);
  }

  String getSaveLocation() {
    return _prefs.getString(AppConstants.keySaveLocation) ?? AppConstants.defaultSaveLocation;
  }

  Future<void> setSaveLocation(String location) async {
    await _prefs.setString(AppConstants.keySaveLocation, location);
  }

  /// Export settings to JSON
  Map<String, dynamic> exportSettings() {
    return {
      AppConstants.keyDefaultOutputFormat: getDefaultOutputFormat(),
      AppConstants.keyKeepExifByDefault: getKeepExifByDefault(),
      AppConstants.keyDefaultResizePercentage: getDefaultResizePercentage(),
      AppConstants.keyCompressionQuality: getCompressionQuality(),
      AppConstants.keyDarkMode: getDarkMode(),
      AppConstants.keySaveLocation: getSaveLocation(),
    };
  }

  /// Import settings from JSON
  Future<void> importSettings(Map<String, dynamic> settings) async {
    if (settings.containsKey(AppConstants.keyDefaultOutputFormat)) {
      await setDefaultOutputFormat(settings[AppConstants.keyDefaultOutputFormat]);
    }
    if (settings.containsKey(AppConstants.keyKeepExifByDefault)) {
      await setKeepExifByDefault(settings[AppConstants.keyKeepExifByDefault]);
    }
    if (settings.containsKey(AppConstants.keyDefaultResizePercentage)) {
      await setDefaultResizePercentage(settings[AppConstants.keyDefaultResizePercentage]);
    }
    if (settings.containsKey(AppConstants.keyCompressionQuality)) {
      await setCompressionQuality(settings[AppConstants.keyCompressionQuality]);
    }
    if (settings.containsKey(AppConstants.keyDarkMode)) {
      await setDarkMode(settings[AppConstants.keyDarkMode]);
    }
    if (settings.containsKey(AppConstants.keySaveLocation)) {
      await setSaveLocation(settings[AppConstants.keySaveLocation]);
    }
  }

  /// Reset all settings to default
  Future<void> resetSettings() async {
    await _prefs.clear();
  }

  /// Check if file exists in storage
  bool fileExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Get file info
  Map<String, dynamic> getFileInfo(String filePath) {
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
    };
  }

  /// Clean up orphaned files (files in storage but not in history)
  Future<int> cleanupOrphanedFiles() async {
    int cleanedCount = 0;
    final historyFiles = _convertedFilesBox.values.map((f) => f.convertedPath).toSet();
    
    try {
      // Get output directory
      final documentsDir = Directory('/path/to/documents'); // This would be properly implemented
      if (documentsDir.existsSync()) {
        final files = documentsDir.listSync().whereType<File>();
        
        for (final file in files) {
          if (!historyFiles.contains(file.path)) {
            await file.delete();
            cleanedCount++;
          }
        }
      }
    } catch (e) {
      print('Error cleaning up orphaned files: $e');
    }
    
    return cleanedCount;
  }
}
