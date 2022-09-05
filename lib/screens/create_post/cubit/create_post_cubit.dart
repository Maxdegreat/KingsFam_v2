import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'create_post_state.dart';

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit() : super(CreatePostState.inital());

  void updateImgF(File f) => emit(state.copyWith(imgF: f));
  void updateVidF(File f) => emit(state.copyWith(vidF: f));
  
}
