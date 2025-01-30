import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/filter_button_util.dart';
import 'package:bondgrid/models/transaction.dart';
import 'package:bondgrid/screens/transactions/transaction_detail_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TransactionScreen extends StatefulWidget {
  const TransactionScreen(
      {super.key,
      required this.transactionList,
      this.headingText = "Transaction History",
      this.onlyTrades = false,
      this.showFilters = true});

  final List<Transaction> transactionList;
  final String headingText;
  final bool onlyTrades;
  final bool showFilters;

  @override
  TransactionScreenState createState() => TransactionScreenState();
}

enum FilterType { timeFrame, status, transactionType }

class TransactionScreenState extends State<TransactionScreen> {
  String _selectedStatus = "All";
  String _selectedTimeFrame = "All Time";
  String _selectedTransactionType = "All";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: AppTheme.backgroundColor,
              automaticallyImplyLeading: false,
              centerTitle: true,
              elevation: 0,
              // title: Text(
              //   "Transaction History",
              //   style: GoogleFonts.poppins(
              //       fontWeight: FontWeight.w500,
              //       fontSize: 18,
              //       color: AppTheme.secondary),
              // ),
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
                    padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headingCard(context),
                        const SizedBox(
                          height: 10,
                        ),
                        widget.showFilters
                            ? showFilters()
                            : const SizedBox.shrink(),
                        anyFilterSelected()
                            ? const Divider()
                            : const SizedBox.shrink(),
                        anyFilterSelected()
                            ? showSelectedFilters()
                            : const SizedBox.shrink(),
                        const SizedBox(
                          height: 20,
                        ),
                        listTransaction(context)
                      ],
                    ))),
          ));
    });
  }

  Widget headingCard(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        widget.headingText,
        style: AppTheme.titleText,
      ),
    );
  }

  void _showFilterOptionsModal(BuildContext context, FilterType filterType) {
    showModalBottomSheet(
        isDismissible: true,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20)),
        ),
        context: context,
        builder: (BuildContext bc) {
          return NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowIndicator();
                return true;
              },
              child: getFilterModalContent(filterType));
        });
  }

  Widget getFilterModalContent(FilterType filterType) {
    switch (filterType) {
      case FilterType.timeFrame:
        return timeFrameFilterList();
      case FilterType.status:
        return statusFilterList();
      case FilterType.transactionType:
        return transactionTypeFilterList();
      default:
        return Container();
    }
  }

  Widget showFilters() {
    Set<String> uniqueStatuses = widget.transactionList
        .map((transaction) => transaction.getMappedStatus())
        .toSet();

    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilterButton<FilterType>(
              filterType: FilterType.timeFrame,
              label: "Date",
              onFilterPressed: (type) {
                _showFilterOptionsModal(context, type);
              },
            ),
            uniqueStatuses.isEmpty || uniqueStatuses.length == 1
                ? const SizedBox.shrink()
                : Row(children: [
                    const SizedBox(width: 5),
                    FilterButton<FilterType>(
                      filterType: FilterType.status,
                      label: "Status",
                      onFilterPressed: (type) {
                        _showFilterOptionsModal(context, type);
                      },
                    ),
                  ]),
            const SizedBox(width: 5),
            FilterButton<FilterType>(
              filterType: FilterType.transactionType,
              label: "Type",
              onFilterPressed: (type) {
                _showFilterOptionsModal(context, type);
              },
            ),
          ],
        ));
  }

  bool anyFilterSelected() {
    return _selectedStatus != 'All' ||
        _selectedTimeFrame != 'All Time' ||
        _selectedTransactionType != 'All';
  }

  Widget showSelectedFilters() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                height: MediaQuery.of(context).size.height * 0.04,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: AppTheme.backgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20), // <-- Radius
                      ),
                      side:
                          const BorderSide(width: 1, color: AppTheme.primary)),
                  onPressed: () {
                    setState(() {
                      _selectedStatus = "All";
                      _selectedTimeFrame = "All Time";
                      _selectedTransactionType = "All";
                    });
                  },
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Clear All",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: AppTheme.primary),
                        ),
                      ]),
                )),
            _selectedStatus == 'All'
                ? const SizedBox.shrink()
                : const SizedBox(
                    width: 5,
                  ),
            _selectedStatus == 'All'
                ? const SizedBox.shrink()
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // <-- Radius
                          ),
                          side: const BorderSide(
                              width: 1, color: AppTheme.primary)),
                      onPressed: () {
                        setState(() {
                          _selectedStatus = "All";
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedStatus,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppTheme.primary),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Icon(Icons.cancel_outlined,
                                color: AppTheme.primary, size: 20)
                          ]),
                    )),
            _selectedTimeFrame == 'All Time'
                ? const SizedBox.shrink()
                : const SizedBox(
                    width: 5,
                  ),
            _selectedTimeFrame == 'All Time'
                ? const SizedBox.shrink()
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // <-- Radius
                          ),
                          side: const BorderSide(
                              width: 1, color: AppTheme.primary)),
                      onPressed: () {
                        setState(() {
                          _selectedTimeFrame = "All Time";
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedTimeFrame,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppTheme.primary),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Icon(Icons.cancel_outlined,
                                color: AppTheme.primary, size: 20)
                          ]),
                    )),
            _selectedTransactionType == 'All'
                ? const SizedBox.shrink()
                : const SizedBox(
                    width: 5,
                  ),
            _selectedTransactionType == 'All'
                ? const SizedBox.shrink()
                : SizedBox(
                    height: MediaQuery.of(context).size.height * 0.04,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: AppTheme.backgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(20), // <-- Radius
                          ),
                          side: const BorderSide(
                              width: 1, color: AppTheme.primary)),
                      onPressed: () {
                        setState(() {
                          _selectedTransactionType = "All";
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedTransactionType,
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                  color: AppTheme.primary),
                            ),
                            const SizedBox(
                              width: 3,
                            ),
                            const Icon(Icons.cancel_outlined,
                                color: AppTheme.primary, size: 20)
                          ]),
                    )),
          ],
        ));
  }

  Widget statusFilterList() {
    Set<String> uniqueStatuses = widget.transactionList
        .map((transaction) => transaction.getMappedStatus())
        .where((status) => status.isNotEmpty)
        .toSet();

    return ListView(
      padding: EdgeInsets.zero,
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          title: Text(widget.onlyTrades ? 'Trade Status' : 'Transaction Status',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            setState(() {
              _selectedStatus = 'All';
            });
            Navigator.pop(context);
          },
          child: ListTile(
              contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              title: Text(
                'All',
                style: _selectedStatus == "All"
                    ? AppTheme.bulletBold
                    : AppTheme.bulletNormal,
              ),
              trailing: _selectedStatus == "All"
                  ? const Icon(Icons.radio_button_checked_rounded,
                      color: AppTheme.primary)
                  : const Icon(Icons.radio_button_off_rounded)),
        ),
        ...uniqueStatuses.map((status) {
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedStatus = status;
                });
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: Text(
                  status,
                  style: _selectedStatus == status
                      ? AppTheme.bulletBold
                      : AppTheme.bulletNormal,
                ),
                trailing: _selectedStatus == status
                    ? const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.primary)
                    : const Icon(Icons.radio_button_off_rounded),
              ));
        }).toList(),
      ],
    );
  }

  Widget timeFrameFilterList() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          title: Text('Date Range',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        ...["All Time", "Current Month", "Last Month", "This Year"]
            .map((timeFrame) {
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedTimeFrame = timeFrame;
                });
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: Text(
                  timeFrame,
                  style: _selectedTimeFrame == timeFrame
                      ? AppTheme.bulletBold
                      : AppTheme.bulletNormal,
                ),
                trailing: _selectedTimeFrame == timeFrame
                    ? const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.primary)
                    : const Icon(Icons.radio_button_off_rounded),
              ));
        }).toList(),
      ],
    );
  }

  Widget transactionTypeFilterList() {
    List<String> filterList = widget.onlyTrades
        ? ["All", "Buy", "Sell"]
        : ["All", "Buy", "Sell", "Deposit", "Withdrawal"];

    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text('Transaction Type',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        ...filterList.map((transactionType) {
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedTransactionType = transactionType;
                });
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: Text(
                  transactionType,
                  style: _selectedTransactionType == transactionType
                      ? AppTheme.bulletBold
                      : AppTheme.bulletNormal,
                ),
                trailing: _selectedTransactionType == transactionType
                    ? const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.primary)
                    : const Icon(Icons.radio_button_off_rounded),
              ));
        }).toList(),
      ],
    );
  }

  Widget listTransaction(BuildContext context) {
    List<Transaction> filteredTransactions = widget.transactionList;

    // Apply filters
    if (_selectedStatus != 'All') {
      filteredTransactions = filteredTransactions
          .where((t) => t.getMappedStatus() == _selectedStatus)
          .toList();
    }
    if (_selectedTransactionType != "All") {
      filteredTransactions = filteredTransactions
          .where((t) => t.action!
              .toLowerCase()
              .contains(_selectedTransactionType.toLowerCase()))
          .toList();
    }
    if (_selectedTimeFrame != 'All Time') {
      DateTime now = DateTime.now().toLocal();
      DateTime firstDayOfCurrentMonth =
          DateTime(now.year, now.month, 1).toLocal();
      DateTime firstDayOfLastMonth =
          DateTime(now.year, now.month - 1, 1).toLocal();
      DateTime firstDayOfNextMonth =
          DateTime(now.year, now.month + 1, 1).toLocal();
      DateTime firstDayOfCurrentYear = DateTime(now.year, 1, 1).toLocal();

      if (_selectedTimeFrame == 'Current Month') {
        filteredTransactions = filteredTransactions.where((t) {
          DateTime transactionDate = DateTime.parse(t.createdTime!).toLocal();
          return transactionDate.isAfter(firstDayOfCurrentMonth) &&
              transactionDate.isBefore(firstDayOfNextMonth);
        }).toList();
      } else if (_selectedTimeFrame == 'Last Month') {
        filteredTransactions = filteredTransactions.where((t) {
          DateTime transactionDate = DateTime.parse(t.createdTime!).toLocal();
          return transactionDate.isAfter(firstDayOfLastMonth) &&
              transactionDate.isBefore(firstDayOfCurrentMonth);
        }).toList();
      } else if (_selectedTimeFrame == 'This Year') {
        filteredTransactions = filteredTransactions.where((t) {
          DateTime transactionDate = DateTime.parse(t.createdTime!).toLocal();
          return transactionDate.isAfter(firstDayOfCurrentYear);
        }).toList();
      }
    }

    return filteredTransactions.isEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Nothing to show here",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                      color: AppTheme.secondary.withOpacity(0.5),
                      fontWeight: FontWeight.w400,
                      fontSize: 12),
                )))
        : Column(
            children: filteredTransactions.map((transaction) {
              String actionLowercase = transaction.action?.toLowerCase() ?? "";
              Map<String, String> image = transaction.getMappedImage();
              return Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          Navigator.push(
                              context,
                              (Theme.of(context).platform == TargetPlatform.iOS)
                                  ? CupertinoPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            transaction: transaction,
                                          ))
                                  : MaterialPageRoute(
                                      builder: (context) =>
                                          TransactionDetailScreen(
                                            transaction: transaction,
                                          )));
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(0),
                          title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  flex: 12,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: SizedBox(
                                      child: image["type"] == "svg"
                                          ? Padding(
                                              padding: const EdgeInsets.all(10),
                                              child: SvgPicture.asset(
                                                image["path"] ??
                                                    'lib/assets/interest.svg',
                                                height: 25.0,
                                                width: 25.0,
                                              ))
                                          : Padding(
                                              padding: const EdgeInsets.all(5),
                                              child: Image.asset(
                                                image["path"] ??
                                                    'lib/assets/interest.png',
                                                height: 35.0,
                                                width: 35.0,
                                              )),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                    flex: 60,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.onlyTrades
                                                ? transaction.action ?? ""
                                                : transaction.displayName ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.bodyNormal,
                                          ),
                                          RichText(
                                            overflow: TextOverflow.ellipsis,
                                            text: TextSpan(
                                              style:
                                                  DefaultTextStyle.of(context)
                                                      .style,
                                              children: <TextSpan>[
                                                TextSpan(
                                                  text: formatDate(
                                                      transaction.createdTime!),
                                                  style: AppTheme.subBodyNormal,
                                                ),
                                                transaction.getMappedStatus() !=
                                                        ''
                                                    ? TextSpan(
                                                        text: " • ",
                                                        style: AppTheme
                                                            .subBodyNormal,
                                                      )
                                                    : const TextSpan(),
                                                transaction.getMappedStatus() !=
                                                        ''
                                                    ? TextSpan(
                                                        text: transaction
                                                            .getMappedStatus(),
                                                        style: transaction.getMappedStatus() ==
                                                                'Pending'
                                                            ? AppTheme
                                                                .subBodyNormalBold
                                                            : AppTheme
                                                                .subBodyNormal,
                                                      )
                                                    : const TextSpan(),
                                              ],
                                            ),
                                          ),
                                        ])),
                                Expanded(
                                    flex: 28,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          transaction.totalExecutionPrice ==
                                                      null &&
                                                  (actionLowercase
                                                          .contains('buy') ||
                                                      actionLowercase
                                                          .contains('sell'))
                                              ? const SizedBox.shrink()
                                              : Text(
                                                  transaction.totalExecutionPrice ==
                                                          null
                                                      ? formatAmount(
                                                          transaction.amount ??
                                                              "0.0",
                                                          direction: transaction
                                                              .direction)
                                                      : formatAmount(
                                                          transaction
                                                                  .totalExecutionPrice ??
                                                              "0.0",
                                                          direction: transaction
                                                              .direction),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: AppTheme.bodyNormal,
                                                )
                                        ])),
                                // Expanded(
                                //     flex: 1,
                                //     child: Column(
                                //       mainAxisAlignment: MainAxisAlignment.center,
                                //       crossAxisAlignment: CrossAxisAlignment.end,
                                //       children: [
                                //         Icon(
                                //           Icons.keyboard_arrow_right_rounded,
                                //           color: AppTheme.actionButton,
                                //           size: 26,
                                //         )
                                //       ],
                                //     ))
                              ]),
                        ))),
                //const Divider()
              ]);
            }).toList(),
          );
  }
}
