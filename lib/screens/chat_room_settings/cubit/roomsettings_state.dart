part of 'roomsettings_cubit.dart';

enum RoomSettingStatus { initial, loading, success, error }

class RoomsettingsState extends Equatable {
  final List<Userr> members;
  final List<String> memberIds;
  final RoomSettingStatus status;
  final String name;
  final File? chatAvatar;
  final Failure failure;

  const RoomsettingsState({
    required this.memberIds,
    required this.members,
    required this.status,
    required this.name,
    required this.chatAvatar,
    required this.failure
  });

  @override
  List<Object?> get props => [memberIds, status, memberIds, chatAvatar, name, failure];

  RoomsettingsState copyWith(
      {List<Userr>? members,
      RoomSettingStatus? status,
      List<String>? memberIds,
      String? name,
      File? chatAvatar,
      Failure? failure
    }) {
    return RoomsettingsState(
      failure: failure ?? this.failure,
        memberIds: memberIds ?? this.memberIds,
        members: members ?? this.members,
        status: status ?? this.status,
        name: name ?? this.name,
        chatAvatar: chatAvatar ?? this.chatAvatar);
  }

  factory RoomsettingsState.initial() {
    return RoomsettingsState(
      failure: Failure(),
        memberIds: [],
        members: [],
        status: RoomSettingStatus.initial,
        name: '',
        chatAvatar: null);
  }
}
