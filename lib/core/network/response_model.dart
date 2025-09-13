class ResponseModel {
  final String status;
  final String message;
  final int httpStatus;
  final Map<String, dynamic>? data;
  final String timestamp;

  ResponseModel({
    required this.status,
    required this.message,
    required this.httpStatus,
    this.data,
    required this.timestamp,
  });

  factory ResponseModel.fromJson(Map<String, dynamic> json) {
    return ResponseModel(
      status: json['status'] ?? '',
      message: json['message'] ?? '',
      httpStatus: json['httpStatus'] ?? 0,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      timestamp: json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'httpStatus': httpStatus,
      'data': data,
      'timestamp': timestamp,
    };
  }
}
