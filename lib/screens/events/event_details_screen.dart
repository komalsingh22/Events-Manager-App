import 'package:flutter/material.dart';
import 'package:campus/models/event.dart';
import 'package:campus/models/user.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/event_service.dart';
import 'package:campus/utils/date_formatter.dart';
import 'package:campus/widgets/custom_app_bar.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;

  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  final _authService = AuthService();
  final _eventService = EventService();

  Event? _event;
  bool _isLoading = true;
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadEventDetails();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _event?.title ?? 'Event Details',
        actions: [
          if (_event != null && _canEditEvent())
            IconButton(
              onPressed: () {
                // TODO: Navigate to edit event screen
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _event == null
          ? _buildErrorState(theme)
          : _buildEventDetails(theme),
      bottomNavigationBar: _buildBottomBar(theme),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
          const SizedBox(height: 16),
          Text('Event not found', style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'The event you\'re looking for doesn\'t exist or has been removed.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildEventDetails(ThemeData theme) {
    final event = _event!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEventImage(theme, event),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildEventHeader(theme, event),
                const SizedBox(height: 16),
                _buildEventInfo(theme, event),
                const SizedBox(height: 24),
                _buildDescription(theme, event),
                const SizedBox(height: 24),
                _buildCapacitySection(theme, event),
                const SizedBox(height: 100), // Space for bottom bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventImage(ThemeData theme, Event event) {
    const double height = 250;

    if (event.imageUrl != null) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: Image.network(
          event.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildDefaultImage(theme, height),
        ),
      );
    } else {
      return _buildDefaultImage(theme, height);
    }
  }

  Widget _buildDefaultImage(ThemeData theme, double height) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.event,
          size: 80,
          color: theme.colorScheme.onPrimary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildEventHeader(ThemeData theme, Event event) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event.isFeatured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16, color: theme.colorScheme.onTertiary),
                const SizedBox(width: 4),
                Text(
                  'Featured',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        if (event.isFeatured) const SizedBox(height: 12),
        Text(
          event.title,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (event.club != null) _buildClubInfo(theme, event),
      ],
    );
  }

  Widget _buildClubInfo(ThemeData theme, Event event) {
    return Row(
      children: [
        if (event.club!.logoUrl != null)
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: NetworkImage(event.club!.logoUrl!),
                fit: BoxFit.cover,
              ),
            ),
          )
        else
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.secondaryContainer,
            ),
            child: Icon(
              Icons.group,
              size: 18,
              color: theme.colorScheme.secondary,
            ),
          ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.club!.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.secondary,
                ),
              ),
              if (event.category != null)
                Text(
                  event.category!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEventInfo(ThemeData theme, Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            theme,
            Icons.access_time,
            'Date & Time',
            DateFormatter.formatEventDateTime(event.startTime, event.endTime),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(theme, Icons.location_on, 'Location', event.location),
          const SizedBox(height: 16),
          _buildInfoRow(
            theme,
            Icons.people,
            'Capacity',
            '${event.registeredCount}/${event.capacity} registered',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    ThemeData theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(ThemeData theme, Event event) {
    if (event.description == null || event.description!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About this event',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(event.description!, style: theme.textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildCapacitySection(ThemeData theme, Event event) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Registration Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: event.registeredCount / event.capacity,
            backgroundColor: theme.colorScheme.outline.withValues(alpha: 0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              event.isFull
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${event.registeredCount} registered',
                style: theme.textTheme.bodyMedium,
              ),
              Text(
                '${event.availableSpots} spots left',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: event.isFull
                      ? theme.colorScheme.error
                      : theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget? _buildBottomBar(ThemeData theme) {
    if (_event == null || _event!.isCompleted) {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _getButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: _getButtonColor(theme),
              foregroundColor: _getButtonTextColor(theme),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isRegistering
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getButtonTextColor(theme),
                      ),
                    ),
                  )
                : Text(
                    _getButtonText(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: _getButtonTextColor(theme),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  VoidCallback? _getButtonAction() {
    if (_event == null || _isRegistering || _event!.isCompleted) {
      return null;
    }

    if (_event!.isFull && !_event!.isRegistered) {
      return null;
    }

    return _event!.isRegistered ? _handleUnregister : _handleRegister;
  }

  Color _getButtonColor(ThemeData theme) {
    if (_event?.isFull == true && !_event!.isRegistered) {
      return theme.colorScheme.outline.withValues(alpha: 0.3);
    }

    return _event?.isRegistered == true
        ? theme.colorScheme.error
        : theme.colorScheme.primary;
  }

  Color _getButtonTextColor(ThemeData theme) {
    if (_event?.isFull == true && !_event!.isRegistered) {
      return theme.colorScheme.onSurface.withValues(alpha: 0.5);
    }

    return _event?.isRegistered == true
        ? theme.colorScheme.onError
        : theme.colorScheme.onPrimary;
  }

  String _getButtonText() {
    if (_event?.isFull == true && !_event!.isRegistered) {
      return 'Event Full';
    }

    return _event?.isRegistered == true ? 'Unregister' : 'Register Now';
  }

  bool _canEditEvent() {
    final currentUser = _authService.currentUser;
    if (currentUser == null || _event == null) return false;

    return currentUser.role.canManageAllEvents ||
        (currentUser.role.canCreateEvents &&
            currentUser.clubId == _event!.clubId);
  }

  Future<void> _loadEventDetails() async {
    setState(() {
      _isLoading = true;
    });

    final result = await _eventService.getEventDetails(widget.eventId);

    if (result.isSuccess && result.data != null) {
      final currentUser = _authService.currentUser;
      final isUserRegistered = currentUser != null
          ? _eventService.isUserRegistered(widget.eventId, currentUser.id)
          : false;

      setState(() {
        _event = result.data!.copyWith(isRegistered: isUserRegistered);
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _handleRegister() async {
    setState(() {
      _isRegistering = true;
    });

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    final result = await _eventService.registerForEvent(
      widget.eventId,
      currentUser.id,
    );

    if (result.isSuccess) {
      // Reload event to get updated registration status
      await _loadEventDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully registered for event!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Registration failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isRegistering = false;
    });
  }

  Future<void> _handleUnregister() async {
    final confirmed = await _showUnregisterDialog();
    if (!confirmed) return;

    setState(() {
      _isRegistering = true;
    });

    final currentUser = _authService.currentUser;
    if (currentUser == null) {
      setState(() {
        _isRegistering = false;
      });
      return;
    }

    final result = await _eventService.unregisterFromEvent(
      widget.eventId,
      currentUser.id,
    );

    if (result.isSuccess) {
      // Reload event to get updated registration status
      await _loadEventDetails();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully unregistered from event'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Unregistration failed'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }

    setState(() {
      _isRegistering = false;
    });
  }

  Future<bool> _showUnregisterDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unregister from Event'),
        content: const Text(
          'Are you sure you want to unregister from this event?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Unregister'),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
