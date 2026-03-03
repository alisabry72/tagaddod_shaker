import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/device_context.dart';
import '../../domain/entities/issue_report.dart';
import '../../domain/entities/shake_reporter_config.dart';
import '../../domain/entities/linear_team.dart';
import '../../domain/usecases/capture_device_context_usecase.dart';
import '../../domain/usecases/capture_screenshot_usecase.dart';
import '../../domain/usecases/get_linear_teams_usecase.dart';
import '../../domain/usecases/get_reporter_config_usecase.dart';
import '../../domain/usecases/submit_issue_report_usecase.dart';
import 'shake_reporter_state.dart';

class ShakeReporterCubit extends Cubit<ShakeReporterState> {
  final SubmitIssueReportUseCase _submitUseCase;
  final CaptureDeviceContextUseCase _deviceContextUseCase;
  final CaptureScreenshotUseCase _screenshotUseCase;
  final GetReporterConfigUseCase _configUseCase;
  final GetLinearTeamsUseCase _getLinearTeamsUseCase;

  ShakeReporterCubit(
    this._submitUseCase,
    this._deviceContextUseCase,
    this._screenshotUseCase,
    this._configUseCase,
    this._getLinearTeamsUseCase,
  ) : super(ShakeReporterInitial());

  Future<void> initialize() async {
    emit(const ShakeReporterLoading('Preparing report...'));

    final configResult = await _configUseCase.call();
    final config = configResult.fold(
      (_) => ShakeReporterConfig.safeFallback,
      id,
    );

    final contextResult = await _deviceContextUseCase.call();
    final deviceContext = contextResult.fold((_) => _emptyDeviceContext(), id);

    String? screenshot;
    if (config.screenshotEnabled) {
      final screenshotResult = await _screenshotUseCase.call();
      screenshot = screenshotResult.fold((_) => null, id);
    }
    final teamsResult = await _getLinearTeamsUseCase.call();
    final linearTeams = teamsResult.fold((_) => <LinearTeam>[], id);

    emit(
      ShakeReporterReady(
        deviceContext: deviceContext,
        screenshotBase64: screenshot,
        includeScreenshot: config.screenshotEnabled && screenshot != null,
        title: '',
        description: '',
        linearTeams: linearTeams,
        isSubmitEnabled: false,
      ),
    );
  }

  void updateTitle(String value) =>
      _updateReady((s) => s.copyWith(title: value));

  void updateDescription(String value) =>
      _updateReady((s) => s.copyWith(description: value));

  void toggleScreenshot(bool include) =>
      _updateReady((s) => s.copyWith(includeScreenshot: include));

  Future<void> submitReport() async {
    final currentState = state;
    if (currentState is! ShakeReporterReady) return;
    if (!currentState.isSubmitEnabled) return;

    emit(const ShakeReporterSubmitting());

    final report = IssueReport(
      title: currentState.title,
      description: currentState.description,
      deviceContext: currentState.deviceContext,
      screenshotBase64: currentState.includeScreenshot
          ? currentState.screenshotBase64
          : null,
      includeScreenshot: currentState.includeScreenshot,
      createdAt: DateTime.now().toUtc(),
    );

    final result = await _submitUseCase.call(report);
    result.fold(
      (failure) => emit(ShakeReporterFailure(failure.message)),
      (_) => emit(const ShakeReporterSuccess()),
    );
  }

  void _updateReady(ShakeReporterReady Function(ShakeReporterReady) update) {
    if (state is ShakeReporterReady) {
      final updated = update(state as ShakeReporterReady);
      final newState = updated.copyWith(
        isSubmitEnabled: updated.title.trim().length >= 5,
      );
      emit(newState);
    }
  }

  DeviceContext _emptyDeviceContext() {
    return DeviceContext(
      appVersion: 'unknown',
      buildNumber: 'unknown',
      deviceModel: 'unknown',
      osName: 'unknown',
      osVersion: 'unknown',
      userId: 'unknown',
      sessionId: 'unknown',
      currentRoute: 'unknown',
      networkStatus: 'unknown',
      environment: 'unknown',
      recentLogs: [],
      timestamp: DateTime.now().toUtc(),
    );
  }
}
