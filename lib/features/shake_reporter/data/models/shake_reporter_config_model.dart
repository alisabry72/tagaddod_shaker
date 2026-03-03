import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/shake_reporter_config.dart';

part 'shake_reporter_config_model.g.dart';

@JsonSerializable()
class ShakeReporterConfigModel {
  final bool enabled;
  final double sensitivityThreshold;
  final int cooldownSeconds;
  final bool screenshotEnabled;
  final List<String> blockedRoutes;
  final List<String> allowedEnvironments;
  final int maxLogLines;

  const ShakeReporterConfigModel({
    required this.enabled,
    required this.sensitivityThreshold,
    required this.cooldownSeconds,
    required this.screenshotEnabled,
    required this.blockedRoutes,
    required this.allowedEnvironments,
    required this.maxLogLines,
  });

  factory ShakeReporterConfigModel.fromJson(Map<String, dynamic> json) =>
      _$ShakeReporterConfigModelFromJson(json);

  Map<String, dynamic> toJson() => _$ShakeReporterConfigModelToJson(this);

  factory ShakeReporterConfigModel.fromEntity(ShakeReporterConfig entity) {
    return ShakeReporterConfigModel(
      enabled: entity.enabled,
      sensitivityThreshold: entity.sensitivityThreshold,
      cooldownSeconds: entity.cooldownSeconds,
      screenshotEnabled: entity.screenshotEnabled,
      blockedRoutes: entity.blockedRoutes,
      allowedEnvironments: entity.allowedEnvironments,
      maxLogLines: entity.maxLogLines,
    );
  }

  ShakeReporterConfig toEntity() {
    return ShakeReporterConfig(
      enabled: enabled,
      sensitivityThreshold: sensitivityThreshold,
      cooldownSeconds: cooldownSeconds,
      screenshotEnabled: screenshotEnabled,
      blockedRoutes: blockedRoutes,
      allowedEnvironments: allowedEnvironments,
      maxLogLines: maxLogLines,
    );
  }
}
