class UserStatusResponse {
  final bool success;
  final String message;
  final UserStatusData? data;

  UserStatusResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UserStatusResponse.fromJson(Map<String, dynamic> json) {
    return UserStatusResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      data: json['data'] != null
          ? UserStatusData.fromJson(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserStatusData {
  final UserInfo user;

  UserStatusData({required this.user});

  factory UserStatusData.fromJson(Map<String, dynamic> json) {
    return UserStatusData(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
    };
  }

  bool get isApproved => user.status == 'active';
}

class UserInfo {
  final int id;
  final String name;
  final String employeeId;
  final String email;
  final String phone;
  final String status;

  UserInfo({
    required this.id,
    required this.name,
    required this.employeeId,
    required this.email,
    required this.phone,
    required this.status,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int,
      name: json['name'] as String,
      employeeId: json['employee_id'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'employee_id': employeeId,
      'email': email,
      'phone': phone,
      'status': status,
    };
  }
}
