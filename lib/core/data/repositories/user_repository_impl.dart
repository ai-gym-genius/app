import 'package:gym_genius/core/domain/entities/user.dart';
import 'package:gym_genius/core/domain/repositories/user_repository.dart';
import 'package:gym_genius/core/network/data/user_credentials.dart';
import 'package:gym_genius/core/network/dio_service.dart';

/// Implementation of [UserRepository] for handling user-related operations.
class UserRepositoryImpl implements UserRepository {
  /// Creates an instance of [UserRepositoryImpl] with the given 
  /// [credentials] and [service].
  UserRepositoryImpl(this.credentials, this.service);

  /// User's credentials.
  /// 
  /// Used for token access.
  final UserCredentials credentials;

  /// Service for network access.
  final DioService service;

  @override
  Future<User> createUser({
    required String name,
    required String surname,
    required String password,
    required String email,
    required String login,
  }) async {
    final user = User(
      login: login,
      email: email,
      name: name,
      surname: surname,
      password: password,
    );

    await service.post('/users', data: user.toJson());
    return user;
  }

  @override
  Future<String> loginUser({
    required String login,
    required String password,
  }) async {
    await service.post('/auth_user', data: {
      'login': login,
      'password': password,
    });

    return '123';
  }

  @override
  Future<void> getToken() {
    // TODO: implement getToken
    throw UnimplementedError();
  }
}
