import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/email_signup_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class NameSignupForm extends StatefulWidget {
  const NameSignupForm({super.key});

  @override
  NameSignupFormState createState() => NameSignupFormState();
}

class NameSignupFormState extends State<NameSignupForm> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  ValueNotifier<bool> isNameFormFilled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    firstNameController.addListener(() => updateNameFormFilled());
    lastNameController.addListener(() => updateNameFormFilled());

    updateNameFormFilled();
  }

  @override
  void dispose() {
    firstNameController.removeListener(updateNameFormFilled);
    lastNameController.removeListener(updateNameFormFilled);

    firstNameController.dispose();
    lastNameController.dispose();

    isNameFormFilled.dispose();
    super.dispose();
  }

  void updateNameFormFilled() {
    isNameFormFilled.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty;
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
            },
            child: nameForm(context, state));
      },
    );
  }

  Widget nameForm(BuildContext context, AuthenticationState state) {
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
                        autofocus: true,
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
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
                  child: ValueListenableBuilder<bool>(
                    valueListenable: isNameFormFilled,
                    builder:
                        (BuildContext context, bool isFilled, Widget? child) {
                      return CustomButton(
                        widthVal: 1,
                        buttonText: 'Continue',
                        isLoading:
                            state.status == AuthenticationStateStatus.loading,
                        onPressFunction: isFilled &&
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
                                                child: EmailSignupForm(
                                                  firstName:
                                                      firstNameController.text,
                                                  middleName:
                                                      middleNameController.text,
                                                  lastName:
                                                      lastNameController.text,
                                                )))
                                        : MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    AuthenticationBloc(
                                                        AuthenticationRepo()),
                                                child: EmailSignupForm(
                                                  firstName:
                                                      firstNameController.text,
                                                  middleName:
                                                      middleNameController.text,
                                                  lastName:
                                                      lastNameController.text,
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
