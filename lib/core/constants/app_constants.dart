class AppConstants {
  static const String appName = 'E-Ticketing Helpdesk';

  // Supabase Configuration
  static const String supabaseUrl = 'https://qcalvfyckhhmbstflaed.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFjYWx2Znlja2hobWJzdGZsYWVkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODMzNDQ1NzIsImV4cCI6MjA5ODkyMDU3Mn0.O9e1Sp-ATYQnnHAgKL7s1mjckMQI5JczKYsDcKmDnQA';

  // Shared Preferences Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLoggedInUser = 'logged_in_user';

  // Categories
  static const List<String> categories = [
    'IT Support',
    'Network',
    'Hardware',
    'Software',
    'Facilities',
  ];

  // Priorities
  static const List<String> priorities = [
    'Low',
    'Medium',
    'High',
  ];

  // Default User Roles
  static const String roleUser = 'User';
  static const String roleHelpdesk = 'Helpdesk';
  static const String roleAdmin = 'Admin';
}
