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

  @override
  String get enterYourCompanyName => 'మీ కంపెనీ పేరును నమోదు చేయండి.';

  @override
  String get couldNotCreateFleetAccountTryAgain =>
      'మీ ఫ్లీట్ ఖాతాను సృష్టించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get setUpYourFleet => 'మీ ఫ్లీట్‌ను సెటప్ చేయండి';

  @override
  String get whatsYourCompanyCalled => 'మీ కంపెనీ పేరు ఏమిటి?';

  @override
  String get companyName => 'కంపెనీ పేరు';

  @override
  String get couldNotLoadFleetData => 'ఫ్లీట్ డేటాను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get removeVehicleQuestion => 'వాహనాన్ని తీసివేయాలా?';

  @override
  String removeVehicleConfirm(String vehicleNumber, String driverName) {
    return '$vehicleNumber మీ ఫ్లీట్ నుండి తీసివేయబడుతుంది. $driverName స్వతంత్ర డ్రైవర్‌గా వారి ఖాతాను కలిగి ఉంటారు - ఇది దేనినీ తొలగించదు, మీ ఫ్లీట్ నుండి మాత్రమే వేరు చేస్తుంది.';
  }

  @override
  String get remove => 'తీసివేయండి';

  @override
  String get theDriverFallback => 'డ్రైవర్';

  @override
  String get couldNotRemoveThatVehicle =>
      'ఆ వాహనాన్ని తీసివేయడం సాధ్యం కాలేదు.';

  @override
  String get fleet => 'ఫ్లీట్';

  @override
  String get notificationSettingsMenuItem => 'నోటిఫికేషన్ సెట్టింగ్‌లు';

  @override
  String get changePasswordMenuItem => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get addVehicle => 'వాహనాన్ని జోడించండి';

  @override
  String get vehiclesLabel => 'వాహనాలు';

  @override
  String approvedCount(int count) {
    return '$count ఆమోదించబడింది';
  }

  @override
  String get activeNow => 'ఇప్పుడు యాక్టివ్‌గా ఉంది';

  @override
  String liveOrdersCount(int count) {
    return '$count లైవ్ ఆర్డర్‌లు';
  }

  @override
  String get totalEarnings => 'మొత్తం సంపాదన';

  @override
  String get yourVehicles => 'మీ వాహనాలు';

  @override
  String get noVehiclesYetTapAddVehicle =>
      'ఇంకా వాహనాలు లేవు - మీ మొదటి వాహనాన్ని నమోదు చేయడానికి \"వాహనాన్ని జోడించండి\" నొక్కండి.';

  @override
  String get unassigned => 'కేటాయించబడలేదు';

  @override
  String vehicleSummaryLine(String driverName, String trips, String earnings,
      String docsUploaded, String docsTotal) {
    return '$driverName · $trips ట్రిప్‌లు · ₹$earnings · KYC పత్రాలు $docsUploaded/$docsTotal';
  }

  @override
  String get online => 'ఆన్‌లైన్';

  @override
  String get offline => 'ఆఫ్‌లైన్';

  @override
  String get pending => 'పెండింగ్‌లో';

  @override
  String get removeFromFleet => 'ఫ్లీట్ నుండి తీసివేయండి';

  @override
  String get fillAllFieldsValidPhone =>
      'చెల్లుబాటు అయ్యే 10-అంకెల ఫోన్ నంబర్‌తో అన్ని ఫీల్డ్‌లను పూరించండి.';

  @override
  String get vehicleAdded => 'వాహనం జోడించబడింది';

  @override
  String driverStillNeedsSelfie(String driverName) {
    return 'ఈ వాహనం ఆమోదించబడటానికి ముందు $driverName తమ సొంత ఫోన్‌లో సైన్ ఇన్ చేసి వారి KYC సెల్ఫీని పూర్తి చేయాలి - ఆ దశ ఇక్కడ నుండి చేయలేము.';
  }

  @override
  String get gotIt => 'అర్థమైంది';

  @override
  String get couldNotAddVehiclePhoneMayExist =>
      'ఈ వాహనాన్ని జోడించడం సాధ్యం కాలేదు. ఫోన్ నంబర్ ఇప్పటికే వేరే పాత్రలో నమోదు చేయబడి ఉండవచ్చు.';

  @override
  String get driverDetails => 'డ్రైవర్ వివరాలు';

  @override
  String get driversName => 'డ్రైవర్ పేరు';

  @override
  String get driversPhoneNumber => 'డ్రైవర్ ఫోన్ నంబర్';

  @override
  String get driversLicenseNumber => 'డ్రైవర్ లైసెన్స్ నంబర్';

  @override
  String couldNotLoadYourProfile(String error) {
    return 'మీ ప్రొఫైల్‌ను లోడ్ చేయడం సాధ్యం కాలేదు.\n$error';
  }

  @override
  String heyName(String name) {
    return 'నమస్తే $name';
  }

  @override
  String get thereFallbackName => 'మిత్రమా';

  @override
  String get onlineReadyForJobs => 'ఆన్‌లైన్‌లో - జాబ్‌ల కోసం సిద్ధంగా ఉంది';

  @override
  String get searchTripsWaybillHint => 'ట్రిప్‌లు, వేబిల్ నంబర్‌ను శోధించండి';

  @override
  String get tripInProgress => 'ట్రిప్ జరుగుతోంది';

  @override
  String get viewJobRequests => 'జాబ్ అభ్యర్థనలను వీక్షించండి';

  @override
  String get tapToResumeTracking =>
      'ట్రాకింగ్‌ను తిరిగి ప్రారంభించడానికి నొక్కండి';

  @override
  String get browseBookingsNearYou => 'మీ సమీపంలోని బుకింగ్‌లను బ్రౌజ్ చేయండి';

  @override
  String get searchResults => 'శోధన ఫలితాలు';

  @override
  String get recentTrips => 'ఇటీవలి ట్రిప్‌లు';

  @override
  String get viewAll => 'అన్నీ వీక్షించండి';

  @override
  String noTripsMatch(String query) {
    return '\"$query\"కి సరిపోలే ట్రిప్‌లు లేవు.';
  }

  @override
  String get noTripsYet => 'ఇంకా ట్రిప్‌లు లేవు.';

  @override
  String get pendingApproval => 'ఆమోదం పెండింగ్‌లో ఉంది';

  @override
  String get verifyingVehicleDetails =>
      'మేము మీ వాహన వివరాలను ధృవీకరిస్తున్నాము. అడ్మిన్ మీ ఖాతాను ఆమోదించిన తర్వాత మీరు ఆన్‌లైన్‌కి వెళ్లగలరు.';

  @override
  String get uploadRemainingDocuments => 'మిగిలిన పత్రాలను అప్‌లోడ్ చేయండి';

  @override
  String get checkStatus => 'స్థితిని తనిఖీ చేయండి';

  @override
  String get stillPendingApprovalCheckBack =>
      'ఇంకా ఆమోదం పెండింగ్‌లో ఉంది - త్వరలో మళ్లీ తనిఖీ చేయండి.';

  @override
  String get enterValidEmail =>
      'చెల్లుబాటు అయ్యే ఇమెయిల్ చిరునామాను నమోదు చేయండి.';

  @override
  String get enterYourPassword => 'మీ పాస్‌వర్డ్‌ను నమోదు చేయండి.';

  @override
  String get couldNotLogInTryAgain =>
      'లాగిన్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get passwordMinLength => 'పాస్‌వర్డ్ కనీసం 6 అక్షరాలు ఉండాలి.';

  @override
  String get passwordsDoNotMatch => 'పాస్‌వర్డ్‌లు సరిపోలలేదు.';

  @override
  String get couldNotCreateAccountTryAgain =>
      'మీ ఖాతాను సృష్టించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get notVerifiedYetTapLink =>
      'ఇంకా ధృవీకరించబడలేదు - మేము పంపిన ఇమెయిల్‌లోని లింక్‌ను నొక్కండి.';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'ధృవీకరణ స్థితిని తనిఖీ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotResendEmailTryAgain =>
      'ఇమెయిల్‌ను మళ్లీ పంపడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotSendCodeTryAgain =>
      'కోడ్‌ను పంపడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterSixDigitCode => '6-అంకెల కోడ్‌ను నమోదు చేయండి.';

  @override
  String get incorrectOrExpiredCode => 'తప్పు లేదా గడువు ముగిసిన కోడ్.';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'ఆ కోడ్‌ను ధృవీకరించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterFullName => 'మీ పూర్తి పేరును నమోదు చేయండి.';

  @override
  String get enterValidPhoneNumber10Digit =>
      'చెల్లుబాటు అయ్యే 10-అంకెల ఫోన్ నంబర్‌ను నమోదు చేయండి.';

  @override
  String get selectYourDob => 'మీ పుట్టిన తేదీని ఎంచుకోండి.';

  @override
  String get couldNotSaveDetailsTryAgain =>
      'మీ వివరాలను సేవ్ చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterEmailFirstThenForgot =>
      'ముందుగా పైన మీ ఇమెయిల్‌ను నమోదు చేయండి, తర్వాత \"పాస్‌వర్డ్ మర్చిపోయారా?\" నొక్కండి.';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'పాస్‌వర్డ్ రీసెట్ లింక్ $emailకి పంపబడింది';
  }

  @override
  String get enterValidMobileNumber =>
      'చెల్లుబాటు అయ్యే 10-అంకెల మొబైల్ నంబర్‌ను నమోదు చేయండి.';

  @override
  String get accountExistsForEmailTryLogin =>
      'ఆ ఇమెయిల్ కోసం ఇప్పటికే ఖాతా ఉంది. బదులుగా లాగిన్ చేయడానికి ప్రయత్నించండి.';

  @override
  String get emailLooksInvalid =>
      'ఆ ఇమెయిల్ చిరునామా చెల్లనిదిగా కనిపిస్తోంది.';

  @override
  String get chooseStrongerPassword => 'బలమైన పాస్‌వర్డ్‌ను ఎంచుకోండి.';

  @override
  String get incorrectEmailOrPassword => 'తప్పు ఇమెయిల్ లేదా పాస్‌వర్డ్.';

  @override
  String get tooManyAttemptsTryAgain =>
      'చాలా ఎక్కువ ప్రయత్నాలు. కొద్దిసేపటి తర్వాత మళ్లీ ప్రయత్నించండి.';

  @override
  String get phoneNumberLooksInvalid =>
      'ఆ ఫోన్ నంబర్ చెల్లనిదిగా కనిపిస్తోంది.';

  @override
  String get codeExpiredRequestNew =>
      'ఆ కోడ్ గడువు ముగిసింది - కొత్తదాన్ని అభ్యర్థించండి.';

  @override
  String get somethingWentWrongTryAgain =>
      'ఏదో తప్పు జరిగింది. మళ్లీ ప్రయత్నించండి.';

  @override
  String get verifyYourNumber => 'మీ నంబర్‌ను ధృవీకరించండి';

  @override
  String get welcomeExclaim => 'స్వాగతం!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'మేము +91 $phoneకి 6-అంకెల కోడ్‌ను పంపాము';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'మీ మొబైల్ నంబర్‌తో లాగిన్ చేయండి లేదా సైన్ అప్ చేయండి';

  @override
  String get welcomeBack => 'మళ్లీ స్వాగతం!';

  @override
  String get createAccount => 'ఖాతాను సృష్టించండి';

  @override
  String get verifyYourEmail => 'మీ ఇమెయిల్‌ను ధృవీకరించండి';

  @override
  String get tellUsAboutYourself => 'మీ గురించి మాకు చెప్పండి';

  @override
  String get logInWithEmailToContinue =>
      'కొనసాగించడానికి మీ ఇమెయిల్‌తో లాగిన్ చేయండి';

  @override
  String get signUpWithEmailToGetStarted =>
      'ప్రారంభించడానికి మీ ఇమెయిల్‌తో సైన్ అప్ చేయండి';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'మేము $emailకి ధృవీకరణ లింక్‌ను పంపాము';
  }

  @override
  String get thisHelpsCustomersSupportIdentifyYou =>
      'ఇది కస్టమర్‌లు మరియు సపోర్ట్ టీమ్ మిమ్మల్ని గుర్తించడంలో సహాయపడుతుంది.';

  @override
  String get emailLabel => 'ఇమెయిల్';

  @override
  String get emailExampleHint => 'you@example.com';

  @override
  String get passwordLabel => 'పాస్‌వర్డ్';

  @override
  String get yourPasswordHint => 'మీ పాస్‌వర్డ్';

  @override
  String get forgotPassword => 'పాస్‌వర్డ్ మర్చిపోయారా?';

  @override
  String get logIn => 'లాగిన్ చేయండి';

  @override
  String get dontHaveAccountSignUp => 'ఖాతా లేదా? సైన్ అప్ చేయండి';

  @override
  String get emailMethod => 'ఇమెయిల్';

  @override
  String get phoneMethod => 'ఫోన్';

  @override
  String get verificationCode => 'ధృవీకరణ కోడ్';

  @override
  String get sixDigitCodeHint => '6-అంకెల కోడ్';

  @override
  String get verifyAndContinue => 'ధృవీకరించి కొనసాగించండి';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds సెకన్లలో కోడ్‌ను మళ్లీ పంపండి';
  }

  @override
  String get resendCode => 'కోడ్‌ను మళ్లీ పంపండి';

  @override
  String get phoneNumberLabel => 'ఫోన్ నంబర్';

  @override
  String get phoneNumberSampleHint => '98765 43210';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get min6CharsHintPassword => 'కనీసం 6 అక్షరాలు';

  @override
  String get confirmPasswordLabel => 'పాస్‌వర్డ్‌ను నిర్ధారించండి';

  @override
  String get reEnterPasswordHint => 'పాస్‌వర్డ్‌ను మళ్లీ నమోదు చేయండి';

  @override
  String get signUp => 'సైన్ అప్ చేయండి';

  @override
  String get alreadyHaveAccountLogIn => 'ఇప్పటికే ఖాతా ఉందా? లాగిన్ చేయండి';

  @override
  String get sendCode => 'కోడ్‌ను పంపండి';

  @override
  String get verifyCode => 'కోడ్‌ను ధృవీకరించండి';

  @override
  String get useLinkInstead => 'బదులుగా లింక్‌ను ఉపయోగించండి';

  @override
  String get iveVerifiedMyEmail => 'నేను నా ఇమెయిల్‌ను ధృవీకరించాను';

  @override
  String get verificationEmailSentAgain => 'ధృవీకరణ ఇమెయిల్ మళ్లీ పంపబడింది';

  @override
  String get resendVerificationEmail => 'ధృవీకరణ ఇమెయిల్‌ను మళ్లీ పంపండి';

  @override
  String get enterCodeInstead => 'బదులుగా కోడ్‌ను నమోదు చేయండి';

  @override
  String get fullNameLabel => 'పూర్తి పేరు';

  @override
  String get yourNameHint => 'మీ పేరు';

  @override
  String get dateOfBirth => 'పుట్టిన తేదీ';

  @override
  String get selectYourDateOfBirth => 'మీ పుట్టిన తేదీని ఎంచుకోండి';
}
