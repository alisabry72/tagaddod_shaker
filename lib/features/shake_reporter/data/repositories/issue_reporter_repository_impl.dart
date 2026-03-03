import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../domain/entities/issue_report.dart';
import '../../domain/entities/linear_team.dart';
import '../../domain/repositories/issue_reporter_repository.dart';
import '../datasources/local/pending_reports_local_datasource.dart';
import '../datasources/remote/issue_api_datasource.dart';

class IssueReporterRepositoryImpl implements IssueReporterRepository {
  final IssueApiDatasource _remoteDatasource;
  final PendingReportsLocalDatasource _localDatasource;

  IssueReporterRepositoryImpl(this._remoteDatasource, this._localDatasource);

  @override
  Future<Either<Failure, List<LinearTeam>>> fetchLinearTeams() {
    return _remoteDatasource.fetchLinearTeams();
  }

  @override
  Future<Either<Failure, void>> submitIssueReport(IssueReport report) async {
    final remoteResult = await _remoteDatasource.submitIssueReport(report);
    return remoteResult.fold((failure) async {
      // If remote fails, queue locally
      final queueResult = await _localDatasource.saveReport(report);
      return queueResult.fold(
        (queueFailure) => Left(queueFailure),
        (_) => Left(failure), // Return original failure, but report is queued
      );
    }, (_) => const Right(null));
  }

  @override
  Future<Either<Failure, void>> queueReportLocally(IssueReport report) async {
    return await _localDatasource.saveReport(report);
  }

  @override
  Future<Either<Failure, void>> flushPendingReports() async {
    final pendingResult = await _localDatasource.getPendingReports();
    return pendingResult.fold((failure) => Left(failure), (reports) async {
      for (final report in reports) {
        final submitResult = await _remoteDatasource.submitIssueReport(report);
        if (submitResult.isRight()) {
          // Remove from queue if successful
          final key = report.createdAt.toIso8601String();
          await _localDatasource.removeReport(key);
        }
        // If failed, keep in queue for next attempt
      }
      return const Right(null);
    });
  }
}
