class User {
  String firstName;
  String lastName;
  String userName;
  String email;
  String password;
  String? avatar;
  String? bio;
  String? headline;
  User({
    required this.firstName,
    required this.lastName,
    required this.userName,
    required this.email,
    required this.password,
    this.avatar,
    this.bio,
    this.headline,
  });
}
