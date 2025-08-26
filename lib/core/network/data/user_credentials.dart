import 'package:objectbox/objectbox.dart';

@Entity()
class UserCredentials {
  UserCredentials();
  @Id(assignable: true)
  int id = 0;

  late String token;
}
