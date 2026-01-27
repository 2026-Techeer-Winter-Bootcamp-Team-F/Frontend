class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';

  // Auth
  static const String login = '/api/v1/users/login';
  static const String signup = '/api/v1/users/signup';

  // User
  static const String userProfile = '/api/v1/users/me';

  // Cards
  static const String cards = '/api/v1/cards';

  // Expenses
  static const String expenses = '/api/v1/expenses';

  // Subscriptions
  static const String subscriptions = '/api/v1/subscriptions';
}
