import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/enums/annual_income.dart';
import 'package:bondgrid/enums/downturn_reaction.dart';
import 'package:bondgrid/enums/investment_horizon.dart';
import 'package:bondgrid/enums/investment_priority.dart';
import 'package:bondgrid/enums/net_worth.dart';
import 'package:bondgrid/models/financial_profile.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

class FinancialProfileScreen extends StatefulWidget {
  const FinancialProfileScreen({Key? key, required this.currentValue})
      : super(key: key);

  final FinancialProfile currentValue;

  @override
  FinancialProfileScreenState createState() => FinancialProfileScreenState();
}

class FinancialProfileScreenState extends State<FinancialProfileScreen> {
  int stepperIndex = 0;

  TextEditingController investmentPriorityController = TextEditingController();
  TextEditingController investmentHorizonController = TextEditingController();
  TextEditingController downturnReactionController = TextEditingController();
  TextEditingController annualIncomeController = TextEditingController();
  TextEditingController netWorthController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Initialize controller if currentValue is set
    if (widget.currentValue.investmentPriority != null) {
      investmentPriorityController.text =
          widget.currentValue.investmentPriority!.value;
    }
    if (widget.currentValue.investmentHorizon != null) {
      investmentHorizonController.text =
          widget.currentValue.investmentHorizon!.value;
    }
    if (widget.currentValue.downturnReaction != null) {
      downturnReactionController.text =
          widget.currentValue.downturnReaction!.value;
    }
    if (widget.currentValue.annualIncome != null) {
      annualIncomeController.text = widget.currentValue.annualIncome!.value;
    }
    if (widget.currentValue.netWorth != null) {
      netWorthController.text = widget.currentValue.netWorth!.value;
    }
  }

  Widget getForm(BuildContext context) {
    if (stepperIndex == 0) {
      return investmentPriorityForm(context);
    } else if (stepperIndex == 1) {
      return investmentHorizonForm(context);
    } else if (stepperIndex == 2) {
      return downturnReactionForm(context);
    } else if (stepperIndex == 3) {
      return annualIncomeForm(context);
    } else if (stepperIndex == 4) {
      return netWorthForm(context);
    } else {
      return investmentPriorityForm(context);
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
              Navigator.pop(context);
            }

            if (state is UpdateFinancialProfileSuccessState) {
              Navigator.pop(context, state.userInfo);
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: getForm(context)));
    });
  }

  Widget investmentPriorityForm(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
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
      body: Column(children: [
        Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "How would you like to invest?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: InvestmentPriority.values.map((priority) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    investmentPriorityController.text =
                                        priority.value;
                                    stepperIndex = 1;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    priority.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: investmentPriorityController
                                                .text.isNotEmpty
                                            ? investmentPriorityController
                                                        .text ==
                                                    priority.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            investmentPriorityController.text ==
                                                    priority.value
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (priority != InvestmentPriority.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget investmentHorizonForm(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperIndex = 0;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppTheme.actionButton,
            size: 22,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "When will you need to access your funds?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: InvestmentHorizon.values.map((horizon) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    investmentHorizonController.text =
                                        horizon.value;
                                    stepperIndex = 2;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    horizon.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: investmentHorizonController
                                                .text.isNotEmpty
                                            ? investmentHorizonController
                                                        .text ==
                                                    horizon.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            investmentHorizonController.text ==
                                                    horizon.value
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (horizon != InvestmentHorizon.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget downturnReactionForm(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperIndex = 1;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppTheme.actionButton,
            size: 22,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "How will you react to a downturn?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: DownturnRection.values.map((reaction) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    downturnReactionController.text =
                                        reaction.value;
                                    stepperIndex = 3;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    reaction.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: downturnReactionController
                                                .text.isNotEmpty
                                            ? downturnReactionController.text ==
                                                    reaction.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            downturnReactionController.text ==
                                                    reaction.value
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (reaction != DownturnRection.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget annualIncomeForm(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperIndex = 2;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppTheme.actionButton,
            size: 22,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your annual income?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: AnnualIncome.values.map((income) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    annualIncomeController.text = income.value;
                                    stepperIndex = 4;
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    income.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: annualIncomeController
                                                .text.isNotEmpty
                                            ? annualIncomeController.text ==
                                                    income.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            annualIncomeController.text ==
                                                    income.value
                                                ? FontWeight.bold
                                                : FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (income != AnnualIncome.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget netWorthForm(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperIndex = 3;
            });
          },
          icon: Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppTheme.actionButton,
            size: 22,
          ),
        ),
      ),
      body: Column(children: [
        Expanded(
            child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your net worth?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: NetWorth.values.map((worth) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  netWorthController.text = worth.value;
                                  homeBloc.add(UpdateFinancialProfileEvent(
                                      investmentPriorityController.text,
                                      investmentHorizonController.text,
                                      downturnReactionController.text,
                                      annualIncomeController.text,
                                      netWorthController.text));
                                  //Navigator.pop(context);
                                },
                                child: ListTile(
                                  title: Text(
                                    worth.displayValue,
                                    style: GoogleFonts.poppins(
                                        color:
                                            netWorthController.text.isNotEmpty
                                                ? netWorthController.text ==
                                                        worth.value
                                                    ? AppTheme.primaryDark
                                                    : AppTheme.secondary
                                                        .withOpacity(0.3)
                                                : AppTheme.primary,
                                        fontWeight: netWorthController.text ==
                                                worth.value
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                  trailing: const Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    color: AppTheme.grey,
                                    size: 22,
                                  ),
                                ),
                              ),
                              if (worth != NetWorth.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }
}
