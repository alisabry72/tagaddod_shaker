import 'package:dartz/dartz.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../../domain/entities/issue_report.dart';
import '../../models/issue_report_model.dart';

abstract class PendingReportsLocalDatasource {
  Future<Either<Failure, void>> saveReport(IssueReport report);
  Future<Either<Failure, List<IssueReport>>> getPendingReports();
  Future<Either<Failure, void>> removeReport(String id);
  Future<Either<Failure, void>> clearAll();
}

class PendingReportsLocalDatasourceImpl
    implements PendingReportsLocalDatasource {
  static const String _boxName = 'pending_reports';

  Future<Box<String>> _getBox() async {
    return await Hive.openBox<String>(_boxName);
  }

  @override
  Future<Either<Failure, void>> saveReport(IssueReport report) async {
    try {
      final box = await _getBox();
      final model = IssueReportModel.fromEntity(report);
      final key = report.createdAt.toIso8601String(); // Use timestamp as key
      await box.put(key, model.toJson().toString());
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save pending report: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IssueReport>>> getPendingReports() async {
    try {
      final box = await _getBox();
      final reports = <IssueReport>[];
      for (final jsonString in box.values) {
        final model = IssueReportModel.fromJson(
          jsonString as Map<String, dynamic>,
        );
        reports.add(model.toEntity());
      }
      return Right(reports);
    } catch (e) {
      return Left(CacheFailure('Failed to load pending reports: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeReport(String id) async {
    try {
      final box = await _getBox();
      await box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to remove report: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearAll() async {
    try {
      final box = await _getBox();
      await box.clear();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to clear reports: $e'));
    }
  }
}
