import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/shake_reporter_config.dart';
import '../repositories/config_repository.dart';

class GetReporterConfigUseCase {
  final ConfigRepository repository;

  GetReporterConfigUseCase(this.repository);

  Future<Either<Failure, ShakeReporterConfig>> call() {
    return repository.getConfig();
  }
}
