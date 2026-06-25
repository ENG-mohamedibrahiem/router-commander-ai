import 'package:flutter/material.dart';

import '../../config/app_breakpoints.dart';
import '../../config/app_spacing.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required this.slivers,
    this.padding = const EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.lg,
    ),
    super.key,
  });

  final List<Widget> slivers;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: SliverConstrainedCrossAxis(
              maxExtent: AppBreakpoints.maxContentWidth,
              sliver: SliverMainAxisGroup(slivers: slivers),
            ),
          ),
        ],
      ),
    );
  }
}
