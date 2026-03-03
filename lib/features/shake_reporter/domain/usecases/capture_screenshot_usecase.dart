import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../repositories/screenshot_repository.dart';

class CaptureScreenshotUseCase {
  final ScreenshotRepository repository;

  CaptureScreenshotUseCase(this.repository);

  Future<Either<Failure, String>> call() {
    return repository.captureAsBase64();
  }
}
