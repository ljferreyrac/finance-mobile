import 'package:equatable/equatable.dart';

import '../../../shared/models/localized_message.dart';
import '../../accounts/models/account_model.dart';
import '../../categories/models/category_model.dart';
import '../../transactions/models/tag_model.dart';
import '../models/transaction_draft_model.dart';

enum VoiceStatus {
  idle,
  recording,

  /// Audio uploaded; Groq is transcribing and Gemini is extracting drafts.
  processing,

  reviewing,

  /// Confirmed drafts are persisted one by one, not as a batch.
  saving,

  success,

  /// Can occur at any phase, not just after saving.
  error,
}

/// Single immutable state for [VoiceBloc].
class VoiceState extends Equatable {
  const VoiceState({
    this.status = VoiceStatus.idle,
    this.recordingStartedAt,
    this.drafts = const [],
    this.errorMessage,
    this.savedCount = 0,
    this.availableAccounts = const [],
    this.availableCategories = const [],
    this.availableTags = const [],
  });

  final VoiceStatus status;

  /// When the current recording started; used by the UI to display a live timer.
  final DateTime? recordingStartedAt;

  /// Extracted transaction drafts returned by the backend.
  final List<TransactionDraftModel> drafts;

  /// Error message. Non-null when [status] is [VoiceStatus.error].
  final LocalizedMessage? errorMessage;

  /// Number of drafts that were successfully saved to the backend.
  final int savedCount;

  final List<AccountModel> availableAccounts;
  final List<CategoryModel> availableCategories;
  final List<TagModel> availableTags;

  VoiceState copyWith({
    VoiceStatus? status,
    DateTime? recordingStartedAt,
    bool clearRecordingStart = false,
    List<TransactionDraftModel>? drafts,
    LocalizedMessage? errorMessage,
    bool clearError = false,
    int? savedCount,
    List<AccountModel>? availableAccounts,
    List<CategoryModel>? availableCategories,
    List<TagModel>? availableTags,
  }) {
    return VoiceState(
      status: status ?? this.status,
      recordingStartedAt: clearRecordingStart
          ? null
          : (recordingStartedAt ?? this.recordingStartedAt),
      drafts: drafts ?? this.drafts,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedCount: savedCount ?? this.savedCount,
      availableAccounts: availableAccounts ?? this.availableAccounts,
      availableCategories: availableCategories ?? this.availableCategories,
      availableTags: availableTags ?? this.availableTags,
    );
  }

  @override
  List<Object?> get props => [
        status,
        recordingStartedAt,
        drafts,
        errorMessage,
        savedCount,
        availableAccounts,
        availableCategories,
        availableTags,
      ];
}
