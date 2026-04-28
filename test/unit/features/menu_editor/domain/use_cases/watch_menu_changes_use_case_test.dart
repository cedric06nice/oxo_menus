import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/features/collaboration/domain/entities/menu_change_event.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/watch_menu_changes_use_case.dart';

import '../../../../../fakes/fake_menu_subscription_repository.dart';

void main() {
  group('WatchMenuChangesUseCase', () {
    test('execute returns a stream that surfaces repository events', () async {
      final repo = FakeMenuSubscriptionRepository();
      final useCase = WatchMenuChangesUseCase(repository: repo);

      final received = <MenuChangeEvent>[];
      final sub = useCase.execute(1).listen(received.add);

      repo.emitChange(
        1,
        const WidgetChangedEvent(eventType: 'create', data: null, ids: null),
      );
      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      await sub.cancel();
    });

    test('cancel forwards to the repository unsubscribe', () async {
      final repo = FakeMenuSubscriptionRepository();
      final useCase = WatchMenuChangesUseCase(repository: repo);

      await useCase.cancel(1);

      expect(
        repo.calls.whereType<UnsubscribeCall>().map((c) => c.menuId),
        contains(1),
      );
    });
  });
}
