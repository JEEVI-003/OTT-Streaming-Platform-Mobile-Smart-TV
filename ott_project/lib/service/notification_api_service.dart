import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/components/notification/notification.dart';
import 'package:ott_project/service/authservice.dart';
import 'package:ott_project/url.dart';

class NotificationApiService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _headers([String? token]) async {
    final rawToken = (token ?? await _authService.getToken())?.trim();
    final normalizedToken = _normalizeToken(rawToken);
    if (normalizedToken == null || normalizedToken.isEmpty) {
      return const {'Content-Type': 'application/json'};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $normalizedToken',
    };
  }

  String? _normalizeToken(String? token) {
    if (token == null) return null;
    final trimmed = token.trim();
    if (trimmed.isEmpty) return null;
    return trimmed.toLowerCase().startsWith('bearer ')
        ? trimmed.substring(7).trim()
        : trimmed;
  }

  void _log(String message) {
    if (kDebugMode) debugPrint(message);
  }

  Future<List<Notifications>> fetchNotification([String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/usernotifications'),
        headers: await _headers(token),
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is! List) return [];
        return decoded
            .map((json) => Notifications.fromJson(json))
            .toList();
      }

      if (response.statusCode == 401) {
        _log('Notification request unauthorized (401)');
      } else {
        _log('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      _log('Notification fetch error: $e');
    }
    return [];
  }

  Future<bool> markAllasRead([String? token]) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/markAllAsReaduser'),
        headers: await _headers(token),
      );

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        _log('Mark-all-as-read unauthorized (401)');
      } else {
        _log('Error in marking all as read: ${response.statusCode}');
      }
    } catch (e) {
      _log('Mark-all-as-read error: $e');
    }
    return false;
  }

  Future<int> fetchUnreadCount([String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/unreadCountuser'),
        headers: await _headers(token),
      );

      if (response.statusCode == 200) {
        final body = response.body.trim();
        return int.tryParse(body) ?? 0;
      }

      if (response.statusCode == 401) {
        _log('Unread-count unauthorized (401)');
      } else {
        _log('Error in count: ${response.statusCode}');
      }
    } catch (e) {
      _log('Unread-count error: $e');
    }
    return 0;
  }

  Future<bool> clearAllNotifications([String? token]) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/clearAlluser'),
        headers: await _headers(token),
      );

      if (response.statusCode == 200) {
        return true;
      }

      if (response.statusCode == 401) {
        _log('Clear-all unauthorized (401)');
      } else {
        _log('Error in clearing: ${response.statusCode}');
      }
    } catch (e) {
      _log('Clear-all error: $e');
    }
    return false;
  }
}
