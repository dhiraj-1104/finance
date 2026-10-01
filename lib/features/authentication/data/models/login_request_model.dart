/// Data model representing the payload sent to `/api/authorize.json`.
class LoginRequestModel {
  final String loginName;
  final String password;

  const LoginRequestModel({required this.loginName, required this.password});

  Map<String, dynamic> toJson() {
    return {'loginName': loginName, 'password': password};
  }

  factory LoginRequestModel.fromJson(Map<String, dynamic>? json) {
    return LoginRequestModel(
      loginName: json?['loginName']?.toString() ?? '',
      password: json?['password']?.toString() ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LoginRequestModel &&
          runtimeType == other.runtimeType &&
          loginName == other.loginName &&
          password == other.password;

  @override
  int get hashCode => Object.hash(loginName, password);

  @override
  String toString() =>
      'LoginRequestModel(loginName: $loginName, password: [PROTECTED])';
}
