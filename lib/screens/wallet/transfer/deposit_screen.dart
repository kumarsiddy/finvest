import 'dart:io';

import 'package:bondgrid/bloc/plaid_bloc.dart';
import 'package:bondgrid/bloc/transfer_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/deposit_confirmation_popover.dart';
import 'package:bondgrid/components/dollar_box.dart';
import 'package:bondgrid/constants/shared_constants.dart';
import 'package:bondgrid/enums/payment_method_status.dart';
import 'package:bondgrid/models/payment_method.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class DepositScreen extends StatefulWidget {
  const DepositScreen({super.key});

  @override
  DepositScreenState createState() => DepositScreenState();
}

class DepositScreenState extends State<DepositScreen>
    with WidgetsBindingObserver {
  int stepperIndex = 0;
  TextEditingController depositAmountController = TextEditingController();
  FocusNode depositAmountFocusNode = FocusNode();
  int? selectedPaymentMethodIndex;
  LinkConfiguration? _configuration;

  List<PaymentMethod> paymentMethodsList = <PaymentMethod>[];
  bool isConfirmationModalOpen = false;

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

  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   super.didChangeAppLifecycleState(state);
  //   if (state == AppLifecycleState.resumed) {
  //     _loadPageData();
  //   }
  // }

  void _loadPageData() {
    context.read<TransferBloc>().add(GetPaymentMethodsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransferBloc, TransferState>(builder: (context, state) {
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   depositAmountFocusNode.requestFocus();
      // });
      return BlocListener<TransferBloc, TransferState>(
          listener: (context, state) {
            if (state.status == TransferStateStatus.failure) {
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            } else if (state is PaymentMethodLoadingState) {
              EasyLoading.show();
            } else {
              EasyLoading.dismiss();
            }

            if (state is CreateDepositSuccessState) {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return DepositConfirmationPopover(
                        depositAmount: depositAmountController.value.text,
                        transaction: state.transaction,
                      );
                    });
              }
            }

            if (state is PaymentMethodSuccessState) {
              paymentMethodsList = state.paymentMethods.paymentMethods;
              if (mounted) {
                if (depositAmountController.value.text.isNotEmpty) {
                  setState(() {
                    selectedPaymentMethodIndex = paymentMethodsList
                                .isNotEmpty &&
                            state.paymentMethods.defaultPaymentMethodIndex != -1
                        ? state.paymentMethods.defaultPaymentMethodIndex
                        : null;
                    stepperIndex = 0;
                    confirmationModal(
                        context,
                        BlocProvider.of<TransferBloc>(context),
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
                  context.read<TransferBloc>().add(GetPaymentMethodsEvent());
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
                      absorbing: state.status == TransferStateStatus.loading,
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
                      child: Text(
                        "Deposit Funds",
                        textAlign: TextAlign.center,
                        style: AppTheme.actionPageTitle,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    DollarBox(
                        controller: depositAmountController,
                        autofocus: true,
                        //focusNode: depositAmountFocusNode,
                        enabled: true,
                        isInputCenter: true,
                        isNumberInput: true,
                        padding: 0,
                        label: ""),
                  ]))),
      Align(
        alignment: Alignment.bottomCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: depositAmountController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              if (value.text.isEmpty) {
                return defaultButtonRow(context);
              } else {
                double? amount = double.tryParse(value.text);
                bool isValid = amount != null && amount > 0;

                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Review',
                  onPressFunction: isValid
                      ? () {
                          confirmationModal(
                              context,
                              BlocProvider.of<TransferBloc>(context),
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
            onPressed: () {
              depositAmountController.text = '1000';
              confirmationModal(context, BlocProvider.of<TransferBloc>(context),
                  BlocProvider.of<PlaidBloc>(context));
            },
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
            onPressed: () {
              depositAmountController.text = '5000';
              confirmationModal(context, BlocProvider.of<TransferBloc>(context),
                  BlocProvider.of<PlaidBloc>(context));
            },
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
            onPressed: () {
              depositAmountController.text = '8000';
              confirmationModal(context, BlocProvider.of<TransferBloc>(context),
                  BlocProvider.of<PlaidBloc>(context));
            },
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
      BuildContext context, TransferBloc transferBloc, PlaidBloc plaidBloc) {
    FocusScope.of(context).unfocus();
    // Close modal if it's already open
    if (isConfirmationModalOpen) {
      Navigator.of(context).pop();
    }

    // Set the flag to true as the modal is being opened
    isConfirmationModalOpen = true;
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
            return transferBloc.state is! CreateDepositLoadingState;
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
                        transferBloc, plaidBloc),
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
      TransferBloc transferBloc, PlaidBloc plaidBloc) {
    switch (index) {
      case 0:
        return reviewModal(context, setState, transferBloc);
      case 1:
        return paymentMethodModal(context, setState);
      case 2:
        return addBankModal(context, setState, plaidBloc);
      default:
        return reviewModal(context, setState, transferBloc);
    }
  }

  Widget reviewModal(BuildContext context, StateSetter modalSetState,
      TransferBloc transferBloc) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text('Review and Deposit',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        const SizedBox(
          height: 10,
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Text(
              formatAmount(depositAmountController.value.text),
              style: GoogleFonts.poppins(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
                fontSize: 20,
              ),
            ),
            Text(
              "will be deposited to Finvest",
              style: AppTheme.bodyNormal,
            ),
          ]),
        ),
        const SizedBox(
          height: 18,
        ),
        const Divider(),
        InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              if (paymentMethodsList.isNotEmpty) {
                modalSetState(() {
                  stepperIndex = 1;
                });
              } else {
                modalSetState(() {
                  stepperIndex = 2;
                });
              }
            },
            child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    selectedPaymentMethodIndex != null
                        ? Text(
                            "From",
                            style: GoogleFonts.poppins(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          )
                        : Text(
                            "Add a funding method",
                            style: GoogleFonts.poppins(
                              color: AppTheme.secondary,
                              fontWeight: FontWeight.w500,
                              fontSize: 16,
                            ),
                          ),
                    selectedPaymentMethodIndex != null
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
        const SizedBox(
          height: 10,
        ),
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
          title: Text(
            // 'By tapping "Confirm" below, you authorize Finvest to transfer the above funds'
            // ' from your choosen payment method to your Finvest brokerage account.\n\n'
            'Make sure you have at least ${formatAmount(depositAmountController.value.text)} in your bank for the pending deposit.',
            style: AppTheme.subBodyNormal,
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPadding),
            child: BlocBuilder<TransferBloc, TransferState>(
              bloc: transferBloc,
              builder: (context, state) {
                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Confirm',
                  isLoading: state is CreateDepositLoadingState,
                  onPressFunction: selectedPaymentMethodIndex != null &&
                          state is! CreateDepositLoadingState
                      ? () {
                          context.read<TransferBloc>().add(CreateDepositEvent(
                              depositAmountController.value.text,
                              paymentMethodsList[selectedPaymentMethodIndex!]
                                  .id!));
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
            IconButton(
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
            ),
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
        const SizedBox(
          height: 10,
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
                            selectedPaymentMethodIndex = value;
                            stepperIndex = 0;
                          });
                        }
                      : null,
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: AppTheme.primary,
                ),
              ));
        }),
        const SizedBox(
          height: 5,
        ),
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
        SizedBox(
          height: bottomPadding,
        ),
      ],
    );
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
            IconButton(
              onPressed: () {
                if (paymentMethodsList.isNotEmpty) {
                  modalSetState(() {
                    stepperIndex = 1;
                  });
                } else {
                  modalSetState(() {
                    stepperIndex = 0;
                  });
                }
              },
              icon: Icon(
                Icons.keyboard_arrow_left_rounded,
                color: AppTheme.actionButton,
                size: 22,
              ),
            ),
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
              },
            ))
      ],
    );
  }
}
