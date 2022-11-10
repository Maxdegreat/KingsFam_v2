import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/event/event_repository.dart';

part 'event_state.dart';

class EventCubit extends Cubit<EventState> {
  final EventRepository _eventRepository;
  final AuthBloc _authBloc;
  EventCubit({
    required EventRepository eventRepository,
    required AuthBloc authBloc
  }) : _eventRepository = eventRepository, 
      _authBloc = authBloc,  
      super(EventState.inital());

    
}
