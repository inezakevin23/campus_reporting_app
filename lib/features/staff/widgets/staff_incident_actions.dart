import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/incident_model.dart';

class StaffIncidentActions extends ConsumerStatefulWidget {
  final Incident incident;

  const StaffIncidentActions({super.key, required this.incident});

  @override
  ConsumerState<StaffIncidentActions> createState() =>
      _StaffIncidentActionsState();
}

class _StaffIncidentActionsState extends ConsumerState<StaffIncidentActions> {
  final _formKey = GlobalKey<FormState>();

  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  // DETERMINE NEXT STATUS
  String? get nextStatus {
    switch (widget.incident.status) {
      case 'submitted':
        return 'in_progress';

      case 'in_progress':
        return 'resolved';

      case 'resolved':
        return null;

      default:
        return null;
    }
  }

  // BUTTON LABEL
  String get actionLabel {
    switch (nextStatus) {
      case 'in_progress':
        return 'Start Working on Issue';

      case 'resolved':
        return 'Mark as Resolved';

      default:
        return 'Issue Resolved';
    }
  }

  // SUBMIT STATUS UPDATE
  Future<void> _updateStatus() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final status = nextStatus;

    if (status == null) {
      return;
    }

    try {
      await ref
          .read(updateIncidentStatusProvider.notifier)
          .updateStatus(
            incidentId: widget.incident.id,
            newStatus: status,
            note: _noteController.text,
          );

      if (!mounted) return;

      _noteController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incident updated to ${_formatStatus(status)}.'),
        ),
      );

      // Firestore streams automatically refresh
      // the incident and status history.
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getErrorMessage(error)),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // FORMAT STATUS
  String _formatStatus(String status) {
    switch (status) {
      case 'submitted':
        return 'Submitted';

      case 'in_progress':
        return 'In Progress';

      case 'resolved':
        return 'Resolved';

      default:
        return status;
    }
  }

  // ERROR MESSAGE
  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('permission-denied')) {
      return 'Access denied. Check your staff permissions.';
    }

    if (message.contains('Incident not found')) {
      return 'This incident could not be found.';
    }

    if (message.contains('Invalid status transition')) {
      return 'This incident status has already changed. '
          'Refresh and try again.';
    }

    if (message.contains('authorized campus staff')) {
      return 'You are not authorized to update incidents.';
    }

    return 'Unable to update the incident. Please try again.';
  }

  // BUILD
  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(updateIncidentStatusProvider).isLoading;

    final status = widget.incident.status;

    final next = nextStatus;

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          const Row(
            children: [
              Icon(Icons.admin_panel_settings_outlined, color: AppTheme.yellow),

              SizedBox(width: 10),

              Text(
                'Staff Incident Management',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 18),

          const Text(
            'Current Status',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),

          const SizedBox(height: 6),

          Text(
            _formatStatus(status),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          if (next == null) ...[
            Container(
              padding: const EdgeInsets.all(12),

              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),

              child: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green),

                  SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      'This incident has been resolved. '
                      'No further status updates are available.',
                      style: TextStyle(color: Colors.green),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Progress / Resolution Note',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _noteController,

                    enabled: !isLoading,

                    maxLines: 4,
                    maxLength: 500,

                    textCapitalization: TextCapitalization.sentences,

                    decoration: const InputDecoration(
                      hintText:
                          'Explain what action has been taken '
                          'or how the issue was resolved.',
                      alignLabelWithHint: true,
                    ),

                    validator: (value) {
                      if (value == null || value.trim().length < 5) {
                        return 'Please provide a meaningful note.';
                      }

                      if (value.trim().length > 500) {
                        return 'Maximum 500 characters.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,

                    child: FilledButton.icon(
                      onPressed: isLoading ? null : _updateStatus,

                      icon: isLoading
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppTheme.navy,
                              ),
                            )
                          : Icon(
                              next == 'resolved'
                                  ? Icons.check_circle_outline
                                  : Icons.play_arrow,
                            ),

                      label: Text(
                        isLoading ? 'Updating Incident...' : actionLabel,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
