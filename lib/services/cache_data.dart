import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

Future<void> cacheData(
    SharedPreferences prefs, String key, dynamic data, String userId) async {
  final cacheEntry = {
    'timestamp': DateTime.now().millisecondsSinceEpoch,
    'userId': userId,
    'data': data,
  };
  await prefs.setString(key, json.encode(cacheEntry));
}

dynamic readCachedData(
    SharedPreferences prefs, String key, String currentUserId,
    {Duration? ageLimit = const Duration(hours: 1)}) {
  final cachedString = prefs.getString(key);
  if (cachedString == null) return null;

  final cachedEntry = json.decode(cachedString);
  // final cachedUserId = cachedEntry['userId'];
  final timestamp = cachedEntry['timestamp'];
  final data = cachedEntry['data'];

  if (ageLimit != null) {
    final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final isRecent = DateTime.now().difference(cacheTime) <= ageLimit;
    if (isRecent) {
      return data;
    } else {
      return null;
    }
  } else {
    // No age limit, return data directly
    return data;
  }
}

Future<void> invalidateCache(SharedPreferences prefs, String key) async {
  await prefs.remove(key);
}
