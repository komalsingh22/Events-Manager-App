import 'package:flutter/material.dart';
import 'package:campus/models/user.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/event_service.dart';
import 'package:campus/utils/constants.dart';
import 'package:campus/utils/validators.dart';
import 'package:campus/utils/date_formatter.dart';
import 'package:campus/widgets/custom_app_bar.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _capacityController = TextEditingController();
  final _imageUrlController = TextEditingController();

  final _authService = AuthService();
  final _eventService = EventService();

  DateTime? _startDateTime;
  DateTime? _endDateTime;
  String? _selectedCategory;
  bool _isFeatured = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Create Event',
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _handleSave,
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBasicInfo(theme),
              const SizedBox(height: 24),
              _buildDateTimeSection(theme),
              const SizedBox(height: 24),
              _buildLocationAndCapacity(theme),
              const SizedBox(height: 24),
              _buildCategorySection(theme),
              const SizedBox(height: 24),
              _buildImageSection(theme),
              const SizedBox(height: 24),
              _buildFeaturedSection(theme),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _titleController,
          validator: Validators.eventTitle,
          decoration: const InputDecoration(
            labelText: 'Event Title*',
            hintText: 'Enter a catchy event title',
            border: OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          validator: Validators.eventDescription,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Description*',
            hintText: 'Describe your event in detail...',
            border: OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildDateTimeSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date & Time',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildDateTimeCard(
                theme,
                'Start',
                _startDateTime,
                (dateTime) => setState(() => _startDateTime = dateTime),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildDateTimeCard(
                theme,
                'End',
                _endDateTime,
                (dateTime) => setState(() => _endDateTime = dateTime),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateTimeCard(
    ThemeData theme,
    String label,
    DateTime? dateTime,
    Function(DateTime?) onChanged,
  ) {
    return GestureDetector(
      onTap: () => _selectDateTime(label == 'Start'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$label Date & Time*',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 8),
            if (dateTime != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DateFormatter.formatDate(dateTime),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    DateFormatter.formatTime(dateTime),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              )
            else
              Text(
                'Tap to select',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationAndCapacity(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location & Capacity',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _locationController,
          validator: Validators.location,
          decoration: const InputDecoration(
            labelText: 'Location*',
            hintText: 'e.g., Main Auditorium, Room 201',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_on),
          ),
          textCapitalization: TextCapitalization.words,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _capacityController,
          validator: Validators.capacity,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Capacity*',
            hintText: 'Maximum number of attendees',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.people),
          ),
        ),
      ],
    );
  }

  Widget _buildCategorySection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedCategory,
          decoration: const InputDecoration(
            labelText: 'Event Category*',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.category),
          ),
          items: EventCategories.all
              .map(
                (category) =>
                    DropdownMenuItem(value: category, child: Text(category)),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              _selectedCategory = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select a category';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildImageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Event Image',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional: Add an image URL to make your event more appealing',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _imageUrlController,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/image.jpg',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.image),
          ),
          keyboardType: TextInputType.url,
        ),
      ],
    );
  }

  Widget _buildFeaturedSection(ThemeData theme) {
    final currentUser = _authService.currentUser;
    final canSetFeatured = currentUser?.role.canManageAllEvents ?? false;

    if (!canSetFeatured) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Featured Event',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Mark as Featured'),
          subtitle: const Text('Featured events appear in the main carousel'),
          value: _isFeatured,
          onChanged: (value) {
            setState(() {
              _isFeatured = value;
            });
          },
        ),
      ],
    );
  }

  Future<void> _selectDateTime(bool isStart) async {
    final initialDate = isStart ? _startDateTime : _endDateTime;
    final firstDate = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate:
          initialDate?.copyWith() ??
          DateTime.now().add(const Duration(days: 1)),
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        initialDate ?? DateTime.now().add(const Duration(hours: 1)),
      ),
    );

    if (time == null) return;

    final dateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    setState(() {
      if (isStart) {
        _startDateTime = dateTime;
        // Automatically set end time to 2 hours later if not set
        _endDateTime ??= dateTime.add(const Duration(hours: 2));
      } else {
        _endDateTime = dateTime;
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate date/time
    final startTimeError = Validators.dateTime(_startDateTime);
    final endTimeError = Validators.endDateTime(_startDateTime, _endDateTime);

    if (startTimeError != null) {
      _showErrorDialog('Invalid Start Time', startTimeError);
      return;
    }

    if (endTimeError != null) {
      _showErrorDialog('Invalid End Time', endTimeError);
      return;
    }

    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.clubId == null) {
      _showErrorDialog(
        'Error',
        'You must be associated with a club to create events.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await _eventService.createEvent(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      clubId: currentUser.clubId!,
      location: _locationController.text.trim(),
      startTime: _startDateTime!,
      endTime: _endDateTime!,
      capacity: int.parse(_capacityController.text.trim()),
      category: _selectedCategory!,
      imageUrl: _imageUrlController.text.trim().isEmpty
          ? null
          : _imageUrlController.text.trim(),
      isFeatured: _isFeatured,
    );

    setState(() {
      _isLoading = false;
    });

    if (result.isSuccess) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Event created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      _showErrorDialog(
        'Create Event Failed',
        result.error ?? 'Failed to create event',
      );
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
