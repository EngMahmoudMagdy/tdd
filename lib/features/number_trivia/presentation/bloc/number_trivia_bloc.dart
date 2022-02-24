import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/utils/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';

part 'number_trivia_state.dart';

const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero.';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;

  NumberTriviaBloc(
      {@required GetConcreteNumberTrivia getConcreteNumberTrivia,
      @required GetRandomNumberTrivia getRandomNumberTrivia,
      @required this.inputConverter})
      : assert(getConcreteNumberTrivia != null),
        assert(getRandomNumberTrivia != null),
        assert(inputConverter != null),
        this.getConcreteNumberTrivia = getConcreteNumberTrivia,
        this.getRandomNumberTrivia = getRandomNumberTrivia;

  @override
  NumberTriviaState get initialState => NumberTriviaInitial();

  @override
  Stream<NumberTriviaState> mapEventToState(NumberTriviaEvent event) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInteger(event.numberString);
      yield* inputEither.fold(
        (failure) async* {
          yield NumberTriviaError(error: INVALID_INPUT_FAILURE_MESSAGE);
        },
        (integer) async* {
          yield NumberTriviaLoading();
          final failureOrTrivia = await getConcreteNumberTrivia(
            Params(number: integer),
          );
          yield* _startLoadingData(failureOrTrivia);
        },
      );
    }
    if (event is GetTriviaForRandomNumber) {
      yield NumberTriviaLoading();
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      yield* _startLoadingData(failureOrTrivia);
    }
  }

  Stream<NumberTriviaState> _startLoadingData(
      Either<Failure, NumberTrivia> failureOrTrivia) async* {
    yield failureOrTrivia.fold(
      (failure) => NumberTriviaError(error: _mapFailureToError(failure)),
      (trivia) => NumberTriviaSuccess(numberTrivia: trivia),
    );
  }

  String _mapFailureToError(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'unexpected error';
    }
  }
}
