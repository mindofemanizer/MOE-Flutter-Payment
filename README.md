# MOE-Flutter-Payment

Payment gateway integration for MOE Flutter ecosystem — QRIS, virtual accounts, refunds.

## Installation

```yaml
dependencies:
  moe_flutter_payment:
    git:
      url: https://github.com/mindofemanizer/MOE-Flutter-Payment.git
      ref: master
```

## Usage

### Setup

```dart
import 'package:moe_flutter_foundation/moe_flutter_foundation.dart';
import 'package:moe_flutter_payment/moe_flutter_payment.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  await MoeFoundation.setup(
    envConfig: EnvConfig.fromEnvironment(),
    sharedPreferences: prefs,
  );

  MoePayment.setup(
    config: MoePaymentConfig(
      apiUrl: 'https://api.kioskit.com/api/payments',
      apiKey: 'sk_production_xyz789',
      enableWebhooks: true,
      supportedProviders: ['midtrans', 'xendit'],
    ),
  );

  runApp(MoeFoundationProviderScope(child: MyApp()));
}
```

### Create Payment & Get QRIS

```dart
final result = await ref.read(paymentsProvider.notifier).createPayment(
  orderNumber: 'ORD-2026-001',
  amount: 75000,
  provider: PaymentProvider.midtrans,
  method: PaymentMethodChannel.qris.code,
  metadata: {'customer_name': 'John Doe'},
);

if (result is Ok) {
  final data = result.data;
  
  // Extract QRIS code from response
  final qrCodeBase64 = data['qr_code'] as String?;
  final redirectUrl = data['redirect_url'] as String?;
  
  if (qrCodeBase64 != null) {
    // Display QR code image
    final qrImage = QrImage(data: qrCodeBase64);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => PaymentQrisScreen(qrCode: qrCodeBase64),
      ),
    );
    
    // Start polling payment status
    final statusResult = await ref
      .read(paymentsProvider.notifier)
      .pollPaymentStatus('pay_id_from_response');
    
    switch (statusResult) {
      case Ok(:final transaction):
        if (transaction.isPaid) {
          print('✅ Payment berhasil! Total: Rp ${Formatters.currency(transaction.amount)}');
        } else {
          print('⚠️ Payment failed: ${transaction.status.displayName}');
        }
      case Err(:final failure):
        print('❌ Error: ${failure.message}');
    }
  } else if (redirectUrl != null) {
    // Redirect to payment page (credit card etc.)
    // Use webview or in-app browser
  }
}
```

### Poll Payment Status

```dart
// Manual polling
await ref.read(paymentsProvider.notifier).checkStatus('pay_id');

switch (ref.watch(paymentsProvider)) {
  case PaymentLoaded(:final transaction):
    // Show payment success/failure UI
    print('${transaction.status.displayName} - ${transaction.updatedAt}');
    
    if (transaction.isPaid) {
      // Navigate to order confirmation
      if (transaction.receiptUrl != null) {
        // Open receipt
      }
    }
  case PaymentLoading:
    CircularProgressIndicator();
  case PaymentError(:final failure):
    Text('Error: ${failure.message}');
}
```

### List All Payments

```dart
// Filter by date range and status
await ref.read(paymentsProvider.notifier).listPayments(
  startDate: DateTime(2026, 8, 1),
  endDate: DateTime(2026, 8, 31),
  status: PaymentStatus.paid, // only successful payments
);

// Then show list
switch (state) {
  case PaymentLoaded(:final payments):
    ListView.builder(
      itemCount: payments.length,
      itemBuilder: (ctx, i) => ListTile(
        title: Text(payments[i].orderNumber),
        subtitle: Text(Formatters.currency(payments[i].amount)),
        trailing: Chip(label: Text(payments[i].status.value)),
      ),
    );
}
```

### Generate Virtual Account

```dart
final result = await ref.read(paymentRepositoryProvider).generateVirtualAccount(
  orderNumber: 'ORD-001',
  aliasName: 'JOHN DOE',
  amount: 50000,
);

if ( result is Ok) {
  final vaData = result.data;
  print('Virtual Account Number: ${vaData['account_number']}');
  print('Bank Name: ${vaData['bank_name']}');
  print('Amount: Rp ${Formatters.currency(vaData['amount'])}');
}
```

### Refund Payment

```dart
final result = await ref.read(paymentRepositoryProvider).refundPayment(
  'pay_id',
  amount: 25000, // partial refund
  reason: 'Item damaged, customer requests partial refund',
);
```

## What's Included

| Module | Description |
|--------|-------------|
| `PaymentTransactionModel` | Full payment record with status lifecycle |
| `PaymentProvider` | Midtrans/Xendit gateway support |
| `PaymentStatus` | Pending→Waiting→Paid/Failed/Canc elled/Refunded states |
| `PaymentMethodChannel` | QRIS/Virtual Account/Bank Transfer/E-Wallet/Card |
| `PaymentRepository` | Create checkout, generate QRIS, poll status, refund |
| `PaymentsNotifier` | Auto-polling until completed, cancel payments |

## Payment Flow Example

```dart
1. User adds items to cart → Checkout
2. Call createPayment(orderNumber, amount, qris)
3. Display QR code to user
4. User scans QR with banking app → Pays
5. Poll payment status every 5 seconds
6. When status == 'paid', show success screen
7. Create order in Commerce package
8. Record finance entry in Finance package
```

## Webhooks (Server-side)

For real-time payment updates, configure webhooks on server:

```dart
// Server receives POST to /webhooks/payment
final isValid = await ref.read(paymentRepositoryProvider).validateWebhookSignature(
  payload: request.body,
  signature: headers['x-midtrans-signature'],
);

if (isValid) {
  // Update order status, send notification, create finance entry
}
```

Recommended: Enable webhooks for production, use polling only for demo/testing.
