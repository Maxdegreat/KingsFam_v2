import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';

part 'snack_time_state.dart';

class SnackTimeCubit extends Cubit<SnackTimeState> {
  SnackTimeCubit() : super(SnackTimeState.initial());
}
