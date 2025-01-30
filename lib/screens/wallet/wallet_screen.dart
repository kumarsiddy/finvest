import 'dart:async';
import 'dart:io';

import 'package:bondgrid/bloc/plaid_bloc.dart';
import 'package:bondgrid/bloc/wallet_bloc.dart';
import 'package:bondgrid/components/account_failure_verification_popover.dart';
import 'package:bondgrid/components/account_pending_verification_popover.dart';
import 'package:bondgrid/components/account_verification_denied_popover.dart';
import 'package:bondgrid/components/bank_add_confirmation_popover.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/constants/shared_constants.dart';
import 'package:bondgrid/enums/payment_method_status.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method.dart';
import 'package:bondgrid/models/payment_method_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/wallet/transfer/deposit_screen.dart';
import 'package:bondgrid/screens/wallet/transfer/withdrawal_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen(
      {Key? key, required this.showNavBar, required this.scrollController})
      : super(key: key);

  final ValueNotifier<bool> showNavBar;
  final ScrollController scrollController;

  @override
  WalletScreenState createState() => WalletScreenState();
}

class WalletScreenState extends State<WalletScreen>
    with WidgetsBindingObserver {
  UserInfo? _userInfo;
  CashBalance? _portfolioValue;
  LinkConfiguration? _configuration;
  PaymentMethodList? _paymentMethodList;
  StreamSubscription? _refreshSubscription;

  bool _shouldListenToPlaidBloc = true;

  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  bool isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();

    keyboardVisibilityController.onChange.listen((bool visible) {
      if (mounted) {
        setState(() {
          isKeyboardVisible = visible;
        });
      }
    });

    WidgetsBinding.instance.addObserver(this);
    _loadPageData();
    _refreshSubscription = navigatorScreenStateKey
        .currentState!.refreshNotifier.onRefresh
        .listen((_) {
      _loadPageData(useCache: false);
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
    if (state == AppLifecycleState.resumed) {
      _loadPageData();
    }
  }

  void _loadPageData({bool useCache = true}) {
    // context.read<WalletBloc>().add(GetCashBalanceEvent());
    // context.read<WalletBloc>().add(GetPaymentMethodsEvent());
    context.read<WalletBloc>().add(LoadInitialDataEvent(useCache: useCache));
  }

  void showBankModalSheet(BuildContext context, PlaidBloc plaidBloc) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  title: Text('Link Bank Account',
                      style: AppTheme.bodyBold, textAlign: TextAlign.center),
                ),
                ListTile(
                  title: Text(
                      'Finvest uses Plaid to verify your bank account info,'
                      ' periodically check the balance to see if'
                      ' there\'s enough money to cover transactions, and'
                      ' as otherwise permitted under our Privacy Policy.'
                      '\n\nOnce you click Next, you will be redirected to the Plaid setup page, where you can securely enter your bank details. Plaid is used by millions of users to connect their financial information.'
                      '\n\nYou can turn off Finvest\'s Plaid connection to this'
                      ' bank by removing the bank account.',
                      textAlign: TextAlign.center,
                      style: AppTheme.subBodyNormal),
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: BlocBuilder<PlaidBloc, PlaidState>(
                      bloc: plaidBloc,
                      builder: (context, state) {
                        return CustomButton(
                          widthVal: 1,
                          buttonText: 'Next',
                          isLoading: state.status == PlaidStateStatus.loading,
                          onPressFunction:
                              state.status == PlaidStateStatus.loading
                                  ? null
                                  : () {
                                      context.read<PlaidBloc>().add(
                                          GetPlaidLinkTokenEvent(Platform.isIOS
                                              ? PLATFORM.IOS
                                              : PLATFORM.ANDROID));
                                    },
                        );
                      },
                    ))
              ],
            ));
      },
    );
  }

  void showPaymentMethodDeleteModalSheet(BuildContext context,
      PaymentMethod paymentMethod, WalletBloc walletBloc) {
    widget.showNavBar.value = false;
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      context: context,
      builder: (BuildContext context) {
        // If the keyboard is visible, use the keyboard's height as the bottom padding
        double bottomPadding =
            isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(10, 0, 10, bottomPadding),
                child: BlocBuilder<WalletBloc, WalletState>(
                  bloc: walletBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            ListTile(
                              title: Column(children: [
                                Text(
                                  "${paymentMethod.institutionName} ${paymentMethod.accountName}",
                                  style: AppTheme.bodyNormal,
                                  textAlign: TextAlign.center,
                                ),
                                Text(
                                  "···· ${paymentMethod.accountMask}",
                                  style: AppTheme.subBodyNormal,
                                  textAlign: TextAlign.center,
                                ),
                              ]),
                            ),
                            const Divider(),
                            TextButton(
                              onPressed: state is DeletePaymentLoadingState
                                  ? null
                                  : () {
                                      if (paymentMethod.id != null) {
                                        walletBloc.add(DeletePaymentMethodEvent(
                                            paymentMethod.id!));
                                      }
                                    },
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Text(
                                "Disconnect Bank",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView(
                          shrinkWrap: true,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: Text(
                                "Cancel",
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppTheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    ]);
                  },
                )));
      },
    ).then(
      (value) {
        widget.showNavBar.value = true;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletBloc, WalletState>(builder: (context, state) {
      return BlocListener<WalletBloc, WalletState>(
          listener: (context, state) {
            if (state.status == WalletStateStatus.failure) {
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is PaymentMethodSuccessState) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
              _paymentMethodList = state.paymentMethods;
            }

            if (state is GetCashBalanceSuccessState) {
              _portfolioValue = state.cashBalance;
            }

            if (state is LoadInitialDataSuccessState) {
              _userInfo = state.userInfo;
              _paymentMethodList = state.paymentMethods;
              _portfolioValue = state.cashBalance;
            }
          },
          child: BlocListener<PlaidBloc, PlaidState>(
              listener: (context, plaidState) {
                if (_shouldListenToPlaidBloc) {
                  if (plaidState.status == PlaidStateStatus.failure) {
                    EasyLoading.showToast(plaidState.errorMessage,
                        toastPosition: EasyLoadingToastPosition.bottom,
                        duration: const Duration(seconds: 5));
                  }

                  if (plaidState is GetPlaidLinkTokenSuccessState) {
                    _configuration =
                        LinkTokenConfiguration(token: plaidState.linkToken);
                    if (_configuration != null) {
                      PlaidLink.open(configuration: _configuration!);
                    }
                  }

                  if (plaidState is ExchangePlaidPublicTokenSuccessState) {
                    if (Navigator.canPop(context)) {
                      Navigator.pop(context);
                    }
                    showDialog(
                        barrierDismissible: false,
                        barrierColor: Colors.black.withOpacity(0.9),
                        context: context,
                        builder: (context) {
                          return const BankAddConfirmationPopover();
                        }).then((_) {
                      _loadPageData(useCache: false);
                    });
                  }
                }
              },
              child: AbsorbPointer(
                  absorbing: state.status == WalletStateStatus.loading,
                  child: SafeArea(
                      child: RefreshIndicator(
                          color: AppTheme.primary,
                          onRefresh: () async {
                            _loadPageData();
                          },
                          child: Scaffold(body: LayoutBuilder(builder:
                              (BuildContext context,
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
                                                headingCard(context, state),
                                                cashDetails(context, state),
                                                userAccounts(
                                                    context,
                                                    state,
                                                    BlocProvider.of<PlaidBloc>(
                                                        context)),
                                                Expanded(child: Container())
                                              ],
                                            )))));
                          })))))));
    });
  }

  Widget headingCard(BuildContext context, WalletState state) {
    return SizedBox(
        width: double.infinity,
        child: Padding(
            padding: const EdgeInsets.only(bottom: 20),
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
                        state is LoadInitialDataLoadingState
                            ? buildNumberShimmer(
                                context: context,
                                width: 120,
                                height: 30,
                                padding: const EdgeInsets.only(bottom: 10),
                                borderRadius: BorderRadius.circular(20))
                            : Text(
                                _portfolioValue != null &&
                                        _portfolioValue!.cashBalance != null
                                    ? formatAmount(
                                        _portfolioValue!.cashBalance!)
                                    : "",
                                style: AppTheme.numberTitleText),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                "Cash Balance",
                                textAlign: TextAlign.center,
                                style: AppTheme.numberSubText,
                              ),
                            ]),
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _userInfo != null &&
                                        (_userInfo!.verification.status ==
                                                VerificationStatus.SUCCESSFUL ||
                                            _userInfo!.verification.status ==
                                                VerificationStatus.PROCESSING)
                                    ? () {
                                        setState(() {
                                          _shouldListenToPlaidBloc = false;
                                        });
                                        widget.showNavBar.value =
                                            false; // Hide the bottom navigation bar
                                        Navigator.push(
                                                context,
                                                (Theme.of(context).platform ==
                                                        TargetPlatform.iOS)
                                                    ? CupertinoPageRoute(
                                                        builder: (context) =>
                                                            const DepositScreen())
                                                    : MaterialPageRoute(
                                                        builder: (context) =>
                                                            const DepositScreen()))
                                            .then((_) {
                                          widget.showNavBar.value = true;
                                          EasyLoading.dismiss();
                                          setState(() {
                                            _shouldListenToPlaidBloc = true;
                                          }); // Show the bottom navigation bar
                                          _loadPageData();
                                        });
                                      }
                                    : _userInfo != null &&
                                            _userInfo!.verification.status ==
                                                VerificationStatus.NOT_STARTED
                                        ? () {
                                            showDialog(
                                                barrierDismissible: false,
                                                barrierColor: Colors.black
                                                    .withOpacity(0.9),
                                                context: context,
                                                builder: (context) {
                                                  return const AccountPendingVerificationPopover();
                                                });
                                          }
                                        : _userInfo != null &&
                                                _userInfo!
                                                        .verification.status ==
                                                    VerificationStatus.FAILED
                                            ? () {
                                                showDialog(
                                                    barrierDismissible: false,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.9),
                                                    context: context,
                                                    builder: (context) {
                                                      return const AccountFailureVerificationPopover();
                                                    });
                                              }
                                            : _userInfo != null &&
                                                    _userInfo!.verification
                                                            .status ==
                                                        VerificationStatus
                                                            .DENIED
                                                ? () {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        barrierColor: Colors
                                                            .black
                                                            .withOpacity(0.9),
                                                        context: context,
                                                        builder: (context) {
                                                          return const AccountVerificationDeniedPopover();
                                                        });
                                                  }
                                                : () {},
                                style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.resolveWith<double>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.pressed)) return 0;
                                      return 0;
                                    },
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      AppTheme.primary),
                                  shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                  minimumSize: MaterialStateProperty.all(
                                      const Size(120, 40)),
                                ),
                                child: Text(
                                  "Deposit",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: AppTheme.nearlyWhite),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              ElevatedButton(
                                onPressed: _userInfo != null &&
                                        (_userInfo!.verification.status ==
                                                VerificationStatus.SUCCESSFUL ||
                                            _userInfo!.verification.status ==
                                                VerificationStatus.PROCESSING)
                                    ? () {
                                        setState(() {
                                          _shouldListenToPlaidBloc = false;
                                        });
                                        widget.showNavBar.value =
                                            false; // Hide the bottom navigation bar
                                        Navigator.push(
                                                context,
                                                (Theme.of(context).platform ==
                                                        TargetPlatform.iOS)
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
                                          setState(() {
                                            _shouldListenToPlaidBloc = true;
                                          });
                                          _loadPageData();
                                        });
                                      }
                                    : _userInfo != null &&
                                            _userInfo!.verification.status ==
                                                VerificationStatus.NOT_STARTED
                                        ? () {
                                            showDialog(
                                                barrierDismissible: false,
                                                barrierColor: Colors.black
                                                    .withOpacity(0.9),
                                                context: context,
                                                builder: (context) {
                                                  return const AccountPendingVerificationPopover();
                                                });
                                          }
                                        : _userInfo != null &&
                                                _userInfo!
                                                        .verification.status ==
                                                    VerificationStatus.FAILED
                                            ? () {
                                                showDialog(
                                                    barrierDismissible: false,
                                                    barrierColor: Colors.black
                                                        .withOpacity(0.9),
                                                    context: context,
                                                    builder: (context) {
                                                      return const AccountFailureVerificationPopover();
                                                    });
                                              }
                                            : _userInfo != null &&
                                                    _userInfo!.verification
                                                            .status ==
                                                        VerificationStatus
                                                            .DENIED
                                                ? () {
                                                    showDialog(
                                                        barrierDismissible:
                                                            false,
                                                        barrierColor: Colors
                                                            .black
                                                            .withOpacity(0.9),
                                                        context: context,
                                                        builder: (context) {
                                                          return const AccountVerificationDeniedPopover();
                                                        });
                                                  }
                                                : () {},
                                style: ElevatedButton.styleFrom(
                                    elevation: 0,
                                    backgroundColor: AppTheme.backgroundColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    side: const BorderSide(
                                        width: 1, color: AppTheme.primary),
                                    minimumSize: const Size(120, 40)),
                                child: Text(
                                  "Withdraw",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: AppTheme.primary),
                                ),
                              ),
                            ])
                      ],
                    )))));
  }

  Widget interestRateCard() {
    return Column(children: [
      Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Card(
              elevation: 0,
              color: AppTheme.backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
                side: BorderSide(
                    width: 1, color: Colors.grey[600]!.withOpacity(0.2)),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      //flex: 7,
                      child: Text(
                        "Current APY on Cash",
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyNormal,
                      ),
                    ),
                    Flexible(
                      //flex: 3,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text("${_portfolioValue!.cashInterestRate}%",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                ),
              ))),
      //const Divider(),
    ]);
  }

  Widget cashDetails(BuildContext context, WalletState state) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: GestureDetector(
                              onTap: () {
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
                                    return NotificationListener<
                                            OverscrollIndicatorNotification>(
                                        onNotification: (overscroll) {
                                          overscroll.disallowIndicator();
                                          return true;
                                        },
                                        child: ListView(
                                          shrinkWrap: true,
                                          children: [
                                            ListTile(
                                              title: Text("Cash Balance",
                                                  style: AppTheme.bodyBold,
                                                  textAlign: TextAlign.center),
                                            ),
                                            ListTile(
                                              title: Text(
                                                  "Reflects the aggregate amount of cash in your account."
                                                  " It includes available funds for investment, unsettled"
                                                  " cash from recent trades, and any pending transfers or withdrawals.",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      AppTheme.subBodyNormal),
                                            ),
                                            ListTile(
                                              title: Text("Interest on Cash",
                                                  style: AppTheme.bodyBold,
                                                  textAlign: TextAlign.center),
                                            ),
                                            ListTile(
                                              title: Text(
                                                  "Your cash balance isn't just sitting idle; it's working"
                                                  " for you. The cash in your account earns interest, which"
                                                  " is calculated daily and paid monthly, helping your balance"
                                                  " grow over time.",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      AppTheme.subBodyNormal),
                                            ),
                                            ListTile(
                                              title: Text("Buying Power",
                                                  style: AppTheme.bodyBold,
                                                  textAlign: TextAlign.center),
                                            ),
                                            ListTile(
                                              title: Text(
                                                  "This represents the total amount of money available"
                                                  " for you to make investments. It is calculated based"
                                                  " on your total cash balance, minus any existing holds"
                                                  " for pending trades or transactions.",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      AppTheme.subBodyNormal),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.all(20),
                                              child: CustomButton(
                                                widthVal: 1,
                                                buttonText: 'Got it',
                                                onPressFunction: () =>
                                                    Navigator.pop(context),
                                              ),
                                            ),
                                          ],
                                        ));
                                  },
                                );
                              },
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Details",
                                      style: AppTheme.sectionTitle,
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.grey,
                                      size: 20,
                                    ),
                                  ]))),
                      _portfolioValue != null &&
                              _portfolioValue!.cashInterestRate != null
                          ? Flexible(
                              child: Text(
                              "${_portfolioValue!.cashInterestRate}%"
                              " APY on Cash",
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: Colors.green),
                              textAlign: TextAlign.center,
                            ))
                          : const SizedBox.shrink()
                    ])),
            Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Cash Balance",
                      style: AppTheme.bodyNormalGrey,
                    ),
                    state is LoadInitialDataLoadingState
                        ? buildNumberShimmer(
                            context: context,
                            width: 70,
                            height: 15,
                            padding: const EdgeInsets.only(bottom: 0),
                            borderRadius: BorderRadius.circular(5))
                        : Text(
                            _portfolioValue != null &&
                                    _portfolioValue!.cashBalance != null
                                ? formatAmount(_portfolioValue!.cashBalance!)
                                : "",
                            style: AppTheme.bodyNormal,
                          ),
                  ],
                )),
            _portfolioValue != null &&
                    _portfolioValue!.pendingBuyOrderAmount != null &&
                    !isZero(_portfolioValue!.pendingBuyOrderAmount!)
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pending Orders",
                          style: AppTheme.bodyNormalGrey,
                        ),
                        Text(
                          _portfolioValue != null &&
                                  _portfolioValue!.pendingBuyOrderAmount != null
                              ? "-${formatAmount(_portfolioValue!.pendingBuyOrderAmount!)}"
                              : "",
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            _portfolioValue != null &&
                    _portfolioValue!.pendingWithdrawalAmount != null &&
                    !isZero(_portfolioValue!.pendingWithdrawalAmount!)
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Pending Withdrawal",
                          style: AppTheme.bodyNormalGrey,
                        ),
                        Text(
                          _portfolioValue != null &&
                                  _portfolioValue!.pendingWithdrawalAmount !=
                                      null
                              ? "-${formatAmount(_portfolioValue!.pendingWithdrawalAmount!)}"
                              : "",
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Buying Power",
                  style: AppTheme.bodyNormalGrey,
                ),
                state is LoadInitialDataLoadingState
                    ? buildNumberShimmer(
                        context: context,
                        width: 70,
                        height: 15,
                        padding: const EdgeInsets.only(bottom: 0),
                        borderRadius: BorderRadius.circular(5))
                    : Text(
                        _portfolioValue != null &&
                                _portfolioValue!.buyingPower != null
                            ? formatAmount(_portfolioValue!.buyingPower!)
                            : "",
                        style: AppTheme.bodyNormal,
                      ),
              ],
            )
          ],
        ));
  }

  Widget userAccounts(
      BuildContext context, WalletState state, PlaidBloc plaidBloc) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 15),
            child: Text(
              "Linked Accounts",
              style: AppTheme.sectionTitle,
            )),
        SizedBox(
            width: double.infinity,
            child: Container(
                padding: const EdgeInsets.all(0),
                child: listAccountsNew(context, state, plaidBloc)))
      ],
    );
  }

  Widget listAccountsNew(
      BuildContext context, WalletState state, PlaidBloc plaidBloc) {
    final paymentMethodsList =
        _paymentMethodList?.paymentMethods ?? <PaymentMethod>[];

    List<Widget> accountList = paymentMethodsList.isEmpty
        ? [const SizedBox.shrink()]
        : paymentMethodsList.map((paymentMethod) {
            return Column(children: [
              Padding(
                padding: const EdgeInsets.all(0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    showPaymentMethodDeleteModalSheet(context, paymentMethod,
                        BlocProvider.of<WalletBloc>(context));
                  },
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: SvgPicture.asset(
                              'lib/assets/bank.svg',
                              height: 25.0,
                              width: 25.0,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${paymentMethod.institutionName} ${paymentMethod.accountName}",
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.bodyNormal,
                                ),
                                Text(
                                  "···· ${paymentMethod.accountMask}",
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.subBodyNormal,
                                ),
                              ]),
                        ),
                        const SizedBox(width: 20),
                        if (paymentMethod.status != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Icon(
                                Icons.circle_rounded,
                                size: 10,
                                color: paymentMethod.status ==
                                            PaymentMethodStatus.ACTIVE ||
                                        paymentMethod.status ==
                                            PaymentMethodStatus.PENDING
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                paymentMethod.status!.displayValue,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  color: paymentMethod.status ==
                                              PaymentMethodStatus.ACTIVE ||
                                          paymentMethod.status ==
                                              PaymentMethodStatus.PENDING
                                      ? Colors.green
                                      : Colors.red,
                                ),
                                textAlign: TextAlign.center,
                              )
                            ],
                          )
                      ],
                    ),
                  ),
                ),
              ),
            ]);
          }).toList();

    Widget newAccount = Column(children: [
      Padding(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          child: InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              showBankModalSheet(context, plaidBloc);
            },
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.add_circle_outline_rounded,
                    color: AppTheme.primary,
                    size: 26,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Add a new bank account",
                    style: AppTheme.bodyNormal,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ))
    ]);

    accountList.add(newAccount);

    // bool hasPendingPaymentMethod = paymentMethodsList.any(
    //     (paymentMethod) => paymentMethod.status == PaymentMethodStatus.PENDING);

    return Column(children: [
      Column(children: accountList),
      //if (hasPendingPaymentMethod) statusCard(context),
    ]);
  }

  Widget listAccounts(
      BuildContext context, WalletState state, PlaidBloc plaidBloc) {
    final paymentMethodsList =
        _paymentMethodList?.paymentMethods ?? <PaymentMethod>[];

    List<Widget> accountList = paymentMethodsList.isEmpty
        ? [const SizedBox.shrink()]
        : paymentMethodsList.map((paymentMethod) {
            return SizedBox(
                width: 150,
                height: 250,
                child: Card(
                  elevation: 0,
                  color: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: BorderSide(
                          width: 1, color: Colors.grey[600]!.withOpacity(0.2))),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: InkWell(
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () {
                        showPaymentMethodDeleteModalSheet(
                            context,
                            paymentMethod,
                            BlocProvider.of<WalletBloc>(context));
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: null,
                              style: ButtonStyle(
                                  elevation:
                                      MaterialStateProperty.resolveWith<double>(
                                    (Set<MaterialState> states) {
                                      if (states.contains(
                                          MaterialState.pressed)) return 0;
                                      return 0;
                                    },
                                  ),
                                  backgroundColor: MaterialStateProperty.all(
                                      AppTheme.primary.withOpacity(0.1)),
                                  shape: MaterialStateProperty.all(
                                      const CircleBorder()),
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.all(15))),
                              child: SvgPicture.asset('lib/assets/bank.svg'),
                            ),
                            Text(
                              "${paymentMethod.institutionName} ${paymentMethod.accountName}",
                              style: AppTheme.bodyNormal,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              "···· ${paymentMethod.accountMask}",
                              style: AppTheme.subBodyNormal,
                              textAlign: TextAlign.center,
                            ),
                            paymentMethod.status != null
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                        Icon(
                                          Icons.circle_rounded,
                                          size: 10,
                                          color: paymentMethod.status ==
                                                  PaymentMethodStatus.ACTIVE
                                              ? Colors.green
                                              : paymentMethod.status ==
                                                      PaymentMethodStatus
                                                          .PENDING
                                                  ? AppTheme.primary
                                                  : Colors.red,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          paymentMethod.status!.displayValue,
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 14,
                                              color: paymentMethod.status ==
                                                      PaymentMethodStatus.ACTIVE
                                                  ? Colors.green
                                                  : paymentMethod.status ==
                                                          PaymentMethodStatus
                                                              .PENDING
                                                      ? AppTheme.primary
                                                      : Colors.red),
                                          textAlign: TextAlign.center,
                                        )
                                      ])
                                : const SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ));
          }).toList();

    Widget newAccount = SizedBox(
      width: 150,
      height: 250,
      child: Card(
        elevation: 0,
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(width: 1, color: Colors.grey[600]!.withOpacity(0.2)),
        ),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            showBankModalSheet(context, plaidBloc);
          },
          child: ListTile(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                      elevation: MaterialStateProperty.resolveWith<double>(
                        (Set<MaterialState> states) {
                          if (states.contains(MaterialState.pressed)) return 0;
                          return 0;
                        },
                      ),
                      backgroundColor:
                          MaterialStateProperty.all(AppTheme.primary),
                      shape: MaterialStateProperty.all(const CircleBorder()),
                      padding:
                          MaterialStateProperty.all(const EdgeInsets.all(15))),
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.nearlyWhite,
                  ),
                ),
                // Icon(Icons.add_circle_rounded,
                //     color: Colors.grey[600]!.withOpacity(0.6), size: 60),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  "Add a new bank account",
                  style: AppTheme.bodyNormal,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    accountList.add(newAccount);

    // Check if any payment method is pending
    // bool hasPendingPaymentMethod = paymentMethodsList.any(
    //     (paymentMethod) => paymentMethod.status == PaymentMethodStatus.PENDING);

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: accountList),
              )),
          //if (hasPendingPaymentMethod) statusCard(context),
        ]);
  }

  Widget statusCard(BuildContext context) {
    return Card(
        elevation: 0,
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: Text(
                  'Your bank account verification is pending. In most cases, the review'
                  ' takes less than 5 minutes though in some cases it might take 1-2 business days.',
                  style: AppTheme.disclosureText,
                  textAlign: TextAlign.center,
                ))));
  }
}
