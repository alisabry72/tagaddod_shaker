import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/shake_reporter_config.dart';

abstract class ConfigRepository {
  Future<Either<Failure, ShakeReporterConfig>> getConfig();
}
