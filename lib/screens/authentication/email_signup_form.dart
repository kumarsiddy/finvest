import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/password_signup_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/screens/home/navigator_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EmailSignupForm extends StatefulWidget {
  const EmailSignupForm({
    super.key,
    required this.firstName,
    required this.middleName,
    required this.lastName,
  });

  final String firstName;
  final String middleName;
  final String lastName;

  @override
  EmailSignupFormState createState() => EmailSignupFormState();
}

class EmailSignupFormState extends State<EmailSignupForm> {
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
            child: emailForm(context, state));
      },
    );
  }

  Widget emailForm(BuildContext context, AuthenticationState state) {
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
                      final RegExp regex =
                          RegExp(r"^[a-zA-Z0-9._]+@[a-zA-Z0-9.-]+\.[a-zA-Z]+");
                      bool isEmailValid = regex.hasMatch(value.text);
                      return CustomButton(
                        widthVal: 1,
                        buttonText: 'Continue',
                        isLoading:
                            state.status == AuthenticationStateStatus.loading,
                        onPressFunction: isEmailValid &&
                                state.status !=
                                    AuthenticationStateStatus.loading
                            ? () {
                                Navigator.push(
                                    context,
                                    (Theme.of(context).platform ==
                                            TargetPlatform.iOS)
                                        ? CupertinoPageRoute(
                                            builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    AuthenticationBloc(
                                                        AuthenticationRepo()),
                                                child: PasswordSignupForm(
                                                  firstName: widget.firstName,
                                                  middleName: widget.middleName,
                                                  lastName: widget.lastName,
                                                  email: emailAddressController
                                                      .text,
                                                )))
                                        : MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    AuthenticationBloc(
                                                        AuthenticationRepo()),
                                                child: PasswordSignupForm(
                                                  firstName: widget.firstName,
                                                  middleName: widget.middleName,
                                                  lastName: widget.lastName,
                                                  email: emailAddressController
                                                      .text,
                                                ))));
                              }
                            : null,
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
