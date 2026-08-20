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

  @override
  String get accountNotRegisteredAsDriver =>
      'ఈ ఖాతా డ్రైవర్‌గా నమోదు కాలేదు. సైన్ అవుట్ చేసి డ్రైవర్ ఖాతాతో లాగిన్ చేయండి.';

  @override
  String get couldNotReachServerCheckConnection =>
      'సర్వర్‌ను చేరుకోవడం సాధ్యం కాలేదు. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get retry => 'మళ్లీ ప్రయత్నించండి';

  @override
  String get signOutAndLogInAgain => 'సైన్ అవుట్ చేసి మళ్లీ లాగిన్ చేయండి';

  @override
  String get howWillYouUseTheApp => 'మీరు యాప్‌ను ఎలా ఉపయోగిస్తారు?';

  @override
  String get iDriveMyOwnVehicle => 'నేను నా స్వంత వాహనం నడుపుతాను';

  @override
  String get acceptJobsEarnPerTrip =>
      'జాబ్‌లను అంగీకరించి ప్రతి ట్రిప్‌కు సంపాదించండి';

  @override
  String get iManageAFleet => 'నేను ఒక ఫ్లీట్‌ను నిర్వహిస్తాను';

  @override
  String get multipleVehiclesAndDrivers => 'బహుళ వాహనాలు మరియు డ్రైవర్లు';

  @override
  String get pressBackAgainToExit => 'నిష్క్రమించడానికి మళ్లీ బ్యాక్ నొక్కండి';

  @override
  String get view => 'వీక్షించండి';

  @override
  String get home => 'హోమ్';

  @override
  String get jobs => 'జాబ్‌లు';

  @override
  String get history => 'చరిత్ర';

  @override
  String get earnings => 'సంపాదన';

  @override
  String get couldNotLoadNotifications =>
      'నోటిఫికేషన్‌లను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get markAllRead => 'అన్నింటినీ చదివినట్లు గుర్తు పెట్టండి';

  @override
  String get allCaughtUpNothingHereYet =>
      'మీరు పూర్తిగా అప్‌డేట్‌గా ఉన్నారు - ఇక్కడ ఇంకా ఏమీ లేదు.';

  @override
  String couldNotUploadDocumentTryAgain(String label) {
    return '$label అప్‌లోడ్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';
  }

  @override
  String get takeAPhoto => 'ఫోటో తీయండి';

  @override
  String get chooseFromGallery => 'గ్యాలరీ నుండి ఎంచుకోండి';

  @override
  String get documents => 'పత్రాలు';

  @override
  String couldNotLoadDocuments(String error) {
    return 'పత్రాలను లోడ్ చేయడం సాధ్యం కాలేదు.\n$error';
  }

  @override
  String get completeVehicleSetupFirst =>
      'ముందుగా వాహన సెటప్‌ను పూర్తి చేయండి.';

  @override
  String get uploaded => 'అప్‌లోడ్ చేయబడింది';

  @override
  String get requiredNotUploaded => 'అవసరం - అప్‌లోడ్ చేయలేదు';

  @override
  String get optionalNotUploaded => 'ఐచ్ఛికం - అప్‌లోడ్ చేయలేదు';

  @override
  String get retake => 'మళ్లీ తీయండి';

  @override
  String get upload => 'అప్‌లోడ్ చేయండి';

  @override
  String get docLabelPhotoId => 'ఫోటో ఐడి (సెల్ఫీ)';

  @override
  String get docLabelLicenseFront => 'డ్రైవింగ్ లైసెన్స్ (ముందు)';

  @override
  String get docLabelLicenseBack => 'డ్రైవింగ్ లైసెన్స్ (వెనుక)';

  @override
  String get docLabelRcFront => 'వాహన RC (ముందు)';

  @override
  String get docLabelRcBack => 'వాహన RC (వెనుక)';

  @override
  String get docLabelAadhaarFront => 'ఆధార్ కార్డ్ (ముందు)';

  @override
  String get docLabelAadhaarBack => 'ఆధార్ కార్డ్ (వెనుక)';

  @override
  String get docLabelInsurance => 'బీమా';

  @override
  String get docLabelPermit => 'పర్మిట్';

  @override
  String get docLabelPollution => 'కాలుష్య ధృవీకరణ పత్రం';

  @override
  String get docLabelPan => 'PAN కార్డ్';

  @override
  String get docLabelCheque => 'రద్దు చేసిన చెక్';

  @override
  String get couldNotLoadEarnings => 'సంపాదనను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get totalLifetimeEarnings => 'మొత్తం జీవితకాల సంపాదన';

  @override
  String tripsCompleted(int count) {
    return '$count ట్రిప్‌లు పూర్తయ్యాయి';
  }

  @override
  String get thisWeek => 'ఈ వారం';

  @override
  String get thisMonth => 'ఈ నెల';

  @override
  String get walletBalance => 'వాలెట్ బ్యాలెన్స్';

  @override
  String get recentActivity => 'ఇటీవలి కార్యకలాపం';

  @override
  String get walletTxnTripFare => 'ట్రిప్ చార్జీ';

  @override
  String get walletTxnCancellationCompensation => 'రద్దు పరిహారం';

  @override
  String get walletTxnPayout => 'చెల్లింపు';

  @override
  String get walletTxnAdjustment => 'సర్దుబాటు';

  @override
  String tripsCount(int count) {
    return '$count ట్రిప్‌లు';
  }

  @override
  String get couldNotLoadMessages => 'సందేశాలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get notConnectedCouldNotSendMessage =>
      'కనెక్ట్ కాలేదు - ఆ సందేశాన్ని పంపడం సాధ్యం కాలేదు. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get chatWithCustomer => 'కస్టమర్‌తో చాట్ చేయండి';

  @override
  String get sayHelloToYourCustomer => 'మీ కస్టమర్‌కు హలో చెప్పండి.';

  @override
  String get typeAMessageHint => 'సందేశాన్ని టైప్ చేయండి…';

  @override
  String get statusPending => 'పెండింగ్‌లో';

  @override
  String get statusAccepted => 'ఆమోదించబడింది';

  @override
  String get statusInTransit => 'రవాణాలో ఉంది';

  @override
  String get statusAwaitingPayment => 'చెల్లింపు కోసం వేచి ఉంది';

  @override
  String get statusDelivered => 'డెలివరీ అయింది';

  @override
  String get statusCancelled => 'రద్దు చేయబడింది';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get filterActive => 'యాక్టివ్';

  @override
  String get couldNotLoadTripHistory =>
      'ట్రిప్ చరిత్రను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get noTripsHereYet => 'ఇక్కడ ఇంకా ట్రిప్‌లు లేవు.';

  @override
  String get tripHistory => 'ట్రిప్ చరిత్ర';

  @override
  String get customerFallback => 'కస్టమర్';

  @override
  String get fillInAllFields => 'అన్ని ఫీల్డ్‌లను పూరించండి.';

  @override
  String get phoneAlreadyRegisteredDifferentRole =>
      'ఈ ఫోన్ నంబర్ ఇప్పటికే వేరే పాత్రలో నమోదు చేయబడింది (ఉదా. కస్టమర్‌గా). సైన్ అవుట్ చేసి డ్రైవర్‌గా సైన్ అప్ చేయడానికి వేరే ఫోన్ నంబర్‌ను ఉపయోగించండి.';

  @override
  String get enterpriseCodeNotValid =>
      'ఆ ఎంటర్‌ప్రైజ్ కోడ్ చెల్లదు. మీ కంపెనీతో తనిఖీ చేయండి, లేదా స్వతంత్రంగా నడపడానికి దీన్ని ఖాళీగా వదలండి.';

  @override
  String get couldNotSubmitDetailsTryAgain =>
      'మీ వివరాలను సమర్పించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get takeSelfieRequired =>
      'కొనసాగించడానికి సెల్ఫీ తీయండి - గుర్తింపు ధృవీకరణ కోసం ఇది అవసరం.';

  @override
  String get couldNotUploadSelfieTryAgain =>
      'మీ సెల్ఫీని అప్‌లోడ్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get vehicleDetails => 'వాహన వివరాలు';

  @override
  String get tellUsAboutYourVehicle =>
      'ప్రారంభించడానికి మీ వాహనం గురించి మాకు చెప్పండి.';

  @override
  String get vehicleRegistrationNumberHint => 'ఉదా. DL 01 AB 1234';

  @override
  String get drivingLicenseNumber => 'డ్రైవింగ్ లైసెన్స్ నంబర్';

  @override
  String get enterpriseInviteCodeOptional =>
      'ఎంటర్‌ప్రైజ్ ఆహ్వాన కోడ్ (ఐచ్ఛికం)';

  @override
  String get enterpriseInviteCodeHint =>
      'ఉదా. ENT-A1B2C3D4 - ఒక కంపెనీ మీకు ఇచ్చినట్లయితే మాత్రమే';

  @override
  String get continueLabel => 'కొనసాగించండి';

  @override
  String get verifyYourIdentity => 'మీ గుర్తింపును ధృవీకరించండి';

  @override
  String get selfieInstructions =>
      'మంచి వెలుతురులో స్పష్టమైన సెల్ఫీ తీయండి. మీ ఖాతాను ఆమోదించే ముందు అడ్మిన్ మీ పత్రాలతో పాటు దీన్ని సమీక్షిస్తారు.';

  @override
  String get takeSelfie => 'సెల్ఫీ తీయండి';

  @override
  String get submitForApproval => 'ఆమోదం కోసం సమర్పించండి';

  @override
  String get jobRequests => 'జాబ్ అభ్యర్థనలు';

  @override
  String get couldNotLoadJobRequests =>
      'జాబ్ అభ్యర్థనలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get jobNoLongerAvailable => 'ఈ జాబ్ ఇకపై అందుబాటులో లేదు.';

  @override
  String get noJobsAvailablePullToRefresh =>
      'ప్రస్తుతం జాబ్‌లు అందుబాటులో లేవు. రిఫ్రెష్ చేయడానికి లాగండి.';

  @override
  String get cargoFallback => 'సరుకు';

  @override
  String get pass => 'పాస్';

  @override
  String get accept => 'అంగీకరించండి';

  @override
  String get jobDetails => 'జాబ్ వివరాలు';

  @override
  String codCollectAtDropOff(String amount) {
    return 'డెలివరీ వద్ద నగదు - డ్రాప్-ఆఫ్ వద్ద ₹$amount వసూలు చేయాలి';
  }

  @override
  String onlineAdvancePaidRemainderNearDelivery(String amount) {
    return 'ఆన్‌లైన్ - ₹$amount అడ్వాన్స్ చెల్లించబడింది, మిగిలినది డెలివరీ సమయంలో ఆన్‌లైన్‌లో వసూలు చేయబడుతుంది';
  }

  @override
  String get goodsLabel => 'సరుకు';

  @override
  String get weightLabel => 'బరువు';

  @override
  String get distanceLabel => 'దూరం';

  @override
  String get customerLabel => 'కస్టమర్';
}
