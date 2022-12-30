
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

    static Future updateKcTimeStamp({required String cmId, required String kcId}) async {
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
        _preferences!.setStringList(_kcTimeStamp + cmId, [kcId + "_" + Timestamp.now().toDate().toIso8601String()]);
      }
    } 

    static Future<List<String>?> getKcTimeStamps(String cmId) async {
      // info will be the cmId
      // lets get back where starting substring is equal to info.
      return _preferences!.getStringList(_kcTimeStamp + cmId) ?? null;
    }

    static Future<void> updateLastVisitedCm({required String cmId}) async {
      await _preferences!.remove("lastVisitedCm");
      _preferences!.setString("lastVisitedCm", cmId);
    }

    static getLastVisitedCm() async {
      return await _preferences!.getString("lastVisitedCm");
    }

}