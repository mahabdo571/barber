import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:barber/features/auth/presentation/pages/login_page.dart';
import 'package:barber/features/auth/presentation/cubit/auth_cubit.dart';
import '../../unit/mocks/mock_auth_repository.mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late AuthCubit authCubit;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authCubit = AuthCubit(mockAuthRepository);
  });

  tearDown(() {
    authCubit.close();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AuthCubit>.value(
        value: authCubit,
        child: const LoginPage(),
      ),
    );
  }

  group('LoginPage', () {
    testWidgets('renders login form correctly', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('تسجيل الدخول'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('التالي'), findsOneWidget);
    });

    testWidgets('shows error message on invalid phone number', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter invalid phone number
      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.text('التالي'));
      await tester.pump();

      expect(find.text('رقم الهاتف غير صحيح'), findsOneWidget);
    });

    testWidgets('calls signInWithPhone on valid submission', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Enter valid phone number
      const phoneNumber = '+1234567890';
      await tester.enterText(find.byType(TextFormField), phoneNumber);
      await tester.tap(find.text('التالي'));
      await tester.pump();

      verify(mockAuthRepository.signInWithPhone(phoneNumber)).called(1);
    });

    testWidgets('shows loading indicator while submitting', (tester) async {
      when(
        mockAuthRepository.signInWithPhone(any),
      ).thenAnswer((_) async => 'verification_id');

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter phone number and submit
      await tester.enterText(find.byType(TextFormField), '+1234567890');
      await tester.tap(find.text('التالي'));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error message on submission failure', (tester) async {
      when(
        mockAuthRepository.signInWithPhone(any),
      ).thenThrow(Exception('Failed to send code'));

      await tester.pumpWidget(createWidgetUnderTest());

      // Enter phone number and submit
      await tester.enterText(find.byType(TextFormField), '+1234567890');
      await tester.tap(find.text('التالي'));
      await tester.pumpAndSettle();

      expect(find.text('Failed to send code'), findsOneWidget);
    });
  });
}
