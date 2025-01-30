import 'dart:async';
import 'dart:ui';

import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/screens/authentication/login_screen_with_bloc.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/signup/signup_screen_with_bloc.dart';
import 'package:bondgrid/services/http_service.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  _LandingScreenState createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  late PageController _pageController;
  Timer? _timer;
  BaseService baseService = BaseService();
  late String interestRate = '5.3';

  void getInterestRate() async {
    final response =
        await baseService.callGet(ConfigurationFile.displayedInterestRate);
    if (response.containsKey('data') && response['data'] != null) {
      setState(() {
        interestRate = response['data'].toString();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getInterestRate();
    _pageController = PageController(initialPage: 1);

    startAutoScrollTimer();

    _pageController.addListener(() {
      if (_pageController.page == _pageController.page?.round()) {
        resetAutoScrollTimer();
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      LayoutConfig().bottomPadding = MediaQuery.of(context).padding.bottom;
      LayoutConfig().topPadding = MediaQuery.of(context).padding.top;
    });
  }

  void startAutoScrollTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      if (_pageController.hasClients) {
        int nextPage = _pageController.page!.toInt() + 1;
        if (nextPage >= 5) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void resetAutoScrollTimer() {
    _timer?.cancel();
    startAutoScrollTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.removeListener(() {});
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    return Scaffold(
        body: Stack(
      children: [
        // Container(
        //   decoration: const BoxDecoration(
        //     gradient: LinearGradient(
        //       begin: Alignment.topLeft,
        //       end: Alignment.bottomRight,
        //       colors: [
        //         AppTheme.primaryDark,
        //         AppTheme.primaryLight
        //       ], // Add your gradient colors here
        //     ),
        //   ),
        // ),
        // Container(
        //   decoration: const BoxDecoration(
        //     image: DecorationImage(
        //       image: AssetImage('lib/assets/light-background.png'),
        //       fit: BoxFit.cover,
        //     ),
        //   ),
        // ),
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 0.3, sigmaY: 0.3),
              child: Container(),
            ),
          ),
        ),
        NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (OverscrollIndicatorNotification overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20.0,
                      MediaQuery.of(context).viewPadding.top,
                      20,
                      bottomPadding),
                  child: Column(children: [
                    Expanded(
                        child: PageView(
                      controller: _pageController,
                      children: <Widget>[
                        mainPage(context),
                        earnPage(context),
                        taxPage(context),
                        savingsPage(context),
                        securityPage(context)
                      ],
                    )),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: 5,
                      effect: const WormEffect(
                          activeDotColor: AppTheme.primary,
                          dotWidth: 10,
                          dotHeight: 10),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomButton(
                                widthVal: 2.3,
                                buttonText: 'Log in',
                                primaryColor: AppTheme.backgroundColor,
                                borderColor: AppTheme.primary,
                                textColor: AppTheme.primary,
                                onPressFunction: () {
                                  Navigator.push(
                                      context,
                                      (Theme.of(context).platform ==
                                              TargetPlatform.iOS)
                                          ? CupertinoPageRoute(
                                              builder: ((context) =>
                                                  const LoginScreenBloc()))
                                          : MaterialPageRoute(
                                              builder: ((context) =>
                                                  const LoginScreenBloc())));
                                },
                              ),
                              CustomButton(
                                widthVal: 2.3,
                                buttonText: 'Sign up',
                                onPressFunction: () {
                                  Navigator.push(
                                      context,
                                      (Theme.of(context).platform ==
                                              TargetPlatform.iOS)
                                          ? CupertinoPageRoute(
                                              builder: ((context) =>
                                                  const SignupDetailsScreenBloc()))
                                          : MaterialPageRoute(
                                              builder: ((context) =>
                                                  const SignupDetailsScreenBloc())));
                                },
                              )
                            ]),
                      ],
                    ),
                  ]),
                ),
              ),
            )),
      ],
    ));
  }

  Widget mainPage(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double imageHeight = constraints.maxHeight * 0.75;

      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SizedBox(
          height: imageHeight,
          child: Align(
              alignment: Alignment.center,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'lib/assets/logo.png',
                    width: 200,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "#1 App for\nUS Treasuries",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 20,
                        color: AppTheme.secondary),
                    textAlign: TextAlign.center,
                  ),
                  // Text(
                  //   "#1 app for investing in \nUS Treasuries",
                  //   style: GoogleFonts.poppins(
                  //       fontWeight: FontWeight.w600,
                  //       fontSize: 20,
                  //       color: AppTheme.secondary),
                  //   textAlign: TextAlign.center,
                  // ),
                ],
              )),
        ),
        Expanded(
            child: SingleChildScrollView(
                child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              "Your investments are custodied and cleared through Pershing Advisor Solutions LLC,"
              " a subsidiary of the Bank of New York Mellon Corp.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: AppTheme.secondary),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        )))
      ]);
    });
  }

  Widget earnPage(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/investment-growth.svg',
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 30),
                    child: Text(
                      "Earn up to $interestRate% on US Treasuries",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  Text(
                    "Interest rates are at an all time high. With US Treasury Bills,"
                    " you can lock in your interest rates, even if the Federal Reserve lowers rates.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget taxPage(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/girl-saving-money.svg',
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 30),
                    child: Text(
                      "No state or local taxes on earnings",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  Text(
                    "Unlike the earnings on your savings account and most other assets,"
                    " the interest you earn on US Treasuries is exempt from state and local taxes.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget savingsPage(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/business-investment.svg',
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 30),
                    child: Text(
                      "Saving for that house?",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  Text(
                    "That’s how wealthy Americans park their cash. Treasury Bills"
                    " are one of the safest assets in the world. You can sell your Treasury"
                    " Bills anytime.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget securityPage(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'lib/assets/piggy-bank.svg',
              height: MediaQuery.of(context).size.width * 0.75,
              width: MediaQuery.of(context).size.width * 0.75,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 0, bottom: 30),
                    child: Text(
                      "Your security is our #1 priority",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                        color: AppTheme.secondary,
                      ),
                    ),
                  ),
                  Text(
                    "Your funds and investments are safely custodied and cleared through Pershing Advisor Solutions LLC,"
                    " a subsidiary of the Bank of New York Mellon Corp.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: AppTheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
