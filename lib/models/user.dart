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
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['first_name'],
      username: json['username'],
      lastName: json['last_name'],
      avatar: json['avatar'],
      bio: json['bio'],
      headline: json['headline'],
    );
  }
}
