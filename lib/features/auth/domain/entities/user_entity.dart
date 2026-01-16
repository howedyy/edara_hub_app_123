class UserEntity{
  String name;
  String employeeId;
  String email;
  String phone;
  String ipDevice;
  //String password;
  String status;


  UserEntity({
  required this.name,
  required this.phone,
  required this.email,
  //required this.password,
  required this.employeeId,
  required this.ipDevice,
    required this.status}
      );


}