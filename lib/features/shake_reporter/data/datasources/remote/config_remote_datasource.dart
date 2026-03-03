import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import 'package:tagaddod_shaker/features/shake_reporter/domain/entities/shake_reporter_config.dart';

abstract class ConfigRemoteDatasource {
  Future<Either<Failure, ShakeReporterConfig>> getConfig();
}

class ConfigRemoteDatasourceImpl implements ConfigRemoteDatasource {
  final FirebaseRemoteConfig _remoteConfig;
  bool _isConfigured = false;

  ConfigRemoteDatasourceImpl(this._remoteConfig);

  Future<void> _configureIfNeeded() async {
    if (_isConfigured) return;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: kDebugMode
            ? Duration.zero
            : const Duration(minutes: 30),
      ),
    );

    // Prevent silent zero/empty values when a key is missing in Firebase.
    await _remoteConfig.setDefaults(const <String, dynamic>{
      'shake_reporter_enabled': false,
      'shake_reporter_sensitivity_threshold': 2.7,
      'shake_reporter_cooldown_seconds': 30,
      'shake_reporter_screenshot_enabled': true,
      'shake_reporter_blocked_routes': '[]',
      'shake_reporter_allowed_environments': '["staging"]',
      'shake_reporter_max_log_lines': 500,
    });

    _isConfigured = true;
  }

  List<String> _parseStringList(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return <String>[];

    // Prefer JSON array string: ["a","b"].
    if (trimmed.startsWith('[') && trimmed.endsWith(']')) {
      final dynamic decoded = jsonDecode(trimmed);
      if (decoded is List) {
        return decoded
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    // Fallback: comma separated values: a,b,c.
    return trimmed
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  Future<Either<Failure, ShakeReporterConfig>> getConfig() async {
    try {
      await _configureIfNeeded();
      await _remoteConfig.fetchAndActivate();

      final enabled = _remoteConfig.getBool('shake_reporter_enabled');
      final sensitivityThreshold = _remoteConfig.getDouble(
        'shake_reporter_sensitivity_threshold',
      );
      final cooldownSeconds = _remoteConfig.getInt(
        'shake_reporter_cooldown_seconds',
      );
      final screenshotEnabled = _remoteConfig.getBool(
        'shake_reporter_screenshot_enabled',
      );
      final blockedRoutesString = _remoteConfig.getString(
        'shake_reporter_blocked_routes',
      );
      final blockedRoutes = _parseStringList(blockedRoutesString);
      final allowedEnvironmentsString = _remoteConfig.getString(
        'shake_reporter_allowed_environments',
      );
      final allowedEnvironments = _parseStringList(allowedEnvironmentsString);
      final maxLogLines = _remoteConfig.getInt('shake_reporter_max_log_lines');

      final config = ShakeReporterConfig(
        enabled: enabled,
        sensitivityThreshold: sensitivityThreshold,
        cooldownSeconds: cooldownSeconds,
        screenshotEnabled: screenshotEnabled,
        blockedRoutes: blockedRoutes,
        allowedEnvironments: allowedEnvironments.isEmpty
            ? const ['staging']
            : allowedEnvironments,
        maxLogLines: maxLogLines <= 0 ? 50 : maxLogLines,
      );

      return Right(config);
    } catch (e) {
      return Left(NetworkFailure('Failed to fetch remote config: $e'));
    }
  }
}
