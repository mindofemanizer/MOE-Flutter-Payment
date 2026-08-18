import 'package:equatable/equatable.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_payment/src/models/payment_provider.dart';
import 'package:moe_flutter_payment/src/models/payment_status.dart';

/// Model representing a payment transaction.
class PaymentTransactionModel extends Equatable {
  final String id;
  final String orderNumber;
  final String externalId;
  final PaymentProvider provider;
  final String method;
  final double amount;
  final CurrencyCode currency;
  final PaymentStatus status;
  final DateTime? paidAt;
  final String? refundReason;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PaymentTransactionModel({
    required this.id,
    required this.orderNumber,
    required this.externalId,
    required this.provider,
    required this.method,
    required this.amount,
    this.currency = CurrencyCode.IDR,
    required this.status,
    this.paidAt,
    this.refundReason,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(amount > 0);

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      externalId: json['external_id'] as String,
      provider: PaymentProvider.fromString(json['provider'] as String),
      method: json['method'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: CurrencyCode.values.firstWhere(
        (c) => c.code == json['currency'],
        orElse: () => CurrencyCode.IDR,
      ),
      status: PaymentStatus.fromValue(json['status']),
      paidAt: json['paid_at'] != null
          ? DateTime.parse(json['paid_at'] as String)
          : null,
      refundReason: json['refund_reason'] as String?,
      notes: json['notes'] as String?,
      receiptUrl: json['receipt_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'external_id': externalId,
      'provider': provider.stringValue,
      'method': method,
      'amount': amount,
      'currency': currency.code,
      'status': status.value,
      if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
      if (refundReason != null) 'refund_reason': refundReason,
      if (notes != null) 'notes': notes,
      if (receiptUrl != null) 'receipt_url': receiptUrl,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Has this payment been completed (success/failure/cancelled)?
  bool get isCompleted => status.isCompleted;

  /// Check if payment is successful.
  bool get isPaid => status == PaymentStatus.paid;

  /// Whether the payment is still active.
  bool get isActive => status.isActive;

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        externalId,
        provider,
        method,
        amount,
        currency,
        status,
        paidAt,
        refundReason,
        notes,
        receiptUrl,
        createdAt,
        updatedAt,
      ];
}
