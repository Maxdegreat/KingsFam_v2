part of 'role_cubit.dart';

class RoleState extends Equatable {
  final Map<String, bool> isChecked;
  final Map<String, List<String>> permissionsMap;
  final bool isSaved;
  final String role;
  final Church community;
  const RoleState({
    required this.isChecked,
    required this.permissionsMap,
    required this.isSaved,
    required this.role,
    required this.community
  });
  factory RoleState.inital() {
    return RoleState(community: Church.empty, isChecked: {}, isSaved: true, role: '', permissionsMap: {});
  }
  @override
  List<Object> get props => [isChecked, permissionsMap,  isSaved,  role, community, ];

  RoleState copyWith({
    Map<String, bool>? isChecked,
    Map<String, List<String>>? permissionsMap,
    bool? isSaved,
    String? role,
    Church? community,
  }) {
    return RoleState(
      isChecked: isChecked ?? this.isChecked,
      permissionsMap: permissionsMap ?? this.permissionsMap,
      isSaved: isSaved ?? this.isSaved,
      role: role ?? this.role,
      community: community ?? this.community,
    );
  }
}


