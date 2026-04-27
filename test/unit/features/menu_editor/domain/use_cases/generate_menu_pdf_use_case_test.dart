import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/gateways/auth_gateway.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu.dart';
import 'package:oxo_menus/features/menu/domain/entities/menu_display_options.dart';
import 'package:oxo_menus/features/menu/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/features/menu/domain/usecases/generate_pdf_usecase.dart';
import 'package:oxo_menus/features/menu_editor/domain/use_cases/generate_menu_pdf_use_case.dart';
import 'package:oxo_menus/features/widget_system/domain/entities/widget_type_config.dart';
import 'package:oxo_menus/features/widget_system/domain/widgets/shared/widget_alignment.dart';
import 'package:oxo_menus/shared/domain/entities/status.dart';
import 'package:oxo_menus/shared/domain/entities/user.dart';
import 'package:oxo_menus/shared/domain/repositories/auth_repository.dart';

const _user = User(id: 'u1', email: 'u@example.com', role: UserRole.user);

const _menu = Menu(
  id: 7,
  name: 'My Menu',
  status: Status.published,
  version: '1.0.0',
  displayOptions: MenuDisplayOptions(),
);

const _menuTree = MenuTree(menu: _menu, pages: <PageWithContainers>[]);

final _bytes = Uint8List.fromList(const [1, 2, 3, 4]);

class _FakeFetchMenuTree implements FetchMenuTreeUseCase {
  Result<MenuTree, DomainError> result = const Success(_menuTree);
  final List<int> calls = [];

  @override
  Future<Result<MenuTree, DomainError>> execute(int input) async {
    calls.add(input);
    return result;
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeGeneratePdf implements GeneratePdfUseCase {
  Result<Uint8List, DomainError>? overrideResult;
  final List<MenuTree> calls = [];

  @override
  Future<Result<Uint8List, DomainError>> execute(MenuTree input) async {
    calls.add(input);
    return overrideResult ?? Success(_bytes);
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _StubAuthRepository implements AuthRepository {
  _StubAuthRepository({required this.restoredUser});

  final Result<User, DomainError> restoredUser;

  @override
  Future<Result<User, DomainError>> login(
    String email,
    String password,
  ) async => const Failure(InvalidCredentialsError());

  @override
  Future<Result<void, DomainError>> logout() async => const Success(null);

  @override
  Future<Result<User, DomainError>> getCurrentUser() async => restoredUser;

  @override
  Future<Result<void, DomainError>> refreshSession() async =>
      const Success(null);

  @override
  Future<Result<User, DomainError>> tryRestoreSession() async => restoredUser;

  @override
  Future<Result<void, DomainError>> requestPasswordReset(
    String email, {
    String? resetUrl,
  }) async => const Success(null);

  @override
  Future<Result<void, DomainError>> confirmPasswordReset({
    required String token,
    required String password,
  }) async => const Success(null);
}

Future<AuthGateway> _gatewayFor(User? user) async {
  final repo = _StubAuthRepository(
    restoredUser: user == null
        ? const Failure(UnauthorizedError())
        : Success(user),
  );
  final gateway = AuthGateway(repository: repo);
  if (user != null) {
    await gateway.tryRestoreSession();
  }
  return gateway;
}

void main() {
  group('GenerateMenuPdfInput', () {
    test('value equality compares all fields', () {
      const a = GenerateMenuPdfInput(menuId: 1);
      const b = GenerateMenuPdfInput(menuId: 1);
      const c = GenerateMenuPdfInput(menuId: 2);

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });

    test('different displayOptionsOverride breaks equality', () {
      const a = GenerateMenuPdfInput(menuId: 1);
      const b = GenerateMenuPdfInput(
        menuId: 1,
        displayOptionsOverride: MenuDisplayOptions(showPrices: false),
      );

      expect(a, isNot(b));
    });

    test('different allowedWidgetsOverride breaks equality', () {
      const a = GenerateMenuPdfInput(menuId: 1);
      const b = GenerateMenuPdfInput(
        menuId: 1,
        allowedWidgetsOverride: <WidgetTypeConfig>[
          WidgetTypeConfig(type: 'dish'),
        ],
      );

      expect(a, isNot(b));
    });
  });

  group('GenerateMenuPdfOutput', () {
    test('value equality compares filename and identical bytes', () {
      final bytes = Uint8List.fromList(const [1, 2, 3]);
      final a = GenerateMenuPdfOutput(bytes: bytes, filename: 'm.pdf');
      final b = GenerateMenuPdfOutput(bytes: bytes, filename: 'm.pdf');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('different filename breaks equality', () {
      final bytes = Uint8List.fromList(const [1]);
      final a = GenerateMenuPdfOutput(bytes: bytes, filename: 'a.pdf');
      final b = GenerateMenuPdfOutput(bytes: bytes, filename: 'b.pdf');

      expect(a, isNot(b));
    });
  });

  group('GenerateMenuPdfUseCase — authorisation', () {
    test('returns Unauthorized when no user is signed in', () async {
      final auth = await _gatewayFor(null);
      addTearDown(auth.dispose);
      final fetch = _FakeFetchMenuTree();
      final generate = _FakeGeneratePdf();
      final useCase = GenerateMenuPdfUseCase(
        authGateway: auth,
        fetchMenuTree: fetch,
        generatePdf: generate,
      );

      final result = await useCase.execute(
        const GenerateMenuPdfInput(menuId: 7),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull, isA<UnauthorizedError>());
      expect(fetch.calls, isEmpty);
      expect(generate.calls, isEmpty);
    });

    test('authenticated regular user reaches the repository chain', () async {
      final auth = await _gatewayFor(_user);
      addTearDown(auth.dispose);
      final fetch = _FakeFetchMenuTree();
      final generate = _FakeGeneratePdf();
      final useCase = GenerateMenuPdfUseCase(
        authGateway: auth,
        fetchMenuTree: fetch,
        generatePdf: generate,
      );

      await useCase.execute(const GenerateMenuPdfInput(menuId: 7));

      expect(fetch.calls, [7]);
      expect(generate.calls, hasLength(1));
    });
  });

  group('GenerateMenuPdfUseCase — happy path', () {
    test(
      'returns bytes and filename derived from menu name and options',
      () async {
        final auth = await _gatewayFor(_user);
        addTearDown(auth.dispose);
        final fetch = _FakeFetchMenuTree();
        final generate = _FakeGeneratePdf();
        final useCase = GenerateMenuPdfUseCase(
          authGateway: auth,
          fetchMenuTree: fetch,
          generatePdf: generate,
          now: () => DateTime(2026, 4, 27),
        );

        final result = await useCase.execute(
          const GenerateMenuPdfInput(menuId: 7),
        );

        expect(result.isSuccess, isTrue);
        final output = result.valueOrNull!;
        expect(output.bytes, same(_bytes));
        expect(output.filename, 'My Menu - Allergy (2026-04-27).pdf');
      },
    );

    test(
      'forwards merged menu (with overrides) to GeneratePdfUseCase',
      () async {
        final auth = await _gatewayFor(_user);
        addTearDown(auth.dispose);
        final fetch = _FakeFetchMenuTree();
        final generate = _FakeGeneratePdf();
        final useCase = GenerateMenuPdfUseCase(
          authGateway: auth,
          fetchMenuTree: fetch,
          generatePdf: generate,
        );

        const allowed = <WidgetTypeConfig>[
          WidgetTypeConfig(type: 'dish', alignment: WidgetAlignment.center),
        ];
        const override = MenuDisplayOptions(
          showPrices: false,
          showAllergens: false,
        );
        await useCase.execute(
          const GenerateMenuPdfInput(
            menuId: 7,
            displayOptionsOverride: override,
            allowedWidgetsOverride: allowed,
          ),
        );

        final pushed = generate.calls.single;
        expect(pushed.menu.displayOptions, override);
        expect(pushed.menu.allowedWidgets, allowed);
      },
    );

    test(
      'falls back to stored menu values when no overrides are passed',
      () async {
        final auth = await _gatewayFor(_user);
        addTearDown(auth.dispose);
        final fetch = _FakeFetchMenuTree()
          ..result = const Success(
            MenuTree(
              menu: Menu(
                id: 7,
                name: 'Stored Menu',
                status: Status.published,
                version: '1.0.0',
                displayOptions: MenuDisplayOptions(showPrices: false),
                allowedWidgets: <WidgetTypeConfig>[
                  WidgetTypeConfig(type: 'wine'),
                ],
              ),
              pages: <PageWithContainers>[],
            ),
          );
        final generate = _FakeGeneratePdf();
        final useCase = GenerateMenuPdfUseCase(
          authGateway: auth,
          fetchMenuTree: fetch,
          generatePdf: generate,
        );

        await useCase.execute(const GenerateMenuPdfInput(menuId: 7));

        final pushed = generate.calls.single;
        expect(
          pushed.menu.displayOptions,
          const MenuDisplayOptions(showPrices: false),
        );
        expect(pushed.menu.allowedWidgets, const <WidgetTypeConfig>[
          WidgetTypeConfig(type: 'wine'),
        ]);
      },
    );

    test(
      'treats an empty allowedWidgetsOverride as "use stored value"',
      () async {
        final auth = await _gatewayFor(_user);
        addTearDown(auth.dispose);
        final fetch = _FakeFetchMenuTree()
          ..result = const Success(
            MenuTree(
              menu: Menu(
                id: 7,
                name: 'Stored Menu',
                status: Status.published,
                version: '1.0.0',
                allowedWidgets: <WidgetTypeConfig>[
                  WidgetTypeConfig(type: 'wine'),
                ],
              ),
              pages: <PageWithContainers>[],
            ),
          );
        final generate = _FakeGeneratePdf();
        final useCase = GenerateMenuPdfUseCase(
          authGateway: auth,
          fetchMenuTree: fetch,
          generatePdf: generate,
        );

        await useCase.execute(
          const GenerateMenuPdfInput(
            menuId: 7,
            allowedWidgetsOverride: <WidgetTypeConfig>[],
          ),
        );

        expect(
          generate.calls.single.menu.allowedWidgets,
          const <WidgetTypeConfig>[WidgetTypeConfig(type: 'wine')],
        );
      },
    );
  });

  group('GenerateMenuPdfUseCase — failure paths', () {
    test(
      'propagates fetch-tree failure without calling GeneratePdfUseCase',
      () async {
        final auth = await _gatewayFor(_user);
        addTearDown(auth.dispose);
        final fetch = _FakeFetchMenuTree()
          ..result = const Failure(NetworkError('cannot fetch'));
        final generate = _FakeGeneratePdf();
        final useCase = GenerateMenuPdfUseCase(
          authGateway: auth,
          fetchMenuTree: fetch,
          generatePdf: generate,
        );

        final result = await useCase.execute(
          const GenerateMenuPdfInput(menuId: 7),
        );

        expect(result.isFailure, isTrue);
        expect(result.errorOrNull, isA<NetworkError>());
        expect(generate.calls, isEmpty);
      },
    );

    test('propagates generate-pdf failure', () async {
      final auth = await _gatewayFor(_user);
      addTearDown(auth.dispose);
      final fetch = _FakeFetchMenuTree();
      final generate = _FakeGeneratePdf()
        ..overrideResult = const Failure(UnknownError('pdf engine boom'));
      final useCase = GenerateMenuPdfUseCase(
        authGateway: auth,
        fetchMenuTree: fetch,
        generatePdf: generate,
      );

      final result = await useCase.execute(
        const GenerateMenuPdfInput(menuId: 7),
      );

      expect(result.isFailure, isTrue);
      expect(result.errorOrNull?.message, contains('pdf engine boom'));
    });
  });
}
