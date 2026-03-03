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
  GlobalKey<NavigatorState>? navigatorKey,
  bool captureScreenshotOnOpen = false,
  bool isScrollControlled = true,
  bool useRootNavigator = true,
  Color barrierColor = Colors.black54,
  Color backgroundColor = Colors.transparent,
}) async {
  final navigatorContext = _resolveNavigatorContext(
    context: context,
    navigatorKey: navigatorKey,
    useRootNavigator: useRootNavigator,
  );
  if (navigatorContext == null) {
    debugPrint(
      'ShakeReporter: unable to open sheet because no Navigator was found for the provided context.',
    );
    return;
  }

  final sl = serviceLocator ?? GetIt.instance;
  final localizedStrings =
      stringsBuilder?.call(navigatorContext) ??
      _defaultStringsForContext(navigatorContext);

  await showModalBottomSheet<void>(
    context: navigatorContext,
    isScrollControlled: isScrollControlled,
    backgroundColor: backgroundColor,
    barrierColor: barrierColor,
    useRootNavigator: false,
    builder: (ctx) => BlocProvider(
      create: (_) => sl<ShakeReporterCubit>()
        ..initialize(captureScreenshotOnOpen: captureScreenshotOnOpen),
      child: ShakeReporterLocalizationScope(
        strings: localizedStrings,
        child: const ShakeReporterBottomSheet(),
      ),
    ),
  );
}

BuildContext? _resolveNavigatorContext({
  required BuildContext context,
  required bool useRootNavigator,
  GlobalKey<NavigatorState>? navigatorKey,
}) {
  final keyContext = navigatorKey?.currentContext;
  if (keyContext != null) return keyContext;

  final targetNavigator = Navigator.maybeOf(
    context,
    rootNavigator: useRootNavigator,
  );
  if (targetNavigator != null) return targetNavigator.context;

  return Navigator.maybeOf(context)?.context;
}

ShakeReporterStrings _defaultStringsForContext(BuildContext context) {
  final languageCode =
      Localizations.maybeLocaleOf(context)?.languageCode.toLowerCase();
  if (languageCode == 'ar') {
    return const ShakeReporterStrings.arabic();
  }
  return const ShakeReporterStrings();
}

/// Plug-and-play listener that opens [ShakeReporterBottomSheet] on shake.
class ShakeReporterListener extends StatefulWidget {
  const ShakeReporterListener({
    super.key,
    required this.child,
    this.serviceLocator,
    this.navigatorKey,
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
  final GlobalKey<NavigatorState>? navigatorKey;
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
        navigatorKey: widget.navigatorKey,
        stringsBuilder: widget.stringsBuilder,
        captureScreenshotOnOpen: true,
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
