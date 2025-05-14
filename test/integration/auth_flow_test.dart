import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:barber/main.dart' as app;
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore mockFirestore;

  setUp(() async {
    await Firebase.initializeApp();
    mockAuth = MockFirebaseAuth();
    mockFirestore = FakeFirebaseFirestore();
    // Initialize your app with mocked dependencies
    await app.main(auth: mockAuth, firestore: mockFirestore);
  });

  group('Authentication Flow', () {
    testWidgets('Complete auth flow - phone sign in to role selection', (
      tester,
    ) async {
      // Wait for the app to load
      await tester.pumpAndSettle();

      // Verify we're on the login page
      expect(find.text('تسجيل الدخول'), findsOneWidget);

      // Enter phone number
      await tester.enterText(find.byType(TextFormField), '+1234567890');
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      // Verify we're on the OTP verification page
      expect(find.text('التحقق من رقم الهاتف'), findsOneWidget);

      // Mock successful OTP verification
      mockAuth.mockUser = MockUser(
        uid: 'test_user_id',
        phoneNumber: '+1234567890',
      );

      // Enter OTP
      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.pumpAndSettle();

      // Verify we're on the role selection page
      expect(find.text('اختر نوع الحساب'), findsOneWidget);

      // Select business role
      await tester.tap(find.text('صاحب صالون'));
      await tester.pumpAndSettle();

      // Verify we're redirected to the business home page
      expect(find.text('لوحة التحكم'), findsOneWidget);
    });

    testWidgets('Sign out flow', (tester) async {
      // Set up an authenticated user
      mockAuth.mockUser = MockUser(
        uid: 'test_user_id',
        phoneNumber: '+1234567890',
      );

      // Wait for the app to load
      await tester.pumpAndSettle();

      // Navigate to settings tab
      await tester.tap(find.text('الإعدادات'));
      await tester.pumpAndSettle();

      // Tap sign out
      await tester.tap(find.text('تسجيل الخروج'));
      await tester.pumpAndSettle();

      // Verify we're back on the login page
      expect(find.text('تسجيل الدخول'), findsOneWidget);
    });
  });
}
