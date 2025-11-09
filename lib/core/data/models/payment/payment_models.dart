/// Models for payment-related operations

class BillDetails {
  final String bookingNumber;
  final double totalFare;
  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double? extraCharges;
  final double? discount;
  final double finalAmount;
  final String currency;
  final String paymentStatus;
  final String? paymentMethod;
  final DateTime paymentDate;

  BillDetails({
    required this.bookingNumber,
    required this.totalFare,
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    this.extraCharges,
    this.discount,
    required this.finalAmount,
    this.currency = 'INR',
    required this.paymentStatus,
    this.paymentMethod,
    required this.paymentDate,
  });

  factory BillDetails.fromJson(Map<String, dynamic> json) {
    return BillDetails(
      bookingNumber: json['bookingNumber'] ?? json['bookingNo'] ?? '',
      totalFare: (json['totalFare'] ?? 0).toDouble(),
      baseFare: (json['baseFare'] ?? 0).toDouble(),
      distanceFare: (json['distanceFare'] ?? 0).toDouble(),
      timeFare: (json['timeFare'] ?? 0).toDouble(),
      extraCharges: json['extraCharges']?.toDouble(),
      discount: json['discount']?.toDouble(),
      finalAmount: (json['finalAmount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      paymentStatus: json['paymentStatus'] ?? json['payment_status'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? json['payment_method'],
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingNumber': bookingNumber,
      'totalFare': totalFare,
      'baseFare': baseFare,
      'distanceFare': distanceFare,
      'timeFare': timeFare,
      'extraCharges': extraCharges,
      'discount': discount,
      'finalAmount': finalAmount,
      'currency': currency,
      'paymentStatus': paymentStatus,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }
}

class PaymentRequest {
  final String bookingNumber;
  final String driverId;
  final String paymentMethod; // "cash", "online"
  final double amount;
  final String? paymentId; // For online payments

  PaymentRequest({
    required this.bookingNumber,
    required this.driverId,
    required this.paymentMethod,
    required this.amount,
    this.paymentId,
  });

  Map<String, dynamic> toJson() {
    return {
      'bookingNumber': bookingNumber,
      'driverId': driverId,
      'paymentMethod': paymentMethod,
      'amount': amount,
      if (paymentId != null) 'paymentId': paymentId,
    };
  }
}

class RSAKeyResponse {
  final String rsaKey;
  final String orderId;
  final String paymentId;
  final Map<String, dynamic>? additionalData;

  RSAKeyResponse({
    required this.rsaKey,
    required this.orderId,
    required this.paymentId,
    this.additionalData,
  });

  factory RSAKeyResponse.fromJson(Map<String, dynamic> json) {
    return RSAKeyResponse(
      rsaKey: json['rsaKey'] ?? json['key'] ?? '',
      orderId: json['orderId'] ?? json['order_id'] ?? '',
      paymentId: json['paymentId'] ?? json['payment_id'] ?? '',
      additionalData: json['additionalData'] ??
          (json.containsKey('data') ? json['data'] : null),
    );
  }
}

class Invoice {
  final String invoiceNumber;
  final String bookingNumber;
  final DateTime invoiceDate;
  final BillDetails billDetails;
  final String pickupAddress;
  final String dropAddress;
  final String vehicleDetails;
  final String driverName;
  final String driverPhone;
  final String? paymentMethod;
  final String? taxInvoice;

  Invoice({
    required this.invoiceNumber,
    required this.bookingNumber,
    required this.invoiceDate,
    required this.billDetails,
    required this.pickupAddress,
    required this.dropAddress,
    required this.vehicleDetails,
    required this.driverName,
    required this.driverPhone,
    this.paymentMethod,
    this.taxInvoice,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      invoiceNumber: json['invoiceNumber'] ?? '',
      bookingNumber: json['bookingNumber'] ?? '',
      invoiceDate: json['invoiceDate'] != null
          ? DateTime.parse(json['invoiceDate'])
          : DateTime.now(),
      billDetails: BillDetails.fromJson(json['billDetails'] ?? {}),
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
      vehicleDetails: json['vehicleDetails'] ?? '',
      driverName: json['driverName'] ?? '',
      driverPhone: json['driverPhone'] ?? '',
      paymentMethod: json['paymentMethod'],
      taxInvoice: json['taxInvoice'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'invoiceNumber': invoiceNumber,
      'bookingNumber': bookingNumber,
      'invoiceDate': invoiceDate.toIso8601String(),
      'billDetails': billDetails.toJson(),
      'pickupAddress': pickupAddress,
      'dropAddress': dropAddress,
      'vehicleDetails': vehicleDetails,
      'driverName': driverName,
      'driverPhone': driverPhone,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (taxInvoice != null) 'taxInvoice': taxInvoice,
    };
  }
}



