import 'package:flutter/material.dart';
import 'package:solarisdemo/screens/settings/settings_security_screen.dart';
import 'package:solarisdemo/widgets/app_toolbar.dart';
import 'package:solarisdemo/widgets/ivory_list_item_with_action.dart';
import 'package:solarisdemo/widgets/screen_scaffold.dart';

import '../../config.dart';

class SettingsScreen extends StatelessWidget {
  static const routeName = "/settingsScreen";

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppToolbar(
          padding: ClientConfig.getCustomClientUiSettings().defaultScreenHorizontalPadding,
        ),
        Expanded(
          child: Padding(
              padding: ClientConfig.getCustomClientUiSettings().defaultScreenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: ClientConfig.getTextStyleScheme().heading1,
                  ),
                  const SizedBox(
                    height: 24,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.person_outline,
                    actionName: 'Account',
                    actionDescription: 'Personal info & account settings',
                    rightIcon: Icons.arrow_forward_ios,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.settings_outlined,
                    actionName: 'App settings',
                    actionDescription: 'Language, FaceID, notifications, etc.',
                    rightIcon: Icons.arrow_forward_ios,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.security,
                    actionName: 'Security',
                    actionDescription: 'Password & device pairing',
                    rightIcon: Icons.arrow_forward_ios,
                    onPressed: () => Navigator.of(context).pushNamed(SettingsSecurityScreen.routeName),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.help_outline,
                    actionName: 'Help',
                    actionDescription: 'Contact us',
                    rightIcon: Icons.arrow_forward_ios,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.article_outlined,
                    actionName: 'FAQ & legal documents',
                    actionDescription: 'FAQ, T&Cs, privacy policy',
                    rightIcon: Icons.arrow_forward_ios,
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  IvoryListItemWithAction(
                    leftIcon: Icons.logout,
                    actionName: 'Log out',
                    rightIcon: Icons.arrow_forward_ios,
                  ),
                  const Spacer(),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('App version 1.0'),
                    ],
                  )
                ],
              )),
        ),
      ],
    ));
  }
}
