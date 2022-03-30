import 'package:flutter_bloc/flutter_bloc.dart';

class SimpleBlocObserver extends BlocObserver {
  //interface for observing the bloc patterns
  
  @override
  void onEvent(Bloc bloc, Object? event) {
    print(event); //fire when an event is fired
    super.onEvent(bloc, event);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    print(transition); //when 
    super.onTransition(bloc, transition);
  }

  @override
  Future<void> onError(BlocBase bloc, Object error, StackTrace stackTrace) async {
    print(error);
    super.onError(bloc, error, stackTrace);
  }
}
