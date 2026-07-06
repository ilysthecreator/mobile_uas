class AppConstants {
  static const String appName = 'E-Ticketing Helpdesk';

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
