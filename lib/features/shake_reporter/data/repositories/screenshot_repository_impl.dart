import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../domain/repositories/screenshot_repository.dart';
import '../datasources/local/screenshot_datasource.dart';

class ScreenshotRepositoryImpl implements ScreenshotRepository {
  final ScreenshotDatasource _datasource;

  ScreenshotRepositoryImpl(this._datasource);

  @override
  Future<Either<Failure, String>> captureAsBase64() {
    return _datasource.captureAsBase64();
  }
}
