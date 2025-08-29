import 'package:objectbox/objectbox.dart';

/// Stores user authentication credentials for ObjectBox persistence.
@Entity()
class UserCredentials {
  /// no-doc.
  UserCredentials();
  @Id(assignable: true)

  /// Unique id of user.
  int id = 0;

  /// User's token.
  late String token;
}
