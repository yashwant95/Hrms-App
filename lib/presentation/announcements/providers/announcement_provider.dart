import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:state_notifier/state_notifier.dart';
import 'package:mobile/domain/entities/announcement.dart';
import 'package:mobile/data/repositories/announcement_repository.dart';
import 'package:mobile/data/datasources/announcement_remote_data_source.dart';
import 'package:mobile/core/utils/api_client.dart';
import 'package:mobile/presentation/auth/providers/auth_provider.dart';

// Providers
final announcementRemoteDataSourceProvider = Provider((ref) => AnnouncementRemoteDataSource(ref.read(apiClientProvider)));
final announcementRepositoryProvider = Provider((ref) => AnnouncementRepository(ref.read(announcementRemoteDataSourceProvider)));

// State
class AnnouncementState {
  final bool isLoading;
  final String? error;
  final List<Announcement> announcements;

  const AnnouncementState({
    this.isLoading = false,
    this.error,
    this.announcements = const [],
  });

  AnnouncementState copyWith({
    bool? isLoading,
    String? error,
    List<Announcement>? announcements,
  }) {
    return AnnouncementState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      announcements: announcements ?? this.announcements,
    );
  }
}

// Notifier
class AnnouncementNotifier extends StateNotifier<AnnouncementState> {
  final AnnouncementRepository _repository;

  AnnouncementNotifier(this._repository) : super(const AnnouncementState()) {
    fetchAnnouncements();
  }

  Future<void> fetchAnnouncements() async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.getAnnouncements();
    result.fold(
      (error) => state = state.copyWith(isLoading: false, error: error),
      (data) => state = state.copyWith(isLoading: false, announcements: data),
    );
  }
}

final announcementProvider = StateNotifierProvider<AnnouncementNotifier, AnnouncementState>((ref) {
  return AnnouncementNotifier(ref.watch(announcementRepositoryProvider));
});
