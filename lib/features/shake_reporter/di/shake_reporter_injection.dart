import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/local/pending_reports_local_datasource.dart';
import '../data/datasources/local/reporter_config_local_datasource.dart';
import '../data/datasources/local/screenshot_datasource.dart';
import '../data/datasources/remote/config_remote_datasource.dart';
import '../data/datasources/remote/issue_api_datasource.dart';
import '../data/repositories/config_repository_impl.dart';
import '../data/repositories/issue_reporter_repository_impl.dart';
import '../data/repositories/screenshot_repository_impl.dart';
import '../domain/repositories/config_repository.dart';
import '../domain/repositories/issue_reporter_repository.dart';
import '../domain/repositories/screenshot_repository.dart';
import '../domain/usecases/capture_device_context_usecase.dart';
import '../domain/usecases/capture_screenshot_usecase.dart';
import '../domain/usecases/flush_pending_reports_usecase.dart';
import '../domain/usecases/get_reporter_config_usecase.dart';
import '../domain/usecases/get_linear_teams_usecase.dart';
import '../domain/usecases/submit_issue_report_usecase.dart';
import '../presentation/cubit/shake_reporter_cubit.dart';
import '../service/device_context_service.dart';
import '../service/shake_detector_service.dart';
import '../service/screenshot_capture_service.dart';
import '../service/shake_diagnostics_service.dart';
import '../shake_reporter_options.dart';

void registerShakeReporterDependencies(
  GetIt sl, {
  ShakeReporterOptions options = const ShakeReporterOptions(),
}) {
  if (!sl.isRegistered<SharedPreferences>()) {
    throw StateError(
      'SharedPreferences must be registered in GetIt before calling registerShakeReporterDependencies().',
    );
  }

  // Services
  sl.registerLazySingleton<ShakeDetectorService>(
    () => ShakeDetectorService(sl<GetReporterConfigUseCase>()),
  );
  sl.registerLazySingleton<DeviceContextService>(
    () => DeviceContextService(
      sharedPreferences: sl<SharedPreferences>(),
      diagnosticsService: sl<ShakeDiagnosticsService>(),
    ),
  );
  sl.registerLazySingleton<ShakeDiagnosticsService>(
    () => ShakeDiagnosticsService(),
  );
  sl.registerLazySingleton<ScreenshotCaptureService>(
    () => ScreenshotCaptureService(),
  );
  sl.registerLazySingleton<http.Client>(() => http.Client());
  // Data Sources
  sl.registerLazySingleton<IssueApiDatasource>(
    () => IssueApiDatasourceImpl(
      sl<http.Client>(),
      options.linear.apiLink,
      token: options.linear.token,
      teamId: options.linear.teamId,
      projectId: options.linear.projectId,
      appApiLink: options.linear.appApiLink,
      diagnosticsService: sl<ShakeDiagnosticsService>(),
    ),
  );
  sl.registerLazySingleton<PendingReportsLocalDatasource>(
    () => PendingReportsLocalDatasourceImpl(),
  );
  sl.registerLazySingleton<ReporterConfigLocalDatasource>(
    () => ReporterConfigLocalDatasourceImpl(sl<SharedPreferences>()),
  );
  sl.registerLazySingleton<ScreenshotDatasource>(
    () => ScreenshotDatasourceImpl(sl<ScreenshotCaptureService>()),
  );
  sl.registerLazySingleton<ConfigRemoteDatasource>(
    () => ConfigRemoteDatasourceImpl(
      options.remoteConfig ?? FirebaseRemoteConfig.instance,
      keys: options.remoteConfigKeys,
      fetchTimeout: options.fetchTimeout,
      minimumFetchInterval: options.minimumFetchInterval,
    ),
  );

  // Repositories
  sl.registerLazySingleton<IssueReporterRepository>(
    () => IssueReporterRepositoryImpl(
      sl<IssueApiDatasource>(),
      sl<PendingReportsLocalDatasource>(),
    ),
  );
  sl.registerLazySingleton<ConfigRepository>(
    () => ConfigRepositoryImpl(
      sl<ReporterConfigLocalDatasource>(),
      sl<ConfigRemoteDatasource>(),
    ),
  );
  sl.registerLazySingleton<ScreenshotRepository>(
    () => ScreenshotRepositoryImpl(sl<ScreenshotDatasource>()),
  );

  // Use Cases
  sl.registerLazySingleton<SubmitIssueReportUseCase>(
    () => SubmitIssueReportUseCase(sl<IssueReporterRepository>()),
  );
  sl.registerLazySingleton<GetReporterConfigUseCase>(
    () => GetReporterConfigUseCase(sl<ConfigRepository>()),
  );
  sl.registerLazySingleton<CaptureDeviceContextUseCase>(
    () => CaptureDeviceContextUseCase(sl<DeviceContextService>()),
  );
  sl.registerLazySingleton<FlushPendingReportsUseCase>(
    () => FlushPendingReportsUseCase(sl<IssueReporterRepository>()),
  );
  sl.registerLazySingleton<GetLinearTeamsUseCase>(
    () => GetLinearTeamsUseCase(sl<IssueReporterRepository>()),
  );
  sl.registerLazySingleton<CaptureScreenshotUseCase>(
    () => CaptureScreenshotUseCase(sl<ScreenshotRepository>()),
  );
  sl.registerFactory<ShakeReporterCubit>(
    () => ShakeReporterCubit(
      sl<SubmitIssueReportUseCase>(),
      sl<CaptureDeviceContextUseCase>(),
      sl<CaptureScreenshotUseCase>(),
      sl<GetReporterConfigUseCase>(),
      sl<GetLinearTeamsUseCase>(),
    ),
  );
}
