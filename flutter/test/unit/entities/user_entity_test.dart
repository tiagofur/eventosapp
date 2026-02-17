import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/features/auth/domain/entities/user_entity.dart';

void main() {
  group('UserEntity', () {
    const testId = 'test-user-id';
    const testEmail = 'test@example.com';
    const testName = 'Test User';
    const testPlan = 'premium';
    const testBusinessName = 'Test Business';
    final testCreatedAt = DateTime(2024, 1, 1);
    final testUpdatedAt = DateTime(2024, 1, 2);

    group('Constructor', () {
      test('should create UserEntity with required fields', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          plan: testPlan,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.id, equals(testId));
        expect(user.email, equals(testEmail));
        expect(user.name, equals(testName));
        expect(user.plan, equals(testPlan));
        expect(user.createdAt, equals(testCreatedAt));
        expect(user.updatedAt, equals(testUpdatedAt));
        expect(user.businessName, isNull);
        expect(user.defaultDepositPercent, isNull);
        expect(user.defaultCancellationDays, isNull);
        expect(user.defaultRefundPercent, isNull);
        expect(user.stripeCustomerId, isNull);
      });

      test('should create UserEntity with all optional fields', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          businessName: testBusinessName,
          defaultDepositPercent: 30.0,
          defaultCancellationDays: 3.0,
          defaultRefundPercent: 100.0,
          plan: testPlan,
          stripeCustomerId: 'stripe-customer-id',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.id, equals(testId));
        expect(user.email, equals(testEmail));
        expect(user.name, equals(testName));
        expect(user.businessName, equals(testBusinessName));
        expect(user.defaultDepositPercent, equals(30.0));
        expect(user.defaultCancellationDays, equals(3.0));
        expect(user.defaultRefundPercent, equals(100.0));
        expect(user.plan, equals(testPlan));
        expect(user.stripeCustomerId, equals('stripe-customer-id'));
      });
    });

    group('isPremium getter', () {
      test('should return true for premium plan', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          plan: 'premium',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.isPremium, isTrue);
      });

      test('should return false for basic plan', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          plan: 'basic',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.isPremium, isFalse);
      });

      test('should return false for free plan', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          plan: 'free',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.isPremium, isFalse);
      });

      test('should be case-insensitive for plan check', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          plan: 'PREMIUM',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.isPremium, isFalse);
      });
    });

    group('displayName getter', () {
      test('should return businessName when available', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          businessName: testBusinessName,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.displayName, equals(testBusinessName));
      });

      test('should return name when businessName is null', () {
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.displayName, equals(testName));
      });

      test('should return empty string when businessName is empty', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          businessName: '',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.displayName, isEmpty);
      });
    });

    group('Edge Cases', () {
      test('should handle empty email string', () {
        final user = UserEntity(
          id: testId,
          email: '',
          name: testName,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.email, isEmpty);
      });

      test('should handle empty name string', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: '',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.name, isEmpty);
      });

      test('should handle zero values for numeric optional fields', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          defaultDepositPercent: 0.0,
          defaultCancellationDays: 0.0,
          defaultRefundPercent: 0.0,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.defaultDepositPercent, equals(0.0));
        expect(user.defaultCancellationDays, equals(0.0));
        expect(user.defaultRefundPercent, equals(0.0));
      });

      test('should handle negative values for numeric optional fields', () {
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          defaultDepositPercent: -10.0,
          defaultCancellationDays: -5.0,
          defaultRefundPercent: -50.0,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(user.defaultDepositPercent, equals(-10.0));
        expect(user.defaultCancellationDays, equals(-5.0));
        expect(user.defaultRefundPercent, equals(-50.0));
      });
    });

    group('Timestamps', () {
      test('should store createdAt correctly', () {
        final now = DateTime.now();
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          createdAt: now,
          updatedAt: testUpdatedAt,
        );

        expect(user.createdAt, equals(now));
        expect(user.createdAt.isAtSameMomentAs(now), isTrue);
      });

      test('should store updatedAt correctly', () {
        final now = DateTime.now();
        final user = UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          createdAt: testCreatedAt,
          updatedAt: now,
        );

        expect(user.updatedAt, equals(now));
        expect(user.updatedAt.isAtSameMomentAs(now), isTrue);
      });

      test('should handle future dates', () {
        final futureDate = DateTime(2099, 12, 31);
        final user = const UserEntity(
          id: testId,
          email: testEmail,
          name: testName,
          createdAt: futureDate,
          updatedAt: futureDate,
        );

        expect(user.createdAt, equals(futureDate));
        expect(user.updatedAt, equals(futureDate));
      });
    });
  });
}
