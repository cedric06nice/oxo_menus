import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';

/// Base class for asynchronous use cases.
///
/// A use case encapsulates one business action and is the only thing a
/// ViewModel is allowed to talk to. Use cases never reach external systems
/// directly; they consume gateway interfaces via constructor injection.
abstract class UseCase<I, O> {
  const UseCase();

  Future<Result<O, DomainError>> execute(I input);
}

/// Base class for synchronous (pure-transformation) use cases.
///
/// Useful when the operation has no I/O — for example, mapping a domain entity
/// to a presentation-ready view model, filtering a list, or selecting a node
/// from a tree.
abstract class SyncUseCase<I, O> {
  const SyncUseCase();

  Result<O, DomainError> execute(I input);
}

/// Base class for stream-producing use cases (subscriptions).
///
/// Used by features that observe long-lived sources such as WebSockets or
/// connectivity changes.
abstract class StreamUseCase<I, O> {
  const StreamUseCase();

  Stream<Result<O, DomainError>> execute(I input);
}

/// Sentinel input type for use cases that take no parameters.
///
/// Prefer this over `void` or positional `null` so call sites read clearly:
/// `useCase.execute(NoInput.instance)`.
final class NoInput {
  const NoInput._();

  static const NoInput instance = NoInput._();
}
