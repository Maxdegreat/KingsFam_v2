part of 'role_cubit.dart';

class RoleState extends Equatable {
  final Map<String, bool> isChecked;
  final Map<String, List<String>> permissionsMap;
  final bool isSaved;
  final String role;
  const RoleState({
    required this.isChecked,
    required this.isSaved,
    required this.role,
    required this.permissionsMap,
  });
  factory RoleState.inital() {
    return RoleState(isChecked: {}, isSaved: true, role: '', permissionsMap: {});
  }
  @override
  List<Object?> get props => [isChecked, isSaved, role, permissionsMap];

  RoleState copyWith({
    Map<String, bool>? isChecked,
    bool? isSaved,
    String? role,
    Map<String, List<String>>? permissionsMap,
  }) {
    return RoleState(
      role: role ?? this.role,
      isChecked: isChecked ?? this.isChecked,
      isSaved: isSaved ?? this.isSaved,
      permissionsMap: permissionsMap ?? this.permissionsMap,
    );
  }
}


