import 'package:bondgrid/theme/app_theme.dart';
import 'package:bondgrid/utilities/format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

Widget tutorial1Content(BuildContext context, {String interestRate = "5.0"}) {
  return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/coint-growth.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Earn up to $interestRate% APY\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Treasury Bills give you a higher interest rate"
                          " than your savings account, reaching levels not seen since 2007.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/money-banknote.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Lock in your interest rate\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Once you buy a Treasury Bill, you lock in your"
                          " interest rate. In contrast, the interest rate"
                          " on savings account will drop as the Federal Reserve"
                          " lowers interest rates.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/hand-coins-currency.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "No state or local taxes\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Interest earned on Treasury Bills is exempt"
                          " from all state or local taxes.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/school-building.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Treasury Bills are backed by the US Government\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Treasury Bills are issued by the US government,"
                          " making them among the safest investment options available.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/wallet-input.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Sell anytime\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text:
                          "Treasury Bills can be sold at any time due to their high liquidity.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
      ]));
}

Widget tutorial2Content(BuildContext context,
    {String interestRate12Months = "5.0", String interestRate6Months = "5.0"}) {
  double interest12Months = 20000 * double.parse(interestRate12Months) / 100;
  double interest6Months =
      (20000 * double.parse(interestRate6Months) / 100) / 2;

  return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        // Row(
        //     mainAxisAlignment: MainAxisAlignment.start,
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       Expanded(
        //           child: RichText(
        //         textAlign: TextAlign.start,
        //         text: TextSpan(
        //           children: <InlineSpan>[
        //             TextSpan(
        //               text: "Maturity\n",
        //               style: GoogleFonts.poppins(
        //                   fontWeight: FontWeight.bold,
        //                   fontSize: 14,
        //                   color: AppTheme.secondary),
        //             ),
        //             TextSpan(
        //               text: "Maturity refers to the date when you receive"
        //                   " your investment along with the interest earned."
        //                   " Treasury Bills come with different maturity periods,"
        //                   " like 1 month, 3 months, 6 months, or 1 year.",
        //               style: GoogleFonts.poppins(
        //                   fontSize: 14,
        //                   color: AppTheme.secondary.withOpacity(0.7)),
        //             ),
        //           ],
        //         ),
        //       ))
        //     ]),
        // const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Interest\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text:
                          "Interest is calculated annually. Here's how it works:\n\n"
                          "• Example 1: Invest \$20,000 in a 12-month Treasury Bill at $interestRate12Months% interest, and earn ${formatAmount(interest12Months.toStringAsFixed(0), keepZero: false)}: $interestRate12Months% of \$20,000 over 12 months.\n"
                          "• Example 2: Invest \$20,000 in a 6-month Treasury Bill at $interestRate6Months% interest, and earn ${formatAmount(interest6Months.toStringAsFixed(0), keepZero: false)}: Half of $interestRate6Months% of \$20,000, since it's"
                          " for 6 months. The annual interest is adjusted for the shorter term.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Maturity\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Maturity refers to the date when you receive"
                          " your investment along with the interest earned."
                          " Upon maturity, Finvest automatically adds both your"
                          " initial investment and the earned interest to your account.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Selling Prior to Maturity\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text:
                          "You have the flexibility to sell your Treasury Bill before"
                          " its maturity date via the Finvest platform. The platform"
                          " provides the current price of your holding to assist you"
                          " in making an informed decision.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
      ]));
}

Widget tutorial3Content(BuildContext context, {String interestRate = "5.0"}) {
  double interest20KMonths = (20000 * double.parse(interestRate) / 100);
  double interest40KMonths = (40000 * double.parse(interestRate) / 100);
  double interest60KMonths = (60000 * double.parse(interestRate) / 100);
  double interest80KMonths = (80000 * double.parse(interestRate) / 100);
  double interest100KMonths = (100000 * double.parse(interestRate) / 100);

  return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text:
                          "Below is a hypothetical example if you invest in a 12-month Treasury Bill at $interestRate% interest rate",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              )),
            ]),
        const SizedBox(height: 20),
        Table(border: TableBorder.all(), columnWidths: const {
          0: FixedColumnWidth(150.0),
          1: FixedColumnWidth(150.0),
        }, children: [
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Investment',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('Annual Interest Earned',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppTheme.primary)),
                  )),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('\$20,000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        formatAmount(interest20KMonths.toStringAsFixed(0),
                            keepZero: false),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primary)),
                  )),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('\$40,000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        formatAmount(interest40KMonths.toStringAsFixed(0),
                            keepZero: false),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primary)),
                  )),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('\$60,000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        formatAmount(interest60KMonths.toStringAsFixed(0),
                            keepZero: false),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primary)),
                  )),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('\$80,000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        formatAmount(interest80KMonths.toStringAsFixed(0),
                            keepZero: false),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primary)),
                  )),
            ],
          ),
          TableRow(
            children: [
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text('\$100,000',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.secondary)),
                  )),
              TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Container(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                        formatAmount(interest100KMonths.toStringAsFixed(0),
                            keepZero: false),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 14, color: AppTheme.primary)),
                  )),
            ],
          ),
        ])
      ]));
}

Widget tutorial4Content(BuildContext context) {
  return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Column(children: [
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/coint-growth.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text:
                          "Your investments are custodied and cleared through Pershing Advisor Solutions LLC,"
                          " a subsidiary of the Bank of New York Mellon Corp\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text:
                          "Finvest never directly holds your cash or investments -"
                          " its held in custody securely through our banking partner.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/money-banknote.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "Backed by the US Government\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Treasury Bills are also considered to be the"
                          " safest asset because its backed by the full-faith"
                          " of the US Government.",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
        const SizedBox(height: 20),
        Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SvgPicture.asset(
                'lib/assets/hand-coins-currency.svg',
                width: 30,
                height: 30,
              ),
              const SizedBox(width: 20),
              Expanded(
                  child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: "SIPC Coverage\n",
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppTheme.secondary),
                    ),
                    TextSpan(
                      text: "Your account is covered by SIPC, which protects"
                          " securities customers of its members up to \$500,000"
                          " (including \$250,000 for claims for cash).",
                      style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.secondary.withOpacity(0.7)),
                    ),
                  ],
                ),
              ))
            ]),
      ]));
}
