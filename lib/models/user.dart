class User {
  String firstName;
  String lastName;
  String username;
  String email;
  String? avatar;
  String? bio;
  String? headline;
  User({
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    this.avatar,
    this.bio,
    this.headline,
  });
}
