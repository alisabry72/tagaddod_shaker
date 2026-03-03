// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_context_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceContextModel _$DeviceContextModelFromJson(Map<String, dynamic> json) =>
    DeviceContextModel(
      appVersion: json['appVersion'] as String,
      buildNumber: json['buildNumber'] as String,
      deviceModel: json['deviceModel'] as String,
      osName: json['osName'] as String,
      osVersion: json['osVersion'] as String,
      userId: json['userId'] as String,
      sessionId: json['sessionId'] as String,
      currentRoute: json['currentRoute'] as String,
      networkStatus: json['networkStatus'] as String,
      environment: json['environment'] as String,
      recentLogs: (json['recentLogs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$DeviceContextModelToJson(DeviceContextModel instance) =>
    <String, dynamic>{
      'appVersion': instance.appVersion,
      'buildNumber': instance.buildNumber,
      'deviceModel': instance.deviceModel,
      'osName': instance.osName,
      'osVersion': instance.osVersion,
      'userId': instance.userId,
      'sessionId': instance.sessionId,
      'currentRoute': instance.currentRoute,
      'networkStatus': instance.networkStatus,
      'environment': instance.environment,
      'recentLogs': instance.recentLogs,
      'timestamp': instance.timestamp.toIso8601String(),
    };
