import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';

// ---------------------------------------------------------------------------
// Top-level convenience constructors
// ---------------------------------------------------------------------------

/// Wraps [value] in a [Success] with [DomainError] as the error type.
///
/// Usage:
/// ```dart
/// final result = success<List<Menu>>([]);
/// ```
Success<T, DomainError> success<T>(T value) => Success<T, DomainError>(value);

/// Wraps [error] in a [Failure] with [DomainError] as the error type.
///
/// Usage:
/// ```dart
/// final result = failure<Menu>(notFound());
/// ```
Failure<T, DomainError> failure<T>(DomainError error) =>
    Failure<T, DomainError>(error);

// ---------------------------------------------------------------------------
// Common error factories
// ---------------------------------------------------------------------------

/// A [NotFoundError] with the default message.
NotFoundError notFound([String message = 'Resource not found']) =>
    NotFoundError(message);

/// An [UnauthorizedError] with the default message.
UnauthorizedError unauthorized([String message = 'Unauthorized']) =>
    UnauthorizedError(message);

/// A [NetworkError] with the default message.
NetworkError network([String message = 'Network error']) =>
    NetworkError(message);

/// A [NetworkUnavailableError] with the default message.
NetworkUnavailableError networkUnavailable(
        [String message = 'Network unavailable']) =>
    NetworkUnavailableError(message);

/// A [ServerError] with the default message.
ServerError server([String message = 'Server error']) => ServerError(message);

/// An [InvalidCredentialsError] with the default message.
InvalidCredentialsError invalidCredentials(
        [String message = 'Invalid credentials']) =>
    InvalidCredentialsError(message);

/// A [TokenExpiredError] with the default message.
TokenExpiredError tokenExpired([String message = 'Token expired']) =>
    TokenExpiredError(message);

/// A [ValidationError] with a required message and optional details.
ValidationError validation(String message, {dynamic details}) =>
    ValidationError(message, details: details);

/// An [UnknownError] with the default message.
UnknownError unknown([String message = 'Unknown error', dynamic details]) =>
    UnknownError(message, details);

/// A [RateLimitError] with the default message.
RateLimitError rateLimit([String message = 'Too many requests']) =>
    RateLimitError(message);

// ---------------------------------------------------------------------------
// Pre-built Failure<T, DomainError> factories for the most common cases
// ---------------------------------------------------------------------------

/// A [Failure] wrapping a [NotFoundError].
Failure<T, DomainError> failureNotFound<T>([String? message]) =>
    failure<T>(notFound(message ?? 'Resource not found'));

/// A [Failure] wrapping an [UnauthorizedError].
Failure<T, DomainError> failureUnauthorized<T>([String? message]) =>
    failure<T>(unauthorized(message ?? 'Unauthorized'));

/// A [Failure] wrapping a [NetworkError].
Failure<T, DomainError> failureNetwork<T>([String? message]) =>
    failure<T>(network(message ?? 'Network error'));

/// A [Failure] wrapping a [ServerError].
Failure<T, DomainError> failureServer<T>([String? message]) =>
    failure<T>(server(message ?? 'Server error'));

/// A [Failure] wrapping an [UnknownError].
Failure<T, DomainError> failureUnknown<T>([String? message]) =>
    failure<T>(unknown(message ?? 'Unknown error'));
