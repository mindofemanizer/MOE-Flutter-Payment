/// Payment gateway provider.
sealed class PaymentProvider {
  const PaymentProvider();
  
  String get stringValue;
  
  factory PaymentProvider.fromString(String value) {
    switch (value) {
      case 'midtrans':
        return midtrans;
      case 'xendit':
        return xendit;
      default:
        throw Exception('Unknown payment provider: $value');
    }
  }

  static const midtrans = _PaymentProviderMidtrans();
  static const xendit = _PaymentProviderXendit();
}

class _PaymentProviderMidtrans extends PaymentProvider {
  const _PaymentProviderMidtrans();
  @override
  String get stringValue => 'midtrans';
  String get displayName => 'Midtrans';
}

class _PaymentProviderXendit extends PaymentProvider {
  const _PaymentProviderXendit();
  @override
  String get stringValue => 'xendit';
  String get displayName => 'Xendit';
}
