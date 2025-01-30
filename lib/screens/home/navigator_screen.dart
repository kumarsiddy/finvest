import 'package:bondgrid/bloc/plaid_bloc.dart';
import 'package:bondgrid/bloc/transfer_bloc.dart';
import 'package:bondgrid/repo/plaid_repo.dart';
import 'package:bondgrid/repo/transfer_repo.dart';
import 'package:bondgrid/screens/home/home_screen_with_bloc.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/home/refresh_notifier.dart';
import 'package:bondgrid/screens/profile/profile_screen_with_bloc.dart';
import 'package:bondgrid/screens/trading/trading_screen_with_bloc.dart';
import 'package:bondgrid/screens/wallet/wallet_screen_with_bloc.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

final GlobalKey<_NavigatorScreenState> navigatorScreenStateKey = GlobalKey();

class NavigatorScreen extends StatefulWidget {
  late int selectedIndex;
  bool showWelcomeScreen;

  NavigatorScreen(
      {Key? key, required this.selectedIndex, this.showWelcomeScreen = false})
      : super(key: navigatorScreenStateKey);

  @override
  State<NavigatorScreen> createState() => _NavigatorScreenState();
}

class _NavigatorScreenState extends State<NavigatorScreen> {
  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];
  final List<ScrollController> _scrollControllers = [
    ScrollController(),
    ScrollController(),
    ScrollController(),
    ScrollController(),
  ];
  final List<bool> _screenLoaded = [false, false, false, false];

  final ValueNotifier<bool> _showNavBar = ValueNotifier<bool>(true);
  final PlaidBloc plaidBloc = PlaidBloc(PlaidRepo());
  final TransferBloc transferBloc = TransferBloc(TransferRepo());

  final refreshNotifier = RefreshNotifier();

  void _onItemTapped(int index) {
    if (!_screenLoaded[index]) {
      setState(() {
        _screenLoaded[index] = true;
      });
    }
    if (index == widget.selectedIndex) {
      // If selecting the active tab, pop to the root of the current tab and scroll to its top
      _navigatorKeys[index].currentState?.popUntil((route) => route.isFirst);
      _scrollControllers[index].animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      setState(() => widget.selectedIndex = index);
    }
  }

  void resetToScreen(int index) {
    setState(() {
      _showNavBar.value = true;
      widget.selectedIndex = index;
      widget.showWelcomeScreen = false;

      if (!_screenLoaded[index]) {
        _screenLoaded[index] = true;
      }

      // Reset stacks for all navigators
      for (int i = 0; i < _navigatorKeys.length; i++) {
        _navigatorKeys[i].currentState?.popUntil((route) => route.isFirst);
      }

      refreshNotifier.refreshScreen();
    });
  }

  @override
  void initState() {
    super.initState();
    _screenLoaded[widget.selectedIndex] = true;
    plaidBloc.add(InitializePlaid());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      LayoutConfig().bottomPadding = MediaQuery.of(context).padding.bottom;
      LayoutConfig().topPadding = MediaQuery.of(context).padding.top;
    });
  }

  @override
  void dispose() {
    plaidBloc.add(DisposePlaid());
    refreshNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: plaidBloc),
          BlocProvider.value(value: transferBloc)
        ],
        child: Scaffold(
          body: ValueListenableBuilder<bool>(
              valueListenable: _showNavBar,
              builder: (context, value, child) {
                return Padding(
                    // Apply bottom padding if the bottom nav bar is not shown
                    padding:
                        //EdgeInsets.only(bottom: value ? 0 : bottomPadding),
                        const EdgeInsets.only(bottom: 0),
                    child: Stack(
                      children: [
                        _buildOffstageNavigator(0),
                        _buildOffstageNavigator(1),
                        _buildOffstageNavigator(2),
                        _buildOffstageNavigator(3),
                      ],
                    ));
              }),
          bottomNavigationBar: ValueListenableBuilder<bool>(
              valueListenable: _showNavBar,
              builder: ((context, value, child) {
                return value
                    ? SizedBox(
                        child: BottomNavigationBar(
                          iconSize: MediaQuery.of(context).size.height * 0.03,
                          selectedLabelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppTheme.secondary),
                          unselectedLabelStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                              color: AppTheme.secondary),
                          items: <BottomNavigationBarItem>[
                            BottomNavigationBarItem(
                              icon: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: SvgPicture.asset(
                                    'lib/assets/home.svg',
                                    height: 22.0,
                                    width: 22.0,
                                    color: widget.selectedIndex == 0
                                        ? AppTheme.primary
                                        : AppTheme.secondary.withOpacity(0.7),
                                  )),
                              label: "Home",
                            ),
                            BottomNavigationBarItem(
                              icon: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: SvgPicture.asset(
                                    'lib/assets/deposit.svg',
                                    height: 22.0,
                                    width: 22.0,
                                    color: widget.selectedIndex == 1
                                        ? AppTheme.primary
                                        : AppTheme.secondary.withOpacity(0.7),
                                  )),
                              label: "Invest",
                            ),
                            BottomNavigationBarItem(
                              icon: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: SvgPicture.asset(
                                    'lib/assets/wallet.svg',
                                    height: 22.0,
                                    width: 22.0,
                                    color: widget.selectedIndex == 2
                                        ? AppTheme.primary
                                        : AppTheme.secondary.withOpacity(0.7),
                                  )),
                              label: "Cash",
                            ),
                            BottomNavigationBarItem(
                              icon: Padding(
                                  padding: const EdgeInsets.only(bottom: 0),
                                  child: SvgPicture.asset(
                                    'lib/assets/account.svg',
                                    height: 22.0,
                                    width: 22.0,
                                    color: widget.selectedIndex == 3
                                        ? AppTheme.primary
                                        : AppTheme.secondary.withOpacity(0.7),
                                  )),
                              label: "Account",
                            ),
                          ],
                          currentIndex: widget.selectedIndex,
                          type: BottomNavigationBarType.fixed,
                          onTap: _onItemTapped,
                        ),
                      )
                    : const SizedBox.shrink();
              })),
        ));
  }

  Widget _buildOffstageNavigator(int index) {
    return Offstage(
      offstage: widget.selectedIndex != index,
      child: WillPopScope(
          onWillPop: () async {
            bool canPop =
                await _navigatorKeys[index].currentState?.maybePop() ?? false;
            return !canPop;
          },
          child: _screenLoaded[index]
              ? Navigator(
                  key: _navigatorKeys[index],
                  onGenerateRoute: (routeSettings) {
                    return MaterialPageRoute(
                      builder: (context) {
                        switch (index) {
                          case 0:
                            return HomeScreenBloc(
                              navigatorKey: _navigatorKeys[index],
                              showNavBar: _showNavBar,
                              switchTab: _onItemTapped,
                              scrollController: _scrollControllers[index],
                              showWelcomeScreen: widget.showWelcomeScreen,
                            );
                          case 1:
                            return TradingScreenBloc(
                              navigatorKey: _navigatorKeys[index],
                              showNavBar: _showNavBar,
                              scrollController: _scrollControllers[index],
                            );
                          case 2:
                            return WalletScreenBloc(
                              navigatorKey: _navigatorKeys[index],
                              showNavBar: _showNavBar,
                              scrollController: _scrollControllers[index],
                            );
                          case 3:
                            return ProfileScreenBloc(
                              navigatorKey: _navigatorKeys[index],
                              showNavBar: _showNavBar,
                              scrollController: _scrollControllers[index],
                            );
                          default:
                            return HomeScreenBloc(
                              navigatorKey: _navigatorKeys[index],
                              showNavBar: _showNavBar,
                              switchTab: _onItemTapped,
                              scrollController: _scrollControllers[index],
                              showWelcomeScreen: widget.showWelcomeScreen,
                            );
                        }
                      },
                    );
                  },
                )
              : Container()),
    );
  }
}
