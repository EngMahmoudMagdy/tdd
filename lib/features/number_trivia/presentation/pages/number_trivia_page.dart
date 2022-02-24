import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:number_trivia/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';

import '../../../../injection_container.dart';
import '../widgets/widgets.dart';

class NumberTriviaPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Trivia'),
      ),
      body: SingleChildScrollView(
        child: buildBody(context),
      ),
    );
  }

  DateTime startedTime = DateTime.now();
  DateTime endedTime = DateTime.now();

  buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NumberTriviaBloc>(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: <Widget>[
              SizedBox(height: 10),
              // Top half
              BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                builder: (context, state) {
                  switch (state.runtimeType) {
                    case NumberTriviaError:
                      print('Error');
                      return MessageDisplay(
                        message: (state as NumberTriviaError).error,
                      );
                    case NumberTriviaLoading:
                      print('Loading');
                      startedTime = DateTime.now();
                      endedTime = DateTime.now();
                      return LoadingWidget();
                    case NumberTriviaSuccess:
                      endedTime = DateTime.now();
                      print('success');
                      print(
                          'time since triggered  ${endedTime.millisecondsSinceEpoch - startedTime.millisecondsSinceEpoch}');
                      return TriviaDisplay(
                        numberTrivia:
                            (state as NumberTriviaSuccess).numberTrivia,
                      );
                    default:
                      print('initial');
                      return MessageDisplay(
                        message: 'Start searching!',
                      );
                  }
                  // We're going to also check for the other states
                },
              ),
              SizedBox(height: 20),
              // Bottom half
              TriviaControls(),
            ],
          ),
        ),
      ),
    );
  }
}
