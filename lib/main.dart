import 'dart:async';

import 'package:finvest/config_options.dart';
import 'package:finvest/di/injection.dart';
import 'package:finvest/env.dart';
import 'package:finvest/presentation/core_app/app_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> mainCommon(
  Env env,
) async {
  runZonedGuarded<Future<void>>(
    () async {
      // Call this if the main method is asynchronous
      WidgetsFlutterBinding.ensureInitialized();
      initConfigReader(env);

      // Sets orientation to portrait mode only
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

      //Initialise Injection
      await configureDependencies(env);

      // Running the app with sentry coverage
      SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp],
      ).then(
        (_) {
          runApp(const AppWidget());
        },
      );
    },
    (error, stack) async {
      // await Crashlytics.logCrash(error, stackTrace: stack);
    },
  );
}
