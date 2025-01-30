import 'dart:math';

import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ItemPickerController<T> {
  final ValueNotifier<T?> _selectedItemNotifier = ValueNotifier<T?>(null);

  ItemPickerController();

  T? get selectedItem => _selectedItemNotifier.value;

  void setItem(T? item) {
    _selectedItemNotifier.value = item;
  }

  void clear() {
    _selectedItemNotifier.value = null;
  }

  ValueListenable<T?> get selectedItemListenable => _selectedItemNotifier;
}

class ItemPickerWidget<T> extends StatefulWidget {
  final Function(T) onItemChanged;
  final ItemPickerController<T>? controller;
  final T? defaultValue;
  final String label;
  final List<T> items;
  final String Function(T) displayName;
  final String Function(T) uniqueId;

  final bool showDeleteButton;
  final Function? deleteFunction;
  final Widget? deleteWidget;

  final bool enabled;

  const ItemPickerWidget(
      {Key? key,
      required this.onItemChanged,
      required this.label,
      required this.items,
      required this.displayName,
      required this.uniqueId,
      this.controller,
      this.defaultValue,
      this.showDeleteButton = false,
      this.deleteFunction,
      this.deleteWidget,
      this.enabled = true})
      : super(key: key);

  @override
  ItemPickerWidgetState<T> createState() => ItemPickerWidgetState<T>();
}

class ItemPickerWidgetState<T> extends State<ItemPickerWidget<T>> {
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.controller?.selectedItem;
    widget.controller?.selectedItemListenable
        .addListener(_onSelectedItemChanged);
  }

  @override
  void dispose() {
    widget.controller?.selectedItemListenable
        .removeListener(_onSelectedItemChanged);
    super.dispose();
  }

  void _onSelectedItemChanged() {
    setState(() {
      _selectedItem = widget.controller?.selectedItem;
    });
  }

  @override
  void didUpdateWidget(covariant ItemPickerWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      setState(() {
        _selectedItem = widget.controller?.selectedItem;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        _selectedItem = await showDialog<T>(
              context: context,
              builder: (BuildContext context) => _ItemPickerDialog(
                label: widget.label,
                items: widget.items,
                displayName: widget.displayName,
                uniqueId: widget.uniqueId,
              ),
            ) ??
            _selectedItem;

        if (_selectedItem != null) {
          widget.onItemChanged(_selectedItem!);
          widget.controller?.setItem(_selectedItem!);
        }

        setState(() {});
      },
      child: Padding(
          padding: const EdgeInsets.only(bottom: 50 * 0.1),
          child: SizedBox(
              height: 50,
              child: Container(
                  padding: const EdgeInsets.only(right: 12, left: 12),
                  decoration: BoxDecoration(
                    color: AppTheme.notWhite,
                    border: Border.all(
                        color: widget.enabled && _selectedItem != null
                            ? AppTheme.primary
                            : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  alignment: Alignment.center,
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                            child: Text(
                                _selectedItem != null
                                    ? widget.displayName(_selectedItem!)
                                    : widget.label,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: _selectedItem != null
                                    ? GoogleFonts.poppins(
                                        fontSize: max(
                                            15,
                                            MediaQuery.of(context).size.height *
                                                0.0175),
                                      )
                                    : GoogleFonts.poppins(
                                        color: AppTheme.inputBoxGrey,
                                        fontSize: max(
                                            15,
                                            MediaQuery.of(context).size.height *
                                                0.0169)))),
                        widget.showDeleteButton && _selectedItem != null
                            ? IconButton(
                                onPressed: widget.deleteFunction != null
                                    ? () => widget.deleteFunction!()
                                    : null,
                                icon: widget.deleteWidget != null
                                    ? widget.deleteWidget!
                                    : const Icon(Icons.arrow_drop_down,
                                        color: AppTheme.grey, size: 27))
                            : const Icon(Icons.arrow_drop_down,
                                color: AppTheme.grey, size: 27)
                      ],
                    ),
                  )))),
    );
  }
}

class _ItemPickerDialog<T> extends StatefulWidget {
  final String label;
  final List<T> items;
  final String Function(T) displayName;
  final String Function(T) uniqueId;

  const _ItemPickerDialog({
    Key? key,
    required this.label,
    required this.items,
    required this.displayName,
    required this.uniqueId,
  }) : super(key: key);

  @override
  _ItemPickerDialogState<T> createState() => _ItemPickerDialogState<T>();
}

class _ItemPickerDialogState<T> extends State<_ItemPickerDialog<T>> {
  late List<T> filteredItems;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    filteredItems = widget.items;
  }

  void filterItems(String query) {
    final List<T> updatedList = widget.items.where((item) {
      // Get the display name and split it into words
      List<String> words = widget.displayName(item).toLowerCase().split(' ');
      // Check if any of the words contains the query
      return words.any((word) => word.contains(query.toLowerCase()));
    }).toList();
    setState(() {
      searchQuery = query;
      filteredItems = updatedList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 5),
            child: TextField(
              onChanged: filterItems,
              cursorColor: AppTheme.primary,
              decoration: InputDecoration(
                  fillColor: AppTheme.notWhite,
                  hintText: "Search",
                  hintStyle: GoogleFonts.poppins(
                      color: AppTheme.inputBoxGrey,
                      fontSize:
                          max(15, MediaQuery.of(context).size.height * 0.0169)),
                  contentPadding: const EdgeInsets.only(right: 12, left: 12),
                  prefixIcon: const Icon(Icons.search),
                  enabledBorder: OutlineInputBorder(
                    // borderRadius:
                    //     const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    // borderRadius:
                    //     const BorderRadius.all(Radius.circular(10)),
                    borderSide: BorderSide(color: AppTheme.primary),
                  )),
            ),
          ),
          ConstrainedBox(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height / 2.5),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 5, 20, 10),
                child: Column(
                  children: filteredItems.map((item) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(context, item);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                widget.displayName(item),
                                style: AppTheme.bodyNormal,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
