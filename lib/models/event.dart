import 'package:campus/models/club.dart';

class Event {
  final String id;
  final String title;
  final String? description;
  final String clubId;
  final Club? club;
  final String location;
  final DateTime startTime;
  final DateTime endTime;
  final int capacity;
  final String? category;
  final String? imageUrl;
  final bool isFeatured;
  final String? createdBy;
  final int registeredCount;
  final bool isRegistered;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Event({
    required this.id,
    required this.title,
    this.description,
    required this.clubId,
    this.club,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    this.category,
    this.imageUrl,
    this.isFeatured = false,
    this.createdBy,
    this.registeredCount = 0,
    this.isRegistered = false,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isUpcoming => startTime.isAfter(DateTime.now());
  bool get isOngoing =>
      DateTime.now().isAfter(startTime) && DateTime.now().isBefore(endTime);
  bool get isCompleted => endTime.isBefore(DateTime.now());
  bool get isFull => registeredCount >= capacity;
  int get availableSpots => capacity - registeredCount;

  EventStatus get status {
    if (isCompleted) return EventStatus.completed;
    if (isOngoing) return EventStatus.ongoing;
    return EventStatus.upcoming;
  }

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'].toString(),
      title: json['title'] as String,
      description: json['description'] as String?,
      clubId: json['club_id'].toString(),
      club: json['club'] != null ? Club.fromJson(json['club']) : null,
      location: json['location'] as String,
      startTime: DateTime.parse(json['start_time']),
      endTime: DateTime.parse(json['end_time']),
      capacity: json['capacity'] as int,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      createdBy: json['created_by'].toString(),
      registeredCount: json['registered_count'] as int? ?? 0,
      isRegistered: json['is_registered'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'club_id': clubId,
      'club': club?.toJson(),
      'location': location,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime.toIso8601String(),
      'capacity': capacity,
      'category': category,
      'image_url': imageUrl,
      'is_featured': isFeatured,
      'created_by': createdBy,
      'registered_count': registeredCount,
      'is_registered': isRegistered,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Event copyWith({
    String? id,
    String? title,
    String? description,
    String? clubId,
    Club? club,
    String? location,
    DateTime? startTime,
    DateTime? endTime,
    int? capacity,
    String? category,
    String? imageUrl,
    bool? isFeatured,
    String? createdBy,
    int? registeredCount,
    bool? isRegistered,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      clubId: clubId ?? this.clubId,
      club: club ?? this.club,
      location: location ?? this.location,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      capacity: capacity ?? this.capacity,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      isFeatured: isFeatured ?? this.isFeatured,
      createdBy: createdBy ?? this.createdBy,
      registeredCount: registeredCount ?? this.registeredCount,
      isRegistered: isRegistered ?? this.isRegistered,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

enum EventStatus { upcoming, ongoing, completed }

extension EventStatusExtension on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.upcoming:
        return 'Upcoming';
      case EventStatus.ongoing:
        return 'Ongoing';
      case EventStatus.completed:
        return 'Completed';
    }
  }
}
