import 'package:bondgrid/components/phone_number_box.dart';
import 'package:bondgrid/repo/authentication_repo.dart';
import 'package:bondgrid/screens/authentication/phone_otp_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bondgrid/bloc/authentication_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class PhoneNumberForm extends StatefulWidget {
  const PhoneNumberForm({super.key});

  @override
  PhoneNumberFormState createState() => PhoneNumberFormState();
}

class PhoneNumberFormState extends State<PhoneNumberForm> {
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController unmaskedPhoneNumberController = TextEditingController();

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

              if (state is GeneratePhoneOTPSuccessState) {
                Navigator.push(
                    context,
                    (Theme.of(context).platform == TargetPlatform.iOS)
                        ? CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const PhoneOtpForm()))
                        : MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                create: (context) =>
                                    AuthenticationBloc(AuthenticationRepo()),
                                child: const PhoneOtpForm())));
              }
            },
            child: phoneNumberForm(context, state));
      },
    );
  }

  Widget phoneNumberForm(BuildContext context, AuthenticationState state) {
    final authenticationBloc = BlocProvider.of<AuthenticationBloc>(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        elevation: 0,
        // leading: IconButton(
        //   onPressed: () {
        //     Navigator.of(context).pop();
        //   },
        //   icon: Icon(
        //     Icons.keyboard_arrow_left_rounded,
        //     color: AppTheme.actionButton,
        //     size: 22,
        //   ),
        // ),
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
                          autofocus: true,
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
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
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
              ],
            ),
          ))),
    );
  }
}
