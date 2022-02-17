import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../fixtures/fixture_reader.dart';

class MockSharedPref extends Mock implements SharedPreferences {}

void main() {
  NumberTriviaLocalDataSourceImpl dataSource;
  MockSharedPref mockSharedPref;

  setUp(() {
    mockSharedPref = MockSharedPref();
    dataSource = NumberTriviaLocalDataSourceImpl(sharedPref: mockSharedPref);
  });

  group('getLastNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(jsonDecode(fixture('trivia_cached.json')));
    test(
        'should return NumberTrivia from sharedPref when there is one in cache',
        () async {
      when(mockSharedPref.getString(any))
          .thenReturn(fixture('trivia_cached.json'));
      final result = await dataSource.getLastNumberTrivia();
      verify(mockSharedPref.getString('CACHED_NUMBER_TRIVIA'));
      expect(result, equals(tNumberTriviaModel));
    });
    test('should throw a CacheException when there is not a cached value', () {
      // arrange
      when(mockSharedPref.getString(any)).thenReturn(null);
      // act
      // Not calling the method here, just storing it inside a call variable
      final call = dataSource.getLastNumberTrivia;
      // assert
      // Calling the method happens from a higher-order function passed.
      // This is needed to test if calling a method throws an exception.
      expect(() => call(), throwsA(isA<CacheException>()));
    });
  });
  group('cacheNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel(number: 1, text: 'test trivia');

    test('should call SharedPreferences to cache the data', () {
      // act
      dataSource.cacheNumberTrivia(tNumberTriviaModel);
      // assert
      final expectedJsonString = json.encode(tNumberTriviaModel.toJson());
      verify(mockSharedPref.setString(
        CACHED_NUMBER_TRIVIA,
        expectedJsonString,
      ));
    });
  });
}
