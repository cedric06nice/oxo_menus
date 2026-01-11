// Reflectable entry point for directus_api_manager
// This file ensures that reflectable code generation includes directus annotations

import 'package:directus_api_manager/directus_api_manager.dart';

// This const ensures the DirectusCollection reflector is included in code generation
const directusReflector = DirectusCollection();
