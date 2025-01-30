import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/account_failure_verification_popover.dart';
import 'package:bondgrid/components/account_verification_denied_popover.dart';
import 'package:bondgrid/components/address_search_box.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/date_input_box.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/item_picker.dart';
import 'package:bondgrid/components/ssn_input_box.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/country.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/account_activation_completion_screen.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:intl/intl.dart';

class UpdateInformation extends StatefulWidget {
  const UpdateInformation({super.key, required this.showNavBar});

  final ValueNotifier<bool> showNavBar;

  @override
  UpdateInformationState createState() => UpdateInformationState();
}

class UpdateInformationState extends State<UpdateInformation>
    with WidgetsBindingObserver {
  UserInfo? _userInfo;
  ValueNotifier<bool> isFormFilled = ValueNotifier(false);

  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  TextEditingController dateOfBirthController = TextEditingController();
  String? formattedDate;

  TextEditingController taxIDController = TextEditingController();

  TextEditingController streetController = TextEditingController();
  TextEditingController additionalController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController regionController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController countryCountroller = TextEditingController();
  ItemPickerController<Country> countryPickerController =
      ItemPickerController<Country>();

  TextEditingController countryOfTaxResidenceController =
      TextEditingController();
  TextEditingController stateOfTaxResidenceController = TextEditingController();

  ValueNotifier<bool> isNameFormFilled = ValueNotifier(false);
  ValueNotifier<bool> formFilledNotifier = ValueNotifier(false);
  String addressWarning = '';

  ValueNotifier<bool> isDOBVaild = ValueNotifier(false);
  String dobInvalidWarning = '';

  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  bool isKeyboardVisible = false;

  void updateNameFormFilled() {
    isNameFormFilled.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
  }

  void updateFormStatus() {
    formFilledNotifier.value = streetController.text.isNotEmpty &&
        cityController.text.isNotEmpty &&
        postalCodeController.text.isNotEmpty &&
        regionController.text.isNotEmpty &&
        countryCountroller.text.isNotEmpty;

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

    WidgetsBinding.instance.addObserver(this);
    _loadPageData();

    firstNameController.addListener(() => updateNameFormFilled());
    lastNameController.addListener(() => updateNameFormFilled());

    streetController.addListener(updateFormStatus);
    cityController.addListener(updateFormStatus);
    postalCodeController.addListener(updateFormStatus);
    regionController.addListener(updateFormStatus);
    countryCountroller.addListener(updateFormStatus);

    dateOfBirthController.addListener(isDOBvalid);
  }

  @override
  void dispose() {
    dateOfBirthController.removeListener(isDOBvalid);

    streetController.removeListener(updateFormStatus);
    cityController.removeListener(updateFormStatus);
    postalCodeController.removeListener(updateFormStatus);
    regionController.removeListener(updateFormStatus);
    countryCountroller.removeListener(updateFormStatus);

    firstNameController.removeListener(updateNameFormFilled);
    lastNameController.removeListener(updateNameFormFilled);

    isNameFormFilled.dispose();

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
    context.read<HomeBloc>().add(GetUserInfoEvent());
  }

  void setDefaultState() {
    if (_userInfo != null) {
      firstNameController.text = _userInfo!.personalDetails.firstName ?? "";
      middleNameController.text = _userInfo!.personalDetails.middleName ?? "";
      lastNameController.text = _userInfo!.personalDetails.lastName ?? "";

      if (_userInfo!.personalDetails.dateOfBirth?.isNotEmpty ?? false) {
        DateTime parsedDate =
            DateTime.parse(_userInfo!.personalDetails.dateOfBirth!);
        formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);
        dateOfBirthController.text = formattedDate!;
      }

      if (_userInfo!.personalDetails.taxID?.isNotEmpty ?? false) {
        taxIDController.text = _userInfo!.personalDetails.taxID!;
      }

      if (_userInfo!.personalDetails.street?.isNotEmpty ?? false) {
        streetController.text = _userInfo!.personalDetails.street!;
      }
      if (_userInfo!.personalDetails.additional?.isNotEmpty ?? false) {
        additionalController.text = _userInfo!.personalDetails.additional!;
      }
      if (_userInfo!.personalDetails.city?.isNotEmpty ?? false) {
        cityController.text = _userInfo!.personalDetails.city!;
      }
      if (_userInfo!.personalDetails.region?.isNotEmpty ?? false) {
        regionController.text = _userInfo!.personalDetails.region!;
      }
      if (_userInfo!.personalDetails.postalCode?.isNotEmpty ?? false) {
        postalCodeController.text = _userInfo!.personalDetails.postalCode!;
      }
      if (_userInfo!.personalDetails.countryCode?.isNotEmpty ?? false) {
        countryCountroller.text = _userInfo!.personalDetails.countryCode!;
        final country =
            Country.findByIsoCode(_userInfo!.personalDetails.countryCode!);
        if (country != null) {
          countryPickerController.setItem(country);
        }
      }

      if (_userInfo!.personalDetails.countryOfTaxResidence?.isNotEmpty ??
          false) {
        countryOfTaxResidenceController.text =
            _userInfo!.personalDetails.countryOfTaxResidence!;
      }
      if (_userInfo!.personalDetails.stateOfTaxResidence?.isNotEmpty ?? false) {
        stateOfTaxResidenceController.text =
            _userInfo!.personalDetails.stateOfTaxResidence!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is GetUserInfoSuccessState) {
              _userInfo = state.userInfo;
              setDefaultState();
              updateNameFormFilled();
              updateFormStatus();
              isDOBvalid();
            }

            if (state is UpdateNameSuccessState) {
              _userInfo = state.userInfo;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }

            if (state is UpdateDOBSuccessState) {
              _userInfo = state.userInfo;
              if (_userInfo!.personalDetails.dateOfBirth?.isNotEmpty ?? false) {
                DateTime parsedDate =
                    DateTime.parse(_userInfo!.personalDetails.dateOfBirth!);
                formattedDate = DateFormat('MM/dd/yyyy').format(parsedDate);
              }
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }

            if (state is UpdateAddressSuccessState) {
              _userInfo = state.userInfo;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }

            if (state is UpdateTaxIdSuccessState) {
              _userInfo = state.userInfo;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
            }

            if (state is SubmitUserVerificationSuccessState) {
              if (state.verification.status == VerificationStatus.DENIED) {
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return const AccountVerificationDeniedPopover();
                    });
              } else if (state.verification.status ==
                  VerificationStatus.FAILED) {
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return const AccountFailureVerificationPopover();
                    });
              } else {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: const AccountActivationCompletionScreen(),
                            )));
              }
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
                // title: Text(
                //   'Update Information',
                //   style: AppTheme.profileText,
                //   textAlign: TextAlign.center,
                // ),
              ),
              body: _userInfo == null
                  ? const SizedBox.shrink()
                  : AbsorbPointer(
                      absorbing: state.status == HomeStateStatus.loading,
                      child: Stack(children: [
                        SingleChildScrollView(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      alignment: Alignment.center,
                                      margin: const EdgeInsets.only(
                                          top: 0, bottom: 20),
                                      child: Text(
                                        "Update Information",
                                        textAlign: TextAlign.center,
                                        style: AppTheme.headingText,
                                      ),
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          showNameUpdateModalSheet(
                                              context,
                                              BlocProvider.of<HomeBloc>(
                                                  context));
                                        },
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Name',
                                                    style:
                                                        AppTheme.bodyNormalGrey,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    _userInfo!.personalDetails
                                                                    .firstName !=
                                                                null &&
                                                            _userInfo!
                                                                    .personalDetails
                                                                    .lastName !=
                                                                null
                                                        ? _userInfo!.personalDetails
                                                                        .middleName !=
                                                                    null &&
                                                                _userInfo!
                                                                    .personalDetails
                                                                    .middleName!
                                                                    .isNotEmpty
                                                            ? "${_userInfo!.personalDetails.firstName} ${_userInfo!.personalDetails.middleName} ${_userInfo!.personalDetails.lastName}"
                                                            : "${_userInfo!.personalDetails.firstName} ${_userInfo!.personalDetails.lastName}"
                                                        : "",
                                                    style: AppTheme.bodyNormal,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  ),
                                                ]),
                                            const Icon(
                                                Icons
                                                    .keyboard_arrow_right_rounded,
                                                color: AppTheme.primary)
                                          ],
                                        )),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          showDOBUpdateModalSheet(
                                              context,
                                              BlocProvider.of<HomeBloc>(
                                                  context));
                                        },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Date of Birth',
                                                    style:
                                                        AppTheme.bodyNormalGrey,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    formattedDate != null
                                                        ? formattedDate!
                                                        : "",
                                                    style: AppTheme.bodyNormal,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  )
                                                ],
                                              ),
                                              const Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                  color: AppTheme.primary)
                                            ])),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          showAddressUpdateModalSheet(
                                              context,
                                              BlocProvider.of<HomeBloc>(
                                                  context));
                                        },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Address',
                                                    style:
                                                        AppTheme.bodyNormalGrey,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    _userInfo!.personalDetails
                                                        .formatAddress(),
                                                    style: AppTheme.bodyNormal,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  )
                                                ],
                                              ),
                                              const Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                  color: AppTheme.primary)
                                            ])),
                                    const Divider(),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        onTap: () {
                                          showTaxIDUpdateModalSheet(
                                              context,
                                              BlocProvider.of<HomeBloc>(
                                                  context));
                                        },
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'SSN',
                                                    style:
                                                        AppTheme.bodyNormalGrey,
                                                  ),
                                                  const SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(
                                                    'XXX - XX - XXXX',
                                                    style: AppTheme.bodyNormal,
                                                    overflow:
                                                        TextOverflow.visible,
                                                  )
                                                ],
                                              ),
                                              const Icon(
                                                  Icons
                                                      .keyboard_arrow_right_rounded,
                                                  color: AppTheme.primary)
                                            ])),
                                    const Divider()
                                  ])),
                        ),
                        submitButton(context, state)
                      ]))));
    });
  }

  Widget submitButton(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
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
                    buttonText: 'Submit',
                    isLoading: state is SubmitUserVerificationLoadingState,
                    onPressFunction: state is SubmitUserVerificationLoadingState
                        ? null
                        : () {
                            homeBloc.add(SubmitUserVerificationEvent());
                          },
                  )
                ])));
  }

  void showNameUpdateModalSheet(BuildContext context, HomeBloc homeBloc) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: homeBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      ListTile(
                        title: Text('Edit Your Legal Name',
                            style: AppTheme.bodyBold,
                            textAlign: TextAlign.center),
                      ),
                      InputBox(
                          controller: firstNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "First Name"),
                      InputBox(
                          controller: middleNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "Middle Name"),
                      InputBox(
                          controller: lastNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "Last Name"),
                      const SizedBox(
                        height: 20,
                      ),
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
                            ValueListenableBuilder<bool>(
                                valueListenable: isNameFormFilled,
                                builder: (BuildContext context, bool isFilled,
                                    Widget? child) {
                                  return CustomButton(
                                    widthVal: 2.3,
                                    buttonText: 'Continue',
                                    isLoading: state is UpdateNameLoadingState,
                                    onPressFunction: isFilled &&
                                            state is! UpdateNameLoadingState
                                        ? () {
                                            homeBloc.add(UpdateNameEvent(
                                                firstNameController.text,
                                                middleNameController.text,
                                                lastNameController.text));
                                          }
                                        : null,
                                  );
                                })
                          ]),
                    ]);
                  },
                )));
      },
    );
  }

  void showDOBUpdateModalSheet(BuildContext context, HomeBloc homeBloc) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: homeBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      ListTile(
                        title: Text('Enter Your Date of Birth',
                            style: AppTheme.bodyBold,
                            textAlign: TextAlign.center),
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
                      DateInputBox(
                          controller: dateOfBirthController,
                          isNumberInput: true,
                          enabled: true,
                          isInputCenter: true,
                          label: "MM / DD / YYYY"),
                      dobInvalidWarning != ''
                          ? Text(dobInvalidWarning,
                              style: AppTheme.warningMessage)
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 20,
                      ),
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
                            ValueListenableBuilder<bool>(
                                valueListenable: isDOBVaild,
                                builder: (BuildContext context, bool isValid,
                                    Widget? child) {
                                  return CustomButton(
                                    widthVal: 2.3,
                                    buttonText: 'Continue',
                                    isLoading: state is UpdateDOBLoadingState,
                                    onPressFunction: isValid &&
                                            state is! UpdateDOBLoadingState
                                        ? () {
                                            homeBloc.add(UpdateDOBEvent(
                                                dateOfBirthController.text));
                                          }
                                        : null,
                                  );
                                })
                          ]),
                    ]);
                  },
                )));
      },
    );
  }

  void showAddressUpdateModalSheet(BuildContext context, HomeBloc homeBloc) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: homeBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      ListTile(
                        title: Text('Edit Your Residential Address',
                            style: AppTheme.bodyBold,
                            textAlign: TextAlign.center),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
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
                        ),
                      ),
                      const SizedBox(height: 10),
                      InputBox(
                          controller: streetController,
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
                      // InputBox(
                      //     controller: countryCountroller,
                      //     enabled: true,
                      //     isInputCenter: true,
                      //     label: "Country"),
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
                      addressWarning != ''
                          ? Text(addressWarning, style: AppTheme.warningMessage)
                          : const SizedBox.shrink(),
                      const SizedBox(
                        height: 20,
                      ),
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
                            ValueListenableBuilder<bool>(
                                valueListenable: formFilledNotifier,
                                builder: (BuildContext context,
                                    bool isFormFilled, Widget? child) {
                                  return CustomButton(
                                    widthVal: 2.3,
                                    buttonText: 'Continue',
                                    isLoading:
                                        state is UpdateAddressLoadingState,
                                    onPressFunction: isFormFilled &&
                                            state is! UpdateAddressLoadingState
                                        ? () {
                                            stateOfTaxResidenceController.text =
                                                regionController.text;
                                            countryOfTaxResidenceController
                                                .text = countryCountroller.text;
                                            homeBloc.add(UpdateAddressEvent(
                                                countryCountroller.text,
                                                streetController.text,
                                                additionalController.text,
                                                cityController.text,
                                                regionController.text,
                                                postalCodeController.text,
                                                countryOfTaxResidenceController
                                                    .text,
                                                stateOfTaxResidenceController
                                                    .text));
                                          }
                                        : null,
                                  );
                                })
                          ]),
                    ]);
                  },
                )));
      },
    );
  }

  void showTaxIDUpdateModalSheet(BuildContext context, HomeBloc homeBloc) {
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
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
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: homeBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      ListTile(
                        title: Text('Enter Your Social Security Number',
                            style: AppTheme.bodyBold,
                            textAlign: TextAlign.center),
                      ),
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
                      SSNInputBox(
                          controller: taxIDController,
                          isNumberInput: true,
                          enabled: true,
                          isInputCenter: true,
                          label: "XXX - XX - XXXX"),
                      const SizedBox(
                        height: 20,
                      ),
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
                            ValueListenableBuilder<bool>(
                                valueListenable: isDOBVaild,
                                builder: (BuildContext context, bool isValid,
                                    Widget? child) {
                                  return CustomButton(
                                    widthVal: 2.3,
                                    buttonText: 'Continue',
                                    isLoading: state is UpdateTaxIdLoadingState,
                                    onPressFunction: isValid &&
                                            state is! UpdateTaxIdLoadingState
                                        ? () {
                                            homeBloc.add(UpdateTaxIDEvent(
                                                taxIDController.text));
                                          }
                                        : null,
                                  );
                                })
                          ]),
                    ]);
                  },
                )));
      },
    );
  }
}
