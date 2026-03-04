import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_build_context_extensions.dart';
import '../cubit/shake_reporter_cubit.dart';
import '../cubit/shake_reporter_state.dart';

class ScreenshotPreviewTile extends StatelessWidget {
  const ScreenshotPreviewTile({super.key});
  static final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickAndAttachPhoto(BuildContext context) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 75,
        maxWidth: 1440,
      );
      if (pickedFile == null) return;

      final bytes = await pickedFile.readAsBytes();
      if (bytes.isEmpty) return;

      if (!context.mounted) return;
      context.read<ShakeReporterCubit>().attachScreenshot(base64Encode(bytes));
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        SnackBar(content: Text(context.locale.shakeReporterPhotoAttachFailed)),
      );
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

        final hasAttachment =
            state.includeScreenshot &&
            (state.screenshotBase64?.trim().isNotEmpty ?? false);
        final screenshotBytes = hasAttachment
            ? _decodeScreenshot(state.screenshotBase64)
            : null;

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
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
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
                  ],
                ),
              ),

              Divider(height: 1, color: cs.outlineVariant),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: hasAttachment
                          ? (screenshotBytes != null
                                ? Image.memory(
                                    screenshotBytes,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, stackTrace) =>
                                        _ScreenshotPlaceholder(cs: cs),
                                  )
                                : _ScreenshotPlaceholder(cs: cs))
                          : _ScreenshotPlaceholder(cs: cs),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (hasAttachment) ...[
                          OutlinedButton.icon(
                            onPressed: () => _pickAndAttachPhoto(context),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: Text(
                              context.locale.shakeReporterChangePhotoButton,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () => context
                                .read<ShakeReporterCubit>()
                                .removeScreenshot(),
                            icon: const Icon(Icons.delete_outline),
                            label: Text(
                              context.locale.shakeReporterRemovePhotoButton,
                            ),
                          ),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: () => _pickAndAttachPhoto(context),
                            icon: const Icon(Icons.add_a_photo_outlined),
                            label: Text(
                              context.locale.shakeReporterAddPhotoButton,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
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
