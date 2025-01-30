import 'dart:math';

import 'package:bondgrid/bloc/home_bloc.dart';
import 'package:bondgrid/components/item_picker.dart';
import 'package:bondgrid/models/country.dart';
import 'package:bondgrid/repo/home_repo.dart';
import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class AddressSearchBox extends StatefulWidget {
  const AddressSearchBox({
    Key? key,
    required this.streetController,
    required this.additionalController,
    required this.cityController,
    required this.postalCodeController,
    required this.regionController,
    required this.countryCountroller,
    required this.countryPickerController,
    this.focusNode,
  }) : super(key: key);

  final TextEditingController streetController;
  final TextEditingController additionalController;
  final TextEditingController cityController;
  final TextEditingController postalCodeController;
  final TextEditingController regionController;
  final TextEditingController countryCountroller;
  final ItemPickerController<Country> countryPickerController;

  final FocusNode? focusNode;

  @override
  AddressSearchBoxState createState() => AddressSearchBoxState();
}

class AddressSearchBoxState extends State<AddressSearchBox> {
  @override
  void initState() {
    super.initState();
    final showModal = widget.streetController.text.isNotEmpty ||
        widget.cityController.text.isNotEmpty ||
        widget.postalCodeController.text.isNotEmpty ||
        widget.regionController.text.isNotEmpty ||
        widget.countryCountroller.text.isNotEmpty;
    if (!showModal) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAddressSearchModal();
      });
    }
  }

  List<dynamic> addressSuggestions = [];
  TextEditingController addressController = TextEditingController();

  void _showAddressSearchModal() {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StreamBuilder<HomeState>(
          stream: homeBloc.stream,
          builder: (context, snapshot) {
            if (snapshot.data is SearchAddressSuccessState) {
              addressSuggestions =
                  (snapshot.data as SearchAddressSuccessState).suggestions;
            }
            return getModalContent(context, homeBloc);
          },
        );
      },
    );
  }

  Widget getModalContent(BuildContext context, HomeBloc homeBloc) {
    return SingleChildScrollView(
        child: Padding(
      padding: EdgeInsets.only(
        top: 50,
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: MediaQuery.of(context).size.height -
            100 -
            MediaQuery.of(context).viewInsets.bottom,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: SizedBox(
                            height: 50,
                            child: Center(
                                child: TextField(
                              focusNode: widget.focusNode,
                              cursorColor: AppTheme.primary,
                              controller: addressController,
                              //textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              style: GoogleFonts.poppins(
                                fontSize: max(
                                    15,
                                    MediaQuery.of(context).size.height *
                                        0.0175),
                              ),
                              onChanged: (_) async {
                                homeBloc.add(GetAddressSuggestionsEvent(
                                    addressController.text));
                              },
                              decoration: InputDecoration(
                                  filled: true,
                                  contentPadding: const EdgeInsets.only(
                                      right: 12, left: 12),
                                  fillColor: AppTheme.notWhite,
                                  hintText: 'Search Home Address',
                                  hintStyle: GoogleFonts.poppins(
                                      color: AppTheme.inputBoxGrey,
                                      fontSize: max(
                                          15,
                                          MediaQuery.of(context).size.height *
                                              0.0169)),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  alignLabelWithHint: true,
                                  prefixIcon: const Icon(Icons.search),
                                  enabledBorder: OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: Colors.grey[300]!),
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderSide:
                                        BorderSide(color: AppTheme.primary),
                                  )),
                            )))),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        height: MediaQuery.of(context).size.height * 0.07,
                        alignment: Alignment.center,
                        child: Center(
                            child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.notWhite,
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel",
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                      color: AppTheme.primary),
                                ))))
                  ],
                )),
            addressSuggestions.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          "Start typing to see results",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              color: AppTheme.secondary.withOpacity(0.5),
                              fontWeight: FontWeight.w400,
                              fontSize: 12),
                        )))
                : ListView.builder(
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: addressSuggestions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(25, 0, 25, 5),
                        child: GestureDetector(
                            onTap: () async {
                              bool isCurrent =
                                  ModalRoute.of(context)?.isCurrent ?? false;

                              widget.streetController.text = "";
                              widget.additionalController.text = "";
                              widget.cityController.text = "";
                              widget.postalCodeController.text = "";
                              widget.regionController.text = "";
                              widget.countryCountroller.text = "";

                              List<dynamic> addressComponents =
                                  await HomeRepo.getPlaces(
                                      addressSuggestions[index]["place_id"]);
                              String streetNumber = "";
                              String route = "";
                              String country = "";
                              for (Map<String, dynamic> addressComponent
                                  in addressComponents) {
                                for (String type in addressComponent['types']) {
                                  if (type == 'postal_code') {
                                    widget.postalCodeController.text =
                                        addressComponent['long_name'];
                                  }
                                  if (type == 'locality') {
                                    widget.cityController.text =
                                        addressComponent['long_name'];
                                  }
                                  if (type == 'street_number') {
                                    streetNumber =
                                        addressComponent['long_name'];
                                  }
                                  if (type == 'route') {
                                    route = addressComponent['long_name'];
                                  }
                                  if (type == 'administrative_area_level_1') {
                                    widget.regionController.text =
                                        addressComponent['short_name'];
                                  }
                                  if (type == 'country') {
                                    country = addressComponent['long_name'];
                                  }
                                }
                              }
                              if (streetNumber != "" || route != "") {
                                widget.streetController.text =
                                    "$streetNumber $route";
                              }

                              if (country != "") {
                                final countryObj = Country.findByName(country);
                                if (countryObj != null) {
                                  widget.countryCountroller.text =
                                      countryObj.isoCode;
                                  final country =
                                      Country.findByIsoCode(countryObj.isoCode);
                                  if (country != null) {
                                    widget.countryPickerController
                                        .setItem(country);
                                  }
                                }
                              }

                              if (isCurrent) {
                                Navigator.pop(context);
                              }
                            },
                            child: Column(children: [
                              ListTile(
                                  contentPadding: const EdgeInsets.all(0),
                                  key: ValueKey(
                                      addressSuggestions[index]["place_id"]),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 9,
                                        child: Text(
                                            addressSuggestions[index]
                                                ["description"],
                                            style: AppTheme.subBodyNormal),
                                      ),
                                      const Expanded(
                                          flex: 1,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              Icon(
                                                Icons
                                                    .keyboard_arrow_right_rounded,
                                                color: AppTheme.grey,
                                                size: 26,
                                              )
                                            ],
                                          ))
                                    ],
                                  )),
                              const Divider()
                            ])),
                      );
                    },
                  ),
          ],
        ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final homeBloc = BlocProvider.of<HomeBloc>(context);
    return BlocBuilder<HomeBloc, HomeState>(builder: (context, state) {
      return BlocListener<HomeBloc, HomeState>(
          listener: (context, state) {},
          child: GestureDetector(
            onTap: () async {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) {
                  return StreamBuilder<HomeState>(
                    stream: homeBloc.stream,
                    builder: (context, snapshot) {
                      if (snapshot.data is SearchAddressSuccessState) {
                        addressSuggestions =
                            (snapshot.data as SearchAddressSuccessState)
                                .suggestions;
                      }
                      return getModalContent(context, homeBloc);
                    },
                  );
                },
              );
            },
            child: Padding(
                padding: const EdgeInsets.only(bottom: 50 * 0.1),
                child: SizedBox(
                    height: 30,
                    child: Container(
                        padding: const EdgeInsets.only(right: 12, left: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.notWhite,
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.search_rounded,
                                  color: AppTheme.inputBoxGrey,
                                  size: max(
                                      15,
                                      MediaQuery.of(context).size.height *
                                          0.0169)),
                              const SizedBox(
                                width: 5,
                              ),
                              Text("Search Home Address",
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                      color: AppTheme.inputBoxGrey,
                                      fontSize: max(
                                          15,
                                          MediaQuery.of(context).size.height *
                                              0.0169))),
                            ],
                          ),
                        )))),
          ));
    });
  }
}
