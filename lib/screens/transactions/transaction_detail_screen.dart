import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class TransactionDetailScreen extends StatefulWidget {
  final Transaction transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  @override
  TransactionDetailScreenState createState() => TransactionDetailScreenState();
}

class TransactionDetailScreenState extends State<TransactionDetailScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String actionLowercase = widget.transaction.action?.toLowerCase() ?? "";
    bool shouldDisplayBondStatusCard =
        (actionLowercase.contains('buy') || actionLowercase.contains('sell')) &&
            widget.transaction.getMappedStatus().toLowerCase() == 'pending';
    bool shouldDisplayFeeInfoCard = actionLowercase.contains('monthly fee');

    return Scaffold(
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
      body: SingleChildScrollView(
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
                  headingCard(context),
                  if (shouldDisplayBondStatusCard) bondStatusCard(context),
                  bodyCard(context),
                  if (widget.transaction.failureReason != null)
                    failureReasonCard(
                        context, widget.transaction.failureReason!),
                  if (shouldDisplayFeeInfoCard) feeInfoCard(context)
                ],
              ))),
    );
  }

  Widget headingCard(BuildContext context) {
    String actionLowercase = widget.transaction.action?.toLowerCase() ?? "";
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Container(
            alignment: Alignment.topLeft,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                widget.transaction.totalExecutionPrice == null &&
                        (actionLowercase.contains('buy') ||
                            actionLowercase.contains('sell'))
                    ? const SizedBox.shrink()
                    : Text(
                        widget.transaction.totalExecutionPrice == null
                            ? formatAmount(widget.transaction.amount ?? "0.0",
                                direction: widget.transaction.direction)
                            : formatAmount(
                                widget.transaction.totalExecutionPrice ?? "0.0",
                                direction: widget.transaction.direction),
                        style: AppTheme.numberSmallText,
                      ),
                Text(
                  widget.transaction.displayName ?? "",
                  style: AppTheme.bodyNormal,
                ),
              ],
            )));
  }

  Widget bondStatusCard(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
            child: Card(
                elevation: 0,
                color: AppTheme.backgroundColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: BorderSide(
                      width: 1, color: Colors.grey[600]!.withOpacity(0.2)),
                ),
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Theme(
                        data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: Text(
                          'This order will be processed during regular bond market trading hours (9:30 AM - 4:00 PM EST, Monday - Friday).',
                          style: AppTheme.subBodyDark,
                          textAlign: TextAlign.center,
                        ))))));
  }

  Widget failureReasonCard(BuildContext context, String failureReason) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Center(
            child: Card(
                elevation: 0,
                color: AppTheme.backgroundColor,
                child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Theme(
                        data: ThemeData(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                        ),
                        child: Text(
                          failureReason,
                          style: AppTheme.warningMessage,
                          textAlign: TextAlign.center,
                        ))))));
  }

  Widget feeInfoCard(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 20),
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
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: AppTheme.subBodyDark,
                  children: [
                    const TextSpan(
                      text:
                          'Finvest charges a monthly fee equal to 0.03% of your treasury value. ',
                    ),
                    WidgetSpan(
                      child: InkWell(
                        onTap: () async {
                          const url =
                              "https://www.getfinvest.com/support/fee-schedule";
                          if (await canLaunchUrl(Uri.parse(url))) {
                            await launchUrl(Uri.parse(url));
                          }
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Learn More',
                              style: AppTheme.subBodyDark.copyWith(
                                color: AppTheme.primary,
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(
                              Icons.arrow_forward,
                              size: 16,
                              color: AppTheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )));
  }

  Widget bodyCard(BuildContext context) {
    String actionLowercase = widget.transaction.action?.toLowerCase() ?? "";

    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.transaction.status != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Status",
                            style: AppTheme.subBodyDark,
                          ),
                          Text(
                            widget.transaction.getMappedStatus(),
                            style: AppTheme.bodyNormal,
                          )
                        ]))
                : const SizedBox.shrink(),
            widget.transaction.createdTime != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Initiated",
                            style: AppTheme.subBodyDark,
                          ),
                          Text(
                            formatDateWithTime(widget.transaction.createdTime),
                            style: AppTheme.bodyNormal,
                          )
                        ]))
                : const SizedBox.shrink(),
            widget.transaction.lastUpdatedTime != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Last updated",
                            style: AppTheme.subBodyDark,
                          ),
                          Text(
                            formatDateWithTime(
                                widget.transaction.lastUpdatedTime),
                            style: AppTheme.bodyNormal,
                          )
                        ]))
                : const SizedBox.shrink(),
            widget.transaction.from != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "From",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.from!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.to != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "To",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.to!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            actionLowercase.contains('maturity')
                ? maturityDetails(context)
                : const SizedBox.shrink(),
            actionLowercase.contains('buy')
                ? buyDetails(context)
                : const SizedBox.shrink(),
            actionLowercase.contains('sell')
                ? sellDetails(context)
                : const SizedBox.shrink(),
          ],
        ));
  }

  Widget buyDetails(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.transaction.holdingDetails != null &&
                    widget.transaction.holdingDetails!.assetSymbol != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asset Identifier",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.holdingDetails!.assetSymbol!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.holdingDetails != null &&
                    widget.transaction.getMappedStatus() != 'Pending' &&
                    widget.transaction.holdingDetails!.maturityDate != null &&
                    widget.transaction.holdingDetails!.yieldToMaturity != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Maturity Date",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.holdingDetails!.maturityDate !=
                                  null
                              ? formatDate(widget
                                  .transaction.holdingDetails!.maturityDate!)
                              : "",
                          style: AppTheme.bodyNormal,
                        ),
                        // const SizedBox(
                        //   height: 15,
                        // ),
                        // Text(
                        //   "Yield To Maturity",
                        //   style: AppTheme.subBodyDark,
                        // ),
                        // Text(
                        //   widget.transaction.holdingDetails!.yieldToMaturity !=
                        //           null
                        //       ? "${widget.transaction.holdingDetails!.yieldToMaturity!}%"
                        //       : "--",
                        //   style: AppTheme.bodyNormal,
                        // ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.orderType != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Type",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.orderType!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.amount != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Quantity",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          formatAmount(widget.transaction.amount!),
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.totalExecutionPrice != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Filled Amount",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          formatAmount(widget.transaction.totalExecutionPrice!),
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.yieldToMaturity != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.transaction.getMappedStatus() == 'Pending'
                              ? "Estimated Yield To Maturity"
                              : "Yield To Maturity",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          "${widget.transaction.yieldToMaturity!}%",
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
          ],
        ));
  }

  Widget sellDetails(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.transaction.holdingDetails != null &&
                    widget.transaction.holdingDetails!.assetSymbol != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asset Identifier",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.holdingDetails!.assetSymbol!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.orderType != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Type",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.orderType!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.amount != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Order Quantity",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.amount!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.totalExecutionPrice != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Total Filled Amount",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          formatAmount(widget.transaction.totalExecutionPrice!),
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
          ],
        ));
  }

  Widget maturityDetails(BuildContext context) {
    return Container(
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            widget.transaction.assetSymbol != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asset Identifier",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.assetSymbol!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.assetDuration != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Asset Name",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.assetDuration!,
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
            widget.transaction.maturityDate != null
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Maturity Date",
                          style: AppTheme.subBodyDark,
                        ),
                        Text(
                          widget.transaction.maturityDate != null
                              ? formatDate(widget.transaction.maturityDate!)
                              : "",
                          style: AppTheme.bodyNormal,
                        ),
                      ],
                    ))
                : const SizedBox.shrink(),
          ],
        ));
  }
}
