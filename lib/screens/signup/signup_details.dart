// DEPRECATED

import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/password_box.dart';
import 'package:bondgrid/components/phone_number_box.dart';
import 'package:bondgrid/components/timed_button.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class SignupDetails extends StatefulWidget {
  const SignupDetails({super.key, this.referralCode});

  final String? referralCode;

  @override
  SignupDetailsScreenState createState() => SignupDetailsScreenState();
}

enum StepperForm {
  nameForm,
  emailForm,
  passwordForm,
  emailOtpForm,
  phoneNumberForm,
  phoneOtpForm
}

class SignupDetailsScreenState extends State<SignupDetails> {
  StepperForm stepperIndex = StepperForm.nameForm;

  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  TextEditingController emailOtpController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController unmaskedPhoneNumberController = TextEditingController();
  TextEditingController phoneOtpController = TextEditingController();

  FocusNode firstNameNode = FocusNode();
  FocusNode emailNode = FocusNode();
  FocusNode passwordNode = FocusNode();
  FocusNode emailOtpNode = FocusNode();
  FocusNode phoneNumberNode = FocusNode();
  FocusNode phoneOtpNode = FocusNode();

  ValueNotifier<bool> isNameFormFilled = ValueNotifier(false);
  ValueNotifier<bool> isPasswordFormFilled = ValueNotifier(false);

  String passwordInvalidWarning = '';

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(() => updateNameFormFilled());
    lastNameController.addListener(() => updateNameFormFilled());

    passwordController.addListener(() => updatePasswordFormFilled());
    retypePasswordController.addListener(() => updatePasswordFormFilled());

    updateNameFormFilled();
    updatePasswordFormFilled();
  }

  @override
  void dispose() {
    firstNameController.removeListener(updateNameFormFilled);
    lastNameController.removeListener(updateNameFormFilled);
    passwordController.removeListener(updatePasswordFormFilled);
    retypePasswordController.removeListener(updatePasswordFormFilled);

    firstNameController.dispose();
    lastNameController.dispose();
    passwordController.dispose();
    retypePasswordController.dispose();

    isNameFormFilled.dispose();
    isPasswordFormFilled.dispose();
    super.dispose();
  }

  void updateNameFormFilled() {
    isNameFormFilled.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
  }

  void updatePasswordFormFilled() {
    final RegExp regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_]).{8,}$');
    bool isPasswordValid = regex.hasMatch(passwordController.text);
    bool isPasswordMatch =
        passwordController.text == retypePasswordController.text;
    isPasswordFormFilled.value = isPasswordValid && isPasswordMatch;

    final password = passwordController.text;
    final retypePassword = retypePasswordController.text;

    String message = '';
    if (password.isEmpty) {
      message = '';
    } else if (password.length < 8) {
      message = 'Password must be at least 8 characters long.';
    } else if (!RegExp(r'(?=.*?[A-Z])').hasMatch(password)) {
      message = 'Password must contain at least one uppercase letter.';
    } else if (!RegExp(r'(?=.*?[a-z])').hasMatch(password)) {
      message = 'Password must contain at least one lowercase letter.';
    } else if (!RegExp(r'(?=.*?[0-9])').hasMatch(password)) {
      message = 'Password must contain at least one digit.';
    } else if (!RegExp(r'(?=.*?[!@#\$&*~_])').hasMatch(password)) {
      message = 'Password must contain at least one special character.';
    } else if (password != retypePassword && retypePassword.isNotEmpty) {
      message = 'Passwords do not match.';
    }

    setState(() {
      passwordInvalidWarning = message;
    });
  }

  Widget getForm(BuildContext context, AuthenticationState state) {
    if (stepperIndex == StepperForm.nameForm) {
      return nameForm(context, state);
    } else if (stepperIndex == StepperForm.emailForm) {
      return emailForm(context, state);
    } else if (stepperIndex == StepperForm.passwordForm) {
      return passwordForm(context, state);
    } else if (stepperIndex == StepperForm.emailOtpForm) {
      return emailOtpForm(context, state);
    } else if (stepperIndex == StepperForm.phoneNumberForm) {
      return phoneNumberForm(context, state);
    } else {
      return phoneOtpForm(context, state);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthenticationBloc, AuthenticationState>(
        builder: (context, state) {
      return BlocListener<AuthenticationBloc, AuthenticationState>(
          listener: (context, state) {
            if (state.status == AuthenticationStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is RegisterSuccessState) {
              setState(() {
                stepperIndex = StepperForm.emailOtpForm;
              });
            }

            if (state is VerifyEmailSuccessState) {
              setState(() {
                stepperIndex = StepperForm.phoneNumberForm;
              });
            }

            if (state is GeneratePhoneOTPSuccessState) {
              setState(() {
                stepperIndex = StepperForm.phoneOtpForm;
              });
            }

            if (state is VerifyPhoneOTPSuccessState) {
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation1, animation2) =>
                      NavigatorScreen(
                    selectedIndex: 0,
                    showWelcomeScreen: true,
                  ),
                  transitionDuration:
                      Duration.zero, // Specify no transition duration
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: getForm(context, state));
    });
  }

  Widget nameForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        firstNameNode.requestFocus();
      });
    }

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

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
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 20, bottom: 12),
                      child: Text(
                        "What is your legal name?",
                        textAlign: TextAlign.center,
                        style: AppTheme.headingText,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(bottom: 32),
                      child: Text(
                        'Enter your name as it appears on your government ID.',
                        textAlign: TextAlign.center,
                        style: AppTheme.secondaryText,
                      ),
                    ),
                    InputBox(
                      controller: firstNameController,
                      isInputCenter: true,
                      textCapitalization: true,
                      focusNode: firstNameNode,
                      enabled: true,
                      label: "First Name",
                    ),
                    InputBox(
                      controller: middleNameController,
                      isInputCenter: true,
                      textCapitalization: true,
                      enabled: true,
                      label: "Middle Name",
                    ),
                    InputBox(
                      controller: lastNameController,
                      isInputCenter: true,
                      textCapitalization: true,
                      enabled: true,
                      label: "Last Name",
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isNameFormFilled,
                  builder:
                      (BuildContext context, bool isFilled, Widget? child) {
                    return CustomButton(
                      widthVal: 1,
                      buttonText: 'Continue',
                      isLoading:
                          state.status == AuthenticationStateStatus.loading,
                      onPressFunction: isFilled
                          ? () {
                              setState(() {
                                stepperIndex = StepperForm.emailForm;
                              });
                            }
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }

  Widget emailForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Request focus once the frame rendering is complete.
        emailNode.requestFocus();
      });
    }

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              setState(() {
                stepperIndex = StepperForm.nameForm;
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppTheme.actionButton,
              size: 22,
            ),
          ),
        ),
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: Column(children: [
            Expanded(
                child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      "What is your email address?",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "You'll use this email to log in and manage your account.",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryText,
                    ),
                  ),
                  InputBox(
                      controller: emailAddressController,
                      isInputCenter: true,
                      //autofocus: true,
                      focusNode: emailNode,
                      enabled: true,
                      label: "Email Address"),
                ])),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: emailAddressController,
                builder: (BuildContext context, TextEditingValue value,
                    Widget? child) {
                  final RegExp regex =
                      RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");
                  bool isEmailValid = regex.hasMatch(value.text);
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading:
                        state.status == AuthenticationStateStatus.loading,
                    onPressFunction: isEmailValid
                        ? () {
                            setState(() {
                              stepperIndex = StepperForm.passwordForm;
                            });
                          }
                        : null,
                  );
                },
              ),
            ),
          ]),
        ));
  }

  Widget passwordForm(BuildContext context, AuthenticationState state) {
    // if (state.status != AuthenticationStateStatus.failure && state.status != AuthenticationStateStatus.loading) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // Request focus once the frame rendering is complete.
    //     passwordNode.requestFocus();
    //   });
    // }

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              setState(() {
                stepperIndex = StepperForm.emailForm;
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppTheme.actionButton,
              size: 22,
            ),
          ),
        ),
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: Column(children: [
            Expanded(
                child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      "Choose a password",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Password must contain at least one uppercase letter, one lowercase letter,"
                      " one digit, one special character, and must be at least 8 characters in length.",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryText,
                    ),
                  ),
                  PasswordBox(
                      controller: passwordController,
                      isInputCenter: true,
                      autofocus: true,
                      //focusNode: passwordNode,
                      enabled: true,
                      label: "Password"),
                  PasswordBox(
                      controller: retypePasswordController,
                      isInputCenter: true,
                      enabled: true,
                      label: "Re-type Password"),
                  passwordInvalidWarning != ''
                      ? Text(passwordInvalidWarning,
                          style: AppTheme.warningMessage)
                      : const SizedBox.shrink(),
                ])),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<bool>(
                valueListenable: isPasswordFormFilled,
                builder: (BuildContext context, bool isFilled, Widget? child) {
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading: state is RegisterLoadingState,
                    onPressFunction: isFilled && state is! RegisterLoadingState
                        ? () {
                            authenticationBloc.add(RegisterEvent(
                                firstNameController.text,
                                middleNameController.text,
                                lastNameController.text,
                                emailAddressController.text,
                                passwordController.text));
                          }
                        : null,
                  );
                },
              ),
            )
          ]),
        ));
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildDoneButtonToolbar(
      BuildContext context, AuthenticationState state) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 0,
        right: 0,
        child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            child: ValueListenableBuilder<TextEditingValue>(
              valueListenable: emailOtpController,
              builder: (BuildContext context, TextEditingValue value,
                  Widget? child) {
                return CustomButton(
                  widthVal: 1,
                  buttonText: 'Sign up',
                  isLoading: state is VerifyEmailLoadingState,
                  onPressFunction:
                      value.text.isEmpty || state is VerifyEmailLoadingState
                          ? null
                          : () {
                              authenticationBloc.add(
                                  VerifyEmailOTPEvent(emailOtpController.text));
                            },
                );
              },
            ))
        // child: Container(
        //   color: Colors.grey[200],
        //   child: SafeArea(
        //     child: Row(
        //       mainAxisAlignment: MainAxisAlignment.end,
        //       children: <Widget>[
        //         IconButton(
        //           icon: const Icon(Icons.done),
        //           onPressed: () => FocusScope.of(context).unfocus(),
        //         ),
        //       ],
        //     ),
        //   ),
        // ),
        );
  }

  Widget emailOtpForm(BuildContext context, AuthenticationState state) {
    // if (state.status != AuthenticationStateStatus.failure && state.status != AuthenticationStateStatus.loading) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     // Request focus once the frame rendering is complete.
    //     emailOtpNode.requestFocus();
    //   });
    // }

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              setState(() {
                stepperIndex = StepperForm.passwordForm;
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppTheme.actionButton,
              size: 22,
            ),
          ),
        ),
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: GestureDetector(
              onTap: () {
                // This will dismiss the keyboard when tapped outside the input field
                FocusScope.of(context).unfocus();
              },
              child: Stack(children: [
                Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: SingleChildScrollView(
                              //shrinkWrap: true,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24),
                              physics: const BouncingScrollPhysics(),
                              child: Column(children: [
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(
                                      top: 20, bottom: 12),
                                  child: Text(
                                    "Enter the verification code",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.headingText,
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  margin: const EdgeInsets.only(bottom: 32),
                                  child: Text(
                                    "Please enter the verification code which has been sent to your email.",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.secondaryText,
                                  ),
                                ),
                                InputBox(
                                    controller: emailOtpController,
                                    isInputCenter: true,
                                    //autofocus: true,
                                    //focusNode: emailOtpNode,
                                    enabled: true,
                                    isNumberInput: true,
                                    label: "Verification Code"),
                                Container(
                                    alignment: Alignment.center,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Didn't Receive it?",
                                          style: AppTheme.secondaryText,
                                        ),
                                        if (state is ResendOTPSuccessState) ...[
                                          const Icon(Icons.check,
                                              color: Colors.green),
                                          Text('OTP Sent',
                                              style:
                                                  AppTheme.secondaryTextBold),
                                        ] else ...[
                                          TimedButton(
                                              onPressed: () {
                                                authenticationBloc
                                                    .add(ResendOTPEvent());
                                              },
                                              label: 'Resend OTP')
                                        ]
                                      ],
                                    )),
                              ]))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 20),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTheme.disclosureText,
                              children: <TextSpan>[
                                const TextSpan(
                                    text:
                                        "By signing up, you are agreeing to our "),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppTheme.primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL(
                                          'https://finvest-documents.s3.us-east-2.amazonaws.com/Finvest+Privacy+Policy.pdf');
                                    },
                                ),
                                const TextSpan(text: " and "),
                                TextSpan(
                                  text: "Terms of Use",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppTheme.primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL(
                                          'https://finvest-documents.s3.us-east-2.amazonaws.com/Finvest+Terms+of+Service.pdf');
                                    },
                                ),
                                const TextSpan(
                                    text:
                                        ". \n\nFinvest has an engagement with Atomic Invest, LLC (“Atomic Invest”), an SEC-registered investment adviser, to bring you the opportunity to open an investment advisory account. See "),
                                TextSpan(
                                  text: "Atomic's Disclosures",
                                  style: const TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: AppTheme.primary),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      _launchURL(
                                          'https://finvest-documents.s3.us-east-2.amazonaws.com/Atomic+Invest+Advisors+LLC+General+Disclosures.pdf');
                                    },
                                ),
                                const TextSpan(text: "."),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                          padding:
                              EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ValueListenableBuilder<TextEditingValue>(
                                  valueListenable: emailOtpController,
                                  builder: (BuildContext context,
                                      TextEditingValue value, Widget? child) {
                                    return CustomButton(
                                      widthVal: 1,
                                      buttonText: 'Sign up',
                                      isLoading:
                                          state is VerifyEmailLoadingState,
                                      onPressFunction: value.text.isEmpty ||
                                              state is VerifyEmailLoadingState
                                          ? null
                                          : () {
                                              authenticationBloc.add(
                                                  VerifyEmailOTPEvent(
                                                      emailOtpController.text));
                                            },
                                    );
                                  },
                                )
                              ]),
                        ),
                      ),
                    ]),
                if (MediaQuery.of(context).viewInsets.bottom !=
                    0) // Check if the keyboard is open
                  _buildDoneButtonToolbar(context, state),
              ])),
        ));
  }

  Widget phoneNumberForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Request focus once the frame rendering is complete.
        phoneNumberNode.requestFocus();
      });
    }
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppTheme.actionButton,
              size: 22,
            ),
          ),
        ),
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: Column(children: [
            Expanded(
                child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      "What is your phone number?",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "We will use this phone number to enable two factor authentication in your account.",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryText,
                    ),
                  ),
                  PhoneNumberBox(
                      controller: phoneNumberController,
                      unmaskedController: unmaskedPhoneNumberController,
                      isInputCenter: true,
                      focusNode: phoneNumberNode,
                      enabled: true,
                      label: "US Phone Number")
                  // IntlPhoneField(
                  //   style: GoogleFonts.poppins(fontSize: 16),
                  //   //autofocus: true,
                  //   focusNode: phoneNumberNode,
                  //   decoration: InputDecoration(
                  //       filled: true,
                  //       contentPadding: const EdgeInsets.only(right: 12, left: 12),
                  //       fillColor: AppTheme.notWhite,
                  //       // fillColor: enabled
                  //       //     ? ShipperAppTheme.nearlyWhite
                  //       //     : Colors.grey[100]!,
                  //       labelText: "Phone Number",
                  //       labelStyle: GoogleFonts.poppins(
                  //           color: AppTheme.inputBoxGrey,
                  //           fontSize: max(
                  //               15, MediaQuery.of(context).size.height * 0.0169)),
                  //       floatingLabelBehavior: FloatingLabelBehavior.auto,
                  //       enabledBorder: OutlineInputBorder(
                  //         // borderRadius:
                  //         //     const BorderRadius.all(Radius.circular(10)),
                  //         borderSide: BorderSide(color: Colors.grey[300]!),
                  //       ),
                  //       focusedBorder: const OutlineInputBorder(
                  //         // borderRadius:
                  //         //     const BorderRadius.all(Radius.circular(10)),
                  //         borderSide: BorderSide(color: AppTheme.primary),
                  //       )),
                  //   initialCountryCode: 'US',
                  //   controller: phoneNumberController,
                  //   onChanged: (phone) {
                  //     // print(phone.completeNumber);
                  //   },
                  // ),
                ])),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: unmaskedPhoneNumberController,
                builder: (BuildContext context, TextEditingValue value,
                    Widget? child) {
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading: state is GeneratePhoneOTPLoadingState,
                    onPressFunction: value.text.isEmpty ||
                            value.text.length < 10 ||
                            state is GeneratePhoneOTPLoadingState
                        ? null
                        : () {
                            authenticationBloc.add(GeneratePhoneOTPEvent(
                                unmaskedPhoneNumberController.text));
                          },
                  );
                },
              ),
            ),
          ]),
        ));
  }

  Widget phoneOtpForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Request focus once the frame rendering is complete.
        phoneOtpNode.requestFocus();
      });
    }

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding = MediaQuery.of(context).viewInsets.bottom > 0
        ? 20
        : MediaQuery.of(context).viewPadding.bottom + 20;

    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
    return Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          centerTitle: true,
          elevation: 0,
          leading: IconButton(
            onPressed: () {
              setState(() {
                stepperIndex = StepperForm.phoneNumberForm;
              });
            },
            icon: Icon(
              Icons.keyboard_arrow_left_rounded,
              color: AppTheme.actionButton,
              size: 22,
            ),
          ),
        ),
        body: AbsorbPointer(
          absorbing: state.status == AuthenticationStateStatus.loading,
          child: Column(children: [
            Expanded(
                child: ListView(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    physics: const BouncingScrollPhysics(),
                    children: [
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 20, bottom: 12),
                    child: Text(
                      "Enter the verification code",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Please enter the verification code which has been sent to your phone number.",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryText,
                    ),
                  ),
                  InputBox(
                      controller: phoneOtpController,
                      isInputCenter: true,
                      //autofocus: true,
                      focusNode: phoneOtpNode,
                      enabled: true,
                      isNumberInput: true,
                      label: "Verification Code"),
                  Container(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Didn't Receive it?",
                            style: AppTheme.secondaryText,
                          ),
                          if (state is ResendOTPSuccessState) ...[
                            const Icon(Icons.check, color: Colors.green),
                            Text('OTP Sent', style: AppTheme.secondaryTextBold),
                          ] else ...[
                            TimedButton(
                                onPressed: () {
                                  authenticationBloc.add(ResendOTPEvent());
                                },
                                label: 'Resend OTP')
                          ]
                        ],
                      )),
                ])),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: phoneOtpController,
                builder: (BuildContext context, TextEditingValue value,
                    Widget? child) {
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading: state is VerifyPhoneOTPLoadingState,
                    onPressFunction: value.text.isEmpty ||
                            state is VerifyPhoneOTPLoadingState
                        ? null
                        : () {
                            authenticationBloc.add(
                                VerifyPhoneOTPEvent(phoneOtpController.text));
                          },
                  );
                },
              ),
            ),
          ]),
        ));
  }
}
