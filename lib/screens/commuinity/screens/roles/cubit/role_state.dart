part of 'role_cubit.dart';

class RoleState extends Equatable {
  final Map<String, bool> isChecked;
  final Map<String, List<String>> permissionsMap;
  final bool isSaved;
  final String role;
  final Church community;
  const RoleState({
    required this.isChecked,
    required this.isSaved,
    required this.role,
    required this.permissionsMap,
    required this.community
  });
  factory RoleState.inital() {
    return RoleState(community: Church.empty, isChecked: {}, isSaved: true, role: '', permissionsMap: {});
  }
  @override
  List<Object?> get props => [isChecked, community, isSaved, role, permissionsMap];

  RoleState copyWith({
    Map<String, bool>? isChecked,
    bool? isSaved,
    String? role,
    Church? community,
    Map<String, List<String>>? permissionsMap,
  }) {
    return RoleState(
      role: role ?? this.role,
      community: community ?? this.community,
      isChecked: isChecked ?? this.isChecked,
      isSaved: isSaved ?? this.isSaved,
      permissionsMap: permissionsMap ?? this.permissionsMap,
    );
  }
}


