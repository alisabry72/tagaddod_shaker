import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'di/shake_reporter_injection.dart';
import 'domain/usecases/flush_pending_reports_usecase.dart';
import 'service/shake_detector_service.dart';

/// Recommended one-shot setup for shake reporter in host apps.
Future<void> bootstrapShakeReporter({
  GetIt? serviceLocator,
  SharedPreferences? sharedPreferences,
  bool flushPendingReports = true,
  bool initializeDetector = true,
}) async {
  final sl = serviceLocator ?? GetIt.instance;

  if (!sl.isRegistered<SharedPreferences>()) {
    final prefs = sharedPreferences ?? await SharedPreferences.getInstance();
    sl.registerSingleton<SharedPreferences>(prefs);
  }

  if (!sl.isRegistered<ShakeDetectorService>()) {
    registerShakeReporterDependencies(sl);
  }

  if (flushPendingReports) {
    await sl<FlushPendingReportsUseCase>().call();
  }
  if (initializeDetector) {
    await sl<ShakeDetectorService>().initialize();
  }
}
