import 'dart:io';

import 'package:bondgrid/bloc/plaid_bloc.dart';
import 'package:bondgrid/bloc/trading_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/dollar_box.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/components/purchase_confirmation_popover.dart';
import 'package:bondgrid/constants/shared_constants.dart';
import 'package:bondgrid/enums/payment_method_status.dart';
import 'package:bondgrid/models/asset.dart';
import 'package:bondgrid/models/cash_balance.dart';
import 'package:bondgrid/models/payment_method.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class BuyScreen extends StatefulWidget {
  const BuyScreen({super.key, required this.asset});

  final Asset asset;

  @override
  BuyScreenState createState() => BuyScreenState();
}

class BuyScreenState extends State<BuyScreen> with WidgetsBindingObserver {
  int stepperIndex = 0;
  TextEditingController buyAmountController = TextEditingController();
  bool isUsingBuyingPower = false;
  bool isBuyingPowerPositive = false;

  int? selectedPaymentMethodIndex;
  LinkConfiguration? _configuration;

  bool isPaymentMethodSelected = false;
  bool isConfirmationModalOpen = false;

  List<PaymentMethod> paymentMethodsList = <PaymentMethod>[];
  CashBalance? _cashBalance;

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

  void _loadPageData() {
    context.read<TradingBloc>().add(LoadInitialBuyDataEvent());
  }

  void setBuyingPowerValues() {
    // Parse the buying power string to a double
    double buyingPowerValue = 0.0;
    if (_cashBalance != null && _cashBalance!.buyingPower != null) {
      buyingPowerValue = double.tryParse(_cashBalance!.buyingPower!) ?? 0.0;
    }

    // Check if the buying power is greater than 0
    isBuyingPowerPositive = buyingPowerValue > 0;

    double? amount = double.tryParse(buyAmountController.value.text);
    if (amount != null) {
      // Check if the buying power is greater than input amount
      isBuyingPowerPositive =
          isBuyingPowerPositive && buyingPowerValue >= amount;
      // set the buying power as the default payment method if no
      // payment method is selected already
      if (isBuyingPowerPositive && !isPaymentMethodSelected) {
        isUsingBuyingPower = true;
        selectedPaymentMethodIndex = null;
      }
    }
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
            } else if (state is LoadInitialBuyDataLoadingState) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }

            if (state is CreatePurchaseSuccessState) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return PurchaseConfirmationPopover(
                        purchaseAmount: buyAmountController.value.text,
                        holdingId: state.purchaseResponse.holdingId,
                        transaction: state.purchaseResponse.transaction,
                      );
                    });
              }
            }

            if (state is LoadInitialBuyDataSuccessState) {
              paymentMethodsList = state.paymentMethods.paymentMethods;
              selectedPaymentMethodIndex = paymentMethodsList.isNotEmpty &&
                      state.paymentMethods.defaultPaymentMethodIndex != -1
                  ? state.paymentMethods.defaultPaymentMethodIndex
                  : null;
              _cashBalance = state.cashBalance;
            }

            if (state is TradingPaymentMethodSuccessState) {
              paymentMethodsList = state.paymentMethods.paymentMethods;
              if (mounted) {
                if (buyAmountController.value.text.isNotEmpty) {
                  setState(() {
                    selectedPaymentMethodIndex = paymentMethodsList
                                .isNotEmpty &&
                            state.paymentMethods.defaultPaymentMethodIndex != -1
                        ? state.paymentMethods.defaultPaymentMethodIndex
                        : null;
                    stepperIndex = 0;
                    isPaymentMethodSelected = true;
                    confirmationModal(
                        context,
                        BlocProvider.of<TradingBloc>(context),
                        BlocProvider.of<PlaidBloc>(context));
                  });
                } else {
                  setState(() {
                    selectedPaymentMethodIndex = paymentMethodsList
                                .isNotEmpty &&
                            state.paymentMethods.defaultPaymentMethodIndex != -1
                        ? state.paymentMethods.defaultPaymentMethodIndex
                        : null;
                  });
                }
              }
            }
          },
          child: BlocListener<PlaidBloc, PlaidState>(
              listener: (context, plaidState) {
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
                  context
                      .read<TradingBloc>()
                      .add(TradingGetPaymentMethodsEvent());
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
                        EasyLoading.dismiss();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.keyboard_arrow_left_rounded,
                        color: AppTheme.actionButton,
                        size: 22,
                      ),
                    ),
                  ),
                  body: AbsorbPointer(
                      absorbing: state.status == TradingStateStatus.loading,
                      child: bodyContent(context)))));
    });
  }

  Widget bodyContent(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Stack(children: [
      Center(
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(top: 20, bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              "Buy ${widget.asset.type} - ${widget.asset.duration}",
                              textAlign: TextAlign.center,
                              style: AppTheme.actionPageTitle,
                            ),
                          ],
                        )),
                    widget.asset.yieldToMaturityFormatted != null
                        ? Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 0, bottom: 12),
                            child: GestureDetector(
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
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "${formatYield(widget.asset.yieldToMaturityFormatted)}% YTM",
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.poppins(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 18),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.info_outline,
                                      color: AppTheme.grey,
                                      size: 20,
                                    ),
                                  ],
                                )))
                        : const SizedBox.shrink(),
                    const SizedBox(
                      height: 10,
                    ),
                    DollarBox(
                        controller: buyAmountController,
                        autofocus: true,
                        enabled: true,
                        isInputCenter: true,
                        isNumberInput: true,
                        padding: 0,
                        label: ""),
                    widget.asset.minimumOrderQuantity != null
                        ? Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 20, bottom: 12),
                            child: Text(
                              "Minimum Order Value: ${formatAmount(widget.asset.minimumOrderQuantity!.toString())}",
                              textAlign: TextAlign.center,
                              style: AppTheme.sectionSmallText,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ]))),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: buyAmountController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              if (value.text.isEmpty) {
                return defaultButtonRow(context);
              } else {
                double? amount = double.tryParse(value.text);
                bool isValid = false;

                if (widget.asset.minimumOrderQuantity != null) {
                  int? minOrderValue = widget.asset.minimumOrderQuantity!;
                  isValid =
                      amount != null && amount > 0 && amount >= minOrderValue;
                }

                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Review',
                  onPressFunction: isValid
                      ? () {
                          confirmationModal(
                              context,
                              BlocProvider.of<TradingBloc>(context),
                              BlocProvider.of<PlaidBloc>(context));
                        }
                      : null,
                );
              }
            },
          ),
        ),
      ),
    ]);
  }

  Widget defaultButtonRow(BuildContext context) {
    int? minOrderValue = widget.asset.minimumOrderQuantity != null
        ? widget.asset.minimumOrderQuantity!
        : 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return 0;
                  return 0;
                },
              ),
              backgroundColor:
                  MaterialStateProperty.all(AppTheme.primary.withOpacity(0.2)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(10),
              ),
            ),
            onPressed: 1000 >= minOrderValue
                ? () {
                    buyAmountController.text = '1000';
                    confirmationModal(
                        context,
                        BlocProvider.of<TradingBloc>(context),
                        BlocProvider.of<PlaidBloc>(context));
                  }
                : null,
            child: Text(
              "\$1,000",
              textAlign: TextAlign.center, // to ensure label is in the middle
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 10), // spacing between buttons, adjust as needed
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return 0;
                  return 0;
                },
              ),
              backgroundColor:
                  MaterialStateProperty.all(AppTheme.primary.withOpacity(0.2)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(10),
              ),
            ),
            onPressed: 5000 >= minOrderValue
                ? () {
                    buyAmountController.text = '5000';
                    confirmationModal(
                        context,
                        BlocProvider.of<TradingBloc>(context),
                        BlocProvider.of<PlaidBloc>(context));
                  }
                : null,
            child: Text(
              "\$5,000",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.primary),
            ),
          ),
        ),
        const SizedBox(width: 10), // spacing between buttons
        Expanded(
          child: ElevatedButton(
            style: ButtonStyle(
              elevation: MaterialStateProperty.resolveWith<double>(
                (Set<MaterialState> states) {
                  if (states.contains(MaterialState.pressed)) return 0;
                  return 0;
                },
              ),
              backgroundColor:
                  MaterialStateProperty.all(AppTheme.primary.withOpacity(0.2)),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              padding: MaterialStateProperty.all(
                const EdgeInsets.all(10),
              ),
            ),
            onPressed: 8000 >= minOrderValue
                ? () {
                    buyAmountController.text = '8000';
                    confirmationModal(
                        context,
                        BlocProvider.of<TradingBloc>(context),
                        BlocProvider.of<PlaidBloc>(context));
                  }
                : null,
            child: Text(
              "\$8,000",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: AppTheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  void confirmationModal(
      BuildContext context, TradingBloc tradingBloc, PlaidBloc plaidBloc) {
    FocusScope.of(context).unfocus();
    // Close modal if it's already open
    if (isConfirmationModalOpen) {
      Navigator.of(context).pop();
    }

    // Set the flag to true as the modal is being opened
    isConfirmationModalOpen = true;

    setBuyingPowerValues();
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
            return tradingBloc.state is! CreatePurchaseLoadingState;
          }, child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: getModalContent(stepperIndex, context, setState,
                        tradingBloc, plaidBloc),
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
      isConfirmationModalOpen = false;

      setState(() {
        stepperIndex = 0;
      });
    });
  }

  Widget getModalContent(int index, BuildContext context, StateSetter setState,
      TradingBloc tradingBloc, PlaidBloc plaidBloc) {
    switch (index) {
      case 0:
        return reviewModal(context, setState, tradingBloc);
      case 1:
        return paymentMethodModal(context, setState);
      case 2:
        return addBankModal(context, setState, plaidBloc);
      default:
        return reviewModal(context, setState, tradingBloc);
    }
  }

  Widget reviewModal(BuildContext context, StateSetter modalSetState,
      TradingBloc tradingBloc) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    double? amount = double.tryParse(buyAmountController.value.text);
    bool isValid = false;

    if (widget.asset.minimumOrderQuantity != null) {
      int? minOrderValue = widget.asset.minimumOrderQuantity!;
      isValid = amount != null && amount > 0 && amount >= minOrderValue;
    }

    int numberOfShares = 0;
    double totalCost = 0.0;
    // int totalAmountAtMaturity = 0;
    // double estimatedReturn = 0.0;
    double amountUninvested = 0.0;
    if (widget.asset.minimumOrderQuantity != null &&
        widget.asset.minimumOrderValue != null &&
        amount != null) {
      numberOfShares = amount ~/ widget.asset.minimumOrderValue!;
      totalCost = numberOfShares * widget.asset.minimumOrderValue!;
      // totalAmountAtMaturity =
      //     numberOfShares * widget.asset.minimumOrderQuantity!;
      // estimatedReturn = totalAmountAtMaturity - totalCost;
      amountUninvested = amount - totalCost;
    }

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text('Review and Buy',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              formatAmount(amount.toString()),
              style: GoogleFonts.poppins(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            Text(
              "Total Order Amount",
              style: AppTheme.bodyNormal,
            ),
            const SizedBox(height: 5),
            Text(
              "${widget.asset.type} - ${widget.asset.duration}: ${widget.asset.yieldToMaturityFormatted ?? ''}% YTM",
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w400,
                  fontSize: 16,
                  color: AppTheme.secondary.withOpacity(0.6)),
            ),
          ]),
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: AppTheme.subBodyNormal,
              children: [
                TextSpan(
                  text:
                      ' ${numberOfShares.toString()} ${numberOfShares == 1 ? "share" : "shares"} will be purchased at an estimated total cost of ${formatAmount(totalCost.toString())}.'
                      ' The remaining ${formatAmount(amountUninvested.toString())} will be stored in the Finvest cash account. Auto Roll will be enabled for this holding. You may disable it on the holding page after the trade is executed. ',
                ),
                TextSpan(
                  text: 'More details',
                  style: AppTheme.subBodyNormal.copyWith(
                      decoration: TextDecoration.underline,
                      color: AppTheme.primary),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            content: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.98,
                                child: SingleChildScrollView(
                                    child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                      Text('Order Details',
                                          style: AppTheme.bodyBold,
                                          textAlign: TextAlign.center),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Number of Shares ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  numberOfShares.toString(),
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Estimated Price Per Share ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  formatAmount(widget.asset
                                                          .minimumOrderValue
                                                          ?.toString() ??
                                                      "0.0"),
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Yield to Maturity ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  "${widget.asset.yieldToMaturityFormatted ?? ""}% APY",
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      const Divider(),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Total Order Amount ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  formatAmount(
                                                      amount.toString()),
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Estimated Total Cost ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  formatAmount(
                                                      totalCost.toString()),
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                                flex: 60,
                                                child: Text(
                                                  "Remaining In Cash ",
                                                  style:
                                                      AppTheme.bodyNormalGrey,
                                                )),
                                            Expanded(
                                                flex: 40,
                                                child: Text(
                                                  formatAmount(amountUninvested
                                                      .toString()),
                                                  style: AppTheme.bodyNormal,
                                                  textAlign: TextAlign.end,
                                                )),
                                          ]),
                                      // const Divider(),
                                      // Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Expanded(
                                      //           flex: 70,
                                      //           child: Text(
                                      //             "Yield to Maturity ",
                                      //             style:
                                      //                 AppTheme.bodyNormalGrey,
                                      //           )),
                                      //       Expanded(
                                      //           flex: 30,
                                      //           child: Text(
                                      //             "${widget.asset.yieldToMaturityFormatted ?? "--"}% APY",
                                      //             style: AppTheme.bodyNormal,
                                      //             textAlign: TextAlign.end,
                                      //           )),
                                      //     ]),
                                      // Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Expanded(
                                      //           flex: 70,
                                      //           child: Text(
                                      //             "Amount at Maturity ",
                                      //             style:
                                      //                 AppTheme.bodyNormalGrey,
                                      //           )),
                                      //       Expanded(
                                      //           flex: 30,
                                      //           child: Text(
                                      //             formatAmount(
                                      //                 totalAmountAtMaturity
                                      //                     .toString()),
                                      //             style: AppTheme.bodyNormal,
                                      //             textAlign: TextAlign.end,
                                      //           )),
                                      //     ]),
                                      // Row(
                                      //     mainAxisAlignment:
                                      //         MainAxisAlignment.spaceBetween,
                                      //     children: [
                                      //       Text(
                                      //         "Estimated Return",
                                      //         style: AppTheme.bodyNormalGrey,
                                      //       ),
                                      //       Text(
                                      //         formatAmount(
                                      //             estimatedReturn.toString()),
                                      //         style: AppTheme.bodyNormal,
                                      //       ),
                                      //     ])
                                    ]))),
                            actionsAlignment: MainAxisAlignment.center,
                            actionsPadding: const EdgeInsets.only(bottom: 20),
                            actions: [
                              SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.06,
                                  width:
                                      MediaQuery.of(context).size.width * 0.5,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text(
                                      "Close",
                                      style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                          color: AppTheme.nearlyWhite),
                                    ),
                                  )),
                            ],
                          );
                        },
                      );
                    },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(
          height: 18,
        ),
        const Divider(),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              modalSetState(() {
                stepperIndex = 1;
              });
            },
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Payment Method",
                      style: GoogleFonts.poppins(
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                    ),
                    isUsingBuyingPower
                        ? Row(
                            children: [
                              Text(
                                "Finvest Cash",
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(width: 2),
                              const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: AppTheme.grey,
                                size: 26,
                              )
                            ],
                          )
                        : selectedPaymentMethodIndex != null
                            ? Row(
                                children: [
                                  Text(
                                    "${paymentMethodsList[selectedPaymentMethodIndex!].institutionName}"
                                    " ···· ${paymentMethodsList[selectedPaymentMethodIndex!].accountMask}",
                                    style: GoogleFonts.poppins(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 2),
                                  const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 26,
                                  )
                                ],
                              )
                            : const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: AppTheme.grey,
                                size: 26,
                              ),
                  ]),
            )),
        const Divider(),
        // const SizedBox(
        //   height: 10,
        // ),
        // ListTile(
        //   contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        //   title: Text(
        //     'By tapping "Confirm" below, you authorize Finvest to purchase as many'
        //     ' Treasury Bills of the above described maturity as possible with the specific amount.',
        //     style: AppTheme.subBodyNormal,
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        const SizedBox(
          height: 10,
        ),
        // Padding(
        //     padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        //     child: RichText(
        //       text: TextSpan(
        //         // Note: Styles for TextSpans must be explicitly defined.
        //         // Child text spans will inherit styles from parent
        //         style: AppTheme.subBodyNormal,
        //         children: const <TextSpan>[
        //           TextSpan(
        //               text:
        //                   'Auto Roll will be enabled for this holding. You may disable it on the holding page after the trade is executed.',
        //               style: TextStyle(fontWeight: FontWeight.bold)),
        //         ],
        //       ),
        //       textAlign: TextAlign.center,
        //     )),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            child: BlocBuilder<TradingBloc, TradingState>(
              bloc: tradingBloc,
              builder: (context, state) {
                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Confirm',
                  isLoading: state is CreatePurchaseLoadingState,
                  onPressFunction: (selectedPaymentMethodIndex != null ||
                              isUsingBuyingPower) &&
                          widget.asset.cusip != null &&
                          isValid &&
                          state is! CreatePurchaseLoadingState
                      ? () {
                          tradingBloc.add(CreatePurchaseEvent(
                              buyAmountController.value.text,
                              widget.asset.cusip!,
                              isUsingBuyingPower
                                  ? 'buying_power'
                                  : 'external_account',
                              isUsingBuyingPower
                                  ? ''
                                  : paymentMethodsList[
                                          selectedPaymentMethodIndex!]
                                      .id!,
                              "${widget.asset.type} - ${widget.asset.duration}",
                              SharedConstants.AUTO_ROLL));
                        }
                      : null,
                );
              },
            ))
      ],
    );
  }

  Widget paymentMethodModal(BuildContext context, StateSetter modalSetState) {
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
                      stepperIndex = 0;
                    });
                  },
                  icon: Icon(
                    Icons.keyboard_arrow_left_rounded,
                    color: AppTheme.actionButton,
                    size: 22,
                  ),
                )),
            Text(
              'Payment Method',
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
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text(
            "Linked Accounts",
            style: AppTheme.secondaryTextBold,
          ),
        ),
        ...List<Widget>.generate(paymentMethodsList.length, (index) {
          bool isPaymentMethodActive = (paymentMethodsList[index].status ==
                  PaymentMethodStatus.ACTIVE ||
              paymentMethodsList[index].status == PaymentMethodStatus.PENDING);
          return Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: Card(
                elevation: 0,
                color: isPaymentMethodActive
                    ? selectedPaymentMethodIndex == index
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.backgroundColor
                    : Colors.grey[600]!.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                    color: isPaymentMethodActive &&
                            selectedPaymentMethodIndex == index
                        ? AppTheme.primary
                        : Colors.grey[600]!.withOpacity(0.2),
                    width: isPaymentMethodActive &&
                            selectedPaymentMethodIndex == index
                        ? 2.0
                        : 1.0,
                  ),
                ),
                child: RadioListTile<int>(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: Icon(
                          Icons.account_balance,
                          size: 20,
                          color: isPaymentMethodActive &&
                                  selectedPaymentMethodIndex == index
                              ? AppTheme.primary
                              : Colors.grey[600]!.withOpacity(0.8),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              "${paymentMethodsList[index].institutionName} ${paymentMethodsList[index].accountName}",
                              style: isPaymentMethodActive &&
                                      selectedPaymentMethodIndex == index
                                  ? GoogleFonts.poppins(
                                      color: AppTheme.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    )
                                  : GoogleFonts.poppins(
                                      color: Colors.grey[600]!.withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 16,
                                    ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            paymentMethodsList[index].status != null
                                ? Text(
                                    "···· ${paymentMethodsList[index].accountMask} • ${paymentMethodsList[index].status!.displayValue}",
                                    style: isPaymentMethodActive &&
                                            selectedPaymentMethodIndex == index
                                        ? GoogleFonts.poppins(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          )
                                        : GoogleFonts.poppins(
                                            color: Colors.grey[600]!
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : Text(
                                    "···· ${paymentMethodsList[index].accountMask}",
                                    style: isPaymentMethodActive &&
                                            selectedPaymentMethodIndex == index
                                        ? GoogleFonts.poppins(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          )
                                        : GoogleFonts.poppins(
                                            color: Colors.grey[600]!
                                                .withOpacity(0.8),
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14,
                                          ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  value: index,
                  groupValue:
                      isPaymentMethodActive ? selectedPaymentMethodIndex : null,
                  onChanged: isPaymentMethodActive
                      ? (int? value) {
                          modalSetState(() {
                            isUsingBuyingPower = false;
                            selectedPaymentMethodIndex = value;
                            isPaymentMethodSelected = true;
                            stepperIndex = 0;
                          });
                        }
                      : null,
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: AppTheme.primary,
                ),
              ));
        }),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              modalSetState(() {
                stepperIndex = 2;
              });
            },
            child: ListTile(
              title:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
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
                  style: AppTheme.bodyBold,
                ),
              ]),
            )),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text(
            "Finvest Cash",
            style: AppTheme.secondaryTextBold,
          ),
        ),
        buyingPowerOption(context, modalSetState),
        SizedBox(
          height: bottomPadding,
        ),
      ],
    );
  }

  Widget buyingPowerOption(BuildContext context, StateSetter modalSetState) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Card(
          elevation: 0,
          color: isBuyingPowerPositive
              ? isUsingBuyingPower
                  ? AppTheme.primary.withOpacity(0.2)
                  : AppTheme.backgroundColor
              : Colors.grey[600]!.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(
              color: isUsingBuyingPower && isBuyingPowerPositive
                  ? AppTheme.primary
                  : Colors.grey[600]!.withOpacity(0.2),
              width: isUsingBuyingPower && isBuyingPowerPositive ? 2.0 : 1.0,
            ),
          ),
          child: RadioListTile<int>(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Icon(
                    Icons.wallet_rounded,
                    size: 20,
                    color: isUsingBuyingPower && isBuyingPowerPositive
                        ? AppTheme.primary
                        : Colors.grey[600]!.withOpacity(0.8),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Buying Power",
                        style: isUsingBuyingPower && isBuyingPowerPositive
                            ? GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              )
                            : GoogleFonts.poppins(
                                color: Colors.grey[600]!.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                              ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _cashBalance != null &&
                                _cashBalance!.buyingPower != null
                            ? formatAmount(_cashBalance!.buyingPower!)
                            : "\$0.00",
                        style: isUsingBuyingPower && isBuyingPowerPositive
                            ? GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              )
                            : GoogleFonts.poppins(
                                color: Colors.grey[600]!.withOpacity(0.8),
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            value: 0,
            groupValue: isUsingBuyingPower && isBuyingPowerPositive ? 0 : null,
            onChanged: isBuyingPowerPositive
                ? (int? value) {
                    modalSetState(() {
                      selectedPaymentMethodIndex = null;
                      isUsingBuyingPower = true;
                      stepperIndex = 0;
                    });
                  }
                : null,
            controlAffinity: ListTileControlAffinity.trailing,
            activeColor: AppTheme.primary,
          ),
        ));
  }

  Widget addBankModal(
      BuildContext context, StateSetter modalSetState, PlaidBloc plaidBloc) {
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
              'Link Bank Account',
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
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          child: BlocBuilder<PlaidBloc, PlaidState>(
              bloc: plaidBloc,
              builder: (context, state) {
                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Next',
                  isLoading: state.status == PlaidStateStatus.loading,
                  onPressFunction: state.status == PlaidStateStatus.loading
                      ? null
                      : () {
                          context.read<PlaidBloc>().add(GetPlaidLinkTokenEvent(
                              Platform.isIOS
                                  ? PLATFORM.IOS
                                  : PLATFORM.ANDROID));
                        },
                );
              }),
        )
      ],
    );
  }
}
