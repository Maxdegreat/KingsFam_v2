
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Role extends Equatable{
  final String? id;
  final String roleName;
  final List<String> permissions;

  const Role({this.id, required this.roleName, required this.permissions});

  static Role empty = Role(roleName: "Member", permissions: ["0"]);

  @override
  List<Object?> get props => [id, roleName, permissions];

  Map<String, dynamic> toDoc() {
    return {
      "roleName" : roleName,
      "permissions" : permissions,
    };
  }

  static Role fromDoc(DocumentSnapshot doc)  {

    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Role(
      roleName: data["roleName"] ?? "Member",
      permissions: List.from(data["permissions"])
    );
  }

}