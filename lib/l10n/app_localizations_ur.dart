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
  String get habitsAllDone => 'آج کی تمام عادات مکمل ہو گئیں۔ عمدہ پیش رفت۔';

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
  String get currentStreakLabel => 'موجودہ سلسلہ';

  @override
  String get bestStreakLabel => 'بہترین سلسلہ';

  @override
  String get habitScoreLabel => 'عادت اسکور';

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
      'نیا کام شامل کریں (مثلاً کل شام 6 بجے امی کو کال کریں #family)';

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
  String get dueDateLabel => 'مقررہ تاریخ اور وقت';

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
  String get settingsTheme => 'تھیم';

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
  String get widgetTodayProgress => 'مدار کی آج کی پیش رفت';

  @override
  String get widgetQuickCheckin => 'فوری عادت چیک اِن';

  @override
  String get widgetTasksGlance => 'باقی کام ایک نظر میں';

  @override
  String get dayStartBoundarySubtitle =>
      'اس گھنٹے سے پہلے کی عادتیں پچھلے دن میں شمار ہوتی ہیں';

  @override
  String get reduceTransparencySubtitle =>
      'کم جی پی یو بوجھ یا زیادہ کنٹراسٹ کے لیے ٹھوس پس منظر کارڈ';

  @override
  String get hapticFeedbackSubtitle =>
      'عادت کے دائروں، چیک باکسز اور اشاروں پر لمسی ارتعاش';

  @override
  String get remindersHealthCheckSubtitle =>
      '100٪ قابل اعتماد عادات کی یاد دہانیوں کو یقینی بنانے کے لیے سسٹم کی اجازتوں اور سام سنگ One UI کے پس منظر کے اصولوں کی توثیق کریں۔';

  @override
  String get sendTestAlert => 'آزمائشی الرٹ بھیجیں';

  @override
  String get syncSchedule => 'شیڈول مطابقت پذیر کریں';

  @override
  String get displayLanguage => 'نمائش کی زبان';

  @override
  String get displayLanguageSubtitle =>
      'مقامی فونٹس اور دائیں سے بائیں سمت کے ساتھ انگریزی، ہندی اور اردو کی معاونت';

  @override
  String get autoDailyBackupsActive => 'خودکار روزانہ بیک اپ فعال ہے';

  @override
  String get autoDailyBackupsSubtitle =>
      'حفاظتی دائرہ پچھلے 7 روزانہ بیک اپ محفوظ رکھتا ہے۔';

  @override
  String get deleteAllDataSubtitle =>
      'عادات، اندراجات، کام اور نوٹس مستقل طور پر حذف کریں';

  @override
  String get deleteAllDataDialogTitle => 'کیا تمام ڈیٹا حذف کریں؟';

  @override
  String get deleteAllDataDialogContent =>
      'اس سے تمام عادات، اندراجات، کام اور نوٹس مٹ جائیں گے۔\n\nحذف کرنے سے پہلے ایک حفاظتی بیک اپ خودکار طور پر بن جائے گا تاکہ آپ ضرورت پڑنے پر بحال کر سکیں۔';

  @override
  String get finalConfirmationTitle => 'حتمی تصدیق';

  @override
  String get finalConfirmationContent =>
      'کیا آپ کو مکمل یقین ہے؟ اس عمل سے آپ کا فعال ورک اسپیس ری سیٹ ہو جائے گا۔';

  @override
  String get keepMyData => 'میرا ڈیٹا برقرار رکھیں';

  @override
  String get wipeEverything => 'سب کچھ مٹا دیں';

  @override
  String get importDialogTitle => 'ڈیٹا / لوپ سی ایس وی درآمد کریں';

  @override
  String get importDialogContent =>
      'نیچے جیسن بیک اپ یا لوپ ہیبٹ ٹریکر سی ایس وی کا متن چسپاں کریں:';

  @override
  String get inspectAndImport => 'معائنہ اور درآمد کریں';

  @override
  String get cancel => 'منسوخ کریں';

  @override
  String get proceed => 'آگے بڑھیں';

  @override
  String get understood => 'سمجھ گیا';

  @override
  String get notificationPermissionTitle => 'اطلاعات کی اجازت';

  @override
  String get notificationPermissionSubtitle =>
      'پوسوال مدار کو اسٹیٹس بار اور لاک اسکرین پر الرٹس دکھانے کی اجازت دیتا ہے۔';

  @override
  String get openNotificationSettings => 'اطلاعات کی ترتیبات کھولیں';

  @override
  String get exactAlarmSchedulingTitle => 'درست وقت پر الارم کی ترتیب';

  @override
  String get exactAlarmSchedulingSubtitle =>
      'بیٹری مینجمنٹ کی تاخیر کے بغیر یاد دہانیوں کو عین مقررہ منٹ پر بجنے دیتا ہے۔';

  @override
  String get manageAlarmPermission => 'الارم کی اجازت کا انتظام کریں';

  @override
  String get samsungBatteryExemptionTitle => 'سام سنگ بیٹری چھوٹ';

  @override
  String get samsungBatteryExemptionSubtitle =>
      'ون یو آئی کچھ دن غیر استعمال شدہ ایپس کو سلا دیتا ہے۔ چھوٹ سے تسلسل کی یاد دہانیاں محفوظ رہتی ہیں۔';

  @override
  String get howToSetUnrestricted => '\"غیر پابند\" کیسے سیٹ کریں';

  @override
  String get rollingWindowStatusTitle => '7 روزہ متحرک شیڈول';

  @override
  String rollingWindowStatusSubtitle(int count) {
    return 'او ایس قطار میں $count یاد دہانیاں فعال ہیں۔';
  }

  @override
  String get refillBtn => 'دوبارہ بھریں';

  @override
  String get sendTestNotificationBtn => 'آزمائشی اطلاع بھیجیں';

  @override
  String get dispatching => 'بھیجا جا رہا ہے...';

  @override
  String get granted => 'منظور شدہ';

  @override
  String get restricted => 'محدود';

  @override
  String get samsungGuideTitle => 'سام سنگ ون یو آئی بیٹری گائیڈ';

  @override
  String get samsungGuideIntro =>
      'سام سنگ فون بیٹری بچانے کے لیے بیک گراؤنڈ ایپس کو بند کر دیتے ہیں۔ تسلسل کے الرٹس برقرار رکھنے کے لیے:';

  @override
  String get habitsDoneCount => 'مکمل عادات';

  @override
  String get tasksFinishedCount => 'مکمل کام';

  @override
  String get bestStreakCount => 'بہترین تسلسل';

  @override
  String get peakMomentum => 'عروج کا وقت';

  @override
  String get observedPattern => 'مشاہدہ شدہ انداز';

  @override
  String get correlationDisclaimer =>
      'ہم محدود ڈیٹا پر نتائج اخذ نہیں کرتے۔ حقیقی تعلق جاننے کے لیے ٹریک کرتے رہیں۔';

  @override
  String get overallHeatmap => 'مجموعی سرگرمی کا نقشہ';

  @override
  String get last8Weeks => 'گزشتہ 8 ہفتے';

  @override
  String get heatmapLess => 'کم';

  @override
  String get heatmapMore => 'زیادہ';

  @override
  String get shareWeeklyRhythm => 'پوسوال مدار پر میری ہفتہ وار ترتیب';

  @override
  String shareFailed(String error) {
    return 'شیئر کرنے میں ناکامی: $error';
  }

  @override
  String get restoreHabitTooltip => 'عادت بحال کریں';

  @override
  String get deletePermanentlyTooltip => 'مستقل طور پر حذف کریں';

  @override
  String get habitNotePlaceholder =>
      'مثلاً آج بہت اچھا محسوس ہوا، 20 منٹ اضافی کیا';

  @override
  String get searchNotesPlaceholder =>
      'عنوان یا متن کے لحاظ سے نوٹس فلٹر کریں...';

  @override
  String get addTagPlaceholder => 'مثلاً پروجیکٹ، خیالات';

  @override
  String get addTag => 'شامل کریں';

  @override
  String get colorLabelTooltip => 'رنگین لیبل';

  @override
  String get linkHabitTaskTooltip => 'عادت یا کام سے منسلک کریں';

  @override
  String get addTagTooltip => 'ٹیگ شامل کریں';

  @override
  String get headingTooltip => 'سرخی';

  @override
  String get boldTooltip => 'جلی (بولڈ)';

  @override
  String get italicTooltip => 'ترچھا (اٹالک)';

  @override
  String get bulletListTooltip => 'بلٹ لسٹ';

  @override
  String get checklistTooltip => 'چیک لسٹ';

  @override
  String get insertLinkTooltip => 'لنک داخل کریں';

  @override
  String get linkTextLabel => 'لنک متن';

  @override
  String get linkUrlLabel => 'یو آر ایل (https://...)';

  @override
  String get globalSearchPlaceholder => 'عادات، کام، نوٹس تلاش کریں...';

  @override
  String get searchTasksPlaceholder => 'کام تلاش کریں...';

  @override
  String get noHabitLinked => 'کوئی عادت منسلک نہیں';

  @override
  String taskDeletedNamed(String title) {
    return 'کام \"$title\" حذف کر دیا گیا';
  }

  @override
  String get searchTooltip => 'تلاش کریں';

  @override
  String get settingsTooltip => 'ترتیبات';

  @override
  String get designPlaygroundTooltip => 'ڈیزائن پلے گراؤنڈ';

  @override
  String get mondayShort => 'پیر';

  @override
  String get sundayShort => 'اتوار';

  @override
  String get saving => 'محفوظ ہو رہا ہے...';

  @override
  String get availableBackups => 'دستیاب بیک اپس (آخری 7)';

  @override
  String get noBackupsYet =>
      'ابھی کوئی بیک اپ سنیپ شاٹ نہیں ہے۔ پہلا سنیپ شاٹ محفوظ کرنے کے لیے \"ابھی بیک اپ لیں\" پر ٹیپ کریں۔';

  @override
  String get restore => 'بحال کریں';

  @override
  String get resetOrClearData => 'ڈیٹا ری سیٹ یا صاف کریں';

  @override
  String get backupFullJson => 'مکمل ڈیٹا بیس سنیپ شاٹ (JSON)';

  @override
  String get backupFullJsonSubtitle =>
      'عادات، کاموں اور نوٹس کے ساتھ مکمل پورٹیبل بیک اپ';

  @override
  String get exportHabitsCsv => 'عادات اور چیک ان (CSV)';

  @override
  String get exportTasksCsv => 'کام اور ذیلی کام (CSV)';

  @override
  String get exportNotesCsv => 'نوٹس اور جرنل (CSV)';

  @override
  String get importPreview => 'درآمد کا پیش نظارہ';

  @override
  String importFormat(String format) {
    return 'فارمیٹ: $format';
  }

  @override
  String get importSafetyNote =>
      'آپ کے موجودہ ڈیٹا بیس کی حفاظت کے لیے درآمد کرنے سے پہلے ایک حفاظتی بیک اپ خودکار طور پر بنایا جائے گا۔';

  @override
  String get importPlaceholder =>
      'یہاں JSON بیک اپ یا لوپ CSV ڈیٹا چسپاں کریں...';

  @override
  String get applyImport => 'درآمد لاگو کریں';

  @override
  String get allDataClearedToast =>
      'تمام ڈیٹا صاف کر دیا گیا۔ بیک اپس میں حفاظتی سنیپ شاٹ محفوظ رکھا گیا تھا۔';

  @override
  String fullJsonCopiedToast(int bytes) {
    return 'مکمل JSON بیک اپ کلپ بورڈ پر کاپی ہو گیا ($bytes بائٹس)';
  }

  @override
  String get habitsCsvCopiedToast => 'عادات CSV کلپ بورڈ پر کاپی ہو گئی';

  @override
  String get tasksCsvCopiedToast => 'کام CSV کلپ بورڈ پر کاپی ہو گئے';

  @override
  String get notesCsvCopiedToast => 'نوٹس CSV کلپ بورڈ پر کاپی ہو گئے';

  @override
  String importSuccessToast(int habits, int tasks, int notes) {
    return 'کامیابی کے ساتھ $habits عادات، $tasks کام، $notes نوٹس درآمد کیے گئے';
  }

  @override
  String get remindersHealthCheckTitle => 'یاد دہانیوں کی جانچ';

  @override
  String get onboardingWelcomeTitle => 'پوسوال مدار میں خوش آمدید';

  @override
  String get onboardingWelcomeDesc =>
      'آپ کی عادات، کاموں اور خیالات کے لیے ایک پرسکون، ذاتی اور آف لائن جگہ۔';

  @override
  String get onboardingHabitsTitle => 'پائیدار تسلسل بنائیں';

  @override
  String get onboardingHabitsDesc =>
      'خوبصورت مدار رنگز اور بغیر کسی ندامت کے احساس کے اپنی روزانہ کی رفتار ٹریک کریں۔';

  @override
  String get onboardingTasksTitle => 'پرسکون اور مرکوز کام';

  @override
  String get onboardingTasksDesc =>
      'سمارٹ فہرستیں اور سادہ چیک لسٹس آپ کے دن کو واضح اور پرسکون رکھتی ہیں۔';

  @override
  String get onboardingNotesTitle => 'ذاتی خیالات اور روزنامچہ';

  @override
  String get onboardingNotesDesc =>
      'مارک ڈاؤن نوٹس اور روزنامچہ، صرف آپ کے ڈیوائس پر محفوظ۔';

  @override
  String get getStarted => 'شروع کریں';

  @override
  String get skip => 'چھوڑیں';

  @override
  String get next => 'آگے';

  @override
  String get restoreBackupDialogTitle => 'بیک اپ سے بحال کریں؟';

  @override
  String restoreBackupDialogBody(String date) {
    return 'یہ آپ کے موجودہ ڈیٹا کو $date کے بیک اپ سے بدل دے گا۔\n\nبحال کرنے سے پہلے آپ کے موجودہ ڈیٹا بیس کا ایک حفاظتی سنیپ شاٹ لیا جائے گا تاکہ کچھ ضائع نہ ہو۔';
  }

  @override
  String get restoreSafelyBtn => 'محفوظ طریقے سے بحال کریں';

  @override
  String get settingsAccentColor => 'لہجے کا رنگ';

  @override
  String get settingsGlassIntensity => 'شیشے کی شدت';

  @override
  String get settingsTimeBoundary => 'وقت اور مدار کی حد';

  @override
  String get settingsAbout => 'کے بارے میں';

  @override
  String get deleteTaskBtn => 'کام حذف کریں';

  @override
  String get taskDetailsTitle => 'کام کی تفصیلات';

  @override
  String get noMatchingResults => 'کوئی مماثل نتائج نہیں ملے';

  @override
  String searchSectionHabits(int count) {
    return 'عادات ($count)';
  }

  @override
  String searchSectionTasks(int count) {
    return 'کام ($count)';
  }

  @override
  String searchSectionNotes(int count) {
    return 'نوٹس ($count)';
  }

  @override
  String get colorLabelTitle => 'رنگ کا لیبل';

  @override
  String get allFilter => 'تمام';

  @override
  String get noteColorLabelTitle => 'نوٹ کے رنگ کا لیبل';

  @override
  String get linkHabitOrTaskTitle => 'عادت یا کام سے منسلک کریں';

  @override
  String get habitsSectionHeader => 'عادات';

  @override
  String get tasksSectionHeader => 'کام';

  @override
  String dailyJournalHeader(String date) {
    return 'روزنامچہ • $date';
  }

  @override
  String get linkedHabitLabel => 'منسلک عادت';

  @override
  String get linkedTaskLabel => 'منسلک کام';

  @override
  String get heatmapSkipped => 'چھوڑا گیا';

  @override
  String get habitConsecutiveOccurrences => 'مسلسل دن';

  @override
  String get habitHistoricalRecord => 'تاریخی ریکارڈ';

  @override
  String get habitEwmaConsistency => '14 دن کی مستقل مزاجی';

  @override
  String get testNotificationTitle => 'پوسوال مدار ٹیسٹ اطلاع';

  @override
  String get testNotificationBody =>
      'اس آلہ پر بالکل درست الارم اور اطلاعی چینلز ٹھیک کام کر رہے ہیں۔';

  @override
  String get testNotificationSent =>
      'ٹیسٹ اطلاع بھیج دی گئی ہے۔ اپنی نوٹیفکیشن بار میں مکمل یا 10 منٹ بعد کا اختیار دیکھیں۔';

  @override
  String get calendarTapHint =>
      'چیک ان میں ترمیم کرنے یا نوٹس شامل کرنے کے لیے کسی بھی دن ٹیپ کریں';

  @override
  String get consistencyHeatmapHeader => 'مستقل مزاجی ہیٹ میپ';

  @override
  String get weeklyPerformanceHeader => 'ہفتہ وار کارکردگی';

  @override
  String get consistencyTrendHeader => '30 دن کی مستقل مزاجی کا رجحان';

  @override
  String recordProgressTitle(String unit) {
    return 'پیش رفت درج کریں ($unit)';
  }

  @override
  String get notificationUrgentPrefix => 'ضروری: ';

  @override
  String get notificationHighPrefix => 'اعلیٰ ترجیح: ';

  @override
  String notificationHabitTitle(String name) {
    return '$name کا وقت';
  }

  @override
  String get notificationKeepMomentum => 'آج اپنی رفتار برقرار رکھیں۔';

  @override
  String get notificationTaskDueNow => 'کام کا وقت ہو گیا';

  @override
  String get datePickerSetDate => 'تاریخ منتخب کریں';

  @override
  String get datePickerSetTime => 'وقت منتخب کریں';
}
