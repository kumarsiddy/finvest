import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/address_search_box.dart';
import 'package:bondgrid/enums/residence_status.dart';
import 'package:bondgrid/models/country.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/date_input_box.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/item_picker.dart';
import 'package:bondgrid/components/ssn_input_box.dart';
import 'package:bondgrid/models/us_state.dart';
import 'package:bondgrid/models/personal_details.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({Key? key, required this.currentValue})
      : super(key: key);

  final PersonalDetails currentValue;

  @override
  PersonalInfoScreenState createState() => PersonalInfoScreenState();
}

enum StepperForm {
  dateOfBirthForm,
  addressForm,
  citizenshipForm,
  residenceStatusForm,
  countryOfTaxResidenceForm,
  stateOfTaxResidenceForm,
  taxIDForm
}

class PersonalInfoScreenState extends State<PersonalInfoScreen> {
  StepperForm stepperForm = StepperForm.dateOfBirthForm;
  bool isUSACitizen = false;
  bool isUSAResident = false;

  TextEditingController dateOfBirthController = TextEditingController();

  TextEditingController addressController = TextEditingController();
  TextEditingController streetController = TextEditingController();
  TextEditingController additionalController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  final regionPickerController = ItemPickerController<USState>();
  TextEditingController regionController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryCountroller = TextEditingController();
  ItemPickerController<Country> countryPickerController =
      ItemPickerController<Country>();

  ValueNotifier<bool> formFilledNotifier = ValueNotifier(false);

  // final citizenshipCountryPickerController = ItemPickerController<Country>();
  // TextEditingController citizenshipController = TextEditingController();
  List<ItemPickerController<Country>> citizenshipCountryPickerControllers = [
    ItemPickerController<Country>()
  ];
  List<TextEditingController> citizenshipControllers = [
    TextEditingController()
  ];

  final countryOfTaxResidencePickerController = ItemPickerController<Country>();
  TextEditingController countryOfTaxResidenceController =
      TextEditingController();

  final stateOfTaxResidencePickerController = ItemPickerController<USState>();
  TextEditingController stateOfTaxResidenceController = TextEditingController();

  TextEditingController taxIDController = TextEditingController();

  TextEditingController residenceStatusController = TextEditingController();

  FocusNode dateOfBirthFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode citizenshipFocusNode = FocusNode();
  FocusNode countryofTaxResidenceFocusNode = FocusNode();
  FocusNode stateofTaxResidenceFocusNode = FocusNode();
  FocusNode taxIdFocusNode = FocusNode();

  String addressWarning = '';

  ValueNotifier<bool> isDOBVaild = ValueNotifier(false);
  String dobInvalidWarning = '';

  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  bool isKeyboardVisible = false;

  void updateFormStatus() {
    formFilledNotifier.value = streetController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        postalCodeController.text.isNotEmpty &&
        regionController.text.isNotEmpty &&
        countryCountroller.text.isNotEmpty &&
        (isUSAResident && !isUSACitizen
            ? countryCountroller.text == 'USA'
            : true);

    String message = '';
    if (streetController.text.isEmpty) {
      message = 'Street Address is missing.';
    } else if (cityController.text.isEmpty) {
      message = 'City is missing.';
    } else if (regionController.text.isEmpty) {
      message = 'State/Region is missing.';
    } else if (countryCountroller.text.isEmpty) {
      message = 'Country is missing.';
    } else if (postalCodeController.text.isEmpty) {
      message = 'Postal code is missing.';
    } else if (isUSAResident &&
        !isUSACitizen &&
        countryCountroller.text != 'USA') {
      message =
          'When the user\'s residence status is set to `RESIDENT`, the country of address must be `USA`';
    }

    setState(() {
      addressWarning = message;
    });
  }

  void isDOBvalid() {
    String message = '';
    if (dateOfBirthController.text.isNotEmpty &&
        dateOfBirthController.text.length >= 10) {
      try {
        List<String> parts = dateOfBirthController.text.split('/');
        int year = int.parse(parts[2]);
        int month = int.parse(parts[0]);
        int day = int.parse(parts[1]);

        if (month < 1 || month > 12) {
          message = 'Invalid month. Please enter a month between 01 and 12.';
          isDOBVaild.value = false;
          setState(() {
            dobInvalidWarning = message;
          });
          return;
        }

        DateTime dob = DateTime(year, month, day);
        if (day != dob.day) {
          message = 'Invalid day for the given month and year.';
          isDOBVaild.value = false;
          setState(() {
            dobInvalidWarning = message;
          });
          return;
        }
        DateTime today = DateTime.now();

        if (dob.isAfter(today)) {
          message = 'Date of birth cannot be in the future.';
          isDOBVaild.value = false;
        } else {
          int age = today.year - dob.year;
          if (dob.month > today.month ||
              (dob.month == today.month && dob.day > today.day)) {
            age--;
          }

          if (age >= 18) {
            message = '';
            isDOBVaild.value = true;
          } else {
            message = 'You must be at least 18 years old.';
            isDOBVaild.value = false;
          }
        }
      } catch (e) {
        // Handle parsing error
        message = 'Invalid date format.';
        isDOBVaild.value = false;
      }
    } else {
      message = '';
      isDOBVaild.value = false;
    }

    setState(() {
      dobInvalidWarning = message;
    });
  }

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
    if (widget.currentValue.dateOfBirth?.isNotEmpty ?? false) {
      DateTime parsedDate = DateTime.parse(widget.currentValue.dateOfBirth!);
      String formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);
      dateOfBirthController.text = formattedDate;
    }

    if (widget.currentValue.street?.isNotEmpty ?? false) {
      streetController.text = widget.currentValue.street!;
    }
    if (widget.currentValue.additional?.isNotEmpty ?? false) {
      additionalController.text = widget.currentValue.additional!;
    }
    if (widget.currentValue.city?.isNotEmpty ?? false) {
      cityController.text = widget.currentValue.city!;
    }
    if (widget.currentValue.region?.isNotEmpty ?? false) {
      regionController.text = widget.currentValue.region!;
      final state = USState.findByCode(widget.currentValue.region!);
      if (state != null) {
        regionPickerController.setItem(state);
      }
    }
    if (widget.currentValue.postalCode?.isNotEmpty ?? false) {
      postalCodeController.text = widget.currentValue.postalCode!;
    }
    if (widget.currentValue.countryCode?.isNotEmpty ?? false) {
      countryCountroller.text = widget.currentValue.countryCode!;
      final country = Country.findByIsoCode(widget.currentValue.countryCode!);
      if (country != null) {
        countryPickerController.setItem(country);
      }
    }

    if (widget.currentValue.countryOfCitizenship?.isNotEmpty ?? false) {
      // citizenshipController.text =
      //     widget.currentValue.countryOfCitizenship!.first;
      // citizenshipCountryPickerController.setItem(Country.findByIsoCode(
      //     widget.currentValue.countryOfCitizenship!.first));
      citizenshipControllers = widget.currentValue.countryOfCitizenship
              ?.map((item) => TextEditingController(text: item))
              .toList() ??
          [TextEditingController()];
      citizenshipCountryPickerControllers =
          (widget.currentValue.countryOfCitizenship
                  ?.map((item) {
                    var controller = ItemPickerController<Country>();
                    final country = Country.findByIsoCode(item);
                    if (country != null) {
                      controller.setItem(country);
                      return controller;
                    }
                    return null;
                  })
                  .where((controller) => controller != null)
                  .toList()
                  .cast<ItemPickerController<Country>>() ??
              [ItemPickerController<Country>()]);
    }

    if (widget.currentValue.residenceStatus != null) {
      residenceStatusController.text =
          widget.currentValue.residenceStatus!.value;
    }

    if (widget.currentValue.countryOfTaxResidence?.isNotEmpty ?? false) {
      countryOfTaxResidenceController.text =
          widget.currentValue.countryOfTaxResidence!;
      final country =
          Country.findByIsoCode(widget.currentValue.countryOfTaxResidence!);
      if (country != null) {
        countryOfTaxResidencePickerController.setItem(country);
      }
    }
    if (widget.currentValue.stateOfTaxResidence?.isNotEmpty ?? false) {
      stateOfTaxResidenceController.text =
          widget.currentValue.stateOfTaxResidence!;
      final state =
          USState.findByCode(widget.currentValue.stateOfTaxResidence!);
      if (state != null) {
        stateOfTaxResidencePickerController.setItem(state);
      }
    }
    if (widget.currentValue.taxID?.isNotEmpty ?? false) {
      taxIDController.text = widget.currentValue.taxID!;
    }

    streetController.addListener(updateFormStatus);
    cityController.addListener(updateFormStatus);
    postalCodeController.addListener(updateFormStatus);
    regionController.addListener(updateFormStatus);
    countryCountroller.addListener(updateFormStatus);

    updateFormStatus();

    dateOfBirthController.addListener(isDOBvalid);
    isDOBvalid();
  }

  @override
  void dispose() {
    streetController.removeListener(updateFormStatus);
    cityController.removeListener(updateFormStatus);
    postalCodeController.removeListener(updateFormStatus);
    regionController.removeListener(updateFormStatus);
    countryCountroller.removeListener(updateFormStatus);
    dateOfBirthController.removeListener(isDOBvalid);
    super.dispose();
  }

  Widget getForm(BuildContext context, HomeState state) {
    if (stepperForm == StepperForm.dateOfBirthForm) {
      return dateOfBirthForm(context);
    } else if (stepperForm == StepperForm.addressForm) {
      return addressForm(context, state);
    } else if (stepperForm == StepperForm.citizenshipForm) {
      return citizenshipForm(context);
    } else if (stepperForm == StepperForm.residenceStatusForm) {
      return residenceStatusForm(context);
    } else if (stepperForm == StepperForm.countryOfTaxResidenceForm) {
      return countryOfTaxResidenceForm(context);
    } else if (stepperForm == StepperForm.stateOfTaxResidenceForm) {
      return stateOfTaxResidenceForm(context);
    } else {
      return taxIDForm(context, state);
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

            if (state is UpdatePersonalDetailsSuccessState) {
              Navigator.pop(context, state.userInfo);
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: getForm(context, state)));
    });
  }

  Widget dateOfBirthForm(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      dateOfBirthFocusNode.requestFocus();
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
                padding: const EdgeInsets.symmetric(horizontal: 20),
                physics: const BouncingScrollPhysics(),
                children: [
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(top: 20, bottom: 12),
                child: Text(
                  "What is your date of birth?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'You need to be 18 years or older to invest through the Finvest app.',
                  textAlign: TextAlign.center,
                  style: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              DateInputBox(
                  controller: dateOfBirthController,
                  isNumberInput: true,
                  //autofocus: true,
                  focusNode: dateOfBirthFocusNode,
                  enabled: true,
                  isInputCenter: true,
                  label: "MM / DD / YYYY"),
              dobInvalidWarning != ''
                  ? Text(dobInvalidWarning, style: AppTheme.warningMessage)
                  : const SizedBox.shrink()
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<bool>(
            valueListenable: isDOBVaild,
            builder: (BuildContext context, bool isValid, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: isValid
                    ? () {
                        setState(() {
                          stepperForm = StepperForm.citizenshipForm;
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

  Widget addressForm(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      addressFocusNode.requestFocus();
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
            // setState(() {
            //   stepperForm = StepperForm.dateOfBirthForm;
            // });
            if (isUSACitizen) {
              setState(() {
                stepperForm = StepperForm.citizenshipForm;
              });
            } else {
              setState(() {
                stepperForm = StepperForm.residenceStatusForm;
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
                  "What is your residential address?",
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
              BlocProvider<HomeBloc>(
                create: (context) => HomeBloc(HomeRepo()),
                child: AddressSearchBox(
                  streetController: streetController,
                  additionalController: additionalController,
                  cityController: cityController,
                  postalCodeController: postalCodeController,
                  regionController: regionController,
                  countryCountroller: countryCountroller,
                  countryPickerController: countryPickerController,
                  focusNode: addressFocusNode,
                ),
              ),
              // AddressSearchBox(
              //   controller: addressController,
              //   focusNode: addressFocusNode,
              // ),
              const SizedBox(height: 10),
              InputBox(
                  controller: streetController,
                  //autofocus: true,
                  //focusNode: addressFocusNode,
                  enabled: true,
                  isInputCenter: true,
                  label: "Street Address"),
              InputBox(
                  controller: additionalController,
                  enabled: true,
                  isInputCenter: true,
                  label: "Apt, Unit, or Building #"),
              InputBox(
                  controller: cityController,
                  enabled: true,
                  isInputCenter: true,
                  label: "City"),
              InputBox(
                  controller: regionController,
                  enabled: true,
                  isInputCenter: true,
                  label: "State"),
              InputBox(
                  controller: postalCodeController,
                  enabled: true,
                  isInputCenter: true,
                  label: "ZIP Code"),
              ItemPickerWidget<Country>(
                onItemChanged: (selectedCountry) {
                  countryCountroller.text = selectedCountry.isoCode;
                },
                label: "Country",
                enabled: false,
                controller: countryPickerController,
                items: Country.ALL,
                displayName: (Country country) => country.name,
                uniqueId: (Country country) => country.isoCode,
              ),
              // InputBox(
              //     controller: countryCountroller,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Country"),
              addressWarning != ''
                  ? Text(addressWarning, style: AppTheme.warningMessage)
                  : const SizedBox.shrink()
              // ItemPickerWidget<USState>(
              //   onItemChanged: (selectedState) {
              //     regionController.text = selectedState.code;
              //   },
              //   label: "State",
              //   enabled: false,
              //   controller: regionPickerController,
              //   items: USState.allStates,
              //   displayName: (USState state) => state.name,
              //   uniqueId: (USState state) => state.code,
              // )
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<bool>(
            valueListenable: formFilledNotifier,
            builder: (BuildContext context, bool isFormFilled, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                isLoading: state is UpdatePersonalDetailsLoadingState,
                onPressFunction:
                    isFormFilled && state is! UpdatePersonalDetailsLoadingState
                        ? () {
                            setState(() {
                              stateOfTaxResidenceController.text =
                                  regionController.text;
                              countryOfTaxResidenceController.text =
                                  countryCountroller.text;
                              if (isUSAResident || isUSACitizen) {
                                stepperForm = StepperForm.taxIDForm;
                              } else {
                                homeBloc.add(UpdatePersonalDetailsEvent(
                                    dateOfBirthController.text,
                                    countryCountroller.text,
                                    streetController.text,
                                    additionalController.text,
                                    cityController.text,
                                    regionController.text,
                                    postalCodeController.text,
                                    citizenshipControllers
                                        .map((controller) => controller.text)
                                        .toList(),
                                    countryOfTaxResidenceController.text,
                                    stateOfTaxResidenceController.text,
                                    residenceStatusController.text,
                                    taxIDController.text));
                              }
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

  Widget citizenshipForm(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      citizenshipFocusNode.requestFocus();
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
            setState(() {
              stepperForm = StepperForm.dateOfBirthForm;
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
                  "Where are you a citizen?",
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
              Column(
                  children: citizenshipControllers.asMap().entries.map((entry) {
                int index = entry.key;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: ItemPickerWidget<Country>(
                          onItemChanged: (selectedCountry) {
                            citizenshipControllers[index].text =
                                selectedCountry.isoCode;
                          },
                          label: "Country of Citizenship",
                          enabled: false,
                          controller:
                              citizenshipCountryPickerControllers[index],
                          items: Country.ALL,
                          displayName: (Country country) => country.name,
                          uniqueId: (Country country) => country.isoCode,
                          showDeleteButton:
                              citizenshipCountryPickerControllers.length > 1
                                  ? true
                                  : false,
                          deleteFunction:
                              citizenshipCountryPickerControllers.length > 1
                                  ? () {
                                      setState(() {
                                        citizenshipControllers.removeAt(index);
                                        citizenshipCountryPickerControllers
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
                  valueListenable: citizenshipControllers.last,
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
                                citizenshipControllers
                                    .add(TextEditingController());
                                citizenshipCountryPickerControllers
                                    .add(ItemPickerController<Country>());
                              });
                            },
                    );
                  },
                ),
              )
              // ItemPickerWidget<Country>(
              //   onItemChanged: (selectedCountry) {
              //     citizenshipController.text = selectedCountry.isoCode;
              //   },
              //   label: "Country of Citizenship",
              //   controller: citizenshipCountryPickerController,
              //   items: Country.ALL,
              //   displayName: (Country country) => country.name,
              //   uniqueId: (Country country) => country.isoCode,
              // )
              // InputBox(
              //     controller: citizenshipController,
              //     //autofocus: true,
              //     focusNode: citizenshipFocusNode,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Country of Citizenship"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: citizenshipControllers.last,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: value.text.isEmpty
                    ? null
                    : () {
                        isUSACitizen = false;
                        for (TextEditingController controller
                            in citizenshipControllers) {
                          if (controller.text == "USA") {
                            isUSACitizen = true;
                          }
                        }
                        if (isUSACitizen) {
                          setState(() {
                            residenceStatusController.text =
                                ResidenceStatus.CITIZEN.value;
                            stepperForm = StepperForm.addressForm;
                          });
                        } else {
                          setState(() {
                            stepperForm = StepperForm.residenceStatusForm;
                          });
                        }
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget residenceStatusForm(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            setState(() {
              stepperForm = StepperForm.citizenshipForm;
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
                  "What is your residence status in the US for tax purposes?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'To be considered a US resident for tax purposes, you must either:',
                  textAlign: TextAlign.center,
                  style: AppTheme.secondaryText,
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  //style: DefaultTextStyle.of(context).style,
                  children: <InlineSpan>[
                    // const WidgetSpan(
                    //   child: Icon(Icons.document_scanner_rounded,
                    //       color: AppTheme.secondary),
                    //   alignment: PlaceholderAlignment.middle,
                    // ),
                    TextSpan(
                      text: "Meet the permanent residency test, or\n",
                      style: AppTheme.secondaryTextBold,
                    ),
                    TextSpan(
                      text:
                          "This requires that you have a US Permanent Resident Card, also known as a US Green Card\n\n",
                      style: AppTheme.secondaryText,
                    ),
                  ],
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <InlineSpan>[
                    // const WidgetSpan(
                    //   child: Icon(Icons.savings_rounded,
                    //       color: AppTheme.secondary),
                    //   alignment: PlaceholderAlignment.middle,
                    // ),
                    TextSpan(
                      text: "Meet the substantial presence test\n",
                      style: AppTheme.secondaryTextBold,
                    ),
                    TextSpan(
                      text:
                          "This requires that you have been in the US for at least 31 days during the current calendar year and at least 183 days during the last three years\n\n",
                      style: AppTheme.secondaryText,
                    ),
                  ],
                ),
              ),
              // Container(
              //   alignment: Alignment.center,
              //   margin: const EdgeInsets.only(bottom: 32),
              //   child: Text(
              //     'You are considered a US resident if you have a US Permanent Resident'
              //     ' Card (i.e., a US Green Card) or you’ve been in the US for at least'
              //     ' 31 days during the current calendar year and at least 183 days during'
              //     ' the last 3 years.',
              //     textAlign: TextAlign.center,
              //     style: AppTheme.secondaryText,
              //   ),
              // ),
              const SizedBox(height: 10),
              Card(
                  elevation: AppTheme.cardElevation,
                  color: AppTheme.nearlyWhite,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: ResidenceStatus.values.where((status) {
                          return status.value != ResidenceStatus.CITIZEN.value;
                        }).map((status) {
                          return Column(
                            children: [
                              InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  setState(() {
                                    residenceStatusController.text =
                                        status.value;
                                    stepperForm = StepperForm.addressForm;

                                    isUSAResident = status.value ==
                                        ResidenceStatus.RESIDENT.value;
                                    updateFormStatus();
                                  });
                                },
                                child: ListTile(
                                  title: Text(
                                    status.displayValue,
                                    style: GoogleFonts.poppins(
                                        color: residenceStatusController
                                                .text.isNotEmpty
                                            ? residenceStatusController.text ==
                                                    status.value
                                                ? AppTheme.primaryDark
                                                : AppTheme.secondary
                                                    .withOpacity(0.3)
                                            : AppTheme.primary,
                                        fontWeight:
                                            residenceStatusController.text ==
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
                              if (status != ResidenceStatus.values.last)
                                const Divider(),
                            ],
                          );
                        }).toList(),
                      )))
            ])),
      ]),
    );
  }

  Widget countryOfTaxResidenceForm(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      countryofTaxResidenceFocusNode.requestFocus();
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
            if (isUSACitizen) {
              setState(() {
                stepperForm = StepperForm.citizenshipForm;
              });
            } else {
              setState(() {
                stepperForm = StepperForm.residenceStatusForm;
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
                  "What is your primary country of tax residence?",
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
              ItemPickerWidget<Country>(
                onItemChanged: (selectedCountry) {
                  countryOfTaxResidenceController.text =
                      selectedCountry.isoCode;
                },
                label: "Country of Tax Residence",
                enabled: false,
                controller: countryOfTaxResidencePickerController,
                items: Country.ALL,
                displayName: (Country country) => country.name,
                uniqueId: (Country country) => country.isoCode,
              )
              // InputBox(
              //     controller: countryOfTaxResidenceController,
              //     //autofocus: true,
              //     focusNode: countryofTaxResidenceFocusNode,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "Country of Tax Resience"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: countryOfTaxResidenceController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: value.text.isEmpty
                    ? null
                    : () {
                        if (countryOfTaxResidencePickerController
                                .selectedItem!.isoCode ==
                            "USA") {
                          setState(() {
                            stepperForm = StepperForm.stateOfTaxResidenceForm;
                          });
                        } else {
                          stateOfTaxResidenceController.text = "";
                          setState(() {
                            stepperForm = StepperForm.taxIDForm;
                          });
                        }
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget stateOfTaxResidenceForm(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      stateofTaxResidenceFocusNode.requestFocus();
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
            setState(() {
              stepperForm = StepperForm.countryOfTaxResidenceForm;
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
                  "What is your state of tax residence?",
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
              ItemPickerWidget<USState>(
                onItemChanged: (selectedState) {
                  stateOfTaxResidenceController.text = selectedState.code;
                },
                label: "State of Tax Residence",
                enabled: false,
                controller: stateOfTaxResidencePickerController,
                items: USState.allStates,
                displayName: (USState state) => state.name,
                uniqueId: (USState state) => state.code,
              )
              // InputBox(
              //     controller: stateOfTaxResidenceController,
              //     //autofocus: true,
              //     focusNode: stateofTaxResidenceFocusNode,
              //     enabled: true,
              //     isInputCenter: true,
              //     label: "State of Tax Resience"),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: stateOfTaxResidenceController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                onPressFunction: value.text.isEmpty
                    ? null
                    : () {
                        setState(() {
                          stepperForm = StepperForm.taxIDForm;
                        });
                      },
              );
            },
          ),
        ),
      ]),
    );
  }

  Widget taxIDForm(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Request focus once the frame rendering is complete.
      taxIdFocusNode.requestFocus();
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
            setState(() {
              stepperForm = StepperForm.addressForm;
            });
            // if (countryOfTaxResidencePickerController.selectedItem!.isoCode ==
            //     "USA") {
            //   setState(() {
            //     stepperForm = StepperForm.stateOfTaxResidenceForm;
            //   });
            // } else {
            //   setState(() {
            //     stepperForm = StepperForm.countryOfTaxResidenceForm;
            //   });
            // }
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
                  "What is your Social Security Number?",
                  textAlign: TextAlign.center,
                  style: AppTheme.headingText,
                ),
              ),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: DefaultTextStyle.of(context).style,
                  children: <InlineSpan>[
                    const WidgetSpan(
                      child: Icon(Icons.lock_person_rounded,
                          color: AppTheme.secondary, size: 20),
                      alignment: PlaceholderAlignment.middle,
                    ),
                    TextSpan(
                      text: " Your data is encrypted and stored securely",
                      style: AppTheme.secondaryTextBold,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              // Container(
              //   alignment: Alignment.center,
              //   margin: const EdgeInsets.only(bottom: 15),
              //   child: Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       const Icon(
              //         Icons.lock_person_rounded,
              //         color: AppTheme.secondary,
              //         size: 20,
              //       ),
              //       const SizedBox(width: 5),
              //       Flexible(
              //           child: Text(
              //               'Your data is encrypted and stored securely',
              //               textAlign: TextAlign.left,
              //               style: AppTheme.secondaryTextBold,
              //               overflow: TextOverflow.visible)),
              //     ],
              //   ),
              // ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: Text(
                  'We are legally required to collect your Social Security Number.'
                  ' It will only be used to verify your identity and will not affect your credit score.',
                  textAlign: TextAlign.center,
                  style: AppTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 10),
              SSNInputBox(
                  controller: taxIDController,
                  isNumberInput: true,
                  //autofocus: true,
                  focusNode: taxIdFocusNode,
                  enabled: true,
                  isInputCenter: true,
                  label: "XXX - XX - XXXX"),
              const SizedBox(height: 10),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.only(bottom: 32),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: AppTheme.disclosureText,
                    children: <TextSpan>[
                      TextSpan(
                        text: "See our ",
                        style: AppTheme.secondaryText,
                      ),
                      TextSpan(
                        text: "security policies",
                        style: GoogleFonts.poppins(
                            decoration: TextDecoration.underline,
                            fontSize: 14,
                            color: AppTheme.primary),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            const url = "https://www.getfinvest.com/security";
                            if (await canLaunchUrl(Uri.parse(url))) {
                              await launchUrl(Uri.parse(url));
                            }
                          },
                      ),
                    ],
                  ),
                ),
              ),
            ])),
        Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: taxIDController,
            builder:
                (BuildContext context, TextEditingValue value, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Continue',
                isLoading: state is UpdatePersonalDetailsLoadingState,
                onPressFunction: value.text.isEmpty ||
                        value.text.length < 11 ||
                        state is UpdatePersonalDetailsLoadingState
                    ? null
                    : () {
                        homeBloc.add(UpdatePersonalDetailsEvent(
                            dateOfBirthController.text,
                            countryCountroller.text,
                            streetController.text,
                            additionalController.text,
                            cityController.text,
                            regionController.text,
                            postalCodeController.text,
                            citizenshipControllers
                                .map((controller) => controller.text)
                                .toList(),
                            countryOfTaxResidenceController.text,
                            stateOfTaxResidenceController.text,
                            residenceStatusController.text,
                            taxIDController.text));
                        // Navigator.pop(context);
                      },
              );
            },
          ),
        ),
      ]),
    );
  }
}
