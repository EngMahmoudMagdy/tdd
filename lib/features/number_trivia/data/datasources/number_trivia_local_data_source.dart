import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:number_trivia/core/error/exceptions.dart';
import 'package:number_trivia/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

const CACHED_NUMBER_TRIVIA = 'CACHED_NUMBER_TRIVIA';

abstract class NumberTriviaLocalDataSource {
  Future<NumberTriviaModel> getLastNumberTrivia();

  Future<void> cacheNumberTrivia(NumberTriviaModel numberTriviaModel);
}

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPref;

  NumberTriviaLocalDataSourceImpl({@required this.sharedPref});

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel numberTriviaModel) {
    return sharedPref.setString(
      CACHED_NUMBER_TRIVIA,
      json.encode(numberTriviaModel.toJson()),
    );
  }

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    final jsonString = sharedPref.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null)
      return Future.value(NumberTriviaModel.fromJson(jsonDecode(jsonString)));
    else
      throw CacheException();
  }
}
