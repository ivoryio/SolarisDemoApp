import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solarisdemo/cubits/auth_cubit/auth_cubit.dart';
// ignore: library_prefixes
import 'package:solarisdemo/router/routing_constants.dart';
import 'package:solarisdemo/screens/home/home_screen.dart';
import 'package:solarisdemo/screens/landing/landing_screen.dart';
import 'package:solarisdemo/screens/login/login_consent_screen.dart';
import 'package:solarisdemo/screens/login/login_screen.dart';
import 'package:solarisdemo/screens/login/login_tan_screen.dart';
import 'package:solarisdemo/services/auth_service.dart';
import 'package:solarisdemo/widgets/button.dart';
import 'package:solarisdemo/widgets/platform_text_input.dart';
import 'package:solarisdemo/widgets/screen.dart';
import 'package:solarisdemo/widgets/tab_view.dart';
import 'package:solarisdemo/widgets/tan_input.dart';
// package:flutter_tools/src/test/integration_test_device.dart

void main() {
  group("Login flow test", () {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    testWidgets(
        'Should tap login button from the landing screen, and redirect the user to the login screen',
        (WidgetTester tester) async {
      //Arrange
      final authCubit = AuthCubit(authService: AuthService());

      final goRouter = GoRouter(
        routes: [
          GoRoute(
            path: landingRoute.path,
            name: landingRoute.name,
            pageBuilder: (context, state) => MaterialPage<void>(
              child: BlocProvider.value(
                value: authCubit,
                child: const LandingScreen(),
              ),
            ),
          ),
          GoRoute(
            path: loginRoute.path,
            name: loginRoute.name,
            pageBuilder: (context, state) => MaterialPage<void>(
              child: BlocProvider.value(
                value: authCubit,
                child: const LoginScreen(),
              ),
            ),
          ),
        ],
        initialLocation: landingRoute.path,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
          routeInformationProvider: goRouter.routeInformationProvider,
        ),
      );

      Finder loginButton = find.text('Login');
      await tester.tap(loginButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // print('aici e printul $loginButton');

      // Check if the current page is the login page
      expect(goRouter.location, equals(loginRoute.path));
    });

    testWidgets(
        'Should redirect the user to the GDPR screen when email&password are valid',
        (WidgetTester tester) async {
      //Arrange
      final authCubit = AuthCubit(authService: AuthService());

      final goRouter = GoRouter(
        routes: [
          GoRoute(
            path: loginRoute.path,
            name: loginRoute.name,
            pageBuilder: (context, state) => MaterialPage<void>(
              child: BlocProvider.value(
                value: authCubit,
                child: const LoginScreen(),
              ),
            ),
          ),
          GoRoute(
            path: loginPasscodeRoute.path,
            name: loginPasscodeRoute.name,
            pageBuilder: (context, state) => MaterialPage<void>(
              child: BlocProvider.value(
                value: authCubit,
                child: const LoginTanScreen(),
              ),
            ),
          ),
        ],
        initialLocation: loginRoute.path,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerDelegate: goRouter.routerDelegate,
          routeInformationParser: goRouter.routeInformationParser,
          routeInformationProvider: goRouter.routeInformationProvider,
        ),
      );

      Finder emailButton = find.widgetWithText(PlatformElevatedButton, "Email");
      await tester.tap(emailButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      Finder emailTextInput =
          find.widgetWithText(PlatformTextInput, "Email Address");
      Finder passwordTextInput =
          find.widgetWithText(PlatformTextInput, "Password");
      await tester.enterText(emailTextInput, "anca.nechita@thinslices.com");
      await tester.enterText(passwordTextInput, "123456");

      Finder loginButton = find.widgetWithText(PrimaryButton, "Continue");
      await tester.tap(loginButton);
      await tester.pumpAndSettle();

      expect('/login/:username', contains('/login/'));
      //expect(goRouter.location, equals(loginPasscodeRoute.path));

     

    testWidgets('Should redirect the user to the GdprConsentScreen',
        (WidgetTester tester) async {
    //   final authCubit = AuthCubit(authService: AuthService());
    //   final goRouter = GoRouter(
    //     routes: [
    //       GoRoute(
    //         path: loginPasscodeRoute.path,
    //         name: loginPasscodeRoute.name,
    //         pageBuilder: (context, state) => MaterialPage<void>(
    //           child: BlocProvider.value(
    //             value: authCubit,
    //             child: const GdprConsentScreen(),
    //           ),
    //         ),
    //       ),
    //       GoRoute(
    //         path: GdprConsentScreen.path,
    //         name: GdprConsentScreen.name,
    //         pageBuilder: (context, state) => MaterialPage<void>(
    //           child: BlocProvider.value(
    //             value: authCubit,
    //             child: const GdprConsentScreen(),
    //           ),
    //         ),
    //       ),
    //     ],
    //     initialLocation: loginPasscodeRoute.path,
    //   );

    //   await tester.pumpWidget(
    //     MaterialApp.router(
    //       routerDelegate: goRouter.routerDelegate,
    //       routeInformationParser: goRouter.routeInformationParser,
    //       routeInformationProvider: goRouter.routeInformationProvider,
    //     ),
    //   );

    Finder consentButton =
          find.widgetWithText(GdprConsentScreen, "Welcome to SolarisDemo!");
      await tester.tap(consentButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));
    });

      Finder passcodeInput = find.widgetWithText(LoginTanScreen,
          "Please enter your 4-digit PIN to login. (PIN: 1234)");
      await tester.enterText(passcodeInput.first, "1");
      await tester.enterText(passcodeInput.at(1), "2");
      await tester.enterText(passcodeInput.at(2), "3");
      await tester.enterText(passcodeInput.at(3), "4");
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // expect(goRouter.location, equals(loginPasscodeRoute.path));
     });
  });
}
