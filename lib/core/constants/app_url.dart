class AppUrl {
  static const String baseUrl = 'https://dev-api-gateway.storygenartist.com';

  // API endpoints
  static const String userService = '$baseUrl/user-service';
  static const String signup = '$userService/user/sign-up';
  static const String signupValidation = '$baseUrl/user-service/user/validate';
  static const String virifyGoogleToken =
      '$baseUrl/user-service/user/create-user-from-session?sessionId=';
  static const String login = '$userService/user/login';
  static const String createNewProject =
      "$baseUrl/spotlight-service/api/projects/create";
}
