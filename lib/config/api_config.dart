class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';

  // Auth
  static const String login = '/api/v1/users/login';
  static const String signup = '/api/v1/users/signup';

  // User
  static const String userProfile = '/api/v1/users';

  // CODEF
  static const String codefToken = '/api/v1/codef/token/';
  static const String codefConnectedIdCreate = '/api/v1/codef/connected-id/create/';
  static const String codefCardList = '/api/v1/codef/card/list/';
  static const String codefCardBilling = '/api/v1/codef/card/billing/';
  static const String codefCardApproval = '/api/v1/codef/card/approval/';

  // Cards
  static const String cards = '/api/v1/cards';

  // Expenses
  static const String expenses = '/api/v1/expenses';

  // Subscriptions
  static const String subscriptions = '/api/v1/subscriptions';

  // Chat - 채팅방 기반 (카드 추천)
  static const String chatMakeRoom = '/api/v1/chat/make_room/';
  static const String chatSendMessage = '/api/v1/chat/send_message/';

  // Chat - AI 직접 대화 (금융 상담)
  static const String chat = '/api/v1/chat/';
}
