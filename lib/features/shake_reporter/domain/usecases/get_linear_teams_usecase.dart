import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/linear_team.dart';
import '../repositories/issue_reporter_repository.dart';

class GetLinearTeamsUseCase {
  final IssueReporterRepository repository;

  GetLinearTeamsUseCase(this.repository);

  Future<Either<Failure, List<LinearTeam>>> call() {
    return repository.fetchLinearTeams();
  }
}
