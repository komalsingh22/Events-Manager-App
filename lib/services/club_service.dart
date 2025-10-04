import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:campus/models/club.dart';
import 'package:campus/utils/constants.dart';

class ClubService {
  static final ClubService _instance = ClubService._internal();
  factory ClubService() => _instance;
  ClubService._internal();

  final _uuid = const Uuid();
  SharedPreferences? _prefs;
  List<Club> _clubs = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadClubs();
  }

  Future<ClubResult<List<Club>>> getClubs() async {
    try {
      return ClubResult.success(_clubs);
    } catch (e) {
      return ClubResult.error('Failed to load clubs: $e');
    }
  }

  Future<ClubResult<Club>> getClubDetails(String clubId) async {
    try {
      final club = _clubs.firstWhere(
        (c) => c.id == clubId,
        orElse: () => throw Exception('Club not found'),
      );

      return ClubResult.success(club);
    } catch (e) {
      return ClubResult.error('Club not found');
    }
  }

  Future<ClubResult<Club>> createClub({
    required String name,
    required String description,
    required String category,
    String? logoUrl,
    String? contactEmail,
    String? contactPhone,
  }) async {
    try {
      final club = Club(
        id: _uuid.v4(),
        name: name,
        description: description,
        category: category,
        logoUrl: logoUrl,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        memberCount: 0,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _clubs.add(club);
      await _saveClubs();

      return ClubResult.success(club);
    } catch (e) {
      return ClubResult.error('Failed to create club: $e');
    }
  }

  Future<void> _loadClubs() async {
    try {
      final clubsJson = _prefs?.getString(StorageKeys.allClubs);
      if (clubsJson != null) {
        final List<dynamic> clubsList = jsonDecode(clubsJson);
        _clubs = clubsList.map((clubData) => Club.fromJson(clubData)).toList();
      } else {
        _clubs = _createSampleClubs();
        await _saveClubs();
      }
    } catch (e) {
      _clubs = _createSampleClubs();
      await _saveClubs();
    }
  }

  Future<void> _saveClubs() async {
    final clubsJson = _clubs.map((club) => club.toJson()).toList();
    await _prefs?.setString(StorageKeys.allClubs, jsonEncode(clubsJson));
  }

  List<Club> _createSampleClubs() {
    final now = DateTime.now();
    return [
      Club(
        id: '1',
        name: 'Tech Club',
        description: 'Exploring the latest in technology and programming',
        category: 'Technology',
        logoUrl:
            'https://images.unsplash.com/photo-1518709268805-4e9042af2176?w=200',
        contactEmail: 'tech.club@university.edu',
        memberCount: 156,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 365)),
        updatedAt: now.subtract(const Duration(days: 30)),
      ),
      Club(
        id: '2',
        name: 'Sports Club',
        description: 'Promoting physical fitness and sportsmanship',
        category: 'Sports',
        logoUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=200',
        contactEmail: 'sports.club@university.edu',
        memberCount: 234,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 300)),
        updatedAt: now.subtract(const Duration(days: 20)),
      ),
      Club(
        id: '3',
        name: 'Cultural Society',
        description: 'Celebrating diversity and cultural exchange',
        category: 'Cultural',
        logoUrl:
            'https://images.unsplash.com/photo-1533174072545-7a4b6ad7a6c3?w=200',
        contactEmail: 'cultural.society@university.edu',
        memberCount: 189,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 280)),
        updatedAt: now.subtract(const Duration(days: 15)),
      ),
      Club(
        id: '4',
        name: 'Business Club',
        description: 'Developing entrepreneurial skills and business acumen',
        category: 'Business',
        logoUrl:
            'https://images.unsplash.com/photo-1556761175-b413da4baf72?w=200',
        contactEmail: 'business.club@university.edu',
        memberCount: 127,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 250)),
        updatedAt: now.subtract(const Duration(days: 10)),
      ),
      Club(
        id: '5',
        name: 'Photography Club',
        description: 'Capturing moments and exploring visual storytelling',
        category: 'Arts',
        logoUrl:
            'https://images.unsplash.com/photo-1606983340126-99ab4feaa64d?w=200',
        contactEmail: 'photography.club@university.edu',
        memberCount: 98,
        isActive: true,
        createdAt: now.subtract(const Duration(days: 200)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }
}

class ClubResult<T> {
  final T? data;
  final String? error;
  final bool isSuccess;

  ClubResult._({this.data, this.error, required this.isSuccess});

  factory ClubResult.success(T? data) {
    return ClubResult._(data: data, isSuccess: true);
  }

  factory ClubResult.error(String error) {
    return ClubResult._(error: error, isSuccess: false);
  }
}
