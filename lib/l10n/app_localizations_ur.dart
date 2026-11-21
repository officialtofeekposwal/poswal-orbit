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
  String get yourOrbitClear => 'آپ کا مدار پرسکون ہے';

  @override
  String get noHabitsScheduled =>
      'آج کے لیے کوئی عادت مقرر نہیں۔\nآرام کریں یا نیچے نئی عادت شروع کریں۔';

  @override
  String get addHabit => 'عادت شامل کریں';

  @override
  String get tasksTitle => 'کام';

  @override
  String tasksDueCount(int count) {
    return '($count باقی)';
  }

  @override
  String get allHabits => 'تمام عادات';

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
  String get streakFreezeActive => '1 اسٹریک فریز فعال';

  @override
  String get streakFreezeDescription =>
      'ماہانہ ایک دن کے ناغے سے تسلسل کو محفوظ رکھتا ہے۔';

  @override
  String get noHabitsYet => 'ابھی کوئی عادت نہیں';

  @override
  String get noHabitsYetSubtitle =>
      'اپنے مدار کا آغاز کرنے کے لیے پہلی عادت بنائیں۔';

  @override
  String get noArchivedHabits => 'کوئی محفوظ شدہ عادت نہیں';

  @override
  String get noArchivedHabitsSubtitle =>
      'محفوظ عادات یہاں الگ رہتی ہیں تاکہ روزمرہ منظر پرسکون رہے۔';

  @override
  String get archivedTapToRestore => 'محفوظ شدہ • بحال کرنے کے لیے دبائیں';

  @override
  String habitRestored(String name) {
    return '\"$name\" کو فعال عادات میں بحال کر دیا گیا';
  }

  @override
  String habitDeleted(String name) {
    return '\"$name\" کو مستقل طور پر حذف کر دیا گیا';
  }

  @override
  String get createHabitTitle => 'نئی عادت بنائیں';

  @override
  String get editHabitTitle => 'عادت کی ترمیم';

  @override
  String get livePreview => 'براہ راست پیش منظر';

  @override
  String get habitNameLabel => 'عادت کا نام';

  @override
  String get habitNameHint => 'مثلاً 20 صفحات کا مطالعہ';

  @override
  String get paletteColor => 'نمایاں رنگ';

  @override
  String get iconLabel => 'علامت';

  @override
  String get timeOfDayLabel => 'دن کا وقت';

  @override
  String get scheduleLabel => 'اوقات کار';

  @override
  String get saveChanges => 'تبدیلیاں محفوظ کریں';

  @override
  String get habitNotFound => 'عادت نہیں ملی';

  @override
  String get currentStreakLabel => 'موجودہ تسلسل';

  @override
  String get bestStreakLabel => 'بہترین تسلسل';

  @override
  String get habitScoreLabel => 'عادت کا اسکور';

  @override
  String get completionRateLabel => 'تکمیل کی شرح';

  @override
  String get archiveHabit => 'عادت محفوظ کریں';

  @override
  String get restoreHabit => 'عادت بحال کریں';

  @override
  String get deleteHabit => 'عادت حذف کریں';

  @override
  String get checkinStatusDone => 'مکمل';

  @override
  String get checkinStatusSkip => 'چھوڑیں';

  @override
  String get checkinStatusMissed => 'چھوٹ گیا';

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
  String get keepDayInMotion => 'اپنے دن کو متحرک رکھیں';

  @override
  String get allProjects => 'تمام پروجیکٹس';

  @override
  String get noPendingTasksFound => 'اس منظر میں کوئی باقی کام نہیں ملا۔';

  @override
  String get addTask => 'کام شامل کریں';

  @override
  String get subtasksTitle => 'ذیلی کام';

  @override
  String get addSubtaskHint => 'ذیلی کام درج کریں...';

  @override
  String get notesLabel => 'نوٹس';

  @override
  String get addNotesHint => 'تفصیلی نوٹس درج کریں...';

  @override
  String get dueDateLabel => 'مقررہ تاریخ';

  @override
  String get priorityLabel => 'ترجیح';

  @override
  String get projectLabel => 'پروجیکٹ';

  @override
  String get taskDeletedToast => 'کام حذف ہو گیا';

  @override
  String get undoButton => 'واپس لائیں';

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
  String get unpinNote => 'پن ہٹائیں';

  @override
  String get pinNote => 'پن کریں';

  @override
  String get changeColorLabel => 'رنگ تبدیل کریں';

  @override
  String get deleteNote => 'نوٹ حذف کریں';

  @override
  String get noteDeletedToast => 'نوٹ حذف ہو گیا';

  @override
  String get noNotesYet => 'ابھی کوئی نوٹ نہیں';

  @override
  String get noNotesYetSubtitle =>
      'اپنے خیالات لکھیں یا آج کا روزنامچہ شروع کریں۔';

  @override
  String get newNote => 'نیا نوٹ';

  @override
  String get noteTitleHint => 'عنوان';

  @override
  String get noteBodyHint => 'تحریر شروع کریں (مارک ڈاؤن سپورٹ)...';

  @override
  String journalForDate(String date) {
    return 'روزنامچہ: $date';
  }

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

  @override
  String get securityTitle => 'ایپ لاک اور سیکیورٹی';

  @override
  String get biometricLock => 'بایومیٹرک لاک';

  @override
  String get biometricLockSubtitle =>
      'آغاز پر فیس آئی ڈی، فنگر پرنٹ یا پاس کوڈ ضروری بنائیں';

  @override
  String get lockTimeout => 'لاک کا وقفہ';

  @override
  String get lockTimeoutImmediate => 'فوراً';

  @override
  String get lockTimeout30s => '30 سیکنڈ بعد';

  @override
  String get lockTimeout1m => '1 منٹ بعد';

  @override
  String get lockTimeout5m => '5 منٹ بعد';

  @override
  String get hideContentRecents => 'حالیہ ایپس میں مواد چھپائیں';

  @override
  String get hideContentRecentsSubtitle =>
      'ٹاسک سوئچر میں ایپ کے پیش منظر کو دھندلا یا بند کرتا ہے';

  @override
  String get unlockPrompt =>
      'عادات اور نوٹس دیکھنے کے لیے پوسوال مدار انلاک کریں';

  @override
  String get unlockWithBiometrics => 'بایومیٹرکس سے انلاک کریں';

  @override
  String get unlockWithPasscode => 'ڈیوائس پاس کوڈ استعمال کریں';

  @override
  String get widgetTodayProgress => 'مدار کی آج کی پیش رفت';

  @override
  String get widgetQuickCheckin => 'فوری عادت چیک اِن';

  @override
  String get widgetTasksGlance => 'باقی کام ایک نظر میں';
}
