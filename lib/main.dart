// FILE: lib/main.dart
//
// PURPOSE:
//   This is the entry point of the entire Flutter application.
//   It is responsible for:
//     1. Ensuring Flutter bindings are initialized before anything else runs
//     2. Initializing Dependency Injection (DI) — all services, repos, and
//        viewmodels are registered here via di/injection.dart
//     3. Calling runApp() with the root App widget
//
// WHAT SHOULD GO HERE:
//   - Flutter binding initialization
//   - DI/service locator setup
//   - runApp() call
//
// WHAT SHOULD NOT GO HERE:
//   - Any UI code (that belongs in app.dart or views/)
//   - Any business logic
//   - Any hardcoded strings or constants

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'di/injection.dart';

void main() async {
  // Ensure Flutter engine bindings are ready before running async setup
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait (campus security apps work best in portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system overlay style (status bar appearance)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize all dependencies (services, repositories, viewmodels)
  // This must happen before runApp() so that everything is available
  // when the first widget tree builds
  await initializeDependencies();

  // Launch the application
  runApp(const SGuardApp());
}
