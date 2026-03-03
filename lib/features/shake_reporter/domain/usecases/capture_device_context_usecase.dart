import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../entities/device_context.dart';
import '../../service/device_context_service.dart';

class CaptureDeviceContextUseCase {
  final DeviceContextService service;

  CaptureDeviceContextUseCase(this.service);

  Future<Either<Failure, DeviceContext>> call() {
    return service.capture();
  }
}
