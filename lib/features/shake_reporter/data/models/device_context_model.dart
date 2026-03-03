import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/device_context.dart';

part 'device_context_model.g.dart';

@JsonSerializable()
class DeviceContextModel {
  final String appVersion;
  final String buildNumber;
  final String deviceModel;
  final String osName;
  final String osVersion;
  final String userId;
  final String sessionId;
  final String currentRoute;
  final String networkStatus;
  final String environment;
  final List<String> recentLogs;
  final DateTime timestamp;

  const DeviceContextModel({
    required this.appVersion,
    required this.buildNumber,
    required this.deviceModel,
    required this.osName,
    required this.osVersion,
    required this.userId,
    required this.sessionId,
    required this.currentRoute,
    required this.networkStatus,
    required this.environment,
    required this.recentLogs,
    required this.timestamp,
  });

  factory DeviceContextModel.fromJson(Map<String, dynamic> json) =>
      _$DeviceContextModelFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceContextModelToJson(this);

  factory DeviceContextModel.fromEntity(DeviceContext entity) {
    return DeviceContextModel(
      appVersion: entity.appVersion,
      buildNumber: entity.buildNumber,
      deviceModel: entity.deviceModel,
      osName: entity.osName,
      osVersion: entity.osVersion,
      userId: entity.userId,
      sessionId: entity.sessionId,
      currentRoute: entity.currentRoute,
      networkStatus: entity.networkStatus,
      environment: entity.environment,
      recentLogs: entity.recentLogs,
      timestamp: entity.timestamp,
    );
  }

  DeviceContext toEntity() {
    return DeviceContext(
      appVersion: appVersion,
      buildNumber: buildNumber,
      deviceModel: deviceModel,
      osName: osName,
      osVersion: osVersion,
      userId: userId,
      sessionId: sessionId,
      currentRoute: currentRoute,
      networkStatus: networkStatus,
      environment: environment,
      recentLogs: recentLogs,
      timestamp: timestamp,
    );
  }
}
