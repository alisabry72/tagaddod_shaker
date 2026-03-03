import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_build_context_extensions.dart';
import '../cubit/shake_reporter_cubit.dart';
import '../cubit/shake_reporter_state.dart';

class ReportFormBody extends StatelessWidget {
  const ReportFormBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShakeReporterCubit, ShakeReporterState>(
      builder: (context, state) {
        if (state is! ShakeReporterReady) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title field
            TextFormField(
              initialValue: state.title,
              decoration: InputDecoration(
                labelText: context.locale.shakeReporterTitleLabel,
                hintText: context.locale.shakeReporterTitleHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  context.read<ShakeReporterCubit>().updateTitle(v),
            ),

            const SizedBox(height: 14),

            // Description field
            TextFormField(
              initialValue: state.description,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: context.locale.shakeReporterDescriptionLabel,
                hintText: context.locale.shakeReporterDescriptionHint,
                border: const OutlineInputBorder(),
              ),
              onChanged: (v) =>
                  context.read<ShakeReporterCubit>().updateDescription(v),
            ),
          ],
        );
      },
    );
  }
}
