// FILE: lib/app.dart
//
// PURPOSE:
//   This is the root widget of the SGuard application.
//   It is responsible for:
//     1. Wrapping the entire app in MultiProvider (state management)
//     2. Setting the MaterialApp theme
//     3. Connecting the router (go_router) to the MaterialApp
//
// WHAT SHOULD GO HERE:
//   - MultiProvider setup (all top-level ViewModels/ChangeNotifiers)
//   - MaterialApp configuration (theme, locale, etc.)
//   - Router attachment
//
// WHAT SHOULD NOT GO HERE:
//   - Business logic
//   - Navigation logic (that lives in routes/app_router.dart)
//   - UI screens (those are in views/)
//
// DATA FLOW:
//   main.dart → app.dart → router → views
//   The providers here are available to the ENTIRE app.
//   ViewModels specific to a screen are provided closer to that screen.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_theme.dart';
import 'di/injection.dart';
import 'routes/app_router.dart';
import 'viewmodels/auth/auth_viewmodel.dart';

class SGuardApp extends StatelessWidget {
  const SGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // AuthViewModel is app-wide because authentication state must be
        // accessible from anywhere (guards, profile, logout buttons, etc.)
        // It's provided at the top level so the router can reactively redirect
        // based on login/logout events.
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => getIt<AuthViewModel>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          // Router is built inside Builder so it can access the AuthViewModel
          // from context. The router uses AuthViewModel to decide which route
          // to show on startup (role selection vs. dashboard).
          final router = AppRouter.createRouter(context);

          return MaterialApp.router(
            title: 'SGuard',
            debugShowCheckedModeBanner: false,

            // Theme configuration lives in core/constants/app_theme.dart
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,

            // Router configuration from routes/app_router.dart
            routerConfig: router,
          );
        },
      ),
    );
  }
}
