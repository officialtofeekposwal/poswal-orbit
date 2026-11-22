import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';

/// HIG Inset Grouped Section for Lists, Tables, and Settings
class AppListSection extends ConsumerWidget {
  final String? title;
  final String? footer;
  final List<Widget> children;
  final EdgeInsetsGeometry margin;
  final bool isDestructive;

  const AppListSection({
    super.key,
    this.title,
    this.footer,
    required this.children,
    this.margin = const EdgeInsets.symmetric(
      horizontal: PoswalSpacing.lg,
      vertical: PoswalSpacing.sm,
    ),
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appThemeModeProvider);
    final isDark = mode.isDark;

    final headerColor = isDark ? PoswalColors.textMutedDark : PoswalColors.textMutedLight;
    final cardBg = isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight;
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    const outerRadius = PoswalRadii.section;

    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header in Title Case (HIG Rule 9)
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: PoswalSpacing.sm,
                bottom: PoswalSpacing.xs,
              ),
              child: Text(
                title!,
                style: PoswalText.footnote.copyWith(
                  color: isDestructive ? PoswalColors.danger : headerColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.1,
                ),
              ),
            ),
          ],

          // Inset Grouped Container (Solid/Semi-solid on Content Layer, never glass blur!)
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(outerRadius),
              border: Border.all(
                color: isDestructive
                    ? PoswalColors.danger.withValues(alpha: 0.30)
                    : borderColor,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.20 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: isDestructive
                  ? PoswalColors.danger.withValues(alpha: isDark ? 0.12 : 0.06)
                  : cardBg,
              borderRadius: BorderRadius.circular(outerRadius),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(children.length, (index) {
                  return Column(
                    children: [
                      children[index],
                      if (index < children.length - 1)
                        Divider(
                          height: 1,
                          thickness: 0.5,
                          indent: PoswalSpacing.lg,
                          color: borderColor,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),

          // Optional Section Footer
          if (footer != null) ...[
            Padding(
              padding: const EdgeInsets.only(
                left: PoswalSpacing.sm,
                top: PoswalSpacing.xs,
              ),
              child: Text(
                footer!,
                style: PoswalText.caption.copyWith(color: headerColor),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
