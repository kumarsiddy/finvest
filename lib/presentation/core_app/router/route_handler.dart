import 'dart:async';

import 'package:finvest/presentation/core_app/home_page/home_page_screen.dart';
import 'package:finvest/presentation/screen/credit_card_page/credit_card_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

abstract class RouteHandler {
  RouteHandler._();

  static Future<T?> navigateTo<T>(
    BuildContext context, {
    required RouteId routeId,
    Map<String, Object?>? args,
  }) {
    return Navigator.pushNamed<T?>(
      context,
      routeId.name,
      arguments: args,
    );
  }

  static Future<T?> replaceWith<T>(
    BuildContext context, {
    required RouteId routeId,
    Map<String, Object?>? args,
  }) async {
    return Navigator.pushReplacementNamed(
      context,
      routeId.name,
      result: args,
      arguments: args,
    );
  }

  ///This will remove all the previous screens
  static Future<void> navigateToOnly(
    BuildContext context, {
    required RouteId routeId,
    Map<String, dynamic>? args,
  }) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeId.name,
      (Route<dynamic> route) => false,
      arguments: args,
    );
  }

  static void pop(
    BuildContext context, {
    Map<String, dynamic>? args,
  }) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context, args);
    } else {
      SystemNavigator.pop();
    }
  }

  static void popUntil(
    BuildContext context, {
    required RouteId routeId,
  }) {
    Navigator.popUntil(context, ModalRoute.withName(routeId.name));
  }

  static Route<Map> generateRoute(RouteSettings routeSettings) {
    final routeID = _parseRouteFrom(routeSettings.name) ?? RouteId.noRoute;
    switch (routeID) {
      case RouteId.homePage:
        return MaterialPageRoute(
          builder: (_) => HomePageScreen(),
        );
      case RouteId.creditCardPage:
        return MaterialPageRoute(
          builder: (_) => CreditCardPageScreen(),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }

  static Route<Map> _buildRoute(
    RouteSettings settings,
    Widget screen, {
    bool noAnimation = false,
  }) {
    if (noAnimation) {
      return _NoAnimationMaterialPageRoute(
        settings: settings,
        builder: (_) => screen,
      );
    }
    return MaterialPageRoute<Map>(
      settings: settings,
      builder: (_) => screen,
    );
  }

  static RouteId? _parseRouteFrom(
    String? routeString,
  ) {
    if (routeString == null) return null;

    return RouteId.values.firstWhere((RouteId e) => e.name == routeString);
  }
}

enum RouteId {
  homePage,
  creditCardPage,
  noRoute,
}

class _NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  _NoAnimationMaterialPageRoute({
    required WidgetBuilder builder,
    RouteSettings? settings,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) : super(
          builder: builder,
          maintainState: maintainState,
          settings: settings,
          fullscreenDialog: fullscreenDialog,
        );

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

Map<String, dynamic>? getArgsFromContext(
  BuildContext context,
) {
  return ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
}

bool isCurrentScreen(BuildContext context) =>
    ModalRoute.of(context)?.isCurrent ?? false;

bool isActiveScreen(BuildContext context) =>
    ModalRoute.of(context)?.isActive ?? false;
