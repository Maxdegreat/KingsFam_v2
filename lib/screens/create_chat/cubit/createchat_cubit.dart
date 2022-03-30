//this cubit has the task of creating a new chat.
// this is the back end for making a chat

import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/chat_model.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'createchat_state.dart';

class CreatechatCubit extends Cubit<CreatechatState> {
  //2 add the dependicies
  final StorageRepository _storageRepository;
  final ChatRepository _chatRepository;
  final UserrRepository _userrRepository;

  CreatechatCubit({
    //3 gen the constructor
    required StorageRepository storageRepository,
    required ChatRepository chatRepository,
    required UserrRepository userrRepository,
  })  : _storageRepository = storageRepository,
        _chatRepository = chatRepository,
        _userrRepository = userrRepository,
        super(CreatechatState.initial()); //1 fix the initial

  // 4 add the onchanged
  void chatAvatarOnChanged(File avatar) {
    emit(state.copyWith(chatAvatar: avatar, status: CreateChatStatus.initial));
  } //ontap avatar state.av will then have a value of avatar on create use repository and write it to doc as the image

  void nameOnChanged(String name) {
    emit(state.copyWith(name: name, status: CreateChatStatus.initial));
  } //textform field onchanged ctx.read().usernameChanged value => name then write to doc

  void userListUpdated(List<String> members) {
    emit(state.copyWith(usersList: members));
  }

  void populateRecentSender(String sender) {
    emit(state.copyWith(recentSender: sender));
  }

  //5 add the submit
  void submit() async {
    print('submit fired \n');
    emit(state.copyWith(status: CreateChatStatus.loading));
    try {
      final avatarImageUrl = await _storageRepository.uploadChatAvatar(
          image: state.chatAvatar!, url: '');
      // the maping of user ids 
      for (String userId in state.usersList) {
        //set selected users = to state.userlist
        state.memberIds.add(userId);

        final user = await _userrRepository.getUserrWithId(userrId: userId);
        Map<String, dynamic> userMap = {
          'username': user.username,
          'email': user.email,
          'token': user.token,
          //'token' : user.token need to add token to user model
        };
        state.memberInfo[userId] = userMap;
        state.readStatus[userId] = false;
      }
      
      final chat = Chat(
          name: state.name,
          imageUrl: avatarImageUrl,
          recentSender: state.recentSender,
          recentMessage: 'made a chat with you',
          searchPram: state.caseSearch,
          date: DateTime.now(),
          memberIds: state
              .memberIds, //within ui code set state.memberid's = to args.members
          memberInfo: state.memberInfo, //
          readStatus: state.readStatus);
      await _chatRepository.createChat(chat: chat);
      emit(state.copyWith(status: CreateChatStatus.success));
    } catch (e) {
      emit(state.copyWith(
          failure:
              Failure(message: 'Something went wrong with making this chat')));
    }
  }
}
