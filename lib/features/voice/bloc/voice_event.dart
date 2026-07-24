import 'package:equatable/equatable.dart';

import '../models/transaction_draft_model.dart';

/// Events dispatched to [VoiceBloc].
abstract class VoiceEvent extends Equatable {
  const VoiceEvent();

  @override
  List<Object?> get props => [];
}

class VoiceStartRecording extends VoiceEvent {
  const VoiceStartRecording();
}

/// Stops the active recording and uploads the audio for transcription and extraction.
class VoiceStopRecording extends VoiceEvent {
  const VoiceStopRecording();
}

class VoiceDraftUpdated extends VoiceEvent {
  const VoiceDraftUpdated({required this.index, required this.draft});

  final int index;
  final TransactionDraftModel draft;

  @override
  List<Object?> get props => [index, draft];
}

/// Saves all included drafts by calling POST /api/v1/transactions for each.
class VoiceDraftConfirmed extends VoiceEvent {
  const VoiceDraftConfirmed();
}

class VoiceReset extends VoiceEvent {
  const VoiceReset();
}

class VoiceError extends VoiceEvent {
  const VoiceError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
