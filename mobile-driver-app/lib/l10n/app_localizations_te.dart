// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'రాహ్‌మిత్ర డ్రైవర్';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get signOut => 'సైన్ అవుట్ చేయి';

  @override
  String get language => 'భాష';

  @override
  String get profile => 'ప్రొఫైల్';

  @override
  String get fullName => 'పూర్తి పేరు';

  @override
  String get noNameSet => 'పేరు సెట్ చేయలేదు';

  @override
  String get nameCannotBeEmpty => 'పేరు ఖాళీగా ఉండకూడదు.';

  @override
  String get couldNotSaveChangesTryAgain =>
      'మార్పులను సేవ్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get signOutQuestion => 'సైన్ అవుట్ చేయాలా?';

  @override
  String get signOutBody => 'కొనసాగించడానికి మీరు మళ్లీ లాగిన్ చేయాలి.';

  @override
  String get chooseVehicleTypeAndNumber =>
      'వాహన రకాన్ని ఎంచుకుని వాహన నంబర్‌ను నమోదు చేయండి.';

  @override
  String get vehicleUpdatedPendingReapproval =>
      'వాహనం నవీకరించబడింది - అడ్మిన్ ద్వారా మళ్లీ ఆమోదం పెండింగ్‌లో ఉంది.';

  @override
  String get vehicleRegistrationNumber => 'వాహన నమోదు సంఖ్య';

  @override
  String get myDocuments => 'నా పత్రాలు';

  @override
  String get bankDetails => 'బ్యాంక్ వివరాలు';

  @override
  String get notifications => 'నోటిఫికేషన్‌లు';

  @override
  String get notificationSettings => 'నోటిఫికేషన్ సెట్టింగ్‌లు';

  @override
  String get changePassword => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get helpAndSupport => 'సహాయం మరియు మద్దతు';

  @override
  String get about => 'యాప్ గురించి';

  @override
  String get raahmitrDriverAppLine => 'రాహ్‌మిత్ర డ్రైవర్ యాప్';

  @override
  String versionNumber(String number) {
    return 'వెర్షన్ $number';
  }

  @override
  String get allFieldsAreRequired => 'అన్ని ఫీల్డ్‌లు అవసరం.';

  @override
  String get bankDetailsSaved => 'బ్యాంక్ వివరాలు సేవ్ చేయబడ్డాయి.';

  @override
  String get couldNotSaveBankDetailsTryAgain =>
      'బ్యాంక్ వివరాలను సేవ్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotLoadYourDetails => 'మీ వివరాలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get usedForWalletPayoutsHint =>
      'వాలెట్ చెల్లింపుల కోసం ఉపయోగించబడుతుంది - ఇది మీ నిజమైన బ్యాంక్ ఖాతాతో సరిపోలుతుందని నిర్ధారించుకోండి.';

  @override
  String get accountHolderName => 'ఖాతాదారు పేరు';

  @override
  String get asPerBankRecordsHint => 'బ్యాంక్ రికార్డుల ప్రకారం';

  @override
  String get accountNumber => 'ఖాతా సంఖ్య';

  @override
  String get ifscCode => 'IFSC కోడ్';

  @override
  String get couldNotLoadNotificationSettings =>
      'నోటిఫికేషన్ సెట్టింగ్‌లను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'నోటిఫికేషన్ ప్రాధాన్యతను నవీకరించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get devicePermission => 'పరికర అనుమతి';

  @override
  String get notificationsAllowedOnDevice =>
      'ఈ పరికరంలో నోటిఫికేషన్‌లు అనుమతించబడ్డాయి.';

  @override
  String get notificationsNotAllowedWarningDriver =>
      'నోటిఫికేషన్‌లు అనుమతించబడలేదు - మీరు వాటిని ప్రారంభించే వరకు జాబ్ అలర్ట్‌లు మరియు ట్రిప్ అప్‌డేట్‌లు మీకు చేరవు.';

  @override
  String get enableNotifications => 'నోటిఫికేషన్‌లను ప్రారంభించండి';

  @override
  String get notificationsBlockedManualEnableHint =>
      'దాన్ని నొక్కినప్పుడు ఏమీ జరగకపోతే, మీ ఫోన్ ఇప్పటికే ఈ యాప్‌ను బ్లాక్ చేసింది - మీ ఫోన్ Settings > Apps > Notifications లో మాన్యువల్‌గా ప్రారంభించండి.';

  @override
  String get pushNotifications => 'పుష్ నోటిఫికేషన్‌లు';

  @override
  String get pushNotificationsDescriptionDriver =>
      'కొత్త జాబ్ అలర్ట్‌లు, ట్రిప్ స్థితి అప్‌డేట్‌లు మరియు చెల్లింపులు.';

  @override
  String get enterCurrentPassword => 'మీ ప్రస్తుత పాస్‌వర్డ్‌ను నమోదు చేయండి.';

  @override
  String get newPasswordMinLength =>
      'కొత్త పాస్‌వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి.';

  @override
  String get newPasswordsDoNotMatch => 'కొత్త పాస్‌వర్డ్‌లు సరిపోలలేదు.';

  @override
  String get passwordUpdated => 'పాస్‌వర్డ్ నవీకరించబడింది';

  @override
  String get currentPasswordIncorrect => 'ప్రస్తుత పాస్‌వర్డ్ తప్పు.';

  @override
  String get couldNotUpdatePassword =>
      'పాస్‌వర్డ్‌ను నవీకరించడం సాధ్యం కాలేదు.';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'పాస్‌వర్డ్‌ను నవీకరించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get currentPassword => 'ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get yourCurrentPasswordHint => 'మీ ప్రస్తుత పాస్‌వర్డ్';

  @override
  String get newPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get min6CharsHint => 'కనీసం 6 అక్షరాలు';

  @override
  String get confirmNewPassword => 'కొత్త పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get reEnterNewPasswordHint => 'కొత్త పాస్‌వర్డ్‌ను మళ్లీ నమోదు చేయండి';

  @override
  String get updatePassword => 'పాస్‌వర్డ్‌ను నవీకరించండి';

  @override
  String get couldNotLoadHelpContent =>
      'సహాయ కంటెంట్‌ను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get needMoreHelp => 'మరింత సహాయం కావాలా?';

  @override
  String get emailSupportAddress => 'ఇమెయిల్ support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'తరచుగా అడిగే ప్రశ్నలు';

  @override
  String get noFaqsAvailable => 'ప్రస్తుతం FAQలు అందుబాటులో లేవు.';
}
