import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/repositories/church_kings_cord_repository/base_kingscord_repository.dart';

class KingsCordRepository extends BaseKingsCordRepository {
  //class data
  final FirebaseFirestore _firebaseFirestore;
  //class constructor
  KingsCordRepository({FirebaseFirestore? firebaseFirestore})
      : _firebaseFirestore = firebaseFirestore ?? FirebaseFirestore.instance;
  //methods

  //create a KingsCord
  @override
  Future<void> createKingsCord(
      {required Church church, required KingsCord kingsCord}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(church.id)
        .collection(Paths.kingsCord)
        .add(kingsCord.toDoc());
  }

  //sneding a message
  @override
  Future<void> sendMsgTxt(
      {required String churchId,
      required String kingsCordId,
      required Message message,
      required String senderId}) async {
    _firebaseFirestore
        .collection(Paths.church)
        .doc(churchId)
        .collection(Paths.kingsCord)
        .doc(kingsCordId)
        .collection(Paths.messages)
        .add(message.ToDoc(senderId: senderId));
  }

}
