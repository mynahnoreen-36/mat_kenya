import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class RoutesRecord extends FirestoreRecord {
  RoutesRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "destination" field.
  String? _destination;
  String get destination => _destination ?? '';
  bool hasDestination() => _destination != null;

  // "origin" field.
  String? _origin;
  String get origin => _origin ?? '';
  bool hasOrigin() => _origin != null;

  // "routeid" field.
  String? _routeid;
  String get routeid => _routeid ?? '';
  bool hasRouteid() => _routeid != null;

  // "is_verified" field.
  bool? _isVerified;
  bool get isVerified => _isVerified ?? false;
  bool hasIsVerified() => _isVerified != null;

  // "stages" field.
  String? _stages;
  String get stages => _stages ?? '';
  bool hasStages() => _stages != null;

  void _initializeFields() {
    _destination = snapshotData['destination'] as String?;
    _origin = snapshotData['origin'] as String?;
    _routeid = snapshotData['routeid'] as String?;
    _isVerified = snapshotData['is_verified'] as bool?;
    _stages = snapshotData['stages'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Routes');

  static Stream<RoutesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RoutesRecord.fromSnapshot(s));

  static Future<RoutesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RoutesRecord.fromSnapshot(s));

  static RoutesRecord fromSnapshot(DocumentSnapshot snapshot) => RoutesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RoutesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RoutesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RoutesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RoutesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRoutesRecordData({
  String? destination,
  String? origin,
  String? routeid,
  bool? isVerified,
  String? stages,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'destination': destination,
      'origin': origin,
      'routeid': routeid,
      'is_verified': isVerified,
      'stages': stages,
    }.withoutNulls,
  );

  return firestoreData;
}

class RoutesRecordDocumentEquality implements Equality<RoutesRecord> {
  const RoutesRecordDocumentEquality();

  @override
  bool equals(RoutesRecord? e1, RoutesRecord? e2) {
    return e1?.destination == e2?.destination &&
        e1?.origin == e2?.origin &&
        e1?.routeid == e2?.routeid &&
        e1?.isVerified == e2?.isVerified &&
        e1?.stages == e2?.stages;
  }

  @override
  int hash(RoutesRecord? e) => const ListEquality()
      .hash([e?.destination, e?.origin, e?.routeid, e?.isVerified, e?.stages]);

  @override
  bool isValidKey(Object? o) => o is RoutesRecord;
}
