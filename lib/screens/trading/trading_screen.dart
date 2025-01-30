import 'dart:async';

import 'package:bondgrid/bloc/trading_bloc.dart';
import 'package:bondgrid/components/account_failure_verification_popover.dart';
import 'package:bondgrid/components/account_pending_verification_popover.dart';
import 'package:bondgrid/components/account_verification_denied_popover.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/components/tutorial_card.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/asset.dart';
import 'package:bondgrid/models/asset_list.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/trading_repo.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/screens/trading/buy_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:bondgrid/utilities/tutorial_contents.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TradingScreen extends StatefulWidget {
  const TradingScreen(
      {Key? key, required this.showNavBar, required this.scrollController})
      : super(key: key);

  final ValueNotifier<bool> showNavBar;
  final ScrollController scrollController;

  @override
  TradingScreenState createState() => TradingScreenState();
}

class TradingScreenState extends State<TradingScreen>
    with WidgetsBindingObserver {
  UserInfo? _userInfo;
  AssetList? _assetList;
  Map<String, Asset> durationAssetMap = {};
  double _currentSliderValue = 10000;
  Asset? selectedAssetType;

  StreamSubscription? _refreshSubscription;

  @override
  void initState() {
    super.initState();
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
    context.read<TradingBloc>().add(LoadInitialDataEvent(useCache: useCache));
  }

  Map<String, Asset> getDurationAssetMap(AssetList? assetList) {
    Map<String, Asset> durationAssetMap = {};
    assetList?.assets.forEach((asset) {
      if (asset.duration != null && asset.yieldToMaturityFormatted != null) {
        durationAssetMap[asset.duration!] = asset;
      }
    });
    return durationAssetMap;
  }

  double calculateInterestEarned(
      double amount, double annualInterestRate, String duration) {
    Map<String, double> durationToYearFraction = {
      "1 Month": 1 / 12,
      "3 Months": 3 / 12,
      "6 Months": 6 / 12,
      "12 Months": 1,
    };

    double yearFraction = durationToYearFraction[duration] ?? 0;
    double interestEarned = amount * annualInterestRate * yearFraction / 100;

    return interestEarned;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TradingBloc, TradingState>(builder: (context, state) {
      return BlocListener<TradingBloc, TradingState>(
          listener: (context, state) {
            if (state.status == TradingStateStatus.failure) {
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is LoadInitialDataSuccessState) {
              _userInfo = state.userInfo;
              _assetList = state.assetList;

              if (_assetList != null && _assetList!.assets.isNotEmpty) {
                durationAssetMap = getDurationAssetMap(_assetList);
                selectedAssetType =
                    durationAssetMap['12 Months'] ?? _assetList!.assets[0];
              }
            }

            if (state is GetAssetListSuccessState) {
              _assetList = state.assetList;
              if (_assetList != null && _assetList!.assets.isNotEmpty) {
                durationAssetMap = getDurationAssetMap(_assetList);
                selectedAssetType =
                    durationAssetMap['12 Months'] ?? _assetList!.assets[0];
              }
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == TradingStateStatus.loading,
              child: SafeArea(
                  child: Scaffold(
                body: NotificationListener<OverscrollIndicatorNotification>(
                    onNotification: (overscroll) {
                      overscroll.disallowIndicator();
                      return true;
                    },
                    child: SingleChildScrollView(
                        controller: widget.scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Container(
                            margin: const EdgeInsets.only(
                                top: 10, bottom: 0, left: 15, right: 15),
                            child: Column(
                              children: [
                                headingCard(context),
                                const SizedBox(
                                  height: 20,
                                ),
                                listOfTreasury(context, state),
                                const SizedBox(
                                  height: 20,
                                ),
                                tutorialCards(context)
                              ],
                            )))),
              ))));
    });
  }

  Widget treasuryYieldInfo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showInfoModal(
            context: context,
            title: 'Treasury YTM (Yield to Maturity)',
            subtext:
                'The listed yield is the estimated annualized yield you will receive if you hold the purchased Treasury bills to maturity.'
                '\n\nOrders are processed on weekdays during regular bond market trading hours (9:30 AM - 4:00 PM EST, Monday - Friday).'
                '\n\nThe price at which your order will execute will be determined by the market price'
                ' at the time of execution and may not always reflect the prior day’s closing price'
                ' of the security.',
            isNavBarVisible: true);
      },
      child: const Padding(
        padding: EdgeInsets.only(left: 5),
        child: Icon(Icons.info_outline, color: AppTheme.grey, size: 24),
      ),
    );
  }

  Widget interestCalculator(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isDismissible: true,
          isScrollControlled: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (BuildContext context) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
              double interestRate;
              try {
                if (selectedAssetType != null &&
                    selectedAssetType!.yieldToMaturityFormatted != null) {
                  interestRate = double.parse(
                      selectedAssetType!.yieldToMaturityFormatted!);
                } else {
                  interestRate = 0.0;
                }
              } catch (e) {
                interestRate = 0.0;
              }
              double interestEarned = calculateInterestEarned(
                  _currentSliderValue,
                  interestRate,
                  selectedAssetType?.duration ?? "");

              return SafeArea(
                child: Container(
                    //height: MediaQuery.of(context).size.height,
                    // decoration: const BoxDecoration(
                    //   color: AppTheme.nearlyWhite,
                    // ),
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.only(
                              top: 0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 30),
                                  child: Text(
                                    "Interest Calculator",
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                        color: AppTheme.secondary),
                                  ),
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(
                                        top: 0,
                                        bottom: 30,
                                        right: 20,
                                        left: 20),
                                    child: Column(
                                      children: [
                                        Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                'Investment Amount',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: AppTheme.secondary
                                                        .withOpacity(0.6)),
                                              ),
                                              Text(
                                                formatAmount(
                                                    _currentSliderValue
                                                        .toString(),
                                                    keepZero: false),
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    color: AppTheme.secondary),
                                              ),
                                            ]),
                                        Slider(
                                          value: _currentSliderValue,
                                          min: 1000,
                                          max: 100000,
                                          divisions: 5000,
                                          activeColor: AppTheme.primary,
                                          label: _currentSliderValue
                                              .round()
                                              .toString(),
                                          onChanged: (double value) {
                                            setModalState(() {
                                              _currentSliderValue = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 20),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'Treasury Duration',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: AppTheme.secondary
                                                        .withOpacity(0.6)),
                                              ),
                                              const SizedBox(height: 5),
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(4),
                                                ),
                                                child:
                                                    DropdownButtonHideUnderline(
                                                  child: DropdownButton<Asset>(
                                                    value: selectedAssetType,
                                                    isDense: true,
                                                    isExpanded: true,
                                                    hint: Text('Duration',
                                                        style:
                                                            GoogleFonts.poppins(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16,
                                                                color: AppTheme
                                                                    .secondary)),
                                                    icon: const Icon(
                                                        Icons
                                                            .keyboard_arrow_down,
                                                        color:
                                                            AppTheme.primary),
                                                    onChanged:
                                                        (Asset? newValue) {
                                                      setModalState(() {
                                                        selectedAssetType =
                                                            newValue;
                                                      });
                                                    },
                                                    items: _assetList?.assets
                                                        .map<
                                                            DropdownMenuItem<
                                                                Asset>>((Asset
                                                            asset) {
                                                      return DropdownMenuItem<
                                                          Asset>(
                                                        value: asset,
                                                        child: Container(
                                                            alignment: Alignment
                                                                .centerLeft,
                                                            child: Text(
                                                                '${asset.duration}',
                                                                style: GoogleFonts.poppins(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w500,
                                                                    fontSize:
                                                                        16,
                                                                    color: AppTheme
                                                                        .secondary))),
                                                      );
                                                    }).toList(),
                                                  ),
                                                ),
                                              )
                                            ]),
                                        const SizedBox(height: 30),
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              Text(
                                                'Yield To Maturity',
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 14,
                                                    color: AppTheme.secondary
                                                        .withOpacity(0.6)),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                "$interestRate%",
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 16,
                                                    color: AppTheme.secondary),
                                              ),
                                            ]),
                                        const SizedBox(height: 15),
                                        const Divider(),
                                        const SizedBox(height: 15),
                                        Text(
                                          'Total Interest Earned',
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              color: AppTheme.primary),
                                        ),
                                        Text(
                                          formatAmount(
                                              interestEarned.toString(),
                                              keepZero: false),
                                          style: GoogleFonts.poppins(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18,
                                              color: AppTheme.primary),
                                        ),
                                        const SizedBox(height: 20),
                                        Text(
                                            'The exact interest earned will be determined by the market price of the security'
                                            ' at the time of execution and may not always reflect the interest quoted above',
                                            textAlign: TextAlign.center,
                                            style: AppTheme.subBodyNormal),
                                      ],
                                    )),
                              ],
                            )))),
              );
            });
          },
        );
      },
      child: Padding(
          padding: const EdgeInsets.only(left: 5),
          child: SvgPicture.asset(
            'lib/assets/calculate.svg',
            height: 24.0,
            width: 24.0,
            color: AppTheme.grey,
          )),
    );
  }

  Widget headingCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 0,
        color: AppTheme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: RichText(
                  textAlign: TextAlign.left,
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: "Grow your wealth with\nUS Treasuries",
                        style: AppTheme.titleTextPrimary,
                      ),
                    ],
                  ),
                ),
              ),
              treasuryYieldInfo(context),
              interestCalculator(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget listOfTreasury(BuildContext context, TradingState state) {
    return Card(
      elevation: 0,
      color: AppTheme.backgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: state is LoadInitialDataLoadingState
          ? buildTransactionShimmer(context)
          : _assetList == null || _assetList!.assets.isEmpty
              ? const SizedBox.shrink()
              : Column(
                  children: _assetList!.assets.map((asset) {
                    return Column(children: [
                      Padding(
                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                          child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: _userInfo != null &&
                                      (_userInfo!.verification.status ==
                                              VerificationStatus.SUCCESSFUL ||
                                          _userInfo!.verification.status ==
                                              VerificationStatus.PROCESSING)
                                  ? () {
                                      widget.showNavBar.value = false;
                                      Navigator.push(
                                        context,
                                        (Theme.of(context).platform ==
                                                TargetPlatform.iOS)
                                            ? CupertinoPageRoute(
                                                builder: (context) =>
                                                    BlocProvider(
                                                      create: (context) =>
                                                          TradingBloc(
                                                              TradingRepo()),
                                                      child: BuyScreen(
                                                          asset: asset),
                                                    ))
                                            : MaterialPageRoute(
                                                builder: (context) =>
                                                    BlocProvider(
                                                      create: (context) =>
                                                          TradingBloc(
                                                              TradingRepo()),
                                                      child: BuyScreen(
                                                          asset: asset),
                                                    )),
                                      ).then((_) {
                                        widget.showNavBar.value = true;
                                        EasyLoading.dismiss();
                                      });
                                    }
                                  : _userInfo != null &&
                                          _userInfo!.verification.status ==
                                              VerificationStatus.NOT_STARTED
                                      ? () {
                                          showDialog(
                                              barrierDismissible: false,
                                              barrierColor:
                                                  Colors.black.withOpacity(0.9),
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
                                                      VerificationStatus.DENIED
                                              ? () {
                                                  showDialog(
                                                      barrierDismissible: false,
                                                      barrierColor: Colors.black
                                                          .withOpacity(0.9),
                                                      context: context,
                                                      builder: (context) {
                                                        return const AccountVerificationDeniedPopover();
                                                      });
                                                }
                                              : () {},
                              child: ListTile(
                                contentPadding:
                                    const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 12,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppTheme.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(5),
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
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  asset.type ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTheme.bodyNormal,
                                                ),
                                                Text(
                                                  asset.duration ?? "",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTheme.subBodyNormal,
                                                ),
                                              ])),
                                      Expanded(
                                          flex: 28,
                                          child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  "${formatYield(asset.yieldToMaturityFormatted)}%",
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: GoogleFonts.poppins(
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 16),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                  color: Colors.grey[600]!
                                                      .withOpacity(0.4),
                                                  size: 26,
                                                )
                                              ]))
                                    ]),
                              ))),
                      const Divider()
                    ]);
                  }).toList(),
                ),
    );
  }

  String findHighestYield(AssetList? assetList) {
    double highestYield = 5.0;
    assetList?.assets.forEach((asset) {
      if (asset.yieldToMaturityFormatted != null) {
        double yieldValue;
        try {
          yieldValue = double.parse(asset.yieldToMaturityFormatted!);
        } catch (e) {
          yieldValue = 0.0;
        }
        if (yieldValue > highestYield) {
          highestYield = yieldValue;
        }
      }
    });
    return highestYield.toStringAsFixed(1);
  }

  Map<String, String> getDurationYieldMap(AssetList? assetList) {
    Map<String, String> durationYieldMap = {};
    assetList?.assets.forEach((asset) {
      if (asset.duration != null && asset.yieldToMaturityFormatted != null) {
        durationYieldMap[asset.duration!] = asset.yieldToMaturityFormatted!;
      }
    });
    return durationYieldMap;
  }

  Widget tutorialCards(BuildContext context) {
    Map<String, String> durationYieldMap = getDurationYieldMap(_assetList);
    String highestYield = findHighestYield(_assetList);

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Learn as you go",
          style: AppTheme.sectionTitle,
          textAlign: TextAlign.start,
        ),
        const SizedBox(
          height: 20,
        ),
        TutorialCard(
          title: "Why invest in Treasury Bills?",
          imagePath: "lib/assets/tutorial1.svg",
          content: tutorial1Content(context, interestRate: highestYield),
        ),
        TutorialCard(
            title: "How does it work?",
            imagePath: "lib/assets/tutorial2.svg",
            content: tutorial2Content(
              context,
              interestRate6Months: durationYieldMap['6 Months'] ?? '5.0',
              interestRate12Months: durationYieldMap['12 Months'] ?? '5.0',
            )),
        TutorialCard(
          title: "How much interest can I earn?",
          imagePath: "lib/assets/tutorial3.svg",
          content: tutorial3Content(context,
              interestRate: durationYieldMap['12 Months'] ?? '5.0'),
        ),
        TutorialCard(
            title: "Is my money safe?",
            imagePath: "lib/assets/tutorial4.svg",
            content: tutorial4Content(context))
      ],
    );
  }
}
