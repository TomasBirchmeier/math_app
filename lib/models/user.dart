enum UserRole { student, admin }

class User {
  const User({
    required this.id,
    required this.displayName,
    required this.role,
    required this.password,
  });

  final String id;
  final String displayName;
  final UserRole role;
  final String password;
}
