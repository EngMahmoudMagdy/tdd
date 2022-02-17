import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/core/error/failures.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/data/repos/number_trivia_repo_impl.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

class MockNumberTriviaRemoteDataSource extends Mock
    implements NumberTriviaRemoteDataSource {}

class MockNumberTriviaLocalDataSource extends Mock
    implements NumberTriviaLocalDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

void main() {
  NumberTriviaRepoImpl repo;
  MockNumberTriviaRemoteDataSource mockNumberTriviaRemoteDataSource;
  MockNumberTriviaLocalDataSource mockNumberTriviaLocalDataSource;
  MockNetworkInfo mockNetworkInfo;

  // DATA FOR THE MOCKS AND ASSERTIONS
  // We'll use these three variables throughout all the tests
  final tNumber = 1;
  final tNumberTriviaModel =
      NumberTriviaModel(number: tNumber, text: 'test trivia');
  final NumberTrivia tNumberTrivia = tNumberTriviaModel;

  setUp(() {
    mockNumberTriviaRemoteDataSource = MockNumberTriviaRemoteDataSource();
    mockNumberTriviaLocalDataSource = MockNumberTriviaLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repo = NumberTriviaRepoImpl(
        remoteDataSource: mockNumberTriviaRemoteDataSource,
        localDataSource: mockNumberTriviaLocalDataSource,
        networkInfo: mockNetworkInfo);
  });

  void runTestsOnline(Function body) {
    group('device is online', () {
      // This setUp applies only to the 'device is online' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      });
      body();
    });
  }

  void runTestsOffline(Function body) {
    group('device is offline', () {
      // This setUp applies only to the 'device is offline' group
      setUp(() {
        when(mockNetworkInfo.isConnected).thenAnswer((_) async => false);
      });
      body();
    });
  }

  group('getConcreteNumberTrivia', () {
    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repo.getConcreteNumberTrivia(tNumber);
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource
                  .getConcreteNumberTrivia(tNumber))
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repo.getConcreteNumberTrivia(tNumber);
          // assert
          
          verify(mockNumberTriviaRemoteDataSource
              .getConcreteNumberTrivia(tNumber));
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
    });

    runTestsOffline(() {
      test('should return data from local if it was cached', () async {
        //arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        //act
        final result = await repo.getConcreteNumberTrivia(tNumber);

        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return failure if there is no data cached', () async {
        //arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repo.getConcreteNumberTrivia(tNumber);

        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });

  group('getRandomNumberTrivia', () {
    test('should check if the device is online', () {
      //arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      // act
      repo.getRandomNumberTrivia();
      // assert
      verify(mockNetworkInfo.isConnected);
    });

    runTestsOnline(() {
      test(
        'should return remote data when the call to remote data source is successful',
        () async {
          // arrange
          when(mockNumberTriviaRemoteDataSource
                  .getRandomNumberTrivia())
              .thenAnswer((_) async => tNumberTriviaModel);
          // act
          final result = await repo.getRandomNumberTrivia();
          // assert
          
          verify(mockNumberTriviaRemoteDataSource
              .getRandomNumberTrivia());
          expect(result, equals(Right(tNumberTrivia)));
        },
      );
    });

    runTestsOffline(() {
      test('should return data from local if it was cached', () async {
        //arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenAnswer((realInvocation) async => tNumberTriviaModel);
        //act
        final result = await repo.getRandomNumberTrivia();

        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Right(tNumberTrivia)));
      });

      test('should return failure if there is no data cached', () async {
        //arrange
        when(mockNumberTriviaLocalDataSource.getLastNumberTrivia())
            .thenThrow(CacheException());
        //act
        final result = await repo.getRandomNumberTrivia();

        //assert
        verifyZeroInteractions(mockNumberTriviaRemoteDataSource);
        verify(mockNumberTriviaLocalDataSource.getLastNumberTrivia());
        expect(result, equals(Left(CacheFailure())));
      });
    });
  });
}
