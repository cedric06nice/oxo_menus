import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/architecture/use_case.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/home/domain/entities/home_overview.dart';
import 'package:oxo_menus/features/home/domain/use_cases/get_home_overview_use_case.dart';
import 'package:oxo_menus/features/home/presentation/routing/home_router.dart';
import 'package:oxo_menus/features/home/presentation/state/home_state.dart';
import 'package:oxo_menus/features/home/presentation/view_models/home_view_model.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';

class _FakeGetHomeOverviewUseCase implements GetHomeOverviewUseCase {
  _FakeGetHomeOverviewUseCase(this._overview);

  HomeOverview _overview;
  int calls = 0;

  set overview(HomeOverview next) => _overview = next;

  @override
  Result<HomeOverview, DomainError> execute(NoInput input) {
    calls++;
    return Success(_overview);
  }
}

class _RecordingHomeRouter implements HomeRouter {
  int menusCalls = 0;
  int settingsCalls = 0;
  int adminTemplatesCalls = 0;
  int adminTemplateCreateCalls = 0;
  int adminExportableMenusCalls = 0;

  @override
  void goToMenus() => menusCalls++;

  @override
  void goToSettings() => settingsCalls++;

  @override
  void goToAdminTemplates() => adminTemplatesCalls++;

  @override
  void goToAdminTemplateCreate() => adminTemplateCreateCalls++;

  @override
  void goToAdminExportableMenus() => adminExportableMenusCalls++;
}

const _alice = User(
  id: 'u-1',
  email: 'alice@example.com',
  firstName: 'Alice',
  role: UserRole.user,
);
const _admin = User(
  id: 'u-2',
  email: 'adam@example.com',
  firstName: 'Adam',
  role: UserRole.admin,
);
const _emailOnly = User(
  id: 'u-3',
  email: 'lone.wolf@example.com',
  role: UserRole.user,
);

DateTime Function() _fixedClock(DateTime moment) =>
    () => moment;

HomeViewModel _buildViewModel({
  HomeOverview overview = const HomeOverview(user: _alice, isAdmin: false),
  _RecordingHomeRouter? router,
  DateTime? now,
}) {
  return HomeViewModel(
    getHomeOverview: _FakeGetHomeOverviewUseCase(overview),
    router: router ?? _RecordingHomeRouter(),
    clock: _fixedClock(now ?? DateTime(2026, 4, 27, 9)),
  );
}

void main() {
  group('HomeState', () {
    test('default state has no user, isAdmin=false, empty greeting', () {
      const state = HomeState();

      expect(state.user, isNull);
      expect(state.isAdmin, isFalse);
      expect(state.greeting, '');
    });

    test('value equality compares user, isAdmin, greeting', () {
      const a = HomeState(user: _alice, isAdmin: false, greeting: 'Hi');
      const b = HomeState(user: _alice, isAdmin: false, greeting: 'Hi');
      const c = HomeState(user: _alice, isAdmin: true, greeting: 'Hi');
      const d = HomeState(user: _alice, isAdmin: false, greeting: 'Bye');
      const e = HomeState(user: _admin, isAdmin: false, greeting: 'Hi');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
      expect(a, isNot(d));
      expect(a, isNot(e));
    });

    test('copyWith leaves untouched fields equal to the source', () {
      const source = HomeState(user: _alice, isAdmin: false, greeting: 'Hello');

      final clone = source.copyWith();

      expect(clone, source);
    });

    test('copyWith can null-out the user', () {
      const source = HomeState(user: _alice, greeting: 'Hi');

      final cleared = source.copyWith(user: null);

      expect(cleared.user, isNull);
      expect(cleared.greeting, 'Hi');
    });

    test('copyWith updates isAdmin and greeting independently', () {
      const source = HomeState();

      final next = source.copyWith(isAdmin: true, greeting: 'Yo');

      expect(next.isAdmin, isTrue);
      expect(next.greeting, 'Yo');
      expect(next.user, isNull);
    });
  });

  group('HomeViewModel — initial state', () {
    test('eagerly loads the overview from the use case', () {
      final useCase = _FakeGetHomeOverviewUseCase(
        const HomeOverview(user: _alice, isAdmin: false),
      );
      final vm = HomeViewModel(
        getHomeOverview: useCase,
        router: _RecordingHomeRouter(),
        clock: _fixedClock(DateTime(2026, 4, 27, 9)),
      );
      addTearDown(vm.dispose);

      expect(useCase.calls, 1);
      expect(vm.state.user, _alice);
      expect(vm.state.isAdmin, isFalse);
    });

    test('greeting uses firstName when present', () {
      final vm = _buildViewModel(
        overview: const HomeOverview(user: _alice, isAdmin: false),
        now: DateTime(2026, 4, 27, 9),
      );
      addTearDown(vm.dispose);

      expect(vm.state.greeting, 'Good morning, Alice!');
    });

    test('greeting falls back to the local-part of the email when firstName is '
        'missing', () {
      final vm = _buildViewModel(
        overview: const HomeOverview(user: _emailOnly, isAdmin: false),
        now: DateTime(2026, 4, 27, 14),
      );
      addTearDown(vm.dispose);

      expect(vm.state.greeting, 'Good afternoon, lone.wolf!');
    });

    test('greeting falls back to "User" when there is no signed-in user', () {
      final vm = _buildViewModel(
        overview: const HomeOverview(user: null, isAdmin: false),
        now: DateTime(2026, 4, 27, 20),
      );
      addTearDown(vm.dispose);

      expect(vm.state.greeting, 'Good evening, User!');
      expect(vm.state.user, isNull);
    });

    test('mirrors isAdmin from the overview for admin users', () {
      final vm = _buildViewModel(
        overview: const HomeOverview(user: _admin, isAdmin: true),
      );
      addTearDown(vm.dispose);

      expect(vm.state.isAdmin, isTrue);
      expect(vm.state.user, _admin);
    });

    test('greeting respects the injected clock at each construction hour', () {
      final morning = _buildViewModel(now: DateTime(2026, 4, 27, 5));
      addTearDown(morning.dispose);
      final afternoon = _buildViewModel(now: DateTime(2026, 4, 27, 12));
      addTearDown(afternoon.dispose);
      final evening = _buildViewModel(now: DateTime(2026, 4, 27, 17));
      addTearDown(evening.dispose);

      expect(morning.state.greeting, 'Good morning, Alice!');
      expect(afternoon.state.greeting, 'Good afternoon, Alice!');
      expect(evening.state.greeting, 'Good evening, Alice!');
    });
  });

  group('HomeViewModel — navigation', () {
    test('goToMenus delegates to the router', () {
      final router = _RecordingHomeRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToMenus();

      expect(router.menusCalls, 1);
    });

    test('goToSettings delegates to the router', () {
      final router = _RecordingHomeRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToSettings();

      expect(router.settingsCalls, 1);
    });

    test('goToAdminTemplates delegates to the router', () {
      final router = _RecordingHomeRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToAdminTemplates();

      expect(router.adminTemplatesCalls, 1);
    });

    test('goToAdminTemplateCreate delegates to the router', () {
      final router = _RecordingHomeRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToAdminTemplateCreate();

      expect(router.adminTemplateCreateCalls, 1);
    });

    test('goToAdminExportableMenus delegates to the router', () {
      final router = _RecordingHomeRouter();
      final vm = _buildViewModel(router: router);
      addTearDown(vm.dispose);

      vm.goToAdminExportableMenus();

      expect(router.adminExportableMenusCalls, 1);
    });
  });

  group('HomeViewModel — disposal', () {
    test('dispose marks the VM as disposed', () {
      final vm = _buildViewModel();

      vm.dispose();

      expect(vm.isDisposed, isTrue);
    });
  });
}
