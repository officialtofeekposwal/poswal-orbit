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
  String get yourOrbitClear => 'आपकी कक्षा साफ है';

  @override
  String get noHabitsScheduled =>
      'इस दिन के लिए कोई आदत निर्धारित नहीं है।\nविश्राम करें या नीचे एक नई आदत बनाएं।';

  @override
  String get addHabit => 'आदत जोड़ें';

  @override
  String get tasksTitle => 'कार्य';

  @override
  String tasksDueCount(int count) {
    return '($count देय)';
  }

  @override
  String get allHabits => 'सभी आदतें';

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
  String get streakFreezeActive => '1 स्ट्रीक फ्रीज सक्रिय';

  @override
  String get streakFreezeDescription =>
      'प्रति माह एक छूटे हुए निर्धारित दिन की सुरक्षा करता है।';

  @override
  String get noHabitsYet => 'अभी कोई आदत नहीं है';

  @override
  String get noHabitsYetSubtitle =>
      'अपनी कक्षा शुरू करने के लिए पहली आदत जोड़ें।';

  @override
  String get noArchivedHabits => 'कोई संग्रहीत आदत नहीं';

  @override
  String get noArchivedHabitsSubtitle =>
      'संग्रहीत आदतें यहां सुरक्षित रखी जाती हैं ताकि मुख्य स्क्रीन साफ रहे।';

  @override
  String get archivedTapToRestore =>
      'संग्रहीत • पुनः सक्रिय करने के लिए टैप करें';

  @override
  String habitRestored(String name) {
    return '\"$name\" को सक्रिय आदतों में बहाल किया गया';
  }

  @override
  String habitDeleted(String name) {
    return '\"$name\" को हमेशा के लिए हटा दिया गया';
  }

  @override
  String get createHabitTitle => 'नई आदत बनाएं';

  @override
  String get editHabitTitle => 'आदत संपादित करें';

  @override
  String get livePreview => 'लाइव पूर्वावलोकन';

  @override
  String get habitNameLabel => 'आदत का नाम';

  @override
  String get habitNameHint => 'उदा. 20 पृष्ठ पढ़ें';

  @override
  String get paletteColor => 'पसंदीदा रंग';

  @override
  String get iconLabel => 'प्रतीक';

  @override
  String get timeOfDayLabel => 'दिन का समय';

  @override
  String get scheduleLabel => 'समय सारणी';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get habitNotFound => 'आदत नहीं मिली';

  @override
  String get currentStreakLabel => 'वर्तमान स्ट्रीक';

  @override
  String get bestStreakLabel => 'सर्वोत्तम स्ट्रीक';

  @override
  String get habitScoreLabel => 'आदत स्कोर';

  @override
  String get completionRateLabel => 'पूर्णता दर';

  @override
  String get archiveHabit => 'आदत संग्रहीत करें';

  @override
  String get restoreHabit => 'आदत बहाल करें';

  @override
  String get deleteHabit => 'आदत हटाएं';

  @override
  String get checkinStatusDone => 'पूर्ण';

  @override
  String get checkinStatusSkip => 'छोड़ें';

  @override
  String get checkinStatusMissed => 'छूटा';

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
  String get keepDayInMotion => 'अपने दिन को गतिमान रखें';

  @override
  String get allProjects => 'सभी प्रोजेक्ट्स';

  @override
  String get noPendingTasksFound =>
      'इस दृश्य के लिए कोई लंबित कार्य नहीं मिला।';

  @override
  String get addTask => 'कार्य जोड़ें';

  @override
  String get subtasksTitle => 'उप-कार्य';

  @override
  String get addSubtaskHint => 'उप-कार्य जोड़ें...';

  @override
  String get notesLabel => 'नोट्स';

  @override
  String get addNotesHint => 'विस्तृत विवरण जोड़ें...';

  @override
  String get dueDateLabel => 'देय तिथि';

  @override
  String get priorityLabel => 'प्राथमिकता';

  @override
  String get projectLabel => 'प्रोजेक्ट';

  @override
  String get taskDeletedToast => 'कार्य हटा दिया गया';

  @override
  String get undoButton => 'पूर्ववत करें';

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
  String get unpinNote => 'पिन हटाएं';

  @override
  String get pinNote => 'पिन करें';

  @override
  String get changeColorLabel => 'रंग लेबल बदलें';

  @override
  String get deleteNote => 'नोट हटाएं';

  @override
  String get noteDeletedToast => 'नोट हटा दिया गया';

  @override
  String get noNotesYet => 'अभी कोई नोट नहीं है';

  @override
  String get noNotesYetSubtitle => 'अपने विचार लिखें या आज की डायरी शुरू करें।';

  @override
  String get newNote => 'नया नोट';

  @override
  String get noteTitleHint => 'शीर्षक';

  @override
  String get noteBodyHint => 'लिखना शुरू करें (मार्कडाउन-लाइट समर्थित)...';

  @override
  String journalForDate(String date) {
    return 'दैनिक डायरी: $date';
  }

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

  @override
  String get securityTitle => 'ऐप लॉक और सुरक्षा';

  @override
  String get biometricLock => 'बायोमेट्रिक लॉक';

  @override
  String get biometricLockSubtitle =>
      'शुरू होने पर फेस आईडी, फिंगरप्रिंट या पिन अनिवार्य करें';

  @override
  String get lockTimeout => 'लॉक समय सीमा';

  @override
  String get lockTimeoutImmediate => 'तुरंत';

  @override
  String get lockTimeout30s => '30 सेकंड बाद';

  @override
  String get lockTimeout1m => '1 मिनट बाद';

  @override
  String get lockTimeout5m => '5 मिनट बाद';

  @override
  String get hideContentRecents => 'हाल के ऐप्स में सामग्री छुपाएं';

  @override
  String get hideContentRecentsSubtitle =>
      'टास्क स्विचर में ऐप पूर्वावलोकन को धुंधला या ब्लॉक करता है';

  @override
  String get unlockPrompt =>
      'अपनी आदतों और नोट्स को देखने के लिए पोसवाल ऑर्बिट अनलॉक करें';

  @override
  String get unlockWithBiometrics => 'बायोमेट्रिक्स से अनलॉक करें';

  @override
  String get unlockWithPasscode => 'डिवाइस पासकोड उपयोग करें';

  @override
  String get widgetTodayProgress => 'ऑर्बिट आज की प्रगति';

  @override
  String get widgetQuickCheckin => 'त्वरित आदत चेक-इन';

  @override
  String get widgetTasksGlance => 'लंबित कार्य एक नज़र में';
}
