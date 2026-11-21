// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'پوسوال مدار';

  @override
  String get tabToday => 'آج';

  @override
  String get tabHabits => 'عادات';

  @override
  String get tabTasks => 'کام';

  @override
  String get tabNotes => 'نوٹس';

  @override
  String get tabInsights => 'بصیرت';

  @override
  String get greetingMorning => 'صبح بخیر';

  @override
  String get greetingAfternoon => 'دوپہر بخیر';

  @override
  String get greetingEvening => 'شام بخیر';

  @override
  String get greetingNight => 'شب بخیر';

  @override
  String habitsProgress(int completed, int total) {
    return '$total میں سے $completed مکمل';
  }

  @override
  String get allClear => 'سب پرسکون ہے۔ وقت کا لطف اٹھائیں۔';

  @override
  String get habitsAllDone => 'آج کی تمام عادات مکمل ہو گئیں۔ شاندار کارکردگی!';

  @override
  String get tasksDueOverdue => 'مقررہ اور بقایا کام';

  @override
  String get habitsActive => 'فعال';

  @override
  String get habitsArchived => 'محفوظ شدہ';

  @override
  String get newHabit => 'نئی عادت';

  @override
  String streakDays(int days) {
    return '$days دن مسلسل';
  }

  @override
  String get tasksSmartToday => 'آج';

  @override
  String get tasksSmartUpcoming => 'آئندہ';

  @override
  String get tasksSmartAll => 'تمام';

  @override
  String get tasksSmartDone => 'مکمل';

  @override
  String get quickAddTaskHint =>
      'نیا کام شامل کریں (مثلاً کل شام 6 بجے امی کو کال کریں !high #family)';

  @override
  String get priorityUrgent => 'انتہائی ضروری';

  @override
  String get priorityHigh => 'اہم';

  @override
  String get priorityMedium => 'درمیانہ';

  @override
  String get priorityLow => 'معمولی';

  @override
  String get priorityNone => 'کوئی نہیں';

  @override
  String get notesPinned => 'پن کردہ';

  @override
  String get notesAll => 'تمام نوٹس';

  @override
  String get notesTodayJournal => 'آج کا روزنامچہ';

  @override
  String get notesSaved => 'محفوظ ہو گیا';

  @override
  String get notesSaving => 'محفوظ ہو رہا ہے...';

  @override
  String get insightsTitle => 'بصیرت';

  @override
  String get weeklyReviewTitle => 'ہفتہ وار جائزہ';

  @override
  String get productivityScore => 'پیداواری اسکور';

  @override
  String get bestDayOfWeek => 'ہفتے کا بہترین دن';

  @override
  String get bestTimeOfDay => 'دن کا بہترین وقت';

  @override
  String get habitHeatmaps => 'عادات کے ہیٹ میپ';

  @override
  String get habitTaskCorrelation => 'عادت اور کام کا تعلق';

  @override
  String get shareCard => 'شیئر کریں';

  @override
  String get insightsEmptyTitle =>
      'جیسے جیسے آپ آگے بڑھیں گے، بصیرت میں اضافہ ہوگا';

  @override
  String get insightsEmptySubtitle =>
      'ذاتی نمونے، ہفتہ وار جائزے اور پیداواری اسکور کو فعال کرنے کے لیے اپنی عادات اور کام مکمل کریں۔';

  @override
  String get settingsTitle => 'ترتیبات';

  @override
  String get settingsAppearance => 'ظاہری شکل';

  @override
  String get settingsTheme => 'تھیم موڈ';

  @override
  String get settingsAccent => 'نمایاں رنگ';

  @override
  String get settingsGlass => 'شیشے کا اثر';

  @override
  String get settingsReduceTransparency => 'شفافیت کم کریں';

  @override
  String get settingsTime => 'وقت اور دن کی حد';

  @override
  String get settingsDayStart => 'دن کے آغاز کی حد';

  @override
  String get settingsFirstDayOfWeek => 'ہفتے کا پہلا دن';

  @override
  String get settingsHaptics => 'لمسی ارتعاش (ہیپٹکس)';

  @override
  String get settingsNotifications => 'یاد دہانی اور نوٹیفیکیشنز';

  @override
  String get settingsHealthCheck => 'یاد دہانی کی صحت کی جانچ';

  @override
  String get settingsLanguage => 'زبان';

  @override
  String get settingsDataSafety => 'ڈیٹا کی حفاظت اور بیک اپ';

  @override
  String get settingsBackupNow => 'ابھی بیک اپ لیں';

  @override
  String get settingsExport => 'برآمد کریں';

  @override
  String get settingsImport => 'درآمد کریں';

  @override
  String get settingsDanger => 'خطرناک زون';

  @override
  String get settingsDeleteAll => 'تمام ڈیٹا حذف کریں';
}
