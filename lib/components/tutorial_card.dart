import 'package:bondgrid/screens/home/layout_config.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialCard extends StatefulWidget {
  const TutorialCard(
      {super.key,
      required this.title,
      required this.imagePath,
      this.content = const SizedBox.shrink()});

  final String title;
  final String imagePath;
  final Widget content;

  @override
  TutorialCardState createState() => TutorialCardState();
}

class TutorialCardState extends State<TutorialCard> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTheme.cardElevation,
      color: AppTheme.nearlyWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
          child: InkWell(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (BuildContext context) {
                    return SafeArea(
                      child: Container(
                          height: MediaQuery.of(context).size.height,
                          decoration: const BoxDecoration(
                            color: AppTheme.nearlyWhite,
                          ),
                          child: tutorialContent(context)),
                    );
                  },
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          flex: 6,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                overflow: TextOverflow.visible,
                                style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 18,
                                    color: AppTheme.secondary),
                              ),
                              const SizedBox(height: 10),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: AppTheme.primary, size: 24),
                            ],
                          )),
                      const SizedBox(width: 2),
                      Expanded(
                          flex: 4,
                          child: SizedBox(
                            child: SvgPicture.asset(
                              widget.imagePath,
                              height: 100.0,
                              width: 100.0,
                              fit: BoxFit.cover,
                            ),
                          )),
                    ]),
              ))),
    );
  }

  Widget tutorialContent(BuildContext context) {
    return Padding(
        padding: EdgeInsets.only(top: LayoutConfig().topPadding),
        child: SingleChildScrollView(
            child: Padding(
                padding: const EdgeInsets.only(
                  top: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                        color: AppTheme.backgroundColor,
                        child: Padding(
                            padding: const EdgeInsets.only(top: 10, right: 10),
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  child: const Icon(
                                    Icons.clear,
                                    color: AppTheme.primary,
                                  ),
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                )))),
                    Container(
                      color: AppTheme.backgroundColor,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SvgPicture.asset(
                          widget.imagePath,
                          height: MediaQuery.of(context).size.width * 0.5,
                          width: MediaQuery.of(context).size.width * 0.5,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Padding(
                        padding: const EdgeInsets.only(top: 20, bottom: 20),
                        child: Column(
                          children: [
                            Padding(
                                padding:
                                    const EdgeInsets.only(top: 0, bottom: 30),
                                child: Text(
                                  widget.title,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 22,
                                      color: AppTheme.secondary),
                                )),
                            widget.content
                          ],
                        )),
                  ],
                ))));
  }
}
