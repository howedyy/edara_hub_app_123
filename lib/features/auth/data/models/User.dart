class User {
  const User({
      required this.id,
      required this.name,
      required this.employeeId,
      required this.email,
      required this.phone,
      required this.ipDevice,
      required this.status,});

  factory User.fromJson(dynamic json) {
    return User(id: json['id'],
        name: json['name'],
        employeeId: json['employee_id'],
        email: json['email'],
        phone: json['phone'],
        ipDevice: json['ip_device'],
        status: json['status']
      );

  }
  final int id;
  final String name;
  final String employeeId;
  final String email;
  final  String phone;
  final String ipDevice;
  final String status;


}