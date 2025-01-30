import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/components/sell_confirmation_popover.dart';
import 'package:bondgrid/components/share_box.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/enums/holding_status.dart';
import 'package:bondgrid/models/holding.dart';
import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/transactions/transaction_detail_screen.dart';
import 'package:bondgrid/screens/transactions/transaction_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_svg/svg.dart';

class HoldingDetailScreen extends StatefulWidget {
  final String holdingId;

  const HoldingDetailScreen({super.key, required this.holdingId});

  @override
  HoldingDetailScreenState createState() => HoldingDetailScreenState();
}

class HoldingDetailScreenState extends State<HoldingDetailScreen>
    with WidgetsBindingObserver {
  Holding? _holding;
  int stepperIndex = 0;
  double estimatedProceeds = 0.0;
  bool? _autoRoll;

  TextEditingController sharesController = TextEditingController();
  var filteredPendingTransactions = <Transaction>[];
  var filteredNonPendingTransactions = <Transaction>[];

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

  void _loadPageData({bool useCache = true}) {
    context
        .read<HomeBloc>()
        .add(GetHoldingByIdEvent(widget.holdingId, useCache: useCache));
  }

  bool _isSellButtonEnabled(String input) {
    int? inputShares = int.tryParse(input);
    return inputShares != null &&
        inputShares > 0 &&
        inputShares <= (_holding!.availableSellShares ?? 0);
  }

  void updateHoldingData(Holding holding) {
    _holding = holding;
    _autoRoll = _holding?.autoRoll;
    if (_holding != null) {
      filteredPendingTransactions = _holding!.trades.transactions
          .where((transaction) => transaction.getMappedStatus() == 'Pending')
          .toList();

      filteredNonPendingTransactions = _holding!.trades.transactions
          .where((transaction) => transaction.getMappedStatus() != 'Pending')
          .toList();
    }
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

            if (state is GetHoldingByIdSuccessState) {
              updateHoldingData(state.holding);
            }

            if (state is CreateSellSuccessState) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                if (_holding != null && _holding!.maturityAmount != null) {
                  updateHoldingData(state.holding);
                  showDialog(
                      barrierDismissible: false,
                      barrierColor: Colors.black.withOpacity(0.9),
                      context: context,
                      builder: (context) {
                        return SellConfirmationPopover(
                          sellAmount: state.amount,
                        );
                      }).then((_) {
                    // updateHoldingData(state.holding);
                    //_loadPageData();
                  });
                }
              }
            }

            if (state is ToggleAutoRollSuccessState) {
              _autoRoll = state.autoRollEnabled;
            }
          },
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.backgroundColor,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0,
              leading: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.keyboard_arrow_left_rounded,
                  color: AppTheme.actionButton,
                  size: 22,
                ),
              ),
            ),
            body: state is GetHoldingByIdLoadingState
                ? buildFullPageShimmer(context)
                : _holding == null
                    ? const SizedBox.shrink()
                    : AbsorbPointer(
                        absorbing: state.status == HomeStateStatus.loading,
                        child: Stack(children: [
                          SingleChildScrollView(
                              child: Padding(
                                  padding: EdgeInsets.fromLTRB(
                                      MediaQuery.of(context).size.width * 0.02 +
                                          10,
                                      0,
                                      MediaQuery.of(context).size.width * 0.02 +
                                          10,
                                      0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      headingCard(context),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      _holding == null
                                          ? const SizedBox.shrink()
                                          : maturityProgressCard(context),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      // const Divider(),
                                      // const SizedBox(
                                      //   height: 10,
                                      // ),
                                      filteredPendingTransactions.isNotEmpty
                                          ? Column(children: [
                                              recentTransactions(
                                                  context,
                                                  state,
                                                  "Pending Trades",
                                                  filteredPendingTransactions),
                                              const SizedBox(
                                                height: 20,
                                              )
                                            ])
                                          : const SizedBox.shrink(),
                                      bodyCard(context),
                                      // const SizedBox(
                                      //   height: 10,
                                      // ),
                                      // const Divider(),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      _autoRoll != null
                                          ? autoRollHoldingToggle(
                                              context,
                                              BlocProvider.of<HomeBloc>(
                                                  context))
                                          : const SizedBox.shrink(),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      filteredNonPendingTransactions.isNotEmpty
                                          ? recentTransactions(
                                              context,
                                              state,
                                              "Trade History",
                                              filteredNonPendingTransactions)
                                          : const SizedBox.shrink(),
                                      const SizedBox(height: 120),
                                    ],
                                  ))),
                          sellButton(context)
                        ])),
          ));
    });
  }

  Widget headingCard(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
                onTap: () {
                  showInfoModal(
                    context: context,
                    title: 'Current Market Value',
                    subtext:
                        'This is the current market value of your holding. If you sell'
                        ' your Treasury before maturity, this is the estimated amount you'
                        ' will receive at sale.\n\n'
                        'This value fluctuates based on changes in interest rates. When interest'
                        ' rates rise, bond prices tend to fall, and conversely, when interest rates decrease,'
                        ' bond prices typically increase.\n\n'
                        'If you maintain your Treasury holding until the maturity date,'
                        ' you will receive the full maturity amount, regardless of'
                        ' market value fluctuations.',
                  );
                },
                child: Row(children: [
                  Text(
                    _holding != null && _holding!.currentValue != null
                        ? formatAmount(
                            _holding!.currentValue?.toString() ?? "0.0")
                        : "\$0.0",
                    style: AppTheme.numberSmallText,
                  ),
                  const SizedBox(width: 5),
                  const Icon(
                    Icons.info_outline,
                    color: AppTheme.grey,
                    size: 20,
                  ),
                ])),
            Text(
              _holding != null && _holding!.duration != null
                  ? _holding!.duration!
                  : "",
              style: AppTheme.bodyNormal,
            ),
          ],
        ));
  }

  Widget maturityProgressCard(BuildContext context) {
    if (_holding!.maturityDate == null || _holding!.purchaseDate == null) {
      return SizedBox(
        width: double.infinity,
        child: Card(
          elevation: AppTheme.cardElevation,
          color: AppTheme.nearlyWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: Center(
              child: Text(
                "Maturity date or purchase date not available",
                style: AppTheme.subBodyNormal,
              ),
            ),
          ),
        ),
      );
    }

    // Convert maturityDate string to DateTime
    DateTime maturityDate = DateTime.parse(_holding!.maturityDate!);
    DateTime purchaseDate = DateTime.parse(_holding!.purchaseDate!);

    DateTime now = DateTime.now();
    Duration totalDuration = maturityDate
        .difference(purchaseDate); // Adjust purchaseDate if it's also a string
    Duration elapsedDuration = now
        .difference(purchaseDate); // Adjust purchaseDate if it's also a string
    double progress = elapsedDuration.inSeconds / totalDuration.inSeconds;
    Duration timeLeft = maturityDate.difference(now);

    int daysLeft = timeLeft.inDays;
    int monthsLeft = daysLeft ~/ 30;
    int remainingDays = daysLeft % 30;

    String timeLeftString;
    if (daysLeft > 30) {
      if (remainingDays > 0) {
        timeLeftString =
            '$monthsLeft month${monthsLeft > 1 ? 's' : ''} and\n$remainingDays day${remainingDays > 1 ? 's' : ''} left';
      } else {
        timeLeftString = '$monthsLeft month${monthsLeft > 1 ? 's' : ''} left';
      }
    } else {
      timeLeftString = '$daysLeft day${daysLeft > 1 ? 's' : ''} left';
    }

    return SizedBox(
        width: double.infinity,
        child: Card(
            elevation: AppTheme.cardElevation,
            color: AppTheme.nearlyWhite,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Maturity Progress",
                          style: AppTheme.subBodyNormal,
                        ),
                        const SizedBox(
                          width: 15,
                        ),
                        Flexible(
                          child: RichText(
                            textAlign: TextAlign.end,
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <InlineSpan>[
                                const WidgetSpan(
                                  child: Icon(Icons.access_time_rounded,
                                      color: AppTheme.primary, size: 20),
                                  alignment: PlaceholderAlignment.middle,
                                ),
                                TextSpan(
                                  text: " $timeLeftString",
                                  style: AppTheme.subBodyNormal,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                    ),
                  ],
                ))));
  }

  Widget bodyCard(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Details', style: AppTheme.sectionTitle),
            const SizedBox(
              height: 10,
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceAround,
            //   children: [
            //     Flexible(
            //       child: Column(
            //         children: [
            //           Text(
            //             "Shares",
            //             style: AppTheme.subBodyNormal,
            //           ),
            //           Text(
            //             formatNumberShares(_holding!.numberShares),
            //             style: AppTheme.bodyNormal,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ],
            //       ),
            //     ),
            //     Flexible(
            //       child: Column(
            //         children: [
            //           Text(
            //             "Market Value",
            //             style: AppTheme.subBodyNormal,
            //           ),
            //           Text(
            //             formatAmount(
            //                 _holding!.currentValue?.toString() ?? "0.0"),
            //             style: AppTheme.bodyNormal,
            //             overflow: TextOverflow.ellipsis,
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),
            // const SizedBox(
            //   height: 10,
            // ),
            // const Divider(),
            // const SizedBox(
            //   height: 10,
            // ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Shares",
                  style: AppTheme.subBodyDark,
                ),
                Text(
                  _holding != null && _holding!.numberShares != null
                      ? formatNumberShares(_holding!.numberShares)
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Asset Identifier",
                  style: AppTheme.subBodyDark,
                ),
                Text(
                  _holding != null && _holding!.assetSymbol != null
                      ? _holding!.assetSymbol!
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Maturity Date",
                  style: AppTheme.subBodyDark,
                ),
                Text(
                  _holding != null && _holding!.maturityDate != null
                      ? formatDate(_holding!.maturityDate!)
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Purchase Amount",
                  style: AppTheme.subBodyDark,
                ),
                Text(
                  _holding != null && _holding!.purchaseAmount != null
                      ? formatAmount(
                          _holding!.purchaseAmount?.toString() ?? "0.0")
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                    onTap: () {
                      showInfoModal(
                        context: context,
                        title: 'Yield to Maturity',
                        subtext:
                            'This is a weighted average of the yield to maturity across all'
                            ' the trades you have made for this treasury bill.',
                      );
                    },
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Yield to Maturity",
                            style: AppTheme.subBodyDark,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.grey,
                            size: 16,
                          ),
                        ])),
                Text(
                  _holding != null && _holding!.yieldToMaturity != null
                      ? "${_holding!.yieldToMaturity!}%"
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Value at Maturity",
                  style: AppTheme.subBodyDark,
                ),
                Text(
                  _holding != null && _holding!.maturityAmount != null
                      ? formatAmount(
                          _holding!.maturityAmount?.toString() ?? "0.0")
                      : "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            ),
          ],
        ));
  }

  Widget autoRollHoldingToggle(BuildContext context, HomeBloc homeBloc) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
            onTap: () {
              showInfoModal(
                context: context,
                title: 'Auto Roll',
                subtext:
                    ' Auto Roll allows you to automatically reinvest the proceeds from this'
                    ' US Treasury Bill at maturity into a new position of the same duration to keep your earnings going.',
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Auto Roll ',
                  style: AppTheme.bodyBold,
                ),
                const Icon(
                  Icons.info_outline,
                  color: AppTheme.grey,
                  size: 18,
                ),
              ],
            )),
        SizedBox(
          width: 50,
          height: 40,
          child: Switch(
            activeColor: AppTheme.primary,
            value: _autoRoll!,
            onChanged: _holding != null && _holding!.id != null
                ? (bool value) {
                    homeBloc.add(ToggleAutoRollEvent(_holding!.id!, value));
                    setState(() {
                      _autoRoll = value;
                    });
                  }
                : null,
          ),
        )
      ],
    );
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
                  'Your sell order has been initiated. Orders are processed on'
                  ' weekdays during regular bond market trading hours (9:30 AM - 4:00 PM EST, Monday - Friday).',
                  style: AppTheme.disclosureText,
                  textAlign: TextAlign.center,
                ))));
  }

  Widget availableToSellCard(BuildContext context) {
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
                  'Available Shares to Sell: ${_holding != null ? formatNumberShares(_holding!.availableSellShares) : ""}',
                  style: AppTheme.disclosureText,
                  textAlign: TextAlign.center,
                ))));
  }

  Widget sellButton(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // _holding!.pendingSellShares != null &&
                  //         _holding!.pendingSellShares! > 0
                  //     ? statusCard(context)
                  //     : const SizedBox.shrink(),
                  // _holding!.availableSellShares != null &&
                  //         _holding!.availableSellShares! > 0
                  //     ? availableToSellCard(context)
                  //     : const SizedBox.shrink(),
                  CustomButton(
                    widthVal: 1,
                    buttonText: 'Sell',
                    onPressFunction: _holding != null &&
                            _holding!.status == HoldingStatus.ACTIVE
                        ? () {
                            confirmationModal(
                                context, BlocProvider.of<HomeBloc>(context));
                          }
                        : null,
                  ),
                ])));
  }

  void confirmationModal(BuildContext context, HomeBloc homeBloc) {
    FocusScope.of(context).unfocus();
    showModalBottomSheet(
        //isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return WillPopScope(onWillPop: () async {
            return homeBloc.state is! CreateSellLoadingState;
          }, child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: getModalContent(
                        stepperIndex, context, setState, homeBloc),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(1, 0),
                          end: const Offset(0, 0),
                        ).animate(animation),
                        child: child,
                      );
                    },
                  ));
            },
          ));
        }).then((value) {
      setState(() {
        stepperIndex = 0;
      });
    });
  }

  Widget getModalContent(int index, BuildContext context, StateSetter setState,
      HomeBloc homeBloc) {
    switch (index) {
      case 0:
        return reviewModal(context, setState, homeBloc);
      case 1:
        return sellModal(context, setState, homeBloc);
      case 2:
        return sellReviewModal(context, setState, homeBloc);
      default:
        return reviewModal(context, setState, homeBloc);
    }
  }

  Widget reviewModal(
      BuildContext context, StateSetter modalSetState, HomeBloc homeBloc) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text(
            'Are you sure you want to sell?',
            style: AppTheme.bodyBold,
            textAlign: TextAlign.center,
          ),
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text(
            'You are on track to earn ${_holding != null && _holding!.yieldToMaturity != null ? "${_holding!.yieldToMaturity!}%" : "0.00%"}'
            ' annualized yield if you hold this T-Bill to maturity.',
            style: AppTheme.subBodyNormal,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        widthVal: 2.3,
                        buttonText: 'Cancel',
                        primaryColor: AppTheme.backgroundColor,
                        borderColor: AppTheme.primary,
                        textColor: AppTheme.primary,
                        onPressFunction: () {
                          Navigator.pop(context);
                        },
                      ),
                      CustomButton(
                        widthVal: 2.3,
                        buttonText: 'Continue',
                        onPressFunction: () {
                          sharesController.text = "";
                          estimatedProceeds = 0.0;
                          modalSetState(() {
                            stepperIndex = 1;
                          });
                        },
                      )
                    ]),
              ],
            ))
      ],
    );
  }

  Widget sellModal(
      BuildContext context, StateSetter modalSetState, HomeBloc homeBloc) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          title: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              'Sell ${_holding!.duration}',
              style: AppTheme.bodyBold,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              'Available Shares: ${formatNumberShares(_holding!.availableSellShares ?? 0)}',
              style: AppTheme.disclosureText,
              textAlign: TextAlign.center,
            )
          ]),
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number of Shares',
                      style: AppTheme.subBodyNormal,
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                        child: ShareBox(
                            controller: sharesController,
                            enabled: true,
                            autofocus: true,
                            label: "0"))
                  ],
                ),
                // const SizedBox(
                //   height: 10,
                // ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          showInfoModal(
                            context: context,
                            title: 'Estimated Share Value',
                            subtext:
                                'This is the current estimated value of your share. If you sell'
                                ' your treasury before maturity, this is the estimated amount you'
                                ' will receive at sale.',
                          );
                        },
                        child: Row(children: [
                          Text(
                            'Share Price',
                            style: AppTheme.subBodyNormal,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.grey,
                            size: 14,
                          ),
                        ])),
                    Expanded(
                        child: Text(
                      formatAmount(_holding!.averagePricePerShare.toString()),
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.right,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Proceeds',
                      style: AppTheme.subBodyNormal,
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: sharesController,
                        builder: (context, value, child) {
                          if (value.text.isNotEmpty &&
                              _holding!.averagePricePerShare != null) {
                            int inputShares = int.tryParse(value.text) ?? 0;
                            estimatedProceeds =
                                inputShares * _holding!.averagePricePerShare!;
                          }
                          return Text(
                            formatAmount(estimatedProceeds.toString()),
                            style: AppTheme.bodyNormal,
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                  ],
                )
              ],
            )),
        ValueListenableBuilder(
          valueListenable: sharesController,
          builder: (context, TextEditingValue value, _) {
            bool isButtonEnabled = _isSellButtonEnabled(value.text);
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
              child: CustomButton(
                widthVal: 1,
                buttonText: 'Review',
                onPressFunction: isButtonEnabled
                    ? () {
                        modalSetState(() {
                          stepperIndex = 2;
                        });
                      }
                    : null,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget sellReviewModal(
      BuildContext context, StateSetter modalSetState, HomeBloc homeBloc) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return ListView(
      shrinkWrap: true,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: IconButton(
                  onPressed: () {
                    modalSetState(() {
                      stepperIndex = 1;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left_rounded,
                    color: AppTheme.actionButton,
                    size: 22,
                  ),
                )),
            Text(
              'Review and Sell',
              style: AppTheme.bodyBold,
              textAlign: TextAlign.center,
            ),
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
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Number of Shares',
                      style: AppTheme.subBodyNormal,
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      sharesController.text,
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                        onTap: () {
                          showInfoModal(
                            context: context,
                            title: 'Estimated Share Value',
                            subtext:
                                'This is the current estimated value of your share. If you sell'
                                ' your treasury before maturity, this is the estimated amount you'
                                ' will receive at sale.',
                          );
                        },
                        child: Row(children: [
                          Text(
                            'Share Price',
                            style: AppTheme.subBodyNormal,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.info_outline,
                            color: AppTheme.grey,
                            size: 14,
                          ),
                        ])),
                    Expanded(
                        child: Text(
                      formatAmount(_holding!.averagePricePerShare.toString()),
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.right,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Estimated Proceeds',
                      style: AppTheme.subBodyNormal,
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                        child: Text(
                      formatAmount(estimatedProceeds.toString()),
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.right,
                    )),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  'Orders are processed on weekdays during regular bond market trading'
                  ' hours (9:30 AM - 4:00 PM EST, Monday - Friday).',
                  style: AppTheme.disclosureText,
                  textAlign: TextAlign.center,
                )
              ],
            )),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            child: BlocBuilder<HomeBloc, HomeState>(
              bloc: homeBloc,
              builder: ((context, state) {
                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Confirm',
                  isLoading: state is CreateSellLoadingState,
                  onPressFunction: state is CreateSellLoadingState
                      ? null
                      : () {
                          homeBloc.add(CreateSellEvent(
                              _holding!.id!,
                              sharesController.text,
                              _holding!.assetSymbol!,
                              _holding!.duration!));
                        },
                );
              }),
            )),
      ],
    );
  }

  Widget recentTransactions(BuildContext context, HomeState state,
      String headingText, Iterable<Transaction> transactions) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  headingText,
                  style: AppTheme.sectionTitle,
                ),
                _holding != null && _holding!.trades.transactions.isEmpty
                    ? const SizedBox.shrink()
                    : Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 10),
                          height: 1,
                          color: AppTheme.secondary.withOpacity(0.1),
                        ),
                      ),
                _holding != null && _holding!.trades.transactions.isEmpty
                    ? const SizedBox.shrink()
                    : TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.notWhite,
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: TransactionScreen(
                                              transactionList:
                                                  transactions.toList(),
                                              headingText: headingText,
                                              onlyTrades: true,
                                            ),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: TransactionScreen(
                                              transactionList:
                                                  transactions.toList(),
                                              headingText: headingText,
                                              onlyTrades: true,
                                            ),
                                          )));
                        },
                        child: Text(
                          "See all",
                          style: AppTheme.sectionSmallText,
                        ))
              ],
            )),
        _holding != null && _holding!.trades.transactions.isEmpty
            ? Padding(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Nothing to show here",
                        style: AppTheme.subBodyNormal,
                      )
                    ]))
            : listTransaction(context, state, transactions)
      ],
    );
  }

  Widget listTransaction(BuildContext context, HomeState state,
      Iterable<Transaction> transactions) {
    var filteredTransactions = transactions.take(4);

    return Column(
      children: filteredTransactions.map((transaction) {
        String actionLowercase = transaction.action?.toLowerCase() ?? "";
        Map<String, String> image = transaction.getMappedImage();
        return Column(
          children: [
            Padding(
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
                                      )));
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
                                          )),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        transaction.action ?? "",
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTheme.bodyNormal,
                                      ),
                                      RichText(
                                        overflow: TextOverflow.ellipsis,
                                        text: TextSpan(
                                          style: DefaultTextStyle.of(context)
                                              .style,
                                          children: <TextSpan>[
                                            TextSpan(
                                              text: formatDate(
                                                  transaction.createdTime!),
                                              style: AppTheme.subBodyNormal,
                                            ),
                                            TextSpan(
                                              text: " • ",
                                              style: AppTheme.subBodyNormal,
                                            ),
                                            TextSpan(
                                              text:
                                                  transaction.getMappedStatus(),
                                              style: transaction
                                                          .getMappedStatus() ==
                                                      'Pending'
                                                  ? AppTheme.subBodyNormalBold
                                                  : AppTheme.subBodyNormal,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ])),
                            // transaction.totalExecutionPrice == null &&
                            //         (actionLowercase.contains('buy') ||
                            //             actionLowercase.contains('sell'))
                            //     ? const SizedBox.shrink()
                            //     : Expanded(
                            Expanded(
                                flex: 28,
                                child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      transaction.totalExecutionPrice == null &&
                                              (actionLowercase
                                                      .contains('buy') ||
                                                  actionLowercase
                                                      .contains('sell'))
                                          ? const SizedBox.shrink()
                                          : Text(
                                              transaction.totalExecutionPrice ==
                                                      null
                                                  ? formatAmount(
                                                      transaction.amount ??
                                                          "0.0",
                                                      direction:
                                                          transaction.direction)
                                                  : formatAmount(
                                                      transaction
                                                              .totalExecutionPrice ??
                                                          "0.0",
                                                      direction: transaction
                                                          .direction),
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
                    ))),
            //const Divider()
          ],
        );
      }).toList(),
    );
  }
}
