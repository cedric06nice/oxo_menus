import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/menu_presence_use_case.dart';

import '../../../../../fakes/fake_presence_repository.dart';

void main() {
  group('MenuPresenceUseCase', () {
    test('join forwards every parameter to the repository', () async {
      final repo = FakePresenceRepository()..whenJoinMenu(const Success(null));
      final useCase = MenuPresenceUseCase(repository: repo);

      await useCase.join(1, 'u-1', userName: 'Alice', userAvatar: 'a.png');

      expect(repo.joinMenuCalls.single.menuId, 1);
      expect(repo.joinMenuCalls.single.userId, 'u-1');
      expect(repo.joinMenuCalls.single.userName, 'Alice');
      expect(repo.joinMenuCalls.single.userAvatar, 'a.png');
    });

    test(
      'leave / heartbeat / getActive / cancel each forward to the repo',
      () async {
        final repo = FakePresenceRepository()
          ..whenLeaveMenu(const Success(null))
          ..whenHeartbeat(const Success(null))
          ..whenGetActiveUsers(1, const Success([]));
        final useCase = MenuPresenceUseCase(repository: repo);

        await useCase.leave(1, 'u-1');
        await useCase.heartbeat(1, 'u-1');
        await useCase.getActive(1);
        await useCase.cancel(1);

        expect(repo.leaveMenuCalls.single.userId, 'u-1');
        expect(repo.heartbeatCalls.single.userId, 'u-1');
        expect(repo.getActiveUsersCalls.single.menuId, 1);
        expect(repo.unsubscribePresenceCalls.map((c) => c.menuId), contains(1));
      },
    );

    test('watch returns the repository stream', () {
      final repo = FakePresenceRepository();
      final useCase = MenuPresenceUseCase(repository: repo);

      final stream = useCase.watch(1);

      expect(stream, isA<Stream<dynamic>>());
    });
  });
}
