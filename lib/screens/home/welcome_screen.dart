import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/constants/config.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/onboarding/onboarding_screen.dart';
import 'package:bondgrid/services/http_service.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({
    super.key,
    required this.showNavBar,
  });

  final ValueNotifier<bool> showNavBar;

  @override
  WelcomeScreenState createState() => WelcomeScreenState();
}

class WelcomeScreenState extends State<WelcomeScreen>
    with WidgetsBindingObserver {
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
    return Column(
      children: [
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
                      SvgPicture.asset(
                        'lib/assets/investment-growth.svg',
                        height: MediaQuery.of(context).size.width * 0.6,
                        width: MediaQuery.of(context).size.width * 0.6,
                        fit: BoxFit.cover,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Column(
                          children: [
                            Text(
                              "Earn up to $interestRate% on US Treasuries",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 24,
                                  color: AppTheme.secondary),
                            ),
                            Text(
                              // "We're glad that you are here."
                              // " In the land of opportunity, your investments should rise with your dreams."
                              // "\nInterest rates are at an all-time high! With Treasury Bills, your interest rates"
                              // " are locked in even if the Federal Reserve decides to lower the rates."
                              "\nYou are signed up! We need a few more details and you'll be ready to start"
                              " purchasing Treasury Bills. This will only take a couple of minutes.",
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 14, color: AppTheme.secondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        getStartedButton(context),
      ],
    );
  }

  double getButtonHeight(BuildContext context) {
    double appBarHeight =
        LayoutConfig().topPadding + AppBar().preferredSize.height;
    double bottomPadding = LayoutConfig().bottomPadding + 20;
    double buttonHeightFactor = MediaQuery.of(context).size.height * 0.06;

    return appBarHeight + bottomPadding + buttonHeightFactor + 50;
  }

  Widget getStartedButton(BuildContext context) {
    double bottomPadding = LayoutConfig().bottomPadding + 20;

    return Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomButton(
                widthVal: 1,
                buttonText: 'Get Started',
                onPressFunction: () {
                  Navigator.push(
                          context,
                          (Theme.of(context).platform == TargetPlatform.iOS)
                              ? CupertinoPageRoute(
                                  builder: (context) => BlocProvider(
                                        create: (context) =>
                                            HomeBloc(HomeRepo()),
                                        child: const OnboardingScreen(),
                                      ))
                              : MaterialPageRoute(
                                  builder: (context) => BlocProvider(
                                        create: (context) =>
                                            HomeBloc(HomeRepo()),
                                        child: const OnboardingScreen(),
                                      )))
                      .then((_) {
                    _loadPageData();
                  });
                },
              )
            ]));
  }
}
