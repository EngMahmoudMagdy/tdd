import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:number_trivia/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:number_trivia/features/number_trivia/domain/repos/number_trivia_repo.dart';
import 'package:number_trivia/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';

class MockNumberTriviaRepo extends Mock implements NumberTriviaRepo {}

void main() {
  MockNumberTriviaRepo mockNumberTriviaRepo;
  GetConcreteNumberTrivia usecase;
  setUp(() {
    mockNumberTriviaRepo = MockNumberTriviaRepo();
    usecase = GetConcreteNumberTrivia(mockNumberTriviaRepo);
  });
  const tNumber = 1;
  final tNumberTrivia = NumberTrivia(text: 'Whatever', number: 1);
  test('should get trivia for the number from the repo', () async {
    when(mockNumberTriviaRepo.getConcreteNumberTrivia(1))
        .thenAnswer((_) async => Right(tNumberTrivia));

    final result = await usecase(Params(number: tNumber));
    expect(result, Right(tNumberTrivia));
    verify(mockNumberTriviaRepo.getConcreteNumberTrivia(tNumber));
    verifyNoMoreInteractions(mockNumberTriviaRepo);
  });
}
