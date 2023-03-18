import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'router/router.dart';
import 'services/auth_service.dart';
import 'cubits/auth_cubit/auth_cubit.dart';
import 'themes/default_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => AuthCubit(
        authService: AuthService(context: context),
      ),
      child: Theme(
        data: defaultMaterialTheme,
        child: PlatformProvider(
          builder: (context) => PlatformApp.router(
            routerConfig: AppRouter(context.read<AuthCubit>()).router,
            material: (context, platform) => MaterialAppRouterData(
              theme: defaultMaterialTheme,
            ),
            cupertino: (context, platform) => CupertinoAppRouterData(
              theme: cupertinoTheme,
            ),
            localizationsDelegates: const [
              DefaultMaterialLocalizations.delegate,
              DefaultWidgetsLocalizations.delegate,
              DefaultCupertinoLocalizations.delegate,
            ],
          ),
        ),
      ),
    );
  }
}
