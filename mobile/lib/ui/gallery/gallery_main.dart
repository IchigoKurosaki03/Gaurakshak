import 'package:flutter/material.dart';

import 'component_gallery.dart';
import '../ui.dart';

/// Dev-only entry point for reviewing the design system in isolation.
///
/// Run with:
///   flutter run -t lib/ui/gallery/gallery_main.dart -d chrome
///
/// This is a Phase 0 review harness — it is never referenced by the shipping
/// app (see lib/main.dart), so it adds no weight to a normal build.
void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GauRakshak — Component Gallery',
      theme: appTheme(),
      home: const ComponentGallery(),
    ),
  );
}
