import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/models/referral.dart';
import 'package:bondgrid/models/referral_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/profile/missing_referral.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';

class ReferralHistory extends StatefulWidget {
  const ReferralHistory({super.key, required this.referralInfo});

  final ReferralInfo referralInfo;

  @override
  ReferralHistoryState createState() => ReferralHistoryState();
}

class ReferralHistoryState extends State<ReferralHistory> {
  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPageData() {}

  @override
  Widget build(BuildContext context) {
    var pendingFilteredReferrals =
        widget.referralInfo.referralList.where((referral) {
      return referral.status == "Pending";
    }).toList();
    var completedFilteredReferrals =
        widget.referralInfo.referralList.where((referral) {
      return referral.status == "Completed";
    }).toList();
    var expiredFilteredReferrals =
        widget.referralInfo.referralList.where((referral) {
      return referral.status == "Expired";
    }).toList();

    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {
            if (state.status == HomeStateStatus.failure) {
              FocusScope.of(context).unfocus();
              EasyLoading.showToast(state.errorMessage,
                  toastPosition: EasyLoadingToastPosition.bottom,
                  duration: const Duration(seconds: 5));
            }
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "Referral History",
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
                child: SingleChildScrollView(
                  child: Padding(
                      padding: EdgeInsets.fromLTRB(
                          20, 20, 20, LayoutConfig().bottomPadding + 20),
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              alignment: Alignment.topLeft,
                              margin: const EdgeInsets.only(top: 0, bottom: 10),
                              child: GestureDetector(
                                  onTap: () {
                                    showInfoModal(
                                      context: context,
                                      title: 'Pending Referrals',
                                      subtext:
                                          'Referrals marked as "Pending" are waiting for the referred person'
                                          ' to invest in Treasury Bills.',
                                    );
                                  },
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Pending",
                                          textAlign: TextAlign.center,
                                          style: AppTheme.sectionTitle,
                                        ),
                                        const SizedBox(width: 5),
                                        const Icon(
                                          Icons.info_outline,
                                          color: AppTheme.primary,
                                          size: 18,
                                        ),
                                      ])),
                            ),
                            SizedBox(
                                width: double.infinity,
                                child: Container(
                                    padding: const EdgeInsets.all(0),
                                    child: pendingFilteredReferrals.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 0, 15, 10),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Nothing to show here",
                                                    style:
                                                        AppTheme.subBodyNormal,
                                                  )
                                                ]))
                                        : listReferrals(context, state,
                                            pendingFilteredReferrals,
                                            status: "Pending"))),
                            const SizedBox(
                              height: 20,
                            ),
                            Container(
                                alignment: Alignment.topLeft,
                                margin:
                                    const EdgeInsets.only(top: 0, bottom: 10),
                                child: GestureDetector(
                                    onTap: () {
                                      showInfoModal(
                                        context: context,
                                        title: 'Active Referrals',
                                        subtext:
                                            'Referrals marked as "Active" indicate that the referred'
                                            ' person has successfully activated their account and invested'
                                            ' in Treasury Bills.',
                                      );
                                    },
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Active",
                                            textAlign: TextAlign.center,
                                            style: AppTheme.sectionTitle,
                                          ),
                                          const SizedBox(width: 5),
                                          const Icon(
                                            Icons.info_outline,
                                            color: AppTheme.primary,
                                            size: 18,
                                          ),
                                        ]))),
                            SizedBox(
                                width: double.infinity,
                                child: Container(
                                    padding: const EdgeInsets.all(0),
                                    child: completedFilteredReferrals.isEmpty
                                        ? Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                15, 0, 15, 10),
                                            child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    "Nothing to show here",
                                                    style:
                                                        AppTheme.subBodyNormal,
                                                  )
                                                ]))
                                        : listReferrals(context, state,
                                            completedFilteredReferrals,
                                            status: "Completed"))),
                            const SizedBox(
                              height: 20,
                            ),
                            expiredFilteredReferrals.isNotEmpty
                                ? Column(children: [
                                    Container(
                                        alignment: Alignment.topLeft,
                                        margin: const EdgeInsets.only(
                                            top: 0, bottom: 10),
                                        child: GestureDetector(
                                            onTap: () {
                                              showInfoModal(
                                                context: context,
                                                title: 'Expired Referrals',
                                                subtext:
                                                    'Referrals marked as "Expired" are those where the referred'
                                                    ' person did not invest in Treasury Bills within 30 days of sign up.',
                                              );
                                            },
                                            child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    "Expired",
                                                    textAlign: TextAlign.center,
                                                    style:
                                                        AppTheme.sectionTitle,
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Icon(
                                                    Icons.info_outline,
                                                    color: AppTheme.primary,
                                                    size: 18,
                                                  ),
                                                ]))),
                                    SizedBox(
                                        width: double.infinity,
                                        child: Container(
                                            padding: const EdgeInsets.all(0),
                                            child: listReferrals(context, state,
                                                expiredFilteredReferrals,
                                                status: "Expired"))),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ])
                                : const SizedBox.shrink(),
                            const Divider(),
                            const SizedBox(
                              height: 10,
                            ),
                            InkWell(
                                splashColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    (Theme.of(context).platform ==
                                            TargetPlatform.iOS)
                                        ? CupertinoPageRoute(
                                            builder: (context) => BlocProvider(
                                                  create: (context) =>
                                                      HomeBloc(HomeRepo()),
                                                  child:
                                                      const MissingReferral(),
                                                ))
                                        : MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                                  create: (context) =>
                                                      HomeBloc(HomeRepo()),
                                                  child:
                                                      const MissingReferral(),
                                                )),
                                  );
                                },
                                child: Row(children: [
                                  Expanded(
                                      child: Text(
                                    'Missing Referrals?',
                                    style: AppTheme.bodyNormal,
                                  )),
                                  Icon(
                                    Icons.keyboard_arrow_right_rounded,
                                    size: 26,
                                    color: Colors.grey[600]!.withOpacity(0.4),
                                  ),
                                ])),
                          ])),
                ),
              )));
    });
  }

  Widget listReferrals(
      BuildContext context, HomeState state, List<Referral> filteredReferrals,
      {status = "Completed"}) {
    return Column(
      children: filteredReferrals.map((referral) {
        return Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 10),
            child: ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 100,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              referral.name ?? "",
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.bodyNormal,
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                style: DefaultTextStyle.of(context).style,
                                children: <TextSpan>[
                                  status == "Completed" &&
                                          referral.activatedDate != null
                                      ? TextSpan(
                                          text: formatDate(
                                              referral.activatedDate),
                                          style: AppTheme.subBodyNormal,
                                        )
                                      : referral.referralDate != null
                                          ? TextSpan(
                                              text: formatDate(
                                                  referral.referralDate!),
                                              style: AppTheme.subBodyNormal,
                                            )
                                          : TextSpan(
                                              text: "",
                                              style: AppTheme.subBodyNormal,
                                            ),
                                ],
                              ),
                            ),
                          ])),
                ],
              ),
            ));
      }).toList(),
    );
  }
}
