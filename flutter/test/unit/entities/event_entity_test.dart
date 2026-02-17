import 'package:flutter_test/flutter_test.dart';
import 'package:eventosapp/features/events/domain/entities/event_entity.dart';

void main() {
  group('EventEntity', () {
    String testId = 'test-event-id';
    String testClientId = 'test-client-id';
    String testClientName = 'Test Client';
    String testEventName = 'Test Event';
    DateTime testEventDate = DateTime(2024, 6, 15);
    String testStartTime = '14:00';
    String testEndTime = '18:00';
    String testLocation = 'Test Location';
    String testAddress = '123 Test Street';
    String testNotes = 'Test notes';
    double testTotalAmount = 20000.00;
    double testDepositAmount = 6000.00;
    double testCancellationDays = 3.0;
    double testRefundPercent = 100.0;
    String testStatus = 'confirmed';
    DateTime testCreatedAt = DateTime(2024, 1, 1);
    DateTime testUpdatedAt = DateTime(2024, 1, 2);
    DateTime testPaymentDate = DateTime(2024, 1, 15);

    group('Constructor', () {
      test('should create EventEntity with all required fields', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.id, equals(testId));
        expect(event.clientId, equals(testClientId));
        expect(event.clientName, equals(testClientName));
        expect(event.eventName, equals(testEventName));
        expect(event.eventDate, equals(testEventDate));
        expect(event.startTime, equals(testStartTime));
        expect(event.endTime, equals(testEndTime));
        expect(event.location, equals(testLocation));
        expect(event.status, equals(testStatus));
        expect(event.totalAmount, equals(0));
        expect(event.depositAmount, equals(0));
        expect(event.cancellationDays, equals(3));
        expect(event.refundPercent, equals(100));
        expect(event.products, isEmpty);
        expect(event.services, isEmpty);
        expect(event.extras, isEmpty);
        expect(event.payments, isEmpty);
      });

      test('should create EventEntity with all fields including optional', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          address: testAddress,
          notes: testNotes,
          totalAmount: testTotalAmount,
          depositAmount: testDepositAmount,
          cancellationDays: testCancellationDays,
          refundPercent: testRefundPercent,
          status: testStatus,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.address, equals(testAddress));
        expect(event.notes, equals(testNotes));
        expect(event.totalAmount, equals(testTotalAmount));
        expect(event.depositAmount, equals(testDepositAmount));
        expect(event.cancellationDays, equals(testCancellationDays));
        expect(event.refundPercent, equals(testRefundPercent));
      });
    });

    group('Status Getters', () {
      test('isConfirmed should return true for confirmed status', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: 'confirmed',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.isConfirmed, isTrue);
        expect(event.isPending, isFalse);
        expect(event.isCompleted, isFalse);
        expect(event.isCancelled, isFalse);
      });

      test('isPending should return true for pending status', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: 'pending',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.isPending, isTrue);
        expect(event.isConfirmed, isFalse);
        expect(event.isCompleted, isFalse);
        expect(event.isCancelled, isFalse);
      });

      test('isCompleted should return true for completed status', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: 'completed',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.isCompleted, isTrue);
        expect(event.isConfirmed, isFalse);
        expect(event.isPending, isFalse);
        expect(event.isCancelled, isFalse);
      });

      test('isCancelled should return true for cancelled status', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: 'cancelled',
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.isCancelled, isTrue);
        expect(event.isConfirmed, isFalse);
        expect(event.isPending, isFalse);
        expect(event.isCompleted, isFalse);
      });
    });

    group('Payment Calculations', () {
      Payment payment1 = Payment(
        id: 'payment-1',
        eventId: testId,
        paymentDate: testPaymentDate,
        amount: 5000.00,
        isDeposit: true,
      );

      Payment payment2 = Payment(
        id: 'payment-2',
        eventId: testId,
        paymentDate: DateTime(2024, 1, 16),
        amount: 10000.00,
      );

      test('collectedAmount should sum all payments', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          totalAmount: 20000.00,
          payments: [payment1, payment2],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.collectedAmount, equals(15000.00));
      });

      test('collectedAmount should be 0 with no payments', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          totalAmount: 20000.00,
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.collectedAmount, equals(0));
      });

      test('pendingAmount should calculate remaining balance', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          totalAmount: 20000.00,
          payments: [payment1, payment2],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.pendingAmount, equals(5000.00));
      });

      test('depositPaid should sum only deposit payments', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          depositAmount: 6000.00,
          payments: [payment1, payment2],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.depositPaid, equals(5000.00));
      });

      test('remainingDeposit should calculate remaining deposit', () {
        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          depositAmount: 6000.00,
          payments: [payment1, payment2],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.remainingDeposit, equals(1000.00));
      });

      test('remainingDeposit should handle overpayment', () {
        Payment overpaidPayment = Payment(
          id: 'payment-3',
          eventId: testId,
          paymentDate: DateTime(2024, 1, 17),
          amount: 8000.00,
          isDeposit: true,
        );

        final event = EventEntity(
          id: testId,
          clientId: testClientId,
          clientName: testClientName,
          eventName: testEventName,
          eventDate: testEventDate,
          startTime: testStartTime,
          endTime: testEndTime,
          location: testLocation,
          status: testStatus,
          depositAmount: 6000.00,
          payments: [overpaidPayment],
          createdAt: testCreatedAt,
          updatedAt: testUpdatedAt,
        );

        expect(event.remainingDeposit, equals(-2000.00));
      });
    });

    group('EventProduct', () {
      test('should create EventProduct correctly', () {
        final product = EventProduct(
          id: 'ep-1',
          productId: 'product-1',
          productName: 'Test Product',
          quantity: 10,
          unitPrice: 1500.00,
          recipeCost: 1000.00,
        );

        expect(product.id, equals('ep-1'));
        expect(product.productId, equals('product-1'));
        expect(product.productName, equals('Test Product'));
        expect(product.quantity, equals(10));
        expect(product.unitPrice, equals(1500.00));
        expect(product.recipeCost, equals(1000.00));
      });

      test('total should calculate correctly', () {
        final product = EventProduct(
          id: 'ep-1',
          productId: 'product-1',
          productName: 'Test Product',
          quantity: 10,
          unitPrice: 1500.00,
          recipeCost: 1000.00,
        );

        expect(product.total, equals(15000.00));
      });

      test('cost should return null when recipeCost is null', () {
        final product = EventProduct(
          id: 'ep-1',
          productId: 'product-1',
          productName: 'Test Product',
          quantity: 10,
          unitPrice: 1500.00,
        );

        expect(product.cost, isNull);
      });

      test('cost should calculate when recipeCost is provided', () {
        final product = EventProduct(
          id: 'ep-1',
          productId: 'product-1',
          productName: 'Test Product',
          quantity: 10,
          unitPrice: 1500.00,
          recipeCost: 1000.00,
        );

        expect(product.cost, equals(10000.00));
      });
    });

    group('EventService', () {
      test('should create EventService correctly', () {
        final service = EventService(
          id: 'es-1',
          serviceId: 'service-1',
          serviceName: 'Test Service',
          description: 'Test service description',
          price: 5000.00,
        );

        expect(service.id, equals('es-1'));
        expect(service.serviceId, equals('service-1'));
        expect(service.serviceName, equals('Test Service'));
        expect(service.description, equals('Test service description'));
        expect(service.price, equals(5000.00));
        expect(service.quantity, isNull);
      });

      test('total should calculate with default quantity', () {
        final service = EventService(
          id: 'es-1',
          serviceId: 'service-1',
          serviceName: 'Test Service',
          description: 'Test service description',
          price: 5000.00,
        );

        expect(service.total, equals(5000.00));
      });

      test('total should calculate with custom quantity', () {
        final service = EventService(
          id: 'es-1',
          serviceId: 'service-1',
          serviceName: 'Test Service',
          description: 'Test service description',
          price: 5000.00,
          quantity: 3,
        );

        expect(service.total, equals(15000.00));
      });
    });

    group('EventExtra', () {
      test('should create EventExtra correctly', () {
        final extra = EventExtra(
          id: 'ee-1',
          extraId: 'extra-1',
          extraName: 'Test Extra',
          description: 'Test extra description',
          price: 1000.00,
        );

        expect(extra.id, equals('ee-1'));
        expect(extra.extraId, equals('extra-1'));
        expect(extra.extraName, equals('Test Extra'));
        expect(extra.description, equals('Test extra description'));
        expect(extra.price, equals(1000.00));
      });
    });

    group('Payment', () {
      test('should create Payment correctly', () {
        final payment = Payment(
          id: 'payment-1',
          eventId: testId,
          paymentDate: testPaymentDate,
          amount: 5000.00,
          method: 'Transferencia',
        );

        expect(payment.id, equals('payment-1'));
        expect(payment.eventId, equals(testId));
        expect(payment.paymentDate, equals(testPaymentDate));
        expect(payment.amount, equals(5000.00));
        expect(payment.method, equals('Transferencia'));
        expect(payment.isDeposit, isFalse);
      });

      test('should handle isDeposit flag', () {
        final depositPayment = Payment(
          id: 'payment-1',
          eventId: testId,
          paymentDate: testPaymentDate,
          amount: 5000.00,
          method: 'Transferencia',
          isDeposit: true,
        );

        expect(depositPayment.isDeposit, isTrue);
      });
    });
  });
}
