import 'package:flutter/material.dart';
import 'package:campus/models/event.dart';
import 'package:campus/models/user.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/event_service.dart';
import 'package:campus/widgets/custom_app_bar.dart';
import 'package:campus/widgets/event_card.dart';
import 'package:campus/screens/events/create_event_screen.dart';
import 'package:campus/screens/events/event_details_screen.dart';

class ClubDashboardScreen extends StatefulWidget {
  const ClubDashboardScreen({super.key});

  @override
  State<ClubDashboardScreen> createState() => _ClubDashboardScreenState();
}

class _ClubDashboardScreenState extends State<ClubDashboardScreen>
    with SingleTickerProviderStateMixin {
  final _authService = AuthService();
  final _eventService = EventService();

  late TabController _tabController;
  List<Event> _upcomingEvents = [];
  List<Event> _pastEvents = [];

  bool _isLoadingUpcoming = true;
  bool _isLoadingPast = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadEvents();
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

    if (currentUser == null || !currentUser.role.canCreateEvents) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Dashboard'),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text('Access Denied', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                'You don\'t have permission to access this dashboard.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Club Dashboard',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildUpcomingTab(theme), _buildPastTab(theme)],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateEvent,
        icon: const Icon(Icons.add),
        label: const Text('Create Event'),
      ),
    );
  }

  Widget _buildUpcomingTab(ThemeData theme) {
    if (_isLoadingUpcoming) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_upcomingEvents.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.event_available,
        'No upcoming events',
        'Create your first event to get started!',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: _upcomingEvents.length,
        itemBuilder: (context, index) {
          final event = _upcomingEvents[index];
          return EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
          );
        },
      ),
    );
  }

  Widget _buildPastTab(ThemeData theme) {
    if (_isLoadingPast) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_pastEvents.isEmpty) {
      return _buildEmptyState(
        theme,
        Icons.history,
        'No past events',
        'Your completed events will appear here.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadEvents,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
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

  Future<void> _loadEvents() async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingUpcoming = true;
      _isLoadingPast = true;
    });

    // Load upcoming events
    final upcomingResult = await _eventService.getEvents(
      startDate: DateTime.now(),
      clubId: currentUser.role.canManageAllEvents ? null : currentUser.clubId,
    );

    if (upcomingResult.isSuccess && upcomingResult.data != null) {
      setState(() {
        _upcomingEvents = upcomingResult.data!;
      });
    }

    setState(() {
      _isLoadingUpcoming = false;
    });

    // Load past events
    final pastResult = await _eventService.getEvents(
      endDate: DateTime.now(),
      clubId: currentUser.role.canManageAllEvents ? null : currentUser.clubId,
    );

    if (pastResult.isSuccess && pastResult.data != null) {
      setState(() {
        _pastEvents = pastResult.data!;
      });
    }

    setState(() {
      _isLoadingPast = false;
    });
  }

  void _navigateToCreateEvent() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateEventScreen()),
    ).then((_) {
      // Refresh events when returning from create screen
      _loadEvents();
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
}
