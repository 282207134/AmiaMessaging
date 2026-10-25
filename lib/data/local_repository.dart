import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// One versioned snapshot keeps the small offline demo easy to reset and migrate.
class LocalRepository {
  late final _preferences = SharedPreferencesAsync();
  static const _key = 'amia.snapshot.v1';
  Future<Map<String, dynamic>> read() async {
    final raw = await _preferences.getString(_key);
    if (raw == null) return {};
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException {
      return {};
    } on TypeError {
      return {};
    }
  }

  Future<void> write(Map<String, dynamic> value) =>
      _preferences.setString(_key, jsonEncode(value));
}
