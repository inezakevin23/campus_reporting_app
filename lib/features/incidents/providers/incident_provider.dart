import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';

import '../../../data/models/incident_model.dart';
import '../../../data/models/incident_status_update_model.dart';

import 'package:campus_reporting_app/data/services/incident_service.dart';
import 'package:campus_reporting_app/data/services/storage_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Storage Service.
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    supabase: ref.watch(supabaseClientProvider),
    auth: FirebaseAuth.instance,
  );
});

// Incident Service.
final incidentServiceProvider = Provider<IncidentService>((ref) {
  return IncidentService(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    storage: ref.watch(storageServiceProvider),
  );
});

// Manage incident submission.
class CreateIncidentController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<String> submit({
    required String title,
    required String description,
    required String category,
    required String location,
    required String priority,
    Uint8List? imageBytes,
    String? imageExtension,
    String? contentType,
  }) async {
    state = const AsyncLoading();

    try {
      final incidentId = await ref
          .read(incidentServiceProvider)
          .createIncident(
            title: title,
            description: description,
            category: category,
            location: location,
            priority: priority,
            imageBytes: imageBytes,
            imageExtension: imageExtension,
            contentType: contentType,
          );

      state = const AsyncData(null);

      return incidentId;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);

      rethrow;
    }
  }
}

final createIncidentProvider =
    AsyncNotifierProvider<CreateIncidentController, void>(
      CreateIncidentController.new,
    );

final campusIncidentsProvider = StreamProvider<List<Incident>>((ref) {
  return ref.watch(incidentServiceProvider).watchCampusIncidents();
});

final myReportsProvider = StreamProvider.family<List<Incident>, String>((
  ref,
  uid,
) {
  return ref.watch(incidentServiceProvider).watchMyReports(uid);
});

final incidentDetailsProvider = StreamProvider.family<Incident?, String>((
  ref,
  incidentId,
) {
  return ref.watch(incidentServiceProvider).watchIncident(incidentId);
});

final incidentHistoryProvider =
    StreamProvider.family<List<IncidentStatusUpdate>, String>((
      ref,
      incidentId,
    ) {
      return ref.watch(incidentServiceProvider).watchStatusHistory(incidentId);
    });

final signedImageUrlProvider = FutureProvider.autoDispose
    .family<String, String>((ref, imagePath) async {
      return ref.watch(storageServiceProvider).getSignedImageUrl(imagePath);
    });
