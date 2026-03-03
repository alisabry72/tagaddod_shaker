import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';

abstract class ScreenshotRepository {
  Future<Either<Failure, String>> captureAsBase64();
}
