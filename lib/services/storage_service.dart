import 'dart:convert';
import 'package:localstorage/localstorage.dart';

class StorageService {
  static LocalStorage store = LocalStorage("Finvest");

  static storeItem(String key, Map<String, dynamic> value) async {
    await store.ready;
    await store.setItem(key, jsonEncode(value));
  }

  static clearAll() async {
    await store.ready;
    await store.clear();
  }

  static clearByKey(String key) async {
    await store.ready;
    await store.deleteItem(key);
  }

  static Future<Map<String, dynamic>?> getItem(String key) async {
    await store.ready;
    dynamic result = store.getItem(key);
    if (result != null) {
      return jsonDecode(result);
    }
    return null;
  }
}
