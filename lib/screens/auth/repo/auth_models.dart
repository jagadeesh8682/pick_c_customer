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
  final String userName;
  final String mobileNumber;
  final String email;
  final String password;
  final String reEnterPwd;

  SignUpRequest({
    required this.userName,
    required this.mobileNumber,
    required this.email,
    required this.password,
    required this.reEnterPwd,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'mobileNumber': mobileNumber,
      'email': email,
      'password': password,
      'reEnterPwd': reEnterPwd,
    };
  }

  factory SignUpRequest.fromJson(Map<String, dynamic> json) {
    return SignUpRequest(
      userName: json['userName'] ?? json['UserName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? json['mobileNo'] ?? '',
      email: json['email'] ?? json['EmailID'] ?? '',
      password: json['password'] ?? json['Password'] ?? '',
      reEnterPwd: json['reEnterPwd'] ?? json['reEnterPassword'] ?? '',
    );
  }
}

class ForgotPasswordRequest {
  final String mobileNumber;
  final String password;
  final String reEnterPwd;

  ForgotPasswordRequest({
    required this.mobileNumber,
    required this.password,
    required this.reEnterPwd,
  });

  Map<String, dynamic> toJson() {
    return {
      'mobileNumber': mobileNumber,
      'password': password,
      'reEnterPwd': reEnterPwd,
    };
  }

  factory ForgotPasswordRequest.fromJson(Map<String, dynamic> json) {
    return ForgotPasswordRequest(
      mobileNumber: json['mobileNumber'] ?? json['mobileNo'] ?? '',
      password: json['password'] ?? json['newPassword'] ?? '',
      reEnterPwd: json['reEnterPwd'] ?? json['reEnterPassword'] ?? '',
    );
  }
}

class ChangePasswordRequest {
  final String oldPassword;
  final String newPassword;
  final String confirmPassword;

  ChangePasswordRequest({
    required this.oldPassword,
    required this.newPassword,
    required this.confirmPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'oldPassword': oldPassword,
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
    };
  }

  factory ChangePasswordRequest.fromJson(Map<String, dynamic> json) {
    return ChangePasswordRequest(
      oldPassword: json['oldPassword'] ?? json['currentPassword'] ?? '',
      newPassword: json['newPassword'] ?? '',
      confirmPassword: json['confirmPassword'] ?? json['newPassword'] ?? '',
    );
  }
}

class Device {
  final String deviceId;
  final String mobileNo;

  Device({required this.deviceId, required this.mobileNo});

  Map<String, dynamic> toJson() {
    return {'deviceId': deviceId, 'mobileNo': mobileNo};
  }

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      deviceId: json['deviceId'] ?? '',
      mobileNo: json['mobileNo'] ?? json['mobileNumber'] ?? '',
    );
  }
}
