// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_report_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

IssueReportModel _$IssueReportModelFromJson(Map<String, dynamic> json) =>
    IssueReportModel(
      title: json['title'] as String,
      description: json['description'] as String,
      deviceContext: DeviceContextModel.fromJson(
        json['deviceContext'] as Map<String, dynamic>,
      ),
      screenshotBase64: json['screenshotBase64'] as String?,
      includeScreenshot: json['includeScreenshot'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$IssueReportModelToJson(IssueReportModel instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'deviceContext': instance.deviceContext.toJson(),
      'screenshotBase64': instance.screenshotBase64,
      'includeScreenshot': instance.includeScreenshot,
      'createdAt': instance.createdAt.toIso8601String(),
    };
