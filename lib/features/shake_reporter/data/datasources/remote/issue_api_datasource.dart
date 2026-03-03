import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:tagaddod_shaker/src/config/shake_reporter_endpoints.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../../domain/entities/issue_report.dart';
import '../../../domain/entities/linear_team.dart';
import '../../../service/shake_diagnostics_service.dart';
import '../../models/issue_report_model.dart';

abstract class IssueApiDatasource {
  Future<Either<Failure, void>> submitIssueReport(IssueReport report);
  Future<Either<Failure, List<LinearTeam>>> fetchLinearTeams();
}

class IssueApiDatasourceImpl implements IssueApiDatasource {
  final http.Client client;
  final String baseUrl;
  final String token;
  final String teamId;
  final String? projectId;
  final ShakeDiagnosticsService diagnosticsService;
  static const int _maxInlineImageBase64Chars = 120000;

  IssueApiDatasourceImpl(
    this.client,
    this.baseUrl, {
    required this.token,
    required this.teamId,
    this.projectId,
    required this.diagnosticsService,
  });

  static const String _issueCreateMutation = r'''
mutation IssueCreate($input: IssueCreateInput!) {
  issueCreate(input: $input) {
    success
  }
}
''';

  static const String _listTeamsQuery = r'''
query Teams {
  teams {
    nodes {
      id
      name
      key
    }
  }
}
''';

  @override
  Future<Either<Failure, void>> submitIssueReport(IssueReport report) async {
    if (token.trim().isEmpty || teamId.trim().isEmpty) {
      return Left(
        ApiFailure(
          'LINEAR_TOKEN and LINEAR_TEAM_ID are required',
          statusCode: 500,
        ),
      );
    }

    Either<Failure, void> lastResult = const Left(NetworkFailure('Initial'));
    const int maxRetries = 3;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      // For the first two attempts, try including the image object.
      // If it keeps failing (e.g., image is too large), the final attempt will fallback to logs only (without images).
      final bool shouldIncludeImage = attempt < maxRetries - 1;

      lastResult = await _attemptSubmit(
        report,
        includeImage: shouldIncludeImage,
      );
      if (lastResult.isRight()) {
        return lastResult; // Success
      }

      if (attempt < maxRetries - 1) {
        // Wait before retrying
        await Future.delayed(const Duration(seconds: 2));
      }
    }

    return lastResult;
  }

  Future<Either<Failure, void>> _attemptSubmit(
    IssueReport report, {
    required bool includeImage,
  }) async {
    try {
      final model = IssueReportModel.fromEntity(report);
      final payload = model.toJson();
      final description = _buildLinearDescription(model, payload, includeImage);

      final input = <String, dynamic>{
        'teamId': teamId,
        'title': model.title.trim().isEmpty
            ? 'Shake report'
            : model.title.trim(),
        'description': description,
      };

      final normalizedProjectId = projectId?.trim() ?? '';
      if (normalizedProjectId.isNotEmpty) {
        input['projectId'] = normalizedProjectId;
      }

      final response = await client.post(
        (() {
          diagnosticsService.recordApiTriggered(
            method: 'POST',
            endpoint: baseUrl,
          );
          return Uri.parse(baseUrl);
        })(),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{
          'query': _issueCreateMutation,
          'variables': <String, dynamic>{'input': input},
        }),
      );

      if (response.statusCode != 200) {
        diagnosticsService.recordApiFailed(
          method: 'POST',
          endpoint: baseUrl,
          statusCode: response.statusCode,
          error: response.body,
        );
        return Left(
          ApiFailure(
            'Linear request failed: ${response.body}',
            statusCode: response.statusCode,
          ),
        );
      }
      diagnosticsService.recordApiSuccess(
        method: 'POST',
        endpoint: baseUrl,
        statusCode: response.statusCode,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        diagnosticsService.recordApiFailed(
          method: 'POST',
          endpoint: baseUrl,
          statusCode: 200,
          error: errors.toString(),
        );
        return Left(
          ApiFailure('Linear GraphQL error: $errors', statusCode: 200),
        );
      }

      final success =
          (((decoded['data'] as Map<String, dynamic>?)?['issueCreate']
                  as Map<String, dynamic>?)?['success'])
              as bool? ??
          false;
      if (!success) {
        diagnosticsService.recordApiFailed(
          method: 'POST',
          endpoint: baseUrl,
          statusCode: 200,
          error: 'issueCreate success=false',
        );
        return Left(
          ApiFailure(
            'Linear issueCreate returned success=false',
            statusCode: 200,
          ),
        );
      }

      return const Right(null);
    } catch (e) {
      diagnosticsService.recordApiFailed(
        method: 'POST',
        endpoint: baseUrl,
        error: e.toString(),
      );
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LinearTeam>>> fetchLinearTeams() async {
    try {
      if (token.trim().isEmpty) {
        return Left(
          ApiFailure(
            'LINEAR_TOKEN is required to fetch teams',
            statusCode: 500,
          ),
        );
      }

      final response = await client.post(
        (() {
          diagnosticsService.recordApiTriggered(
            method: 'POST',
            endpoint: baseUrl,
          );
          return Uri.parse(baseUrl);
        })(),
        headers: <String, String>{
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, dynamic>{'query': _listTeamsQuery}),
      );

      if (response.statusCode != 200) {
        diagnosticsService.recordApiFailed(
          method: 'POST',
          endpoint: baseUrl,
          statusCode: response.statusCode,
          error: response.body,
        );
        return Left(
          ApiFailure(
            'Failed to fetch Linear teams: ${response.body}',
            statusCode: response.statusCode,
          ),
        );
      }
      diagnosticsService.recordApiSuccess(
        method: 'POST',
        endpoint: baseUrl,
        statusCode: response.statusCode,
      );

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final errors = decoded['errors'];
      if (errors is List && errors.isNotEmpty) {
        diagnosticsService.recordApiFailed(
          method: 'POST',
          endpoint: baseUrl,
          statusCode: 200,
          error: errors.toString(),
        );
        return Left(
          ApiFailure('Linear GraphQL error: $errors', statusCode: 200),
        );
      }

      final nodes =
          (((decoded['data'] as Map<String, dynamic>?)?['teams']
                  as Map<String, dynamic>?)?['nodes']
              as List<dynamic>?) ??
          const <dynamic>[];

      final teams = nodes
          .whereType<Map<String, dynamic>>()
          .map(
            (node) => LinearTeam(
              id: (node['id'] ?? '').toString(),
              name: (node['name'] ?? '').toString(),
              key: node['key']?.toString(),
            ),
          )
          .where((team) => team.id.isNotEmpty)
          .toList();

      return Right(teams);
    } catch (e) {
      diagnosticsService.recordApiFailed(
        method: 'POST',
        endpoint: baseUrl,
        error: e.toString(),
      );
      return Left(NetworkFailure('Network error: $e'));
    }
  }

  String _getEnvironmentFromApiLink() {
    final link = ShakeReporterEndpoints.apiLink.toLowerCase();
    if (link.contains('staging')) return 'Staging';
    if (link.contains('dev')) return 'Development';
    if (link.contains('localhost') || link.contains('10.0.2.2')) return 'Local';
    return 'Production';
  }

  String _buildLinearDescription(
    IssueReportModel report,
    Map<String, dynamic> rawPayload,
    bool includeImage,
  ) {
    final ctx = report.deviceContext;
    final screenshotPreview = _buildBase64Preview(report.screenshotBase64);
    final screenshotDataUri = _buildScreenshotDataUri(report.screenshotBase64);
    final latestFlyErrors = ctx.recentLogs.isEmpty
        ? 'No Fly backend error captured in current app session.'
        : _truncate(ctx.recentLogs.join('\n'), 4000);

    final sanitizedPayload = Map<String, dynamic>.from(rawPayload);
    final screenshotLen = report.screenshotBase64?.length ?? 0;
    if (sanitizedPayload.containsKey('screenshotBase64')) {
      sanitizedPayload['screenshotBase64'] = screenshotLen > 0
          ? '<omitted_base64 length=$screenshotLen>'
          : null;
    }
    if (screenshotPreview != null) {
      sanitizedPayload['screenshotBase64Preview'] = screenshotPreview;
    }
    final payloadJson = _truncate(
      const JsonEncoder.withIndent('  ').convert(sanitizedPayload),
      6000,
    );
    final isImageIncluded =
        includeImage &&
        report.includeScreenshot &&
        (report.screenshotBase64?.isNotEmpty ?? false);
    final screenshotSection = isImageIncluded
        ? (screenshotDataUri != null
              ? '''

## Screenshot
![shake_reporter_screenshot]($screenshotDataUri)
'''
              : '''

## Screenshot
- Captured on device but skipped inline rendering (payload too large for safe submit).
- Total Length: $screenshotLen chars
```text
${screenshotPreview ?? '<not available>'}
```
''')
        : (includeImage
              ? ''
              : '\n## Screenshot\n- System omitted image during fallback retry to ensure ticket creation succeeds.');

    final realEnv = _getEnvironmentFromApiLink();

    return '''
## User Description
${report.description}

## Context
- APP: SuperApp
- Screen: ${ctx.currentRoute}
- App Version: ${ctx.appVersion} (${ctx.buildNumber})
- Device: ${ctx.deviceModel}
- OS: ${ctx.osName} ${ctx.osVersion}
- Network: ${ctx.networkStatus}
- Environment: $realEnv (from API_LINK)
- Device Context Env: ${ctx.environment}
- User ID: ${ctx.userId}
- Session ID: ${ctx.sessionId}
- Reported At: ${ctx.timestamp.toUtc()}
$screenshotSection
## Latest Fly Errors
```text
$latestFlyErrors
```

## Raw Mobile Payload
```json
$payloadJson
```
''';
  }

  String _truncate(String value, int maxChars) {
    if (value.length <= maxChars) return value;
    return '${value.substring(0, maxChars)}\n...<truncated ${value.length - maxChars} chars>';
  }

  String? _buildBase64Preview(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    const int head = 1200;
    const int tail = 200;
    if (base64.length <= head + tail) return base64;
    final omitted = base64.length - head - tail;
    return '${base64.substring(0, head)}...<snip $omitted chars>...${base64.substring(base64.length - tail)}';
  }

  String? _buildScreenshotDataUri(String? base64) {
    if (base64 == null || base64.isEmpty) return null;
    if (base64.length > _maxInlineImageBase64Chars) return null;
    final mimeType = _detectMimeTypeFromBase64(base64);
    return 'data:$mimeType;base64,$base64';
  }

  String _detectMimeTypeFromBase64(String base64) {
    try {
      final bytes = base64Decode(base64);
      if (bytes.length >= 4 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        return 'image/png';
      }
      if (bytes.length >= 3 &&
          bytes[0] == 0xFF &&
          bytes[1] == 0xD8 &&
          bytes[2] == 0xFF) {
        return 'image/jpeg';
      }
      if (bytes.length >= 12 &&
          bytes[0] == 0x52 &&
          bytes[1] == 0x49 &&
          bytes[2] == 0x46 &&
          bytes[3] == 0x46 &&
          bytes[8] == 0x57 &&
          bytes[9] == 0x45 &&
          bytes[10] == 0x42 &&
          bytes[11] == 0x50) {
        return 'image/webp';
      }
    } catch (_) {
      // Fall through to default.
    }
    return 'image/png';
  }
}
