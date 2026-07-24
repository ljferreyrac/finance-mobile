import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/api/dio_client.dart';
import '../../../shared/models/failure.dart';
import '../../accounts/data/account_repository.dart';
import '../../categories/data/category_repository.dart';
import '../../transactions/data/tag_repository.dart';
import '../data/voice_api_service.dart';
import '../models/transaction_draft_model.dart';
import 'voice_event.dart';
import 'voice_state.dart';

/// Manages the full voice-to-transaction flow:
///
///   idle -> recording -> processing -> reviewing -> saving -> success
///
/// Any step can transition to [VoiceStatus.error].
class VoiceBloc extends Bloc<VoiceEvent, VoiceState> {
  VoiceBloc({
    VoiceApiService? apiService,
    AccountRepository? accountRepository,
    CategoryRepository? categoryRepository,
    TagRepository? tagRepository,
  })  : _api = apiService ?? VoiceApiService(),
        _accountRepo = accountRepository ?? AccountRepositoryImpl(),
        _categoryRepo = categoryRepository ?? CategoryRepositoryImpl(),
        _tagRepo = tagRepository ?? TagRepositoryImpl(),
        super(const VoiceState()) {
    on<VoiceStartRecording>(_onStartRecording);
    on<VoiceStopRecording>(_onStopRecording);
    on<VoiceDraftUpdated>(_onDraftUpdated);
    on<VoiceDraftConfirmed>(_onDraftConfirmed);
    on<VoiceReset>(_onReset);
    on<VoiceError>(_onError);
  }

  final VoiceApiService _api;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final TagRepository _tagRepo;
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  bool _recorderOpen = false;

  Future<void> _onStartRecording(
    VoiceStartRecording event,
    Emitter<VoiceState> emit,
  ) async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      emit(state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'Se necesita permiso de microfono para grabar audio.',
      ));
      return;
    }

    try {
      if (!_recorderOpen) {
        await _recorder.openRecorder();
        _recorderOpen = true;
      }

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/voice_recording.m4a';

      await _recorder.startRecorder(
        toFile: path,
        codec: Codec.aacMP4,
        numChannels: 1,
        sampleRate: 44100,
      );

      emit(state.copyWith(
        status: VoiceStatus.recording,
        recordingStartedAt: DateTime.now(),
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'No se pudo iniciar la grabacion: ${e.toString()}',
      ));
    }
  }

  Future<void> _onStopRecording(
    VoiceStopRecording event,
    Emitter<VoiceState> emit,
  ) async {
    final audioPath = await _recorder.stopRecorder();

    if (audioPath == null) {
      emit(state.copyWith(
        status: VoiceStatus.error,
        errorMessage: 'No se encontro el archivo de audio grabado.',
      ));
      return;
    }

    emit(state.copyWith(
      status: VoiceStatus.processing,
      clearRecordingStart: true,
      clearError: true,
    ));

    try {
      final results = await Future.wait([
        _api.transcribeAndExtract(audioPath),
        _accountRepo.getAccounts(),
        _categoryRepo.listCategories(),
        _tagRepo.getTags(),
      ]);

      final drafts = results[0] as List<TransactionDraftModel>;
      final accounts = results[1] as List;
      final categories = results[2] as List;
      final tags = results[3] as List;

      final enrichedDrafts = drafts.map((d) {
        final resolvedTags = d.tags
            .map((stub) => tags.firstWhere(
                  (t) => t.id == stub.id,
                  orElse: () => stub,
                ))
            .toList();
        return d.copyWith(tags: List.unmodifiable(resolvedTags));
      }).toList();

      emit(state.copyWith(
        status: VoiceStatus.reviewing,
        drafts: enrichedDrafts,
        availableAccounts: List.unmodifiable(accounts),
        availableCategories: List.unmodifiable(categories),
        availableTags: List.unmodifiable(tags),
      ));
    } on Failure catch (f) {
      emit(state.copyWith(status: VoiceStatus.error, errorMessage: f.message));
    } on DioException catch (e) {
      emit(state.copyWith(
          status: VoiceStatus.error,
          errorMessage: DioClient.errorMessage(e)));
    } catch (e) {
      emit(state.copyWith(
          status: VoiceStatus.error, errorMessage: e.toString()));
    }
  }

  void _onDraftUpdated(
    VoiceDraftUpdated event,
    Emitter<VoiceState> emit,
  ) {
    final updated = List<TransactionDraftModel>.from(state.drafts);
    if (event.index < 0 || event.index >= updated.length) return;
    updated[event.index] = event.draft;
    emit(state.copyWith(drafts: updated));
  }

  Future<void> _onDraftConfirmed(
    VoiceDraftConfirmed event,
    Emitter<VoiceState> emit,
  ) async {
    final included = state.drafts.where((d) => d.included).toList();
    if (included.isEmpty) return;

    emit(state.copyWith(status: VoiceStatus.saving));

    int saved = 0;
    String? lastError;

    for (final draft in included) {
      try {
        await _api.createTransaction(draft.toCreateBody());
        saved++;
      } on Failure catch (f) {
        lastError = f.message;
      } on DioException catch (e) {
        lastError = DioClient.errorMessage(e);
      } catch (e) {
        lastError = e.toString();
      }
    }

    if (saved == included.length) {
      emit(state.copyWith(
        status: VoiceStatus.success,
        savedCount: saved,
        clearError: true,
      ));
    } else {
      emit(state.copyWith(
        status: VoiceStatus.error,
        savedCount: saved,
        errorMessage:
            lastError ?? 'Algunas transacciones no se pudieron guardar.',
      ));
    }
  }

  Future<void> _onReset(
    VoiceReset event,
    Emitter<VoiceState> emit,
  ) async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    emit(const VoiceState());
  }

  void _onError(
    VoiceError event,
    Emitter<VoiceState> emit,
  ) {
    emit(state.copyWith(
      status: VoiceStatus.error,
      errorMessage: event.message,
    ));
  }

  @override
  Future<void> close() async {
    if (_recorder.isRecording) {
      await _recorder.stopRecorder();
    }
    if (_recorderOpen) {
      await _recorder.closeRecorder();
    }
    return super.close();
  }
}
