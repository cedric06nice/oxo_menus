import 'package:oxo_menus/core/errors/domain_errors.dart';

/// Maps exceptions from data layer (Directus, network, etc.) to domain errors
DomainError mapDirectusError(dynamic error) {
  // Handle Directus exceptions
  if (_isDirectusException(error)) {
    final code = _getExceptionCode(error);
    final message = _getExceptionMessage(error);
    final extensions = _getExceptionExtensions(error);

    switch (code) {
      case 'INVALID_CREDENTIALS':
      case 'INVALID_PAYLOAD':
        return InvalidCredentialsError(message);

      case 'TOKEN_EXPIRED':
        return TokenExpiredError(message);

      case 'FORBIDDEN':
        return UnauthorizedError(message);

      case 'NOT_FOUND':
        return NotFoundError(message);

      case 'INVALID_QUERY':
      case 'RECORD_NOT_UNIQUE':
      case 'INVALID_FOREIGN_KEY':
        return ValidationError(message, details: extensions);

      default:
        return ServerError(message);
    }
  }

  // Handle network exceptions
  if (_isNetworkException(error)) {
    return NetworkError(error.toString());
  }

  // Default to UnknownError for any other exception type
  return UnknownError(error.toString());
}

/// Check if the error is a Directus exception by looking for 'code' property
bool _isDirectusException(dynamic error) {
  try {
    // Check if error has a 'code' property (duck typing)
    return error != null &&
        error.runtimeType.toString().contains('DirectusException');
  } catch (_) {
    return false;
  }
}

/// Check if the error is a Network exception
bool _isNetworkException(dynamic error) {
  try {
    return error != null &&
        error.runtimeType.toString().contains('NetworkException');
  } catch (_) {
    return false;
  }
}

/// Extract error code from exception using reflection
String _getExceptionCode(dynamic error) {
  try {
    // Use reflection to get 'code' property
    final mirror = error as dynamic;
    return mirror.code?.toString() ?? 'UNKNOWN';
  } catch (_) {
    return 'UNKNOWN';
  }
}

/// Extract error message from exception
String _getExceptionMessage(dynamic error) {
  try {
    final mirror = error as dynamic;
    return mirror.message?.toString() ?? error.toString();
  } catch (_) {
    return error.toString();
  }
}

/// Extract extensions from exception
Map<String, dynamic>? _getExceptionExtensions(dynamic error) {
  try {
    final mirror = error as dynamic;
    final extensions = mirror.extensions;
    return extensions is Map<String, dynamic> ? extensions : null;
  } catch (_) {
    return null;
  }
}
