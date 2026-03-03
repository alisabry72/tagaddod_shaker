import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dartz/dartz.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../domain/entities/device_context.dart';
import 'shake_diagnostics_service.dart';

class DeviceContextService {
  final DeviceInfoPlugin _deviceInfo;
  final Connectivity _connectivity;
  final SharedPreferences _sharedPreferences;
  final ShakeDiagnosticsService _diagnosticsService;

  DeviceContextService({
    DeviceInfoPlugin? deviceInfo,
    Connectivity? connectivity,
    SharedPreferences? sharedPreferences,
    ShakeDiagnosticsService? diagnosticsService,
  }) : _deviceInfo = deviceInfo ?? DeviceInfoPlugin(),
       _connectivity = connectivity ?? Connectivity(),
       _sharedPreferences =
           sharedPreferences ?? GetIt.instance<SharedPreferences>(),
       _diagnosticsService =
           diagnosticsService ?? GetIt.instance<ShakeDiagnosticsService>();

  // TODO: Inject log buffer, session service, router
  // final LogBuffer _logBuffer;
  // final SessionService _session;
  // final RouterObserver _router;

  Future<Either<Failure, DeviceContext>> capture() async {
    try {
      final deviceInfoFuture = _deviceInfo.deviceInfo;
      final connectivityFuture = _connectivity.checkConnectivity();
      final packageInfoFuture = PackageInfo.fromPlatform();

      final deviceInfo = await deviceInfoFuture;
      final dynamic connectivityRaw = await connectivityFuture;
      final packageInfo = await packageInfoFuture;
      final connectivity = _normalizeConnectivity(connectivityRaw);
      final collectorId = _sharedPreferences.getString('collectorId');
      final salesAgentId = _sharedPreferences.getString('salesAgentId');
      final userId = (collectorId?.trim().isNotEmpty ?? false)
          ? collectorId!.trim()
          : ((salesAgentId?.trim().isNotEmpty ?? false)
                ? salesAgentId!.trim()
                : 'anonymous');

      return Right(
        DeviceContext(
          appVersion: packageInfo.version,
          buildNumber: packageInfo.buildNumber,
          deviceModel: _extractDeviceModel(deviceInfo),
          osName: Platform.isIOS ? 'iOS' : 'Android',
          osVersion: _extractOsVersion(deviceInfo),
          userId: userId,
          sessionId: DateTime.now().millisecondsSinceEpoch.toString(),
          currentRoute: _diagnosticsService.currentRoute,
          networkStatus: _mapConnectivity(connectivity),
          environment: const String.fromEnvironment(
            'APP_ENV',
            defaultValue: 'unknown',
          ),
          recentLogs: _diagnosticsService.getRecentFlyErrors(20),
          timestamp: DateTime.now().toUtc(),
        ),
      );
    } catch (e) {
      return Left(AppExceptionFailure('Failed to capture device context: $e'));
    }
  }

  String _extractDeviceModel(BaseDeviceInfo deviceInfo) {
    if (Platform.isAndroid) {
      final androidInfo = deviceInfo as AndroidDeviceInfo;
      return androidInfo.model;
    } else if (Platform.isIOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      return iosInfo.utsname.machine;
    }
    return 'Unknown';
  }

  String _extractOsVersion(BaseDeviceInfo deviceInfo) {
    if (Platform.isAndroid) {
      final androidInfo = deviceInfo as AndroidDeviceInfo;
      return androidInfo.version.release;
    } else if (Platform.isIOS) {
      final iosInfo = deviceInfo as IosDeviceInfo;
      return iosInfo.systemVersion;
    }
    return 'Unknown';
  }

  String _mapConnectivity(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return 'wifi';
      case ConnectivityResult.mobile:
        return 'mobile';
      case ConnectivityResult.ethernet:
        return 'ethernet';
      case ConnectivityResult.bluetooth:
        return 'bluetooth';
      case ConnectivityResult.none:
        return 'none';
      default:
        return 'unknown';
    }
  }

  ConnectivityResult _normalizeConnectivity(dynamic raw) {
    // connectivity_plus v6 may return List<ConnectivityResult> on some platforms.
    if (raw is ConnectivityResult) return raw;
    if (raw is List && raw.isNotEmpty) {
      final first = raw.first;
      if (first is ConnectivityResult) return first;
    }
    return ConnectivityResult.none;
  }
}
