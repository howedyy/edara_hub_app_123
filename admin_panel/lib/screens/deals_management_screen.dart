import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class DealsManagementScreen extends StatefulWidget {
  const DealsManagementScreen({super.key});

  @override
  State<DealsManagementScreen> createState() => _DealsManagementScreenState();
}

class _DealsManagementScreenState extends State<DealsManagementScreen> {
  String _filterStatus = 'all'; // 'all', 'published', 'draft', 'expired'

  Stream<QuerySnapshot> _getDealsStream() {
    Query query = FirebaseFirestore.instance.collection('deals');
    
    if (_filterStatus == 'published') {
      query = query.where('is_published', isEqualTo: true);
    } else if (_filterStatus == 'draft') {
      query = query.where('is_published', isEqualTo: false);
    }
    
    return query.orderBy('created_at', descending: true).snapshots();
  }

  Future<void> _createDeal() async {
    await showDialog(
      context: context,
      builder: (context) => const DealFormDialog(),
    );
  }

  Future<void> _editDeal(String dealId, Map<String, dynamic> dealData) async {
    await showDialog(
      context: context,
      builder: (context) => DealFormDialog(
        dealId: dealId,
        initialData: dealData,
      ),
    );
  }

  Future<void> _deleteDeal(String dealId, Map<String, dynamic> dealData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Deal'),
        content: Text('Are you sure you want to delete "${dealData['title']}"?'),
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
      await FirebaseFirestore.instance.collection('deals').doc(dealId).delete();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deal deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting deal: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePublishStatus(String dealId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('deals').doc(dealId).update({
        'is_published': !currentStatus,
        'updated_at': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              currentStatus ? 'Deal unpublished' : 'Deal published successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating deal: $e'),
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
                onPressed: _createDeal,
                icon: const Icon(Icons.add),
                label: const Text('Create Deal'),
              ),
            ],
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _getDealsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              final deals = snapshot.data!.docs;

              if (deals.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No deals found',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton.icon(
                        onPressed: _createDeal,
                        icon: const Icon(Icons.add),
                        label: const Text('Create First Deal'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final dealDoc = deals[index];
                  final dealData = dealDoc.data() as Map<String, dynamic>;
                  final dealId = dealDoc.id;
                  final isPublished = dealData['is_published'] ?? false;
                  final validUntil = (dealData['valid_until'] as Timestamp?)?.toDate();
                  final isExpired = validUntil != null && DateTime.now().isAfter(validUntil);

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (dealData['image_url'] != null)
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              dealData['image_url'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.local_offer, size: 64),
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
                                      dealData['title'] ?? 'Untitled',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isExpired)
                                    const Chip(
                                      label: Text(
                                        'Expired',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      backgroundColor: Colors.red,
                                    )
                                  else
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
                                dealData['description'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const Divider(height: 24),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.attach_money,
                                      'Price',
                                      '\$${dealData['original_price']} → \$${dealData['discounted_price']}',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.percent,
                                      'Discount',
                                      '${dealData['discount_percentage']}% OFF',
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.category,
                                      'Category',
                                      dealData['category'] ?? 'N/A',
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.calendar_today,
                                      'Valid Until',
                                      _formatTimestamp(dealData['valid_until']),
                                    ),
                                  ),
                                  Expanded(
                                    child: _buildInfoItem(
                                      Icons.visibility,
                                      'Visibility',
                                      dealData['visibility'] == 'all_users'
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
                                    onPressed: () => _deleteDeal(dealId, dealData),
                                    icon: const Icon(Icons.delete),
                                    label: const Text('Delete'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton.icon(
                                    onPressed: () => _editDeal(dealId, dealData),
                                    icon: const Icon(Icons.edit),
                                    label: const Text('Edit'),
                                  ),
                                  const SizedBox(width: 8),
                                  if (!isExpired)
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _togglePublishStatus(dealId, isPublished),
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


// Deal Form Dialog for creating and editing deals
class DealFormDialog extends StatefulWidget {
  final String? dealId;
  final Map<String, dynamic>? initialData;

  const DealFormDialog({
    super.key,
    this.dealId,
    this.initialData,
  });

  @override
  State<DealFormDialog> createState() => _DealFormDialogState();
}

class _DealFormDialogState extends State<DealFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();
  final _categoryController = TextEditingController();
  
  DateTime? _validUntil;
  String _visibility = 'all_users';
  List<String> _selectedUsers = [];
  List<Map<String, dynamic>> _availableUsers = [];
  bool _isLoading = false;
  String? _imageUrl;
  bool _isPublished = false;
  int _discountPercentage = 0;

  @override
  void initState() {
    super.initState();
    _loadAvailableUsers();
    
    if (widget.initialData != null) {
      _populateForm();
    }
    
    // Add listeners to calculate discount percentage
    _originalPriceController.addListener(_calculateDiscount);
    _discountedPriceController.addListener(_calculateDiscount);
  }

  void _calculateDiscount() {
    final original = double.tryParse(_originalPriceController.text) ?? 0;
    final discounted = double.tryParse(_discountedPriceController.text) ?? 0;
    
    if (original > 0 && discounted > 0 && discounted < original) {
      setState(() {
        _discountPercentage = (((original - discounted) / original) * 100).round();
      });
    } else {
      setState(() {
        _discountPercentage = 0;
      });
    }
  }

  void _populateForm() {
    final data = widget.initialData!;
    _titleController.text = data['title'] ?? '';
    _descriptionController.text = data['description'] ?? '';
    _originalPriceController.text = (data['original_price'] ?? '').toString();
    _discountedPriceController.text = (data['discounted_price'] ?? '').toString();
    _categoryController.text = data['category'] ?? '';
    _visibility = data['visibility'] ?? 'all_users';
    _selectedUsers = List<String>.from(data['allowed_users'] ?? []);
    _imageUrl = data['image_url'];
    _isPublished = data['is_published'] ?? false;
    _discountPercentage = data['discount_percentage'] ?? 0;
    
    if (data['valid_until'] != null) {
      _validUntil = (data['valid_until'] as Timestamp).toDate();
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
      initialDate: _validUntil ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      setState(() => _validUntil = date);
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
        final fileName = 'deals/${DateTime.now().millisecondsSinceEpoch}_${file.name}';
        
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

  Future<void> _saveDeal() async {
    if (!_formKey.currentState!.validate()) return;
    if (_validUntil == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select valid until date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dealData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'original_price': double.parse(_originalPriceController.text),
        'discounted_price': double.parse(_discountedPriceController.text),
        'discount_percentage': _discountPercentage,
        'category': _categoryController.text.trim(),
        'valid_until': Timestamp.fromDate(_validUntil!),
        'visibility': _visibility,
        'allowed_users': _visibility == 'selected_users' ? _selectedUsers : [],
        'is_published': _isPublished,
        'updated_at': FieldValue.serverTimestamp(),
        'wishlist': [],
      };

      if (_imageUrl != null) {
        dealData['image_url'] = _imageUrl!;
      }

      if (widget.dealId != null) {
        // Update existing deal
        await FirebaseFirestore.instance
            .collection('deals')
            .doc(widget.dealId)
            .update(dealData);
      } else {
        // Create new deal
        dealData['created_at'] = FieldValue.serverTimestamp();
        dealData['created_by'] = 'admin'; // TODO: Get actual admin ID
        await FirebaseFirestore.instance.collection('deals').add(dealData);
      }

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.dealId != null 
                  ? 'Deal updated successfully' 
                  : 'Deal created successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving deal: $e'),
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
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    _categoryController.dispose();
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
                  widget.dealId != null ? 'Edit Deal' : 'Create Deal',
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
                                      'Click to upload deal image',
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
                          labelText: 'Deal Title *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter deal title';
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
                            return 'Please enter deal description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _originalPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Original Price *',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Invalid number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _discountedPriceController,
                              decoration: const InputDecoration(
                                labelText: 'Discounted Price *',
                                border: OutlineInputBorder(),
                                prefixText: '\$ ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Required';
                                }
                                final price = double.tryParse(value);
                                if (price == null) {
                                  return 'Invalid number';
                                }
                                final original = double.tryParse(_originalPriceController.text) ?? 0;
                                if (price >= original) {
                                  return 'Must be less than original';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.green[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '$_discountPercentage%',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                                const Text('OFF', style: TextStyle(fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _categoryController,
                              decoration: const InputDecoration(
                                labelText: 'Category *',
                                border: OutlineInputBorder(),
                                hintText: 'e.g., Electronics, Fashion',
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter category';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: InkWell(
                              onTap: _selectDate,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Valid Until *',
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _validUntil != null
                                      ? DateFormat('MMM dd, yyyy').format(_validUntil!)
                                      : 'Select date',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Visibility Settings
                      const Text(
                        'Deal Visibility',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      
                      RadioListTile<String>(
                        title: const Text('All Users'),
                        subtitle: const Text('All approved users can see this deal'),
                        value: 'all_users',
                        groupValue: _visibility,
                        onChanged: (value) => setState(() => _visibility = value!),
                      ),
                      
                      RadioListTile<String>(
                        title: const Text('Selected Users'),
                        subtitle: const Text('Only selected users can see this deal'),
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
                        title: const Text('Publish Deal'),
                        subtitle: Text(
                          _isPublished 
                              ? 'Deal will be visible to users' 
                              : 'Deal will be saved as draft',
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
                  onPressed: _isLoading ? null : _saveDeal,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.dealId != null ? 'Update Deal' : 'Create Deal'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
