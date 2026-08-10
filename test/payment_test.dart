import 'package:flutter_test/flutter_test.dart';
import 'package:moe_flutter_payment/moe_flutter_payment.dart';

void main() {
  group('PaymentProvider', () {
    test('has correct values', () {
      expect(PaymentProvider.midtrans.stringValue, equals('midtrans'));
      expect(PaymentProvider.xendit.stringValue, equals('xendit'));
    });

    test('fromString parses correctly', () {
      expect(PaymentProvider.fromString('midtrans'), equals(PaymentProvider.midtrans));
      expect(PaymentProvider.fromString('xendit'), equals(PaymentProvider.xendit));
    });
  });

  group('PaymentStatus', () {
    test('isCompleted returns true for paid/cancelled', () {
      expect(PaymentStatus.paid.isCompleted, isTrue);
      expect(PaymentStatus.cancelled.isCompleted, isTrue);
      
      expect(PaymentStatus.pending.isCompleted, isFalse);
      expect(PaymentStatus.failed.isCompleted, isFalse);
      expect(PaymentStatus.refunded.isCompleted, isTrue);
    });

    test('isActive returns true for non-completed statuses', () {
      expect(PaymentStatus.pending.isActive, isTrue);
      expect(PaymentStatus.paid.isActive, isFalse);
      expect(PaymentStatus.cancelled.isActive, isFalse);
    });

    test('fromValue returns default for unknown', () {
      expect(PaymentStatus.fromValue('invalid'), equals(PaymentStatus.pending));
      expect(PaymentStatus.fromValue('paid'), equals(PaymentStatus.paid));
    });
  });

  group('PaymentMethodChannel', () {
    test('has correct codes and display names', () {
      expect(PaymentMethodChannel.qris.code, equals('qris'));
      expect(PaymentMethodChannel.qris.displayName, equals('QRIS'));
      
      expect(PaymentMethodChannel.retailOutlet.code, equals('retail_outlet'));
      expect(PaymentMethodChannel.retailOutlet.displayName, equals('Retail Outlet (Alfamart/Indomaret)'));
    });
  });

  group('PaymentTransactionModel', () {
    test('isPaid returns true when status is paid', () {
      const transaction = PaymentTransactionModel(
        id: 'p1',
        orderNumber: 'ORD-001',
        externalId: 'EXT-001',
        provider: PaymentProvider.midtrans,
        method: PaymentMethodChannel.onlineBankTransfer.code,
        amount: 150000,
        status: PaymentStatus.paid,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(transaction.isPaid, isTrue);
      expect(transaction.isCompleted, isTrue);
      expect(transaction.isActive, isFalse);
    });

    test('isPaid returns false when pending', () {
      const transaction = PaymentTransactionModel(
        id: 'p1',
        orderNumber: 'ORD-001',
        externalId: 'EXT-001',
        provider: PaymentProvider.midtrans,
        method: PaymentMethodChannel.qris.code,
        amount: 50000,
        status: PaymentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(transaction.isPaid, isFalse);
      expect(transaction.isActive, isTrue);
    });

    test('fromJson parses all fields', () {
      final json = {
        'id': 'pay1',
        'order_number': 'ORD-2026-001',
        'external_id': 'EXT-2026-001',
        'provider': 'midtrans',
        'method': 'qris',
        'amount': 75000,
        'currency': 'IDR',
        'status': 'waiting_payment',
        'paid_at': null,
        'refund_reason': null,
        'notes': 'Pembayaran QRIS',
        'receipt_url': null,
        'created_at': '2026-08-10T10:00:00.000Z',
        'updated_at': '2026-08-10T12:00:00.000Z',
      };

      final payment = PaymentTransactionModel.fromJson(json);

      expect(payment.id, equals('pay1'));
      expect(payment.orderNumber, equals('ORD-2026-001'));
      expect(payment.externalId, equals('EXT-2026-001'));
      expect(payment.provider, equals(PaymentProvider.midtrans));
      expect(payment.method, equals('qris'));
      expect(payment.amount, equals(75000));
      expect(payment.currency, equals(CurrencyCode.IDR));
      expect(payment.status, equals(PaymentStatus.waiting_payment));
      expect(payment.paidAt, isNull);
      expect(payment.notes, equals('Pembayaran QRIS'));
      expect(payment.isCompleted, isFalse);
      expect(payment.isActive, isTrue);
    });

    test('assertion fails on zero or negative amount', () {
      expect(
        () => PaymentTransactionModel(
          id: 'p1',
          orderNumber: 'ORD-001',
          externalId: 'EXT-001',
          provider: PaymentProvider.midtrans,
          method: 'bank_transfer',
          amount: 0,
          status: PaymentStatus.pending,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsA(isAssertionError),
      );
    });
  });

  group('MoePaymentConfig', () {
    test('has required apiKey', () {
      const config = MoePaymentConfig(
        apiUrl: 'https://api.example.com',
        apiKey: 'sk_test_12345',
      );

      expect(config.apiUrl, equals('https://api.example.com'));
      expect(config.apiKey, equals('sk_test_12345'));
      expect(config.enableWebhooks, isTrue);
      expect(config.supportedProviders, contains('midtrans'));
      expect(config.supportedProviders, contains('xendit'));
    });

    test('supports multiple providers', () {
      const config = MoePaymentConfig(
        apiUrl: 'https://api.example.com',
        apiKey: 'sk_test_12345',
        supportedProviders: ['midtrans', 'stripe'],
      );

      expect(config.supportedProviders, equals(['midtrans', 'stripe']));
    });
  });
}
