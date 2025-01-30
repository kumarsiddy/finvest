import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/timed_button.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class OtpLoginForm extends StatefulWidget {
  const OtpLoginForm({super.key});

  @override
  OtpLoginFormState createState() => OtpLoginFormState();
}

class OtpLoginFormState extends State<OtpLoginForm> {
  TextEditingController phoneOtpController = TextEditingController();

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

              if (state is VerifyLoginSuccessState) {
                Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        NavigatorScreen(selectedIndex: 0),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              }
            },
            child: otpForm(context, state));
      },
    );
  }

  Widget otpForm(BuildContext context, AuthenticationState state) {
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
              children: [
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
                        autofocus: true,
                        enabled: true,
                        isNumberInput: true,
                        label: "Verification Code",
                      ),
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
                              Text('OTP Sent',
                                  style: AppTheme.secondaryTextBold),
                            ] else ...[
                              TimedButton(
                                onPressed: () {
                                  authenticationBloc.add(ResendOTPEvent());
                                },
                                label: 'Resend OTP',
                              )
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
                                  VerifyLoginOTPEvent(phoneOtpController.text),
                                );
                              },
                      );
                    },
                  ),
                ),
              ],
            ),
          ))),
    );
  }
}
