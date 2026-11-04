import 'package:cloud_firestore/cloud_firestore.dart';

class IncidentStatusUpdate {
  final String id;
  final String status;
  final String note;
  final String changedByUid;
  final DateTime? createdAt;

  const IncidentStatusUpdate({
    required this.id,
    required this.status,
    required this.note,
    required this.changedByUid,
    this.createdAt,
  });

  factory IncidentStatusUpdate.fromMap(String id, Map<String, dynamic> data) {
    return IncidentStatusUpdate(
      id: id,
      status: data['status'] as String,
      note: data['note'] as String,
      changedByUid: data['changedByUid'] as String,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
