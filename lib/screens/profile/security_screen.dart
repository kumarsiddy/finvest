import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/password_box.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({Key? key}) : super(key: key);

  @override
  SecurityScreenState createState() => SecurityScreenState();
}

class SecurityScreenState extends State<SecurityScreen> {
  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController retypePasswordController = TextEditingController();

  ValueNotifier<bool> isPasswordFormFilled = ValueNotifier(false);

  String passwordInvalidWarning = '';

  KeyboardVisibilityController keyboardVisibilityController =
      KeyboardVisibilityController();
  bool isKeyboardVisible = false;

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

    oldPasswordController.addListener(() => updatePasswordFormFilled());
    newPasswordController.addListener(() => updatePasswordFormFilled());
    retypePasswordController.addListener(() => updatePasswordFormFilled());
  }

  @override
  void dispose() {
    oldPasswordController.removeListener(updatePasswordFormFilled);
    newPasswordController.removeListener(updatePasswordFormFilled);
    retypePasswordController.removeListener(updatePasswordFormFilled);

    oldPasswordController.dispose();
    newPasswordController.dispose();
    retypePasswordController.dispose();
    super.dispose();
  }

  void updatePasswordFormFilled() {
    final RegExp regex = RegExp(
        r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~_]).{8,}$');
    bool isPasswordValid = regex.hasMatch(newPasswordController.text);
    bool isPasswordMatch =
        newPasswordController.text == retypePasswordController.text;
    isPasswordFormFilled.value = isPasswordValid &&
        isPasswordMatch &&
        oldPasswordController.text.isNotEmpty;

    final password = newPasswordController.text;
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
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return GestureDetector(onTap: () {
      FocusScope.of(context).unfocus();
    }, child: BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is ChangePasswordSuccessState) {
              Navigator.of(context).pop();
              EasyLoading.showToast("Password updated successfully!",
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }
          },
          child: Scaffold(
              resizeToAvoidBottomInset: true,
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
              ),
              body: AbsorbPointer(
                  absorbing: state.status == HomeStateStatus.loading,
                  child: Column(children: [
                    Expanded(
                        child: ListView(
                            shrinkWrap: true,
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                            physics: const BouncingScrollPhysics(),
                            children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 0, bottom: 20),
                            child: Text(
                              "Update Password",
                              textAlign: TextAlign.center,
                              style: AppTheme.headingText,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(bottom: 20),
                            child: Text(
                              "New password must contain at least one uppercase letter, one lowercase letter,"
                              " one digit, one special character, and must be at least 8 characters in length.",
                              textAlign: TextAlign.center,
                              style: AppTheme.bodyNormalGrey,
                            ),
                          ),
                          Card(
                            elevation: 0,
                            color: AppTheme.backgroundColor,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              children: [
                                PasswordBox(
                                    controller: oldPasswordController,
                                    isInputCenter: true,
                                    enabled: true,
                                    padding: 0,
                                    label: "Current Password"),
                                const SizedBox(height: 10),
                                PasswordBox(
                                    controller: newPasswordController,
                                    isInputCenter: true,
                                    enabled: true,
                                    padding: 0,
                                    label: "New Password"),
                                const SizedBox(height: 10),
                                PasswordBox(
                                    controller: retypePasswordController,
                                    isInputCenter: true,
                                    enabled: true,
                                    padding: 0,
                                    label: "Re-type New Password"),
                                passwordInvalidWarning != ''
                                    ? Text(
                                        passwordInvalidWarning,
                                        style: AppTheme.warningMessage,
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        ])),
                    submitButton(context, bottomPadding, state)
                  ]))));
    }));
  }

  Widget submitButton(
      BuildContext context, double bottomPadding, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    return Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
        child: ValueListenableBuilder<bool>(
          valueListenable: isPasswordFormFilled,
          builder: (BuildContext context, bool isFilled, Widget? child) {
            return CustomButton(
              widthVal: 1,
              buttonText: 'Submit',
              isLoading: state is ChangePasswordLoadingState,
              onPressFunction: isFilled && state is! ChangePasswordLoadingState
                  ? () {
                      homeBloc.add(ChangePasswordEvent(
                          oldPasswordController.text,
                          newPasswordController.text));
                    }
                  : null,
            );
          },
        ));
  }
}
