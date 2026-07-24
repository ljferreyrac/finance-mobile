import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/api/dio_client.dart';
import '../../transactions/data/transaction_api_service.dart';
import '../../transactions/models/transaction_model.dart';
import '../models/transaction_draft_model.dart';

/// Raw HTTP calls for the voice entry flow.
///
/// - [transcribeAndExtract] uploads an audio file to the backend, which
///   transcribes it with Groq Whisper and extracts transaction drafts with Gemini.
/// - Transaction creation is delegated to [TransactionApiService].
class VoiceApiService {
  VoiceApiService({Dio? dio})
      : _dio = dio ?? DioClient.instance,
        _transactionApiService =
            TransactionApiService(dio: dio ?? DioClient.instance);

  final Dio _dio;
  final TransactionApiService _transactionApiService;

  static const String _voiceAudioPath = '/transactions/voice-audio';

  /// Uploads [audioFilePath] to the backend, which transcribes it with Groq
  /// Whisper and returns extracted [TransactionDraftModel] candidates.
  ///
  /// Throws [DioException] on non-2xx responses.
  Future<List<TransactionDraftModel>> transcribeAndExtract(
    String audioFilePath,
  ) async {
    final offset = DateTime.now().timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final userTimezone = '$sign$hours:$minutes';

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        audioFilePath,
        filename: File(audioFilePath).uri.pathSegments.last,
      ),
      'timezone': userTimezone,
    });

    final response = await _dio.post<List<dynamic>>(
      _voiceAudioPath,
      data: formData,
    );

    final list = response.data ?? [];
    return list
        .cast<Map<String, dynamic>>()
        .map(TransactionDraftModel.fromJson)
        .toList();
  }

  /// Creates a single transaction from [body].
  Future<TransactionModel> createTransaction(
    Map<String, dynamic> body,
  ) =>
      _transactionApiService.createTransaction(body);
}
