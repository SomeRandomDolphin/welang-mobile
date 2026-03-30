import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:welangflood/src/constants/api_constants.dart';
import 'package:welangflood/src/models/flood_category.dart';
import 'package:welangflood/src/services/api_service.dart';

class CategoryService {
  static const String _cacheKey = 'flood_categories_cache';
  static const String _cacheSavedAtKey = 'flood_categories_cache_saved_at';
  static const Duration _cacheTtl = Duration(hours: 24);

  static Future<List<FloodCategory>> getCategories({bool forceRefresh = false}) async {
	final prefs = await SharedPreferences.getInstance();

	if (!forceRefresh) {
	  final cached = _readCacheIfFresh(prefs);
	  if (cached.isNotEmpty) {
		return cached;
	  }
	}

	final response = await ApiService.get(ApiConstants.categories);
	if (response['status'] == 'success') {
	  final categories = _parseCategories(response);
	  if (categories.isNotEmpty) {
		await _saveCache(prefs, categories);
		return categories;
	  }
	}

	final fallback = _readCacheAllowStale(prefs);
	if (fallback.isNotEmpty) {
	  return fallback;
	}

	return _defaultCategories;
  }

  static List<FloodCategory> _parseCategories(Map<String, dynamic> response) {
	dynamic raw = response['data'];
	if (raw is Map<String, dynamic>) {
	  raw = raw['categories'] ?? raw['category'] ?? raw['data'];
	}

	if (raw is! List) {
	  return [];
	}

	final parsed = raw
		.whereType<Map>()
		.map((e) => FloodCategory.fromJson(Map<String, dynamic>.from(e)))
		.map((e) => FloodCategory(
			  jenis: e.jenis,
			  minHeight: e.minHeight,
			  maxHeight: e.maxHeight,
			  iconUrl: _toAbsoluteIconUrl(e.iconUrl),
			))
		.toList();

	parsed.sort((a, b) => a.minHeight.compareTo(b.minHeight));
	return parsed;
  }

  static String? _toAbsoluteIconUrl(String? raw) {
	if (raw == null || raw.isEmpty) return null;
	final uri = Uri.tryParse(raw);
	if (uri != null && uri.hasScheme) {
	  return raw;
	}

	final base = ApiConstants.baseUrl.endsWith('/')
		? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 1)
		: ApiConstants.baseUrl;
	final path = raw.startsWith('/') ? raw.substring(1) : raw;
	return '$base/$path';
  }

  static List<FloodCategory> _readCacheIfFresh(SharedPreferences prefs) {
	final savedAtMs = prefs.getInt(_cacheSavedAtKey);
	if (savedAtMs == null) return [];

	final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(savedAtMs));
	if (age > _cacheTtl) return [];

	return _readCacheAllowStale(prefs);
  }

  static List<FloodCategory> _readCacheAllowStale(SharedPreferences prefs) {
	final raw = prefs.getString(_cacheKey);
	if (raw == null || raw.isEmpty) return [];

	try {
	  final decoded = jsonDecode(raw);
	  if (decoded is! List) return [];

	  final parsed = decoded
		  .whereType<Map>()
		  .map((e) => FloodCategory.fromJson(Map<String, dynamic>.from(e)))
		  .toList();
	  parsed.sort((a, b) => a.minHeight.compareTo(b.minHeight));
	  return parsed;
	} catch (_) {
	  return [];
	}
  }

  static Future<void> _saveCache(SharedPreferences prefs, List<FloodCategory> categories) async {
	final encoded = jsonEncode(categories.map((e) => e.toJson()).toList());
	await prefs.setString(_cacheKey, encoded);
	await prefs.setInt(_cacheSavedAtKey, DateTime.now().millisecondsSinceEpoch);
  }

  static const List<FloodCategory> _defaultCategories = [
	FloodCategory(jenis: '1', minHeight: 0, maxHeight: 10),
	FloodCategory(jenis: '2', minHeight: 10, maxHeight: 30),
	FloodCategory(jenis: '3', minHeight: 30, maxHeight: 50),
	FloodCategory(jenis: '4', minHeight: 50, maxHeight: 100),
	FloodCategory(jenis: '5', minHeight: 100),
  ];
}

