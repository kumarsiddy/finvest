import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bondgrid/screens/authentication/base_authentication_screen.dart';
import 'package:bondgrid/screens/home/apps_flyer_manager.dart';
import 'package:bondgrid/screens/home/loading_screen.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:bondgrid/services/storage_service.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/constants/storage_constants.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:bondgrid/services/push_notifications.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationHelper.initialized();
  runApp(
    DevicePreview(
      enabled: false, // Turn off in release mode
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool isLoggedIn = false;
  late bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loginFunc();
    initAppsFlyer();
  }

  void loginFunc() async {
    String? jwtToken = await TokenService.getJWTToken(forceRenew: true);

    if (jwtToken != null &&
        TokenService.hasValidVerificationStep(jwtToken, 'login_successful')) {
      final pushNotificationToken =
          await StorageService.getItem(StorageConstants.fcmToken);
      if (pushNotificationToken != null) {
        await AuthenticationRepo()
            .addPushNotificationToken(pushNotificationToken['token']);
      }
      setState(() {
        isLoading = false;
        isLoggedIn = true;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }

  void initAppsFlyer() async {
    final appsflyerSdk = AppsFlyerManager().sdk;

    appsflyerSdk.onDeepLinking((DeepLinkResult dp) {
      switch (dp.status) {
        case Status.FOUND:
          String? referralCode = dp.deepLink?.deepLinkValue;
          // store referralCode in localStorage
          if (referralCode != null) {
            StorageService.storeItem(
                StorageConstants.referralCode, {'code': referralCode});
          }
          break;
        case Status.NOT_FOUND:
          break;
        case Status.ERROR:
          break;
        case Status.PARSE_ERROR:
          break;
      }
    });

    appsflyerSdk.initSdk(registerOnDeepLinkingCallback: true);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finvest',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      home: getScreen(),
      themeMode: ThemeMode.light,
      theme: AppTheme.light,
      darkTheme: AppTheme.light,
      builder: (context, child) {
        return EasyLoading.init()(context, child);
      },
    );
  }

  Widget getScreen() {
    if (isLoading) {
      return const LoadingScreen();
    } else if (isLoggedIn) {
      return NavigatorScreen(
        selectedIndex: 0,
      );
    } else {
      return const LandingScreen();
    }
  }
}
