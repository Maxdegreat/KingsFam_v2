import 'dart:async';


import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/blocs/auth/auth_bloc.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/church_kingscord_model.dart';
import 'package:kingsfam/models/failure_model.dart';
import 'package:kingsfam/models/message_model.dart';
import 'package:kingsfam/models/user_model.dart';
import 'package:kingsfam/repositories/church/church_repository.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/kingscord_repository.dart';

part 'says_state.dart';

class SaysCubit extends Cubit<SaysState> {
  KingsCordRepository _kingsCordRepository;
  AuthBloc _authBloc;
  ChurchRepository _churchRepository;
  StreamSubscription<List<Future<Message?>>>? _msgStreamSubscription;

  SaysCubit({
    required KingsCordRepository kingsCordRepository,
    required AuthBloc authBloc,
    required ChurchRepository churchRepository,
  })  : _kingsCordRepository = kingsCordRepository,
        _authBloc = authBloc,
        _churchRepository = churchRepository,
        super(SaysState.inital());

  pagMsgs({
      required String cmId,
      required String kcId,
      required int limit,
      String? lastPostId}) {
    if (state.msgs.isEmpty) {
      _msgStreamSubscription?.cancel();
      _msgStreamSubscription = _churchRepository
          .getMsgStream(cmId: cmId, kcId: kcId, limit: limit, lastPostDoc: null)
          .listen((msgs) async {
        List<Message> allMsgs = [];
        for (int i = 0; i < msgs.length; i++) {
          Message? m = await msgs[i];
          if (m != null) {
            if (m.replyMsg != null) {
              m.copyWith(replyMsg: m);
            }
            allMsgs.add(m);
          }
        }
      });
    } else {
      FirebaseFirestore.instance
          .collection(Paths.church)
          .doc(cmId)
          .collection(Paths.kingsCord)
          .doc(kcId)
          .collection(Paths.messages)
          .doc(lastPostId)
          .get()
        ..then((lastDoc) {
          if (state.msgs.isEmpty) {
            _msgStreamSubscription?.cancel();
            _msgStreamSubscription = _churchRepository
                .getMsgStream(
                    cmId: cmId, kcId: kcId, limit: limit, lastPostDoc: lastDoc)
                .listen((msgs) async {
              List<Message> allMsgs = [];
              for (int i = 0; i < msgs.length; i++) {
                Message? m = await msgs[i];
                if (m != null) {
                  if (m.replyMsg != null) {
                    m.copyWith(replyMsg: m);
                  }
                  allMsgs.add(m);
                }
              }
            });
          }
        });
    }
  }

  onIsTyping(bool value) => state.copyWith(isTyping: value);

  onSendMsgs({
    required String cmId,
    required String kcId,
    required String msgsTxt,
    required Map<String, dynamic> mentionedInfo,
    required String cmTitle,
    required KingsCord kc,
    required String currUsername,
    required Message? reply,
    Map<String, dynamic>? metadata = const {},
  }) {
    // TODO:

    emit(state.copyWith(
      msgs: state.msgs,
      isTyping: false,
      replying: false,
      replyMessage: null,
    ));
  }

  onShowBottomTab(value) => state.copyWith(showHidden: value);
}
