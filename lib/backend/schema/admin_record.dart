import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class AdminRecord extends FirestoreRecord {
  AdminRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "adminid" field.
  String? _adminid;
  String get adminid => _adminid ?? '';
  bool hasAdminid() => _adminid != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "name" field.
  String? _name;
  String get name => _name ?? '';
  bool hasName() => _name != null;

  // "role" field.
  String? _role;
  String get role => _role ?? '';
  bool hasRole() => _role != null;

  void _initializeFields() {
    _adminid = snapshotData['adminid'] as String?;
    _email = snapshotData['email'] as String?;
    _name = snapshotData['name'] as String?;
    _role = snapshotData['role'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Admin');

  static Stream<AdminRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => AdminRecord.fromSnapshot(s));

  static Future<AdminRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => AdminRecord.fromSnapshot(s));

  static AdminRecord fromSnapshot(DocumentSnapshot snapshot) => AdminRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static AdminRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      AdminRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'AdminRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is AdminRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createAdminRecordData({
  String? adminid,
  String? email,
  String? name,
  String? role,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'adminid': adminid,
      'email': email,
      'name': name,
      'role': role,
    }.withoutNulls,
  );

  return firestoreData;
}

class AdminRecordDocumentEquality implements Equality<AdminRecord> {
  const AdminRecordDocumentEquality();

  @override
  bool equals(AdminRecord? e1, AdminRecord? e2) {
    return e1?.adminid == e2?.adminid &&
        e1?.email == e2?.email &&
        e1?.name == e2?.name &&
        e1?.role == e2?.role;
  }

  @override
  int hash(AdminRecord? e) =>
      const ListEquality().hash([e?.adminid, e?.email, e?.name, e?.role]);

  @override
  bool isValidKey(Object? o) => o is AdminRecord;
}
