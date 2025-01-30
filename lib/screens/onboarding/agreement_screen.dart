import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/account_failure_verification_popover.dart';
import 'package:bondgrid/components/account_verification_denied_popover.dart';
import 'package:bondgrid/components/custom_button.dart';
import 'package:bondgrid/enums/verification_status.dart';
import 'package:bondgrid/models/user_agreement_list.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/home/account_activation_completion_screen.dart';
import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class AgreementScreen extends StatefulWidget {
  const AgreementScreen({Key? key}) : super(key: key);

  @override
  AgreementScreenState createState() => AgreementScreenState();
}

class AgreementScreenState extends State<AgreementScreen> {
  bool userAgreement = false;
  UserAgreementList? _userAgreementList;

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

    context.read<HomeBloc>().add(GetUserAgreementsEvent());
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
              //Navigator.pop(context);
            }

            if (state is SubmitUserVerificationSuccessState) {
              // Navigator.popUntil(context, (route) => route.isFirst);
              if (state.verification.status == VerificationStatus.DENIED) {
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return const AccountVerificationDeniedPopover();
                    });
              } else if (state.verification.status ==
                  VerificationStatus.FAILED) {
                showDialog(
                    barrierDismissible: false,
                    barrierColor: Colors.black.withOpacity(0.9),
                    context: context,
                    builder: (context) {
                      return const AccountFailureVerificationPopover();
                    });
              } else {
                //Navigator.popUntil(context, (route) => route.isFirst);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BlocProvider(
                              create: (context) => HomeBloc(HomeRepo()),
                              child: const AccountActivationCompletionScreen(),
                            )));
                // showDialog(
                //     barrierDismissible: false,
                //     barrierColor: Colors.black.withOpacity(0.9),
                //     context: context,
                //     builder: (context) {
                //       return const AccountReviewConfirmationPopover();
                //     });
              }
            }

            if (state is GetUserAgreementsSuccessState) {
              _userAgreementList = state.userAgreements;
            }
          },
          child: agreementList(context, state));
    });
  }

  Widget agreementList(BuildContext context, HomeState state) {
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
      body: AbsorbPointer(
          absorbing: state.status == HomeStateStatus.loading,
          child: Stack(children: [
            SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.fromLTRB(
                        MediaQuery.of(context).size.width * 0.02 + 10,
                        0,
                        MediaQuery.of(context).size.width * 0.02 + 10,
                        0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(top: 20, bottom: 15),
                            child: Text(
                              "Agreements",
                              textAlign: TextAlign.center,
                              style: AppTheme.headingText,
                            ),
                          ),
                          Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.only(bottom: 15),
                            child: Text(
                              'Your funds,'
                              ' investments, and treasuries are held in custody and cleared'
                              ' through Pershing Advisor Solutions LLC, a subsidiary of the Bank of New York'
                              ' Mellon Corp. We have partnered with Atomic Invest, LLC to bring you the opportunity'
                              ' open an account. Pershing and Atomic require you to sign some of their standard policies.'
                              ' Please open and review all documents.',
                              textAlign: TextAlign.center,
                              style: AppTheme.disclosureText,
                            ),
                          ),
                          _userAgreementList == null ||
                                  _userAgreementList!.agreements.isEmpty
                              ? const SizedBox.shrink()
                              : Card(
                                  elevation: AppTheme.cardElevation,
                                  color: AppTheme.nearlyWhite,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                        children: _userAgreementList?.agreements
                                                .map((agreement) {
                                              return Container(
                                                  margin:
                                                      const EdgeInsets.all(2),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    highlightColor:
                                                        Colors.transparent,
                                                    onTap: agreement.url != null
                                                        ? () async {
                                                            await launchUrl(
                                                                Uri.parse(
                                                                    "https://${agreement.url}"),
                                                                mode: LaunchMode
                                                                    .externalApplication);
                                                          }
                                                        : null,
                                                    child: ListTile(
                                                      leading: Icon(
                                                          Icons
                                                              .assignment_rounded,
                                                          color: AppTheme
                                                              .secondary
                                                              .withOpacity(
                                                                  0.7)),
                                                      title: Text(
                                                        cleanUpString(agreement
                                                            .type
                                                            .toString()),
                                                        style:
                                                            GoogleFonts.poppins(
                                                                color: AppTheme
                                                                    .secondary
                                                                    .withOpacity(
                                                                        0.7),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                fontSize: 16),
                                                      ),
                                                      trailing: Icon(
                                                          Icons
                                                              .keyboard_arrow_right_rounded,
                                                          color: AppTheme
                                                              .actionButton,
                                                          size: 14),
                                                    ),
                                                  ));
                                            }).toList() ??
                                            [const SizedBox.shrink()]),
                                  )),
                          const SizedBox(height: 10),
                          termsAndConditionsText(),
                          const SizedBox(height: 250),
                        ]))),
            submitButton(context, state)
          ])),
    );
  }

  Widget submitButton(BuildContext context, HomeState state) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    // If the keyboard is visible, use the keyboard's height as the bottom padding
    double bottomPadding =
        isKeyboardVisible ? 20 : LayoutConfig().bottomPadding + 20;

    return Align(
        alignment: Alignment.bottomCenter,
        child: Card(
            color: AppTheme.backgroundColor,
            elevation: 5,
            child: Padding(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: Text(
                      'By checking this box, you acknowledge that you have read and'
                      ' agree to the terms and agreements listed above.',
                      style: GoogleFonts.poppins(
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15),
                    ),
                    value: userAgreement,
                    onChanged: (bool? value) {
                      setState(() {
                        userAgreement = value!;
                      });
                    },
                    activeColor: AppTheme.primary,
                  ),
                  const SizedBox(height: 10),
                  CustomButton(
                    widthVal: 1,
                    buttonText: 'Submit',
                    isLoading: state is SubmitUserVerificationLoadingState,
                    onPressFunction: state
                                is! SubmitUserVerificationLoadingState &&
                            _userAgreementList != null &&
                            userAgreement
                        ? () {
                            homeBloc.add(SubmitUserVerificationEvent(
                                userAgreements: _userAgreementList!,
                                viewedTimestamp:
                                    DateTime.now().toUtc().toIso8601String(),
                                signedTimestamp:
                                    DateTime.now().toUtc().toIso8601String(),
                                endUserIp: "127.0.0.1"));
                          }
                        : null,
                  )
                ]))));
  }

  Widget termsAndConditionsText() {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 15),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: AppTheme.disclosureText,
          children: <TextSpan>[
            const TextSpan(
              text: 'You are electronically signing the ',
            ),
            _linkTextSpan('Atomic Invest, LLC Client Account Agreements',
                'http://legal.atomicvest.com/usa.ima.3FhWfWocRJbFt9qCd5vLON-MMdpqYo1z9OLuUV6uTCg=.pdf'),
            const TextSpan(
              text:
                  ' which include your agreement to the following items as well: \n\n- I confirm that my '
                  'electronic signature may be used in connection with this agreement and the records '
                  'to which such agreement reflects. \n- I confirm that my electronic signature may be '
                  'used for other purposes, but only when I expressly apply a new signature or when a '
                  'new signature is obtained from my authorized investment advisor, if permission has '
                  'been granted. \n- I agree to establish a brokerage account with ',
            ),
            _linkTextSpan('Pershing Advisor Solutions LLC',
                'https://legal.atomicvest.com/usa.ria-account-form.pdf'),
            const TextSpan(
              text: ' \n- Receive account-related communications (including '
                  'quarterly statements and tax documents, among others) electronically; and \n- Resolve '
                  'disputes with Atomic Invest and Pershing through arbitration; and \n- By signing, you '
                  'are deemed by Atomic Invest, to have received the Atomic Invest, LLC ',
            ),
            _linkTextSpan('Form ADV',
                'https://legal.atomicvest.com/usa.adv.15138320-a16d-4037-846f-f63ef451fcf5.pdf'),
            const TextSpan(
              text: ' and ',
            ),
            _linkTextSpan('Form CRS',
                'https://legal.atomicvest.com/usa.crs.9b1c545a-56e5-4067-bfca-4742891199dc.pdf'),
            const TextSpan(
              text:
                  '. \n\nYou also affirm that you are of full legal age in the state or jurisdiction '
                  'in which you reside and have the capacity to enter into this agreement. Further, you '
                  'acknowledge that you have read, understood, and agree to the terms outlined in Atomic Invest\'s ',
            ),
            _linkTextSpan('Privacy Policy',
                'https://legal.atomicvest.com/usa.privacy.de3d0277-78f7-4741-9e9f-755f6b4f03ba.pdf'),
            const TextSpan(
              text: ', ',
            ),
            _linkTextSpan('Form CRS',
                'https://legal.atomicvest.com/usa.crs.9b1c545a-56e5-4067-bfca-4742891199dc.pdf'),
            const TextSpan(
              text: ', and ',
            ),
            _linkTextSpan('Form ADV Part 2A',
                'https://legal.atomicvest.com/usa.adv.15138320-a16d-4037-846f-f63ef451fcf5.pdf'),
            const TextSpan(
              text: ', as well as Pershing’s ',
            ),
            _linkTextSpan('Terms and Conditions',
                'https://legal.atomicvest.com/us.custodian-terms.88042386-f4a0-472d-bb2b-7c26e6731289.pdf'),
            const TextSpan(
              text:
                  '. \n\nUnder penalties of perjury, you also certify that all the statements below are true:',
            ),
            const TextSpan(
              text:
                  '\n\n- You have provided your correct Social Security Number or Taxpayer Identification Number;',
            ),
            const TextSpan(
              text:
                  '\n- You are not subject to backup withholding because: (a) You are exempt from backup withholding, or (b) You have not been notified by the Internal Revenue Service (IRS) that you are subject to backup withholding as a result of a failure to report all interest or dividends, or (c) the IRS has notified you that you are no longer subject to backup withholding.',
            ),
            const TextSpan(
              text: '\n- You are exempt from FATCA reporting for this account.',
            ),
          ],
        ),
      ),
    );
  }

  TextSpan _linkTextSpan(String text, String url) {
    return TextSpan(
      text: text,
      style: const TextStyle(
          decoration: TextDecoration.underline, color: AppTheme.primary),
      recognizer: TapGestureRecognizer()
        ..onTap = () {
          _launchURL(url);
        },
    );
  }

  void _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }
}
