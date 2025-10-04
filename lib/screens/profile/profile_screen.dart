import 'package:flutter/material.dart';
import 'package:campus/models/user.dart';
import 'package:campus/models/event.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/event_service.dart';
import 'package:campus/widgets/custom_app_bar.dart';
import 'package:campus/widgets/event_card.dart';
import 'package:campus/screens/events/event_details_screen.dart';
import 'package:campus/screens/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _eventService = EventService();

  late TabController _tabController;
  List<Event> _registeredEvents = [];
  List<Event> _pastEvents = [];

  bool _isLoadingEvents = true;
  final bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserEvents();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUser = _authService.currentUser;

    if (currentUser == null) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Profile',
        actions: [
          IconButton(
            onPressed: _showLogoutDialog,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildProfileHeader(theme, currentUser),
          _buildTabBar(theme),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildRegisteredTab(theme), _buildPastTab(theme)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(ThemeData theme, User user) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildAvatar(theme, user),
          const SizedBox(height: 16),
          Text(
            user.fullName,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onPrimaryContainer.withValues(
                alpha: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildRoleChip(theme, user),
        ],
      ),
    );
  }

  Widget _buildAvatar(ThemeData theme, User user) {
    return GestureDetector(
      onTap: _showEditProfileDialog,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.onPrimaryContainer.withValues(
                  alpha: 0.2,
                ),
                width: 3,
              ),
            ),
            child: ClipOval(
              child: user.avatarUrl != null
                  ? Image.network(
                      user.avatarUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: theme.colorScheme.primary,
                        child: Icon(
                          Icons.person,
                          size: 48,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Container(
                      color: theme.colorScheme.primary,
                      child: Icon(
                        Icons.person,
                        size: 48,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.colorScheme.primaryContainer,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.edit,
                size: 16,
                color: theme.colorScheme.onSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(ThemeData theme, User user) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        user.role.displayName,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSecondary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTabBar(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Registered Events'),
          Tab(text: 'Past Events'),
        ],
        indicator: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: theme.colorScheme.onPrimary,
        unselectedLabelColor: theme.colorScheme.onSurface,
        dividerHeight: 0,
      ),
    );
  }

  Widget _buildRegisteredTab(ThemeData theme) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcomingEvents = _registeredEvents
        .where((event) => event.isUpcoming)
        .toList();

    if (upcomingEvents.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.event_available,
        'No upcoming events',
        'Events you register for will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = upcomingEvents[index];
          return EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
          );
        },
      ),
    );
  }

  Widget _buildPastTab(ThemeData theme) {
    if (_isLoadingEvents) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pastEvents.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.history,
        'No past events',
        'Events you\'ve attended will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 16),
        itemCount: _pastEvents.length,
        itemBuilder: (context, index) {
          final event = _pastEvents[index];
          return EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    ThemeData theme,
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _loadUserEvents() async {
    setState(() {
      _isLoadingEvents = true;
    });

    final currentUser = _authService.currentUser;
    if (currentUser != null) {
      final allEvents = await _eventService.getUserRegisteredEvents(
        currentUser.id,
      );

      setState(() {
        _registeredEvents = allEvents
            .where((event) => !event.isCompleted)
            .toList();
        _pastEvents = allEvents.where((event) => event.isCompleted).toList();
      });
    }

    setState(() {
      _isLoadingEvents = false;
    });
  }

  void _navigateToEventDetails(Event event) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EventDetailsScreen(eventId: event.id),
      ),
    );
  }

  void _showEditProfileDialog() {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final firstNameController = TextEditingController(
      text: currentUser.firstName,
    );
    final lastNameController = TextEditingController(
      text: currentUser.lastName,
    );
    final avatarUrlController = TextEditingController(
      text: currentUser.avatarUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: firstNameController,
                decoration: const InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastNameController,
                decoration: const InputDecoration(
                  labelText: 'Last Name',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: avatarUrlController,
                decoration: const InputDecoration(
                  labelText: 'Avatar URL (optional)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _updateProfile(
              firstNameController.text.trim(),
              lastNameController.text.trim(),
              avatarUrlController.text.trim(),
            ),
            child: _isUpdatingProfile
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProfile(
    String firstName,
    String lastName,
    String avatarUrl,
  ) async {
    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('First name and last name are required'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // For demo purposes, just close the dialog with a success message
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile update is not implemented in demo mode'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(onPressed: _handleLogout, child: const Text('Logout')),
        ],
      ),
    );
  }

  Future<void> _handleLogout() async {
    Navigator.pop(context); // Close dialog

    await _authService.logout();

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }
}
