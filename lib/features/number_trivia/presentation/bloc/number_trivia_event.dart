part of 'number_trivia_bloc.dart';

@immutable
abstract class NumberTriviaEvent extends Equatable {
  NumberTriviaEvent([List props = const <dynamic>[]]);
}

class GetTriviaForConcreteNumber implements NumberTriviaEvent {
  final String numberString;

  GetTriviaForConcreteNumber(this.numberString);

  @override
  List<Object> get props => [numberString];

  @override
  bool get stringify => true;
}

class GetTriviaForRandomNumber implements NumberTriviaEvent {
  @override
  List<Object> get props => [];

  @override
  bool get stringify => true;
}
