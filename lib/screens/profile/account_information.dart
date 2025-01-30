import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/input_box.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/profile/request_account_closure.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

class AccountInformation extends StatefulWidget {
  const AccountInformation({Key? key, required this.showNavBar})
      : super(key: key);

  final ValueNotifier<bool> showNavBar;

  @override
  AccountInformationState createState() => AccountInformationState();
}

class AccountInformationState extends State<AccountInformation>
    with WidgetsBindingObserver {
  UserInfo? _userInfo;
  ValueNotifier<bool> isFormFilled = ValueNotifier(false);

  TextEditingController firstNameController = TextEditingController();
  TextEditingController middleNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

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

    WidgetsBinding.instance.addObserver(this);
    _loadPageData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _loadPageData();
    }
  }

  void _loadPageData() {
    context.read<HomeBloc>().add(GetUserInfoEvent());
  }

  void setDefaultState() {
    if (_userInfo != null) {
      firstNameController.text = _userInfo!.personalDetails.firstName ?? "";
      middleNameController.text = _userInfo!.personalDetails.middleName ?? "";
      lastNameController.text = _userInfo!.personalDetails.lastName ?? "";
    }
  }

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

            if (state is GetUserInfoSuccessState) {
              _userInfo = state.userInfo;
              setDefaultState();
            }

            if (state is UpdateNameSuccessState) {
              _userInfo = state.userInfo;
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              }
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
                // title: Text(
                //   'Account Information',
                //   style: AppTheme.profileText,
                //   textAlign: TextAlign.center,
                // ),
              ),
              body: _userInfo == null
                  ? const SizedBox.shrink()
                  : AbsorbPointer(
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
                                  margin:
                                      const EdgeInsets.only(top: 0, bottom: 20),
                                  child: Text(
                                    "Account Information",
                                    textAlign: TextAlign.center,
                                    style: AppTheme.headingText,
                                  ),
                                ),
                                Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Name',
                                        style: AppTheme.bodyNormalGrey,
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        _userInfo!.personalDetails.firstName !=
                                                    null &&
                                                _userInfo!.personalDetails
                                                        .lastName !=
                                                    null
                                            ? _userInfo!.personalDetails
                                                            .middleName !=
                                                        null &&
                                                    _userInfo!.personalDetails
                                                        .middleName!.isNotEmpty
                                                ? "${_userInfo!.personalDetails.firstName} ${_userInfo!.personalDetails.middleName} ${_userInfo!.personalDetails.lastName}"
                                                : "${_userInfo!.personalDetails.firstName} ${_userInfo!.personalDetails.lastName}"
                                            : "",
                                        style: AppTheme.bodyNormal,
                                        overflow: TextOverflow.visible,
                                      ),
                                    ]),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Email address',
                                      style: AppTheme.bodyNormalGrey,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _userInfo!.personalDetails.email != null
                                          ? _userInfo!.personalDetails.email!
                                          : "",
                                      style: AppTheme.bodyNormal,
                                      overflow: TextOverflow.visible,
                                    )
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phone number',
                                      style: AppTheme.bodyNormalGrey,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _userInfo!.personalDetails.phoneNumber !=
                                              null
                                          ? _userInfo!
                                              .personalDetails.phoneNumber!
                                          : "",
                                      style: AppTheme.bodyNormal,
                                      overflow: TextOverflow.visible,
                                    )
                                  ],
                                ),
                                const Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Address',
                                      style: AppTheme.bodyNormalGrey,
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      _userInfo!.personalDetails
                                          .formatAddress(),
                                      style: AppTheme.bodyNormal,
                                      overflow: TextOverflow.visible,
                                    )
                                  ],
                                ),
                                const Divider()
                              ]),
                        ),
                        deleteAccountButton(context)
                      ]))));
    });
  }

  Widget deleteAccountButton(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
        child: CustomButton(
          heightVal: 0.05,
          widthVal: 1,
          buttonText: 'Delete Account',
          primaryColor: AppTheme.backgroundColor,
          borderColor: AppTheme.red,
          textColor: AppTheme.red,
          onPressFunction: () {
            Navigator.push(
                context,
                (Theme.of(context).platform == TargetPlatform.iOS)
                    ? CupertinoPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: const RequestAccountClosure(),
                            ))
                    : MaterialPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: const RequestAccountClosure(),
                            )));
          },
        ));
  }

  void showNameUpdateModalSheet(BuildContext context, HomeBloc homeBloc) {
    setDefaultState();
    widget.showNavBar.value = false;
    showModalBottomSheet(
      isDismissible: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20), topRight: Radius.circular(20)),
      ),
      context: context,
      builder: (BuildContext context) {
        // If the keyboard is visible, use the keyboard's height as the bottom padding
        double bottomPadding =
            isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

        return NotificationListener<OverscrollIndicatorNotification>(
            onNotification: (overscroll) {
              overscroll.disallowIndicator();
              return true;
            },
            child: Padding(
                padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPadding),
                child: BlocBuilder<HomeBloc, HomeState>(
                  bloc: homeBloc,
                  builder: (context, state) {
                    return ListView(shrinkWrap: true, children: [
                      ListTile(
                        title: Text('Edit Your Name',
                            style: AppTheme.bodyBold,
                            textAlign: TextAlign.center),
                      ),
                      InputBox(
                          controller: firstNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "First Name"),
                      InputBox(
                          controller: middleNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "Middle Name"),
                      InputBox(
                          controller: lastNameController,
                          isInputCenter: true,
                          textCapitalization: true,
                          enabled: true,
                          label: "Last Name"),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomButton(
                              widthVal: 2.3,
                              buttonText: 'Cancel',
                              primaryColor: AppTheme.backgroundColor,
                              borderColor: AppTheme.primary,
                              textColor: AppTheme.primary,
                              onPressFunction: () {
                                Navigator.pop(context);
                              },
                            ),
                            CustomButton(
                              widthVal: 2.3,
                              buttonText: 'Continue',
                              isLoading: state is UpdateNameLoadingState,
                              onPressFunction: state is UpdateNameLoadingState
                                  ? null
                                  : () {
                                      homeBloc.add(UpdateNameEvent(
                                          firstNameController.text,
                                          middleNameController.text,
                                          lastNameController.text));
                                    },
                            )
                          ]),
                    ]);
                  },
                )));
      },
    ).then(
      (value) {
        widget.showNavBar.value = true;
      },
    );
  }
}
