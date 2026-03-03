// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shake_reporter_config_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ShakeReporterConfigModel _$ShakeReporterConfigModelFromJson(
  Map<String, dynamic> json,
) => ShakeReporterConfigModel(
  enabled: json['enabled'] as bool,
  sensitivityThreshold: (json['sensitivityThreshold'] as num).toDouble(),
  cooldownSeconds: (json['cooldownSeconds'] as num).toInt(),
  screenshotEnabled: json['screenshotEnabled'] as bool,
  blockedRoutes: (json['blockedRoutes'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  allowedEnvironments: (json['allowedEnvironments'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  maxLogLines: (json['maxLogLines'] as num).toInt(),
);

Map<String, dynamic> _$ShakeReporterConfigModelToJson(
  ShakeReporterConfigModel instance,
) => <String, dynamic>{
  'enabled': instance.enabled,
  'sensitivityThreshold': instance.sensitivityThreshold,
  'cooldownSeconds': instance.cooldownSeconds,
  'screenshotEnabled': instance.screenshotEnabled,
  'blockedRoutes': instance.blockedRoutes,
  'allowedEnvironments': instance.allowedEnvironments,
  'maxLogLines': instance.maxLogLines,
};
