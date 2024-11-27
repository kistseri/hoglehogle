class LoginDTO {
  final String email;
  final String shaPassword;

  LoginDTO({
    required this.email,
    required this.shaPassword,
  });

  Map<String, dynamic> toJson() => {
        "id": email,
        "pwd": shaPassword,
      };
}
