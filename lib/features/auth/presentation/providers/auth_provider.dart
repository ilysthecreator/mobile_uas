import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_mobile/features/auth/data/models/user_model.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;

  // In-memory registered accounts (Empty initially for database connection)
  final List<UserModel> _mockUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<UserModel> get mockUsers => _mockUsers;

  AuthProvider() {
    _loadSession();
  }

  // Load user session & theme from SharedPreferences
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme
    final isDark = prefs.getBool('is_dark_theme') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Session
    final userJson = prefs.getString('user_session');
    if (userJson != null) {
      try {
        _currentUser = UserModel.fromJson(userJson);
      } catch (e) {
        // Clear corrupt session
        await prefs.remove('user_session');
      }
    }
    notifyListeners();
  }

  // Toggle Theme
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', isDark);
    notifyListeners();
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    // Simulate network latency
    await Future.delayed(const Duration(milliseconds: 1200));

    // Simple mock auth matching
    try {
      final userIndex = _mockUsers.indexWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase() && password == 'password',
      );

      if (userIndex != -1) {
        _currentUser = _mockUsers[userIndex];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_session', _currentUser!.toJson());
        
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Register
  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1500));

    // Check if email already exists
    final exists = _mockUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    if (exists) {
      _isLoading = false;
      notifyListeners();
      return false;
    }

    // Determine role dynamically based on email
    final String role;
    if (email.toLowerCase().contains('admin')) {
      role = 'Admin';
    } else if (email.toLowerCase().contains('helpdesk') || email.toLowerCase().contains('support')) {
      role = 'Helpdesk';
    } else {
      role = 'User';
    }

    final newUser = UserModel(
      id: 'USR-${100 + _mockUsers.length}',
      username: username.trim().toLowerCase(),
      email: email.trim().toLowerCase(),
      fullName: fullName,
      role: role,
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=150&q=80',
    );

    _mockUsers.add(newUser);
    
    // Automatically log in newly registered user
    _currentUser = newUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_session', _currentUser!.toJson());

    _isLoading = false;
    notifyListeners();
    return true;
  }

  // Reset Password Simulation
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1200));

    final exists = _mockUsers.any((u) => u.email.toLowerCase() == email.trim().toLowerCase());
    
    _isLoading = false;
    notifyListeners();
    return exists; // Returns true if account exists and reset link "sent"
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    notifyListeners();
  }
}
