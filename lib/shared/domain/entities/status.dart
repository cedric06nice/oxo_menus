import 'package:freezed_annotation/freezed_annotation.dart';

enum Status {
  @JsonValue('draft')
  draft,
  @JsonValue('published')
  published,
  @JsonValue('archived')
  archived,
}

/// Extension methods for Status enum
extension StatusConverter on Status {
  static Status mapStatusToEnum(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Status.draft;
      case 'published':
        return Status.published;
      case 'archived':
        return Status.archived;
      default:
        return Status.draft; // Default fallback
    }
  }

  static String mapStatusToString(Status status) {
    switch (status) {
      case Status.draft:
        return 'draft';
      case Status.published:
        return 'published';
      case Status.archived:
        return 'archived';
    }
  }
}
