import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import 'package:tagaddod_shaker/features/shake_reporter/service/screenshot_capture_service.dart';

abstract class ScreenshotDatasource {
  Future<Either<Failure, String>> captureAsBase64();
}

class ScreenshotDatasourceImpl implements ScreenshotDatasource {
  final ScreenshotCaptureService _captureService;

  ScreenshotDatasourceImpl(this._captureService);

  @override
  Future<Either<Failure, String>> captureAsBase64() async {
    try {
      final preCaptured = _captureService.consumeLatestCapture();
      if (preCaptured != null && preCaptured.trim().isNotEmpty) {
        return Right(preCaptured);
      }

      final captured = await _captureService.captureFromBoundary();
      if (captured == null || captured.trim().isEmpty) {
        return const Left(
          AppExceptionFailure('Screenshot capture returned empty image'),
        );
      }

      return Right(captured);
    } catch (e) {
      return Left(AppExceptionFailure('Failed to capture screenshot: $e'));
    }
  }
}
