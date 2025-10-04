class ApiConstants {
  // TODO: Replace with your actual backend URL
  static const String baseUrl = 'http://localhost:3000/api';

  // Auth endpoints
  static const String login = '$baseUrl/auth/login';
  static const String signup = '$baseUrl/auth/signup';
  static const String refresh = '$baseUrl/auth/refresh';
  static const String me = '$baseUrl/auth/me';

  // Event endpoints
  static const String events = '$baseUrl/events';
  static String eventDetails(String id) => '$events/$id';
  static String eventRegister(String id) => '$events/$id/register';

  // User endpoints
  static const String profile = '$baseUrl/users/profile';
  static String userEvents(String id) => '$baseUrl/users/$id/events';

  // Club endpoints
  static const String clubs = '$baseUrl/clubs';
  static String clubDetails(String id) => '$clubs/$id';
  static String clubEvents(String id) => '$clubs/$id/events';
}

class StorageKeys {
  static const String currentUser = 'current_user';
  static const String allUsers = 'all_users';
  static const String allEvents = 'all_events';
  static const String eventRegistrations = 'event_registrations';
  static const String allClubs = 'all_clubs';
}

class EventCategories {
  static const List<String> all = [
    'Academic',
    'Sports',
    'Cultural',
    'Technology',
    'Business',
    'Social',
    'Volunteer',
    'Workshop',
    'Conference',
    'Other',
  ];
}

class AppConstants {
  static const String appName = 'GatherUp';
  static const int itemsPerPage = 20;
  static const int searchDebounceMs = 500;
  static const int maxImageSizeMB = 5;
}
