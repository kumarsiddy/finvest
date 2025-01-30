import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/components/info_modal.dart';
import 'package:bondgrid/components/shimmer.dart';
import 'package:bondgrid/constants/shared_constants.dart';
import 'package:bondgrid/models/referral_info.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/apps_flyer_manager.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/screens/profile/referral_history.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferScreen extends StatefulWidget {
  const ReferScreen({super.key});

  @override
  ReferScreenState createState() => ReferScreenState();
}

class ReferScreenState extends State<ReferScreen> {
  String interestRate = '5.3';
  String referralBonus = '1.2';
  String totalInterestRate = '6.5';

  String? referralCode;
  String? referralLink;

  ReferralInfo? referralInfo;

  late AppsFlyerInviteLinkParams inviteLinkParams;

  @override
  void initState() {
    super.initState();
    _loadPageData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _loadPageData() {
    context.read<HomeBloc>().add(LoadReferralScreenInitialDataEvent());
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

            if (state is LoadReferralScreenInitialSuccessState) {
              referralInfo = state.referralInfo;

              interestRate = state.referralInfo.interestRate != null
                  ? double.parse(state.referralInfo.interestRate!)
                      .toStringAsFixed(1)
                  : '5.3';
              referralBonus = state.referralInfo.referralBonus != null
                  ? double.parse(state.referralInfo.referralBonus!)
                      .toStringAsFixed(1)
                  : '1.2';

              if (state.referralInfo.interestRate != null &&
                  state.referralInfo.referralBonus != null) {
                totalInterestRate =
                    (double.parse(state.referralInfo.interestRate!) +
                            double.parse(state.referralInfo.referralBonus!))
                        .toStringAsFixed(1);
              }

              referralCode = state.referralInfo.referralCode ?? '';

              // AppsFlyer supports only the deep_link_value and deep_link_sub1 query params
              // using custom params do not work - https://content.appsflyer.com/ios-hub/deep-linking/
              AppsFlyerInviteLinkParams inviteLinkParams =
                  AppsFlyerInviteLinkParams(
                      brandDomain: APPSFLYER.BRAND_DOMAIN,
                      customParams: {"deep_link_value": referralCode});

              final appsflyerSdk = AppsFlyerManager().sdk;
              appsflyerSdk.generateInviteLink(inviteLinkParams, (result) {
                if (result.containsKey('payload') &&
                    result['payload'] != null &&
                    result['payload'].containsKey('userInviteURL') &&
                    result['payload']['userInviteURL'] != null) {
                  setState(() {
                    referralLink = result['payload']['userInviteURL'];
                  });
                }
              }, (error) {
                referralLink = referralCode;
              });
            }
          },
          child: Scaffold(
              appBar: AppBar(
                title: Text(
                  "Finvest Referral",
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
                actions: <Widget>[
                  Padding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      child: TextButton(
                        onPressed: referralInfo == null
                            ? null
                            : () {
                                Navigator.push(
                                    context,
                                    (Theme.of(context).platform ==
                                            TargetPlatform.iOS)
                                        ? CupertinoPageRoute(
                                            builder: (context) => BlocProvider(
                                                  create: (context) =>
                                                      HomeBloc(HomeRepo()),
                                                  child: ReferralHistory(
                                                    referralInfo: referralInfo!,
                                                  ),
                                                ))
                                        : MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                                  create: (context) =>
                                                      HomeBloc(HomeRepo()),
                                                  child: ReferralHistory(
                                                    referralInfo: referralInfo!,
                                                  ),
                                                )));
                              },
                        child: const Icon(Icons.history,
                            color: AppTheme.primary, size: 22),
                        // child: Text("History",
                        //     style: GoogleFonts.poppins(
                        //         color: AppTheme.primary,
                        //         fontWeight: FontWeight.w500,
                        //         fontSize: 12))
                      )),
                ],
              ),
              body: state is LoadReferralScreenInitialLoadingState
                  ? buildFullPageShimmer(context)
                  : AbsorbPointer(
                      absorbing: state.status == HomeStateStatus.loading,
                      child: Stack(children: [
                        SingleChildScrollView(
                          child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                              child: Column(children: [
                                if (referralInfo != null &&
                                    referralInfo!.selfReferralStatus != null &&
                                    referralInfo!.selfReferralStatus! ==
                                        "Pending")
                                  selfReferralMessageCard(context),
                                headingCard(context),
                                if (referralInfo != null &&
                                    referralInfo!.numberOfReferrals != null &&
                                    referralInfo!.totalBonusAmount != null &&
                                    referralInfo!.daysLeft != null)
                                  bonusSummaryCard(context),
                                bonusInfoCard(context),
                                howItWorksCard(context),
                                SizedBox(height: getButtonHeight(context)),
                              ])),
                        ),
                        shareButton(context)
                      ]))));
    });
  }

  Widget selfReferralMessageCard(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 30),
        child: Center(
            child: Card(
          elevation: 0,
          color: AppTheme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side:
                BorderSide(width: 1, color: Colors.grey[600]!.withOpacity(0.2)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Theme(
                data: ThemeData(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                child: Column(
                  children: [
                    Text(
                      "You got referred!\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primary),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Your referral bonus is just one step away."
                      " Invest in a treasury bill to activate your $referralBonus% APY referral boost.",
                      style: AppTheme.subBodyDark,
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
          ),
        )));
  }

  Widget headingCard(BuildContext context) {
    return Column(children: [
      Image.asset(
        'lib/assets/referral.png',
        height: MediaQuery.of(context).size.width * 0.6,
        width: MediaQuery.of(context).size.width * 0.6,
        fit: BoxFit.cover,
      ),
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, bottom: 12),
        child: Text(
          "Refer a friend and earn\n$referralBonus% APY Referral Bonus",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 24,
              color: AppTheme.primary),
        ),
      ),
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 0, bottom: 12),
        child: Text(
          // "Each time a friend signs up and invests in a treasury bill,"
          // " you'll both receive a $referralBonus% APY referral bonus for 3 months.",
          // "For each friend you refer, you earn an additional $referralBonus% APY"
          // " referral bonus for 3 months on your treasury holdings. Up to 4 referrals.",
          "Each time a friend signs up and invests in a treasury bill,"
          " you'll both receive a $referralBonus% APY referral"
          " bonus for 3 months. You can refer up to 4 friends and"
          " earn the bonus for the next 12 months.",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 14, color: AppTheme.secondary),
        ),
      )
    ]);
  }

  Widget bonusSummaryCard(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 20, bottom: 20),
        child: IntrinsicHeight(
            child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              flex: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Referrals",
                    style: AppTheme.subBodyNormal,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    referralInfo!.numberOfReferrals!,
                    style: AppTheme.bodyNormal,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(
              flex: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                      onTap: () {
                        showInfoModal(
                          context: context,
                          title: 'Estimated Bonus',
                          subtext:
                              'Your referral bonus is accumulated daily based on the average value of funds invested in Treasury Bills'
                              ' and paid out at the end of each month.\n\n'
                              'The figure provided represents the total bonus which includes bonuses already paid out as'
                              ' well as estimated earnings for the current month, giving you a complete view of your earnings from referrals.',
                        );
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Bonus',
                              style: AppTheme.subBodyNormal,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(width: 3),
                            const Icon(
                              Icons.info_outline,
                              color: AppTheme.primary,
                              size: 14,
                            ),
                          ])),
                  const SizedBox(height: 5),
                  Text(
                    formatAmount(referralInfo!.totalBonusAmount!),
                    style: AppTheme.bodyNormal,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
            const VerticalDivider(),
            Expanded(
              flex: 30,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Days left",
                    style: AppTheme.subBodyNormal,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    referralInfo!.daysLeft!,
                    textAlign: TextAlign.center,
                    style: AppTheme.bodyNormal,
                  )
                ],
              ),
            ),
          ],
        )));
  }

  Widget bonusInfoCard(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.blue.withOpacity(0.1),
      margin: const EdgeInsets.fromLTRB(0, 15, 0, 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 30, 15, 30),
        child: Column(children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  flex: 30,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$interestRate% APY",
                          style: AppTheme.bodyNormal,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Treasury Bills",
                          style: AppTheme.subBodyNormal,
                          textAlign: TextAlign.center,
                        ),
                      ])),
              const SizedBox(width: 4),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "+",
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.center,
                    ),
                  ]),
              const SizedBox(width: 4),
              Expanded(
                  flex: 30,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$referralBonus% APY",
                          style: AppTheme.bodyNormal,
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          "Referral Bonus",
                          style: AppTheme.subBodyNormal,
                          textAlign: TextAlign.center,
                        ),
                      ])),
              const SizedBox(width: 4),
              Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "=",
                      style: AppTheme.bodyNormal,
                      textAlign: TextAlign.center,
                    ),
                  ]),
              const SizedBox(width: 4),
              Expanded(
                  flex: 30,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "$totalInterestRate% APY",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.primary),
                        ),
                        Text(
                          "For 3 Months",
                          style: AppTheme.subBodyNormal,
                          textAlign: TextAlign.center,
                        ),
                      ])),
            ],
          ),
          // const SizedBox(
          //   height: 10,
          // ),
          // Text(
          //   "APY on Treasury may fluctuate over time before"
          //   " or after the account is opened.",
          //   textAlign: TextAlign.center,
          //   style: AppTheme.disclosureText,
          // ),
        ]),
      ),
    );
  }

  Widget howItWorksCard(BuildContext context) {
    return Column(children: [
      Container(
        alignment: Alignment.centerLeft,
        margin: const EdgeInsets.only(top: 12, bottom: 25),
        child: Text(
          "Here's how it works",
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppTheme.secondary,
              fontWeight: FontWeight.bold),
        ),
      ),
      Padding(
          padding: const EdgeInsets.only(left: 0, right: 0),
          child: Column(children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "01",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Refer a friend\n",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.secondary),
                        ),
                        TextSpan(
                          text:
                              "Share your unique referral link to invite someone who isn't"
                              " already an existing client.",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.secondary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ))
                ]),
            const SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "02",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Receive a $referralBonus% APY boost\n",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.secondary),
                        ),
                        TextSpan(
                          text:
                              "Once your friend signs up and invests in a treasury bill,"
                              " you'll both receive a $referralBonus% APY boost on"
                              " investments up to \$20,000 in Treasury Bills, valid for 3 months."
                              "\n\nThe bonus accumulates daily and is paid monthly into your Finvest Cash account.",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.secondary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ))
                ]),
            const SizedBox(height: 15),
            Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "03",
                    style: GoogleFonts.poppins(
                        fontSize: 14, color: AppTheme.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                      child: RichText(
                    textAlign: TextAlign.start,
                    text: TextSpan(
                      children: <InlineSpan>[
                        TextSpan(
                          text: "Stack up to 12 months\n",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: AppTheme.secondary),
                        ),
                        TextSpan(
                          text:
                              "The referral bonus is applied for 3 months for each referral."
                              " You can refer up to 4 friends to earn the bonus for 12 months."
                              "\n\nIf you were referred to Finvest and qualified for the referral boost,"
                              " you can refer 4 additional friends, thereby extending the bonus to 15 months.",
                          style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppTheme.secondary.withOpacity(0.7)),
                        ),
                      ],
                    ),
                  ))
                ]),
            const SizedBox(height: 10),
            // Row(
            //     mainAxisAlignment:
            //         MainAxisAlignment.start,
            //     crossAxisAlignment:
            //         CrossAxisAlignment.start,
            //     children: [
            //       Text(
            //         "04",
            //         style: GoogleFonts.poppins(
            //             fontSize: 14,
            //             color: AppTheme.primary),
            //       ),
            //       const SizedBox(width: 10),
            //       Expanded(
            //           child: RichText(
            //         textAlign: TextAlign.start,
            //         text: TextSpan(
            //           children: <InlineSpan>[
            //             TextSpan(
            //               text:
            //                   "Balance Limit of \$20K\n",
            //               style: GoogleFonts.poppins(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 14,
            //                   color: AppTheme.secondary),
            //             ),
            //             TextSpan(
            //               text:
            //                   "The referral reward program applies to up to a maximum amount of \$20,000"
            //                   " invested in Treasury Bills."
            //                   " If you hold over \$20,000, then you'll earn the original interest rate locked-in"
            //                   " on the remaining.",
            //               style: GoogleFonts.poppins(
            //                   fontSize: 12,
            //                   color: AppTheme.secondary
            //                       .withOpacity(0.7)),
            //             ),
            //           ],
            //         ),
            //       ))
            //     ]),
            // const SizedBox(height: 10),
          ])),
      Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 12, bottom: 0),
        child: InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            const url = "https://www.getfinvest.com/referral";
            if (await canLaunchUrl(Uri.parse(url))) {
              await launchUrl(Uri.parse(url));
            }
          },
          child: RichText(
            textAlign: TextAlign.start,
            text: TextSpan(
              children: [
                WidgetSpan(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: AppTheme.secondary.withOpacity(0.5),
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Text(
                      "See FAQs",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppTheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ]);
  }

  double getButtonHeight(BuildContext context) {
    double bottomPadding = LayoutConfig().bottomPadding + 20;
    double buttonHeightFactor = MediaQuery.of(context).size.height * 0.06;

    return bottomPadding + buttonHeightFactor + 50;
  }

  Widget shareButton(BuildContext context) {
    double bottomPadding = LayoutConfig().bottomPadding + 20;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Card(
          color: AppTheme.backgroundColor,
          elevation: 0,
          child: Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding),
              child: CustomButton(
                  widthVal: 1,
                  buttonText: 'Share Referral Link',
                  onPressFunction: referralLink == null
                      ? null
                      : () {
                          Share.share(
                              "Join me at Finvest to invest into US Treasury bills"
                              " and earn up to $interestRate% APY.\n\nWhen you sign up"
                              " and buy your first treasury, we both receive a $referralBonus%"
                              " APY referral boost for the next 3 months.\n\nSign up with my"
                              " link: $referralLink");
                        }))),
    );
  }
}
