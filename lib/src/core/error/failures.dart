import 'package:equatable/equatable.dart';

/// Base class for all failures in shake reporter package.
abstract class Failure extends Equatable {
  const Failure(this.message, {this.code, this.title});

  final String message;
  final String? code;
  final String? title;

  @override
  List<Object?> get props => [message, code, title];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class AppExceptionFailure extends Failure {
  const AppExceptionFailure(super.message, {super.title});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ApiFailure extends Failure {
  ApiFailure(super.message, {required this.statusCode})
    : super(code: statusCode.toString());

  final int statusCode;

  @override
  List<Object?> get props => [message, code, statusCode];
}

class InvalidDataFailure extends Failure {
  const InvalidDataFailure(super.message);
}
