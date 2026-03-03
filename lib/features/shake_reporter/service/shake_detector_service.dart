import 'dart:async';
import 'dart:math';
import 'package:flutter/widgets.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../domain/usecases/get_reporter_config_usecase.dart';
import '../domain/entities/shake_reporter_config.dart';

class ShakeDetectorService with WidgetsBindingObserver {
  final GetReporterConfigUseCase _configUseCase;

  StreamSubscription<UserAccelerometerEvent>? _subscription;
  final _triggerController = StreamController<void>.broadcast();

  Stream<void> get onShakeTrigger => _triggerController.stream;
  static const int _shakeWindowMs = 1200;
  static const int _requiredShakeCount = 2;
  static const int _requiredDirectionChanges = 0;
  static const int _minSpikeGapMs = 80;

  DateTime? _lastTriggered;
  DateTime? _shakeWindowStart;
  DateTime? _lastSpikeAt;
  DateTime? _listeningStartedAt;

  bool _isSheetOpen = false;
  bool _isListening = false;

  int _shakeCount = 0;
  int _directionChanges = 0;
  int? _lastDirection;
  int? _lastAxis;

  ShakeReporterConfig? _config;

  ShakeDetectorService(this._configUseCase);

  // ----------------------------
  // Initialization
  // ----------------------------

  Future<void> initialize() async {
    if (_isListening) return;

    final configResult = await _configUseCase.call();

    configResult.fold((_) => null, (config) {
      if (!config.enabled) return;

      _config = config;
      _startListening();
      WidgetsBinding.instance.addObserver(this);
    });
  }

  void _startListening() {
    if (_isListening || _config == null) return;

    _subscription = userAccelerometerEventStream().listen(_onSensorEvent);
    _isListening = true;
    _listeningStartedAt = DateTime.now();
  }

  void _stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  // ----------------------------
  // Sensor Logic
  // ----------------------------

  void _onSensorEvent(UserAccelerometerEvent event) {
    final config = _config;
    if (config == null) return;
    if (_listeningStartedAt != null &&
        DateTime.now().difference(_listeningStartedAt!) <
            const Duration(milliseconds: 1000)) {
      // Ignore early noisy readings immediately after subscription starts.
      return;
    }

    // Use vector magnitude for stable thresholding.
    final acceleration = sqrt(
      event.x * event.x + event.y * event.y + event.z * event.z,
    );
    final effectiveThreshold = (config.sensitivityThreshold * 0.85).clamp(
      1.6,
      6.0,
    );
    if (acceleration < effectiveThreshold) return;
    if (_isInCooldown(config.cooldownSeconds)) return;
    if (_isSheetOpen) return;

    final now = DateTime.now();
    if (_lastSpikeAt != null &&
        now.difference(_lastSpikeAt!) <
            const Duration(milliseconds: _minSpikeGapMs)) {
      return;
    }
    _lastSpikeAt = now;

    // Start shake window
    _shakeWindowStart ??= now;

    // Reset window if exceeded
    if (now.difference(_shakeWindowStart!) >
        const Duration(milliseconds: _shakeWindowMs)) {
      _resetShakeWindow(startAt: now);
    }

    final axis = _dominantAxis(event);
    // Ignore mostly vertical/device-lift movements to reduce accidental opens.
    if (axis == 2) return;
    final horizontalMagnitude = axis == 0 ? event.x.abs() : event.y.abs();
    if (horizontalMagnitude < event.z.abs() * 0.85) return;
    final direction = _axisDirection(event, axis);
    if (_lastAxis != null &&
        _lastDirection != null &&
        _lastAxis == axis &&
        _lastDirection != direction) {
      _directionChanges++;
    }
    _lastAxis = axis;
    _lastDirection = direction;

    _shakeCount++;

    if (_shakeCount >= _requiredShakeCount &&
        _directionChanges >= _requiredDirectionChanges) {
      _trigger(now);
    }
  }

  void _trigger(DateTime now) {
    _lastTriggered = now;
    _resetShakeWindow();
    _triggerController.add(null);
  }

  void _resetShakeWindow({DateTime? startAt}) {
    _shakeCount = 0;
    _directionChanges = 0;
    _lastDirection = null;
    _lastAxis = null;
    _shakeWindowStart = startAt;
    _lastSpikeAt = null;
  }

  int _dominantAxis(UserAccelerometerEvent event) {
    final ax = event.x.abs();
    final ay = event.y.abs();
    final az = event.z.abs();
    if (ax >= ay && ax >= az) return 0;
    if (ay >= ax && ay >= az) return 1;
    return 2;
  }

  int _axisDirection(UserAccelerometerEvent event, int axis) {
    final value = axis == 0
        ? event.x
        : axis == 1
        ? event.y
        : event.z;
    return value >= 0 ? 1 : -1;
  }

  bool _isInCooldown(int seconds) {
    if (_lastTriggered == null) return false;
    return DateTime.now().difference(_lastTriggered!).inSeconds < seconds;
  }

  // ----------------------------
  // External Controls
  // ----------------------------

  void setSheetOpen(bool isOpen) {
    _isSheetOpen = isOpen;
  }

  bool canOpenReporterFor({
    required String routeName,
    required String environment,
  }) {
    final config = _config;
    if (config == null || !config.enabled) return false;

    if (config.blockedRoutes.any((blocked) => blocked == routeName)) {
      return false;
    }

    if (config.allowedEnvironments.isNotEmpty) {
      final currentEnv = environment.trim().toLowerCase();
      if (currentEnv.isEmpty || currentEnv == 'unknown') {
        // Do not hard-block when build-time env is not provided.
        return true;
      }
      final allowed = config.allowedEnvironments
          .map((e) => e.trim().toLowerCase())
          .contains(currentEnv);
      if (!allowed) return false;
    }

    return true;
  }

  // ----------------------------
  // Lifecycle Handling
  // ----------------------------

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_config == null) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _stopListening();
    } else if (state == AppLifecycleState.resumed) {
      _startListening();
    }
  }

  // ----------------------------
  // Dispose
  // ----------------------------

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopListening();
    _triggerController.close();
  }
}
