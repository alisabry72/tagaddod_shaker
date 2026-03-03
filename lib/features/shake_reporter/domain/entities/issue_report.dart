import 'device_context.dart';

class IssueReport {
  final String title;
  final String description;
  final DeviceContext deviceContext;
  final String? screenshotBase64;
  final bool includeScreenshot;
  final DateTime createdAt;

  const IssueReport({
    required this.title,
    required this.description,
    required this.deviceContext,
    this.screenshotBase64,
    required this.includeScreenshot,
    required this.createdAt,
  });

  IssueReport copyWith({
    String? title,
    String? description,
    DeviceContext? deviceContext,
    String? screenshotBase64,
    bool? includeScreenshot,
    DateTime? createdAt,
  }) {
    return IssueReport(
      title: title ?? this.title,
      description: description ?? this.description,
      deviceContext: deviceContext ?? this.deviceContext,
      screenshotBase64: screenshotBase64 ?? this.screenshotBase64,
      includeScreenshot: includeScreenshot ?? this.includeScreenshot,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is IssueReport &&
        other.title == title &&
        other.description == description &&
        other.deviceContext == deviceContext &&
        other.screenshotBase64 == screenshotBase64 &&
        other.includeScreenshot == includeScreenshot &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return title.hashCode ^
        description.hashCode ^
        deviceContext.hashCode ^
        screenshotBase64.hashCode ^
        includeScreenshot.hashCode ^
        createdAt.hashCode;
  }
}
