import 'package:dartz/dartz.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../domain/entities/shake_reporter_config.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/local/reporter_config_local_datasource.dart';
import '../datasources/remote/config_remote_datasource.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ReporterConfigLocalDatasource _localDatasource;
  final ConfigRemoteDatasource _remoteDatasource;

  ConfigRepositoryImpl(this._localDatasource, this._remoteDatasource);

  @override
  Future<Either<Failure, ShakeReporterConfig>> getConfig() async {
    // Try remote first
    final remoteResult = await _remoteDatasource.getConfig();
    if (remoteResult.isRight()) {
      final config = remoteResult.getOrElse(
        () => ShakeReporterConfig.safeFallback,
      );
      await _localDatasource.saveConfig(config);
      return remoteResult;
    }

    // Fallback to local
    return await _localDatasource.getConfig();
  }
}
