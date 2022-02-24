import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/utils/input_converter.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });
  test('initialState should be Empty', () {
    // assert
    expect(bloc.initialState, equals(NumberTriviaInitial()));
  });
  group('GetTriviaForConcreteNumber', () {
    // The event takes in a String
    final tNumberString = '1';
    // This is the successful output of the InputConverter
    final tNumberParsed = int.parse(tNumberString);
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Right(tNumberParsed));
    test(
      'should call the InputConverter to validate and convert the string to an unsigned integer',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockInputConverter.stringToUnsignedInteger(any));
        // assert
        verify(mockInputConverter.stringToUnsignedInteger(tNumberString));
      },
    );
    test(
      'should emit error when input is invalid',
      () async {
        // arrange
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(Left(InvalidInputFailure()));
        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaError(error: INVALID_INPUT_FAILURE_MESSAGE)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
    test(
      'should get data from the concrete use case',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        await untilCalled(mockGetConcreteNumberTrivia(any));
        // assert later
        verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
      },
    );

    test(
      'should emit Loading and Success when input is valid',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaSuccess(numberTrivia: tNumberTrivia)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
    test(
      'should emit Loading and Error from server',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaError(error: SERVER_FAILURE_MESSAGE)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
    test(
      'should emit Loading and Error from cache',
      () async {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        //act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaError(error: CACHE_FAILURE_MESSAGE)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
  });

  group('GetTriviaForRandomNumber', () {
    // NumberTrivia instance is needed too, of course
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaForRandomNumber());
        await untilCalled(mockGetRandomNumberTrivia(any));
        // assert later
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit Loading and Success with random number',
      () async {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Right(tNumberTrivia));
        //act
        bloc.add(GetTriviaForRandomNumber());
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaSuccess(numberTrivia: tNumberTrivia)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
    test(
      'should emit Loading and Error from server for random',
      () async {
        // arrange
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        //act
        bloc.add(GetTriviaForRandomNumber());
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaError(error: SERVER_FAILURE_MESSAGE)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
    test(
      'should emit Loading and Error from cache for random',
      () async {
        // arrange
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));
        //act
        bloc.add(GetTriviaForRandomNumber());
        // assert later
        final expected = [
          NumberTriviaInitial(),
          NumberTriviaLoading(),
          NumberTriviaError(error: CACHE_FAILURE_MESSAGE)
        ];
        expectLater(bloc, emitsInOrder(expected));
      },
    );
  });
}
