import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/item_picker.dart';
import 'package:bondgrid/enums/employment_status.dart';
import 'package:bondgrid/models/affiliated_exchange.dart';
import 'package:bondgrid/models/employment_information.dart';
import 'package:bondgrid/models/occupation.dart';
import 'package:bondgrid/models/occupation_industry.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';

class EmploymentInfoScreen extends StatefulWidget {
  const EmploymentInfoScreen({Key? key, required this.currentValue})
      : super(key: key);

  final EmploymentInformation currentValue;

  @override
  EmploymentInfoScreenState createState() => EmploymentInfoScreenState();
}

class EmploymentInfoScreenState extends State<EmploymentInfoScreen> {
  int stepperIndex = 0;

  TextEditingController employmentStatusController = TextEditingController();

  FocusNode employerFocusNode = FocusNode();
  TextEditingController employerNameController = TextEditingController();

  final occupationPickerController = ItemPickerController<Occupation>();
  TextEditingController occupationController = TextEditingController();

  final occupationIndustryPickerController =
      ItemPickerController<OccupationIndustry>();
  TextEditingController occupationIndustryController = TextEditingController();

  bool isFinraAffiliated = false;
  bool isPoliticallyExposed = false;
  bool isFamilyPoliticallyExposed = false;
  bool isControlPublicCompany = false;

  //FocusNode affiliatedExchangeFocusNode = FocusNode();
  // final affiliatedExchangePickerController =
  //     ItemPickerController<AffiliatedExchange>();
  // TextEditingController affiliatedExchangeController = TextEditingController();
  List<ItemPickerController<AffiliatedExchange>>
      affiliatedExchangePickerControllers = [
    ItemPickerController<AffiliatedExchange>()
  ];
  List<TextEditingController> affiliatedExchangeControllers = [
    TextEditingController()
  ];

  // FocusNode affiliatedCorporationFocusNode = FocusNode();
  // TextEditingController affiliatedCorporationController =
  //     TextEditingController();
  List<FocusNode> affiliatedCorporationFocusNodes = [FocusNode()];
  List<TextEditingController> affiliatedCorporationControllers = [
    TextEditingController()
  ];

  ValueNotifier<bool> isFormFilled = ValueNotifier(false);

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

    // Initialize controller if currentValue is set
    if (widget.currentValue.employmentStatus != null) {
      employmentStatusController.text =
          widget.currentValue.employmentStatus!.value;
    }

    if (widget.currentValue.employerName?.isNotEmpty ?? false) {
      employerNameController.text = widget.currentValue.employerName!;
    }

    if (widget.currentValue.occupation?.value.isNotEmpty ?? false) {
      occupationController.text = widget.currentValue.occupation!.value;
      occupationPickerController.setItem(widget.currentValue.occupation!);
    }

    if (widget.currentValue.occupationIndustry?.value.isNotEmpty ?? false) {
      occupationIndustryController.text =
          widget.currentValue.occupationIndustry!.value;
      occupationIndustryPickerController
          .setItem(widget.currentValue.occupationIndustry!);
    }

    if (widget.currentValue.isFinraAffiliated ?? false) {
      isFinraAffiliated = widget.currentValue.isFinraAffiliated!;
    }
    if (widget.currentValue.isControlPublicCompany ?? false) {
      isControlPublicCompany = widget.currentValue.isControlPublicCompany!;
    }
    if (widget.currentValue.isPoliticallyExposed ?? false) {
      isPoliticallyExposed = widget.currentValue.isPoliticallyExposed!;
    }
    if (widget.currentValue.isFamilyPoliticallyExposed ?? false) {
      isFamilyPoliticallyExposed =
          widget.currentValue.isFamilyPoliticallyExposed!;
    }

    if (widget.currentValue.affiliatedExchange?.isNotEmpty ?? false) {
      // affiliatedExchangeController.text =
      //     widget.currentValue.affiliatedExchange!.first;
      // final exchange = AffiliatedExchange.findByValue(
      //     widget.currentValue.affiliatedExchange!.first);
      // if (exchange != null) {
      //   affiliatedExchangePickerController.setItem(exchange);
      // }
      affiliatedExchangeControllers = widget.currentValue.affiliatedExchange
              ?.map((item) => TextEditingController(text: item))
              .toList() ??
          [TextEditingController()];
      affiliatedExchangePickerControllers =
          (widget.currentValue.affiliatedExchange
                  ?.map((item) {
                    var controller = ItemPickerController<AffiliatedExchange>();
                    final exchange = AffiliatedExchange.findByValue(item);
                    if (exchange != null) {
                      controller.setItem(exchange);
                      return controller;
                    }
                    return null;
                  })
                  .where((controller) => controller != null)
                  .toList()
                  .cast<ItemPickerController<AffiliatedExchange>>() ??
              [ItemPickerController<AffiliatedExchange>()]);
    }

    if (widget.currentValue.controlCorporation?.isNotEmpty ?? false) {
      // affiliatedCorporationController.text =
      //     widget.currentValue.controlCorporation!.first;
      affiliatedCorporationControllers = widget.currentValue.controlCorporation
              ?.map((item) => TextEditingController(text: item))
              .toList() ??
          [TextEditingController()];
      affiliatedCorporationFocusNodes = widget.currentValue.controlCorporation
              ?.map((item) => FocusNode())
              .toList() ??
          [FocusNode()];
    }

    employerNameController.addListener(() => updateFormFilled());
    occupationController.addListener(() => updateFormFilled());
    occupationIndustryController.addListener(() => updateFormFilled());

    updateFormFilled();
  }

  @override
  void dispose() {
    employerNameController.removeListener(updateFormFilled);
    occupationController.removeListener(updateFormFilled);
    occupationIndustryController.removeListener(updateFormFilled);

    employerNameController.dispose();
    occupationController.dispose();
    occupationIndustryController.dispose();

    isFormFilled.dispose();
    super.dispose();
  }

  void updateFormFilled() {
    isFormFilled.value = employerNameController.text.isNotEmpty &&
        occupationController.text.isNotEmpty &&
        occupationIndustryController.text.isNotEmpty;
  }

  Widget getForm(BuildContext context, HomeState state) {
    if (stepperIndex == 0) {
      return statusForm(context);
    } else if (stepperIndex == 1) {
      return employerForm(context);
    } else if (stepperIndex == 2) {
      return occupationForm(context);
    } else if (stepperIndex == 3) {
      return occupationIndustryForm(context);
    } else if (stepperIndex == 4) {
      return affiliationForm(context, state);
    } else if (stepperIndex == 5) {
      return affiliatedExchangeForm(context, state);
    } else if (stepperIndex == 6) {
      return corporationAffiliationForm(context, state);
    } else {
      return statusForm(context);
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

            if (state is UpdateEmploymentInfoSuccessState) {
              Navigator.pop(context, state.userInfo);
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: getForm(context, state)));
    });
  }

  Widget statusForm(BuildContext context) {
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
                  "What is your employment status?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              // Container(
              //   alignment: Alignment.center,
              //   margin: const EdgeInsets.only(bottom: 32),
              //   child: Text(
              //     'We are legally required to collect this information.',
              //     textAlign: TextAlign.center,
              //     style: AppTheme.secondaryText,
              //   ),
              // ),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: EmploymentStatus.values.map((status) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    employmentStatusController.text =
                                        status.value;
                                    if (status == EmploymentStatus.EMPLOYED ||
                                        status ==
                                            EmploymentStatus.SELF_EMPLOYED) {
                                      if (occupationController.text ==
                                          "TITLE__NOT__APPLICABLE__UNEMPLOYED") {
                                        occupationController.text = "";
                                        occupationPickerController.clear();
                                      }

                                      if (occupationIndustryController.text ==
                                          "INDUSTRY__NOT__APPLICABLE__UNEMPLOYED") {
                                        occupationIndustryController.text = "";
                                        occupationIndustryPickerController
                                            .clear();
                                      }

                                      stepperIndex = 1;
                                    } else {
                                      employerNameController.text = "";
                                      occupationController.text =
                                          "TITLE__NOT__APPLICABLE__UNEMPLOYED";
                                      occupationIndustryController.text =
                                          "INDUSTRY__NOT__APPLICABLE__UNEMPLOYED";
                                      stepperIndex = 4;
                                    }
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    status.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: employmentStatusController
                                                .text.isNotEmpty
                                            ? employmentStatusController.text ==
                                                    status.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            employmentStatusController.text ==
                                                    status.value
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
                              if (status != EmploymentStatus.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget employerForm(BuildContext context) {
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Request focus once the frame rendering is complete.
    //   employerFocusNode.requestFocus();
    // });

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "Employer Information",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'We are legally required to collect this information.',
                  textAlign: TextAlign.center,
                  style: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              InputBox(
                  controller: employerNameController,
                  focusNode: employerFocusNode,
                  enabled: true,
                  isInputCenter: true,
                  label: "Employer Name"),
              ItemPickerWidget<Occupation>(
                onItemChanged: (selectedOccupation) {
                  occupationController.text = selectedOccupation.value;
                },
                label: "Occupation",
                enabled: false,
                controller: occupationPickerController,
                items: Occupation.ALL,
                displayName: (Occupation occupation) => occupation.displayValue,
                uniqueId: (Occupation occupation) => occupation.value,
              ),
              ItemPickerWidget<OccupationIndustry>(
                onItemChanged: (selectedOccupationIndustry) {
                  occupationIndustryController.text =
                      selectedOccupationIndustry.value;
                },
                label: "Occupation Industry",
                enabled: false,
                controller: occupationIndustryPickerController,
                items: OccupationIndustry.ALL,
                displayName: (OccupationIndustry occupationIndustry) =>
                    occupationIndustry.displayValue,
                uniqueId: (OccupationIndustry occupationIndustry) =>
                    occupationIndustry.value,
              )
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<bool>(
            valueListenable: isFormFilled,
            builder: (BuildContext context, bool isFilled, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: isFilled
                    ? () {
                        setState(() {
                          stepperIndex = 4;
                        });
                      }
                    : null,
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget occupationForm(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your occupation?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              ItemPickerWidget<Occupation>(
                onItemChanged: (selectedOccupation) {
                  occupationController.text = selectedOccupation.value;
                },
                label: "Occupation",
                enabled: false,
                controller: occupationPickerController,
                items: Occupation.ALL,
                displayName: (Occupation occupation) => occupation.displayValue,
                uniqueId: (Occupation occupation) => occupation.value,
              )
              // InputBox(
              //     controller: occupationController,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Occupation"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: occupationController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: value.text.isEmpty
                    ? null
                    : () {
                        setState(() {
                          stepperIndex = 3;
                        });
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget occupationIndustryForm(BuildContext context) {
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your occupation industry?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              ItemPickerWidget<OccupationIndustry>(
                onItemChanged: (selectedOccupationIndustry) {
                  occupationIndustryController.text =
                      selectedOccupationIndustry.value;
                },
                label: "Occupation Industry",
                enabled: false,
                controller: occupationIndustryPickerController,
                items: OccupationIndustry.ALL,
                displayName: (OccupationIndustry occupationIndustry) =>
                    occupationIndustry.displayValue,
                uniqueId: (OccupationIndustry occupationIndustry) =>
                    occupationIndustry.value,
              )
              // InputBox(
              //     controller: occupationIndustryController,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Occupation Industry"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: occupationIndustryController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: value.text.isEmpty
                    ? null
                    : () {
                        setState(() {
                          stepperIndex = 4;
                        });
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget affiliationForm(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              if (employmentStatusController.text ==
                      EmploymentStatus.EMPLOYED.value ||
                  employmentStatusController.text ==
                      EmploymentStatus.SELF_EMPLOYED.value) {
                stepperIndex = 3;
              } else {
                stepperIndex = 0;
              }
            });
          },
          icon: const Icon(
            Icons.keyboard_arrow_left_rounded,
            color: AppTheme.grey,
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
                  "Do any of these apply to you?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'We are required to ask this information for regulatory purposes.',
                  textAlign: TextAlign.center,
                  style: AppTheme.secondaryText,
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
                      child: Column(children: [
                        InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () {
                              isFinraAffiliated = false;
                              isControlPublicCompany = false;
                              isPoliticallyExposed = false;
                              isFamilyPoliticallyExposed = false;

                              homeBloc.add(UpdateEmploymentInfoEvent(
                                  employmentStatusController.text,
                                  employerNameController.text,
                                  occupationController.text,
                                  occupationIndustryController.text,
                                  isFinraAffiliated,
                                  isControlPublicCompany,
                                  isPoliticallyExposed,
                                  isFamilyPoliticallyExposed,
                                  const [],
                                  const []));
                              //Navigator.pop(context);
                            },
                            child: ListTile(
                              title: Text(
                                'None of these apply to me',
                                style: GoogleFonts.poppins(
                                    color: AppTheme.primary,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15),
                              ),
                              trailing: const Icon(
                                Icons.keyboard_arrow_right_rounded,
                                color: AppTheme.grey,
                                size: 22,
                              ),
                            )),
                      ]))),
              const SizedBox(height: 15),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(children: [
                        CheckboxListTile(
                          title: Text(
                            'Are you or anyone in your immediate family affiliated with a brokerage firm or FINRA?',
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          value: isFinraAffiliated,
                          onChanged: (bool? value) {
                            setState(() {
                              isFinraAffiliated = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                        ),
                        const Divider(),
                        CheckboxListTile(
                          title: Text(
                            'Are you or is anyone in your immediate family a senior executive or 10% or greater shareholder at a publicly traded company?',
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          value: isControlPublicCompany,
                          onChanged: (bool? value) {
                            setState(() {
                              isControlPublicCompany = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                        ),
                        const Divider(),
                        CheckboxListTile(
                          title: Text(
                            'Are you a politically exposed person?',
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          value: isPoliticallyExposed,
                          onChanged: (bool? value) {
                            setState(() {
                              isPoliticallyExposed = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                        ),
                        const Divider(),
                        CheckboxListTile(
                          title: Text(
                            'Is anyone in your immediate family politically exposed?',
                            style: GoogleFonts.poppins(
                                color: AppTheme.primary,
                                fontWeight: FontWeight.w500,
                                fontSize: 15),
                          ),
                          value: isFamilyPoliticallyExposed,
                          onChanged: (bool? value) {
                            setState(() {
                              isFamilyPoliticallyExposed = value!;
                            });
                          },
                          activeColor: AppTheme.primary,
                        ),
                      ]))),
            ])),
        Card(
            color: AppTheme.backgroundColor,
            elevation: 0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: employerNameController,
                builder: (BuildContext context, TextEditingValue value,
                    Widget? child) {
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading: state is UpdateEmploymentInfoLoadingState,
                    onPressFunction: state is UpdateEmploymentInfoLoadingState
                        ? null
                        : (isFinraAffiliated ||
                                isControlPublicCompany ||
                                isPoliticallyExposed ||
                                isFamilyPoliticallyExposed)
                            ? () {
                                if (isFinraAffiliated) {
                                  setState(() {
                                    stepperIndex = 5;
                                  });
                                } else if (isControlPublicCompany) {
                                  setState(() {
                                    stepperIndex = 6;
                                  });
                                } else {
                                  homeBloc.add(UpdateEmploymentInfoEvent(
                                      employmentStatusController.text,
                                      employerNameController.text,
                                      occupationController.text,
                                      occupationIndustryController.text,
                                      isFinraAffiliated,
                                      isControlPublicCompany,
                                      isPoliticallyExposed,
                                      isFamilyPoliticallyExposed,
                                      const [],
                                      const []));
                                  //Navigator.pop(context);
                                }
                              }
                            : null,
                  );
                },
              ),
            )),
      ]),
    );
  }

  Widget affiliatedExchangeForm(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // Request focus once the frame rendering is complete.
    //   affiliatedExchangeFocusNode.requestFocus();
    // });

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperIndex = 4;
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your affiliation with a brokerage firm or FINRA?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                  children: affiliatedExchangeControllers
                      .asMap()
                      .entries
                      .map((entry) {
                int index = entry.key;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: ItemPickerWidget<AffiliatedExchange>(
                          onItemChanged: (exchange) {
                            affiliatedExchangeControllers[index].text =
                                exchange.value;
                          },
                          enabled: false,
                          label: "MIC Identifier",
                          controller:
                              affiliatedExchangePickerControllers[index],
                          items: AffiliatedExchange.ALL,
                          displayName: (AffiliatedExchange exchange) =>
                              exchange.displayValue,
                          uniqueId: (AffiliatedExchange exchange) =>
                              exchange.value,
                          showDeleteButton:
                              affiliatedExchangePickerControllers.length > 1
                                  ? true
                                  : false,
                          deleteFunction:
                              affiliatedExchangePickerControllers.length > 1
                                  ? () {
                                      setState(() {
                                        affiliatedExchangeControllers
                                            .removeAt(index);
                                        affiliatedExchangePickerControllers
                                            .removeAt(index);
                                      });
                                    }
                                  : null,
                          deleteWidget: Icon(Icons.delete,
                              color: Colors.red.withOpacity(0.7), size: 27),
                        ))
                      ],
                    )
                  ],
                );
              }).toList()),
              const SizedBox(height: 5),
              Material(
                elevation: 0.0,
                color: Colors.transparent,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: affiliatedExchangeControllers.last,
                  builder: (BuildContext context, TextEditingValue value,
                      Widget? child) {
                    return IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      color: AppTheme.primary,
                      iconSize: 35.0,
                      onPressed: value.text.isEmpty
                          ? null
                          : () {
                              setState(() {
                                affiliatedExchangeControllers
                                    .add(TextEditingController());
                                affiliatedExchangePickerControllers.add(
                                    ItemPickerController<AffiliatedExchange>());
                              });
                            },
                    );
                  },
                ),
              )
              // ItemPickerWidget<AffiliatedExchange>(
              //     onItemChanged: (selectedItem) {
              //       affiliatedExchangeController.text = selectedItem.value;
              //     },
              //     controller: affiliatedExchangePickerController,
              //     label: "MIC Identifier",
              //     items: AffiliatedExchange.ALL,
              //     displayName: (AffiliatedExchange item) => item.displayValue,
              //     uniqueId: (AffiliatedExchange item) => item.value)
              // InputBox(
              //     controller: affiliatedExchangeController,
              //     //autofocus: true,
              //     focusNode: affiliatedExchangeFocusNode,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "MIC Identifier"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: affiliatedExchangeControllers.last,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                isLoading: state is UpdateEmploymentInfoLoadingState,
                onPressFunction: value.text.isEmpty ||
                        state is UpdateEmploymentInfoLoadingState
                    ? null
                    : () {
                        if (isControlPublicCompany) {
                          setState(() {
                            stepperIndex = 6;
                          });
                        } else {
                          homeBloc.add(UpdateEmploymentInfoEvent(
                              employmentStatusController.text,
                              employerNameController.text,
                              occupationController.text,
                              occupationIndustryController.text,
                              isFinraAffiliated,
                              isControlPublicCompany,
                              isPoliticallyExposed,
                              isFamilyPoliticallyExposed,
                              affiliatedExchangeControllers
                                  .map((controller) => controller.text)
                                  .toList(),
                              const []));
                          //Navigator.pop(context);
                        }
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget corporationAffiliationForm(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      affiliatedCorporationFocusNodes.last.requestFocus();
    });

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            if (isFinraAffiliated) {
              setState(() {
                stepperIndex = 5;
              });
            } else {
              setState(() {
                stepperIndex = 4;
              });
            }
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is the name of the publicly traded company that you're associated with?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              const SizedBox(height: 10),
              Column(
                children: affiliatedCorporationControllers
                    .asMap()
                    .entries
                    .map((entry) {
                  int index = entry.key;
                  TextEditingController controller = entry.value;
                  return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InputBox(
                                controller: controller,
                                focusNode:
                                    affiliatedCorporationFocusNodes[index],
                                enabled: true,
                                isInputCenter: true,
                                label: "Stock Symbol",
                                showDeleteButton:
                                    affiliatedCorporationControllers.length > 1
                                        ? true
                                        : false,
                                deleteFunction:
                                    affiliatedCorporationControllers.length > 1
                                        ? () {
                                            setState(() {
                                              affiliatedCorporationControllers
                                                  .removeAt(index);
                                              affiliatedCorporationFocusNodes
                                                  .removeAt(index);
                                            });
                                          }
                                        : null,
                                deleteWidget: Icon(
                                  Icons.delete,
                                  color: Colors.red.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ],
                        )
                      ]);
                }).toList(),
              ),
              Material(
                elevation: 0.0,
                color: Colors.transparent,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: affiliatedCorporationControllers.last,
                  builder: (BuildContext context, TextEditingValue value,
                      Widget? child) {
                    return IconButton(
                      icon: const Icon(Icons.add_circle_rounded),
                      color: AppTheme.primary,
                      iconSize: 35.0,
                      onPressed: value.text.isEmpty
                          ? null
                          : () {
                              setState(() {
                                affiliatedCorporationControllers
                                    .add(TextEditingController());
                                affiliatedCorporationFocusNodes
                                    .add(FocusNode());
                              });
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                affiliatedCorporationFocusNodes.last
                                    .requestFocus();
                              });
                            },
                    );
                  },
                ),
              )
              // InputBox(
              //     controller: affiliatedCorporationController,
              //     //autofocus: true,
              //     focusNode: affiliatedCorporationFocusNode,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Stock Symbol"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: affiliatedCorporationControllers.last,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                isLoading: state is UpdateEmploymentInfoLoadingState,
                onPressFunction: value.text.isEmpty ||
                        state is UpdateEmploymentInfoLoadingState
                    ? null
                    : () {
                        homeBloc.add(UpdateEmploymentInfoEvent(
                            employmentStatusController.text,
                            employerNameController.text,
                            occupationController.text,
                            occupationIndustryController.text,
                            isFinraAffiliated,
                            isControlPublicCompany,
                            isPoliticallyExposed,
                            isFamilyPoliticallyExposed,
                            affiliatedExchangeControllers.isNotEmpty &&
                                    isFinraAffiliated
                                ? affiliatedExchangeControllers
                                    .map((controller) => controller.text)
                                    .toList()
                                : const [],
                            affiliatedCorporationControllers
                                .map((controller) => controller.text)
                                .toList()));
                        //Navigator.pop(context);
                      },
              );
            },
          ),
        ),
      ]),
    );
  }
}
