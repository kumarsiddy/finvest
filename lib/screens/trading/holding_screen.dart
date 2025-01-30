import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/filter_button_util.dart';
import 'package:bondgrid/enums/holding_status.dart';
import 'package:bondgrid/models/holding.dart';
import 'package:bondgrid/models/holding_list.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/screens/trading/holding_detail_screen.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bondgrid/utilities/format.dart';

class HoldingScreen extends StatefulWidget {
  const HoldingScreen(
      {super.key, required this.showNavBar, required this.holdingList});

  final ValueNotifier<bool> showNavBar;
  final HoldingList holdingList;

  @override
  HoldingScreenState createState() => HoldingScreenState();
}

enum FilterType { maturityTimeFrame, treasuryType }

class HoldingScreenState extends State<HoldingScreen> {
  String _selectedMaturityTimeFrame = "All Time";
  String _selectedTreasuryType = "All";

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
                            showFilters(),
                            anyFilterSelected()
                                ? const Divider()
                                : const SizedBox.shrink(),
                            anyFilterSelected()
                                ? showSelectedFilters()
                                : const SizedBox.shrink(),
                            const SizedBox(
                              height: 20,
                            ),
                            listHoldings(context)
                          ])))));
    });
  }

  Widget headingCard(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      child: Text(
        "Your Holdings",
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
      case FilterType.maturityTimeFrame:
        return maturityTimeFrameFilterList();
      case FilterType.treasuryType:
        return treasuryTypeFilterList();
      default:
        return Container(); // Just in case, this shouldn't be hit.
    }
  }

  Widget showFilters() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            FilterButton<FilterType>(
              filterType: FilterType.maturityTimeFrame,
              label: "Maturity Date",
              onFilterPressed: (type) {
                _showFilterOptionsModal(context, type);
              },
            ),
            const SizedBox(
              width: 5,
            ),
            FilterButton<FilterType>(
              filterType: FilterType.treasuryType,
              label: "Holding Type",
              onFilterPressed: (type) {
                _showFilterOptionsModal(context, type);
              },
            ),
          ],
        ));
  }

  bool anyFilterSelected() {
    return _selectedMaturityTimeFrame != 'All Time' ||
        _selectedTreasuryType != 'All';
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
                      _selectedMaturityTimeFrame = "All Time";
                      _selectedTreasuryType = "All";
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
            _selectedMaturityTimeFrame == 'All Time'
                ? const SizedBox.shrink()
                : const SizedBox(
                    width: 5,
                  ),
            _selectedMaturityTimeFrame == 'All Time'
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
                          _selectedMaturityTimeFrame = "All Time";
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedMaturityTimeFrame,
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
            _selectedTreasuryType == 'All'
                ? const SizedBox.shrink()
                : const SizedBox(
                    width: 5,
                  ),
            _selectedTreasuryType == 'All'
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
                          _selectedTreasuryType = "All";
                        });
                      },
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              _selectedTreasuryType,
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

  Widget maturityTimeFrameFilterList() {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text('Maturity Date Range',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        ...["All Time", "Next 30 Days", "Next 60 Days", "Next 90 Days"]
            .map((timeFrame) {
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedMaturityTimeFrame = timeFrame;
                });
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: Text(
                  timeFrame,
                  style: _selectedMaturityTimeFrame == timeFrame
                      ? AppTheme.bulletBold
                      : AppTheme.bulletNormal,
                ),
                trailing: _selectedMaturityTimeFrame == timeFrame
                    ? const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.primary)
                    : const Icon(Icons.radio_button_off_rounded),
              ));
        }).toList(),
      ],
    );
  }

  Widget treasuryTypeFilterList() {
    Set<String> uniqueHoldingTypes = widget.holdingList.holdings
        .where((holding) => holding.duration != null)
        .map((holding) => holding.duration!)
        .toSet();

    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        ListTile(
          title: Text('Holding Type',
              style: AppTheme.bodyBold, textAlign: TextAlign.center),
        ),
        ...uniqueHoldingTypes.map((treasuryType) {
          return InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                setState(() {
                  _selectedTreasuryType = treasuryType;
                });
                Navigator.pop(context);
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
                title: Text(
                  treasuryType,
                  style: _selectedTreasuryType == treasuryType
                      ? AppTheme.bulletBold
                      : AppTheme.bulletNormal,
                ),
                trailing: _selectedTreasuryType == treasuryType
                    ? const Icon(Icons.radio_button_checked_rounded,
                        color: AppTheme.primary)
                    : const Icon(Icons.radio_button_off_rounded),
              ));
        }).toList(),
      ],
    );
  }

  Widget listHoldings(BuildContext context) {
    List<Holding> filteredHoldings = widget.holdingList.holdings;

    if (_selectedTreasuryType != 'All') {
      filteredHoldings = filteredHoldings
          .where((t) => t.duration == _selectedTreasuryType)
          .toList();
    }

    if (_selectedMaturityTimeFrame != 'All Time') {
      DateTime now = DateTime.now().toLocal();

      if (_selectedMaturityTimeFrame == 'Next 30 Days') {
        DateTime endOf30Days = now.add(const Duration(days: 30));

        filteredHoldings = filteredHoldings.where((t) {
          DateTime maturityDate = DateTime.parse(t.maturityDate!).toLocal();
          return maturityDate.isAfter(now) &&
              maturityDate.isBefore(endOf30Days);
        }).toList();
      } else if (_selectedMaturityTimeFrame == 'Next 60 Days') {
        DateTime endOf60Days = now.add(const Duration(days: 60));

        filteredHoldings = filteredHoldings.where((t) {
          DateTime maturityDate = DateTime.parse(t.maturityDate!).toLocal();
          return maturityDate.isAfter(now) &&
              maturityDate.isBefore(endOf60Days);
        }).toList();
      } else if (_selectedMaturityTimeFrame == 'Next 90 Days') {
        DateTime endOf90Days = now.add(const Duration(days: 90));

        filteredHoldings = filteredHoldings.where((t) {
          DateTime maturityDate = DateTime.parse(t.maturityDate!).toLocal();
          return maturityDate.isAfter(now) &&
              maturityDate.isBefore(endOf90Days);
        }).toList();
      }
    }

    return filteredHoldings.isEmpty
        ? Padding(
            padding: const EdgeInsets.fromLTRB(15, 20, 15, 20),
            child: Align(
                alignment: Alignment.center,
                child: Text(
                  "Nothing to show here",
                  textAlign: TextAlign.center,
                  style: AppTheme.subBodyNormal,
                )))
        : Column(
            children: filteredHoldings.map((holding) {
              return Column(children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        onTap: () {
                          widget.showNavBar.value =
                              false; // Hide the bottom navigation bar
                          if (holding.id != null) {
                            Navigator.push(
                                    context,
                                    (Theme.of(context).platform ==
                                            TargetPlatform.iOS)
                                        ? CupertinoPageRoute(
                                            builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    HomeBloc(HomeRepo()),
                                                child: HoldingDetailScreen(
                                                  holdingId: holding.id!,
                                                )))
                                        : MaterialPageRoute(
                                            builder: (context) => BlocProvider(
                                                create: (context) =>
                                                    HomeBloc(HomeRepo()),
                                                child: HoldingDetailScreen(
                                                  holdingId: holding.id!,
                                                ))))
                                .then((_) {
                              widget.showNavBar.value =
                                  true; // Show the bottom navigation bar
                            });
                          }
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
                                      child: Padding(
                                        padding: const EdgeInsets.all(5),
                                        child: Image.asset(
                                          'lib/assets/seal.png',
                                          height: 35.0,
                                          width: 35.0,
                                        ),
                                      ),
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
                                            holding.duration ?? "",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.bodyNormal,
                                          ),
                                          Text(
                                              "Maturity date: ${holding.maturityDate != null ? formatDate(holding.maturityDate!) : ""}",
                                              overflow: TextOverflow.ellipsis,
                                              style: AppTheme.subBodyNormal)
                                        ])),
                                Expanded(
                                    flex: 28,
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                holding.getTradeSymbol(),
                                                style: GoogleFonts.poppins(
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 8,
                                                    color: AppTheme.secondary
                                                        .withOpacity(0.6)),
                                              ),
                                              Text(
                                                formatAmount(holding
                                                        .currentValue
                                                        ?.toString() ??
                                                    "0.0"),
                                                overflow: TextOverflow.ellipsis,
                                                style: AppTheme.bodyNormal,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            holding.yieldToMaturity != null
                                                ? "${holding.yieldToMaturity!}% YTM"
                                                : "",
                                            overflow: TextOverflow.ellipsis,
                                            style: AppTheme.subBodyNormalGreen,
                                          )
                                        ])),
                                // const SizedBox(
                                //   width: 10,
                                // ),
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
