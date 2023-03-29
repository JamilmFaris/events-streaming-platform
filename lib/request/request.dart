abstract class Request {
  static void login(String userName, String password) {}

  static void signup(
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
  ) {}

  static void editAccount(
    String firstName,
    String lastName,
    String userName,
    String email,
    String password,
    String bio,
    String headline,
  ) {}
}
