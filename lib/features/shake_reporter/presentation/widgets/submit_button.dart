import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_build_context_extensions.dart';
import '../cubit/shake_reporter_cubit.dart';
import '../cubit/shake_reporter_state.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShakeReporterCubit, ShakeReporterState>(
      buildWhen: (previous, current) {
        final previousEnabled =
            previous is ShakeReporterReady && previous.isSubmitEnabled;
        final currentEnabled =
            current is ShakeReporterReady && current.isSubmitEnabled;
        final previousLoading = previous is ShakeReporterSubmitting;
        final currentLoading = current is ShakeReporterSubmitting;
        return previousEnabled != currentEnabled ||
            previousLoading != currentLoading;
      },
      builder: (context, state) {
        final isEnabled = state is ShakeReporterReady && state.isSubmitEnabled;
        final isLoading = state is ShakeReporterSubmitting;
        final scheme = Theme.of(context).colorScheme;
        final enabledFg = scheme.onPrimary;
        final disabledFg = scheme.onSurface.withValues(alpha: 0.5);

        return SizedBox(
          width: context.width,
          child: ElevatedButton(
            onPressed: isEnabled && !isLoading
                ? () => context.read<ShakeReporterCubit>().submitReport()
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: scheme.primary,
              foregroundColor: enabledFg,
              disabledBackgroundColor: scheme.surfaceContainerHighest,
              disabledForegroundColor: disabledFg,
              padding: const EdgeInsets.symmetric(vertical: 14),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            child: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: enabledFg,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          context.locale.shakeReporterSubmitButton,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
