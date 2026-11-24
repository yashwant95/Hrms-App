import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../domain/entities/field_timeline.dart';
import '../../../data/datasources/field_tracking_remote_data_source.dart';
import '../../../data/repositories/field_tracking_repository.dart';
import '../../auth/providers/auth_provider.dart';

final fieldTrackingRemoteDataSourceProvider =
    Provider((ref) => FieldTrackingRemoteDataSource(ref.read(apiClientProvider)));

final fieldTrackingRepositoryProvider =
    Provider((ref) => FieldTrackingRepository(ref.read(fieldTrackingRemoteDataSourceProvider)));

class FieldTrackingState {
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final FieldTimeline? timeline;

  const FieldTrackingState({
    this.isLoading = false,
    this.error,
    required this.selectedDate,
    this.timeline,
  });

  FieldTrackingState copyWith({
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    FieldTimeline? timeline,
  }) {
    return FieldTrackingState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedDate: selectedDate ?? this.selectedDate,
      timeline: timeline ?? this.timeline,
    );
  }
}

class FieldTrackingNotifier extends StateNotifier<FieldTrackingState> {
  final FieldTrackingRepository _repository;

  FieldTrackingNotifier(this._repository)
      : super(FieldTrackingState(selectedDate: DateTime.now())) {
    fetchTimeline();
  }

  Future<void> fetchTimeline([DateTime? date]) async {
    final targetDate = date ?? state.selectedDate;
    state = state.copyWith(isLoading: true, selectedDate: targetDate, error: null);

    final dateStr = DateFormat('yyyy-MM-dd').format(targetDate);
    final result = await _repository.getDayTimeline(date: dateStr);

    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (timeline) => state = state.copyWith(isLoading: false, timeline: timeline),
    );
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
    fetchTimeline(date);
  }

  Future<bool> logClientVisit({
    required String clientName,
    required String address,
    String? notes,
    String? contactPerson,
    double latitude = 12.9716, // fallback BLR
    double longitude = 77.5946,
  }) async {
    final payload = {
      'clientName': clientName,
      'address': address,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      if (contactPerson != null && contactPerson.isNotEmpty) 'contactPerson': contactPerson,
      'latitude': latitude,
      'longitude': longitude,
    };

    final result = await _repository.logClientVisit(payload);
    return result.fold(
      (error) {
        state = state.copyWith(error: error);
        return false;
      },
      (newStop) {
        fetchTimeline();
        return true;
      },
    );
  }

  Future<bool> checkoutClientVisit(String visitId, {String? notes}) async {
    final result = await _repository.checkoutClientVisit(visitId, notes: notes);
    return result.fold(
      (error) {
        state = state.copyWith(error: error);
        return false;
      },
      (_) {
        fetchTimeline();
        return true;
      },
    );
  }
}

final fieldTrackingProvider =
    StateNotifierProvider<FieldTrackingNotifier, FieldTrackingState>((ref) {
  return FieldTrackingNotifier(ref.watch(fieldTrackingRepositoryProvider));
});
