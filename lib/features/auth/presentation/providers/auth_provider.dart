import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_mobile/features/auth/data/models/user_model.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  UserModel? _currentUser;
  bool _isLoading = false;
  ThemeMode _themeMode = ThemeMode.light;

  // Daftar user helpdesk untuk assignment tiket
  List<UserModel> _helpdeskUsers = [];

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<UserModel> get mockUsers => _helpdeskUsers;

  AuthProvider() {
    _loadSession();
  }

  // Load user session & theme from SharedPreferences & Supabase
  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();

    // Theme
    final isDark = prefs.getBool('is_dark_theme') ?? false;
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;

    // Cek apakah ada session aktif di Supabase
    final session = _supabase.auth.currentSession;
    if (session != null) {
      await _fetchUserProfile(session.user.id);
    }
    notifyListeners();
  }

  // Fetch profil user dari tabel profiles di Supabase
  // Jika profil belum ada (misal user terdaftar sebelum trigger dibuat),
  // maka akan otomatis dibuat.
  Future<void> _fetchUserProfile(String uid) async {
    try {
      final authUser = _supabase.auth.currentUser;

      // Coba ambil profil dari tabel profiles
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle(); // Gunakan maybeSingle agar tidak error jika tidak ada data

      if (response != null) {
        // Profil ditemukan, langsung pakai
        final profileData = Map<String, dynamic>.from(response);
        profileData['email'] = authUser?.email ?? '';
        _currentUser = UserModel.fromMap(profileData);
      } else if (authUser != null) {
        // Profil TIDAK ditemukan → buat secara manual
        debugPrint('Profile not found for $uid, creating one...');

        final metadata = authUser.userMetadata ?? {};
        final email = authUser.email ?? '';

        // Tentukan role dari metadata atau dari email
        String role = metadata['role'] ?? 'User';
        if (role == 'User') {
          if (email.toLowerCase().contains('admin')) {
            role = 'Admin';
          } else if (email.toLowerCase().contains('helpdesk') ||
              email.toLowerCase().contains('support')) {
            role = 'Helpdesk';
          }
        }

        final newProfile = {
          'id': uid,
          'username': metadata['username'] ??
              email.split('@').first.toLowerCase(),
          'full_name': metadata['full_name'] ?? email.split('@').first,
          'role': role,
          'avatar_url': null,
        };

        await _supabase.from('profiles').upsert(newProfile);

        final profileData = Map<String, dynamic>.from(newProfile);
        profileData['email'] = email;
        _currentUser = UserModel.fromMap(profileData);
      }
    } catch (e) {
      debugPrint('Error fetching/creating user profile: $e');
      _currentUser = null;
    }
  }

  // Fetch daftar user helpdesk untuk assignment tiket
  Future<List<UserModel>> fetchHelpdeskUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('role', 'Helpdesk');

      _helpdeskUsers = (response as List)
          .map((u) => UserModel.fromMap(u))
          .toList();
      notifyListeners();
      return _helpdeskUsers;
    } catch (e) {
      debugPrint('Error fetching helpdesk users: $e');
      return [];
    }
  }

  // Toggle Theme
  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_theme', isDark);
    notifyListeners();
  }

  // Login dengan Supabase Auth
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        await _fetchUserProfile(response.user!.id);
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

  // Register dengan Supabase Auth
  Future<bool> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Tentukan role berdasarkan email (logika yang sudah ada sebelumnya)
      final String role;
      if (email.toLowerCase().contains('admin')) {
        role = 'Admin';
      } else if (email.toLowerCase().contains('helpdesk') ||
          email.toLowerCase().contains('support')) {
        role = 'Helpdesk';
      } else {
        role = 'User';
      }

      // Mendaftar ke Supabase Auth dengan metadata tambahan
      // Metadata ini akan digunakan oleh database trigger untuk membuat profil
      final response = await _supabase.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'username': username.trim().toLowerCase(),
          'full_name': fullName,
          'role': role,
        },
      );

      if (response.user != null) {
        // Tunggu sebentar agar database trigger selesai membuat profil
        await Future.delayed(const Duration(milliseconds: 500));
        await _fetchUserProfile(response.user!.id);

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Register error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  // Reset Password via Supabase
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _supabase.auth.resetPasswordForEmail(email.trim());
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Reset password error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    notifyListeners();
  }
}
