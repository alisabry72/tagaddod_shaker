import 'dart:convert';

import 'package:fly_networking/AppException.dart';
import 'package:fly_networking/fly.dart';

import 'shake_diagnostics_service.dart';

/// Global Fly wrapper that captures GraphQL failures from all requests.
/// This avoids adding per-mutation listeners across a large codebase.
class ObservedFly extends Fly<dynamic> {
  final String _defaultApiUrl;
  final ShakeDiagnosticsService _diagnostics;

  ObservedFly(this._defaultApiUrl, this._diagnostics) : super(_defaultApiUrl);

  @override
  Future<Map<String, dynamic>?> requestWithoutParse({
    String? apiUrl,
    required dynamic query,
    Map<String, String>? parameters,
  }) async {
    final endpoint = (apiUrl == null || apiUrl.trim().isEmpty)
        ? _defaultApiUrl
        : apiUrl.trim();
    final operation = _extractOperationName(query);
    final requestContext = 'POST $endpoint | op:$operation';

    _diagnostics.recordApiTriggered(method: 'POST', endpoint: endpoint);
    try {
      final result = await super.requestWithoutParse(
        apiUrl: apiUrl,
        query: query,
        parameters: parameters,
      );
      if (_hasGraphQlErrors(result)) {
        _diagnostics.captureRawLogLine(jsonEncode(result));
        _diagnostics.recordApiFailed(
          method: 'POST',
          endpoint: endpoint,
          statusCode: 200,
          error: 'GraphQL errors payload returned',
        );
        return result;
      }
      _diagnostics.recordApiSuccess(
        method: 'POST',
        endpoint: endpoint,
        statusCode: 200,
      );
      return result;
    } on AppException catch (e) {
      _diagnostics.captureFlyAppException(e, requestContext: requestContext);
      _diagnostics.recordApiFailed(
        method: 'POST',
        endpoint: endpoint,
        statusCode: e.code,
        error: e.uglyMsg ?? e.beautifulMsg,
      );
      rethrow;
    } catch (e) {
      _diagnostics.recordApiFailed(
        method: 'POST',
        endpoint: endpoint,
        error: e.toString(),
      );
      rethrow;
    }
  }

  String _extractOperationName(dynamic query) {
    if (query is Map && query['query'] is String) {
      return _extractFromGraphQlString((query['query'] as String));
    }

    if (query is List && query.isNotEmpty) {
      return _extractOperationName(query.first);
    }

    return 'unknown';
  }

  String _extractFromGraphQlString(String queryText) {
    final compact = queryText.replaceAll('\n', ' ').trim();
    if (compact.isEmpty) return 'unknown';

    final fieldMatch = RegExp(
      r'\{\s*([A-Za-z0-9_]+)\s*(\(|\{)',
    ).firstMatch(compact);
    if (fieldMatch != null) {
      return fieldMatch.group(1) ?? 'unknown';
    }
    return 'unknown';
  }

  bool _hasGraphQlErrors(Map<String, dynamic>? result) {
    if (result == null) return false;
    final errors = result['errors'];
    return errors is List && errors.isNotEmpty;
  }
}
