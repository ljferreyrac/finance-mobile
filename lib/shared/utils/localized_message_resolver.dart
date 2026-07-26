import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../models/failure_code.dart';
import '../models/localized_message.dart';

/// Resolves a [LocalizedMessage] to a display string. Call at render time,
/// where a [BuildContext] (and therefore [AppLocalizations]) is available -
/// blocs cannot do this themselves, which is the whole reason
/// [LocalizedMessage] exists instead of a plain hard-coded [String].
extension LocalizedMessageResolver on LocalizedMessage {
  String resolve(AppLocalizations l10n) => when(
        code: (c) => switch (c) {
          FailureCode.accountCreated => l10n.accountCreated,
          FailureCode.accountUpdated => l10n.accountUpdated,
          FailureCode.accountDeleted => l10n.accountDeleted,
          FailureCode.accountSetDefault => l10n.accountSetDefault,
          FailureCode.categoryCreated => l10n.categoryCreated,
          FailureCode.categoryUpdated => l10n.categoryUpdated,
          FailureCode.categoryDeleted => l10n.categoryDeleted,
          FailureCode.categorySetDefault => l10n.categorySetDefault,
          FailureCode.transactionCreated => l10n.transactionCreated,
          FailureCode.transactionUpdated => l10n.transactionUpdated,
          FailureCode.transactionDeleted => l10n.transactionDeleted,
          FailureCode.authInvalidCredentials => l10n.authInvalidCredentials,
          FailureCode.authEmailAlreadyRegistered =>
            l10n.emailAlreadyRegistered,
          FailureCode.noInternetConnection => l10n.noInternetConnection,
          FailureCode.voiceMicPermissionRequired =>
            l10n.micPermissionRequired,
          FailureCode.voiceRecordingFileNotFound =>
            l10n.recordingFileNotFound,
          FailureCode.voiceSomeTransactionsFailedToSave =>
            l10n.someTransactionsFailedToSave,
        },
        raw: (t) => t,
      );
}
