import 'package:finvest/presentation/core_app/design_library/app_colors.dart';
import 'package:finvest/presentation/core_app/design_library/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;

  const CustomAppBar({
    super.key,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0.2,
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios,
          size: Navigator.canPop(context) ? 16.r : 0,
          color: AppColors.primaryDark,
        ),
        onPressed: () {
          if (Navigator.canPop(context)) {
            Navigator.of(context).pop();
          }
        },
      ),
      title: Body(text: title ?? ''),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
