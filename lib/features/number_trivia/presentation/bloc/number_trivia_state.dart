part of 'number_trivia_bloc.dart';

@immutable
abstract class NumberTriviaState extends Equatable {}

class NumberTriviaInitial extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class NumberTriviaLoading extends NumberTriviaState {
  @override
  List<Object> get props => [];
}

class NumberTriviaSuccess extends NumberTriviaState {
  final NumberTrivia numberTrivia;

  NumberTriviaSuccess({@required this.numberTrivia});

  @override
  List<Object> get props => [numberTrivia];
}

class NumberTriviaError extends NumberTriviaState {
  final String error;

  NumberTriviaError({@required this.error});

  @override
  List<Object> get props => [error];
}
