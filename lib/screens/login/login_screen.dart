import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import '../../cubits/auth_cubit/auth_cubit.dart';
import '../../widgets/platform_text_input.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        iosContentPadding: true,
        iosContentBottomPadding: true,
        appBar: PlatformAppBar(
          title: const Text('Login'),
        ),
        body: const LoginOptions());
  }
}

class LoginOptions extends StatefulWidget {
  const LoginOptions({super.key});

  @override
  State<LoginOptions> createState() => _LoginOptionsState();
}

class _LoginOptionsState extends State<LoginOptions> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page = _selectedIndex == 0
        ? const PhoneNumberLoginForm()
        : const EmailLoginForm();

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
      child: Column(
        children: [
          Container(
            height: 40,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(9.0)),
                border: Border.all(width: 1)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExpandedButton(
                  active: _selectedIndex == 0,
                  text: "Phone Number",
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                ),
                ExpandedButton(
                  active: _selectedIndex == 1,
                  text: "Phone Number",
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: page,
          ),
        ],
      ),
    );
  }
}

class ExpandedButton extends StatelessWidget {
  final String text;
  final bool active;
  final Function onPressed;

  const ExpandedButton(
      {super.key,
      required this.onPressed,
      required this.text,
      required this.active});

  @override
  Widget build(BuildContext context) {
    final Color textColor = active ? Colors.white : Colors.black;
    final Color backgroundColor = active ? Colors.black : Colors.white;

    return Expanded(
      child: PlatformElevatedButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: backgroundColor,
          child: Text(text,
              softWrap: false,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              )),
          cupertino: (context, platform) => CupertinoElevatedButtonData(
              pressedOpacity: 0.75,
              borderRadius: const BorderRadius.all(Radius.circular(7))),
          onPressed: () => onPressed()),
    );
  }
}

class PhoneNumberLoginForm extends StatefulWidget {
  const PhoneNumberLoginForm({super.key});

  @override
  State<PhoneNumberLoginForm> createState() => _PhoneNumberLoginFormState();
}

class _PhoneNumberLoginFormState extends State<PhoneNumberLoginForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    TextEditingController phoneController = TextEditingController();

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          PlatformTextInput(controller: phoneController),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Forgot your phone number?"),
              SizedBox(
                width: double.infinity,
                child: PlatformElevatedButton(
                  color: Colors.black,
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      String phoneNumber = phoneController.text;

                      log("Phone number: $phoneNumber");

                      context.read<AuthCubit>().login(phoneNumber);
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({super.key});

  @override
  State<EmailLoginForm> createState() => _EmailLoginFormState();
}

class _EmailLoginFormState extends State<EmailLoginForm> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
