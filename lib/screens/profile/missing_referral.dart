import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/components/missing_referral_popover.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class MissingReferral extends StatefulWidget {
  const MissingReferral({Key? key}) : super(key: key);

  @override
  State<MissingReferral> createState() => _MissingReferralState();
}

class _MissingReferralState extends State<MissingReferral> {
  TextEditingController missingReferralEmailController =
      TextEditingController();
  ValueNotifier<bool> isMissingReferralEmailFilled = ValueNotifier(false);

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

    missingReferralEmailController
        .addListener(() => updateIsmissingReferralFormEmpty());
  }

  void updateIsmissingReferralFormEmpty() {
    isMissingReferralEmailFilled.value =
        missingReferralEmailController.text.isNotEmpty;
  }

  @override
  void dispose() {
    missingReferralEmailController
        .removeListener(updateIsmissingReferralFormEmpty);
    missingReferralEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(onTap: () {
      FocusScope.of(context).unfocus();
    }, child: BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return BlocListener<HomeBloc, HomeState>(
            listener: (context, state) {
              if (state.status == HomeStateStatus.failure) {
                FocusScope.of(context).unfocus();
                EasyLoading.showToast(state.errorMessage,
                    toastPosition: EasyLoadingToastPosition.bottom,
                    duration: const Duration(seconds: 5));
              }

              if (state is MissingReferralRequestSuccessState) {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.9),
                    builder: (context) {
                      return const MissingReferralPopover();
                    });
              }
            },
            child: Scaffold(
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
                                "Add Missing Referral",
                                textAlign: TextAlign.center,
                                style: AppTheme.headingText,
                              ),
                            ),
                            Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                "If the person you invited has joined Finvest but does not show up in your referral history, you can add their email below.",
                                textAlign: TextAlign.center,
                                style: AppTheme.bodyNormalGrey,
                              ),
                            ),
                            InputBox(
                                controller: missingReferralEmailController,
                                isInputCenter: true,
                                enabled: true,
                                label: "Email Address"),
                          ],
                        ),
                      ),
                      sendMissingReferralRequestButton(state),
                    ]))));
      },
    ));
  }

  Widget sendMissingReferralRequestButton(HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    // Disable button if email form is empty
    return Padding(
        padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
        child: ValueListenableBuilder<bool>(
            valueListenable: isMissingReferralEmailFilled,
            builder: (BuildContext context, bool isFilled, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Submit',
                isLoading: state is MissingReferralRequestLoadingState,
                onPressFunction:
                    !isFilled || state is MissingReferralRequestLoadingState
                        ? null
                        : () {
                            homeBloc.add(MissingReferralRequestEvent(
                                missingReferralEmailController.text));
                          },
              );
            }));
  }
}
