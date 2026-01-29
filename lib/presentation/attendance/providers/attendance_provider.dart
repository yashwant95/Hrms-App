import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import '../../auth/providers/auth_provider.dart';

import '../../../core/utils/api_client.dart';
import '../../../data/datasources/attendance_remote_data_source.dart';
import '../../../data/repositories/attendance_repository_impl.dart';
import '../../../domain/repositories/attendance_repository.dart';

// Providers
final attendanceRemoteDataSourceProvider = Provider((ref) => AttendanceRemoteDataSource(ref.read(apiClientProvider)));
final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) => AttendanceRepositoryImpl(ref.read(attendanceRemoteDataSourceProvider)));

// State
class AttendanceState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? todayStatus;

  const AttendanceState({
    this.isLoading = false,
    this.error,
    this.todayStatus,
  });

  AttendanceState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? todayStatus,
  }) {
    return AttendanceState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      todayStatus: todayStatus ?? this.todayStatus,
    );
  }
}

// Notifier
class AttendanceNotifier extends StateNotifier<AttendanceState> {
  final AttendanceRepository _repository;

  AttendanceNotifier(this._repository) : super(const AttendanceState()) {
    getTodayStatus();
  }

  Future<void> getTodayStatus() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getTodayStatus();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (data) => state = state.copyWith(isLoading: false, todayStatus: data),
    );
  }

  Future<void> checkIn() async {
    state = state.copyWith(isLoading: true);
    // Hardcoded location for demo
    final result = await _repository.checkIn(37.422, -122.084, 'Googleplex, Mountain View');
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (data) {
        state = state.copyWith(isLoading: false);
        getTodayStatus(); // refresh
      },
    );
  }

  Future<void> checkOut() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.checkOut();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (data) {
        state = state.copyWith(isLoading: false);
        getTodayStatus(); // refresh
      },
    );
  }
}

final attendanceProvider = StateNotifierProvider<AttendanceNotifier, AttendanceState>((ref) {
  return AttendanceNotifier(ref.watch(attendanceRepositoryProvider));
});
