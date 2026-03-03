import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/issue_report.dart';
import '../repositories/issue_reporter_repository.dart';

class SubmitIssueReportUseCase {
  final IssueReporterRepository repository;

  SubmitIssueReportUseCase(this.repository);

  Future<Either<Failure, void>> call(IssueReport report) {
    return repository.submitIssueReport(report);
  }
}
