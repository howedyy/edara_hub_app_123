class LoginRequest {
 const LoginRequest(
     {
     required this.employeeId,
     required this.password,}
     );


  final String employeeId;
 final  String password;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['employee_id'] = employeeId;
    map['password'] = password;
    return map;
  }

}