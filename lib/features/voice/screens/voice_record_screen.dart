import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../bloc/voice_bloc.dart';
import '../bloc/voice_event.dart';
import '../bloc/voice_state.dart';
import 'voice_review_screen.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snack_bar.dart';
import '../../../shared/utils/localized_message_resolver.dart';

/// Full-screen modal for recording a voice expense entry.
///
/// Flow:
///   1. User taps the mic button  -> [VoiceStartRecording] dispatched.
///   2. Timer counts up while recording.
///   3. User taps the stop button -> [VoiceStopRecording] dispatched.
///   4. Screen shows "Procesando..." while Groq transcribes and Gemini extracts.
///   5. On [VoiceStatus.reviewing] the screen pushes [VoiceReviewScreen].
///
/// A [VoiceBloc] must be provided above this widget.
class VoiceRecordScreen extends StatelessWidget {
  const VoiceRecordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<VoiceBloc, VoiceState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: (context, state) {
        if (state.status == VoiceStatus.reviewing) {
          Navigator.of(context).push<void>(
            MaterialPageRoute(
              builder: (_) => BlocProvider.value(
                value: context.read<VoiceBloc>(),
                child: const VoiceReviewScreen(),
              ),
            ),
          );
        }

        if (state.status == VoiceStatus.error && state.errorMessage != null) {
          final l10n = AppLocalizations.of(context)!;
          AppSnackBar.showError(
            context,
            state.errorMessage!.resolve(l10n),
            actionLabel: l10n.retry,
            onAction: () => context.read<VoiceBloc>().add(const VoiceReset()),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.voiceRecordTitle),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () {
              context.read<VoiceBloc>().add(const VoiceReset());
              Navigator.of(context).pop();
            },
          ),
        ),
        body: const _VoiceRecordBody(),
      ),
    );
  }
}

class _VoiceRecordBody extends StatelessWidget {
  const _VoiceRecordBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VoiceBloc, VoiceState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        final isRecording = state.status == VoiceStatus.recording;
        final isProcessing = state.status == VoiceStatus.processing;
        final isBusy = isProcessing;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 32),

                Text(
                  isRecording
                      ? l10n.voiceRecordingStatus
                      : isProcessing
                          ? l10n.voiceProcessingStatus
                          : l10n.voiceIdleStatus,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                _MicButton(
                  isRecording: isRecording,
                  isBusy: isBusy,
                  onTap: isBusy
                      ? null
                      : () {
                          if (isRecording) {
                            context
                                .read<VoiceBloc>()
                                .add(const VoiceStopRecording());
                          } else {
                            context
                                .read<VoiceBloc>()
                                .add(const VoiceStartRecording());
                          }
                        },
                ),

                const SizedBox(height: 40),

                Expanded(
                  child: Center(
                    child: isRecording
                        ? _RecordingTimer(startedAt: state.recordingStartedAt)
                        : isProcessing
                            ? _ProcessingIndicator()
                            : _IdleHint(),
                  ),
                ),

                const SizedBox(height: 32),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: isBusy
                        ? null
                        : () {
                            context
                                .read<VoiceBloc>()
                                .add(const VoiceReset());
                            Navigator.of(context).pop();
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(l10n.cancel),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.isRecording,
    required this.isBusy,
    this.onTap,
  });

  final bool isRecording;
  final bool isBusy;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const primaryColor = AppColors.teal400;

    Widget button = GestureDetector(
      onTap: onTap,
      child: Container(
        width: 88,
        height: 88,
        decoration: BoxDecoration(
          color:
              isRecording ? primaryColor : colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
          boxShadow: isRecording
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: isBusy
            ? const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : Icon(
                isRecording ? Icons.stop_rounded : Icons.mic_none_rounded,
                size: 40,
                color: isRecording ? Colors.white : colorScheme.onSurfaceVariant,
              ),
      ),
    );

    if (isRecording) {
      button = button
          .animate(onPlay: (c) => c.repeat())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.12, 1.12),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            begin: const Offset(1.12, 1.12),
            end: const Offset(1.0, 1.0),
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeInOut,
          );
    }

    return button;
  }
}

class _RecordingTimer extends StatefulWidget {
  const _RecordingTimer({this.startedAt});
  final DateTime? startedAt;

  @override
  State<_RecordingTimer> createState() => _RecordingTimerState();
}

class _RecordingTimerState extends State<_RecordingTimer> {
  late Timer _timer;
  Duration _elapsed = Duration.zero;

  @override
  void initState() {
    super.initState();
    _tick();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (!mounted) return;
    setState(() {
      _elapsed = widget.startedAt != null
          ? DateTime.now().difference(widget.startedAt!)
          : Duration.zero;
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _elapsed.inMinutes.toString().padLeft(2, '0');
    final seconds = (_elapsed.inSeconds % 60).toString().padLeft(2, '0');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$minutes:$seconds',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
                color: AppColors.teal400,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.voiceRecordingLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context)
                    .colorScheme
                    .onSurfaceVariant
                    .withValues(alpha: 0.6),
              ),
        ),
      ],
    );
  }
}

class _ProcessingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(
          color: AppColors.teal400,
          strokeWidth: 3,
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.voiceTranscribingLabel,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _IdleHint extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      AppLocalizations.of(context)!.voiceIdleExample,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context)
                .colorScheme
                .onSurfaceVariant
                .withValues(alpha: 0.6),
            fontStyle: FontStyle.italic,
          ),
      textAlign: TextAlign.center,
    );
  }
}
