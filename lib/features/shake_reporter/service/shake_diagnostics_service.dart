import 'dart:collection';
import 'dart:convert';
import 'package:fly_networking/AppException.dart';

class ShakeDiagnosticsService {
  final ListQueue<String> _flyErrors = ListQueue<String>();
  static const int _maxLines = 100;
  static const int _maxRawChars = 1800;

  String _currentRoute = 'unknown';
  String get currentRoute => _currentRoute;
  String? _lastFlyRequest;
  bool _awaitingFlyResponse = false;

  void setCurrentRoute(String route) {
    if (route.trim().isEmpty) return;
    _currentRoute = route;
  }

  void log(String message) {}

  void captureRawLogLine(String line) {
    final text = _normalizeLogLine(line);
    if (text.isEmpty) return;

    // Capture Fly-style request logs robustly:
    // "Request: POST https://.../graphql"
    if (text.contains('Request:')) {
      final methodMatch = RegExp(
        r'\b(GET|POST|PUT|PATCH|DELETE)\b',
      ).firstMatch(text);
      final urlMatch = RegExp(r'https?://\S+').firstMatch(text);
      final method = methodMatch?.group(1) ?? 'UNKNOWN';
      final endpoint = urlMatch?.group(0) ?? 'unknown';
      if (endpoint.contains('tagaddod.com') && endpoint.contains('/graphql')) {
        _lastFlyRequest = '$method $endpoint';
        _awaitingFlyResponse = true;
      }
      return;
    }

    if (!_awaitingFlyResponse) {
      final fallbackCapture = _tryCaptureGraphQlErrorsPayload(text);
      if (fallbackCapture) return;
      return;
    }

    if (_awaitingFlyResponse && text.contains('Response:')) {
      return;
    }

    final lowered = text.toLowerCase();
    if (lowered.contains('linear graphql error') ||
        lowered.contains('api.linear.app')) {
      return;
    }

    if (_tryCaptureGraphQlErrorsPayload(text)) {
      _awaitingFlyResponse = false;
      return;
    }
    try {
      final dynamic decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) {
        // Response parsed and no GraphQL errors => close awaiting window.
        _awaitingFlyResponse = false;
        return;
      }
    } catch (_) {
      // keep legacy fallback checks below
    }

    // Capture server-side error payloads that include GraphQL "errors".
    if (lowered.contains('errors') ||
        lowered.contains('"message"') ||
        lowered.contains(r'\"message\"') ||
        lowered.contains('invalid information')) {
      final compact = _sanitizeRaw(text);
      final requestContext = _lastFlyRequest ?? 'unknown request';
      final message = _extractErrorMessage(compact);
      _addFlyError('[FLY_ERROR] $requestContext | $message');
      _addFlyError('[FLY_ERROR_RAW] $compact');
      _awaitingFlyResponse = false;
      return;
    }
  }

  void captureFlyAppException(
    AppException exception, {
    String? requestContext,
  }) {
    final request = requestContext?.trim().isNotEmpty == true
        ? requestContext!.trim()
        : (_lastFlyRequest ?? 'unknown request');
    final payload = exception.uglyMsg?.trim();
    final fallback = exception.beautifulMsg?.trim();

    if (payload != null && payload.isNotEmpty) {
      final normalized = _sanitizeRaw(_normalizePossibleJson(payload));
      final message = _extractErrorMessage(normalized);
      _addFlyError('[FLY_ERROR] $request | $message');
      _addFlyError('[FLY_ERROR_RAW] $normalized');
      _awaitingFlyResponse = false;
      return;
    }

    if (fallback != null && fallback.isNotEmpty) {
      _addFlyError('[FLY_ERROR] $request | $fallback');
      _awaitingFlyResponse = false;
    }
  }

  void captureAnyError(Object error, {String? requestContext}) {
    if (error is AppException) {
      captureFlyAppException(error, requestContext: requestContext);
    }
  }

  void recordApiTriggered({required String method, required String endpoint}) {}

  void recordApiSuccess({
    required String method,
    required String endpoint,
    required int statusCode,
  }) {}

  void recordApiFailed({
    required String method,
    required String endpoint,
    int? statusCode,
    String? error,
  }) {}

  List<String> getRecentFlyErrors([int maxLines = 20]) {
    final logs = <String>[];
    if (_lastFlyRequest != null) {
      logs.add(
        '[${DateTime.now().toUtc().toIso8601String()}] [FLY_REQUEST] $_lastFlyRequest',
      );
    }
    if (_flyErrors.isNotEmpty) {
      final start = _flyErrors.length > maxLines
          ? _flyErrors.length - maxLines
          : 0;
      logs.addAll(_flyErrors.toList().sublist(start));
    }
    return logs;
  }

  void _addFlyError(String message) {
    final line = '[${DateTime.now().toUtc().toIso8601String()}] $message';
    if (_flyErrors.length >= _maxLines) {
      _flyErrors.removeFirst();
    }
    _flyErrors.addLast(line);
  }

  String _extractErrorMessage(String payload) {
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(payload);
    if (match != null) {
      return match.group(1) ?? 'Unknown error';
    }
    if (payload.toLowerCase().contains('invalid information')) {
      return 'Invalid information';
    }
    return 'Fly backend error';
  }

  String _normalizeLogLine(String line) {
    final text = line.trim();
    if (text.isEmpty) return text;

    // Handles logcat lines like:
    // I/flutter (22307): {"errors":[...]}
    final match = RegExp(
      r'^[A-Z]\/flutter\s*\(\s*\d+\s*\):\s*(.*)$',
    ).firstMatch(text);
    if (match != null) {
      return (match.group(1) ?? '').trim();
    }
    return text;
  }

  String _normalizePossibleJson(String text) {
    final raw = text.trim();
    if (raw.isEmpty) return raw;

    try {
      final decoded = jsonDecode(raw);
      return jsonEncode(decoded);
    } catch (_) {
      return raw;
    }
  }

  String _sanitizeRaw(String raw) {
    var value = raw;
    value = value.replaceAll(
      RegExp(r'data:image\/[a-zA-Z0-9.+-]+;base64,[A-Za-z0-9+/=]+'),
      '<omitted_base64_image>',
    );
    if (value.length > _maxRawChars) {
      value =
          '${value.substring(0, _maxRawChars)}...<truncated ${value.length - _maxRawChars} chars>';
    }
    return value;
  }

  bool _tryCaptureGraphQlErrorsPayload(String text) {
    try {
      final dynamic decoded = jsonDecode(text);
      if (decoded is! Map<String, dynamic>) return false;
      final errors = decoded['errors'];
      if (errors is! List || errors.isEmpty) return false;
      final compact = _sanitizeRaw(jsonEncode(decoded));
      final requestContext = _lastFlyRequest ?? 'unknown request';
      final message = _extractErrorMessage(compact);
      _addFlyError('[FLY_ERROR] $requestContext | $message');
      _addFlyError('[FLY_ERROR_RAW] $compact');
      return true;
    } catch (_) {
      return false;
    }
  }
}
