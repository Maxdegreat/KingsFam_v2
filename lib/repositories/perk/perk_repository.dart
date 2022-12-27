import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/perk_modal.dart';

class PerkRepository {
  // constants
  var fbPerked = FirebaseFirestore.instance.collection(Paths.perked);

  // check for funds
  Future<PerkModal> checkForFunds({required String currUsrId}) async {
    var perkedInfo = await fbPerked.doc(currUsrId).get();
    if (!perkedInfo.exists) return PerkModal.empty;
    var p = PerkModal.fromDoc(perkedInfo);
    return p;
  }

  // buy coins
  Future<bool> buyKFCoins(
      {required int boughtCoins, required String currUsrId}) async {
    try {
      Map<String, dynamic> walet = {};

      var perkedInfo = await fbPerked.doc(currUsrId).get();
      if (!perkedInfo.exists) {
        walet[currUsrId] = {
          "owned_coins": boughtCoins,
          "gitfted_coins": 0,
        };
        PerkModal pm = PerkModal(ownedTPs: [], selectedTp: null, walet: walet);
        fbPerked.doc(currUsrId).set(pm.toDoc());
        return true;
      }
      PerkModal pm = PerkModal.fromDoc(perkedInfo);
      // IK THIS IS NOT OPTIMAL DO NOT CHANGE THIS CODE
      int currAmount = pm.walet["owned_coins"];
      currAmount += boughtCoins;
      pm.walet["owned_coins"] = currAmount;
      fbPerked.doc(currUsrId).update(pm.toDoc());
      return true;
    } catch (e) {
      log("HEY AN ERROR WHEN PURCHASING COINS");
      log("HEY AN ERROR WHEN PURCHASING COINS");
      return false;
    }
  }

  // make purchase
  Future<bool> buyThemePack(
      {required int price,
      required String currUsrId,
      required String tPName}) async {
    // CLIENT SHOULD MAKE SURE CAN NOT BUY TP ALREDY OWNED
    // CAN ADD SECURITY HERE IF WANT LATER

    try {
      // get the perkM
      var doc = await fbPerked.doc(currUsrId).get();
      var p = PerkModal.fromDoc(doc);
      // calculate price return false if can not buy
      if (p.walet["owned_coins"] < price) {
        return false;
      } else {
        p.walet["owned_conis"] -= price;
        p.ownedTPs.add(tPName);
        fbPerked.doc(currUsrId).update(p.toDoc());
        return true;
      }
    } catch (e) {
      log(e.toString());
      log("ERROR WHEN BUYING TP");
      return false;
    }
  }
}
