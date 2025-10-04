import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:campus/models/user.dart';
import 'package:campus/utils/constants.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final _uuid = const Uuid();
  User? _currentUser;
  SharedPreferences? _prefs;
  List<User> _users = [];

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUsers();
    await _loadCurrentUser();
  }

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    try {
      // Find user by email
      final user = _users.firstWhere(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
        orElse: () => throw Exception('User not found'),
      );

      // In a real app, you'd verify the password hash
      // For demo purposes, accept any password for existing users
      await _saveCurrentUser(user);
      _currentUser = user;

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Invalid email or password');
    }
  }

  Future<AuthResult> signup({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required UserRole role,
    String? clubId,
  }) async {
    // Validate that role is either student or superAdmin
    if (role != UserRole.student && role != UserRole.superAdmin) {
      return AuthResult.error('Invalid user role');
    }
    try {
      // Check if user already exists
      final existingUser = _users.where(
        (u) => u.email.toLowerCase() == email.toLowerCase(),
      );

      if (existingUser.isNotEmpty) {
        return AuthResult.error('An account with this email already exists');
      }

      // Create new user
      final user = User(
        id: _uuid.v4(),
        email: email,
        firstName: firstName,
        lastName: lastName,
        role: role,
        clubId: clubId,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      _users.add(user);
      await _saveUsers();
      await _saveCurrentUser(user);
      _currentUser = user;

      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Signup failed: $e');
    }
  }

  Future<void> logout() async {
    try {
      await _clearCurrentUser();
      _currentUser = null;
    } catch (e) {
      await _clearCurrentUser();
      _currentUser = null;
    }
  }

  Future<bool> refreshCurrentUser() async {
    try {
      if (_currentUser != null) {
        // Find updated user data
        final updatedUser = _users.firstWhere(
          (u) => u.id == _currentUser!.id,
          orElse: () => _currentUser!,
        );

        if (updatedUser != _currentUser) {
          _currentUser = updatedUser;
          await _saveCurrentUser(updatedUser);
        }
        return true;
      }
    } catch (e) {
      // Failed to refresh user data
    }
    return false;
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userJson = _prefs?.getString(StorageKeys.currentUser);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = User.fromJson(userData);
      }
    } catch (e) {
      await _clearCurrentUser();
    }
  }

  Future<void> _saveCurrentUser(User user) async {
    await _prefs?.setString(StorageKeys.currentUser, jsonEncode(user.toJson()));
  }

  Future<void> _clearCurrentUser() async {
    await _prefs?.remove(StorageKeys.currentUser);
  }

  Future<void> _loadUsers() async {
    try {
      final usersJson = _prefs?.getString(StorageKeys.allUsers);
      if (usersJson != null) {
        final List<dynamic> usersList = jsonDecode(usersJson);
        _users = usersList.map((userData) => User.fromJson(userData)).toList();
      } else {
        // Initialize with sample users
        _users = _createSampleUsers();
        await _saveUsers();
      }
    } catch (e) {
      _users = _createSampleUsers();
      await _saveUsers();
    }
  }

  Future<void> _saveUsers() async {
    final usersJson = _users.map((user) => user.toJson()).toList();
    await _prefs?.setString(StorageKeys.allUsers, jsonEncode(usersJson));
  }

  List<User> _createSampleUsers() {
    return [
      User(
        id: '1',
        email: 'admin@university.edu',
        firstName: 'Admin',
        lastName: 'User',
        role: UserRole.superAdmin,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        updatedAt: DateTime.now(),
      ),
      User(
        id: '4',
        email: 'john.student@university.edu',
        firstName: 'John',
        lastName: 'Student',
        role: UserRole.student,
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}

class AuthResult {
  final User? user;
  final String? error;
  final bool isSuccess;

  AuthResult._({this.user, this.error, required this.isSuccess});

  factory AuthResult.success(User user) {
    return AuthResult._(user: user, isSuccess: true);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(error: error, isSuccess: false);
  }
}
