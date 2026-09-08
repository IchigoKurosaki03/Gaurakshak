enum AppLanguage {
  english('en', 'English'),
  hindi('hi', 'हिंदी'),
  marathi('mr', 'मराठी');

  const AppLanguage(this.code, this.label);
  final String code;
  final String label;
}

const Map<String, Map<AppLanguage, String>> _strings = {
  'home': {AppLanguage.english: 'Home', AppLanguage.hindi: 'होम', AppLanguage.marathi: 'मुख्यपृष्ठ'},
  'cows': {AppLanguage.english: 'Cows', AppLanguage.hindi: 'गायें', AppLanguage.marathi: 'गायी'},
  'health': {AppLanguage.english: 'Health', AppLanguage.hindi: 'स्वास्थ्य', AppLanguage.marathi: 'आरोग्य'},
  'milk': {AppLanguage.english: 'Milk', AppLanguage.hindi: 'दूध', AppLanguage.marathi: 'दूध'},
  'more': {AppLanguage.english: 'More', AppLanguage.hindi: 'अन्य', AppLanguage.marathi: 'अधिक'},
  'goodMorning': {AppLanguage.english: 'GOOD MORNING', AppLanguage.hindi: 'सुप्रभात', AppLanguage.marathi: 'शुभ सकाळ'},
  'todayMilk': {AppLanguage.english: "TODAY'S MILK", AppLanguage.hindi: 'आज का दूध', AppLanguage.marathi: 'आजचे दूध'},
  'herdOverview': {AppLanguage.english: 'Herd overview', AppLanguage.hindi: 'झुंड का सारांश', AppLanguage.marathi: 'कळपाचा आढावा'},
  'startMilking': {AppLanguage.english: 'Start a milking session', AppLanguage.hindi: 'दूध निकालना शुरू करें', AppLanguage.marathi: 'दूध काढणे सुरू करा'},
  'scanCow': {AppLanguage.english: 'Scan cow tag', AppLanguage.hindi: 'गाय का टैग स्कैन करें', AppLanguage.marathi: 'गायीचा टॅग स्कॅन करा'},
  'cowHealth': {AppLanguage.english: 'Cow health', AppLanguage.hindi: 'गाय का स्वास्थ्य', AppLanguage.marathi: 'गायीचे आरोग्य'},
  'healthSubtitle': {AppLanguage.english: 'Check a cow’s latest wearable and health readings.', AppLanguage.hindi: 'गाय के नवीनतम वेयरेबल और स्वास्थ्य रीडिंग देखें।', AppLanguage.marathi: 'गायीचे नवीनतम वेअरेबल आणि आरोग्य रीडिंग तपासा.'},
  'milkMonitoring': {AppLanguage.english: 'Milk monitoring', AppLanguage.hindi: 'दूध निगरानी', AppLanguage.marathi: 'दूध निरीक्षण'},
  'milkSubtitle': {AppLanguage.english: 'Check the latest milk-quality and milking readings.', AppLanguage.hindi: 'नवीनतम दूध गुणवत्ता और मिल्किंग रीडिंग देखें।', AppLanguage.marathi: 'नवीनतम दूध गुणवत्ता आणि मिल्किंग रीडिंग तपासा.'},
  'checkHealth': {AppLanguage.english: 'Check health', AppLanguage.hindi: 'स्वास्थ्य देखें', AppLanguage.marathi: 'आरोग्य तपासा'},
  'checkMilk': {AppLanguage.english: 'Check milk', AppLanguage.hindi: 'दूध देखें', AppLanguage.marathi: 'दूध तपासा'},
  'cowIdHint': {AppLanguage.english: 'Cow ID  •  COW_0002', AppLanguage.hindi: 'गाय ID  •  COW_0002', AppLanguage.marathi: 'गाय ID  •  COW_0002'},
  'idFormats': {AppLanguage.english: 'Works with COW_0002, COW-02, or cow0002.', AppLanguage.hindi: 'COW_0002, COW-02 या cow0002 के साथ काम करता है।', AppLanguage.marathi: 'COW_0002, COW-02 किंवा cow0002 सह कार्य करते.'},
  'language': {AppLanguage.english: 'Language', AppLanguage.hindi: 'भाषा', AppLanguage.marathi: 'भाषा'},
  'chooseLanguage': {AppLanguage.english: 'Choose language', AppLanguage.hindi: 'भाषा चुनें', AppLanguage.marathi: 'भाषा निवडा'},
  'alerts': {AppLanguage.english: 'Alerts', AppLanguage.hindi: 'सूचनाएं', AppLanguage.marathi: 'सूचना'},
  'devices': {AppLanguage.english: 'Devices', AppLanguage.hindi: 'डिवाइस', AppLanguage.marathi: 'उपकरणे'},
  'settings': {AppLanguage.english: 'Farm settings', AppLanguage.hindi: 'फार्म सेटिंग्स', AppLanguage.marathi: 'फार्म सेटिंग्ज'},
  'askAssistant': {AppLanguage.english: 'Ask GauSaathi', AppLanguage.hindi: 'गौसाथी से पूछें', AppLanguage.marathi: 'गौसाथीला विचारा'},
};

String tr(AppLanguage language, String key) =>
    _strings[key]?[language] ?? _strings[key]?[AppLanguage.english] ?? key;
