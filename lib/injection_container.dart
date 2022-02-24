
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:number_trivia/core/network/network_info.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:number_trivia/features/number_trivia/data/repos/number_trivia_repo_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/network/trivia_interceptor.dart';
import 'core/utils/input_converter.dart';
import 'features/number_trivia/domain/repos/number_trivia_repo.dart';
import 'features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia
  //Bloc
  sl.registerFactory(
    () => NumberTriviaBloc(
      getConcreteNumberTrivia: sl(),
      getRandomNumberTrivia: sl(),
      inputConverter: sl(),
    ),
  );
  //Use cases
  sl.registerLazySingleton(
    () => GetConcreteNumberTrivia(sl()),
  );
  sl.registerLazySingleton(
    () => GetRandomNumberTrivia(sl()),
  );
  // Repository
  sl.registerLazySingleton<NumberTriviaRepo>(
    () => NumberTriviaRepoImpl(
        remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );

  // Data Sources
  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
      () => NumberTriviaRemoteDataSourceImpl(sl()));

  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
      () => NumberTriviaLocalDataSourceImpl(sharedPref: sl()));

  //! Core
  sl.registerLazySingleton(
    () => InputConverter(),
  );

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() =>
      HttpClientWithInterceptor.build(interceptors: [TriviaInterceptor()]));
  sl.registerLazySingleton(() => DataConnectionChecker());
}
