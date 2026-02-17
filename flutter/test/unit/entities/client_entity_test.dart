import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/features/clients/domain/entities/client_entity.dart';

void main() {
  group('ClientEntity', () {
    const testId = 'test-client-id';
    const testName = 'Test Client';
    const testEmail = 'test@example.com';
    const testPhone = '+525512345678';
    const testAddress = '123 Test Street';
    const testCompany = 'Test Company';
    const testTaxId = 'RFC123456789';
    const testStatus = 'active';
    const testTotalSpent = 50000.00;
    const testEventsCount = 5;
    final testLastEventDate = DateTime(2024, 1, 15);
    final testCreatedAt = DateTime(2024, 1, 1);
    final testUpdatedAt = DateTime(2024, 1, 2);

    group('Constructor', () {
      test('should create ClientEntity with all fields', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          phone: testPhone,
          address: testAddress,
          company: testCompany,
          taxId: testTaxId,
          status: testStatus,
          totalSpent: testTotalSpent,
          eventsCount: testEventsCount,
          lastEventDate: testLastEventDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.id, equals(testId));
        expect(client.name, equals(testName));
        expect(client.email, equals(testEmail));
        expect(client.phone, equals(testPhone));
        expect(client.address, equals(testAddress));
        expect(client.company, equals(testCompany));
        expect(client.taxId, equals(testTaxId));
        expect(client.status, equals(testStatus));
        expect(client.totalSpent, equals(testTotalSpent));
        expect(client.eventsCount, equals(testEventsCount));
        expect(client.lastEventDate, equals(testLastEventDate));
        expect(client.createdAt, equals(testCreatedAt));
        expect(client.updatedAt, equals(testUpdatedAt));
      });

      test('should create ClientEntity with required fields only', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          status: testStatus,
          totalSpent: 0,
          eventsCount: 0,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.id, equals(testId));
        expect(client.name, equals(testName));
        expect(client.email, equals(testEmail));
        expect(client.phone, isNull);
        expect(client.address, isNull);
        expect(client.company, isNull);
        expect(client.taxId, isNull);
        expect(client.status, equals(testStatus));
        expect(client.totalSpent, equals(0));
        expect(client.eventsCount, equals(0));
        expect(client.lastEventDate, isNull);
        expect(client.createdAt, equals(testCreatedAt));
        expect(client.updatedAt, equals(testUpdatedAt));
      });

      test('should handle null optional fields correctly', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.phone, isNull);
        expect(client.address, isNull);
        expect(client.company, isNull);
        expect(client.taxId, isNull);
        expect(client.lastEventDate, isNull);
      });
    });

    group('Status Getters', () {
      test('isActive should return true for active status', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          status: 'active',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.isActive, isTrue);
        expect(client.isInactive, isFalse);
        expect(client.isArchived, isFalse);
      });

      test('isInactive should return true for inactive status', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          status: 'inactive',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.isActive, isFalse);
        expect(client.isInactive, isTrue);
        expect(client.isArchived, isFalse);
      });

      test('isArchived should return true for archived status', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          status: 'archived',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.isActive, isFalse);
        expect(client.isInactive, isFalse);
        expect(client.isArchived, isTrue);
      });
    });

    group('displayName getter', () {
      test('should return company name when available', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          company: testCompany,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.displayName, equals(testCompany));
      });

      test('should return name when company is null', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.displayName, equals(testName));
      });

      test('should return empty string when company is empty', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          company: '',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.displayName, isEmpty);
      });
    });

    group('formattedPhone getter', () {
      test('should return phone when available', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          phone: testPhone,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedPhone, equals(testPhone));
      });

      test('should return N/A when phone is null', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedPhone, equals('N/A'));
      });

      test('should return N/A when phone is empty', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          phone: '',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedPhone, equals('N/A'));
      });
    });

    group('formattedLastEventDate getter', () {
      test('should return formatted date when lastEventDate is available', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          lastEventDate: testLastEventDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedLastEventDate, equals('15/01/2024'));
      });

      test('should return No hay eventos when lastEventDate is null', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedLastEventDate, equals('No hay eventos'));
      });
    });

    group('formattedDate getters', () {
      test('should return formatted createdAt', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(client.formattedCreatedAt, equals('01/01/2024'));
        expect(client.formattedUpdatedAt, equals('02/01/2024'));
      });
    });

    group('toJson', () {
      test('should convert entity to JSON map', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          phone: testPhone,
          address: testAddress,
          company: testCompany,
          taxId: testTaxId,
          status: testStatus,
          totalSpent: testTotalSpent,
          eventsCount: testEventsCount,
          lastEventDate: testLastEventDate,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final json = client.toJson();

        expect(json['id'], equals(testId));
        expect(json['name'], equals(testName));
        expect(json['email'], equals(testEmail));
        expect(json['phone'], equals(testPhone));
        expect(json['address'], equals(testAddress));
        expect(json['company'], equals(testCompany));
        expect(json['taxId'], equals(testTaxId));
        expect(json['status'], equals(testStatus));
        expect(json['totalSpent'], equals(testTotalSpent));
        expect(json['eventsCount'], equals(testEventsCount));
        expect(json['lastEventDate'], equals(testLastEventDate.toIso8601String()));
        expect(json['createdAt'], equals(testCreatedAt.toIso8601String()));
        expect(json['updatedAt'], equals(testUpdatedAt.toIso8601String()));
      });
    });

    group('copyWith', () {
      test('should copy entity with all fields changed', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          status: testStatus,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final copied = client.copyWith(
          name: 'Updated Name',
          phone: '+5255543211',
          totalSpent: 60000.00,
          eventsCount: 10,
        );

        expect(copied.id, equals(testId));
        expect(copied.name, equals('Updated Name'));
        expect(copied.email, equals(testEmail));
        expect(copied.phone, equals('+5255543211'));
        expect(copied.totalSpent, equals(60000.00));
        expect(copied.eventsCount, equals(10));
        expect(copied.status, equals(testStatus));
        expect(copied.createdAt, equals(testCreatedAt));
        expect(copied.updatedAt, equals(testUpdatedAt));
      });

      test('should copy entity with null values', () {
        final client = ClientEntity(
          id: testId,
          name: testName,
          email: testEmail,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        final copied = client.copyWith(
          phone: null,
          address: null,
          company: null,
          totalSpent: null,
          eventsCount: null,
          lastEventDate: null,
        );

        expect(copied.id, equals(testId));
        expect(copied.name, equals(testName));
        expect(copied.email, equals(testEmail));
        expect(copied.phone, isNull);
        expect(copied.address, isNull);
        expect(copied.company, isNull);
        expect(copied.totalSpent, isNull);
        expect(copied.eventsCount, isNull);
        expect(copied.lastEventDate, isNull);
        expect(copied.status, equals(testStatus));
        expect(copied.createdAt, equals(testCreatedAt));
        expect(copied.updatedAt, equals(testUpdatedAt));
      });
    });
  });
}
