import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/issue_report.dart';
import '../entities/linear_team.dart';

abstract class IssueReporterRepository {
  Future<Either<Failure, void>> submitIssueReport(IssueReport report);
  Future<Either<Failure, List<LinearTeam>>> fetchLinearTeams();
  Future<Either<Failure, void>> queueReportLocally(IssueReport report);
  Future<Either<Failure, void>> flushPendingReports();
}
