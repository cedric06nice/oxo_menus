import 'dart:typed_data';

/// Immutable state of the migrated PDF-preview screen.
///
/// One of three high-level shapes:
/// - **Loading**: `isLoading == true`, all payload fields null.
/// - **Failure**: `isLoading == false`, `errorMessage != null`, payload null.
/// - **Success**: `isLoading == false`, `errorMessage == null`, both
///   `pdfBytes` and `filename` non-null.
final class PdfPreviewScreenState {
  const PdfPreviewScreenState({
    this.isLoading = true,
    this.errorMessage,
    this.pdfBytes,
    this.filename,
  });

  /// True while the underlying use case is in flight (initial load or retry).
  final bool isLoading;

  /// Last error message surfaced by the use case; `null` when the most recent
  /// run succeeded or when no run has finished yet.
  final String? errorMessage;

  /// Generated PDF bytes; `null` while loading or on failure.
  final Uint8List? pdfBytes;

  /// Suggested download filename; `null` while loading or on failure.
  final String? filename;

  PdfPreviewScreenState copyWith({
    bool? isLoading,
    Object? errorMessage = _sentinel,
    Object? pdfBytes = _sentinel,
    Object? filename = _sentinel,
  }) {
    return PdfPreviewScreenState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      pdfBytes: identical(pdfBytes, _sentinel)
          ? this.pdfBytes
          : pdfBytes as Uint8List?,
      filename: identical(filename, _sentinel)
          ? this.filename
          : filename as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) =>
      other is PdfPreviewScreenState &&
      other.isLoading == isLoading &&
      other.errorMessage == errorMessage &&
      identical(other.pdfBytes, pdfBytes) &&
      other.filename == filename;

  @override
  int get hashCode => Object.hash(
    isLoading,
    errorMessage,
    identityHashCode(pdfBytes),
    filename,
  );
}
