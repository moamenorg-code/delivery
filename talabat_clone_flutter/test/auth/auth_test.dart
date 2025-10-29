import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_lib/services/auth_service.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';

void main() {
  late AuthService authService;
  
  setUp(() {
    final auth = MockFirebaseAuth();
    authService = AuthService();
    Get.put(authService);
  });

  group('Authentication Tests', () {
    test('should sign in with valid email and password', () async {
      // Act
      final result = await authService.signInWithEmail(
        'test@example.com',
        'Password123!'
      );

      // Assert
      expect(result, isNotNull);
      expect(result.email, equals('test@example.com'));
    });

    test('should throw error with invalid password', () async {
      // Act & Assert
      expect(
        () => authService.signInWithEmail(
          'test@example.com',
          'weak'
        ),
        throwsA(anything)
      );
    });

    test('should validate password strength', () async {
      // Act & Assert
      expect(
        () => authService.signUpWithEmail(
          'test@example.com',
          'weak',
          'Test User',
          '+1234567890',
          'customer'
        ),
        throwsA(anything)
      );
    });

    test('should validate phone number format', () async {
      // Act & Assert
      expect(
        () => authService.signUpWithEmail(
          'test@example.com',
          'Password123!',
          'Test User',
          'invalid',
          'customer'
        ),
        throwsA(anything)
      );
    });

    test('should maintain session after login', () async {
      // Arrange
      await authService.signInWithEmail(
        'test@example.com',
        'Password123!'
      );

      // Act
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, isTrue);
    });

    test('should clear session after logout', () async {
      // Arrange
      await authService.signInWithEmail(
        'test@example.com',
        'Password123!'
      );

      // Act
      await authService.signOut();
      final isLoggedIn = await authService.isLoggedIn();

      // Assert
      expect(isLoggedIn, isFalse);
    });
  });
}