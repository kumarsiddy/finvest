import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/phone_number_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/timed_button.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:url_launcher/url_launcher.dart';

class OtpSignupForm extends StatefulWidget {
  const OtpSignupForm({super.key});

  @override
  OtpSignupFormState createState() => OtpSignupFormState();
}

class OtpSignupFormState extends State<OtpSignupForm> {
  TextEditingController emailOtpController = TextEditingController();

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

              if (state is VerifyEmailSuccessState) {
                Navigator.push(
                    context,
                    (Theme.of(context).platform == TargetPlatform.iOS)
                        ? CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const PhoneNumberForm()))
                        : MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const PhoneNumberForm())));
              }
            },
            child: otpForm(context, state));
      },
    );
  }

  Widget otpForm(BuildContext context, AuthenticationState state) {
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom != 0;
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

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
      body: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: SafeArea(
              child: AbsorbPointer(
            absorbing: state.status == AuthenticationStateStatus.loading,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                  TextButton(
                                      onPressed: null,
                                      child: Text('OTP Sent',
                                          style: AppTheme.secondaryTextBold)),
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
                      ])),
                  if (!isKeyboardVisible) ...[
                    Padding(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                        child: Container(
                          alignment: Alignment.center,
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
                        ))
                  ],
                  Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: emailOtpController,
                        builder: (BuildContext context, TextEditingValue value,
                            Widget? child) {
                          return CustomButton(
                            widthVal: 1,
                            buttonText: 'Sign up',
                            isLoading: state is VerifyEmailLoadingState,
                            onPressFunction: value.text.isEmpty ||
                                    state is VerifyEmailLoadingState
                                ? null
                                : () {
                                    authenticationBloc.add(VerifyEmailOTPEvent(
                                        emailOtpController.text));
                                  },
                          );
                        },
                      )),
                ]),
          ))),
    );
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
            )));
  }
}
