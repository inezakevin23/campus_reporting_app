import 'dart:typed_data';

import 'package:campus_reporting_app/features/incidents/providers/incident_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_theme.dart';

class CreateIncidentScreen extends ConsumerStatefulWidget {
  const CreateIncidentScreen({super.key});

  @override
  ConsumerState<CreateIncidentScreen> createState() =>
      _CreateIncidentScreenState();
}

class _CreateIncidentScreenState extends ConsumerState<CreateIncidentScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();

  String _category = 'water';
  String _priority = 'medium';

  Uint8List? _imageBytes;
  String? _imageName;
  String? _imageExtension;
  String? _contentType;

  bool _isPickingImage = false;

  String? _errorMessage;

  static const int _maxImageSize = 5 * 1024 * 1024;

  static const Map<String, String> _categories = {
    'facilities': 'Facilities',
    'water': 'Water',
    'electricity': 'Electricity',
    'safety': 'Safety',
    'sanitation': 'Sanitation',
    'furniture': 'Furniture',
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();

    super.dispose();
  }

  // SELECT IMAGE
  Future<void> _pickImage() async {
    setState(() {
      _isPickingImage = true;
      _errorMessage = null;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      final extension = image.name.split('.').last.toLowerCase();

      const supportedFormats = {
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'png': 'image/png',
        'webp': 'image/webp',
      };

      if (!supportedFormats.containsKey(extension)) {
        throw Exception(
          'Unsupported image format. '
          'Choose JPG, PNG or WebP.',
        );
      }

      final bytes = await image.readAsBytes();

      if (bytes.length > _maxImageSize) {
        throw Exception(
          'Image is larger than 5 MB. '
          'Choose a smaller photograph.',
        );
      }

      if (!mounted) return;

      setState(() {
        _imageBytes = bytes;
        _imageName = image.name;
        _imageExtension = extension;
        _contentType = supportedFormats[extension];
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = error.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  // -----------------------------------------------
  // REMOVE SELECTED IMAGE
  // -----------------------------------------------

  void _removeImage() {
    setState(() {
      _imageBytes = null;
      _imageName = null;
      _imageExtension = null;
      _contentType = null;
    });
  }

  // SUBMIT INCIDENT
  Future<void> _submitIncident() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _errorMessage = null;
    });

    try {
      final incidentId = await ref
          .read(createIncidentProvider.notifier)
          .submit(
            title: _titleController.text,
            description: _descriptionController.text,
            category: _category,
            location: _locationController.text,
            priority: _priority,
            imageBytes: _imageBytes,
            imageExtension: _imageExtension,
            contentType: _contentType,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Incident submitted successfully. ID: $incidentId'),
          duration: const Duration(seconds: 4),
        ),
      );

      context.go('/student');
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _errorMessage = _getErrorMessage(error);
      });
    }
  }

  // ERROR HANDLING
  String _getErrorMessage(Object error) {
    final message = error.toString();

    if (message.contains('not configured for Supabase')) {
      return 'Your account is not yet enabled for photograph '
          'uploads. Contact the administrator.';
    }

    if (message.contains('permission-denied')) {
      return 'You do not have permission to submit this incident. '
          'Check your account and database permissions.';
    }

    if (message.contains('SocketException') || message.contains('network')) {
      return 'Network error. Check your internet connection.';
    }

    return 'Submission failed. Please check your connection '
        'and try again.';
  }

  // BUILD SCREEN
  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(createIncidentProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Report an Issue')),

      body: SafeArea(
        child: Form(
          key: _formKey,

          child: ListView(
            padding: const EdgeInsets.all(20),

            children: [
              const Text(
                'Help us improve the campus.',
                style: TextStyle(color: Colors.white70),
              ),

              const SizedBox(height: 24),

              // CATEGORY
              const Text(
                'Category',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _category,

                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),

                items: _categories.entries.map((entry) {
                  return DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),

                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 20),

              // TITLE
              const Text(
                'Title',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _titleController,

                maxLength: 80,

                textCapitalization: TextCapitalization.sentences,

                decoration: const InputDecoration(
                  hintText: 'e.g. Water shortage in Block A',
                  prefixIcon: Icon(Icons.title),
                  counterText: '',
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Incident title is required.';
                  }

                  if (value.trim().length < 3) {
                    return 'Title must contain at least 3 characters.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // DESCRIPTION
              const Text(
                'Description',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _descriptionController,

                maxLines: 5,
                maxLength: 1000,

                textCapitalization: TextCapitalization.sentences,

                decoration: const InputDecoration(
                  hintText:
                      'Describe what happened, where it happened '
                      'and how it affects students.',
                  alignLabelWithHint: true,
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required.';
                  }

                  if (value.trim().length < 10) {
                    return 'Please provide more details.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // LOCATION
              const Text(
                'Location',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              TextFormField(
                controller: _locationController,

                textCapitalization: TextCapitalization.sentences,

                decoration: const InputDecoration(
                  hintText: 'e.g. Block A - Room 204',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),

                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Incident location is required.';
                  }

                  if (value.trim().length < 3) {
                    return 'Enter a more specific location.';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 20),

              // PRIORITY
              const Text(
                'Priority Level',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              DropdownButtonFormField<String>(
                initialValue: _priority,

                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.flag_outlined),
                ),

                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'medium', child: Text('Medium')),
                  DropdownMenuItem(value: 'high', child: Text('High')),
                ],

                onChanged: isSubmitting
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() {
                            _priority = value;
                          });
                        }
                      },
              ),

              const SizedBox(height: 24),

              // IMAGE PICKER
              const Text(
                'Photograph (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              if (_imageBytes == null)
                InkWell(
                  onTap: (isSubmitting || _isPickingImage) ? null : _pickImage,

                  borderRadius: BorderRadius.circular(12),

                  child: Container(
                    padding: const EdgeInsets.all(28),

                    decoration: BoxDecoration(
                      color: AppTheme.card,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),

                    child: Column(
                      children: [
                        if (_isPickingImage)
                          const CircularProgressIndicator()
                        else
                          const Icon(
                            Icons.add_a_photo_outlined,
                            size: 40,
                            color: AppTheme.yellow,
                          ),

                        const SizedBox(height: 12),

                        Text(
                          _isPickingImage
                              ? 'Selecting photograph...'
                              : 'Tap to add a photograph',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          'JPG, PNG or WebP · Maximum 5 MB',
                          style: TextStyle(color: Colors.white60, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.card,
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),

                        child: Image.memory(
                          _imageBytes!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      ListTile(
                        leading: const Icon(
                          Icons.image_outlined,
                          color: AppTheme.yellow,
                        ),

                        title: Text(
                          _imageName ?? 'Selected image',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        subtitle: Text(
                          '${(_imageBytes!.length / 1024).toStringAsFixed(1)} KB',
                        ),

                        trailing: IconButton(
                          onPressed: isSubmitting ? null : _removeImage,

                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.redAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // ERROR MESSAGE
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),

                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),

                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                ),

                const SizedBox(height: 16),
              ],

              // SUBMIT BUTTON
              FilledButton.icon(
                onPressed: (isSubmitting || _isPickingImage)
                    ? null
                    : _submitIncident,

                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppTheme.navy,
                        ),
                      )
                    : const Icon(Icons.send),

                label: Text(
                  isSubmitting ? 'Submitting Report...' : 'Submit Report',
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Your report will be reviewed by authorized '
                'campus staff.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.white60),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
