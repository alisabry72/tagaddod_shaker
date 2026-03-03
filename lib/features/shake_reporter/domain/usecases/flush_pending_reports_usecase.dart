import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../repositories/issue_reporter_repository.dart';

class FlushPendingReportsUseCase {
  final IssueReporterRepository repository;

  FlushPendingReportsUseCase(this.repository);

  Future<Either<Failure, void>> call() {
    return repository.flushPendingReports();
  }
}
