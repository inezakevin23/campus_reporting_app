import 'package:cloud_firestore/cloud_firestore.dart';

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String priority;
  final String status;
  final String reporterId;
  final String? imagePath;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.priority,
    required this.status,
    required this.reporterId,
    this.imagePath,
    this.createdAt,
    this.updatedAt,
  });

  factory Incident.fromMap(String id, Map<String, dynamic> data) {
    return Incident(
      id: id,
      title: data['title'] as String,
      description: data['description'] as String,
      category: data['category'] as String,
      location: data['location'] as String,
      priority: data['priority'] as String,
      status: data['status'] as String,
      reporterId: data['reporterId'] as String,
      imagePath: data['imagePath'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
