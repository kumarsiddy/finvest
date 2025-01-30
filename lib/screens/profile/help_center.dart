import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/support_request_received_popover.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class HelpCenter extends StatefulWidget {
  const HelpCenter({super.key, required this.userEmail});

  final String userEmail;

  @override
  State<HelpCenter> createState() => _HelpCenterState();
}

class _HelpCenterState extends State<HelpCenter> {
  TextEditingController supportFormController = TextEditingController();
  ValueNotifier<bool> isSupportFormFilled = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    supportFormController.addListener(() => updateIsSupportFormEmpty());
  }

  void updateIsSupportFormEmpty() {
    isSupportFormFilled.value = supportFormController.text.isNotEmpty;
  }

  @override
  void dispose() {
    supportFormController.removeListener(updateIsSupportFormEmpty);
    supportFormController.dispose();
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

              if (state is SendSupportRequestSuccessState) {
                Navigator.of(context).pop();
                showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.9),
                    builder: (context) {
                      return SupportRequestReceivedPopover(
                          userEmail: widget.userEmail);
                    });
              }
            },
            child: Scaffold(
                appBar: AppBar(
                  title: Text(
                    'Help Center',
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
                              "Message us through this form and we'll get back to you shortly.",
                              //" If it's urgent, please call us at (650) 885-9270.",
                              style: AppTheme.bodyNormalGrey,
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(height: 20),
                            supportForm()
                          ],
                        ),
                      ),
                      sendSupportRequestButton(state),
                    ]))));
      },
    ));
  }

  Widget sendSupportRequestButton(HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    // Disable button if support form is empty
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: ValueListenableBuilder<bool>(
            valueListenable: isSupportFormFilled,
            builder: (BuildContext context, bool isFilled, Widget? child) {
              return CustomButton(
                widthVal: 1,
                buttonText: 'Send',
                isLoading: state is SendSupportRequestLoadingState,
                onPressFunction:
                    !isFilled || state is SendSupportRequestLoadingState
                        ? null
                        : () {
                            homeBloc.add(SendSupportRequestEvent(
                                supportFormController.text));
                          },
              );
            }));
  }

  Widget supportForm() {
    return TextField(
      maxLines: 10,
      controller: supportFormController,
      style: AppTheme.bodyNormalGrey,
      decoration: InputDecoration(
          hintText:
              "For your security, don't share your social security number or bank details in this form.",
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.grey)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primary, width: 2))),
    );
  }
}
