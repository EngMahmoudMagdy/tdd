import 'dart:convert';

import 'package:http_interceptor/http_client_with_interceptor.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaRemoteDataSource {
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  final HttpClientWithInterceptor httpClient;

  NumberTriviaRemoteDataSourceImpl(this.httpClient);

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async =>
      _getTrivia('http://numbersapi.com/$number?json');

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async =>
      _getTrivia('http://numbersapi.com/random');

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
