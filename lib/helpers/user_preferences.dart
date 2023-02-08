import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferences {
  static SharedPreferences? _preferences;

  static Future init() async {
    _preferences = await SharedPreferences.getInstance();
    // _preferences!.clear();
  }

  // to hold timestamps for cms.
  // cmId_kcId_timestamp
  static const String _kcTimeStamp = "kcTs";
  static const String _cmTs = "cmTs";
  static const String _hasAgreedToTermsOfService = "hasAgreedToTermsOfService";
  static const String _lastVisitiedKc = "lastVisitiedKc";

  static Future updateCmTimestamp({required String cmId}) async {
    updateLastVisitedCm(cmId: cmId);
    List<String>? cts = await _preferences!.getStringList(_cmTs);
    if (cts != null) {
      bool done = false;
      for (int i = 0; i < cts.length; i++) {
        if (cts[i].substring(0, 21) == cmId + "_") {
          done = true;
          cts[i] = cmId + '_' + Timestamp.now().toDate().toIso8601String();
          break;
        }
      }
      if (!done) {
        cts.add(cmId + '_' + Timestamp.now().toDate().toIso8601String());
      }
      _preferences!.setStringList(_cmTs, cts);
    } else {
      _preferences!.setStringList(
          _cmTs, [cmId + '_' + Timestamp.now().toDate().toIso8601String()]);
    }
  }

  static Future<List<String>?> getCmTimestamps() async {
    // info will be the cmId
    // lets get back where starting substring is equal to info.
    return _preferences!.getStringList(_cmTs) ?? null;
  }

  // update Last visited kc
  static updateLastVisitedKc(String kcId) =>  _preferences!.setString(_lastVisitiedKc, kcId);
  

  static Future<String?> getLastVisitedKc() async => await _preferences!.getString(_lastVisitiedKc);

  static Future updateKcTimeStamp(
      {required String cmId, required String kcId}) async {
    List<String>? kts = await _preferences!.getStringList(_kcTimeStamp + cmId);
    if (kts != null) {
      bool done = false;
      for (int i = 0; i < kts.length; i++) {
        if (kts[i].substring(0, 21) == kcId + "_") {
          done = true;
          kts[i] = kcId + "_" + Timestamp.now().toDate().toIso8601String();
          break;
        }
      }
      if (!done) {
        kts.add(kcId + "_" + Timestamp.now().toDate().toIso8601String());
      }

      _preferences!.setStringList(_kcTimeStamp + cmId, kts);
    } else {
      _preferences!.setStringList(_kcTimeStamp + cmId,
          [kcId + "_" + Timestamp.now().toDate().toIso8601String()]);
    }
    updateLastVisitedKc(kcId);
  }

  static Future<List<String>?> getKcTimeStamps(String cmId) async {
    // info will be the cmId
    // lets get back where starting substring is equal to info.
    return _preferences!.getStringList(_kcTimeStamp + cmId) ?? null;
  }

  static bool getHasAggredToTermsOfService() {
    return _preferences!.getBool(_hasAgreedToTermsOfService) ?? false;
  }

  static setAgreeToTermsOfService() {
    _preferences!.setBool(_hasAgreedToTermsOfService, true);
  }

  static Future<void> updateLastVisitedCm({required String cmId}) async {
    await _preferences!.remove("lastVisitedCm");
    _preferences!.setString("lastVisitedCm", cmId);
  }

  static Future<String?> getLastVisitedCm() async {
    return await _preferences!.getString("lastVisitedCm");
  }

  static clearLastVisitedCm() async {
    _preferences!.remove("lastVisitedCm");
  }

  // blocking and reporting ugc
  static Future<Set<String>> addToBlockedUIDS({required String uid}) async {
    List<String>? uids = await _preferences!.getStringList("blockedUIDS");
    bool isBlocked = false;

    log(uids.toString());

    if (uids != null) {
      if (uids.contains(uid)) {
        isBlocked = true;
      }
      log("isBlocked: " + isBlocked.toString());

      if (isBlocked)
        uids.remove(uid);
      else
        uids.add(uid);

      log("uids: " + uids.toString());

      // update the local db

      _preferences!.setStringList("blockedUIDS", uids);
    } else {
      _preferences!.setStringList("blockedUIDS", [uid]);
    }

    // if true then user was removed from block list. so update the local SHOW CONTENT
    return uids?.toSet() ?? {};
  }

  static Future<Set<String>> getBlockedUsers() async {
    // get lst of blocked users and return if contains.
    return await _preferences!.getStringList("blockedUIDS")?.toSet() ?? {};
  }
}
