import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SubmitVerificationInfo extends StatefulWidget {
  const SubmitVerificationInfo({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<SubmitVerificationInfo> createState() => _SubmitVerificationInfoState();
}

class _SubmitVerificationInfoState extends State<SubmitVerificationInfo> {
  TextEditingController userInputController = TextEditingController();
  ValueNotifier<bool> isInputFormFilled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    userInputController.addListener(() => updateIsFormEmpty());
  }

  void updateIsFormEmpty() {
    isInputFormFilled.value = userInputController.text.isNotEmpty;
  }

  @override
  void dispose() {
    userInputController.removeListener(updateIsFormEmpty);
    userInputController.dispose();
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

              if (state is SubmitVerificationInfoSuccessState) {
                Navigator.of(context).pop();
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Submit Information',
                    style: AppTheme.profileText,
                    textAlign: TextAlign.center,
                  ),
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
                            const SizedBox(height: 20),
                            Text(
                              "Submit the missing account information through this form and we'll review your account shortly.",
                              style: AppTheme.bodyNormalGrey,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 20),
                            userInputForm()
                          ],
                        ),
                      ),
                      sendButton(state),
                    ]))));
      },
    ));
  }

  Widget sendButton(HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    // Disable button if form is empty
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: ValueListenableBuilder<bool>(
            valueListenable: isInputFormFilled,
            builder: (BuildContext context, bool isFilled, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Send',
                isLoading: state is SubmitVerificationInfoLoadingState,
                onPressFunction:
                    !isFilled || state is SubmitVerificationInfoLoadingState
                        ? null
                        : () {
                            homeBloc.add(SubmitVerificationInfoEvent(
                                userInputController.text));
                          },
              );
            }));
  }

  Widget userInputForm() {
    return TextField(
      maxLines: 10,
      controller: userInputController,
      style: AppTheme.bodyNormalGrey,
      decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2))),
    );
  }
}
