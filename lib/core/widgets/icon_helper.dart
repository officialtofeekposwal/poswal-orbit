import 'package:flutter/widgets.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class HabitIconHelper {
  static const Map<String, IconData> icons = {
    'drop': PhosphorIconsRegular.drop,
    'book': PhosphorIconsRegular.bookOpen,
    'barbell': PhosphorIconsRegular.barbell,
    'heart': PhosphorIconsRegular.heart,
    'sparkle': PhosphorIconsRegular.sparkle,
    'target': PhosphorIconsRegular.target,
    'bicycle': PhosphorIconsRegular.bicycle,
    'lightning': PhosphorIconsRegular.lightning,
    'sun': PhosphorIconsRegular.sunHorizon,
    'moon': PhosphorIconsRegular.moon,
    'brain': PhosphorIconsRegular.brain,
    'code': PhosphorIconsRegular.code,
    'coffee': PhosphorIconsRegular.coffee,
    'tree': PhosphorIconsRegular.tree,
    'pencil': PhosphorIconsRegular.pencilSimple,
    'check': PhosphorIconsRegular.checkCircle,
  };

  static IconData getIcon(String name) {
    return icons[name] ?? PhosphorIconsRegular.target;
  }

  static List<String> get availableIconNames => icons.keys.toList();
}
