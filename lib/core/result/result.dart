import '../errors/app_failure.dart';

class Result<T> {
  final T? data;
  final AppFailure? failure;

  const Result._({this.data, this.failure});

  bool get isSuccess => failure == null;
  bool get isFailure => failure != null;

  static Result<T> success<T>(T data) => Result<T>._(data: data);
  static Result<T> error<T>(String message, {Object? cause}) =>
      Result<T>._(failure: AppFailure(message, cause: cause));
}
