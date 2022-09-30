import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'perk_state.dart';

class PerkCubit extends Cubit<PerkState> {
  PerkCubit() : super(PerkState.initial());
}
