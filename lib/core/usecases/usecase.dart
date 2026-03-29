import 'package:equatable/equatable.dart';

abstract class UseCase<TResult, Params> {
  Future<TResult> call(Params params);
}

class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => const [];
}
