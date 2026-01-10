/// Base class for all domain errors in the application.
///
/// All errors should extend this class instead of using exceptions.
/// This follows the Railway-Oriented Programming pattern where errors
/// are values, not exceptional situations.
sealed class DomainError {
  /// A human-readable error message.
  final String message;

  /// Optional additional details about the error.
  final dynamic details;

  const DomainError(this.message, {this.details});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DomainError &&
        other.runtimeType == runtimeType &&
        other.message == message &&
        other.details == details;
  }

  @override
  int get hashCode => Object.hash(runtimeType, message, details);

  @override
  String toString() {
    final buffer = StringBuffer(runtimeType.toString());
    buffer.write('($message');
    if (details != null) {
      buffer.write(', details: $details');
    }
    buffer.write(')');
    return buffer.toString();
  }
}

// ============================================================================
// Authentication Errors
// ============================================================================

/// Error thrown when user credentials are invalid.
final class InvalidCredentialsError extends DomainError {
  const InvalidCredentialsError([String message = 'Invalid credentials'])
      : super(message);
}

/// Error thrown when an authentication token has expired.
final class TokenExpiredError extends DomainError {
  const TokenExpiredError([String message = 'Token expired']) : super(message);
}

/// Error thrown when user is not authorized to perform an action.
final class UnauthorizedError extends DomainError {
  const UnauthorizedError([String message = 'Unauthorized']) : super(message);
}

// ============================================================================
// Network Errors
// ============================================================================

/// Error thrown when a network request fails.
final class NetworkError extends DomainError {
  const NetworkError([String message = 'Network error']) : super(message);
}

/// Error thrown when network is unavailable (no internet connection).
final class NetworkUnavailableError extends DomainError {
  const NetworkUnavailableError([String message = 'Network unavailable'])
      : super(message);
}

// ============================================================================
// Data Errors
// ============================================================================

/// Error thrown when a requested resource is not found.
final class NotFoundError extends DomainError {
  const NotFoundError([String message = 'Resource not found']) : super(message);
}

/// Error thrown when data validation fails.
final class ValidationError extends DomainError {
  const ValidationError(String message, {dynamic details})
      : super(message, details: details);
}

// ============================================================================
// Server Errors
// ============================================================================

/// Error thrown when the server returns an error.
final class ServerError extends DomainError {
  const ServerError([String message = 'Server error']) : super(message);
}

/// Error thrown when an unknown or unexpected error occurs.
final class UnknownError extends DomainError {
  const UnknownError([String message = 'Unknown error', dynamic details])
      : super(message, details: details);
}
