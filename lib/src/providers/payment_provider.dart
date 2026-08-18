import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_payment/src/models/payment_transaction_model.dart';
import 'package:moe_flutter_payment/src/models/payment_provider.dart';
import 'package:moe_flutter_payment/src/models/payment_status.dart';
import 'package:moe_flutter_payment/src/services/payment_repository.dart';

/// State for payment transactions.
sealed class PaymentState {
  const PaymentState();
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentLoading extends PaymentState {
  const PaymentLoading();
}

final class PaymentLoaded extends PaymentState {
  final PaymentTransactionModel transaction;
  const PaymentLoaded(this.transaction);
}

final class PaymentError extends PaymentState {
  final AppFailure failure;
  const PaymentError(this.failure);
}

/// Notifier for payments.
class PaymentsNotifier extends StateNotifier<PaymentState> {
  final PaymentRepository _repository;

  PaymentsNotifier(this._repository) : super(const PaymentInitial());

  /// Create new payment and get checkout URL/QRIS.
  Future<AppResult<Map<String, dynamic>>> createPayment({
    required String orderNumber,
    required double amount,
    required PaymentProvider provider,
    required String method,
    Map<String, dynamic>? metadata,
  }) async {
    state = const PaymentLoading();

    final result = await _repository.createPayment(
      orderNumber: orderNumber,
      amount: amount,
      provider: provider,
      method: method,
      metadata: metadata,
    );

    switch (result) {
      case Ok():
        return result;
      case Err(:final failure):
        state = PaymentError(failure);
        return result;
    }
  }

  /// Poll payment status until completed.
  Future<AppResult<PaymentTransactionModel>> pollPaymentStatus(
    String id,
  ) async {
    var attempts = 0;
    const maxAttempts = 60; // 5 minutes with 5s interval

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 5));

      final result = await _repository.getPayment(id);

      switch (result) {
        case Ok(:final data):
          if (data.isCompleted) {
            state = PaymentLoaded(data);
            return result;
          }

          // Continue polling
          attempts++;
        case Err(:final failure):
          state = PaymentError(failure);
          return result;
      }
    }

    // Timeout
    const timeoutFailure = AppFailure(
      type: FailureType.unknown,
      message: 'Payment timeout after ${maxAttempts * 5}s',
    );
    state = const PaymentError(timeoutFailure);
    return const Err(timeoutFailure);
  }

  /// Check single payment status.
  Future<AppResult<PaymentTransactionModel>> checkStatus(String id) async {
    state = const PaymentLoading();

    final result = await _repository.checkPaymentStatus(id);

    switch (result) {
      case Ok(:final data):
        state = PaymentLoaded(data);
      case Err(:final failure):
        state = PaymentError(failure);
    }

    return result;
  }

  /// List all payments with filters.
  Future<AppResult<List<PaymentTransactionModel>>> listPayments({
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
  }) async {
    final result = await _repository.listPayments(
      startDate: startDate,
      endDate: endDate,
      status: status,
    );

    if (result is Ok) {
      return result;
    }

    return result;
  }

  /// Cancel pending payment.
  Future<AppResult<void>> cancelPayment(String id) async {
    final result = await _repository.refundPayment(
      id,
      amount: 0, // Zero refund just cancels
      reason: 'Cancelled by user',
    );

    return result;
  }
}

/// Provider for PaymentRepository.
final paymentRepositoryProvider = Provider<PaymentRepository>((ref) {
  throw UnimplementedError('MoePayment.setup() must be called before use.');
});

/// Provider for PaymentsNotifier.
final paymentsProvider = StateNotifierProvider<PaymentsNotifier, PaymentState>(
  (ref) => PaymentsNotifier(ref.watch(paymentRepositoryProvider)),
);
