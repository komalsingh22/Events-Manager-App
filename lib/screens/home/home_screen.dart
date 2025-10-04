import 'dart:async';
import 'package:flutter/material.dart';
import 'package:campus/models/event.dart';
import 'package:campus/models/user.dart';
import 'package:campus/services/auth_service.dart';
import 'package:campus/services/event_service.dart';
import 'package:campus/widgets/banner_carosuel.dart';
import 'package:campus/widgets/event_card.dart';
import 'package:campus/widgets/search_filter_bar.dart';
import 'package:campus/screens/events/event_details_screen.dart';
import 'package:campus/screens/dashboard/club_dashboard_screen.dart';
import 'package:campus/screens/profile/profile_screen.dart';
import 'package:campus/screens/auth/login_screen.dart';
import 'package:campus/utils/constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _eventService = EventService();
  final _scrollController = ScrollController();

  List<Event> _featuredEvents = [];
  List<Event> _events = [];

  bool _isLoadingFeatured = true;
  bool _isLoadingEvents = true;
  bool _isLoadingMore = false;
  bool _hasMoreEvents = true;

  String? _searchQuery;
  String? _selectedCategory;
  DateTimeRange? _selectedDateRange;
  bool _showSearchBar = false;

  int _currentPage = 1;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadFeaturedEvents();
    _loadEvents();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      body: _buildBody(theme, currentUser),
      bottomNavigationBar: _buildBottomNavBar(theme, currentUser),
    );
  }

  Widget _buildBody(ThemeData theme, User currentUser) {
    // For admin users: Home (0), Dashboard (1), Profile (2)
    // For student users: Home (0), Profile (1)

    if (_currentIndex == 1 && currentUser.role.canCreateEvents) {
      return const ClubDashboardScreen();
    } else if ((_currentIndex == 2 && currentUser.role.canCreateEvents) ||
        (_currentIndex == 1 && !currentUser.role.canCreateEvents)) {
      return const ProfileScreen();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          _buildAppBar(theme, currentUser),
          if (_showSearchBar) _buildSearchBar(),
          if (!_showSearchBar && _featuredEvents.isNotEmpty)
            _buildFeaturedSection(),
          _buildEventsSection(theme),
        ],
      ),
    );
  }

  Widget _buildAppBar(ThemeData theme, User currentUser) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: theme.appBarTheme.backgroundColor,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event,
              size: 18,
              color: theme.colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'GatherUp',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {
            setState(() {
              _showSearchBar = !_showSearchBar;
            });
          },
          icon: Icon(_showSearchBar ? Icons.close : Icons.search),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: SearchFilterBar(
        searchQuery: _searchQuery,
        selectedCategory: _selectedCategory,
        dateRange: _selectedDateRange,
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query.isEmpty ? null : query;
          });
          _debounceSearch();
        },
        onCategoryChanged: (category) {
          setState(() {
            _selectedCategory = category;
          });
          _loadEvents(reset: true);
        },
        onDateRangeChanged: (dateRange) {
          setState(() {
            _selectedDateRange = dateRange;
          });
          _loadEvents(reset: true);
        },
        onClearFilters: () {
          setState(() {
            _searchQuery = null;
            _selectedCategory = null;
            _selectedDateRange = null;
          });
          _loadEvents(reset: true);
        },
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Featured Events',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          _isLoadingFeatured
              ? const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                )
              : BannerCarousel(
                  featuredEvents: _featuredEvents,
                  onEventTap: _navigateToEventDetails,
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildEventsSection(ThemeData theme) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _showSearchBar ? 'Search Results' : 'Upcoming Events',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _buildEventsList(theme),
        ],
      ),
    );
  }

  Widget _buildEventsList(ThemeData theme) {
    if (_isLoadingEvents && _events.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_events.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No events found',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your search or filters',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        ..._events.map(
          (event) => EventCard(
            event: event,
            onTap: () => _navigateToEventDetails(event),
          ),
        ),
        if (_isLoadingMore)
          const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
        const SizedBox(height: 80), // Bottom padding for navigation bar
      ],
    );
  }

  Widget _buildBottomNavBar(ThemeData theme, User currentUser) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
      if (currentUser.role.canCreateEvents)
        const BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Dashboard',
        ),
      const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
    ];

    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: items,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: theme.colorScheme.primary,
      unselectedItemColor: theme.colorScheme.onSurface.withValues(alpha: 0.6),
      backgroundColor: theme.colorScheme.surface,
    );
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoadingMore && _hasMoreEvents) {
        _loadMoreEvents();
      }
    }
  }

  Future<void> _onRefresh() async {
    await Future.wait([_loadFeaturedEvents(), _loadEvents(reset: true)]);
  }

  Future<void> _loadFeaturedEvents() async {
    setState(() {
      _isLoadingFeatured = true;
    });

    final result = await _eventService.getFeaturedEvents();

    if (result.isSuccess && result.data != null) {
      setState(() {
        _featuredEvents = result.data!;
      });
    }

    setState(() {
      _isLoadingFeatured = false;
    });
  }

  Future<void> _loadEvents({bool reset = false}) async {
    if (reset) {
      setState(() {
        _currentPage = 1;
        _hasMoreEvents = true;
        _isLoadingEvents = true;
      });
    }

    final result = await _eventService.getEvents(
      page: _currentPage,
      limit: AppConstants.itemsPerPage,
      search: _searchQuery,
      category: _selectedCategory,
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
    );

    if (result.isSuccess && result.data != null) {
      setState(() {
        if (reset) {
          _events = result.data!;
        } else {
          _events.addAll(result.data!);
        }

        _hasMoreEvents = result.data!.length == AppConstants.itemsPerPage;
        if (!reset) _currentPage++;
      });
    }

    setState(() {
      _isLoadingEvents = false;
    });
  }

  Future<void> _loadMoreEvents() async {
    setState(() {
      _isLoadingMore = true;
    });

    await _loadEvents();

    setState(() {
      _isLoadingMore = false;
    });
  }

  Timer? _debounceTimer;
  void _debounceSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _loadEvents(reset: true);
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
