import 'dart:convert';

import 'package:http/http.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final Client httpClient;

  NumberTriviaRemoteDataSourceImpl(this.httpClient);

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async =>
      _getTrivia('numbersapi.com/$number?json');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async =>
      _getTrivia('numbersapi.com/random');

  Future<NumberTriviaModel> _getTrivia(String url) async {
    final response = await httpClient.get(
      url,
      headers: {'Content-type': 'application/json'},
    );
    if (response.statusCode == 200) {
      return NumberTriviaModel.fromJson(jsonDecode(response.body));
    }
    throw ServerException();
  }
}
