import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/issue_report.dart';
import 'device_context_model.dart';

part 'issue_report_model.g.dart';

@JsonSerializable()
class IssueReportModel {
  final String title;
  final String description;
  final DeviceContextModel deviceContext;
  final String? screenshotBase64;
  final bool includeScreenshot;
  final DateTime createdAt;

  const IssueReportModel({
    required this.title,
    required this.description,
    required this.deviceContext,
    this.screenshotBase64,
    required this.includeScreenshot,
    required this.createdAt,
  });

  factory IssueReportModel.fromJson(Map<String, dynamic> json) =>
      _$IssueReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$IssueReportModelToJson(this);

  factory IssueReportModel.fromEntity(IssueReport entity) {
    return IssueReportModel(
      title: entity.title,
      description: entity.description,
      deviceContext: DeviceContextModel.fromEntity(entity.deviceContext),
      screenshotBase64: entity.screenshotBase64,
      includeScreenshot: entity.includeScreenshot,
      createdAt: entity.createdAt,
    );
  }

  IssueReport toEntity() {
    return IssueReport(
      title: title,
      description: description,
      deviceContext: deviceContext.toEntity(),
      screenshotBase64: screenshotBase64,
      includeScreenshot: includeScreenshot,
      createdAt: createdAt,
    );
  }
}
