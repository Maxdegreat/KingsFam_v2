//

// ignore_for_file: unused_local_variable


import 'package:kingsfam/models/models.dart';

abstract class BaseKingsCordRepository {
  // method to create a KingsCord
  Future<void> createKingsCord(
      {required Church church, required KingsCord kingsCord});

  // method to send a message
  Future<void> sendMsgTxt(
      {required String churchId,
      required String kingsCordId,
      required Message message,
      required String senderId});

  
}
