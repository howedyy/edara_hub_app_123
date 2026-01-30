import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

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
      query = query.where('is_published', isEqualTo: true);
    } else if (_filterStatus == 'draft') {
      query = query.where('is_published', isEqualTo: false);
    }
    
    return query.orderBy('created_at', descending: true).snapshots();
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
  String? _imageUrl;
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
    _imageUrl = data['image_url'];
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

  Future<void> _pickImage() async {
    try {
      final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();

      uploadInput.onChange.listen((e) async {
        final files = uploadInput.files;
        if (files!.isEmpty) return;

        final file = files[0];
        final fileName = 'events/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        
        setState(() => _isLoading = true);

        try {
          final storageRef = FirebaseStorage.instance.ref().child(fileName);
          final uploadTask = storageRef.putBlob(file);
          final snapshot = await uploadTask;
          final downloadUrl = await snapshot.ref.getDownloadURL();
          
          setState(() {
            _imageUrl = downloadUrl;
            _isLoading = false;
          });
        } catch (e) {
          setState(() => _isLoading = false);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error uploading image: $e')),
            );
          }
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
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
        'is_published': _isPublished,
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (_imageUrl != null) {
        eventData['image_url'] = _imageUrl!;
      }

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
                      // Image Upload Section
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: _imageUrl != null
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      _imageUrl!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: IconButton(
                                      onPressed: () => setState(() => _imageUrl = null),
                                      icon: const Icon(Icons.delete),
                                      style: IconButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : InkWell(
                                onTap: _pickImage,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.cloud_upload,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Click to upload event image',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
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
                  onPressed: _isLoading ? null : _saveEvent,
                  child: _isLoading
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