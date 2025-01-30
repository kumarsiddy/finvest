import 'package:bondgrid/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget buildCircularShimmer(BuildContext context,
    {double size = 50, EdgeInsetsGeometry padding = EdgeInsets.zero}) {
  return Padding(
    padding: padding,
    child: Shimmer.fromColors(
      period: const Duration(milliseconds: 3000),
      baseColor: AppTheme.shimmerBaseColor, // Base color of the shimmer
      highlightColor:
          AppTheme.shimmerHighlightColor, // Highlight color of the shimmer
      child: Container(
        decoration:
            const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        width: size,
        height: size,
      ),
    ),
  );
}

Widget buildNumberShimmer({
  required BuildContext context,
  double width = 200,
  double height = 12,
  EdgeInsets padding = const EdgeInsets.all(0),
  BorderRadius borderRadius = const BorderRadius.all(Radius.circular(5)),
}) {
  return Padding(
    padding: padding,
    child: Shimmer.fromColors(
      period: const Duration(milliseconds: 3000),
      baseColor: AppTheme.shimmerBaseColor, // Base color of the shimmer
      highlightColor:
          AppTheme.shimmerHighlightColor, // Highlight color of the shimmer
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius,
        ),
        width: width,
        height: height,
      ),
    ),
  );
}

Widget buildTransactionShimmer(BuildContext context) {
  return Shimmer.fromColors(
    period: const Duration(milliseconds: 3000),
    baseColor: AppTheme.shimmerBaseColor, // Base color of the shimmer
    highlightColor:
        AppTheme.shimmerHighlightColor, // Highlight color of the shimmer
    child: Column(
      children: List.generate(
        2,
        (index) => Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 12,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: const AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black,
                        ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 200,
                      height: 14,
                      // color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 200,
                      height: 14,
                      //color: Colors.black,
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 28,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 50,
                      height: 14,
                      // color: Colors.black,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      width: 50,
                      height: 14,
                      //color: Colors.black,
                    ),
                  ],
                ),
              ),
              // Expanded(
              //   flex: 28,
              //   child: Column(
              //     crossAxisAlignment: CrossAxisAlignment.end,
              //     children: [
              //       Container(
              //         width: 50,
              //         height: 10,
              //         color: Colors.black,
              //       ),
              //     ],
              //   ),
              // ),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget buildFullPageShimmer(BuildContext context) {
  return Padding(
      padding: const EdgeInsets.all(20),
      child: Shimmer.fromColors(
        period: const Duration(milliseconds: 3000),
        baseColor: AppTheme.shimmerBaseColor, // Base color of the shimmer
        highlightColor:
            AppTheme.shimmerHighlightColor, // Highlight color of the shimmer
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              width: 400,
              height: 20,
              // color: Colors.black,
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(5),
              ),
              width: 200,
              height: 20,
              //color: Colors.black,
            ),
          ],
        ),
      ));
}
