// DEPRECATED

import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/password_box.dart';
import 'package:bondgrid/components/phone_number_box.dart';
import 'package:bondgrid/components/timed_button.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  int stepperIndex = 0;
  ValueNotifier<bool> isFormFilled = ValueNotifier(false);

  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  TextEditingController phoneOtpController = TextEditingController();

  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController unmaskedPhoneNumberController = TextEditingController();

  FocusNode emailAddressNode = FocusNode();
  FocusNode phoneNumberNode = FocusNode();
  FocusNode phoneOtpNode = FocusNode();

  @override
  void initState() {
    super.initState();
    emailAddressController.addListener(() => updateFormFilled());
    passwordController.addListener(() => updateFormFilled());

    updateFormFilled();
  }

  @override
  void dispose() {
    emailAddressController.removeListener(updateFormFilled);
    passwordController.removeListener(updateFormFilled);

    emailAddressController.dispose();
    passwordController.dispose();

    isFormFilled.dispose();
    super.dispose();
  }

  void updateFormFilled() {
    isFormFilled.value = emailAddressController.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
  }

  Widget getForm(BuildContext context, AuthenticationState state) {
    if (stepperIndex == 0) {
      return emailForm(context, state);
    } else if (stepperIndex == 1) {
      return otpForm(context, state);
    } else if (stepperIndex == 2) {
      return resetPasswordForm(context, state);
    } else if (stepperIndex == 3) {
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

              if (state is LoginSuccessState) {
                setState(() {
                  stepperIndex = 1;
                });
              }

              if (state is LoginPhoneState) {
                setState(() {
                  stepperIndex = 3;
                });
              }

              if (state is GeneratePhoneOTPSuccessState) {
                setState(() {
                  stepperIndex = 4;
                });
              }

              if (state is VerifyLoginSuccessState ||
                  state is VerifyPhoneOTPSuccessState) {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        NavigatorScreen(selectedIndex: 0),
                    transitionDuration:
                        Duration.zero, // Specify no transition duration
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }

              if (state is ForgotPasswordSuccessState) {
                emailAddressController.text = "";
                passwordController.text = "";

                showDialog(
                    context: context,
                    barrierDismissible: true,
                    builder: (context) {
                      // set up the AlertDialog
                      return AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // <-- Radius
                        ),
                        icon: Stack(children: [
                          Center(
                              child: Icon(Icons.check_circle_outline,
                                  size:
                                      MediaQuery.of(context).size.height * 0.06,
                                  color: Colors.green))
                        ]),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Check your email",
                              style: AppTheme.headingText,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(
                              "Please check your email with password reset instructions.",
                              style: AppTheme.secondaryText,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    });
              }
            },
            child: getForm(context, state));
      },
    );
  }

  Widget emailForm(BuildContext context, AuthenticationState state) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);
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
                      "Log In",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  InputBox(
                      controller: emailAddressController,
                      //isInputCenter: true,
                      enabled: true,
                      label: "Email Address"),
                  PasswordBox(
                      controller: passwordController,
                      //isInputCenter: true,
                      enabled: true,
                      label: "Password"),
                  TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.notWhite,
                    ),
                    onPressed: () {
                      setState(() {
                        stepperIndex = 2;
                      });
                    },
                    child: Text(
                      "Forgot Password?",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryTextBold,
                    ),
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
                    isLoading: state is LoginLoadingState,
                    onPressFunction: isFilled && state is! LoginLoadingState
                        ? () {
                            authenticationBloc.add(LoginEvent(
                                emailAddressController.text,
                                passwordController.text));
                          }
                        : null,
                  );
                },
              ),
            ),
          ]),
        ));
  }

  Widget otpForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Please enter the verification code which has been sent to your registered phone number.",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingSmallText,
                    ),
                  ),
                  InputBox(
                      controller: phoneOtpController,
                      isInputCenter: true,
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
                    isLoading: state is VerifyLoginLoadingState,
                    onPressFunction: value.text.isEmpty ||
                            state is VerifyLoginLoadingState
                        ? null
                        : () {
                            authenticationBloc.add(
                                VerifyLoginOTPEvent(phoneOtpController.text));
                          },
                  );
                },
              ),
            ),
          ]),
        ));
  }

  Widget resetPasswordForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading &&
        state is! ForgotPasswordSuccessState) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        emailAddressNode.requestFocus();
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
                      "Reset Password",
                      textAlign: TextAlign.center,
                      style: AppTheme.headingText,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Text(
                      "Please enter the email address associated with your account."
                      " We will send you an email with instructions on how to reset your password.",
                      textAlign: TextAlign.center,
                      style: AppTheme.secondaryText,
                    ),
                  ),
                  InputBox(
                      controller: emailAddressController,
                      isInputCenter: true,
                      focusNode: emailAddressNode,
                      enabled: true,
                      label: "Email Address"),
                ])),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: emailAddressController,
                builder: (BuildContext context, TextEditingValue value,
                    Widget? child) {
                  return CustomButton(
                    widthVal: 1,
                    buttonText: 'Continue',
                    isLoading: state is ForgotPasswordLoadingState,
                    onPressFunction: value.text.isNotEmpty &&
                            state is! ForgotPasswordLoadingState
                        ? () {
                            authenticationBloc.add(ForgotPasswordEvent(
                                emailAddressController.text));
                          }
                        : null,
                  );
                },
              ),
            ),
          ]),
        ));
  }

  Widget phoneNumberForm(BuildContext context, AuthenticationState state) {
    if (state.status != AuthenticationStateStatus.failure &&
        state.status != AuthenticationStateStatus.loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
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
                      "You'll use this phone number to enable two factor authentication in your account.",
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
                  //   focusNode: phoneNumberNode,
                  //   decoration: InputDecoration(
                  //       filled: true,
                  //       contentPadding: const EdgeInsets.only(right: 12, left: 12),
                  //       fillColor: AppTheme.notWhite,
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
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
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
              padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
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
