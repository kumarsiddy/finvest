import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class ResetPasswordForm extends StatefulWidget {
  const ResetPasswordForm({super.key});

  @override
  ResetPasswordFormState createState() => ResetPasswordFormState();
}

class ResetPasswordFormState extends State<ResetPasswordForm> {
  TextEditingController emailAddressController = TextEditingController();

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

              if (state is ForgotPasswordSuccessState) {
                emailAddressController.text = "";

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
            child: resetPasswordForm(context, state));
      },
    );
  }

  Widget resetPasswordForm(BuildContext context, AuthenticationState state) {
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
                          autofocus: true,
                          enabled: true,
                          label: "Email Address"),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: emailAddressController,
                    builder: (BuildContext context, TextEditingValue value,
                        Widget? child) {
                      return CustomButton(
                        widthVal: 1,
                        buttonText: 'Continue',
                        isLoading: state is ForgotPasswordLoadingState,
                        onPressFunction: value.text.isEmpty ||
                                state is ForgotPasswordLoadingState
                            ? null
                            : () {
                                authenticationBloc.add(ForgotPasswordEvent(
                                    emailAddressController.text));
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
