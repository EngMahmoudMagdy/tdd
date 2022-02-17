import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockHttpClient extends Mock implements Client {}

void main() {
  MockHttpClient mockHttpClient;
  NumberTriviaRemoteDataSourceImpl numberTriviaRemoteDataSourceImpl;
  setUp(() {
    mockHttpClient = MockHttpClient();
    numberTriviaRemoteDataSourceImpl =
        NumberTriviaRemoteDataSourceImpl(mockHttpClient);
  });

  void setUpMockHttpClientSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => Response('Not found', 404));
  }

  group('getConcreteNumberTrivia', () {
    final tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));

    test(
        'should preform a GET request to get Concrete Number Trivia for a specific number on URL when connection is ok',
        () async {
      setUpMockHttpClientSuccess200();
      numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
      verify(mockHttpClient.get(
        'numbersapi.com/$tNumber?json',
        headers: {'Content-type': 'application/json'},
      ));
    });

    test('should return a NumberTrivia when response code is 200', () async {
      setUpMockHttpClientSuccess200();
      final result = await numberTriviaRemoteDataSourceImpl
          .getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });
    test('should return a NumberTrivia when response code is 404', () async {
      setUpMockHttpClientFailure404();
      final call =
          numberTriviaRemoteDataSourceImpl.getConcreteNumberTrivia(tNumber);
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    test(
        'should preform a GET request for getting a random number on URL when connection is ok',
        () async {
      setUpMockHttpClientSuccess200();
      numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
      verify(mockHttpClient.get(
        'numbersapi.com/random',
        headers: {'Content-type': 'application/json'},
      ));
    });

    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia.json')));
    test('should return a NumberTrivia when response code is 200', () async {
      setUpMockHttpClientSuccess200();
      final result =
          await numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
    });
    test('should return a NumberTrivia when response code is 404', () async {
      setUpMockHttpClientFailure404();
      final call = numberTriviaRemoteDataSourceImpl.getRandomNumberTrivia();
      expect(() => call, throwsA(isA<ServerException>()));
    });
  });
}
