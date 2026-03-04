import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:tagaddod_shaker/src/config/shake_reporter_endpoints.dart';

class ShakeReporterLinearConfig {
  const ShakeReporterLinearConfig({
    this.apiLink = ShakeReporterEndpoints.linearApiLink,
    this.token = ShakeReporterEndpoints.linearToken,
    this.teamId = ShakeReporterEndpoints.linearTeamId,
    this.projectId = ShakeReporterEndpoints.linearProjectId,
    this.appApiLink = ShakeReporterEndpoints.apiLink,
  });

  final String apiLink;
  final String token;
  final String teamId;
  final String? projectId;
  final String appApiLink;
}

class ShakeReporterRemoteConfigKeys {
  const ShakeReporterRemoteConfigKeys({
    this.enabled = 'shake_reporter_enabled',
    this.sensitivityThreshold = 'shake_reporter_sensitivity_threshold',
    this.cooldownSeconds = 'shake_reporter_cooldown_seconds',
    this.screenshotEnabled = 'shake_reporter_screenshot_enabled',
    this.blockedRoutes = 'shake_reporter_blocked_routes',
    this.allowedEnvironments = 'shake_reporter_allowed_environments',
    this.maxLogLines = 'shake_reporter_max_log_lines',
  });

  final String enabled;
  final String sensitivityThreshold;
  final String cooldownSeconds;
  final String screenshotEnabled;
  final String blockedRoutes;
  final String allowedEnvironments;
  final String maxLogLines;

  Map<String, dynamic> defaults() {
    return <String, dynamic>{
      enabled: false,
      sensitivityThreshold: 2.7,
      cooldownSeconds: 30,
      screenshotEnabled: true,
      blockedRoutes: '[]',
      allowedEnvironments: '["staging"]',
      maxLogLines: 500,
    };
  }
}

class ShakeReporterOptions {
  const ShakeReporterOptions({
    this.remoteConfig,
    this.linear = const ShakeReporterLinearConfig(),
    this.remoteConfigKeys = const ShakeReporterRemoteConfigKeys(),
    this.fetchTimeout = const Duration(seconds: 10),
    this.minimumFetchInterval,
  });

  final FirebaseRemoteConfig? remoteConfig;
  final ShakeReporterLinearConfig linear;
  final ShakeReporterRemoteConfigKeys remoteConfigKeys;
  final Duration fetchTimeout;
  final Duration? minimumFetchInterval;
}
