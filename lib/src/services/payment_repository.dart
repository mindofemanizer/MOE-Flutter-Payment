import 'package:dio/dio.dart';

import 'package:moe_flutter_core/moe_flutter_core.dart';
import 'package:moe_flutter_payment/src/config/payment_config.dart';
import 'package:moe_flutter_payment/src/models/payment_transaction_model.dart';
import 'package:moe_flutter_payment/src/models/payment_provider.dart';
import 'package:moe_flutter_payment/src/models/payment_status.dart';

/// Repository for payment operations.
class PaymentRepository {
  final Dio _dio;

  PaymentRepository(this._dio, MoePaymentConfig _);

  // ── Payment Transactions ───────────────────────────────────

  /// Create new payment transaction (generate checkout URL/QRIS).
  Future<AppResult<Map<String, dynamic>>> createPayment({
    required String orderNumber,
    required double amount,
    required PaymentProvider provider,
    required String method,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _dio.post(
        '/payments',
        data: {
          'order_number': orderNumber,
          'amount': amount,
          'provider': provider.stringValue,
          'method': method,
          if (metadata != null) 'metadata': metadata,
        },
      );
      return Ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// Get payment status and details.
  Future<AppResult<PaymentTransactionModel>> getPayment(String id) async {
    try {
      final response = await _dio.get('/payments/$id');
      return Ok(
        PaymentTransactionModel.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// List payment transactions with filtering.
  Future<AppResult<List<PaymentTransactionModel>>> listPayments({
    String? orderNumber,
    DateTime? startDate,
    DateTime? endDate,
    PaymentStatus? status,
    String? method,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (orderNumber != null) 'order_number': orderNumber,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
        if (status != null) 'status': status.value,
        if (method != null) 'method': method,
      };
      final response = await _dio.get('/payments', queryParameters: params);
      final data = response.data as Map<String, dynamic>;
      final payments = (data['data'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map((p) => PaymentTransactionModel.fromJson(p))
          .toList();
      return Ok(payments);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// Validate webhook signature (server-to-server).
  Future<AppResult<bool>> validateWebhookSignature({
    required String payload,
    required String signature,
  }) async {
    try {
      final params = <String, dynamic>{
        'payload': payload,
        'signature': signature,
      };
      await _dio.post('/webhooks/validate', data: params);
      return const Ok(true);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// Refund payment.
  Future<AppResult<void>> refundPayment(
    String id, {
    required double amount,
    required String reason,
  }) async {
    try {
      await _dio.post(
        '/payments/$id/refund',
        data: {'amount': amount, 'reason': reason},
      );
      return const Ok(null);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// Check payment status via polling (for webhooks not available).
  Future<AppResult<PaymentTransactionModel>> checkPaymentStatus(
    String id,
  ) async {
    return getPayment(id);
  }

  /// Get QRIS code for payment.
  Future<AppResult<Map<String, dynamic>>> getQrisCode({
    required String orderNumber,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/qris',
        data: {'order_number': orderNumber, 'amount': amount},
      );
      return Ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }

  /// Generate virtual account number.
  Future<AppResult<Map<String, dynamic>>> generateVirtualAccount({
    required String orderNumber,
    required String aliasName,
    required double amount,
  }) async {
    try {
      final response = await _dio.post(
        '/payments/virtual-account',
        data: {
          'order_number': orderNumber,
          'alias_name': aliasName,
          'amount': amount,
        },
      );
      return Ok(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      return Err(mapDioErrorToFailure(e));
    } catch (e) {
      return Err(AppFailure(type: FailureType.unknown, message: e.toString()));
    }
  }
}
