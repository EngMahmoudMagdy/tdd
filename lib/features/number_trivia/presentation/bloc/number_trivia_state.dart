part of 'number_trivia_bloc.dart';

@immutable
abstract class NumberTriviaState {}

class NumberTriviaInitial extends NumberTriviaState {}

class NumberTriviaLoading extends NumberTriviaState {}

class NumberTriviaSuccess extends NumberTriviaState {
  final NumberTrivia numberTrivia;

  NumberTriviaSuccess({@required this.numberTrivia});
}

class NumberTriviaError extends NumberTriviaState {
  final String error;

  NumberTriviaError({@required this.error});
}
