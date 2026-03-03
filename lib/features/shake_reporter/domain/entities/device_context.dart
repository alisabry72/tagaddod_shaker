class DeviceContext {
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

  const DeviceContext({
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

  DeviceContext copyWith({
    String? appVersion,
    String? buildNumber,
    String? deviceModel,
    String? osName,
    String? osVersion,
    String? userId,
    String? sessionId,
    String? currentRoute,
    String? networkStatus,
    String? environment,
    List<String>? recentLogs,
    DateTime? timestamp,
  }) {
    return DeviceContext(
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      deviceModel: deviceModel ?? this.deviceModel,
      osName: osName ?? this.osName,
      osVersion: osVersion ?? this.osVersion,
      userId: userId ?? this.userId,
      sessionId: sessionId ?? this.sessionId,
      currentRoute: currentRoute ?? this.currentRoute,
      networkStatus: networkStatus ?? this.networkStatus,
      environment: environment ?? this.environment,
      recentLogs: recentLogs ?? this.recentLogs,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DeviceContext &&
        other.appVersion == appVersion &&
        other.buildNumber == buildNumber &&
        other.deviceModel == deviceModel &&
        other.osName == osName &&
        other.osVersion == osVersion &&
        other.userId == userId &&
        other.sessionId == sessionId &&
        other.currentRoute == currentRoute &&
        other.networkStatus == networkStatus &&
        other.environment == environment &&
        other.recentLogs == recentLogs &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return appVersion.hashCode ^
        buildNumber.hashCode ^
        deviceModel.hashCode ^
        osName.hashCode ^
        osVersion.hashCode ^
        userId.hashCode ^
        sessionId.hashCode ^
        currentRoute.hashCode ^
        networkStatus.hashCode ^
        environment.hashCode ^
        recentLogs.hashCode ^
        timestamp.hashCode;
  }
}
