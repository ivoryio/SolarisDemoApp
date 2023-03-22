import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:solaris_structure_1/cubits/auth_cubit/auth_cubit.dart';
import 'package:solaris_structure_1/router/routing_constants.dart';
import '../../widgets/screen.dart';

class LoginPasscodeErrorScreen extends StatelessWidget {
  const LoginPasscodeErrorScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var authenticationError =
        context.read<AuthCubit>().state.authenticationError;
    inspect(authenticationError);

    return Screen(
      title: "Login",
      child: Column(
        children: [
          Text(
              "Error: ${authenticationError?.error} for username ${authenticationError?.username}"),
          PlatformTextButton(
            child: const Text("Go to landing page"),
            onPressed: () {
              context.go(landingRoute.path);
              context.read<AuthCubit>().reset();
            },
          )
        ],
      ),
    );
  }
}
