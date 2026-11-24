import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io' show Platform;
import '../../../core/utils/api_client.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';

// Providers for dependencies
final apiClientProvider = Provider((ref) => ApiClient());
final authRemoteDataSourceProvider = Provider(
  (ref) => AuthRemoteDataSource(ref.read(apiClientProvider)),
);
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)),
);

// Auth State
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final List<String> permissions;
  final List<String> modules;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.permissions = const [],
    this.modules = const [],
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    List<String>? permissions,
    List<String>? modules,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      permissions: permissions ?? this.permissions,
      modules: modules ?? this.modules,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final ApiClient _apiClient;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository, this._apiClient) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'token');
    if (token != null) {
      try {
        final response = await _apiClient.client.get('/auth/me');
        final data = Map<String, dynamic>.from(response.data as Map);
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: Map<String, dynamic>.from(data['user'] as Map),
          permissions: List<String>.from(data['permissions'] ?? const []),
          modules: List<String>.from(
            (data['entitlements']?['modules'] as List?) ?? const [],
          ),
        );
        await _registerPushToken();
      } catch (_) {
        await _storage.delete(key: 'token');
        await _storage.delete(key: 'refreshToken');
        state = const AuthState();
      }
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.login(email, password);
    await result.fold(
      (error) async {
        state = state.copyWith(
          isLoading: false,
          error: error,
          isAuthenticated: false,
        );
      },
      (response) async {
        final token = response['token'] as String?;
        final user = Map<String, dynamic>.from(response['user'] as Map);
        if (token == null) {
          state = state.copyWith(
            isLoading: false,
            error: 'The server did not return a sign-in token.',
          );
          return;
        }
        await _storage.write(key: 'token', value: token);
        final refreshToken = response['refreshToken'] as String?;
        if (refreshToken != null) {
          await _storage.write(key: 'refreshToken', value: refreshToken);
        }
        final modules = List<String>.from(
          (response['entitlements']?['modules'] as List?) ?? const [],
        );
        state = state.copyWith(
          isLoading: false,
          user: user,
          permissions: List<String>.from(response['permissions'] ?? const []),
          modules: modules,
          isAuthenticated: true,
        );
        await _registerPushToken();
      },
    );
  }

  Future<void> _registerPushToken() async {
    if (!state.modules.contains('chat')) return;
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      final platform = Platform.isIOS ? 'IOS' : 'ANDROID';
      if (token != null) {
        await _apiClient.client.post(
          '/chat/devices',
          data: {'token': token, 'platform': platform},
        );
      }
      messaging.onTokenRefresh.listen((nextToken) {
        _apiClient.client.post(
          '/chat/devices',
          data: {'token': nextToken, 'platform': platform},
        );
      });
    } catch (_) {
      // Push needs per-platform Firebase configuration; sign-in and chat continue without it.
    }
  }

  Future<void> logout() async {
    if (state.modules.contains('chat')) {
      try {
        final token = await FirebaseMessaging.instance.getToken();
        if (token != null) {
          await _apiClient.client.delete(
            '/chat/devices',
            data: {'token': token},
          );
        }
      } catch (_) {}
    }
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'refreshToken');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(apiClientProvider),
  );
});
