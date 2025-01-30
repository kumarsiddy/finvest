import 'package:appsflyer_sdk/appsflyer_sdk.dart';

class AppsFlyerManager {
  static final AppsFlyerManager _instance = AppsFlyerManager._internal();
  late final AppsflyerSdk _appsflyerSdk;

  factory AppsFlyerManager() {
    return _instance;
  }

  AppsFlyerManager._internal() {
    AppsFlyerOptions appsFlyerOptions = AppsFlyerOptions(
        afDevKey: "PLVzyiwEp5FJoBYz5tHyhg",
        appId: "6473599514",
        // showDebug: true,
        timeToWaitForATTUserAuthorization: 50); // for iOS 14.5
    _appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    _appsflyerSdk.setAppInviteOneLinkID('C1TY', (res) {});
  }

  AppsflyerSdk get sdk => _appsflyerSdk;
}
