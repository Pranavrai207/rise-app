import '../models/habit.dart';
import '../models/profile.dart';
import '../models/progression.dart';
import '../models/quest.dart';
import '../services/api_exception.dart';
import '../services/connectivity_service.dart';
import '../services/habit_api_service.dart';
import '../services/habit_local_store.dart';
import 'auth_repository.dart';

class HabitRepository {
  HabitRepository({
    HabitLocalStore? localStore,
    HabitApiService? apiService,
    required this.authRepository,
    this.enableRemoteSync = true,
    this.connectivityService,
  })  : _localStore = localStore ?? HabitLocalStore(),
        _apiService = apiService ?? HabitApiService();

  final HabitLocalStore _localStore;
  final HabitApiService _apiService;
  final AuthRepository authRepository;
  final bool enableRemoteSync;
  final ConnectivityService? connectivityService;

  /// True when remote calls are possible.
  bool get isOnline =>
      enableRemoteSync &&
      authRepository.accessToken != null &&
      (connectivityService?.isOnline.value ?? true);

  Future<List<Habit>> loadHabits() async {
    List<Habit> habits;

    if (enableRemoteSync && authRepository.accessToken != null) {
      try {
        final remote = await authRepository.withAuthRetry(
          (token) => _apiService.fetchHabits(accessToken: token),
        );
        await _localStore.saveHabits(remote);
        habits = remote;
      } on ApiException catch (e) {
        if (e.statusCode == 401) {
          rethrow;
        }
        habits = await _localStore.loadHabits();
      } catch (_) {
        habits = await _localStore.loadHabits();
      }
    } else {
      habits = await _localStore.loadHabits();
    }

    if (habits.isEmpty) {
      final seeded = defaultHabits();
      await _localStore.saveHabits(seeded);
      habits = seeded;
    }

    // ── Daily reset: if saved completion date differs from today, reset all ──
    final savedDate = await _localStore.loadCompletionDate();
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    if (savedDate == null || savedDate.isBefore(todayDate)) {
      for (final habit in habits) {
        habit.completed = false;
      }
      await _localStore.saveHabits(habits);
      await _localStore.saveCompletionDate(todayDate);
    }

    return habits;
  }

  Future<ProgressionSnapshot?> loadProgression() async {
    if (!enableRemoteSync || authRepository.accessToken == null) {
      return null;
    }

    try {
      return await authRepository.withAuthRetry(
        (token) => _apiService.fetchProgression(accessToken: token),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        rethrow;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> saveHabits(List<Habit> habits) async {
    await _localStore.saveHabits(habits);
  }

  Future<Habit> addHabit(Habit draft) async {
    if (enableRemoteSync && authRepository.accessToken != null) {
      return authRepository.withAuthRetry(
        (token) => _apiService.createHabit(accessToken: token, draft: draft),
      );
    }

    return draft;
  }

  Future<void> syncCompletion(Habit habit) async {
    if (!enableRemoteSync || authRepository.accessToken == null) {
      return;
    }

    await authRepository.withAuthRetry(
      (token) => _apiService.updateCompletion(
        accessToken: token,
        habitId: habit.id,
        completed: habit.completed,
      ),
    );
  }

  Future<List<QuestItem>> loadQuests() async {
    if (!isOnline) {
      return const [];
    }

    return authRepository.withAuthRetry(
      (token) => _apiService.fetchQuests(accessToken: token),
    );
  }

  Future<QuestItem> addQuest({required String title, required String notes}) async {
    if (!isOnline) {
      throw const ApiException(statusCode: 0, message: 'You are offline. Quest submission requires an internet connection.');
    }

    return authRepository.withAuthRetry(
      (token) => _apiService.createQuest(accessToken: token, title: title, notes: notes),
    );
  }

  Future<QuestItem> setQuestDone(int questId) async {
    if (!isOnline) {
      throw const ApiException(statusCode: 0, message: 'You are offline. Quest completion requires an internet connection.');
    }

    return authRepository.withAuthRetry(
      (token) => _apiService.updateQuestStatus(
        accessToken: token,
        questId: questId,
        status: 'done',
      ),
    );
  }

  Future<ProfileSnapshot?> loadProfile() async {
    if (!enableRemoteSync || authRepository.accessToken == null) {
      return null;
    }

    try {
      return await authRepository.withAuthRetry(
        (token) => _apiService.fetchProfile(accessToken: token),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 401) {
        rethrow;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<ProfileSnapshot> updateAvatar({required String avatarType}) async {
    if (!isOnline) {
      throw const ApiException(statusCode: 0, message: 'You are offline. Avatar updates require an internet connection.');
    }

    return authRepository.withAuthRetry(
      (token) => _apiService.updateAvatar(accessToken: token, avatarType: avatarType),
    );
  }
}
