/// Identifies a message that originates in Dart code (a bloc), as opposed
/// to one that arrives as text from the backend.
///
/// Blocs have zero Flutter framework dependencies - no [BuildContext], no
/// `material.dart` imports - which keeps them unit-testable without a
/// widget tree. That means they cannot call `AppLocalizations.of(context)`
/// directly, so a bloc that used to hard-code a Spanish string instead
/// emits one of these codes; the widget layer resolves it to a localized
/// string at render time (see `LocalizedMessage.resolve`).
enum FailureCode {
  accountCreated,
  accountUpdated,
  accountDeleted,
  accountSetDefault,
  categoryCreated,
  categoryUpdated,
  categoryDeleted,
  categorySetDefault,
  transactionCreated,
  transactionUpdated,
  transactionDeleted,
  authInvalidCredentials,
  authEmailAlreadyRegistered,
  noInternetConnection,
  voiceMicPermissionRequired,
  voiceRecordingFileNotFound,
  voiceSomeTransactionsFailedToSave,
}
