import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class AccountActivationCompletionScreen extends StatefulWidget {
  const AccountActivationCompletionScreen({
    super.key,
  });

  @override
  AccountActivationCompletionScreenState createState() =>
      AccountActivationCompletionScreenState();
}

class AccountActivationCompletionScreenState
    extends State<AccountActivationCompletionScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPageData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadPageData();
    }
  }

  void _loadPageData() {}

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    automaticallyImplyLeading: false,
                    centerTitle: true,
                    elevation: 0,
                    actions: <Widget>[
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child: TextButton(
                            onPressed: () {
                              // Navigator.of(context).pushAndRemoveUntil(
                              //   MaterialPageRoute(
                              //       builder: (context) =>
                              //           NavigatorScreen(selectedIndex: 0)),
                              //   (Route<dynamic> route) => false,
                              // );
                              navigatorScreenStateKey.currentState
                                  ?.resetToScreen(
                                      0); // Resets to the home screen
                            },
                            child: Text(
                              'Skip for Now',
                              style: AppTheme.sectionSmallText,
                            ),
                          )),
                    ],
                  ),
                  body: bodyContent(context))));
    });
  }

  Widget bodyContent(BuildContext context) {
    return Column(children: [
      Expanded(
          child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Center(
                  child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: MediaQuery.of(context).size.height -
                            getButtonHeight(context),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.center,
                              child: SvgPicture.asset(
                                'lib/assets/tutorial5.svg',
                                height: MediaQuery.of(context).size.width * 0.5,
                                width: MediaQuery.of(context).size.width * 0.5,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 20),
                                        child: Text(
                                          "Your account setup is complete!",
                                          textAlign: TextAlign.center,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 24,
                                              color: AppTheme.secondary),
                                        )),
                                    Text(
                                      "Ready to grow your money? Buy your first Treasury Bill now and grow your wealth in a"
                                      " stress-free & secure way."
                                      // "\n\nInterest rates are at an all-time high! With Treasury Bills, your interest rates"
                                      // " are locked in even if the Federal Reserve decides to lower the rates"
                                      "\n\nYou don't have to pay state or local taxes on your earnings.",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: AppTheme.secondary),
                                    ),
                                  ]),
                            ),
                          ],
                        ),
                      ))))),
      continueButton(context),
    ]);
  }

  double getButtonHeight(BuildContext context) {
    double appBarHeight = AppBar().preferredSize.height;
    double bottomPadding = LayoutConfig().bottomPadding + 20;
    double buttonHeightFactor = MediaQuery.of(context).size.height * 0.06;

    return appBarHeight + bottomPadding + buttonHeightFactor + 50;
  }

  Widget continueButton(BuildContext context) {
    double bottomPadding = LayoutConfig().bottomPadding + 20;

    return Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: () {
                  // Navigator.of(context).pushAndRemoveUntil(
                  //   MaterialPageRoute(
                  //       builder: (context) =>
                  //           NavigatorScreen(selectedIndex: 1)),
                  //   (Route<dynamic> route) => false,
                  // );
                  navigatorScreenStateKey.currentState
                      ?.resetToScreen(1); // Resets to the invest screen
                },
              ),
            ]));
  }
}
