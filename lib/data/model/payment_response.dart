class PaymentResponse {
  final String bin;
  final String accountNumber;
  final String accountName;
  final int amount;
  final String description;
  final String orderCode;
  final String currency;
  final String paymentLinkId;
  final String status;
  final String checkoutUrl;
  final String qrCode;

  PaymentResponse({
    required this.bin,
    required this.accountNumber,
    required this.accountName,
    required this.amount,
    required this.description,
    required this.orderCode,
    required this.currency,
    required this.paymentLinkId,
    required this.status,
    required this.checkoutUrl,
    required this.qrCode,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      bin: json['bin']?.toString() ?? '',
      accountNumber: json['accountNumber']?.toString() ?? '',
      accountName: json['accountName']?.toString() ?? '',
      amount: json['amount'] is String ? int.tryParse(json['amount']) ?? 0 : json['amount'] ?? 0,
      description: json['description']?.toString() ?? '',
      orderCode: json['orderCode']?.toString() ?? '',
      currency: json['currency']?.toString() ?? 'VND',
      paymentLinkId: json['paymentLinkId']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      checkoutUrl: json['checkoutUrl']?.toString() ?? '',
      qrCode: json['qrCode']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bin': bin,
      'accountNumber': accountNumber,
      'accountName': accountName,
      'amount': amount,
      'description': description,
      'orderCode': orderCode,
      'currency': currency,
      'paymentLinkId': paymentLinkId,
      'status': status,
      'checkoutUrl': checkoutUrl,
      'qrCode': qrCode,
    };
  }

  // Helper methods
  bool get isPending => status == 'PENDING';
  bool get isCompleted => status == 'PAID';
  bool get isCancelled => status == 'CANCELLED';

  String get formattedAmount => '${amount.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},'
  )} $currency';

  @override
  String toString() {
    return 'PaymentResponse{bin: $bin, accountNumber: $accountNumber, accountName: $accountName, amount: $amount, description: $description, orderCode: $orderCode, currency: $currency, paymentLinkId: $paymentLinkId, status: $status, checkoutUrl: $checkoutUrl, qrCode: $qrCode}';
  }
}
