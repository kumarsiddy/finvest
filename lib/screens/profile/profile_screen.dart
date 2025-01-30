import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/boxed_text.dart';
import 'package:bondgrid/components/help_center_popover.dart';
import 'package:bondgrid/components/logout_popover.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/models/user_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/profile/account_information.dart';
import 'package:bondgrid/screens/profile/documents_screen.dart';
import 'package:bondgrid/screens/profile/help_center.dart';
import 'package:bondgrid/screens/profile/refer_screen.dart';
import 'package:bondgrid/screens/profile/settings_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen(
      {super.key, required this.showNavBar, required this.scrollController});

  final ValueNotifier<bool> showNavBar;
  final ScrollController scrollController;

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  UserInfo? _userInfo;
  bool _referralProgramActive = false;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPageData({bool useCache = true}) {
    // context.read<HomeBloc>().add(GetUserInfoEvent());
    // context.read<HomeBloc>().add(CheckReferralProgramStatusEvent());
    context
        .read<HomeBloc>()
        .add(LoadProfileScreenInitialDataEvent(useCache: useCache));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }

            if (state is LoadProfileScreenInitialSuccessState) {
              _userInfo = state.userInfo;
              _referralProgramActive = state.active;
            }

            if (state is GetUserInfoSuccessState) {
              _userInfo = state.userInfo;
            }

            if (state is CheckReferralProgramStatusSuccessStatus) {
              _referralProgramActive = state.active;
            }
          },
          child: AbsorbPointer(
              absorbing: state.status == HomeStateStatus.loading,
              child: SafeArea(child: Scaffold(body: LayoutBuilder(builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                    controller: widget.scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: viewportConstraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                            child: Container(
                                margin: const EdgeInsets.only(
                                    top: 10, bottom: 0, left: 15, right: 15),
                                child: Column(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    profileCard(context, state),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    profileMenu(context),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    logOutMenu(context),
                                    // const SizedBox(
                                    //   height: 15,
                                    // ),
                                    // Text(
                                    //   "Version 1.0.0",
                                    //   textAlign: TextAlign.center,
                                    //   style: GoogleFonts.poppins(
                                    //       color: AppTheme.grey,
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: 12),
                                    // ),
                                    // Text(
                                    //   "Finvest",
                                    //   textAlign: TextAlign.center,
                                    //   style: GoogleFonts.poppins(
                                    //       color: AppTheme.grey,
                                    //       fontWeight: FontWeight.w500,
                                    //       fontSize: 12),
                                    // ),
                                    Expanded(child: Container())
                                  ],
                                )))));
              })))));
    });
  }

  Widget profileCard(BuildContext context, HomeState state) {
    return SizedBox(
        width: double.infinity,
        child: Card(
            elevation: 0,
            color: AppTheme.backgroundColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Container(
                padding: const EdgeInsets.fromLTRB(15, 20, 15, 0),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      state is LoadProfileScreenInitialLoadingState
                          ? buildCircularShimmer(context, size: 50)
                          : _userInfo != null &&
                                  _userInfo!.personalDetails.firstName !=
                                      null &&
                                  _userInfo!.personalDetails.lastName != null
                              ? CircleAvatar(
                                  backgroundColor: AppTheme.primary,
                                  radius: 35,
                                  child: Text(
                                    "${_userInfo!.personalDetails.firstName![0].toUpperCase()}${_userInfo!.personalDetails.lastName![0].toUpperCase()}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 30,
                                      color: AppTheme.nearlyWhite,
                                    ),
                                  ), // Adjust the size as needed
                                )
                              : const SizedBox.shrink(),
                      const SizedBox(
                        height: 10,
                      ),
                      state is LoadProfileScreenInitialLoadingState
                          ? buildNumberShimmer(
                              context: context,
                              width: 120,
                              height: 20,
                              padding: const EdgeInsets.only(bottom: 10),
                              borderRadius: BorderRadius.circular(5))
                          : Text(
                              _userInfo != null &&
                                      _userInfo!.personalDetails.firstName !=
                                          null &&
                                      _userInfo!.personalDetails.lastName !=
                                          null
                                  ? "${_userInfo!.personalDetails.firstName} ${_userInfo!.personalDetails.lastName}"
                                  : "",
                              style: AppTheme.titleTextPrimary,
                              textAlign: TextAlign.center,
                            ),
                      state is LoadProfileScreenInitialLoadingState
                          ? buildNumberShimmer(
                              context: context,
                              width: 50,
                              height: 15,
                              padding: const EdgeInsets.only(bottom: 10),
                              borderRadius: BorderRadius.circular(5))
                          : Text(
                              _userInfo != null &&
                                      _userInfo!.personalDetails.email != null
                                  ? "${_userInfo!.personalDetails.email}"
                                  : "",
                              style: AppTheme.secondaryText,
                              textAlign: TextAlign.center,
                            ),
                    ]))));
  }

  Widget profileMenu(BuildContext context) {
    return Card(
        elevation: AppTheme.cardElevation,
        color: AppTheme.nearlyWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          InkWell(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              Navigator.push(
                      context,
                      (Theme.of(context).platform == TargetPlatform.iOS)
                          ? CupertinoPageRoute(
                              builder: (context) => BlocProvider(
                                    create: (context) => HomeBloc(HomeRepo()),
                                    child: AccountInformation(
                                      showNavBar: widget.showNavBar,
                                    ),
                                  ))
                          : MaterialPageRoute(
                              builder: (context) => BlocProvider(
                                    create: (context) => HomeBloc(HomeRepo()),
                                    child: AccountInformation(
                                        showNavBar: widget.showNavBar),
                                  )))
                  .then((_) {
                _loadPageData();
              });
            },
            child: ListTile(
                leading: SvgPicture.asset('lib/assets/account.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'My Account',
                  style: AppTheme.profileText,
                )),
          ),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                widget.showNavBar.value = false;
                Navigator.push(
                        context,
                        (Theme.of(context).platform == TargetPlatform.iOS)
                            ? CupertinoPageRoute(
                                builder: (context) => BlocProvider(
                                      create: (context) => HomeBloc(HomeRepo()),
                                      child: const SettingsScreen(),
                                    ))
                            : MaterialPageRoute(
                                builder: (context) => BlocProvider(
                                      create: (context) => HomeBloc(HomeRepo()),
                                      child: const SettingsScreen(),
                                    )))
                    .then((_) {
                  widget.showNavBar.value = true;
                });
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/settings.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Settings',
                  style: AppTheme.profileText,
                ),
              )),
          _referralProgramActive
              ? InkWell(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  onTap: () {
                    widget.showNavBar.value = false;
                    Navigator.push(
                            context,
                            (Theme.of(context).platform == TargetPlatform.iOS)
                                ? CupertinoPageRoute(
                                    builder: (context) => BlocProvider(
                                          create: (context) =>
                                              HomeBloc(HomeRepo()),
                                          child: const ReferScreen(),
                                        ))
                                : MaterialPageRoute(
                                    builder: (context) => BlocProvider(
                                          create: (context) =>
                                              HomeBloc(HomeRepo()),
                                          child: const ReferScreen(),
                                        )))
                        .then((_) {
                      widget.showNavBar.value = true;
                    });
                  },
                  child: ListTile(
                    leading: SvgPicture.asset('lib/assets/gift.svg',
                        height: 25, width: 25, color: AppTheme.primary),
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Refer & Earn',
                            style: AppTheme.profileText,
                          ),
                          BoxedText(
                            text: "New",
                            backgroundColor: AppTheme.primary.withOpacity(0.2),
                            textColor: AppTheme.primary,
                          ),
                        ]),
                  ))
              : const SizedBox.shrink(),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                Navigator.push(
                    context,
                    (Theme.of(context).platform == TargetPlatform.iOS)
                        ? CupertinoPageRoute(
                            builder: (context) => BlocProvider(
                                  create: (context) => HomeBloc(HomeRepo()),
                                  child: const DocumentsScreen(),
                                ))
                        : MaterialPageRoute(
                            builder: (context) => BlocProvider(
                                  create: (context) => HomeBloc(HomeRepo()),
                                  child: const DocumentsScreen(),
                                )));
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/folder.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Documents',
                  style: AppTheme.profileText,
                ),
              )),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap:
                  _userInfo != null && _userInfo!.personalDetails.email != null
                      ? () {
                          Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: HelpCenter(
                                                userEmail: _userInfo!
                                                    .personalDetails.email!),
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) => BlocProvider(
                                            create: (context) =>
                                                HomeBloc(HomeRepo()),
                                            child: HelpCenter(
                                                userEmail: _userInfo!
                                                    .personalDetails.email!),
                                          )));
                        }
                      : () {
                          showDialog(
                              context: context,
                              barrierColor: Colors.black.withOpacity(0.9),
                              builder: (context) {
                                return const HelpCenterPopover();
                              });
                        },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/support.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Help Center',
                  style: AppTheme.profileText,
                ),
              )),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                const url = "https://www.getfinvest.com/legal";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/office-folder.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Disclosures',
                  style: AppTheme.profileText,
                ),
              )),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                const url = "https://www.getfinvest.com/support/fee-schedule";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/dollar.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Finvest Fees',
                  style: AppTheme.profileText,
                ),
              )),
        ]));
  }

  Widget logOutMenu(BuildContext context) {
    return Card(
        elevation: AppTheme.cardElevation,
        color: AppTheme.nearlyWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(children: [
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                const url = "https://www.getfinvest.com/support/about-finvest";
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url));
                }
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/game.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'About Us',
                  style: AppTheme.profileText,
                ),
              )),
          InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showDialog(
                    context: context,
                    barrierColor: Colors.black.withOpacity(0.9),
                    builder: (context) {
                      return const LogoutPopover();
                    });
              },
              child: ListTile(
                leading: SvgPicture.asset('lib/assets/arrow.svg',
                    height: 25, width: 25, color: AppTheme.primary),
                title: Text(
                  'Log Out',
                  style: AppTheme.profileText,
                ),
              )),
        ]));
  }
}
