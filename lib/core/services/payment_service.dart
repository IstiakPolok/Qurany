import 'package:flutter/foundation.dart';
import 'package:pay/pay.dart';

class PaymentService {
  static const String _googlePayConfigPath =
      'payment_configurations/google_pay_config.json';

  /// Pre-configured payment items for Google Pay
  static List<PaymentItem> getPaymentItems({
    required String label,
    required String amount,
  }) {
    return [
      PaymentItem(
        label: label,
        amount: amount,
        status: PaymentItemStatus.final_price,
      ),
    ];
  }

  /// Handles the payment result from Google Pay
  static void onGooglePayResult(Map<String, dynamic> result) {
    debugPrint('[PaymentService] Google Pay Result: $result');
    // Here you would typically send the token to your payment processor (Stripe, etc.)
    // result['paymentMethodData']['tokenizationData']['token']
  }

  /// Configuration for the Google Pay button
  static const String googlePayConfig = '''{
    "provider": "google_pay",
    "data": {
      "environment": "TEST",
      "apiVersion": 2,
      "apiVersionMinor": 0,
      "allowedPaymentMethods": [
        {
          "type": "CARD",
          "tokenizationSpecification": {
            "type": "PAYMENT_GATEWAY",
            "parameters": {
              "gateway": "example",
              "gatewayMerchantId": "exampleGatewayMerchantId"
            }
          },
          "parameters": {
            "allowedCardNetworks": ["VISA", "MASTERCARD"],
            "allowedAuthMethods": ["PAN_ONLY", "CRYPTOGRAM_3DS"],
            "billingAddressRequired": true,
            "billingAddressParameters": {
              "format": "FULL",
              "phoneNumberRequired": true
            }
          }
        }
      ],
      "merchantInfo": {
        "merchantId": "01234567890123456789",
        "merchantName": "Qurany App"
      },
      "transactionInfo": {
        "countryCode": "US",
        "currencyCode": "USD"
      }
    }
  }''';
}
