import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:poswal_orbit/core/theme/poswal_theme.dart';
import 'package:poswal_orbit/core/theme/poswal_tokens.dart';
import 'package:poswal_orbit/core/widgets/app_glass.dart';

/// HIG Inline Expandable Glass Search Field
class AppSearchField extends ConsumerStatefulWidget {
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onCancelled;
  final String hintText;
  final bool initiallyExpanded;

  const AppSearchField({
    super.key,
    this.controller,
    this.onChanged,
    this.onCancelled,
    this.hintText = 'Search habits, tasks, notes...',
    this.initiallyExpanded = false,
  });

  @override
  ConsumerState<AppSearchField> createState() => _AppSearchFieldState();
}

class _AppSearchFieldState extends ConsumerState<AppSearchField> {
  late final TextEditingController _controller;
  late bool _isExpanded;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _isExpanded = widget.initiallyExpanded;
    if (_isExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
    }
  }

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleExpand() {
    HapticFeedback.lightImpact();
    setState(() => _isExpanded = true);
    _focusNode.requestFocus();
  }

  void _handleCancel() {
    HapticFeedback.lightImpact();
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.unfocus();
    setState(() => _isExpanded = false);
    widget.onCancelled?.call();
  }

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appThemeModeProvider);
    final reduceTransparency = ref.watch(reduceTransparencyProvider);
    final isDark = mode.isDark;
    final textPrimary = isDark ? PoswalColors.textOnDark : PoswalColors.textOnLight;
    final textMuted = isDark ? PoswalColors.textSecondaryDark : PoswalColors.textSecondaryLight;

    const outerRadius = PoswalRadii.capsule;

    if (!_isExpanded) {
      // Compact Glass Search Button
      Widget searchPill = Container(
        height: PoswalRowHeights.minTouchTarget,
        padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
        decoration: BoxDecoration(
          color: (isDark ? Colors.black : Colors.white).withValues(
            alpha: PoswalGlass.tintOpacity(GlassTier.standard, isDark: isDark),
          ),
          borderRadius: BorderRadius.circular(outerRadius),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withValues(
              alpha: PoswalGlass.borderOpacity(GlassTier.standard, isDark: isDark),
            ),
            width: PoswalGlass.borderWidth,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: textMuted),
            const SizedBox(width: PoswalSpacing.xs),
            Text(
              'Search',
              style: PoswalText.callout.copyWith(color: textMuted),
            ),
          ],
        ),
      );

      if (!reduceTransparency && !mode.isOled) {
        final sigma = PoswalGlass.blurSigma(GlassTier.standard);
        searchPill = ClipRRect(
          borderRadius: BorderRadius.circular(outerRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: searchPill,
          ),
        );
      }

      return GestureDetector(
        key: const ValueKey('app_search_field_trigger'),
        onTap: _handleExpand,
        behavior: HitTestBehavior.opaque,
        child: searchPill,
      );
    }

    // Expanded Glass Search Input with Cancel button
    Widget expandedInput = Container(
      height: PoswalRowHeights.minTouchTarget,
      padding: const EdgeInsets.symmetric(horizontal: PoswalSpacing.md),
      decoration: BoxDecoration(
        color: (isDark ? PoswalColors.surfaceDark2 : PoswalColors.surfaceLight).withValues(
          alpha: isDark ? 0.90 : 0.94,
        ),
        borderRadius: BorderRadius.circular(outerRadius),
        border: Border.all(
          color: PoswalColors.teal.withValues(alpha: isDark ? 0.40 : 0.30),
          width: 1.2,
        ),
      ),
      child: Row(
        children: [
          const Icon(PhosphorIconsRegular.magnifyingGlass, size: 18, color: PoswalColors.teal),
          const SizedBox(width: PoswalSpacing.sm),
          Expanded(
            child: TextField(
              key: const ValueKey('app_search_input'),
              controller: _controller,
              focusNode: _focusNode,
              style: PoswalText.subheadline.copyWith(color: textPrimary),
              decoration: InputDecoration(
                hintText: widget.hintText,
                hintStyle: PoswalText.callout.copyWith(color: textMuted),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (val) {
                setState(() {});
                widget.onChanged?.call(val);
              },
            ),
          ),
          if (_controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _controller.clear();
                widget.onChanged?.call('');
                setState(() {});
              },
              child: Padding(
                padding: const EdgeInsets.all(4.0),
                child: Icon(PhosphorIconsFill.xCircle, size: 16, color: textMuted),
              ),
            ),
        ],
      ),
    );

    return Row(
      children: [
        Expanded(child: expandedInput),
        const SizedBox(width: PoswalSpacing.xs),
        TextButton(
          key: const ValueKey('app_search_cancel_btn'),
          onPressed: _handleCancel,
          child: Text(
            'Cancel',
            style: PoswalText.callout.copyWith(
              color: PoswalColors.teal,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
