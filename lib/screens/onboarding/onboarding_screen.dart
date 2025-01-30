import 'dart:io';

import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/bloc/plaid_bloc.dart';
import 'package:bondgrid/components/bank_add_confirmation_popover.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/constants/shared_constants.dart';
import 'package:bondgrid/enums/residence_status.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/onboarding/agreement_screen.dart';
import 'package:bondgrid/screens/onboarding/employment_info_screen.dart';
import 'package:bondgrid/screens/onboarding/financial_profile_screen.dart';
import 'package:bondgrid/screens/onboarding/personal_info_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plaid_flutter/plaid_flutter.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({Key? key}) : super(key: key);

  @override
  OnboardingScreenState createState() => OnboardingScreenState();
}

class OnboardingScreenState extends State<OnboardingScreen> {
  LinkConfiguration? _configuration;
  bool _isUserEligible = true;

  List<Task> tasks = [
    Task('Personal Details', Icons.person, 'Pending'),
    Task('Employment Info', Icons.work, 'Pending'),
    Task('Financial Profile', Icons.credit_card, 'Pending'),
    // Task('Link Bank Account', Icons.link, 'Optional'),
  ];

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

    context.read<HomeBloc>().add(GetUserInfoEvent());
  }

  @override
  void dispose() {
    super.dispose();
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

  void checkUserEligibility(UserInfo userInfo) {
    if (userInfo.personalDetails.residenceStatus ==
        ResidenceStatus.NON_RESIDENT) {
      _isUserEligible = false;
    } else {
      _isUserEligible = true;
    }
  }

  Widget ineligibilityWarning(BuildContext context) {
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
                  'Sorry we are unable to open an account for non-US citizens and'
                  ' non-residents at this time. We will reach out to you once we are'
                  ' able to onboard you.',
                  style: GoogleFonts.poppins(
                      fontSize: 14, color: AppTheme.secondary.withOpacity(0.7)),
                  textAlign: TextAlign.center,
                ))));
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

            if (state is GetUserInfoSuccessState) {
              if (state.userInfo.personalDetails.isComplete()) {
                checkUserEligibility(state.userInfo);
                setState(() {
                  tasks[0].status = 'Completed';
                });
              }
              if (state.userInfo.employmentInformation.isComplete()) {
                setState(() {
                  tasks[1].status = 'Completed';
                });
              }
              if (state.userInfo.financialProfile.isComplete()) {
                setState(() {
                  tasks[2].status = 'Completed';
                });
              }
              // if (state.userInfo.paymentsDetails != null &&
              //     state.userInfo.paymentsDetails!.isNotEmpty) {
              //   setState(() {
              //     tasks[3].status = 'Completed';
              //   });
              // }
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
                  setState(() {
                    tasks[3].status = 'Completed';
                  });

                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  showDialog(
                      barrierDismissible: false,
                      barrierColor: Colors.black.withOpacity(0.9),
                      context: context,
                      builder: (context) {
                        return const BankAddConfirmationPopover();
                      });
                }
              },
              child: Scaffold(
                appBar: AppBar(
                  backgroundColor: AppTheme.backgroundColor,
                  automaticallyImplyLeading: false,
                  centerTitle: true,
                  elevation: 0,
                  // title: Text("Account Activation",
                  //     style: GoogleFonts.poppins(
                  //         color: AppTheme.secondary,
                  //         fontWeight: FontWeight.w600,
                  //         fontSize: 16)),
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
                body: AbsorbPointer(
                    absorbing: state.status == HomeStateStatus.loading,
                    child: Stack(children: [
                      SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(
                                        top: 0, bottom: 12),
                                    child: Text(
                                      "Account Activation",
                                      textAlign: TextAlign.center,
                                      style: AppTheme.headingText,
                                    ),
                                  ),
                                  Container(
                                    alignment: Alignment.center,
                                    margin: const EdgeInsets.only(bottom: 15),
                                    child: Text(
                                      "We are required to collect this information for regulatory purposes.",
                                      textAlign: TextAlign.center,
                                      style: AppTheme.secondaryText,
                                    ),
                                  ),
                                  Card(
                                    elevation: AppTheme.cardElevation,
                                    color: AppTheme.nearlyWhite,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: tasks.map((task) {
                                          return Container(
                                              margin: const EdgeInsets.all(2),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                highlightColor:
                                                    Colors.transparent,
                                                onTap: () {
                                                  if (state
                                                      is GetUserInfoSuccessState) {
                                                    // Navigate to the specific task page
                                                    if (task.title ==
                                                        'Personal Details') {
                                                      Navigator.push(
                                                        context,
                                                        (Theme.of(context)
                                                                    .platform ==
                                                                TargetPlatform
                                                                    .iOS)
                                                            ? CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              PersonalInfoScreen(currentValue: state.userInfo.personalDetails),
                                                                        ))
                                                            : MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              PersonalInfoScreen(currentValue: state.userInfo.personalDetails),
                                                                        )),
                                                      ).then(
                                                        (updatedUserInfo) {
                                                          if (updatedUserInfo !=
                                                              null) {
                                                            state.userInfo =
                                                                updatedUserInfo;
                                                            checkUserEligibility(
                                                                state.userInfo);
                                                            setState(() {
                                                              if (updatedUserInfo
                                                                  .personalDetails
                                                                  .isComplete()) {
                                                                tasks[0].status =
                                                                    'Completed';
                                                              }
                                                              if (_allTasksCompleted() &&
                                                                  _isUserEligible) {
                                                                Navigator.push(
                                                                  context,
                                                                  (Theme.of(context)
                                                                              .platform ==
                                                                          TargetPlatform
                                                                              .iOS)
                                                                      ? CupertinoPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              ))
                                                                      : MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              )),
                                                                );
                                                              }
                                                            });
                                                          }
                                                        },
                                                      );
                                                    } else if (task.title ==
                                                        'Employment Info') {
                                                      Navigator.push(
                                                        context,
                                                        (Theme.of(context)
                                                                    .platform ==
                                                                TargetPlatform
                                                                    .iOS)
                                                            ? CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              EmploymentInfoScreen(currentValue: state.userInfo.employmentInformation),
                                                                        ))
                                                            : MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              EmploymentInfoScreen(currentValue: state.userInfo.employmentInformation),
                                                                        )),
                                                      ).then(
                                                        (updatedUserInfo) {
                                                          if (updatedUserInfo !=
                                                              null) {
                                                            state.userInfo =
                                                                updatedUserInfo;
                                                            setState(() {
                                                              if (updatedUserInfo
                                                                  .employmentInformation
                                                                  .isComplete()) {
                                                                tasks[1].status =
                                                                    'Completed';
                                                              }
                                                              if (_allTasksCompleted() &&
                                                                  _isUserEligible) {
                                                                Navigator.push(
                                                                  context,
                                                                  (Theme.of(context)
                                                                              .platform ==
                                                                          TargetPlatform
                                                                              .iOS)
                                                                      ? CupertinoPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              ))
                                                                      : MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              )),
                                                                );
                                                              }
                                                            });
                                                          }
                                                        },
                                                      );
                                                    } else if (task.title ==
                                                        'Financial Profile') {
                                                      Navigator.push(
                                                        context,
                                                        (Theme.of(context)
                                                                    .platform ==
                                                                TargetPlatform
                                                                    .iOS)
                                                            ? CupertinoPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              FinancialProfileScreen(currentValue: state.userInfo.financialProfile),
                                                                        ))
                                                            : MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        BlocProvider(
                                                                          create: (context) =>
                                                                              HomeBloc(HomeRepo()),
                                                                          child:
                                                                              FinancialProfileScreen(currentValue: state.userInfo.financialProfile),
                                                                        )),
                                                      ).then(
                                                        (updatedUserInfo) {
                                                          if (updatedUserInfo !=
                                                              null) {
                                                            state.userInfo =
                                                                updatedUserInfo;
                                                            setState(() {
                                                              if (updatedUserInfo
                                                                  .financialProfile
                                                                  .isComplete()) {
                                                                tasks[2].status =
                                                                    'Completed';
                                                              }
                                                              if (_allTasksCompleted() &&
                                                                  _isUserEligible) {
                                                                Navigator.push(
                                                                  context,
                                                                  (Theme.of(context)
                                                                              .platform ==
                                                                          TargetPlatform
                                                                              .iOS)
                                                                      ? CupertinoPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              ))
                                                                      : MaterialPageRoute(
                                                                          builder: (context) =>
                                                                              BlocProvider(
                                                                                create: (context) => HomeBloc(HomeRepo()),
                                                                                child: const AgreementScreen(),
                                                                              )),
                                                                );
                                                              }
                                                            });
                                                          }
                                                        },
                                                      );
                                                    } else if (task.title ==
                                                        'Link Bank Account') {
                                                      showBankModalSheet(
                                                          context,
                                                          BlocProvider.of<
                                                                  PlaidBloc>(
                                                              context));
                                                    }
                                                  }
                                                },
                                                child: ListTile(
                                                  leading: Icon(task.icon,
                                                      color: AppTheme.primary),
                                                  title: Text(
                                                    task.title,
                                                    style: GoogleFonts.poppins(
                                                        color: AppTheme.primary,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 16),
                                                  ),
                                                  subtitle: Text(task.status,
                                                      style: _getStatusStyle(
                                                          task.status)),
                                                  trailing: const Icon(
                                                      Icons
                                                          .keyboard_arrow_right_rounded,
                                                      color: AppTheme.grey,
                                                      size: 22),
                                                ),
                                              ));
                                        }).toList(),
                                      ),
                                    ),
                                  ),
                                  if (!_isUserEligible)
                                    ineligibilityWarning(context),
                                ])),
                      ),
                      continueButton(context)
                    ])),
              )));
    });
  }

  Widget continueButton(BuildContext context) {
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
                  CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    onPressFunction: _allTasksCompleted() && _isUserEligible
                        ? () {
                            Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const AgreementScreen(),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: const AgreementScreen(),
                                          )),
                            );
                          }
                        : null,
                  )
                ])));
  }

  TextStyle _getStatusStyle(String status) {
    switch (status) {
      case 'Completed':
        return GoogleFonts.poppins(
            color: Colors.green, fontWeight: FontWeight.w600, fontSize: 12);
      case 'Error':
        return GoogleFonts.poppins(
            color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12);
      default:
        return GoogleFonts.poppins(
            color: AppTheme.secondary.withOpacity(0.4),
            fontWeight: FontWeight.w400,
            fontSize: 12);
    }
  }

  bool _allTasksCompleted() {
    return [tasks[0], tasks[1], tasks[2]]
        .every((task) => task.status == 'Completed');
  }
}

class Task {
  final String title;
  final IconData icon;
  String status;

  Task(this.title, this.icon, this.status);
}
