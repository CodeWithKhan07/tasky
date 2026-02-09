class dbExceptions implements Exception {
  final String message;
  final String? details;

  dbExceptions(this.message, [this.details]);

  @override
  String toString() => "DatabaseException: $message ${details ?? ''}";
}

class RecordNotFoundException extends dbExceptions {
  RecordNotFoundException(int id) : super("No record found with ID: $id");
}

class ValidationException extends dbExceptions {
  ValidationException(String message) : super("Validation Failed: $message");
}
