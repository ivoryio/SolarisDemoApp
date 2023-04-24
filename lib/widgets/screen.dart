import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:go_router/go_router.dart';

import '../router/router.dart';
import '../themes/default_theme.dart';

class Screen extends StatelessWidget {
  final Widget child;
  final String title;
  final bool hideAppBar;
  final bool? centerTitle;
  final Color? appBarColor;
  final bool? hideBackButton;
  final Icon? backButtonIcon;
  final bool hideBottomNavbar;
  final TextStyle? titleTextStyle;
  final List<Widget>? trailingActions;
  final Function? customBackButtonCallback;
  final BottomStickyWidget? bottomStickyWidget;

  const Screen({
    super.key,
    this.appBarColor,
    this.backButtonIcon,
    required this.child,
    required this.title,
    this.titleTextStyle,
    this.trailingActions,
    this.hideAppBar = false,
    this.centerTitle = true,
    this.bottomStickyWidget,
    this.hideBackButton = false,
    this.hideBottomNavbar = false,
    this.customBackButtonCallback,
  });

  @override
  Widget build(BuildContext context) {
    PlatformAppBar? appBar = hideAppBar == true
        ? null
        : createAppBar(
            context,
            title: title,
            centerTitle: centerTitle,
            backgroundColor: appBarColor,
            hideBackButton: hideBackButton,
            titleTextStyle: titleTextStyle,
            backButtonIcon: backButtonIcon,
            trailingActions: trailingActions,
            customBackButtonCallback: customBackButtonCallback,
          );

    int currentPageIndex = AppRouter.calculateSelectedIndex(context);

    PlatformTabController tabController = PlatformTabController(
      initialIndex: currentPageIndex,
    );

    if (hideBottomNavbar) {
      return PlatformScaffold(
        appBar: appBar,
        iosContentPadding: true,
        iosContentBottomPadding: true,
        body: LayoutBuilder(builder:
            (BuildContext context, BoxConstraints viewportConstraints) {
          num bottomStickyWidgetHeight = bottomStickyWidget?.height ?? 0;

          Widget screenContent = SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    viewportConstraints.maxHeight - bottomStickyWidgetHeight,
              ),
              child: IntrinsicHeight(
                child: child,
              ),
            ),
          );

          return Column(children: [
            Expanded(child: screenContent),
            if (bottomStickyWidget != null) bottomStickyWidget!.build(context)
          ]);
        }),
      );
    }

    return PlatformTabScaffold(
      iosContentPadding: true,
      tabController: tabController,
      iosContentBottomPadding: true,
      appBarBuilder: (context, index) => appBar,
      itemChanged: (pageIndex) {
        if (currentPageIndex != pageIndex) {
          AppRouter.navigateToPage(pageIndex, context);
        }
      },
      materialTabs: (context, platform) => MaterialNavBarData(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      cupertinoTabs: (context, platform) => CupertinoTabBarData(
        backgroundColor: Colors.white,
        activeColor: Colors.black,
        inactiveColor: Colors.grey,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_card),
          label: 'Wallet',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.payments),
          label: 'Transactions',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      bodyBuilder: (context, index) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: viewportConstraints.maxHeight,
            ),
            child: child,
          ),
        );
      }),
    );
  }
}

class LoadingScreen extends StatelessWidget {
  final String? title;
  const LoadingScreen({super.key, this.title = "Loading"});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: createAppBar(context, title: title!),
      iosContentBottomPadding: true,
      body: Center(
        child: PlatformCircularProgressIndicator(),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String? title;
  final String? message;
  const ErrorScreen(
      {super.key,
      this.title = "Error",
      this.message = "An unexpected error has occured"});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: createAppBar(context, title: title!),
      iosContentBottomPadding: true,
      body: Text(message!),
    );
  }
}

PlatformAppBar createAppBar(
  BuildContext context, {
  bool? hideBackButton,
  Icon? backButtonIcon,
  required String title,
  bool? centerTitle = true,
  TextStyle? titleTextStyle,
  List<Widget>? trailingActions,
  Function? customBackButtonCallback,
  Color? backgroundColor = Colors.white,
}) {
  Text titleText = Text(
    title,
    style: titleTextStyle,
  );

  Icon defaultBackButtonIcon = const Icon(
    Icons.arrow_back_ios,
    color: Colors.black,
  );

  Widget leftAlignedTitle = Container(
    width: double.infinity,
    padding: const EdgeInsets.only(left: 16),
    child: titleText,
  );

  PlatformIconButton backButton = PlatformIconButton(
    padding: EdgeInsets.zero,
    icon: backButtonIcon ?? defaultBackButtonIcon,
    material: (context, platform) => MaterialIconButtonData(
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: defaultScreenHorizontalPadding),
    ),
    cupertino: (context, platform) => CupertinoIconButtonData(
      alignment: Alignment.centerLeft,
    ),
    onPressed: () {
      if (customBackButtonCallback != null) {
        customBackButtonCallback();
      } else {
        context.pop(context);
      }
    },
  );

  return PlatformAppBar(
    leading: hideBackButton == true ? null : backButton,
    title: centerTitle == true ? titleText : leftAlignedTitle,
    backgroundColor: backgroundColor,
    trailingActions: trailingActions,
    material: (context, platform) =>
        MaterialAppBarData(elevation: 0, centerTitle: centerTitle, actions: [
      if (trailingActions != null) ...trailingActions,
      const SizedBox(
        width: defaultScreenHorizontalPadding,
      )
    ]),
    cupertino: (context, platform) => CupertinoNavigationBarData(
      border: Border.all(color: Colors.transparent),
      padding: const EdgeInsetsDirectional.symmetric(
        horizontal: defaultScreenHorizontalPadding,
      ),
    ),
    automaticallyImplyLeading: hideBackButton == true ? false : true,
  );
}

class BottomStickyWidget extends StatelessWidget {
  final Widget child;
  final num height;

  const BottomStickyWidget({
    super.key,
    this.height = 100,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height.toDouble(),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, -4),
            color: Colors.black.withOpacity(0.25),
          ),
        ],
      ),
      child: Container(
        alignment: Alignment.topLeft,
        child: child,
      ),
    );
  }
}
