import 'package:equatable/equatable.dart';

import '../../domain/entities/device_context.dart';
import '../../domain/entities/linear_team.dart';

abstract class ShakeReporterState extends Equatable {
  const ShakeReporterState();

  @override
  List<Object?> get props => [];
}

class ShakeReporterInitial extends ShakeReporterState {}

class ShakeReporterLoading extends ShakeReporterState {
  final String message;

  const ShakeReporterLoading(this.message);

  @override
  List<Object?> get props => [message];
}

class ShakeReporterReady extends ShakeReporterState {
  static const Object _noChange = Object();

  final DeviceContext deviceContext;
  final String? screenshotBase64;
  final bool includeScreenshot;
  final String title;
  final String description;
  final List<LinearTeam> linearTeams;
  final bool isSubmitEnabled;

  const ShakeReporterReady({
    required this.deviceContext,
    this.screenshotBase64,
    required this.includeScreenshot,
    required this.title,
    required this.description,
    required this.linearTeams,
    required this.isSubmitEnabled,
  });

  ShakeReporterReady copyWith({
    DeviceContext? deviceContext,
    Object? screenshotBase64 = _noChange,
    bool? includeScreenshot,
    String? title,
    String? description,
    List<LinearTeam>? linearTeams,
    bool? isSubmitEnabled,
  }) {
    return ShakeReporterReady(
      deviceContext: deviceContext ?? this.deviceContext,
      screenshotBase64: screenshotBase64 == _noChange
          ? this.screenshotBase64
          : screenshotBase64 as String?,
      includeScreenshot: includeScreenshot ?? this.includeScreenshot,
      title: title ?? this.title,
      description: description ?? this.description,
      linearTeams: linearTeams ?? this.linearTeams,
      isSubmitEnabled: isSubmitEnabled ?? this.isSubmitEnabled,
    );
  }

  @override
  List<Object?> get props => [
    deviceContext,
    screenshotBase64,
    includeScreenshot,
    title,
    description,
    linearTeams,
    isSubmitEnabled,
  ];
}

class ShakeReporterSubmitting extends ShakeReporterState {
  const ShakeReporterSubmitting();
}

class ShakeReporterSuccess extends ShakeReporterState {
  const ShakeReporterSuccess();
}

class ShakeReporterFailure extends ShakeReporterState {
  final String message;

  const ShakeReporterFailure(this.message);

  @override
  List<Object?> get props => [message];
}
