abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message);
}

class DuplicateUserFailure extends Failure {
  const DuplicateUserFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class DoubleBookingFailure extends Failure {
  const DoubleBookingFailure(super.message);
}

class BackupFailure extends Failure {
  const BackupFailure(super.message);
}
