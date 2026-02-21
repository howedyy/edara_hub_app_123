import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';

class EventsManagementScreen extends StatefulWidget {
  const EventsManagementScreen({super.key});

  @override
  State<EventsManagementScreen> createState() => _EventsManagementScreenState();
}

class _EventsManagementScreenState extends State<EventsManagementScreen> {
  String _filterStatus = 'all'; // 'all', 'published', 'draft'

  Stream<QuerySnapshot> _getEventsStream() {
    Query query = FirebaseFirestore.instance.collection('events');
    
    if (_filterStatus == 'published') {
      query = query.where('is_published', isEqualTo: true).orderBy('created_at', descending: true);
    } else if (_filterStatus == 'draft') {
      query = query.where('is_published', isEqualTo: false).orderBy('created_at', descending: true);
    }
    // For 'all' filter, don't use orderBy to avoid requiring additional index
    
    return query.snapshots();
  }

  Future<void> _createEvent() async {
    await showDialog(
      context: context,
      builder: (context) => const EventFormDialog(),
    );
  }

  Future<void> _editEvent(String eventId, Map<String, dynamic> eventData) async {
    await showDialog(
      context: context,
      builder: (context) => EventFormDialog(
        eventId: eventId,
        initialData: eventData,
      ),
    );
  }

  Future<void> _deleteEvent(String eventId, Map<String, dynamic> eventData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${eventData['title']}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePublishStatus(String eventId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).update({
        'is_published': !currentStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'Event unpublished' : 'Event published successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Row(
            children: [
              const Text(
                'Filter:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 16),
              ChoiceChip(
                label: const Text('All'),
                selected: _filterStatus == 'all',
                onSelected: (selected) {
                  if (selected) setState(() => _filterStatus = 'all');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Published'),
                selected: _filterStatus == 'published',
                onSelected: (selected) {
                  if (selected) setState(() => _filterStatus = 'published');
                },
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('Draft'),
                selected: _filterStatus == 'draft',
                onSelected: (selected) {
                  if (selected) setState(() => _filterStatus = 'draft');
                },
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _createEvent,
                icon: const Icon(Icons.add),
                label: const Text('Create Event'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getEventsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final events = snapshot.data!.docs;

              if (events.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No events found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _createEvent,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Event'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final eventDoc = events[index];
                  final eventData = eventDoc.data() as Map<String, dynamic>;
                  final eventId = eventDoc.id;
                  final isPublished = eventData['is_published'] ?? false;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (eventData['image_url'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              eventData['image_url'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.image, size: 64),
                                );
                              },
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      eventData['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      isPublished ? 'Published' : 'Draft',
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    backgroundColor:
                                        isPublished ? Colors.green : Colors.grey,
                                  ),
                                  const SizedBox(width: 8),
                                  if (eventData['attachments'] != null && (eventData['attachments'] as List).isNotEmpty)
                                    Chip(
                                      avatar: const Icon(Icons.attach_file, size: 16, color: Colors.blue),
                                      label: Text(
                                        '${(eventData['attachments'] as List).length} Files',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                eventData['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.calendar_today,
                                      'Date',
                                      _formatTimestamp(eventData['event_date']),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.location_on,
                                      'Location',
                                      eventData['location'] ?? 'N/A',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.visibility,
                                      'Visibility',
                                      eventData['visibility'] == 'all_users'
                                          ? 'All Users'
                                          : 'Selected Users',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _deleteEvent(eventId, eventData),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _editEvent(eventId, eventData),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _togglePublishStatus(eventId, isPublished),
                                    icon: Icon(
                                      isPublished ? Icons.unpublished : Icons.publish,
                                    ),
                                    label: Text(
                                      isPublished ? 'Unpublish' : 'Publish',
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          isPublished ? Colors.orange : Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ],
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    try {
      final date = (timestamp as Timestamp).toDate();
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return 'N/A';
    }
  }
}

// Event Form Dialog for creating and editing events
class EventFormDialog extends StatefulWidget {
  final String? eventId;
  final Map<String, dynamic>? initialData;

  const EventFormDialog({
    super.key,
    this.eventId,
    this.initialData,
  });

  @override
  State<EventFormDialog> createState() => _EventFormDialogState();
}

class _EventFormDialogState extends State<EventFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxAttendeesController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String _visibility = 'all_users';
  List<String> _selectedUsers = [];
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = false;
  bool _isUploading = false;
  List<String> _attachments = [];
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
    
    if (widget.initialData != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final data = widget.initialData!;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _locationController.text = data['location'] ?? '';
    _maxAttendeesController.text = (data['max_attendees'] ?? '').toString();
    _visibility = data['visibility'] ?? 'all_users';
    _selectedUsers = List<String>.from(data['allowed_users'] ?? []);
    _attachments = List<String>.from(data['attachments'] ?? []);
    // Fallback for old data without attachments but with image_url
    if (_attachments.isEmpty && data['image_url'] != null) {
      _attachments.add(data['image_url']);
    }
    _isPublished = data['is_published'] ?? false;
    
    if (data['event_date'] != null) {
      final eventDateTime = (data['event_date'] as Timestamp).toDate();
      _selectedDate = eventDateTime;
      _selectedTime = TimeOfDay.fromDateTime(eventDateTime);
    }
  }

  Future<void> _loadAvailableUsers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('approved', isEqualTo: true)
          .get();
      
      setState(() {
        _availableUsers = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'name': doc.data()['name'] ?? 'Unknown',
                  'email': doc.data()['email'] ?? '',
                })
            .toList();
      });
    } catch (e) {
      print('Error loading users: $e');
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  Future<void> _pickMultimedia() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'png', 'jpeg', 'mp4', 'mov', 'avi'],
        allowMultiple: true,
        withData: true, // Crucial for Web
      );

      if (result == null || result.files.isEmpty) return;

      setState(() {
        _isUploading = true;
      });

      try {
        for (var file in result.files) {
          if (file.bytes == null) {
            print('AdminPanel: File ${file.name} has no bytes, skipping.');
            continue;
          }

          final fileName = file.name;
          print('AdminPanel: Preparing to upload $fileName...');
          
          final isVideo = fileName.toLowerCase().endsWith('.mp4') || 
                          fileName.toLowerCase().endsWith('.mov') || 
                          fileName.toLowerCase().endsWith('.avi');
          
          final folder = isVideo ? 'videos' : 'images';
          final storagePath = 'events/$folder/${DateTime.now().millisecondsSinceEpoch}_$fileName';
          
          final storageRef = FirebaseStorage.instance.ref().child(storagePath);
          
          final uploadTask = storageRef.putData(
            file.bytes!,
            SettableMetadata(contentType: isVideo ? 'video/mp4' : 'image/jpeg'),
          );
          
          try {
            print('AdminPanel: Awaiting storage response for $fileName...');
            // Add a timeout to prevent infinite spinning if network/CORS fails
            final snapshot = await uploadTask.timeout(const Duration(minutes: 2));
            final downloadUrl = await snapshot.ref.getDownloadURL();
            
            print('AdminPanel: Upload successful: $downloadUrl');
            if (mounted) {
              setState(() {
                _attachments.add(downloadUrl);
              });
            }
          } catch (e) {
            print('AdminPanel: Error uploading $fileName: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload $fileName: $e'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          }
        }
      } catch (e) {
        print('AdminPanel: Critical error during selection/upload loop: $e');
      } finally {
        if (mounted) {
          setState(() {
            _isUploading = false;
          });
          print('AdminPanel: Upload process finished.');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Picker error: $e')),
        );
      }
    }
  }

  Future<void> _saveEvent() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select date and time')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final eventData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'event_date': Timestamp.fromDate(eventDateTime),
        'max_attendees': int.tryParse(_maxAttendeesController.text) ?? 0,
        'current_attendees': 0,
        'visibility': _visibility,
        'allowed_users': _visibility == 'selected_users' ? _selectedUsers : [],
        'attachments': _attachments,
        'image_url': _attachments.isNotEmpty ? _attachments.first : null, // Retro-compatibility
        'is_published': _isPublished,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (widget.eventId != null) {
        // Update existing event
        await FirebaseFirestore.instance
            .collection('events')
            .doc(widget.eventId)
            .update(eventData);
      } else {
        // Create new event
        eventData['created_at'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('events').add(eventData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.eventId != null 
                  ? 'Event updated successfully' 
                  : 'Event created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving event: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxAttendeesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: 800,
        height: 600,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  widget.eventId != null ? 'Edit Event' : 'Create Event',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _isUploading
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Uploading files... Please wait.'),
                                ],
                              )
                            : _attachments.isEmpty
                                ? InkWell(
                                    onTap: _pickMultimedia,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.blue[300]),
                                        const SizedBox(height: 8),
                                        const Text('Click to upload images and videos'),
                                        Text('Support multiple files', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                                      ],
                                    ),
                                  )
                            : Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Text('${_attachments.length} files selected', style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const Spacer(),
                                        TextButton.icon(
                                          onPressed: _isUploading ? null : _pickMultimedia,
                                          icon: const Icon(Icons.add),
                                          label: const Text('Add More'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      itemCount: _attachments.length,
                                      itemBuilder: (context, index) {
                                        final url = _attachments[index];
                                        final isVideo = url.contains('/videos/') || url.contains('.mp4');
                                        
                                        return Stack(
                                          children: [
                                            Container(
                                              width: 120,
                                              margin: const EdgeInsets.only(right: 8, bottom: 8),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(8),
                                                image: !isVideo ? DecorationImage(
                                                  image: NetworkImage(url),
                                                  fit: BoxFit.cover,
                                                ) : null,
                                                color: isVideo ? Colors.black87 : Colors.grey[200],
                                              ),
                                              child: isVideo ? const Center(child: Icon(Icons.play_circle_outline, color: Colors.white, size: 40)) : null,
                                            ),
                                            Positioned(
                                              top: 4,
                                              right: 12,
                                              child: InkWell(
                                                onTap: () => setState(() => _attachments.removeAt(index)),
                                                child: Container(
                                                  padding: const EdgeInsets.all(2),
                                                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Basic Information
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter event description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location *',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter location';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _maxAttendeesController,
                              decoration: const InputDecoration(
                                labelText: 'Max Attendees',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Event Date *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _selectedDate != null
                                      ? DateFormat('MMM dd, yyyy').format(_selectedDate!)
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Event Time *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _selectedTime != null
                                      ? _selectedTime!.format(context)
                                      : 'Select time',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Visibility Settings
                      const Text(
                        'Event Visibility',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      RadioListTile<String>(
                        title: const Text('All Users'),
                        subtitle: const Text('All approved users can see this event'),
                        value: 'all_users',
                        groupValue: _visibility,
                        onChanged: (value) => setState(() => _visibility = value!),
                      ),
                      
                      RadioListTile<String>(
                        title: const Text('Selected Users'),
                        subtitle: const Text('Only selected users can see this event'),
                        value: 'selected_users',
                        groupValue: _visibility,
                        onChanged: (value) => setState(() => _visibility = value!),
                      ),
                      
                      if (_visibility == 'selected_users') ...[
                        const SizedBox(height: 8),
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(8),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Text(
                                      'Select Users',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    Text('${_selectedUsers.length} selected'),
                                  ],
                                ),
                              ),
                              Expanded(
                                child: ListView.builder(
                                  itemCount: _availableUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _availableUsers[index];
                                    final isSelected = _selectedUsers.contains(user['id']);
                                    
                                    return CheckboxListTile(
                                      title: Text(user['name']),
                                      subtitle: Text(user['email']),
                                      value: isSelected,
                                      onChanged: (selected) {
                                        setState(() {
                                          if (selected == true) {
                                            _selectedUsers.add(user['id']);
                                          } else {
                                            _selectedUsers.remove(user['id']);
                                          }
                                        });
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      const SizedBox(height: 16),
                      
                      // Publish Status
                      SwitchListTile(
                        title: const Text('Publish Event'),
                        subtitle: Text(
                          _isPublished 
                              ? 'Event will be visible to users' 
                              : 'Event will be saved as draft',
                        ),
                        value: _isPublished,
                        onChanged: (value) => setState(() => _isPublished = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            const Divider(),
            
            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: (_isLoading || _isUploading) ? null : _saveEvent,
                  child: (_isLoading || _isUploading)
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.eventId != null ? 'Update Event' : 'Create Event'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}