import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_localization_scope.dart';
import 'package:tagaddod_shaker/src/presentation/shake_reporter_strings.dart';

import '../../service/screenshot_capture_service.dart';
import '../../service/shake_detector_service.dart';
import '../../service/shake_diagnostics_service.dart';
import '../cubit/shake_reporter_cubit.dart';
import 'shake_reporter_bottom_sheet.dart';

typedef ShakeReporterStringsBuilder =
    ShakeReporterStrings Function(BuildContext context);

Future<void> showShakeReporterSheet({
  required BuildContext context,
  GetIt? serviceLocator,
  ShakeReporterStringsBuilder? stringsBuilder,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  Color barrierColor = Colors.black54,
  Color backgroundColor = Colors.transparent,
}) async {
  final sl = serviceLocator ?? GetIt.instance;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    useRootNavigator: useRootNavigator,
    builder: (ctx) => BlocProvider(
      create: (_) => sl<ShakeReporterCubit>()..initialize(),
      child: ShakeReporterLocalizationScope(
        strings: stringsBuilder?.call(ctx) ?? const ShakeReporterStrings(),
        child: const ShakeReporterBottomSheet(),
      ),
    ),
  );
}

/// Plug-and-play listener that opens [ShakeReporterBottomSheet] on shake.
class ShakeReporterListener extends StatefulWidget {
  const ShakeReporterListener({
    super.key,
    required this.child,
    this.serviceLocator,
    this.routeNameResolver,
    this.environmentResolver,
    this.stringsBuilder,
    this.isScrollControlled = true,
    this.useRootNavigator = true,
    this.barrierColor = Colors.black54,
    this.backgroundColor = Colors.transparent,
    this.enableHaptics = true,
  });

  final Widget child;
  final GetIt? serviceLocator;
  final String Function()? routeNameResolver;
  final String Function()? environmentResolver;
  final ShakeReporterStringsBuilder? stringsBuilder;
  final bool isScrollControlled;
  final bool useRootNavigator;
  final Color barrierColor;
  final Color backgroundColor;
  final bool enableHaptics;

  @override
  State<ShakeReporterListener> createState() => _ShakeReporterListenerState();
}

class _ShakeReporterListenerState extends State<ShakeReporterListener> {
  late final GetIt _sl;
  late final StreamSubscription<void> _shakeSubscription;
  bool _isPresentingReporter = false;

  @override
  void initState() {
    super.initState();
    _sl = widget.serviceLocator ?? GetIt.instance;
    _shakeSubscription = _sl<ShakeDetectorService>().onShakeTrigger.listen((
      _,
    ) async {
      if (_isPresentingReporter) return;
      await _showShakeReporter();
    });
  }

  @override
  void dispose() {
    _shakeSubscription.cancel();
    super.dispose();
  }

  Future<void> _showShakeReporter() async {
    if (_isPresentingReporter || !mounted) return;

    final shakeDetector = _sl<ShakeDetectorService>();
    final routeName = widget.routeNameResolver?.call() ?? 'unknown';
    final appEnvironment =
        widget.environmentResolver?.call() ??
        const String.fromEnvironment('APP_ENV', defaultValue: 'unknown');

    if (!shakeDetector.canOpenReporterFor(
      routeName: routeName,
      environment: appEnvironment,
    )) {
      return;
    }

    _sl<ShakeDiagnosticsService>().setCurrentRoute(routeName);

    _isPresentingReporter = true;
    shakeDetector.setSheetOpen(true);
    try {
      await _sl<ScreenshotCaptureService>().captureFromBoundary();
      if (!mounted) return;

      if (widget.enableHaptics) {
        await HapticFeedback.mediumImpact();
      }
      if (!mounted) return;

      await showShakeReporterSheet(
        context: context,
        serviceLocator: _sl,
        stringsBuilder: widget.stringsBuilder,
        isScrollControlled: widget.isScrollControlled,
        backgroundColor: widget.backgroundColor,
        barrierColor: widget.barrierColor,
        useRootNavigator: widget.useRootNavigator,
      );
    } finally {
      shakeDetector.setSheetOpen(false);
      _isPresentingReporter = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: ScreenshotCaptureService.boundaryKey,
      child: widget.child,
    );
  }
}
