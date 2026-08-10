# Changelog

## 1.0.0 — 2026-08-10

### Added
- Initial release
- `PaymentProvider` — Midtrans, Xendit support
- `PaymentStatus` — pending/waiting/paid/failed/refunded/cancelled lifecycle
- `PaymentMethodChannel` — QRIS, virtual account, bank transfer, e-wallet, credit card
- `PaymentTransactionModel` — complete payment record with external ID
- `PaymentRepository` — create checkout/generate QRIS, poll status, refund, webhook validation
- `PaymentsNotifier` — polling auto-check until completed
- `MoePaymentConfig` — configurable API URL + API key + webhook settings

### Features
- Multiple payment gateway support (Midtrans, Xendit extensible)
- Auto-polling payment status (5s interval, 5min timeout)
- QRIS generation for mobile payments
- Virtual account number generation
- Refund capability
- Webhook signature validation
- Receipt URL tracking
- Amount validation (must be > 0)
