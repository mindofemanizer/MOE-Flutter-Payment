/// Payment status lifecycle.
enum PaymentStatus {
  pending('pending', 'Menunggu Pembayaran'),
  waiting_payment('waiting_payment', 'Menunggu Pembayaran User'),
  paid('paid', 'Lunas'),
  failed('failed', 'Gagal'),
  refunded('refunded', 'Direfund'),
  cancelled('cancelled', 'Dibatalkan');

  const PaymentStatus(this.value, this.displayName);
  final String value;
  final String displayName;

  factory PaymentStatus.fromValue(String value) {
    return values.firstWhere(
      (e) => e.value == value,
      orElse: () => pending,
    );
  }

  bool get isCompleted => this == paid || this == cancelled;
  bool get isActive => !isCompleted && this != refunded;
}

/// Payment method channel.
enum PaymentMethodChannel {
  onlineBankTransfer('online_bank_transfer', 'Transfer Bank Online'),
  bankTransfer('bank_transfer', 'Transfer Bank Manual'),
  qris('qris', 'QRIS'),
  ewallet('ewallet', 'E-Wallet'),
  creditCard('credit_card', 'Kartu Kredit/Debit'),
  retailOutlet('retail_outlet', 'Retail Outlet (Alfamart/Indomaret)'),
  virtualAccount('virtual_account', 'Virtual Account'),
  overdraft('overdraft', 'Paylater/Cicilan');

  const PaymentMethodChannel(this.code, this.displayName);
  final String code;
  final String displayName;

  factory PaymentMethodChannel.fromValue(String value) {
    return values.firstWhere(
      (e) => e.code == value,
      orElse: () => onlineBankTransfer,
    );
  }
}
