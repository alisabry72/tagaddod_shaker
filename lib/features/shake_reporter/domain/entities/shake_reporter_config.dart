class ShakeReporterConfig {
  final bool enabled;
  final double sensitivityThreshold; // accelerometer G-force threshold
  final int cooldownSeconds; // min seconds between triggers
  final bool screenshotEnabled;
  final List<String> blockedRoutes; // routes where shake is ignored
  final List<String> allowedEnvironments;
  final int maxLogLines;

  const ShakeReporterConfig({
    required this.enabled,
    required this.sensitivityThreshold,
    required this.cooldownSeconds,
    required this.screenshotEnabled,
    required this.blockedRoutes,
    required this.allowedEnvironments,
    required this.maxLogLines,
  });

  // Safe fallback when remote config is unavailable
  static const ShakeReporterConfig safeFallback = ShakeReporterConfig(
    enabled: false, // always OFF if config fetch fails
    sensitivityThreshold: 2.7,
    cooldownSeconds: 30,
    screenshotEnabled: true,
    blockedRoutes: [],
    allowedEnvironments: ['staging'],
    maxLogLines: 50,
  );

  ShakeReporterConfig copyWith({
    bool? enabled,
    double? sensitivityThreshold,
    int? cooldownSeconds,
    bool? screenshotEnabled,
    List<String>? blockedRoutes,
    List<String>? allowedEnvironments,
    int? maxLogLines,
  }) {
    return ShakeReporterConfig(
      enabled: enabled ?? this.enabled,
      sensitivityThreshold: sensitivityThreshold ?? this.sensitivityThreshold,
      cooldownSeconds: cooldownSeconds ?? this.cooldownSeconds,
      screenshotEnabled: screenshotEnabled ?? this.screenshotEnabled,
      blockedRoutes: blockedRoutes ?? this.blockedRoutes,
      allowedEnvironments: allowedEnvironments ?? this.allowedEnvironments,
      maxLogLines: maxLogLines ?? this.maxLogLines,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ShakeReporterConfig &&
        other.enabled == enabled &&
        other.sensitivityThreshold == sensitivityThreshold &&
        other.cooldownSeconds == cooldownSeconds &&
        other.screenshotEnabled == screenshotEnabled &&
        other.blockedRoutes == blockedRoutes &&
        other.allowedEnvironments == allowedEnvironments &&
        other.maxLogLines == maxLogLines;
  }

  @override
  int get hashCode {
    return enabled.hashCode ^
        sensitivityThreshold.hashCode ^
        cooldownSeconds.hashCode ^
        screenshotEnabled.hashCode ^
        blockedRoutes.hashCode ^
        allowedEnvironments.hashCode ^
        maxLogLines.hashCode;
  }
}
