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
  String get habitsAllDone =>
      'आज की सभी आदतें पूरी हो चुकी हैं। उत्कृष्ट प्रगति।';

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
  String get currentStreakLabel => 'वर्तमान लय';

  @override
  String get bestStreakLabel => 'सर्वश्रेष्ठ लय';

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
      'कार्य जोड़ें (उदा. कल शाम 6 बजे माँ को कॉल #family)';

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
  String get dueDateLabel => 'नियत तिथि और समय';

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
  String get settingsTheme => 'थीम';

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
  String get widgetTodayProgress => 'ऑर्बिट आज की प्रगति';

  @override
  String get widgetQuickCheckin => 'त्वरित आदत चेक-इन';

  @override
  String get widgetTasksGlance => 'लंबित कार्य एक नज़र में';

  @override
  String get dayStartBoundarySubtitle =>
      'इस घंटे से पहले की आदतें पिछले दिन में गिनी जाती हैं';

  @override
  String get reduceTransparencySubtitle =>
      'कम जीपीयू लोड या उच्च कंट्रास्ट के लिए ठोस बैकग्राउंड कार्ड';

  @override
  String get hapticFeedbackSubtitle =>
      'आदत चक्र, चेकबॉक्स और जेस्चर पर स्पर्श प्रतिक्रिया';

  @override
  String get remindersHealthCheckSubtitle =>
      '100% विश्वसनीय आदत रिमाइंडर सुनिश्चित करने के लिए सिस्टम अनुमतियों और सैमसंग One UI बैकग्राउंड नियमों की जांच करें।';

  @override
  String get sendTestAlert => 'परीक्षण अलर्ट भेजें';

  @override
  String get syncSchedule => 'शेड्यूल सिंक करें';

  @override
  String get displayLanguage => 'प्रदर्शन भाषा';

  @override
  String get displayLanguageSubtitle =>
      'मूल फोंट और आरटीएल दिशा के साथ अंग्रेज़ी, हिन्दी और उर्दू का समर्थन';

  @override
  String get autoDailyBackupsActive => 'स्वचालित दैनिक बैकअप सक्रिय';

  @override
  String get autoDailyBackupsSubtitle =>
      'रोलिंग रिटेंशन पिछले 7 दैनिक स्नैपशॉट को सुरक्षित रखता है।';

  @override
  String get deleteAllDataSubtitle =>
      'आदतें, प्रविष्टियाँ, कार्य और नोट्स स्थायी रूप से मिटाएँ';

  @override
  String get deleteAllDataDialogTitle => 'सारा डेटा हटाएं?';

  @override
  String get deleteAllDataDialogContent =>
      'यह सभी आदतों, प्रविष्टियों, कार्यों और नोट्स को मिटा देगा।\n\nमिटाने से पहले एक सुरक्षा बैकअप स्नैपशॉट स्वचालित रूप से बनाया जाएगा ताकि आप ज़रूरत पड़ने पर पुनर्प्राप्त कर सकें।';

  @override
  String get finalConfirmationTitle => 'अंतिम पुष्टि';

  @override
  String get finalConfirmationContent =>
      'क्या आप पूरी तरह सुनिश्चित हैं? यह क्रिया आपके सक्रिय कार्यक्षेत्र को रीसेट कर देगी।';

  @override
  String get keepMyData => 'मेरा डेटा रखें';

  @override
  String get wipeEverything => 'सब कुछ मिटा दें';

  @override
  String get importDialogTitle => 'डेटा / लूप सीएसवी आयात करें';

  @override
  String get importDialogContent =>
      'नीचे जेसन बैकअप सामग्री या लूप हैबिट ट्रैकर सीएसवी डेटा पेस्ट करें:';

  @override
  String get inspectAndImport => 'निरीक्षण और आयात करें';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get proceed => 'आगे बढ़ें';

  @override
  String get understood => 'समझ गया';

  @override
  String get notificationPermissionTitle => 'अधिसूचना अनुमति';

  @override
  String get notificationPermissionSubtitle =>
      'पोसवाल ऑर्बिट को आपके स्टेटस बार और लॉक स्क्रीन पर अलर्ट दिखाने की अनुमति देता है।';

  @override
  String get openNotificationSettings => 'अधिसूचना सेटिंग्स खोलें';

  @override
  String get exactAlarmSchedulingTitle => 'सटीक अलार्म शेड्यूलिंग';

  @override
  String get exactAlarmSchedulingSubtitle =>
      'रिमाइंडर को बैटरी प्रबंधन द्वारा विलंबित किए बिना ठीक उसी मिनट पर बजने की अनुमति देता है।';

  @override
  String get manageAlarmPermission => 'अलार्म अनुमति प्रबंधित करें';

  @override
  String get samsungBatteryExemptionTitle => 'सैमसंग बैटरी छूट';

  @override
  String get samsungBatteryExemptionSubtitle =>
      'वन यूआई कुछ दिनों तक उपयोग न किए गए ऐप्स को सुला देता है। छूट से स्ट्रीक रिमाइंडर सुनिश्चित रहते हैं।';

  @override
  String get howToSetUnrestricted => '\"अप्रतिबंधित\" कैसे सेट करें';

  @override
  String get rollingWindowStatusTitle => 'रोलिंग 7-दिवसीय विंडो';

  @override
  String rollingWindowStatusSubtitle(int count) {
    return 'ओएस कतार में $count निर्धारित अनुस्मारक सक्रिय हैं।';
  }

  @override
  String get refillBtn => 'पुनः भरें';

  @override
  String get sendTestNotificationBtn => 'परीक्षण अधिसूचना भेजें';

  @override
  String get dispatching => 'भेज रहा है...';

  @override
  String get granted => 'स्वीकृत';

  @override
  String get restricted => 'प्रतिबंधित';

  @override
  String get samsungGuideTitle => 'सैमसंग वन यूआई बैटरी गाइड';

  @override
  String get samsungGuideIntro =>
      'सैमसंग फोन बैटरी बचाने के लिए बैकग्राउंड ऐप्स को बंद कर देते हैं। स्ट्रीक रिमाइंडर न छूटने के लिए:';

  @override
  String get habitsDoneCount => 'आदतें पूरी हुईं';

  @override
  String get tasksFinishedCount => 'कार्य पूर्ण हुए';

  @override
  String get bestStreakCount => 'सर्वश्रेष्ठ स्ट्रीक';

  @override
  String get peakMomentum => 'चरम गति';

  @override
  String get observedPattern => 'देखा गया पैटर्न';

  @override
  String get correlationDisclaimer =>
      'हम सीमित डेटा पर निष्कर्ष पर नहीं पहुँचते। वास्तविक सहसंबंध प्रकट करने के लिए ट्रैक करते रहें।';

  @override
  String get overallHeatmap => 'समग्र गतिविधि हीटमैप';

  @override
  String get last8Weeks => 'पिछले 8 सप्ताह';

  @override
  String get heatmapLess => 'कम';

  @override
  String get heatmapMore => 'अधिक';

  @override
  String get shareWeeklyRhythm => 'पोसवाल ऑर्बिट पर मेरी साप्ताहिक लय';

  @override
  String shareFailed(String error) {
    return 'साझा करने में विफल: $error';
  }

  @override
  String get restoreHabitTooltip => 'आदत पुनर्स्थापित करें';

  @override
  String get deletePermanentlyTooltip => 'स्थायी रूप से हटाएं';

  @override
  String get habitNotePlaceholder =>
      'उदा. आज बहुत अच्छा लगा, 20 मिनट अतिरिक्त किया';

  @override
  String get searchNotesPlaceholder =>
      'शीर्षक या सामग्री द्वारा नोट्स फ़िल्टर करें...';

  @override
  String get addTagPlaceholder => 'उदा. प्रोजेक्ट, विचार';

  @override
  String get addTag => 'जोड़ें';

  @override
  String get colorLabelTooltip => 'रंग लेबल';

  @override
  String get linkHabitTaskTooltip => 'आदत/कार्य से जोड़ें';

  @override
  String get addTagTooltip => 'टैग जोड़ें';

  @override
  String get headingTooltip => 'शीर्षक';

  @override
  String get boldTooltip => 'मोटा (बोल्ड)';

  @override
  String get italicTooltip => 'तिरछा (इटैलिक)';

  @override
  String get bulletListTooltip => 'बुलेट सूची';

  @override
  String get checklistTooltip => 'चेकलिस्ट';

  @override
  String get insertLinkTooltip => 'लिंक डालें';

  @override
  String get linkTextLabel => 'लिंक का टेक्स्ट';

  @override
  String get linkUrlLabel => 'यूआरएल (https://...)';

  @override
  String get globalSearchPlaceholder => 'आदतें, कार्य, नोट्स खोजें...';

  @override
  String get searchTasksPlaceholder => 'कार्य खोजें...';

  @override
  String get noHabitLinked => 'कोई आदत जुड़ी नहीं';

  @override
  String taskDeletedNamed(String title) {
    return 'कार्य \"$title\" हटा दिया गया';
  }

  @override
  String get searchTooltip => 'खोजें';

  @override
  String get settingsTooltip => 'सेटिंग्स';

  @override
  String get designPlaygroundTooltip => 'डिज़ाइन प्लेग्राउंड';

  @override
  String get mondayShort => 'सोम';

  @override
  String get sundayShort => 'रवि';

  @override
  String get saving => 'सहेज रहा है...';

  @override
  String get availableBackups => 'उपलब्ध बैकअप (पिछले 7)';

  @override
  String get noBackupsYet =>
      'अभी कोई बैकअप स्नैपशॉट नहीं है। अपना पहला स्नैपशॉट सहेजने के लिए \"अभी बैकअप लें\" पर टैप करें।';

  @override
  String get restore => 'पुनर्स्थापित करें';

  @override
  String get resetOrClearData => 'डेटा रीसेट या साफ़ करें';

  @override
  String get backupFullJson => 'पूर्ण डेटाबेस स्नैपशॉट (JSON)';

  @override
  String get backupFullJsonSubtitle =>
      'आदतों, कार्यों और नोट्स के साथ पूर्ण पोर्टेबल बैकअप';

  @override
  String get exportHabitsCsv => 'आदतें और चेक-इन (CSV)';

  @override
  String get exportTasksCsv => 'कार्य और उप-कार्य (CSV)';

  @override
  String get exportNotesCsv => 'नोट्स और जर्नल (CSV)';

  @override
  String get importPreview => 'आयात पूर्वावलोकन';

  @override
  String importFormat(String format) {
    return 'प्रारूप: $format';
  }

  @override
  String get importSafetyNote =>
      'आपके वर्तमान डेटाबेस की सुरक्षा के लिए आयात करने से पहले एक सुरक्षा बैकअप स्वचालित रूप से बनाया जाएगा।';

  @override
  String get importPlaceholder => 'JSON बैकअप या लूप CSV डेटा यहाँ चिपकाएँ...';

  @override
  String get applyImport => 'आयात लागू करें';

  @override
  String get allDataClearedToast =>
      'सभी डेटा साफ़ कर दिया गया। बैकअप में सुरक्षा स्नैपशॉट सुरक्षित रखा गया था।';

  @override
  String fullJsonCopiedToast(int bytes) {
    return 'पूर्ण JSON बैकअप क्लिपबोर्ड पर कॉपी किया गया ($bytes बाइट्स)';
  }

  @override
  String get habitsCsvCopiedToast => 'आदतें CSV क्लिपबोर्ड पर कॉपी की गई';

  @override
  String get tasksCsvCopiedToast => 'कार्य CSV क्लिपबोर्ड पर कॉपी किए गए';

  @override
  String get notesCsvCopiedToast => 'नोट्स CSV क्लिपबोर्ड पर कॉपी किए गए';

  @override
  String importSuccessToast(int habits, int tasks, int notes) {
    return 'सफलतापूर्वक $habits आदतें, $tasks कार्य, $notes नोट्स आयात किए गए';
  }

  @override
  String get remindersHealthCheckTitle => 'रिमाइंडर स्वास्थ्य जांच';

  @override
  String get onboardingWelcomeTitle => 'पोसवाल ऑर्बिट में आपका स्वागत है';

  @override
  String get onboardingWelcomeDesc =>
      'आपकी आदतों, कार्यों और विचारों के लिए एक शांत, निजी और ऑफ़लाइन स्थान।';

  @override
  String get onboardingHabitsTitle => 'स्थायी गति बनाएं';

  @override
  String get onboardingHabitsDesc =>
      'खूबसूरत ऑर्बिट रिंग्स और बिना किसी अपराधबोध के अपनी दैनिक प्रगति ट्रैक करें।';

  @override
  String get onboardingTasksTitle => 'शांत और केंद्रित कार्य';

  @override
  String get onboardingTasksDesc =>
      'स्मार्ट सूचियां और आसान चेकलिस्ट आपके दिन को स्पष्ट और शांत रखती हैं।';

  @override
  String get onboardingNotesTitle => 'निजी विचार और डायरी';

  @override
  String get onboardingNotesDesc =>
      'मार्कडाउन नोट्स और दैनिक डायरी, केवल आपके डिवाइस पर सुरक्षित।';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get skip => 'छोड़ें';

  @override
  String get next => 'आगे';

  @override
  String get restoreBackupDialogTitle => 'बैकअप से पुनर्स्थापित करें?';

  @override
  String restoreBackupDialogBody(String date) {
    return 'यह आपके वर्तमान डेटा को $date के बैकअप से बदल देगा।\n\nपुनर्स्थापित करने से ठीक पहले आपके वर्तमान डेटाबेस का एक सुरक्षा स्नैपशॉट लिया जाएगा ताकि कुछ भी न खोए।';
  }

  @override
  String get restoreSafelyBtn => 'सुरक्षित रूप से पुनर्स्थापित करें';

  @override
  String get settingsAccentColor => 'एक्सेंट रंग';

  @override
  String get settingsGlassIntensity => 'ग्लास तीव्रता';

  @override
  String get settingsTimeBoundary => 'समय और कक्षा सीमा';

  @override
  String get settingsAbout => 'के बारे में';

  @override
  String get deleteTaskBtn => 'कार्य हटाएं';

  @override
  String get taskDetailsTitle => 'कार्य विवरण';

  @override
  String get noMatchingResults => 'कोई मेल खाने वाले परिणाम नहीं मिले';

  @override
  String searchSectionHabits(int count) {
    return 'आदतें ($count)';
  }

  @override
  String searchSectionTasks(int count) {
    return 'कार्य ($count)';
  }

  @override
  String searchSectionNotes(int count) {
    return 'नोट्स ($count)';
  }

  @override
  String get colorLabelTitle => 'रंग लेबल';

  @override
  String get allFilter => 'सभी';

  @override
  String get noteColorLabelTitle => 'नोट का रंग लेबल';

  @override
  String get linkHabitOrTaskTitle => 'आदत या कार्य से जोड़ें';

  @override
  String get habitsSectionHeader => 'आदतें';

  @override
  String get tasksSectionHeader => 'कार्य';

  @override
  String dailyJournalHeader(String date) {
    return 'दैनिक डायरी • $date';
  }

  @override
  String get linkedHabitLabel => 'जुड़ी हुई आदत';

  @override
  String get linkedTaskLabel => 'जुड़ा हुआ कार्य';

  @override
  String get heatmapSkipped => 'छोड़ा गया';

  @override
  String get habitConsecutiveOccurrences => 'लगातार दिन';

  @override
  String get habitHistoricalRecord => 'ऐतिहासिक रिकॉर्ड';

  @override
  String get habitEwmaConsistency => '14-दिवसीय ईडब्ल्यूएमए निरंतरता';

  @override
  String get testNotificationTitle => 'पोसवाल ऑर्बिट परीक्षण सूचना';

  @override
  String get testNotificationBody =>
      'इस डिवाइस पर सटीक अलार्म और अधिसूचना चैनल ठीक से काम कर रहे हैं।';

  @override
  String get testNotificationSent =>
      'परीक्षण सूचना भेज दी गई है। अपनी सूचना पट्टी में पूर्ण या 10 मिनट बाद विकल्प देखें।';

  @override
  String get calendarTapHint =>
      'चेक-इन संपादित करने या नोट्स जोड़ने के लिए किसी भी दिन टैप करें';

  @override
  String get consistencyHeatmapHeader => 'निरंतरता हीटमैप';

  @override
  String get weeklyPerformanceHeader => 'साप्ताहिक प्रदर्शन';

  @override
  String get consistencyTrendHeader => '30-दिवसीय निरंतरता रुझान';

  @override
  String recordProgressTitle(String unit) {
    return 'प्रगति दर्ज करें ($unit)';
  }

  @override
  String get notificationUrgentPrefix => 'अति आवश्यक: ';

  @override
  String get notificationHighPrefix => 'उच्च प्राथमिकता: ';

  @override
  String notificationHabitTitle(String name) {
    return '$name का समय';
  }

  @override
  String get notificationKeepMomentum => 'आज अपनी गति बनाए रखें।';

  @override
  String get notificationTaskDueNow => 'कार्य का समय हो गया';

  @override
  String get datePickerSetDate => 'तिथि चुनें';

  @override
  String get datePickerSetTime => 'समय चुनें';
}
