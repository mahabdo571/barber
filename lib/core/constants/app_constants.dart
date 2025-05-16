class AppConstants {
  static const String appName = 'Barber';

  // API Constants
  static const int timeoutDuration = 30; // seconds

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userRoleKey = 'user_role';
  static const String userIdKey = 'user_id';
  static const String userPhoneKey = 'user_phone';

  // Role Types
  static const String roleCustomer = 'customer';
  static const String roleBusiness = 'business';

  // Routes
  static const String routeInitial = '/';
  static const String routeLogin = '/login';
  static const String routeRoleSelection = '/role-selection';
  static const String routeBusinessProfile = '/business/profile';
  static const String routeCustomerProfile = '/customer/profile';
  static const String routeBusinessHome = '/business';
  static const String routeCustomerHome = '/customer';
  static const String routeBusinessDetails = '/business/details';

  // Collections
  static const String colUsers = 'users';
  static const String colBusinesses = 'businesses';
  static const String colServices = 'services';
  static const String colBookings = 'bookings';
  static const String colChats = 'chats';
  static const String colMessages = 'messages';
  static const String colTimeSlots = 'time_slots';

  // Time Slots
  static const int defaultSlotDuration = 30; // minutes
  static const String timeFormat = 'HH:mm';
  static const String dateFormat = 'yyyy-MM-dd';
}
