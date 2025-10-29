import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'platform_service.dart';

class StorageService {
  static Future<String> get _localPath async {
    if (kIsWeb) return '';
    
    if (PlatformService.isDesktop) {
      if (Platform.isMacOS) {
        final directory = await getApplicationSupportDirectory();
        return directory.path;
      } else if (Platform.isWindows) {
        final directory = await getApplicationSupportDirectory();
        return directory.path;
      } else if (Platform.isLinux) {
        final directory = await getApplicationSupportDirectory();
        return directory.path;
      }
    }
    
    // لنظامي iOS و Android
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName');
  }

  // حفظ الملفات
  static Future<void> saveFile(String fileName, List<int> bytes) async {
    if (kIsWeb) {
      // استخدام IndexedDB للويب
      return;
    }

    try {
      final file = await _localFile(fileName);
      await file.writeAsBytes(bytes);
    } catch (e) {
      print('Error saving file: $e');
      rethrow;
    }
  }

  // قراءة الملفات
  static Future<List<int>> readFile(String fileName) async {
    if (kIsWeb) {
      // استخدام IndexedDB للويب
      return [];
    }

    try {
      final file = await _localFile(fileName);
      return await file.readAsBytes();
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }

  // حذف الملفات
  static Future<void> deleteFile(String fileName) async {
    if (kIsWeb) {
      // استخدام IndexedDB للويب
      return;
    }

    try {
      final file = await _localFile(fileName);
      await file.delete();
    } catch (e) {
      print('Error deleting file: $e');
    }
  }

  // حفظ البيانات المحلية
  static Future<void> saveData(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is String) {
      await prefs.setString(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is List<String>) {
      await prefs.setStringList(key, value);
    }
  }

  // قراءة البيانات المحلية
  static Future<dynamic> getData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.get(key);
  }

  // حذف البيانات المحلية
  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  // مسح كل البيانات المحلية
  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}