

class PaymentSettings {
  final String razorpay_key;
  final String razorpay_secret_key;

  PaymentSettings(
      {required this.razorpay_key, required this.razorpay_secret_key});

  factory PaymentSettings.fromJson(Map<String, dynamic> json) {
    return PaymentSettings(
        razorpay_key: json['razorpay_key'],
        razorpay_secret_key: json['razorpay_secret_key']);
  }
}
