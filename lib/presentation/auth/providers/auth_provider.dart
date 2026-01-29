import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/utils/api_client.dart';
import '../../../data/datasources/auth_remote_data_source.dart';
import '../../../data/repositories/auth_repository_impl.dart';
import '../../../domain/repositories/auth_repository.dart';

// Providers for dependencies
final apiClientProvider = Provider((ref) => ApiClient());
final authRemoteDataSourceProvider = Provider((ref) => AuthRemoteDataSource(ref.read(apiClientProvider)));
final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider)));

// Auth State
class AuthState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? user;
  final bool isAuthenticated;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.user,
    this.isAuthenticated = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? user,
    bool? isAuthenticated,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

// Auth Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final _storage = const FlutterSecureStorage();

  AuthNotifier(this._repository) : super(const AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);
    final token = await _storage.read(key: 'token');
    if (token != null) {
      // In a real app, you might want to fetch user profile here
      state = state.copyWith(isLoading: false, isAuthenticated: true);
    } else {
      state = state.copyWith(isLoading: false, isAuthenticated: false);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    
    // Simulating API delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock successful login data
    final mockUser = {
      'id': '123',
      'email': email,
      'name': 'John Doe',
      'role': 'EMPLOYEE',
    };
    
    await _storage.write(key: 'token', value: 'mock_token_123');
    state = state.copyWith(
      isLoading: false, 
      user: mockUser, 
      isAuthenticated: true
    );
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    state = const AuthState();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
