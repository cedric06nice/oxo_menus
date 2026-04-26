import 'package:directus_api_manager/directus_api_manager.dart';
import 'package:reflectable/reflectable.dart';

/// A canonical in-process fake for [DirectusWebSocketSubscription].
///
/// Consolidates the inline `FakeDirectusWebSocketSubscription` classes that
/// previously existed across the test suite.
///
/// Tests drive the subscription by calling [emitCreate], [emitUpdate],
/// [emitDelete], [emitError], or [emitDone] directly.  The fake records
/// every callback invocation on [onCreateCallCount], [onUpdateCallCount], and
/// [onDeleteCallCount] for assertion convenience.
///
/// The [specificClass] and [collectionMetadata] getters are never called
/// during unit tests — they exist only for the reflectable-based toJson()
/// path which tests bypass entirely.  Both throw [UnimplementedError] to make
/// misuse obvious.
///
/// Usage:
/// ```dart
/// final fake = FakeDirectusWebSocketSubscription(uid: 'menu-42');
/// fake.emitCreate({'id': 1, 'type_key': 'dish', 'index': 0});
/// ```
class FakeDirectusWebSocketSubscription
    implements DirectusWebSocketSubscription<DirectusItem> {
  @override
  final String uid;

  FakeDirectusWebSocketSubscription({this.uid = 'fake-subscription-uid'});

  // -------------------------------------------------------------------------
  // DirectusWebSocketSubscription callback fields
  // -------------------------------------------------------------------------

  @override
  String? Function(Map<String, dynamic>)? onCreate;

  @override
  String? Function(Map<String, dynamic>)? onUpdate;

  @override
  String? Function(Map<String, dynamic>)? onDelete;

  @override
  Function(dynamic)? onError;

  @override
  Function()? onDone;

  // -------------------------------------------------------------------------
  // Fields required by the interface — unused in tests, default to null
  // -------------------------------------------------------------------------

  @override
  List<String>? get fields => null;

  @override
  Filter? get filter => null;

  @override
  List<SortProperty>? get sort => null;

  @override
  int? get limit => null;

  @override
  int? get offset => null;

  // -------------------------------------------------------------------------
  // Reflectable-backed members — not called in unit tests
  // -------------------------------------------------------------------------

  /// Not used in unit tests.  Throws [UnimplementedError] on access to signal
  /// that the test has unintentionally triggered the reflectable path.
  @override
  ClassMirror get specificClass =>
      throw UnimplementedError('specificClass is not available in fake');

  /// Not used in unit tests.  Throws [UnimplementedError] on access.
  @override
  CollectionMetadata get collectionMetadata =>
      throw UnimplementedError('collectionMetadata is not available in fake');

  @override
  String get collection => 'fake_collection';

  @override
  String toJson() => '{"type":"subscribe","uid":"$uid"}';

  @override
  List<String> get fieldsToJson => [];

  @override
  Map<String, dynamic>? get filterToJson => null;

  // -------------------------------------------------------------------------
  // Call counters — tests can assert invocation counts
  // -------------------------------------------------------------------------

  int onCreateCallCount = 0;
  int onUpdateCallCount = 0;
  int onDeleteCallCount = 0;
  int onErrorCallCount = 0;
  int onDoneCallCount = 0;

  // -------------------------------------------------------------------------
  // Driver methods — tests call these to simulate server-push events
  // -------------------------------------------------------------------------

  /// Simulates a `create` event arriving from the Directus WebSocket server.
  void emitCreate(Map<String, dynamic> data) {
    onCreateCallCount++;
    onCreate?.call(data);
  }

  /// Simulates an `update` event arriving from the Directus WebSocket server.
  void emitUpdate(Map<String, dynamic> data) {
    onUpdateCallCount++;
    onUpdate?.call(data);
  }

  /// Simulates a `delete` event arriving from the Directus WebSocket server.
  void emitDelete(Map<String, dynamic> data) {
    onDeleteCallCount++;
    onDelete?.call(data);
  }

  /// Simulates an error on the socket.
  void emitError(dynamic error) {
    onErrorCallCount++;
    onError?.call(error);
  }

  /// Simulates the subscription completing (unsubscribe acknowledged or socket
  /// closed).
  void emitDone() {
    onDoneCallCount++;
    onDone?.call();
  }
}
