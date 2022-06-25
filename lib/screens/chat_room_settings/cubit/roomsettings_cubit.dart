import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/repositories.dart';

part 'roomsettings_state.dart';

class RoomsettingsCubit extends Cubit<RoomsettingsState> {
  final ChatRepository _chatRepository;
  final UserrRepository _userrRepository;
  final StorageRepository _storageRepository;
  RoomsettingsCubit(
      {required StorageRepository storageRepository,
      required ChatRepository chatRepository,
      required UserrRepository userrRepository})
      : _chatRepository = chatRepository,
        _userrRepository = userrRepository,
        _storageRepository = storageRepository,
        super(RoomsettingsState.initial());

  void onNameChanged(String value) {
    emit(state.copyWith(name: value, status: RoomSettingStatus.initial));
  }

  void onAvatarChanged(File? value) {
    emit(state.copyWith(chatAvatar: value, status: RoomSettingStatus.initial));
  }

  void submit(String chatId) async {
    emit(state.copyWith(status: RoomSettingStatus.loading));
    try {
      final Chat? chat = await _chatRepository.getChatWithId(chatId: chatId);

      if (chat != null) {
        String? avatarUrl = chat.imageUrl;
        if (state.chatAvatar != null && chat.imageUrl != null) {
          avatarUrl = await _storageRepository.uploadChatAvatar(image: state.chatAvatar!, url: chat.imageUrl!);
        }
        var chatName = chat.chatName;
        if (state.name.isNotEmpty) {
          chatName = state.name;
        }

        Chat updatedChat = chat.copyWith(chatName: chatName, imageUrl: avatarUrl);

        await _chatRepository.updateChat(chat: updatedChat);
        emit(state.copyWith(status: RoomSettingStatus.success));
      }
    } catch (err) {
      emit(state.copyWith(
          failure: Failure(
              message: /*'hmm something went wrong, please try again'*/ '$err'),
          status: RoomSettingStatus.error));
    }
  }

  void memberList(List<String> ids, int chatIdsLength) async {
    //pass list of ids with foreach and add each user to list of members
    //emit state.copyWith List<members> add members
    List<Userr> members = [];

    Future<String> membersComplete() async {
      for (int i = 0; i < chatIdsLength; i++) {
        Userr user = await _userrRepository.getUserrWithId(userrId: ids[i]);
        members.add(user);
        print('in func');
      }
      return "Success";
    }

    await membersComplete();
    print("member 0 in func ${members[0].username}");
    emit(state.copyWith(members: members, status: RoomSettingStatus.initial));
  }
  //print("chat id length " + chatIdsLength.toString());
}
