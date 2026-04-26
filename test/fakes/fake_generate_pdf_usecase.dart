import 'dart:typed_data';

import 'package:oxo_menus/core/errors/domain_errors.dart';
import 'package:oxo_menus/core/types/result.dart';
import 'package:oxo_menus/domain/repositories/asset_loader_repository.dart';
import 'package:oxo_menus/domain/usecases/fetch_menu_tree_usecase.dart';
import 'package:oxo_menus/domain/usecases/generate_pdf_usecase.dart';

// ---------------------------------------------------------------------------
// Call-record type
// ---------------------------------------------------------------------------

/// Records a single [FakeGeneratePdfUseCase.execute] call.
final class GeneratePdfCall {
  final MenuTree menuTree;
  const GeneratePdfCall({required this.menuTree});
}

// ---------------------------------------------------------------------------
// FakeGeneratePdfUseCase
// ---------------------------------------------------------------------------

/// A manual fake that extends [GeneratePdfUseCase] and intercepts [execute].
///
/// The real constructor requires an [AssetLoaderRepository].  This fake
/// satisfies it with a private no-op stub and disables the isolate path
/// (useIsolate: false) so the super class does not attempt isolate spawning.
///
/// Usage:
/// ```dart
/// final fake = FakeGeneratePdfUseCase();
/// fake.stubExecute(Success(Uint8List(0)));
/// final result = await fake.execute(menuTree);
/// expect(fake.calls.single.menuTree, same(menuTree));
/// ```
class FakeGeneratePdfUseCase extends GeneratePdfUseCase {
  FakeGeneratePdfUseCase()
    : super(assetLoader: _ThrowAssetLoaderRepository(), useIsolate: false);

  // -------------------------------------------------------------------------
  // Call log
  // -------------------------------------------------------------------------

  final List<GeneratePdfCall> calls = [];

  // -------------------------------------------------------------------------
  // Response stub
  // -------------------------------------------------------------------------

  Result<Uint8List, DomainError>? _stubResult;

  /// Configures the next (and all subsequent) [execute] calls to return [result].
  void stubExecute(Result<Uint8List, DomainError> result) {
    _stubResult = result;
  }

  // -------------------------------------------------------------------------
  // Override
  // -------------------------------------------------------------------------

  @override
  Future<Result<Uint8List, DomainError>> execute(MenuTree menuTree) async {
    calls.add(GeneratePdfCall(menuTree: menuTree));
    if (_stubResult != null) {
      return _stubResult!;
    }
    throw StateError(
      'FakeGeneratePdfUseCase: no stub configured — call stubExecute() first',
    );
  }
}

// ---------------------------------------------------------------------------
// Private stub (satisfies super constructor; never actually called)
// ---------------------------------------------------------------------------

class _ThrowAssetLoaderRepository implements AssetLoaderRepository {
  @override
  Future<ByteData> loadAsset(String assetPath) =>
      throw StateError('_ThrowAssetLoaderRepository should not be called');
}
