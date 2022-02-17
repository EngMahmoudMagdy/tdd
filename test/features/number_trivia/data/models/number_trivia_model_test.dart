import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';

import '../../../../fixtures/fixture_reader.dart';

void main() {
  final tNumberTriviaModel = NumberTriviaModel(
      number: 1,
      text:
          '1e+120 is the Shannon number, an estimation of the game-tree complexity of chess.');

  test('should be a subclass of NT entity', () async {
    expect(tNumberTriviaModel, isA<NumberTrivia>());
  });

  group('fromJson', () {
    test('should return a valid model when the JSON number is an integer',
        () async {
      final Map<String, dynamic> jsonMap = jsonDecode(fixture('trivia.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, tNumberTriviaModel);
    });
    test('should return a valid model when the JSON number is an integer',
        () async {
      final Map<String, dynamic> jsonMap =
          jsonDecode(fixture('trivia_double.json'));
      final result = NumberTriviaModel.fromJson(jsonMap);
      expect(result, tNumberTriviaModel);
    });
  });

  group('toJson', () {
    test('should return a JSON map containing the proper data', () async {
      final result = tNumberTriviaModel.toJson();
      final expectdMap = {
        "text":
            "1e+120 is the Shannon number, an estimation of the game-tree complexity of chess.",
        "number": 1
      };
      expect(result, expectdMap);
    });
  });
}
