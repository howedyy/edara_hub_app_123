class RegisterRequest {
  const RegisterRequest({
      required this.email,
      required this.employeeId,
      required this.ipDevice,
      required this.name,
      required this.password,
      required this.phone,}
      );

  final String email;
  final String employeeId;
  final String ipDevice;
  final String name;
  final String password;
  final String phone;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['email'] = email;
    map['employee_id'] = employeeId;
    map['ip_device'] = ipDevice;
    map['name'] = name;
    map['password'] = password;
    map['phone'] = phone;
    return map;
  }

}