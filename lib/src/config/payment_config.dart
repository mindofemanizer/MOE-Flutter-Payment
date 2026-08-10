import 'package:equatable/equatable.dart';

/// Configuration for MOE Payment module.
class MoePaymentConfig extends Equatable {
  final String apiUrl;
  final String apiKey;
  final bool enableWebhooks;
  final List<String> supportedProviders;

  const MoePaymentConfig({
    required this.apiUrl,
    required this.apiKey,
    this.enableWebhooks = true,
    this.supportedProviders = const ['midtrans', 'xendit'],
  });

  @override
  List<Object?> get props => [apiUrl, apiKey, enableWebhooks, supportedProviders];
}
