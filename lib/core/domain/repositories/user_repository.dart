import 'package:gym_genius/core/domain/entities/user.dart';

abstract interface class UserRepository {
  Future<void> getToken();
  Future<User> createUser({
    required String name,
    required String surname,
    required String password,
    required String email,
    required String login,
  });

  Future<String> loginUser({
    required String login,
    required String password,
  });
}
