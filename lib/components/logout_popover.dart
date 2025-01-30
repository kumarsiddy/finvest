import 'package:bondgrid/screens/authentication/base_authentication_screen.dart';
import 'package:bondgrid/services/token_service.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bondgrid/constants/storage_constants.dart';
import 'package:bondgrid/services/storage_service.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutPopover extends StatelessWidget {
  const LogoutPopover({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // set up the buttons
    Widget cancelButton = SizedBox(
        height: MediaQuery.of(context).size.height * 0.06,
        width: MediaQuery.of(context).size.width * 0.5,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // <-- Radius
            ),
          ),
          onPressed: () async {
            // Delete push notification token
            final pushNotificationToken =
                await StorageService.getItem(StorageConstants.fcmToken);
            if (pushNotificationToken != null) {
              final AuthenticationRepo authenticationRepo =
                  AuthenticationRepo();
              authenticationRepo.deletePushNotificationTokenAtSignout(
                  pushNotificationToken['token']);
            }

            // Clear cache
            final prefs = await SharedPreferences.getInstance();
            prefs.clear();

            // Clear JWT token before logging out
            TokenService.clearJWTKey().then((value) {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      const LandingScreen(),
                  transitionDuration:
                      Duration.zero, // Specify no transition duration
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            });
          },
          child: Text(
            "Logout",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                color: AppTheme.nearlyWhite),
          ),
        ));
    // set up the AlertDialog
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // <-- Radius
      ),
      icon: Stack(children: [
        Center(
            child: SvgPicture.asset('lib/assets/arrow.svg',
                height: MediaQuery.of(context).size.height * 0.06,
                width: MediaQuery.of(context).size.height * 0.06,
                color: AppTheme.primary)),
        GestureDetector(
          onTap: () {},
          child: Container(
            alignment: FractionalOffset.topRight,
            child: GestureDetector(
              child: const Icon(
                Icons.clear,
                color: AppTheme.grey,
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ]),
      content: Text(
        "Are you sure that you want to logout?",
        style: AppTheme.bodyNormal,
        textAlign: TextAlign.center,
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 20),
      actions: [cancelButton],
    );
  }
}
