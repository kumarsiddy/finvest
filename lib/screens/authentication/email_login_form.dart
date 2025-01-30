import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/password_box.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/otp_login_form.dart';
import 'package:bondgrid/screens/authentication/phone_number_form.dart';
import 'package:bondgrid/screens/authentication/reset_password_form.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class EmailLoginForm extends StatefulWidget {
  const EmailLoginForm({super.key});

  @override
  EmailLoginFormState createState() => EmailLoginFormState();
}

class EmailLoginFormState extends State<EmailLoginForm> {
  ValueNotifier<bool> isFormFilled = ValueNotifier(false);

  TextEditingController emailAddressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

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
                Navigator.push(
                    context,
                    (Theme.of(context).platform == TargetPlatform.iOS)
                        ? CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const OtpLoginForm()))
                        : MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const OtpLoginForm())));
              }

              if (state is LoginPhoneState) {
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
            child: emailForm(context, state));
      },
    );
  }

  Widget emailForm(BuildContext context, AuthenticationState state) {
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
                              Navigator.push(
                                  context,
                                  (Theme.of(context).platform ==
                                          TargetPlatform.iOS)
                                      ? CupertinoPageRoute(
                                          builder: (context) => BlocProvider(
                                              create: (context) =>
                                                  AuthenticationBloc(
                                                      AuthenticationRepo()),
                                              child: const ResetPasswordForm()))
                                      : MaterialPageRoute(
                                          builder: (context) => BlocProvider(
                                              create: (context) =>
                                                  AuthenticationBloc(
                                                      AuthenticationRepo()),
                                              child:
                                                  const ResetPasswordForm())));
                            },
                            child: Text(
                              "Forgot Password?",
                              textAlign: TextAlign.center,
                              style: AppTheme.secondaryTextBold,
                            ),
                          )
                        ])),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                      child: ValueListenableBuilder<bool>(
                        valueListenable: isFormFilled,
                        builder: (BuildContext context, bool isFilled,
                            Widget? child) {
                          return CustomButton(
                            widthVal: 1,
                            buttonText: 'Continue',
                            isLoading: state is LoginLoadingState,
                            onPressFunction:
                                isFilled && state is! LoginLoadingState
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
                  ]))),
        ));
  }
}
