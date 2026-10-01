/// Data model representing the payload sent to `/api/register.json`.
class RegisterRequestModel {
  final String username;
  final String email;
  final String nickname;
  final String password;
  final String language;
  final String defaultCurrency;
  final List categories;

  const RegisterRequestModel({
    required this.username,
    required this.email,
    required this.nickname,
    required this.password,
    required this.language,
    this.defaultCurrency = 'USD',
    this.categories = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'nickname': nickname,
      'password': password,
      'language': language,
      'defaultCurrency': defaultCurrency,
      'categories': categories,
    };
  }

  factory RegisterRequestModel.fromJson(Map<String, dynamic>? json) {
    return RegisterRequestModel(
      username: json?['username']?.toString() ?? '',
      email: json?['email']?.toString() ?? '',
      nickname: json?['nickname']?.toString() ?? '',
      password: json?['password']?.toString() ?? '',
      language: json?['language']?.toString() ?? 'en',
      defaultCurrency: json?['defaultCurrency']?.toString() ?? 'USD',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterRequestModel &&
          runtimeType == other.runtimeType &&
          username == other.username &&
          email == other.email &&
          nickname == other.nickname &&
          password == other.password &&
          language == other.language &&
          defaultCurrency == other.defaultCurrency;

  @override
  int get hashCode => Object.hash(
    username,
    email,
    nickname,
    password,
    language,
    defaultCurrency,
  );

  @override
  String toString() =>
      'RegisterRequestModel(username: $username, email: $email, nickname: $nickname, language: $language, defaultCurrency: $defaultCurrency, password: [PROTECTED])';
}
