import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tagaddod_shaker/src/core/error/failures.dart';
import '../../../domain/entities/shake_reporter_config.dart';
import '../../models/shake_reporter_config_model.dart';

abstract class ReporterConfigLocalDatasource {
  Future<Either<Failure, ShakeReporterConfig>> getConfig();
  Future<Either<Failure, void>> saveConfig(ShakeReporterConfig config);
}

class ReporterConfigLocalDatasourceImpl
    implements ReporterConfigLocalDatasource {
  final SharedPreferences prefs;
  static const String _configKey = 'shake_reporter_config';

  ReporterConfigLocalDatasourceImpl(this.prefs);

  @override
  Future<Either<Failure, ShakeReporterConfig>> getConfig() async {
    try {
      final jsonString = prefs.getString(_configKey);
      if (jsonString != null) {
        final model = ShakeReporterConfigModel.fromJson(
          jsonDecode(jsonString) as Map<String, dynamic>,
        );
        return Right(model.toEntity());
      } else {
        return const Right(ShakeReporterConfig.safeFallback);
      }
    } catch (e) {
      return Left(CacheFailure('Failed to load config: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveConfig(ShakeReporterConfig config) async {
    try {
      final model = ShakeReporterConfigModel.fromEntity(config);
      final jsonString = jsonEncode(model.toJson());
      await prefs.setString(_configKey, jsonString);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to save config: $e'));
    }
  }
}
