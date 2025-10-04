import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:campus/models/event.dart';
import 'package:campus/models/event_registration.dart';
// import 'package:campus/models/club.dart';
import 'package:campus/utils/constants.dart';

class EventService {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal();

  final _uuid = const Uuid();
  SharedPreferences? _prefs;
  List<Event> _events = [];
  List<EventRegistration> _registrations = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadEvents();
    await _loadRegistrations();
  }

  Future<EventResult<List<Event>>> getEvents({
    int page = 1,
    int limit = 20,
    String? search,
    String? category,
    String? clubId,
    DateTime? startDate,
    DateTime? endDate,
    bool? featured,
  }) async {
    try {
      var filteredEvents = List<Event>.from(_events);

      // Apply filters
      if (search != null && search.isNotEmpty) {
        filteredEvents = filteredEvents
            .where(
              (event) =>
                  event.title.toLowerCase().contains(search.toLowerCase()) ||
                  (event.description?.toLowerCase().contains(
                        search.toLowerCase(),
                      ) ??
                      false),
            )
            .toList();
      }

      if (category != null && category.isNotEmpty && category != 'All') {
        filteredEvents = filteredEvents
            .where((event) => event.category == category)
            .toList();
      }

      if (clubId != null && clubId.isNotEmpty) {
        filteredEvents = filteredEvents
            .where((event) => event.clubId == clubId)
            .toList();
      }

      if (startDate != null) {
        filteredEvents = filteredEvents
            .where(
              (event) =>
                  event.startTime.isAfter(startDate) ||
                  event.startTime.isAtSameMomentAs(startDate),
            )
            .toList();
      }

      if (endDate != null) {
        filteredEvents = filteredEvents
            .where(
              (event) =>
                  event.endTime.isBefore(endDate) ||
                  event.endTime.isAtSameMomentAs(endDate),
            )
            .toList();
      }

      if (featured != null && featured) {
        filteredEvents = filteredEvents
            .where((event) => event.isFeatured)
            .toList();
      }

      // Sort by start time
      filteredEvents.sort((a, b) => a.startTime.compareTo(b.startTime));

      // Apply pagination
      final startIndex = (page - 1) * limit;
      final endIndex = startIndex + limit;

      if (startIndex >= filteredEvents.length) {
        return EventResult.success([]);
      }

      final paginatedEvents = filteredEvents.sublist(
        startIndex,
        endIndex > filteredEvents.length ? filteredEvents.length : endIndex,
      );

      return EventResult.success(paginatedEvents);
    } catch (e) {
      return EventResult.error('Failed to load events: $e');
    }
  }

  Future<EventResult<Event>> getEventDetails(String eventId) async {
    try {
      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );

      return EventResult.success(event);
    } catch (e) {
      return EventResult.error('Event not found');
    }
  }

  Future<EventResult<Event>> createEvent({
    required String title,
    required String description,
    required String clubId,
    required String location,
    required DateTime startTime,
    required DateTime endTime,
    required int capacity,
    required String category,
    String? imageUrl,
    bool isFeatured = false,
  }) async {
    try {
      final event = Event(
        id: _uuid.v4(),
        title: title,
        description: description,
        clubId: clubId,
        location: location,
        startTime: startTime,
        endTime: endTime,
        capacity: capacity,
        category: category,
        imageUrl: imageUrl,
        isFeatured: isFeatured,
        registeredCount: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _events.add(event);
      await _saveEvents();

      return EventResult.success(event);
    } catch (e) {
      return EventResult.error('Failed to create event: $e');
    }
  }

  Future<EventResult<Event>> updateEvent({
    required String eventId,
    String? title,
    String? description,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    String? category,
    String? imageUrl,
    bool? isFeatured,
  }) async {
    try {
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex == -1) {
        return EventResult.error('Event not found');
      }

      final event = _events[eventIndex];
      final updatedEvent = event.copyWith(
        title: title ?? event.title,
        description: description ?? event.description,
        location: location ?? event.location,
        startTime: startTime ?? event.startTime,
        endTime: endTime ?? event.endTime,
        capacity: capacity ?? event.capacity,
        category: category ?? event.category,
        imageUrl: imageUrl ?? event.imageUrl,
        isFeatured: isFeatured ?? event.isFeatured,
        updatedAt: DateTime.now(),
      );

      _events[eventIndex] = updatedEvent;
      await _saveEvents();

      return EventResult.success(updatedEvent);
    } catch (e) {
      return EventResult.error('Failed to update event: $e');
    }
  }

  Future<EventResult<void>> deleteEvent(String eventId) async {
    try {
      _events.removeWhere((e) => e.id == eventId);
      _registrations.removeWhere((r) => r.eventId == eventId);

      await _saveEvents();
      await _saveRegistrations();

      return EventResult.success(null);
    } catch (e) {
      return EventResult.error('Failed to delete event: $e');
    }
  }

  Future<EventResult<void>> registerForEvent(
    String eventId,
    String userId,
  ) async {
    try {
      // Check if already registered
      final existing = _registrations.where(
        (r) => r.eventId == eventId && r.userId == userId,
      );

      if (existing.isNotEmpty) {
        return EventResult.error('Already registered for this event');
      }

      final event = _events.firstWhere(
        (e) => e.id == eventId,
        orElse: () => throw Exception('Event not found'),
      );

      if (event.registeredCount >= event.capacity) {
        return EventResult.error('Event is full');
      }

      // Create registration
      final registration = EventRegistration(
        id: _uuid.v4(),
        eventId: eventId,
        userId: userId,
        registeredAt: DateTime.now(),
        status: RegistrationStatus.confirmed,
      );

      _registrations.add(registration);

      // Update event registered count
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      _events[eventIndex] = event.copyWith(
        registeredCount: event.registeredCount + 1,
        updatedAt: DateTime.now(),
      );

      await _saveEvents();
      await _saveRegistrations();

      return EventResult.success(null);
    } catch (e) {
      return EventResult.error('Failed to register for event: $e');
    }
  }

  Future<EventResult<void>> unregisterFromEvent(
    String eventId,
    String userId,
  ) async {
    try {
      final registrationIndex = _registrations.indexWhere(
        (r) => r.eventId == eventId && r.userId == userId,
      );

      if (registrationIndex == -1) {
        return EventResult.error('Not registered for this event');
      }

      _registrations.removeAt(registrationIndex);

      // Update event registered count
      final eventIndex = _events.indexWhere((e) => e.id == eventId);
      if (eventIndex != -1) {
        final event = _events[eventIndex];
        _events[eventIndex] = event.copyWith(
          registeredCount: event.registeredCount - 1,
          updatedAt: DateTime.now(),
        );
      }

      await _saveEvents();
      await _saveRegistrations();

      return EventResult.success(null);
    } catch (e) {
      return EventResult.error('Failed to unregister from event: $e');
    }
  }

  Future<EventResult<List<EventRegistration>>> getEventRegistrations(
    String eventId,
  ) async {
    try {
      final registrations = _registrations
          .where((r) => r.eventId == eventId)
          .toList();

      return EventResult.success(registrations);
    } catch (e) {
      return EventResult.error('Failed to load registrations: $e');
    }
  }

  bool isUserRegistered(String eventId, String userId) {
    return _registrations.any(
      (r) => r.eventId == eventId && r.userId == userId,
    );
  }

  Future<List<Event>> getUserRegisteredEvents(String userId) async {
    final userRegistrations = _registrations
        .where((r) => r.userId == userId)
        .toList();

    return _events
        .where(
          (event) => userRegistrations.any((reg) => reg.eventId == event.id),
        )
        .toList();
  }

  Future<EventResult<List<Event>>> getFeaturedEvents() async {
    return getEvents(featured: true, limit: 5);
  }

  Future<EventResult<List<Event>>> getUpcomingEvents({int limit = 10}) async {
    return getEvents(startDate: DateTime.now(), limit: limit);
  }

  Future<void> _loadEvents() async {
    try {
      final eventsJson = _prefs?.getString(StorageKeys.allEvents);
      if (eventsJson != null) {
        final List<dynamic> eventsList = jsonDecode(eventsJson);
        _events = eventsList
            .map((eventData) => Event.fromJson(eventData))
            .toList();
      } else {
        _events = _createSampleEvents();
        await _saveEvents();
      }
    } catch (e) {
      _events = _createSampleEvents();
      await _saveEvents();
    }
  }

  Future<void> _saveEvents() async {
    final eventsJson = _events.map((event) => event.toJson()).toList();
    await _prefs?.setString(StorageKeys.allEvents, jsonEncode(eventsJson));
  }

  Future<void> _loadRegistrations() async {
    try {
      final registrationsJson = _prefs?.getString(
        StorageKeys.eventRegistrations,
      );
      if (registrationsJson != null) {
        final List<dynamic> registrationsList = jsonDecode(registrationsJson);
        _registrations = registrationsList
            .map((regData) => EventRegistration.fromJson(regData))
            .toList();
      }
    } catch (e) {
      _registrations = [];
    }
  }

  Future<void> _saveRegistrations() async {
    final registrationsJson = _registrations
        .map((reg) => reg.toJson())
        .toList();
    await _prefs?.setString(
      StorageKeys.eventRegistrations,
      jsonEncode(registrationsJson),
    );
  }

  List<Event> _createSampleEvents() {
    final now = DateTime.now();
    return [
      Event(
        id: '1',
        title: 'Tech Talk: AI in Software Development',
        description:
            'Join us for an exciting discussion about the role of artificial intelligence in modern software development. Learn about the latest tools and techniques.',
        clubId: '1',
        location: 'Engineering Building - Room 201',
        startTime: now.add(const Duration(days: 3, hours: 2)),
        endTime: now.add(const Duration(days: 3, hours: 4)),
        capacity: 50,
        category: 'Technology',
        imageUrl:
            'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=500',
        isFeatured: true,
        registeredCount: 23,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      Event(
        id: '2',
        title: 'Basketball Tournament',
        description:
            'Annual inter-college basketball tournament. Register your team now and compete for the championship trophy!',
        clubId: '2',
        location: 'Sports Complex - Main Court',
        startTime: now.add(const Duration(days: 7)),
        endTime: now.add(const Duration(days: 7, hours: 6)),
        capacity: 100,
        category: 'Sports',
        imageUrl:
            'https://images.unsplash.com/photo-1546519638-68e109498ffc?w=500',
        isFeatured: true,
        registeredCount: 45,
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Event(
        id: '3',
        title: 'Cultural Night',
        description:
            'Celebrate diversity with performances from around the world. Music, dance, and food from different cultures.',
        clubId: '3',
        location: 'Student Union - Main Hall',
        startTime: now.add(const Duration(days: 14, hours: 6)),
        endTime: now.add(const Duration(days: 14, hours: 10)),
        capacity: 200,
        category: 'Cultural',
        imageUrl:
            'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=500',
        isFeatured: true,
        registeredCount: 87,
        createdAt: now.subtract(const Duration(days: 15)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Event(
        id: '4',
        title: 'Startup Pitch Competition',
        description:
            'Present your innovative startup ideas to a panel of investors and industry experts. Cash prizes available!',
        clubId: '4',
        location: 'Business School - Auditorium',
        startTime: now.add(const Duration(days: 21, hours: 1)),
        endTime: now.add(const Duration(days: 21, hours: 5)),
        capacity: 80,
        category: 'Business',
        imageUrl:
            'https://images.unsplash.com/photo-1556761175-5973dc0f32e7?w=500',
        isFeatured: false,
        registeredCount: 34,
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      Event(
        id: '5',
        title: 'Photography Workshop',
        description:
            'Learn the fundamentals of photography from professional photographers. Bring your camera!',
        clubId: '5',
        location: 'Art Building - Studio 1',
        startTime: now.add(const Duration(days: 2, hours: 3)),
        endTime: now.add(const Duration(days: 2, hours: 6)),
        capacity: 25,
        category: 'Workshop',
        imageUrl:
            'https://images.unsplash.com/photo-1606983340126-99ab4feaa64d?w=500',
        isFeatured: false,
        registeredCount: 18,
        createdAt: now.subtract(const Duration(days: 12)),
        updatedAt: now.subtract(const Duration(days: 12)),
      ),
    ];
  }
}

class EventResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  EventResult._({this.data, this.error, required this.isSuccess});

  factory EventResult.success(T? data) {
    return EventResult._(data: data, isSuccess: true);
  }

  factory EventResult.error(String error) {
    return EventResult._(error: error, isSuccess: false);
  }
}
