import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/account_closure_popover.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class RequestAccountClosure extends StatefulWidget {
  const RequestAccountClosure({Key? key}) : super(key: key);

  @override
  State<RequestAccountClosure> createState() => _RequestAccountClosureState();
}

class _RequestAccountClosureState extends State<RequestAccountClosure> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
        listener: (context, state) {
          if (state.status == HomeStateStatus.failure) {
            FocusScope.of(context).unfocus();
            EasyLoading.showToast(state.errorMessage,
                toastPosition: EasyLoadingToastPosition.bottom,
                duration: const Duration(seconds: 5));
          }

          if (state is RequestAccountClosureSuccessState) {
            while (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
            showDialog(
                context: context,
                barrierColor: Colors.black.withOpacity(0.9),
                builder: (context) {
                  return const AccountClosurePopover();
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
            absorbing: state is RequestAccountClosureLoadingState,
            child: accountClosureInfo(state),
          ),
        ),
      );
    });
  }

  Widget accountClosureInfo(HomeState state) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            physics: const BouncingScrollPhysics(),
            children: [
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Request to close Finvest account',
                  style: AppTheme.headingText,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'Before closing an account, make sure that you liquidate all your holdings and ensure your account has no balance.',
                  style: AppTheme.bodyNormalGrey,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'After we receive your account closure request, we might follow up with you on email for any additional information which might be required.',
                  style: AppTheme.bodyNormalGrey,
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: const EdgeInsets.only(bottom: 20),
                child: Text(
                  'If you have any questions or need any assistance, please reach out at support@getfinvest.com.',
                  style: AppTheme.bodyNormalGrey,
                ),
              ),
            ],
          ),
        ),
        accountClosureButton(context, state),
      ],
    );
  }

  Widget accountClosureButton(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: CustomButton(
        heightVal: 0.05,
        widthVal: 1,
        buttonText: 'Request account closure',
        primaryColor: AppTheme.red,
        borderColor: AppTheme.red,
        isLoading: state is RequestAccountClosureLoadingState,
        onPressFunction: () {
          state is RequestAccountClosureLoadingState
              ? null
              : homeBloc.add(RequestAccountClosureEvent());
        },
      ),
    );
  }
}
