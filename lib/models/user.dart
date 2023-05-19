class User {
  String? firstName;
  String? lastName;
  String username;
  String? email;
  String? avatar;
  String? bio;
  String? headline;
  User({
    this.firstName,
    this.lastName,
    required this.username,
    this.email,
    this.avatar,
    this.bio,
    this.headline,
  });
}
