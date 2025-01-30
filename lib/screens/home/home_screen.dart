import 'dart:async';

import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/account_failure_verification_popover.dart';
import 'package:bondgrid/components/account_pending_verification_popover.dart';
import 'package:bondgrid/components/account_verification_denied_popover.dart';
import 'package:bondgrid/components/circular_button_with_text.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/components/default_notification_card.dart';
import 'package:bondgrid/components/default_notification_modal.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/enums/button_link_type.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/holding_list.dart';
import 'package:bondgrid/models/in_app_notification.dart';
import 'package:bondgrid/models/in_app_notification_list.dart';
import 'package:bondgrid/models/transaction_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/home/submit_verification_info.dart';
import 'package:bondgrid/screens/onboarding/onboarding_screen.dart';
import 'package:bondgrid/screens/onboarding/update_information.dart';
import 'package:bondgrid/screens/profile/refer_screen.dart';
import 'package:bondgrid/screens/trading/holding_detail_screen.dart';
import 'package:bondgrid/screens/trading/holding_screen.dart';
import 'package:bondgrid/screens/transactions/transaction_detail_screen.dart';
import 'package:bondgrid/screens/transactions/transaction_screen.dart';
import 'package:bondgrid/screens/wallet/transfer/deposit_screen.dart';
import 'package:bondgrid/screens/wallet/transfer/withdrawal_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tuple/tuple.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.showNavBar,
    required this.switchTab,
    required this.scrollController,
  });

  final ValueNotifier<bool> showNavBar;
  final Function(int) switchTab;
  final ScrollController scrollController;

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  CashBalance? _portfolioValue;
  UserInfo? _userInfo;
  TransactionList? _transactionList;
  HoldingList? _holdingList;
  InAppNotificationList? _notificationList;
  bool _interestSummaryActive = false;

  StreamSubscription? _refreshSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadPageData();
    _refreshSubscription = navigatorScreenStateKey
        .currentState!.refreshNotifier.onRefresh
        .listen((_) {
      _loadPageData();
    });
  }

  @override
  void dispose() {
    _refreshSubscription?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // If the app is resumed, fetch the user status.
    if (state == AppLifecycleState.resumed) {
      _loadPageData();
    }
  }

  void _loadPageData({bool useCache = true}) {
    context.read<HomeBloc>().add(GetPortfolioValueEvent(useCache: useCache));
    context.read<HomeBloc>().add(GetUserInfoEvent(useCache: useCache));
    context.read<HomeBloc>().add(GetTransactionListEvent(useCache: useCache));
    context.read<HomeBloc>().add(GetHoldingListEvent(useCache: useCache));
    context.read<HomeBloc>().add(GetInterestSummaryStatusEvent());
    context.read<HomeBloc>().add(LoadInAppNotifications());
    // context
    //     .read<HomeBloc>()
    //     .add(LoadHomeScreenInitialDataEvent(useCache: useCache));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            // if (state is LoadHomeScreenInitialSuccessState) {
            //   _portfolioValue = state.portfolioValue;
            //   _userInfo = state.userInfo;
            //   _transactionList = state.transactionList;
            //   _holdingList = state.holdingList;
            //   _interestSummaryActive = state.interestSummaryActive;
            // }

            if (state is LoadInAppNotificationSuccessState) {
              _notificationList = state.notificationList;
              if (_notificationList != null &&
                  _notificationList!.modalNotifications.isNotEmpty) {
                // We only want to display one modal on app start up so we
                // display the latest one
                showNotificationModal(
                    _notificationList!.modalNotifications.first);
              }
            }

            if (state is GetPortfolioValueSuccessState) {
              _portfolioValue = state.portfolioValue;
            }

            if (state is GetUserInfoSuccessState) {
              _userInfo = state.userInfo;
            }

            if (state is GetTransactionListSuccessState) {
              _transactionList = state.transactionList;
            }

            if (state is GetHoldingListSuccessState) {
              _holdingList = state.holdingList;
            }

            if (state is GetInterestSummaryStatusSuccessState) {
              _interestSummaryActive = state.interestSummaryActive;
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: SafeArea(
                  child: RefreshIndicator(
                      color: AppTheme.primary,
                      onRefresh: () async {
                        _loadPageData();
                      },
                      child: Scaffold(
                          body: NotificationListener<
                                  OverscrollIndicatorNotification>(
                              onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      }, child: LayoutBuilder(builder: (BuildContext context,
                                  BoxConstraints viewportConstraints) {
                        return SingleChildScrollView(
                            controller: widget.scrollController,
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: viewportConstraints.maxHeight,
                                ),
                                child: IntrinsicHeight(
                                    child: Container(
                                        margin: const EdgeInsets.only(
                                            top: 10,
                                            bottom: 20,
                                            left: 15,
                                            right: 15),
                                        child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            children: [
                                              portfolioCard(context, state),
                                              buyingPowerCard(context, state),
                                              accountStatusCard(context, state),
                                              notificationCards(context, state),
                                              userHoldings(context, state),
                                              recentTransactions(
                                                  context, state),
                                              Expanded(child: Container())
                                            ])))));
                      })))))));
    });
  }

  Widget portfolioCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: 0,
                color: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          _portfolioValue == null
                              ? buildNumberShimmer(
                                  context: context,
                                  width: 120,
                                  height: 30,
                                  padding: const EdgeInsets.only(bottom: 10),
                                  borderRadius: BorderRadius.circular(20))
                              : Text(
                                  _portfolioValue != null &&
                                          _portfolioValue!.portfolioValue !=
                                              null
                                      ? formatAmount(
                                          _portfolioValue!.portfolioValue!)
                                      : "",
                                  style: AppTheme.numberTitleText),
                          Text(
                            "Portfolio Value",
                            style: AppTheme.numberSubText,
                          ),
                          _interestSummaryActive
                              ? interestSummary(context)
                              : const SizedBox.shrink(),
                          const SizedBox(
                            height: 20,
                          ),
                          buttonRows(context, state)
                        ])))));
  }

  Widget interestSummary(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 5,
        ),
        _portfolioValue != null &&
                _portfolioValue!.totalInterest != null &&
                isPositive(_portfolioValue!.totalInterest!) &&
                _portfolioValue!.totalRealizedGains != null &&
                _portfolioValue!.totalUnrealizedGains != null
            ? GestureDetector(
                onTap: () {
                  showMainModal();
                },
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // const Icon(
                      //   Icons.arrow_upward,
                      //   color: Colors.green,
                      //   size: 16,
                      // ),
                      // const SizedBox(width: 2),
                      Text(
                          "${formatAmount(_portfolioValue!.totalInterest!, showPositiveSign: true)} Interest Earned",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                              color: Colors.green)),
                      const SizedBox(width: 5),
                      const Icon(
                        Icons.arrow_circle_right_outlined,
                        color: Colors.green,
                        size: 18,
                      ),
                    ]))
            : const SizedBox.shrink()
      ],
    );
  }

  void showMainModal() {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: interestModalContent(context));
        // return DraggableScrollableSheet(
        //   initialChildSize: 0.3,
        //   minChildSize: 0.25,
        //   maxChildSize: 0.7,
        //   expand: false,
        //   builder: (BuildContext context,
        //       ScrollController
        //           scrollController) {
        //     return interestModalContent(
        //         context, scrollController);
        //   },
        // );
      },
    );
  }

  Widget interestModalContent(BuildContext context) {
    return ListView(
      //controller: scrollController,
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Opacity(
              opacity: 0.0,
              child: IconButton(
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  size: 22,
                ),
                onPressed: null,
              ),
            ),
            Text(
              'Balance Details',
              style: AppTheme.bodyBold,
              textAlign: TextAlign.center,
            ),
            Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.clear,
                    color: AppTheme.actionButton,
                    size: 22,
                  ),
                )),
          ],
        ),
        Padding(
            padding:
                const EdgeInsets.only(top: 20, bottom: 20, left: 15, right: 15),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              interestBreakdownModalSection(context),
              // const SizedBox(height: 10),
              // const Divider(),
              // const SizedBox(height: 10),
              // upcomingInterestModalSection(context),
              // const SizedBox(height: 10),
              // const Divider(),
              // const SizedBox(height: 10),
              // depositModalSection(context)
            ]))
      ],
    );
  }

  Widget interestBreakdownModalSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
          _portfolioValue!.totalInterest != null
              ? formatAmount(_portfolioValue!.totalInterest!)
              : "",
          style: AppTheme.sectionTitleText),
      const SizedBox(height: 3),
      Text("Total Interest Earned", style: AppTheme.bodyNormalGrey),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Realized Interest",
            style: AppTheme.subBodyDark,
          ),
          Text(
            _portfolioValue!.totalRealizedGains != null
                ? formatAmount(_portfolioValue!.totalRealizedGains!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the main modal
                showInfoModal(
                    context: context,
                    title: 'Unrealized Interest',
                    subtext:
                        'This is the estimated interest that you have earned on your current treasury holdings'
                        ' based on their present market value. This interest is considered unrealized because'
                        ' it has not yet been converted into actual gains or cash in your account.\n\n'
                        'The actual interest you receive may differ from this estimate when you sell your holdings or hold them to maturity.',
                    isNavBarVisible: true,
                    onClose: () {
                      // Reopen the main modal when the unrealized interest modal is closed);
                      showMainModal();
                    });
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Unrealized Interest",
                      style: AppTheme.subBodyDark,
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ])),
          Text(
            _portfolioValue!.totalUnrealizedGains != null
                ? formatAmount(_portfolioValue!.totalUnrealizedGains!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Cash Interest",
            style: AppTheme.subBodyDark,
          ),
          Text(
            _portfolioValue!.cashInterestAccrued != null
                ? formatAmount(_portfolioValue!.cashInterestAccrued!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the main modal
                showInfoModal(
                    context: context,
                    title: 'Finvest Bonus',
                    subtext: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTheme.subBodyNormal,
                        children: const [
                          TextSpan(
                            text:
                                'This represents the total bonus that has been paid out by Finvest through any promotions'
                                ' such as the referral program.',
                          ),
                        ],
                      ),
                    ),
                    isNavBarVisible: true,
                    onClose: () {
                      // Reopen the main modal when the unrealized interest modal is closed);
                      showMainModal();
                    });
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Finvest Bonus",
                      style: AppTheme.subBodyDark,
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ])),
          Text(
            _portfolioValue!.totalBonus != null
                ? formatAmount(_portfolioValue!.totalBonus!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
              onTap: () {
                Navigator.pop(context); // Close the main modal
                showInfoModal(
                    context: context,
                    title: 'Finvest Fees',
                    subtext: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: AppTheme.subBodyNormal,
                        children: [
                          const TextSpan(
                            text:
                                'Finvest charges a monthly fee equal to 0.03% of your treasury value. ',
                          ),
                          WidgetSpan(
                            child: InkWell(
                              onTap: () async {
                                const url =
                                    "https://www.getfinvest.com/support/fee-schedule";
                                if (await canLaunchUrl(Uri.parse(url))) {
                                  await launchUrl(Uri.parse(url));
                                }
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Learn More',
                                    style: AppTheme.subBodyNormal.copyWith(
                                      color: AppTheme.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: AppTheme.primary,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    isNavBarVisible: true,
                    onClose: () {
                      // Reopen the main modal when the unrealized interest modal is closed);
                      showMainModal();
                    });
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Finvest Fees",
                      style: AppTheme.subBodyDark,
                    ),
                    const SizedBox(width: 5),
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.primary,
                      size: 16,
                    ),
                  ])),
          Text(
            _portfolioValue!.totalFees != null
                ? formatAmount(_portfolioValue!.totalFees!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
    ]);
  }

  Widget upcomingInterestModalSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Upcoming Interest', style: AppTheme.sectionSmallTitle),
      const SizedBox(height: 3),
      Text(
          "Here's how your future portfolio might look like based on your current holdings.",
          style: AppTheme.bodyNormalGrey),
      const SizedBox(height: 20),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Current Value",
            style: AppTheme.subBodyDark,
          ),
          Text(
            _portfolioValue!.portfolioValue != null
                ? formatAmount(_portfolioValue!.portfolioValue!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "End of this month",
            style: AppTheme.subBodyDark,
          ),
          Text(
            _portfolioValue!.portfolioValue != null
                ? formatAmount(_portfolioValue!.portfolioValue!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      ),
      const SizedBox(height: 5),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "End of this year",
            style: AppTheme.subBodyDark,
          ),
          Text(
            _portfolioValue!.portfolioValue != null
                ? formatAmount(_portfolioValue!.portfolioValue!)
                : "",
            style: AppTheme.bodyNormal,
          ),
        ],
      )
    ]);
  }

  Widget depositModalSection(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Save more, grow more', style: AppTheme.sectionSmallTitle),
      const SizedBox(height: 3),
      Text(
          "Add a deposit and invest into treasury bills to maximize the interest on your idle cash.",
          style: AppTheme.bodyNormalGrey),
      const SizedBox(height: 20),
      CustomButton(
        widthVal: 1,
        heightVal: 0.05,
        buttonText: 'Deposit',
        onPressFunction: () {
          Navigator.pop(context);
          widget.switchTab(2);
        },
      )
    ]);
  }

  Widget buttonRows(BuildContext context, HomeState state) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircularButtonWithText(
          icon: Icons.sync_alt_rounded,
          text: "Invest",
          onPressed: () {
            widget.switchTab(1);
          },
          backgroundColor: AppTheme.primary,
          iconColor: AppTheme.nearlyWhite,
        ),
        CircularButtonWithText(
          icon: Icons.arrow_upward_rounded,
          text: "Deposit",
          onPressed: _userInfo != null &&
                  (_userInfo!.verification.status ==
                          VerificationStatus.SUCCESSFUL ||
                      _userInfo!.verification.status ==
                          VerificationStatus.PROCESSING)
              ? () {
                  widget.showNavBar.value =
                      false; // Hide the bottom navigation bar
                  Navigator.push(
                          context,
                          (Theme.of(context).platform == TargetPlatform.iOS)
                              ? CupertinoPageRoute(
                                  builder: (context) => const DepositScreen())
                              : MaterialPageRoute(
                                  builder: (context) => const DepositScreen()))
                      .then((_) {
                    widget.showNavBar.value =
                        true; // Show the bottom navigation bar
                    EasyLoading.dismiss();
                  });
                }
              : _userInfo != null &&
                      _userInfo!.verification.status ==
                          VerificationStatus.NOT_STARTED
                  ? () {
                      showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.9),
                          context: context,
                          builder: (context) {
                            return const AccountPendingVerificationPopover();
                          });
                    }
                  : _userInfo != null &&
                          _userInfo!.verification.status ==
                              VerificationStatus.FAILED
                      ? () {
                          showDialog(
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.9),
                              context: context,
                              builder: (context) {
                                return const AccountFailureVerificationPopover();
                              });
                        }
                      : _userInfo != null &&
                              _userInfo!.verification.status ==
                                  VerificationStatus.DENIED
                          ? () {
                              showDialog(
                                  barrierDismissible: false,
                                  barrierColor: Colors.black.withOpacity(0.9),
                                  context: context,
                                  builder: (context) {
                                    return const AccountVerificationDeniedPopover();
                                  });
                            }
                          : () {},
          backgroundColor: AppTheme.primary,
          iconColor: AppTheme.nearlyWhite,
        ),
        CircularButtonWithText(
          icon: Icons.arrow_downward_rounded,
          text: "Withdraw",
          onPressed: _userInfo != null &&
                  (_userInfo!.verification.status ==
                          VerificationStatus.SUCCESSFUL ||
                      _userInfo!.verification.status ==
                          VerificationStatus.PROCESSING)
              ? () {
                  widget.showNavBar.value =
                      false; // Hide the bottom navigation bar
                  Navigator.push(
                          context,
                          (Theme.of(context).platform == TargetPlatform.iOS)
                              ? CupertinoPageRoute(
                                  builder: (context) =>
                                      const WithdrawalScreen())
                              : MaterialPageRoute(
                                  builder: (context) =>
                                      const WithdrawalScreen()))
                      .then((_) {
                    widget.showNavBar.value =
                        true; // Show the bottom navigation bar
                    EasyLoading.dismiss();
                  });
                }
              : _userInfo != null &&
                      _userInfo!.verification.status ==
                          VerificationStatus.NOT_STARTED
                  ? () {
                      showDialog(
                          barrierDismissible: false,
                          barrierColor: Colors.black.withOpacity(0.9),
                          context: context,
                          builder: (context) {
                            return const AccountPendingVerificationPopover();
                          });
                    }
                  : _userInfo != null &&
                          _userInfo!.verification.status ==
                              VerificationStatus.FAILED
                      ? () {
                          showDialog(
                              barrierDismissible: false,
                              barrierColor: Colors.black.withOpacity(0.9),
                              context: context,
                              builder: (context) {
                                return const AccountFailureVerificationPopover();
                              });
                        }
                      : _userInfo != null &&
                              _userInfo!.verification.status ==
                                  VerificationStatus.DENIED
                          ? () {
                              showDialog(
                                  barrierDismissible: false,
                                  barrierColor: Colors.black.withOpacity(0.9),
                                  context: context,
                                  builder: (context) {
                                    return const AccountVerificationDeniedPopover();
                                  });
                            }
                          : () {},
          backgroundColor: AppTheme.primary,
          iconColor: AppTheme.nearlyWhite,
        ),
        CircularButtonWithText(
          icon: Icons.more_horiz_rounded,
          text: "More",
          onPressed: () async {
            const url = "https://www.getfinvest.com";
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            }
          },
          backgroundColor: AppTheme.primary,
          iconColor: AppTheme.nearlyWhite,
        )
      ],
    );
  }

  Widget accountStatusCard(BuildContext context, HomeState state) {
    if (_userInfo != null && state is! LoadHomeScreenInitialLoadingState) {
      switch (_userInfo!.verification.status) {
        case VerificationStatus.NOT_STARTED:
          return accountVerificationActivationCard(context, state);
        case VerificationStatus.PROCESSING:
          if (_transactionList != null &&
              _transactionList!.transactions.isNotEmpty) {
            return accountVerificationProcessingCard(context, state);
          }
          return const SizedBox.shrink();
        case VerificationStatus.FAILED:
          return accountVerificationFailureCard(context, state);
        case VerificationStatus.DENIED:
          return accountVerificationDeniedCard(context, state);
        case VerificationStatus.SUCCESSFUL:
          return const SizedBox.shrink();
        case VerificationStatus.CLOSED:
          return accountVerificationClosedCard(context, state);
        default:
          return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  void showNotificationModal(InAppNotification notification) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    widget.showNavBar.value = false;
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      context: context,
      builder: (BuildContext context) {
        if (notification.title == null || notification.body == null) {
          return const SizedBox.shrink();
        }

        Color backgroundColor =
            notification.backgroundColor ?? AppTheme.primary;
        Color textColor = notification.textColor ?? AppTheme.nearlyWhite;

        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: DefaultNotificationModal(
              title: notification.title!,
              bodyText: notification.body!,
              buttonText: notification.buttonText,
              onPressed: () {
                if (notification.buttonLinkType == ButtonLinkType.APP) {
                  // Navigate to a page within the app if the buttonLink matches a screen
                  final screenData = _getAppScreen(notification.buttonLink);
                  if (screenData != null) {
                    final screen = screenData.item1;
                    final hideNav = screenData.item2;
                    widget.showNavBar.value = !hideNav;
                    Navigator.push(
                            context,
                            (Theme.of(context).platform == TargetPlatform.iOS)
                                ? CupertinoPageRoute(
                                    builder: (context) => BlocProvider(
                                          create: (context) =>
                                              HomeBloc(HomeRepo()),
                                          child: screen,
                                        ))
                                : MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                          create: (context) =>
                                              HomeBloc(HomeRepo()),
                                          child: screen,
                                        )))
                        .then((_) {
                      widget.showNavBar.value = false;
                    });
                  }
                } else if (notification.buttonLinkType ==
                    ButtonLinkType.EXTERNAL) {
                  _launchURL(notification.buttonLink);
                }
              },
              localImagePath: notification.localImagePath,
              imageUrl: notification.imageUrl,
              backgroundColor: backgroundColor,
              textColor: textColor,
            ));
      },
    ).then(
      (value) {
        homeBloc.add(MarkNotificationAsProcessed(notification.id!));
        widget.showNavBar.value = true;
      },
    );
  }

  Widget notificationCards(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    return _notificationList == null ||
            _notificationList!.cardNotifications.isEmpty
        ? const SizedBox.shrink()
        : SizedBox(
            width: double.infinity,
            child: Stack(
                children:
                    _notificationList!.cardNotifications.map((notification) {
              if (notification.title == null || notification.body == null) {
                return const SizedBox.shrink();
              }

              Color backgroundColor =
                  notification.backgroundColor ?? AppTheme.primary;
              Color textColor = notification.textColor ?? AppTheme.nearlyWhite;

              return Dismissible(
                  key: ValueKey(notification),
                  crossAxisEndOffset: -0.2,
                  onDismissed: (direction) {
                    homeBloc.add(MarkNotificationAsProcessed(notification.id!));
                    setState(() {
                      _notificationList!.cardNotifications.remove(notification);
                    });
                  },
                  child: DefaultNotificationCard(
                    title: notification.title!,
                    bodyText: notification.body!,
                    buttonText: notification.buttonText,
                    onPressed: () {
                      if (notification.buttonLinkType == ButtonLinkType.APP) {
                        // Navigate to a page within the app if the buttonLink matches a screen
                        final screenData =
                            _getAppScreen(notification.buttonLink);
                        if (screenData != null) {
                          final screen = screenData.item1;
                          final hideNav = screenData.item2;
                          widget.showNavBar.value = !hideNav;
                          Navigator.push(
                                  context,
                                  (Theme.of(context).platform ==
                                          TargetPlatform.iOS)
                                      ? CupertinoPageRoute(
                                          builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    HomeBloc(HomeRepo()),
                                                child: screen,
                                              ))
                                      : MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    HomeBloc(HomeRepo()),
                                                child: screen,
                                              )))
                              .then((_) {
                            widget.showNavBar.value = true;
                          });
                        }
                      } else if (notification.buttonLinkType ==
                          ButtonLinkType.EXTERNAL) {
                        _launchURL(notification.buttonLink);
                      }
                    },
                    onCancel: () {
                      homeBloc
                          .add(MarkNotificationAsProcessed(notification.id!));
                      setState(() {
                        _notificationList!.cardNotifications
                            .remove(notification);
                      });
                    },
                    textButton: true,
                    localImagePath: notification.localImagePath,
                    imageUrl: notification.imageUrl,
                    backgroundColor: backgroundColor,
                    textColor: textColor,
                  ));
            }).toList()));
  }

  Tuple2<Widget, bool>? _getAppScreen(String? buttonLink) {
    if (buttonLink == '/refer') {
      return const Tuple2(ReferScreen(), true);
    }
    return null;
  }

  void _launchURL(String? url) async {
    if (url != null) {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      }
    }
  }

  Widget accountVerificationActivationCard(
      BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary,
                          AppTheme.primaryLight,
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.recent_actors_rounded,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account Activation",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "You are signed up! We need a few more details and you'll be ready to start"
                                        " purchasing Treasury Bills. This will only take a couple of minutes.",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                              width: MediaQuery.of(context).size.width,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.nearlyWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: () {
                                  // context.read<HomeBloc>().add(GetUserInfoEvent());
                                  widget.showNavBar.value =
                                      false; // Hide the bottom navigation bar
                                  Navigator.push(
                                          context,
                                          (Theme.of(context).platform ==
                                                  TargetPlatform.iOS)
                                              ? CupertinoPageRoute(
                                                  builder: (context) =>
                                                      BlocProvider(
                                                        create: (context) =>
                                                            HomeBloc(
                                                                HomeRepo()),
                                                        child:
                                                            const OnboardingScreen(),
                                                      ))
                                              : MaterialPageRoute(
                                                  builder: (context) =>
                                                      BlocProvider(
                                                        create: (context) =>
                                                            HomeBloc(
                                                                HomeRepo()),
                                                        child:
                                                            const OnboardingScreen(),
                                                      )))
                                      .then((_) {
                                    widget.showNavBar.value =
                                        true; // Show the bottom navigation bar
                                    _loadPageData();
                                  });
                                },
                                child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Text(
                                      "Get Started",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: AppTheme.primary),
                                    )),
                              ))
                        ])))));
  }

  Widget accountVerificationSuccessCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.teal,
                          Colors.teal.shade400,
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account Approved",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Your account has been successfully approved."
                                        " Begin purchasing treasuries and let your money work for itself. Start investing"
                                        " and watch your savings grow!",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ])))));
  }

  Widget accountVerificationProcessingCard(
      BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple,
                          Colors.purple.shade400,
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.check_circle_outline,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account In-Review",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "We are reviewing your account."
                                        // " In most cases, the review is instant though in some cases it might take 1-2 business days."
                                        // " We'll contact you if we require any further information.",
                                        " Once your account is approved, we will process any pending transactions.",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ])))));
  }

  Widget accountVerificationDeniedCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red,
                          Colors.red.shade400,
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.cancel_outlined,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account Not Approved",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "We're sorry but your account could not be approved at this time."
                                        " Please contact us at support@getfinvest.com for more information.",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ])))));
  }

  Widget accountVerificationClosedCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.red,
                          Colors.red.shade400,
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.cancel_outlined,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account Closed",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        "Your account is closed."
                                        " Please contact us at support@getfinvest.com if you want to reopen the account.",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12),
                                      )
                                    ],
                                  ),
                                ),
                              ]),
                        ])))));
  }

  Widget accountVerificationFailureCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Card(
                elevation: AppTheme.cardElevation,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary,
                          AppTheme.primaryLight
                        ], // Transition from primary to a darker shade.
                      ),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.warning_outlined,
                                    size: MediaQuery.of(context).size.height *
                                        0.04,
                                    color: AppTheme.nearlyWhite),
                                const SizedBox(
                                  width: 20,
                                ),
                                Expanded(
                                  // Use Expanded widget to enable multiline text
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Account Verification Failed",
                                        style: GoogleFonts.poppins(
                                            color: AppTheme.nearlyWhite,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 16),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      if (_userInfo!
                                              .verification.failureMessage !=
                                          null)
                                        Text(
                                          _userInfo!
                                              .verification.failureMessage!,
                                          style: GoogleFonts.poppins(
                                              color: AppTheme.nearlyWhite,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        )
                                      else
                                        Text(
                                          "Your information could not be verified. Please upload the necessary documents to verify your identity.",
                                          style: GoogleFonts.poppins(
                                              color: AppTheme.nearlyWhite,
                                              fontWeight: FontWeight.w400,
                                              fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ),
                              ]),
                          const SizedBox(
                            height: 15,
                          ),
                          failureButtons(context, state)
                        ])))));
  }

  Widget failureButtons(BuildContext context, HomeState state) {
    final hasCustomFailure =
        _userInfo?.verification.customFailureInput ?? false;
    final hasCompletionLink = _userInfo?.verification.completionLink != null;
    final hasFailedAttributes =
        _userInfo?.verification.failedAttributes?.isNotEmpty ?? false;

    return Column(children: [
      if (hasCustomFailure)
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: submitVerificationInfoButton(context))
      else if (hasCompletionLink && hasFailedAttributes)
        Row(
          children: [
            Expanded(child: updateInformationButton(context)),
            const SizedBox(width: 10), // Spacing between the buttons
            Expanded(child: uploadDocumentButton(context)),
          ],
        )
      else if (hasCompletionLink)
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: uploadDocumentButton(context))
      else if (hasFailedAttributes)
        SizedBox(
            width: MediaQuery.of(context).size.width,
            child: updateInformationButton(context))
    ]);
  }

  Widget submitVerificationInfoButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.nearlyWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: _userInfo != null && _userInfo!.personalDetails.email != null
          ? () {
              Navigator.push(
                      context,
                      (Theme.of(context).platform == TargetPlatform.iOS)
                          ? CupertinoPageRoute(
                              builder: (context) => BlocProvider(
                                    create: (context) => HomeBloc(HomeRepo()),
                                    child: SubmitVerificationInfo(
                                        userEmail:
                                            _userInfo!.personalDetails.email!),
                                  ))
                          : MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                    create: (context) => HomeBloc(HomeRepo()),
                                    child: SubmitVerificationInfo(
                                        userEmail:
                                            _userInfo!.personalDetails.email!),
                                  )))
                  .then((_) {
                _loadPageData();
              });
            }
          : null,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "Submit Information",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget updateInformationButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.nearlyWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        widget.showNavBar.value = false; // Hide the bottom navigation bar
        Navigator.push(
                context,
                (Theme.of(context).platform == TargetPlatform.iOS)
                    ? CupertinoPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: UpdateInformation(
                                showNavBar: widget.showNavBar,
                              ),
                            ))
                    : MaterialPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: UpdateInformation(
                                showNavBar: widget.showNavBar,
                              ),
                            )))
            .then((_) {
          widget.showNavBar.value = true; // Show the bottom navigation bar
          _loadPageData();
        });
      },
      child: FittedBox(
        fit: BoxFit.fitWidth,
        child: Text(
          "Update Information",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }

  Widget uploadDocumentButton(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.nearlyWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () async {
        if (_userInfo!.verification.completionLink != null) {
          await launchUrl(Uri.parse(_userInfo!.verification.completionLink!));
        }
      },
      child: FittedBox(
          fit: BoxFit.fitWidth,
          child: Text(
            "Upload Documents",
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500, color: AppTheme.primary),
          )),
    );
  }

  Widget buyingPowerCard(BuildContext context, HomeState state) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            widget.switchTab(2);
          },
          child: Card(
              elevation: 0,
              color: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                    width: 1, color: Colors.grey[600]!.withOpacity(0.2)),
              ),
              //margin: const EdgeInsets.fromLTRB(10, 20, 20, 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      //flex: 7,
                      child: Text(
                        "Buying Power",
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyNormal,
                      ),
                    ),
                    Flexible(
                      //flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _portfolioValue != null &&
                                    _portfolioValue!.buyingPower != null
                                ? formatAmount(_portfolioValue!.buyingPower!)
                                : "",
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.bodyNormal,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.keyboard_arrow_right_rounded,
                            color: AppTheme.primary,
                            size: 26,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
    );
  }

  Widget userHoldings(BuildContext context, HomeState state) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Your Holdings",
                      style: AppTheme.sectionTitle,
                    ),
                    _holdingList == null || _holdingList!.holdings.isEmpty
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: 1,
                              color: AppTheme.secondary.withOpacity(0.1),
                            ),
                          ),
                    _holdingList == null || _holdingList!.holdings.isEmpty
                        ? const SizedBox.shrink()
                        : TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.notWhite,
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: _holdingList == null
                                ? null
                                : () {
                                    Navigator.push(
                                            context,
                                            (Theme.of(context).platform ==
                                                    TargetPlatform.iOS)
                                                ? CupertinoPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                          create: (context) =>
                                                              HomeBloc(
                                                                  HomeRepo()),
                                                          child: HoldingScreen(
                                                              showNavBar: widget
                                                                  .showNavBar,
                                                              holdingList:
                                                                  _holdingList!),
                                                        ))
                                                : MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                          create: (context) =>
                                                              HomeBloc(
                                                                  HomeRepo()),
                                                          child: HoldingScreen(
                                                              showNavBar: widget
                                                                  .showNavBar,
                                                              holdingList:
                                                                  _holdingList!),
                                                        )))
                                        .then((_) {
                                      _loadPageData();
                                    });
                                  },
                            child: Text(
                              "See all",
                              style: AppTheme.sectionSmallText,
                            ))
                  ],
                )),
            SizedBox(
                width: double.infinity,
                child: Container(
                    padding: const EdgeInsets.all(0),
                    child: _holdingList == null
                        ? buildTransactionShimmer(context)
                        : _holdingList == null || _holdingList!.holdings.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Nothing to show here",
                                        style: AppTheme.subBodyNormal,
                                      )
                                    ]))
                            : listHoldings(context, state)))
          ],
        ));
  }

  Widget listHoldings(BuildContext context, HomeState state) {
    return Column(
      children: _holdingList!.holdings.take(4).map((holding) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  widget.showNavBar.value = false;
                  if (holding.id != null) {
                    Navigator.push(
                            context,
                            (Theme.of(context).platform == TargetPlatform.iOS)
                                ? CupertinoPageRoute(
                                    builder: (context) => BlocProvider(
                                        create: (context) =>
                                            HomeBloc(HomeRepo()),
                                        child: HoldingDetailScreen(
                                          holdingId: holding.id!,
                                        )))
                                : MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                        create: (context) =>
                                            HomeBloc(HomeRepo()),
                                        child: HoldingDetailScreen(
                                          holdingId: holding.id!,
                                        ))))
                        .then((_) {
                      widget.showNavBar.value =
                          true; // Show the bottom navigation bar
                      _loadPageData();
                    });
                  }
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: SizedBox(
                              child: Padding(
                                padding: const EdgeInsets.all(5),
                                child: Image.asset(
                                  'lib/assets/seal.png',
                                  height: 35.0,
                                  width: 35.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 60,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    holding.duration ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodyNormal,
                                  ),
                                  Text(
                                      "Maturity date: ${holding.maturityDate != null ? formatDate(holding.maturityDate!) : ""}",
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTheme.subBodyNormal)
                                ])),
                        Expanded(
                            flex: 28,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        holding.getTradeSymbol(),
                                        style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 8,
                                            color: AppTheme.secondary
                                                .withOpacity(0.6)),
                                      ),
                                      Text(
                                        formatAmount(
                                            holding.currentValue?.toString() ??
                                                "0.0"),
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.bodyNormal,
                                      ),
                                    ],
                                  ),
                                  Text(
                                    holding.yieldToMaturity != null
                                        ? "${holding.yieldToMaturity!}% YTM"
                                        : "",
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.subBodyNormalGreen,
                                  )
                                ]))
                      ]),
                )));
      }).toList(),
    );
  }

  Widget recentTransactions(BuildContext context, HomeState state) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Recent Transactions",
                      style: AppTheme.sectionTitle,
                    ),
                    _transactionList == null ||
                            _transactionList!.transactions.isEmpty
                        ? const SizedBox.shrink()
                        : Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              height: 1,
                              color: AppTheme.secondary.withOpacity(0.1),
                            ),
                          ),
                    _transactionList == null ||
                            _transactionList!.transactions.isEmpty
                        ? const SizedBox.shrink()
                        : TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.notWhite,
                              padding: const EdgeInsets.all(0),
                            ),
                            onPressed: _transactionList == null
                                ? null
                                : () {
                                    Navigator.push(
                                            context,
                                            (Theme.of(context).platform ==
                                                    TargetPlatform.iOS)
                                                ? CupertinoPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                          create: (context) =>
                                                              HomeBloc(
                                                                  HomeRepo()),
                                                          child:
                                                              TransactionScreen(
                                                            transactionList:
                                                                _transactionList!
                                                                    .transactions,
                                                          ),
                                                        ))
                                                : MaterialPageRoute(
                                                    builder: (context) =>
                                                        BlocProvider(
                                                          create: (context) =>
                                                              HomeBloc(
                                                                  HomeRepo()),
                                                          child: TransactionScreen(
                                                              transactionList:
                                                                  _transactionList!
                                                                      .transactions),
                                                        )))
                                        .then((_) {
                                      //_loadPageData();
                                    });
                                  },
                            child: Text(
                              "See all",
                              style: AppTheme.sectionSmallText,
                            ))
                  ],
                )),
            SizedBox(
                width: double.infinity,
                child: Container(
                    padding: const EdgeInsets.all(0),
                    child: _transactionList == null
                        ? buildTransactionShimmer(context)
                        : _transactionList == null ||
                                _transactionList!.transactions.isEmpty
                            ? Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(15, 20, 15, 20),
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        "Nothing to show here",
                                        style: AppTheme.subBodyNormal,
                                      )
                                    ]))
                            : listTransactionNew(context, state)))
          ],
        ));
  }

  Widget listTransactionNew(BuildContext context, HomeState state) {
    return Column(
      children: _transactionList!.transactions.take(4).map((transaction) {
        String actionLowercase = transaction.action?.toLowerCase() ?? "";
        Map<String, String> image = transaction.getMappedImage();
        return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  Navigator.push(
                          context,
                          (Theme.of(context).platform == TargetPlatform.iOS)
                              ? CupertinoPageRoute(
                                  builder: (context) => TransactionDetailScreen(
                                        transaction: transaction,
                                      ))
                              : MaterialPageRoute(
                                  builder: (context) => TransactionDetailScreen(
                                        transaction: transaction,
                                      )))
                      .then((_) {
                    //_loadPageData();
                  });
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(0),
                  title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 12,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: SizedBox(
                                child: image["type"] == "svg"
                                    ? Padding(
                                        padding: const EdgeInsets.all(10),
                                        child: SvgPicture.asset(
                                          image["path"] ??
                                              'lib/assets/interest.svg',
                                          height: 25.0,
                                          width: 25.0,
                                        ))
                                    : Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Image.asset(
                                          image["path"] ??
                                              'lib/assets/interest.png',
                                          height: 35.0,
                                          width: 35.0,
                                        ))),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Expanded(
                            flex: 60,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.displayName ?? "",
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTheme.bodyNormal,
                                  ),
                                  RichText(
                                    overflow: TextOverflow.ellipsis,
                                    text: TextSpan(
                                      style: DefaultTextStyle.of(context).style,
                                      children: <TextSpan>[
                                        TextSpan(
                                          text: formatDate(
                                              transaction.createdTime!),
                                          style: AppTheme.subBodyNormal,
                                        ),
                                        transaction.getMappedStatus() != ''
                                            ? TextSpan(
                                                text: " • ",
                                                style: AppTheme.subBodyNormal,
                                              )
                                            : const TextSpan(),
                                        transaction.getMappedStatus() != ''
                                            ? TextSpan(
                                                text: transaction
                                                    .getMappedStatus(),
                                                style: transaction
                                                            .getMappedStatus() ==
                                                        'Pending'
                                                    ? AppTheme.subBodyNormalBold
                                                    : AppTheme.subBodyNormal,
                                              )
                                            : const TextSpan(),
                                      ],
                                    ),
                                  ),
                                ])),
                        Expanded(
                            flex: 28,
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  // Buy and Sell Orders have two fields: total execution price and order amount
                                  // If its a buy and sell order, we only show total execution price once its available
                                  // If its anything else, we just show the order amount
                                  transaction.totalExecutionPrice == null &&
                                          (actionLowercase.contains('buy') ||
                                              actionLowercase.contains('sell'))
                                      ? const SizedBox.shrink()
                                      : Text(
                                          transaction.totalExecutionPrice ==
                                                  null
                                              ? formatAmount(
                                                  transaction.amount ?? "0.0",
                                                  direction:
                                                      transaction.direction)
                                              : formatAmount(
                                                  transaction
                                                          .totalExecutionPrice ??
                                                      "0.0",
                                                  direction:
                                                      transaction.direction),
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTheme.bodyNormal,
                                        )
                                ])),
                        // Expanded(
                        //     flex: 1,
                        //     child: Column(
                        //       mainAxisAlignment: MainAxisAlignment.center,
                        //       crossAxisAlignment: CrossAxisAlignment.end,
                        //       children: [
                        //         Icon(
                        //           Icons.keyboard_arrow_right_rounded,
                        //           color: AppTheme.actionButton,
                        //           size: 26,
                        //         )
                        //       ],
                        //     ))
                      ]),
                )));
      }).toList(),
    );
  }
}
