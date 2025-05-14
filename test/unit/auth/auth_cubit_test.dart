import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:barber/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:barber/features/auth/domain/repositories/auth_repository.dart';
import '../mocks/mock_auth_repository.mocks.dart';

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

  group('AuthCubit', () {
    test('initial state is AuthInitial', () {
      expect(authCubit.state, isA<AuthInitial>());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when not signed in',
      build: () {
        when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => false);
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when signed in with role',
      build: () {
        when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => true);
        when(
          mockAuthRepository.getCurrentUserId(),
        ).thenAnswer((_) async => 'test_user_id');
        when(
          mockAuthRepository.getUserRole(),
        ).thenAnswer((_) async => 'business');
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthAuthenticated>()
                .having((state) => state.role, 'role', 'business')
                .having((state) => state.userId, 'userId', 'test_user_id'),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthNeedsRole] when signed in without role',
      build: () {
        when(mockAuthRepository.isSignedIn()).thenAnswer((_) async => true);
        when(
          mockAuthRepository.getCurrentUserId(),
        ).thenAnswer((_) async => 'test_user_id');
        when(mockAuthRepository.getUserRole()).thenAnswer((_) async => null);
        return authCubit;
      },
      act: (cubit) => cubit.checkAuthStatus(),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthNeedsRole>().having(
              (state) => state.userId,
              'userId',
              'test_user_id',
            ),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthCodeSent] when phone sign in succeeds',
      build: () {
        when(
          mockAuthRepository.signInWithPhone(any),
        ).thenAnswer((_) async => 'verification_id');
        return authCubit;
      },
      act: (cubit) => cubit.signInWithPhone('+1234567890'),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthCodeSent>().having(
              (state) => state.verificationId,
              'verificationId',
              'verification_id',
            ),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when phone sign in fails',
      build: () {
        when(
          mockAuthRepository.signInWithPhone(any),
        ).thenThrow(Exception('Sign in failed'));
        return authCubit;
      },
      act: (cubit) => cubit.signInWithPhone('+1234567890'),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthError>().having(
              (state) => state.message,
              'message',
              'Exception: Sign in failed',
            ),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthNeedsRole] when OTP verification succeeds',
      build: () {
        when(
          mockAuthRepository.verifyOTP(any, any),
        ).thenAnswer((_) async => 'user_id');
        return authCubit;
      },
      act: (cubit) => cubit.verifyOTP('verification_id', '123456'),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthNeedsRole>().having(
              (state) => state.userId,
              'userId',
              'user_id',
            ),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when setting user role succeeds',
      build: () {
        when(
          mockAuthRepository.getCurrentUserId(),
        ).thenAnswer((_) async => 'user_id');
        when(mockAuthRepository.setUserRole(any)).thenAnswer((_) async => {});
        return authCubit;
      },
      act: (cubit) => cubit.setUserRole('business'),
      expect:
          () => [
            isA<AuthLoading>(),
            isA<AuthAuthenticated>()
                .having((state) => state.role, 'role', 'business')
                .having((state) => state.userId, 'userId', 'user_id'),
          ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthUnauthenticated] when sign out succeeds',
      build: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
        return authCubit;
      },
      act: (cubit) => cubit.signOut(),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );
  });
}
