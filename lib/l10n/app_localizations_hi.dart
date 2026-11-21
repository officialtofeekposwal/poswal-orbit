// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'पोसवाल ऑर्बिट';

  @override
  String get tabToday => 'आज';

  @override
  String get tabHabits => 'आदतें';

  @override
  String get tabTasks => 'कार्य';

  @override
  String get tabNotes => 'नोट्स';

  @override
  String get tabInsights => 'अंतर्दृष्टि';

  @override
  String get greetingMorning => 'सुप्रभात';

  @override
  String get greetingAfternoon => 'शुभ दोपहर';

  @override
  String get greetingEvening => 'शुभ संध्या';

  @override
  String get greetingNight => 'शुभ संध्या';

  @override
  String habitsProgress(int completed, int total) {
    return '$total में से $completed पूर्ण';
  }

  @override
  String get allClear => 'सब कुछ शांत है। आराम का आनंद लें।';

  @override
  String get habitsAllDone => 'आज की सभी आदतें पूरी हो चुकी हैं। शानदार काम!';

  @override
  String get tasksDueOverdue => 'देय और बकाया कार्य';

  @override
  String get habitsActive => 'सक्रिय';

  @override
  String get habitsArchived => 'संग्रहीत';

  @override
  String get newHabit => 'नई आदत';

  @override
  String streakDays(int days) {
    return '$days दिन लगातार';
  }

  @override
  String get tasksSmartToday => 'आज';

  @override
  String get tasksSmartUpcoming => 'आगामी';

  @override
  String get tasksSmartAll => 'सभी';

  @override
  String get tasksSmartDone => 'पूर्ण';

  @override
  String get quickAddTaskHint =>
      'कार्य जोड़ें (उदा. कल शाम 6 बजे माँ को कॉल !high #family)';

  @override
  String get priorityUrgent => 'अति आवश्यक';

  @override
  String get priorityHigh => 'उच्च';

  @override
  String get priorityMedium => 'मध्यम';

  @override
  String get priorityLow => 'निम्न';

  @override
  String get priorityNone => 'कोई नहीं';

  @override
  String get notesPinned => 'पिन किए गए';

  @override
  String get notesAll => 'सभी नोट्स';

  @override
  String get notesTodayJournal => 'आज की डायरी';

  @override
  String get notesSaved => 'सहेजा गया';

  @override
  String get notesSaving => 'सहेजा जा रहा है...';

  @override
  String get insightsTitle => 'अंतर्दृष्टि';

  @override
  String get weeklyReviewTitle => 'साप्ताहिक समीक्षा';

  @override
  String get productivityScore => 'उत्पादकता स्कोर';

  @override
  String get bestDayOfWeek => 'सप्ताह का सर्वश्रेष्ठ दिन';

  @override
  String get bestTimeOfDay => 'दिन का सर्वोत्तम समय';

  @override
  String get habitHeatmaps => 'आदत हीटमैप्स';

  @override
  String get habitTaskCorrelation => 'आदत और कार्य संबंध';

  @override
  String get shareCard => 'साझा करें';

  @override
  String get insightsEmptyTitle =>
      'जैसे-जैसे आप आगे बढ़ेंगे, अंतर्दृष्टि बढ़ेगी';

  @override
  String get insightsEmptySubtitle =>
      'व्यक्तिगत पैटर्न, साप्ताहिक समीक्षा और उत्पादकता स्कोर अनलॉक करने के लिए आदतें पूरी करें और कार्य पूरे करें।';

  @override
  String get settingsTitle => 'सेटिंग्स';

  @override
  String get settingsAppearance => 'दिखावट';

  @override
  String get settingsTheme => 'थीम मोड';

  @override
  String get settingsAccent => 'मुख्य रंग';

  @override
  String get settingsGlass => 'कांच प्रभाव तीव्रता';

  @override
  String get settingsReduceTransparency => 'पारदर्शिता कम करें';

  @override
  String get settingsTime => 'समय और दिन की सीमा';

  @override
  String get settingsDayStart => 'दिन की शुरुआत का समय';

  @override
  String get settingsFirstDayOfWeek => 'सप्ताह का पहला दिन';

  @override
  String get settingsHaptics => 'हैप्टिक कंपन';

  @override
  String get settingsNotifications => 'अनुस्मारक और सूचनाएं';

  @override
  String get settingsHealthCheck => 'अनुस्मारक स्थिति जांच';

  @override
  String get settingsLanguage => 'भाषा';

  @override
  String get settingsDataSafety => 'डेटा सुरक्षा और बैकअप';

  @override
  String get settingsBackupNow => 'अभी बैकअप लें';

  @override
  String get settingsExport => 'निर्यात करें';

  @override
  String get settingsImport => 'आयात करें';

  @override
  String get settingsDanger => 'खतरा क्षेत्र';

  @override
  String get settingsDeleteAll => 'सारा डेटा हटाएं';
}
