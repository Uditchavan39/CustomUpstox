import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class secureStore {
  
  final storage = const FlutterSecureStorage();
  Future<String?> gettoken() async {
    return await storage.read(
        key: 'access_token',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));
  }

  Future<bool?> checkkey(String token) async {
    return await storage.containsKey(
        key: token,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));
  }

  Future deleteall() async {
    await storage.deleteAll();
  }

  Future update(String token, String value) async {
    await storage.delete(key: token);
    await storage.write(key: token, value: value);
  }

  Future setToken(String token) async {
    await storage.write(
        key: 'access_token',
        value: token,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    setDate(date);
  }

  Future setDate(String date) async {
    await storage.write(
        key: 'date',
        value: date,
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));
  }

  Future<String?> getDate() async {
    return await storage.read(
        key: 'date',
        aOptions: const AndroidOptions(encryptedSharedPreferences: true));
  }
}
