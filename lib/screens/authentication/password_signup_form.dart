import 'package:bondgrid/components/password_box.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/otp_signup_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PasswordSignupForm extends StatefulWidget {
  const PasswordSignupForm(
      {super.key,
      required this.firstName,
      required this.middleName,
      required this.lastName,
      required this.email});

  final String firstName;
  final String middleName;
  final String lastName;
  final String email;

  @override
  PasswordSignupFormState createState() => PasswordSignupFormState();
}

class PasswordSignupFormState extends State<PasswordSignupForm> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  ValueNotifier<bool> isPasswordFormFilled = ValueNotifier(false);

  String passwordInvalidWarning = '';

  @override
  void initState() {
    super.initState();

    passwordController.addListener(() => updatePasswordFormFilled());
    retypePasswordController.addListener(() => updatePasswordFormFilled());

    updatePasswordFormFilled();
  }

  @override
  void dispose() {
    passwordController.removeListener(updatePasswordFormFilled);
    retypePasswordController.removeListener(updatePasswordFormFilled);

    passwordController.dispose();
    retypePasswordController.dispose();

    isPasswordFormFilled.dispose();
    super.dispose();
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
                Navigator.push(
                    context,
                    (Theme.of(context).platform == TargetPlatform.iOS)
                        ? CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const OtpSignupForm()))
                        : MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const OtpSignupForm())));
              }
            },
            child: passwordForm(context, state));
      },
    );
  }

  Widget passwordForm(BuildContext context, AuthenticationState state) {
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isPasswordFormFilled,
                    builder:
                        (BuildContext context, bool isFilled, Widget? child) {
                      return CustomButton(
                        widthVal: 1,
                        buttonText: 'Continue',
                        isLoading: state is RegisterLoadingState,
                        onPressFunction:
                            isFilled && state is! RegisterLoadingState
                                ? () {
                                    authenticationBloc.add(RegisterEvent(
                                        widget.firstName,
                                        widget.middleName,
                                        widget.lastName,
                                        widget.email,
                                        passwordController.text));
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
