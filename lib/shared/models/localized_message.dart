import 'failure_code.dart';

/// A message that is either a [FailureCode] emitted by a bloc (resolved to
/// a localized string by `LocalizedMessageResolver.resolve` at render time)
/// or already plain text (a [raw] string - typically a backend-provided
/// message, e.g. `Failure.message`, which the server decides the language
/// of and this app has no further translation to apply).
///
/// Kept dependency-free (no Flutter, no AppLocalizations) so bloc files
/// that construct these stay widget-tree-independent; see
/// `shared/utils/localized_message_resolver.dart` for the widget-layer half.
sealed class LocalizedMessage {
  const LocalizedMessage();

  const factory LocalizedMessage.code(FailureCode code) = _CodedMessage;
  const factory LocalizedMessage.raw(String text) = _RawMessage;

  /// Visitor: exactly one branch runs depending on which variant this is.
  T when<T>({
    required T Function(FailureCode code) code,
    required T Function(String text) raw,
  }) => switch (this) {
        _CodedMessage(value: final c) => code(c),
        _RawMessage(value: final t) => raw(t),
      };
}

class _CodedMessage extends LocalizedMessage {
  const _CodedMessage(this.value);
  final FailureCode value;
}

class _RawMessage extends LocalizedMessage {
  const _RawMessage(this.value);
  final String value;
}
