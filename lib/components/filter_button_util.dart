import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FilterButton<T> extends StatelessWidget {
  final T filterType;
  final String label;
  final void Function(T filterType) onFilterPressed;

  const FilterButton({
    Key? key,
    required this.filterType,
    required this.label,
    required this.onFilterPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.04,
      child: ElevatedButton(
        style: ButtonStyle(
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 0;
              return 0;
            },
          ),
          backgroundColor: MaterialStateProperty.all(AppTheme.primary),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
        onPressed: () => onFilterPressed(filterType),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: AppTheme.nearlyWhite),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.nearlyWhite, size: 20)
          ],
        ),
      ),
    );
  }
}
