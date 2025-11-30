import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class FaresRecord extends FirestoreRecord {
  FaresRecord._(
    super.reference,
    super.data,
  ) {
    _initializeFields();
  }

  // "peak_hours_end" field.
  String? _peakHoursEnd;
  String get peakHoursEnd => _peakHoursEnd ?? '';
  bool hasPeakHoursEnd() => _peakHoursEnd != null;

  // "peak_hours_starts" field.
  String? _peakHoursStarts;
  String get peakHoursStarts => _peakHoursStarts ?? '';
  bool hasPeakHoursStarts() => _peakHoursStarts != null;

  // "route_id" field.
  String? _routeId;
  String get routeId => _routeId ?? '';
  bool hasRouteId() => _routeId != null;

  // "standard_fare" field.
  int? _standardFare;
  int get standardFare => _standardFare ?? 0;
  bool hasStandardFare() => _standardFare != null;

  // "peak_multiplier" field.
  double? _peakMultiplier;
  double get peakMultiplier => _peakMultiplier ?? 0.0;
  bool hasPeakMultiplier() => _peakMultiplier != null;

  void _initializeFields() {
    _peakHoursEnd = snapshotData['peak_hours_end'] as String?;
    _peakHoursStarts = snapshotData['peak_hours_starts'] as String?;
    _routeId = snapshotData['route_id'] as String?;
    _standardFare = castToType<int>(snapshotData['standard_fare']);
    _peakMultiplier = castToType<double>(snapshotData['peak_multiplier']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('Fares');

  static Stream<FaresRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => FaresRecord.fromSnapshot(s));

  static Future<FaresRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => FaresRecord.fromSnapshot(s));

  static FaresRecord fromSnapshot(DocumentSnapshot snapshot) => FaresRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static FaresRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      FaresRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'FaresRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is FaresRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createFaresRecordData({
  String? peakHoursEnd,
  String? peakHoursStarts,
  String? routeId,
  int? standardFare,
  double? peakMultiplier,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'peak_hours_end': peakHoursEnd,
      'peak_hours_starts': peakHoursStarts,
      'route_id': routeId,
      'standard_fare': standardFare,
      'peak_multiplier': peakMultiplier,
    }.withoutNulls,
  );

  return firestoreData;
}

class FaresRecordDocumentEquality implements Equality<FaresRecord> {
  const FaresRecordDocumentEquality();

  @override
  bool equals(FaresRecord? e1, FaresRecord? e2) {
    return e1?.peakHoursEnd == e2?.peakHoursEnd &&
        e1?.peakHoursStarts == e2?.peakHoursStarts &&
        e1?.routeId == e2?.routeId &&
        e1?.standardFare == e2?.standardFare &&
        e1?.peakMultiplier == e2?.peakMultiplier;
  }

  @override
  int hash(FaresRecord? e) => const ListEquality().hash([
        e?.peakHoursEnd,
        e?.peakHoursStarts,
        e?.routeId,
        e?.standardFare,
        e?.peakMultiplier
      ]);

  @override
  bool isValidKey(Object? o) => o is FaresRecord;
}
