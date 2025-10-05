class LoginCredentials {
  final String mobileNo;
  final String password;

  LoginCredentials({required this.mobileNo, required this.password});

  Map<String, dynamic> toJson() {
    return {'mobileNo': mobileNo, 'password': password};
  }

  factory LoginCredentials.fromJson(Map<String, dynamic> json) {
    return LoginCredentials(
      mobileNo: json['mobileNo'] ?? '',
      password: json['password'] ?? '',
    );
  }
}

class Token {
  final String tokenType;
  final int expiresIn;

  Token({required this.tokenType, required this.expiresIn});

  Map<String, dynamic> toJson() {
    return {'tokenType': tokenType, 'expiresIn': expiresIn};
  }

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? json['expires_in'] ?? 3600,
    );
  }
}

class Customer {
  final String id;
  final String name;
  final String mobileNo;
  final String email;
  final String address;
  final bool isActive;
  final DateTime createdAt;

  Customer({
    required this.id,
    required this.name,
    required this.mobileNo,
    required this.email,
    required this.address,
    required this.isActive,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mobileNo': mobileNo,
      'email': email,
      'address': address,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      mobileNo: json['mobileNo'] ?? json['mobile'] ?? '',
      email: json['email'] ?? '',
      address: json['address'] ?? '',
      isActive: json['isActive'] ?? json['is_active'] ?? true,
      createdAt:
          DateTime.tryParse(json['createdAt'] ?? json['created_at'] ?? '') ??
          DateTime.now(),
    );
  }

  Customer copyWith({
    String? id,
    String? name,
    String? mobileNo,
    String? email,
    String? address,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      mobileNo: mobileNo ?? this.mobileNo,
      email: email ?? this.email,
      address: address ?? this.address,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class SignUpRequest {
  final String mobileNo;
  final String password;
  final String name;
  final String emailID;
  final String deviceID;
  final DateTime createdOn;

  SignUpRequest({
    required this.mobileNo,
    required this.password,
    required this.name,
    required this.emailID,
    required this.deviceID,
    required this.createdOn,
  });

  Map<String, dynamic> toJson() {
    return {
      'MobileNo': mobileNo,
      'Password': password,
      'Name': name,
      'EmailID': emailID,
      'DeviceID': deviceID,
      'CreatedOn': createdOn.toIso8601String(),
    };
  }

  factory SignUpRequest.fromJson(Map<String, dynamic> json) {
    return SignUpRequest(
      mobileNo: json['MobileNo'] ?? json['mobileNo'] ?? '',
      password: json['Password'] ?? json['password'] ?? '',
      name: json['Name'] ?? json['name'] ?? '',
      emailID: json['EmailID'] ?? json['emailID'] ?? json['email'] ?? '',
      deviceID: json['DeviceID'] ?? json['deviceID'] ?? '',
      createdOn:
          DateTime.tryParse(json['CreatedOn'] ?? json['createdOn'] ?? '') ??
          DateTime.now(),
    );
  }

  SignUpRequest copyWith({
    String? mobileNo,
    String? password,
    String? name,
    String? emailID,
    String? deviceID,
    DateTime? createdOn,
  }) {
    return SignUpRequest(
      mobileNo: mobileNo ?? this.mobileNo,
      password: password ?? this.password,
      name: name ?? this.name,
      emailID: emailID ?? this.emailID,
      deviceID: deviceID ?? this.deviceID,
      createdOn: createdOn ?? this.createdOn,
    );
  }
}

class ForgotPasswordRequest {
  final String mobileNo;
  final String newPassword;
  final String otp;

  ForgotPasswordRequest({
    required this.mobileNo,
    required this.newPassword,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {'mobileNo': mobileNo, 'newPassword': newPassword, 'otp': otp};
  }

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      mobileNo: json['mobileNo'] ?? '',
      newPassword: json['newPassword'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      currentPassword: json['currentPassword'] ?? '',
      newPassword: json['newPassword'] ?? '',
    );
  }
}

class Device {
  final String deviceId;
  final String deviceType;
  final String fcmToken;

  Device({
    required this.deviceId,
    required this.deviceType,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceType': deviceType,
      'fcmToken': fcmToken,
    };
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] ?? '',
      deviceType: json['deviceType'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
    );
  }
}
