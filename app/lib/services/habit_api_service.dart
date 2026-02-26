import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/habit.dart';
import '../models/profile.dart';
import '../models/progression.dart';
import '../models/quest.dart';
import 'api_exception.dart';
import 'api_base_url.dart';

class HabitApiService {
  HabitApiService({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? resolveApiBaseUrl();

  final http.Client _client;
  final String _baseUrl;

  Future<List<Habit>> fetchHabits({required String accessToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/habits');
    final response = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwOnFailure(response, fallback: 'Failed to fetch habits');

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return Habit(
        id: (map['id'] ?? '').toString(),
        title: (map['title'] ?? '').toString(),
        subtitle: (map['description'] ?? '').toString(),
        type: HabitType.fromLabel((map['type'] ?? 'FOCUS').toString()),
        completed: map['completed'] == true,
      );
    }).toList();
  }

  Future<Habit> createHabit({required String accessToken, required Habit draft}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/habits');
    final response = await _client.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({
        'title': draft.title,
        'description': draft.subtitle,
        'type': draft.type.label,
        'schedule': 'DAILY',
      }),
    );
    _throwOnFailure(response, fallback: 'Failed to create habit');

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return Habit(
      id: (map['id'] ?? '').toString(),
      title: (map['title'] ?? '').toString(),
      subtitle: (map['description'] ?? '').toString(),
      type: HabitType.fromLabel((map['type'] ?? 'FOCUS').toString()),
      completed: map['completed'] == true,
    );
  }

  Future<void> updateCompletion({
    required String accessToken,
    required String habitId,
    required bool completed,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/habits/$habitId/completion');
    final response = await _client.patch(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'completed': completed}),
    );
    _throwOnFailure(response, fallback: 'Failed to sync completion');
  }

  Future<ProgressionSnapshot> fetchProgression({required String accessToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/progression/me');
    final response = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwOnFailure(response, fallback: 'Failed to fetch progression');

    final root = jsonDecode(response.body) as Map<String, dynamic>;
    final stats = root['stats'] as Map<String, dynamic>? ?? const {};
    final avatar = root['avatar'] as Map<String, dynamic>? ?? const {};

    return ProgressionSnapshot(
      chakraXp: (stats['chakra_xp'] as num?)?.toInt() ?? 0,
      vitalityXp: (stats['vitality_xp'] as num?)?.toInt() ?? 0,
      focusXp: (stats['focus_xp'] as num?)?.toInt() ?? 0,
      auraLevel: (avatar['aura_level'] as num?)?.toInt() ?? 0,
      auraLabel: (avatar['aura_label'] ?? 'Dormant').toString(),
      avatarType: (avatar['avatar_type'] ?? 'neutral').toString(),
      streak: (stats['streak'] as num?)?.toInt() ?? 0,
      totalXp: (stats['total_xp'] as num?)?.toInt() ?? 0,
      nextLevelXp: (stats['next_level_xp'] as num?)?.toInt() ?? 1000,
      weeklyCompletionRate: (stats['weekly_completion_rate'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Future<List<QuestItem>> fetchQuests({required String accessToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/quests');
    final response = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwOnFailure(response, fallback: 'Failed to fetch quests');

    final data = jsonDecode(response.body) as List<dynamic>;
    return data.map((item) {
      final map = item as Map<String, dynamic>;
      return QuestItem(
        id: (map['id'] as num?)?.toInt() ?? 0,
        title: (map['title'] ?? '').toString(),
        status: (map['status'] ?? 'active').toString(),
        notes: (map['notes'] ?? '').toString(),
      );
    }).toList();
  }

  Future<QuestItem> createQuest({
    required String accessToken,
    required String title,
    required String notes,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/quests');
    final response = await _client.post(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'title': title, 'notes': notes}),
    );
    _throwOnFailure(response, fallback: 'Failed to create quest');

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return QuestItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? '').toString(),
      status: (map['status'] ?? 'active').toString(),
      notes: (map['notes'] ?? '').toString(),
    );
  }

  Future<QuestItem> updateQuestStatus({
    required String accessToken,
    required int questId,
    required String status,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/quests/$questId');
    final response = await _client.patch(
      uri,
      headers: _authHeaders(accessToken),
      body: jsonEncode({'status': status}),
    );
    _throwOnFailure(response, fallback: 'Failed to update quest');

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return QuestItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: (map['title'] ?? '').toString(),
      status: (map['status'] ?? 'active').toString(),
      notes: (map['notes'] ?? '').toString(),
    );
  }

  Future<ProfileSnapshot> fetchProfile({required String accessToken}) async {
    final uri = Uri.parse('$_baseUrl/api/v1/profile/me');
    final response = await _client.get(uri, headers: _authHeaders(accessToken));
    _throwOnFailure(response, fallback: 'Failed to fetch profile');

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ProfileSnapshot(
      userId: (map['user_id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      totalHabits: (map['total_habits'] as num?)?.toInt() ?? 0,
      completedHabits: (map['completed_habits'] as num?)?.toInt() ?? 0,
      chakraXp: (map['chakra_xp'] as num?)?.toInt() ?? 0,
      vitalityXp: (map['vitality_xp'] as num?)?.toInt() ?? 0,
      focusXp: (map['focus_xp'] as num?)?.toInt() ?? 0,
      auraLevel: (map['aura_level'] as num?)?.toInt() ?? 0,
      auraLabel: (map['aura_label'] ?? 'Dormant').toString(),
      avatarType: (map['avatar_type'] ?? 'neutral').toString(),
    );
  }

  Future<ProfileSnapshot> updateAvatar({
    required String accessToken,
    required String avatarType,
  }) async {
    final uri = Uri.parse('$_baseUrl/api/v1/profile/avatar').replace(
      queryParameters: {'avatar_type': avatarType},
    );
    final response = await _client.patch(uri, headers: _authHeaders(accessToken));
    _throwOnFailure(response, fallback: 'Failed to update avatar');

    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ProfileSnapshot(
      userId: (map['user_id'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      totalHabits: (map['total_habits'] as num?)?.toInt() ?? 0,
      completedHabits: (map['completed_habits'] as num?)?.toInt() ?? 0,
      chakraXp: (map['chakra_xp'] as num?)?.toInt() ?? 0,
      vitalityXp: (map['vitality_xp'] as num?)?.toInt() ?? 0,
      focusXp: (map['focus_xp'] as num?)?.toInt() ?? 0,
      auraLevel: (map['aura_level'] as num?)?.toInt() ?? 0,
      auraLabel: (map['aura_label'] ?? 'Dormant').toString(),
      avatarType: (map['avatar_type'] ?? 'neutral').toString(),
    );
  }

  void _throwOnFailure(http.Response response, {required String fallback}) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    String message = '$fallback (${response.statusCode})';
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final backendMessage = body['message']?.toString();
        if (backendMessage != null && backendMessage.isNotEmpty) {
          message = backendMessage;
        }
      }
    } catch (_) {
      if (response.body.isNotEmpty) {
        message = response.body;
      }
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: message,
    );
  }

  Map<String, String> _authHeaders(String accessToken) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      };
}
