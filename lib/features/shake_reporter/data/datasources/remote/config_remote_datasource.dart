import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:tagaddod_shaker/features/shake_reporter/shake_reporter_options.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import 'package:tagaddod_shaker/features/shake_reporter/domain/entities/shake_reporter_config.dart';

abstract class ConfigRemoteDatasource {
  Future<Either<Failure, ShakeReporterConfig>> getConfig();
}

class ConfigRemoteDatasourceImpl implements ConfigRemoteDatasource {
  final FirebaseRemoteConfig _remoteConfig;
  final ShakeReporterRemoteConfigKeys _keys;
  final Duration _fetchTimeout;
  final Duration? _minimumFetchInterval;
  bool _isConfigured = false;

  ConfigRemoteDatasourceImpl(
    this._remoteConfig, {
    ShakeReporterRemoteConfigKeys keys = const ShakeReporterRemoteConfigKeys(),
    Duration fetchTimeout = const Duration(seconds: 10),
    Duration? minimumFetchInterval,
  }) : _keys = keys,
       _fetchTimeout = fetchTimeout,
       _minimumFetchInterval = minimumFetchInterval;

  Future<void> _configureIfNeeded() async {
    if (_isConfigured) return;

    await _remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: _fetchTimeout,
        minimumFetchInterval:
            _minimumFetchInterval ??
            (kDebugMode ? Duration.zero : const Duration(minutes: 30)),
      ),
    );

    // Prevent silent zero/empty values when a key is missing in Firebase.
    await _remoteConfig.setDefaults(_keys.defaults());

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

      final enabled = _remoteConfig.getBool(_keys.enabled);
      final sensitivityThreshold = _remoteConfig.getDouble(
        _keys.sensitivityThreshold,
      );
      final cooldownSeconds = _remoteConfig.getInt(_keys.cooldownSeconds);
      final screenshotEnabled = _remoteConfig.getBool(_keys.screenshotEnabled);
      final blockedRoutesString = _remoteConfig.getString(_keys.blockedRoutes);
      final blockedRoutes = _parseStringList(blockedRoutesString);
      final allowedEnvironmentsString = _remoteConfig.getString(
        _keys.allowedEnvironments,
      );
      final allowedEnvironments = _parseStringList(allowedEnvironmentsString);
      final maxLogLines = _remoteConfig.getInt(_keys.maxLogLines);

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
