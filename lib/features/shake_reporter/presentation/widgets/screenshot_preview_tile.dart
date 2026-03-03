import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_build_context_extensions.dart';
import '../cubit/shake_reporter_cubit.dart';
import '../cubit/shake_reporter_state.dart';

class ScreenshotPreviewTile extends StatelessWidget {
  const ScreenshotPreviewTile({super.key});

  Uint8List? _decodeScreenshot(String? screenshotBase64) {
    if (screenshotBase64 == null) return null;
    final trimmed = screenshotBase64.trim();
    if (trimmed.isEmpty) return null;
    try {
      final bytes = base64Decode(trimmed);
      if (bytes.isEmpty) return null;
      return bytes;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocBuilder<ShakeReporterCubit, ShakeReporterState>(
      buildWhen: (previous, current) {
        if (previous.runtimeType != current.runtimeType) return true;
        if (previous is! ShakeReporterReady || current is! ShakeReporterReady) {
          return true;
        }
        return previous.includeScreenshot != current.includeScreenshot ||
            previous.screenshotBase64 != current.screenshotBase64;
      },
      builder: (context, state) {
        if (state is! ShakeReporterReady) return const SizedBox.shrink();

        final screenshotBytes = _decodeScreenshot(state.screenshotBase64);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.camera_alt_outlined,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      context.locale.shakeReporterScreenshotLabel,
                      style: tt.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Switch.adaptive(
                      value: state.includeScreenshot,
                      onChanged: (value) => context
                          .read<ShakeReporterCubit>()
                          .toggleScreenshot(value),
                    ),
                  ],
                ),
              ),

              // Preview image
              if (state.includeScreenshot) ...[
                Divider(height: 1, color: cs.outlineVariant),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: screenshotBytes != null
                        ? Image.memory(
                            screenshotBytes,
                            height: 110,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, error, stackTrace) =>
                                _ScreenshotPlaceholder(cs: cs),
                          )
                        : _ScreenshotPlaceholder(cs: cs),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ScreenshotPlaceholder extends StatelessWidget {
  const _ScreenshotPlaceholder({required this.cs});
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110,
      width: double.infinity,
      color: cs.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            color: cs.onSurfaceVariant,
            size: 28,
          ),
          const SizedBox(height: 6),
          Text(
            context.locale.shakeReporterNoScreenshot,
            style: Theme.of(
              context,
            ).textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
