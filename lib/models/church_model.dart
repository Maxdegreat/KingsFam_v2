import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:kingsfam/config/cm_privacy.dart';
import 'package:kingsfam/config/cm_type.dart';
import 'package:kingsfam/config/paths.dart';
import 'package:kingsfam/models/models.dart';
import 'package:kingsfam/roles/role_types.dart';

class Church extends Equatable {
  //1 make the church class data
  final String? id;
  final String name;
  final String cmPrivacy;
  final String location;
  final List<String>? hashTags;
  final String imageUrl;
  final String about;
  final List<String> searchPram;
  final Map<Userr, dynamic> members;
  final List<String> events;
  final int? size;
  final Map<String, List<dynamic>>? permissions;
  final Timestamp recentMsgTime;
  final int boosted; // 0 none 1 basic, 2 if I ever add more versions
  final String themePack;
  final bool? readStatus;
  final List<String>? badges;
  // 2 gen the constructor
  Church({
    required this.searchPram,
    this.id,
    required this.cmPrivacy,
    required this.name,
    required this.location,
    required this.imageUrl,
    this.hashTags,
    this.permissions,
    required this.members,
    required this.events,
    required this.about,
    required this.recentMsgTime,
    required this.boosted,
    required this.themePack,
    this.badges,
    this.size,
    this.readStatus,
  });
  // 3 make the props
  @override
  List<Object?> get props => [
        id,
        searchPram,
        name,
        location,
        cmPrivacy,
        hashTags,
        imageUrl,
        about,
        permissions,
        members,
        events,
        recentMsgTime,
        boosted,
        themePack,
        size,
        badges,
        readStatus,
      ];
  //generate the copy with
  Church copyWith({
    String? id,
    List<String>? searchPram,
    List<String>? hashTags,
    String? name,
    String? location,
    String? imageUrl,
    String? about,
    String? cmPrivacy,
    Timestamp? recentMsgTime,
    Map<Userr, dynamic>? members,
    List<String>? events,
    int? size,
    int? boosted,
    String? themePack,
    Map<String, List<dynamic>>? permissions,
    List<String>? badges,
    bool? readStatus,
  }) {
    return Church(
      cmPrivacy: cmPrivacy ?? this.cmPrivacy,
      id: id ?? this.id,
      recentMsgTime: recentMsgTime ?? this.recentMsgTime,
      searchPram: searchPram ?? this.searchPram,
      hashTags: hashTags ?? this.hashTags,
      name: name ?? this.name,
      location: location ?? this.location,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      members: members ?? this.members,
      events: events ?? this.events,
      size: size ?? this.size,
      boosted: boosted ?? this.boosted,
      themePack: themePack ?? this.themePack,
      permissions: permissions ?? this.permissions,
      readStatus: readStatus ?? this.readStatus,
      badges: badges ?? this.badges
    );
  }

  //5 make the to doc
  Map<String, dynamic> toDoc() {
    return {
      'cmPrivacy': cmPrivacy,
      'name': name,
      'location': location,
      'searchPram': searchPram,
      'about': about,
      'imageUrl': imageUrl,
      'members':
          {}, // this is depreciated. now using a separate collection to hold roles and members
      'events': events,
      'size': size,
      'boosted': boosted,
      'themePack': themePack,
      'recentMsgTime': Timestamp.now(),
      'badges': badges
    };
  }

  Map<String, dynamic> toDocUpdate({required Map<String, String> roles}) {
    List<String> ids = members.keys.map((u) => u.id).toList();

    //DocumentReference<Map<String, dynamic>>
    Map<String, dynamic> memRefs = {};

    //! We only update the users who have a new role. otherwise the user would not have been updated.
    //! if you want to remove a user or add a user this is done through a different method
    for (String id in ids) {
      if (roles.containsKey(id)) {
        memRefs[id] = {
          'userReference':
              FirebaseFirestore.instance.collection(Paths.users).doc(id),
          'timestamp': Timestamp.now(),
          'role':
              roles[id] == '' || roles[id] == null ? Roles.Member : roles[id],
        };
      }
    }

    return {
      'cmPrivacy': cmPrivacy,
      'name': name,
      'location': location,
      'searchPram': searchPram,
      'hashTags': hashTags,
      'about': about,
      'imageUrl': imageUrl,
      'members': memRefs,
      'events': events,
      'size': size,
      'boosted': boosted,
      'themePack': themePack,
      'recentMsgTime': Timestamp.now(),
    };
  }

  static Set<String> getCommunityMemberIds(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final memRefs = Map<String, dynamic>.from(data['members']);
    // ignore: unnecessary_null_comparison
    if (memRefs == null) return {};
    return memRefs.keys.toSet();
  }

  //6 from doc
  static Future<Church> fromDoc(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;

    String location = data["location"] ?? "Remote";
    location = location == "" ? "Remote" : location;

    return Church(
      members: {},
      id: doc.id,
      size: data['size'] ?? 0, // ----------------------------------------------
      searchPram:
          List<String>.from(data['searchPram'] ?? []), // ----------------
      hashTags: [],
      name:
          data['name'] ?? 'name', //-------------------------------------------
      location:
          location, // ------------------------------------------------------
      about: data['about'] ??
          '', // ------------------------------------------------
      imageUrl:
          data['imageUrl'] ?? '', //------------------------------------------
      recentMsgTime:
          data['recentMsgTime'] ?? Timestamp(0, 0), //-------------------
      boosted:
          data['boosted'] ?? 0, // --------------------------------------------
      themePack:
          data['themePack'] ?? "none", // ---------------------------------
      events: List<String>.from(data['events'] ?? []), // ----------------------
      cmPrivacy:
          data['cmPrivacy'] ?? CmPrivacy.open, // ---------------------------
      readStatus: false,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  static Future<Church> fromId(String id) async {
    DocumentSnapshot doc =
        await FirebaseFirestore.instance.collection(Paths.church).doc(id).get();
    final data = doc.data() as Map<String, dynamic>;

    String location = data["location"] ?? "Remote";
    location = location == "" ? "Remote" : location;

    return Church(
      members: {},
      id: doc.id,
      size: data['size'] ?? 0, // ----------------------------------------------
      searchPram:
          List<String>.from(data['searchPram'] ?? []), // ----------------
      hashTags: [],
      name:
          data['name'] ?? 'name', //-------------------------------------------
      location:
          location, // ------------------------------------------------------
      about: data['about'] ??
          '', // ------------------------------------------------
      imageUrl:
          data['imageUrl'] ?? '', //------------------------------------------
      recentMsgTime:
          data['recentMsgTime'] ?? Timestamp(0, 0), //-------------------
      boosted:
          data['boosted'] ?? 0, // --------------------------------------------
      themePack:
          data['themePack'] ?? "none", // ---------------------------------
      events: List<String>.from(data['events'] ?? []), // ----------------------
      cmPrivacy:
          data['cmPrivacy'] ?? CmPrivacy.open, // ---------------------------
      readStatus: false,
      badges: List<String>.from(data['badges'] ?? []),
    );
  }

  //7 church. empty
  static Church empty = Church(
    cmPrivacy: CmPrivacy.open,
    searchPram: [],
    name: '...',
    location: '... ',
    imageUrl: '...',
    members: {},
    events: [],
    about: '...',
    recentMsgTime: Timestamp(0, 0),
    boosted: 0,
    hashTags: [],
    size: 0,
    themePack: 'none',
    readStatus: false,
  );

  static Church mock = Church(
    id: "mockId",
    permissions: {},
    cmPrivacy: CmPrivacy.open,
    searchPram: [],
    name: "MockCm",
    location: "Local",
    imageUrl:
        "https://github.com/amagalla1394/odin-recipe-git-test/blob/main/recipes/images/Steamed_Pork_Buns.jpg?raw=true",
    members: {},
    events: [],
    about:
        'A little about this cm is that this is a mock cm, did you know that??? or could you not tell',
    recentMsgTime: Timestamp(0, 0),
    boosted: 0,
    hashTags: [],
    size: 0,
    themePack: 'none',
    readStatus: false,
  );
}
