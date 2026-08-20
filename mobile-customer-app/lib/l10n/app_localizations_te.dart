// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Telugu (`te`).
class AppLocalizationsTe extends AppLocalizations {
  AppLocalizationsTe([String locale = 'te']) : super(locale);

  @override
  String get appTitle => 'రాహ్‌మిత్ర';

  @override
  String get cancel => 'రద్దు చేయి';

  @override
  String get save => 'సేవ్ చేయి';

  @override
  String get signOut => 'సైన్ అవుట్ చేయి';

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
  String get personalInformation => 'వ్యక్తిగత సమాచారం';

  @override
  String get addresses => 'చిరునామాలు';

  @override
  String get paymentMethods => 'చెల్లింపు పద్ధతులు';

  @override
  String get notifications => 'నోటిఫికేషన్‌లు';

  @override
  String get notificationSettings => 'నోటిఫికేషన్ సెట్టింగ్‌లు';

  @override
  String get language => 'భాష';

  @override
  String get changePassword => 'పాస్‌వర్డ్ మార్చండి';

  @override
  String get helpAndSupport => 'సహాయం మరియు మద్దతు';

  @override
  String get about => 'యాప్ గురించి';

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
  String get emailAddress => 'ఇమెయిల్ చిరునామా';

  @override
  String get password => 'పాస్‌వర్డ్';

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
  String get sixDigitCode => '6-అంకెల కోడ్';

  @override
  String get verifyAndContinue => 'ధృవీకరించి కొనసాగించండి';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds సెకన్లలో కోడ్‌ను మళ్లీ పంపండి';
  }

  @override
  String get resendCode => 'కోడ్‌ను మళ్లీ పంపండి';

  @override
  String get tenDigitMobileNumber => '10-అంకెల మొబైల్ నంబర్';

  @override
  String get sendOtp => 'OTP పంపండి';

  @override
  String get passwordMinCharsHint => 'పాస్‌వర్డ్ (కనీసం 6 అక్షరాలు)';

  @override
  String get confirmPassword => 'పాస్‌వర్డ్‌ను నిర్ధారించండి';

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
  String get onboardingTitle1 => 'సులభమైన షిప్పింగ్,\nస్మార్ట్ వ్యాపారం';

  @override
  String get onboardingBody1 =>
      'స్మార్ట్ షిప్పింగ్ సమయాన్ని ఆదా చేస్తుంది, ఖర్చులను తగ్గిస్తుంది\nమరియు వ్యాపారాలను వేగంగా పెంచుతుంది.';

  @override
  String get onboardingTitle2 => 'లైవ్‌గా ట్రాక్ చేయండి,\nతలుపు వరకు';

  @override
  String get onboardingBody2 =>
      'మ్యాప్‌లో మీ డ్రైవర్ సమీపిస్తున్నట్లు చూడండి\nరియల్-టైమ్ ETA అప్‌డేట్‌లతో.';

  @override
  String get onboardingTitle3 => 'మీ ఇష్టప్రకారం చెల్లించండి,\nప్రతిసారీ';

  @override
  String get onboardingBody3 =>
      'UPI, కార్డులు, నెట్ బ్యాంకింగ్ లేదా వాలెట్ -\nమీ ఎంపిక, ప్రతి బుకింగ్‌లో.';

  @override
  String get getStarted => 'ప్రారంభించండి';

  @override
  String get next => 'తదుపరి';

  @override
  String get pressBackAgainToExit => 'నిష్క్రమించడానికి మళ్లీ బ్యాక్ నొక్కండి';

  @override
  String get view => 'వీక్షించండి';

  @override
  String get home => 'హోమ్';

  @override
  String get orders => 'ఆర్డర్‌లు';

  @override
  String get couldNotLoadYourBookings =>
      'మీ బుకింగ్‌లను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String heyNameWave(String name) {
    return 'నమస్తే $name 👋';
  }

  @override
  String get thereFallbackName => 'మిత్రమా';

  @override
  String get whereAreWeShippingToday => 'ఈరోజు మనం ఎక్కడ షిప్ చేస్తున్నాము?';

  @override
  String get searchShipmentsHint =>
      'వేబిల్ లేదా చిరునామా ద్వారా షిప్‌మెంట్‌లను శోధించండి';

  @override
  String get bookNewShipment => 'కొత్త షిప్‌మెంట్‌ను బుక్ చేయండి';

  @override
  String get getInstantPriceBookDelivery =>
      'తక్షణ ధరను పొందండి మరియు మీ డెలివరీని బుక్ చేయండి';

  @override
  String get priceCalculator => 'ధర కాలిక్యులేటర్';

  @override
  String get myOrders => 'నా ఆర్డర్‌లు';

  @override
  String get support => 'మద్దతు';

  @override
  String get searchResults => 'శోధన ఫలితాలు';

  @override
  String get recentOrders => 'ఇటీవలి ఆర్డర్‌లు';

  @override
  String get viewAll => 'అన్నీ వీక్షించండి';

  @override
  String noShipmentsMatch(String query) {
    return '\"$query\"కి సరిపోలే షిప్‌మెంట్‌లు లేవు.';
  }

  @override
  String get noBookingsYetTapAway =>
      'ఇంకా బుకింగ్‌లు లేవు - మీ మొదటిది ఒక్క నొక్కు దూరంలో ఉంది.';

  @override
  String get statusPaymentPending => 'చెల్లింపు పెండింగ్‌లో ఉంది';

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
  String get raahmitrCustomerAppLine => 'రాహ్‌మిత్ర కస్టమర్ యాప్';

  @override
  String versionNumber(String number) {
    return 'వెర్షన్ $number';
  }

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
  String get notificationsNotAllowedWarning =>
      'నోటిఫికేషన్‌లు అనుమతించబడలేదు - మీరు వాటిని ప్రారంభించే వరకు బుకింగ్ మరియు డెలివరీ అప్‌డేట్‌లు మీకు చేరవు.';

  @override
  String get enableNotifications => 'నోటిఫికేషన్‌లను ప్రారంభించండి';

  @override
  String get notificationsBlockedManualEnableHint =>
      'దాన్ని నొక్కినప్పుడు ఏమీ జరగకపోతే, మీ ఫోన్ ఇప్పటికే ఈ యాప్‌ను బ్లాక్ చేసింది - మీ ఫోన్ Settings > Apps > Notifications లో మాన్యువల్‌గా ప్రారంభించండి.';

  @override
  String get pushNotifications => 'పుష్ నోటిఫికేషన్‌లు';

  @override
  String get pushNotificationsDescription =>
      'బుకింగ్ అప్‌డేట్‌లు, డ్రైవర్ కేటాయింపు మరియు డెలివరీ నిర్ధారణలు.';

  @override
  String get saved => 'సేవ్ చేయబడింది.';

  @override
  String get email => 'ఇమెయిల్';

  @override
  String get phone => 'ఫోన్';

  @override
  String get businessGstinOptional => 'వ్యాపార GSTIN (ఐచ్ఛికం)';

  @override
  String get usedOnInvoicesIfAny =>
      'మీ వద్ద ఉంటే, ఇది మీ బుకింగ్ ఇన్‌వాయిస్‌లపై ఉపయోగించబడుతుంది.';

  @override
  String get saveChanges => 'మార్పులను సేవ్ చేయండి';

  @override
  String get couldNotLoadYourAddresses =>
      'మీ చిరునామాలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get addAddress => 'చిరునామాను జోడించండి';

  @override
  String get editAddress => 'చిరునామాను సవరించండి';

  @override
  String get labelHint => 'లేబుల్ (ఉదా. ఇల్లు, కార్యాలయం)';

  @override
  String get fullAddress => 'పూర్తి చిరునామా';

  @override
  String get couldNotSaveThisAddress =>
      'ఈ చిరునామాను సేవ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get couldNotRemoveThisAddress =>
      'ఈ చిరునామాను తీసివేయడం సాధ్యం కాలేదు.';

  @override
  String get noSavedAddressesYet =>
      'ఇంకా సేవ్ చేసిన చిరునామాలు లేవు - ఒకటి జోడించడానికి + నొక్కండి.';

  @override
  String get edit => 'సవరించండి';

  @override
  String get delete => 'తొలగించండి';

  @override
  String get couldNotLoadPaymentHistory =>
      'చెల్లింపు చరిత్రను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get removeCardQuestion => 'కార్డును తీసివేయాలా?';

  @override
  String removeCardConfirm(String network, String last4) {
    return '$last4తో ముగిసే $network కార్డును తీసివేయాలా?';
  }

  @override
  String get remove => 'తీసివేయండి';

  @override
  String get couldNotRemoveThatCard => 'ఆ కార్డును తీసివేయడం సాధ్యం కాలేదు.';

  @override
  String get savedCards => 'సేవ్ చేసిన కార్డులు';

  @override
  String get noSavedCardsYet =>
      'ఇంకా సేవ్ చేసిన కార్డులు లేవు - మీ తదుపరి చెల్లింపు సమయంలో \"ఈ కార్డును సేవ్ చేయి\" ఎంచుకోండి.';

  @override
  String get transactionHistory => 'లావాదేవీల చరిత్ర';

  @override
  String get noPaymentsYet => 'ఇంకా చెల్లింపులు లేవు.';

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
  String get newPassword => 'కొత్త పాస్‌వర్డ్';

  @override
  String get confirmNewPassword => 'కొత్త పాస్‌వర్డ్‌ను నిర్ధారించండి';

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
  String get turnOnLocationServices =>
      'మీ ప్రస్తుత స్థానాన్ని ఉపయోగించడానికి లొకేషన్ సేవలను ఆన్ చేయండి.';

  @override
  String get locationPermissionRequired =>
      'మీ ప్రస్తుత స్థానాన్ని ఉపయోగించడానికి లొకేషన్ అనుమతి అవసరం.';

  @override
  String get couldNotDetermineAddressTryAgain =>
      'మీ చిరునామాను నిర్ధారించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotGetCurrentLocationTryAgain =>
      'మీ ప్రస్తుత స్థానాన్ని పొందడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get enterBothPickupAndDrop =>
      'పికప్ మరియు డ్రాప్ రెండు స్థానాలను నమోదు చేయండి.';

  @override
  String get pickupDropCannotBeSame =>
      'పికప్ మరియు డ్రాప్ ఒకే ప్రదేశంగా ఉండకూడదు.';

  @override
  String get couldNotVerifyAddressPickSuggestion =>
      'ఈ చిరునామాలలో ఒకదాన్ని ధృవీకరించడం సాధ్యం కాలేదు. జాబితా నుండి సూచనను ఎంచుకోండి, లేదా పికప్ కోసం ప్రస్తుత స్థానాన్ని ఉపయోగించండి.';

  @override
  String get whereTo => 'ఎక్కడికి?';

  @override
  String get pickupLocation => 'పికప్ స్థానం';

  @override
  String get dropLocation => 'డ్రాప్ స్థానం';

  @override
  String get continueLabel => 'కొనసాగించండి';

  @override
  String get bookingConfirmed => 'బుకింగ్ నిర్ధారించబడింది!';

  @override
  String get shipmentBookedSuccessfully =>
      'మీ షిప్‌మెంట్ విజయవంతంగా బుక్ చేయబడింది.';

  @override
  String get estimatedPrice => 'అంచనా ధర';

  @override
  String payAdvanceNowCashAtDelivery(String advance, String remaining) {
    return 'ఇప్పుడు ₹$advance మరియు డెలివరీ వద్ద నగదులో ₹$remaining చెల్లించండి';
  }

  @override
  String payCashAtDeliveryNoAdvance(String amount) {
    return 'డెలివరీ వద్ద నగదులో ₹$amount చెల్లించండి - అడ్వాన్స్ అవసరం లేదు';
  }

  @override
  String payAdvanceNowRemainingOnlineNearDelivery(
      String advance, String remaining) {
    return 'ఇప్పుడు ₹$advance చెల్లించండి, మిగిలిన ₹$remaining డెలివరీ సమయంలో ఆన్‌లైన్‌లో చెల్లించాలి';
  }

  @override
  String get trackShipment => 'షిప్‌మెంట్‌ను ట్రాక్ చేయండి';

  @override
  String get trackShipmentAvailableOnceAdvanceConfirmed =>
      'మీ అడ్వాన్స్ చెల్లింపు నిర్ధారించబడిన తర్వాత షిప్‌మెంట్ ట్రాకింగ్ అందుబాటులో ఉంటుంది.';

  @override
  String get backToHome => 'హోమ్‌కు తిరిగి వెళ్ళండి';

  @override
  String get bodyTypeBike => 'బైక్';

  @override
  String get bodyTypeAuto => 'ఆటో';

  @override
  String get bodyTypeOpen => 'ఓపెన్';

  @override
  String get bodyTypeContainer => 'కంటైనర్';

  @override
  String get bodyTypeTrailer => 'ట్రైలర్';

  @override
  String get filterByCargoWeight => 'కార్గో బరువు ద్వారా ఫిల్టర్ చేయండి';

  @override
  String get weightKgFieldLabel => 'బరువు (కేజీ)';

  @override
  String get weightFilterChipLabel => 'బరువు';

  @override
  String weightKgChipValue(String weight) {
    return '$weight కేజీ';
  }

  @override
  String get clear => 'క్లియర్ చేయండి';

  @override
  String get apply => 'వర్తింపజేయండి';

  @override
  String get selectVehicle => 'వాహనాన్ని ఎంచుకోండి';

  @override
  String get couldNotLoadVehicleTypes =>
      'వాహన రకాలను లోడ్ చేయడం సాధ్యం కాలేదు. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get noVehicleTypesAvailable => 'ప్రస్తుతం వాహన రకాలు అందుబాటులో లేవు.';

  @override
  String get noVehiclesMatchThisWeight =>
      'ఈ వర్గంలో ఈ బరువుకు సరిపోలే వాహనాలు లేవు.';

  @override
  String get goodsTypeGeneralCargo => 'సాధారణ సరుకు';

  @override
  String get goodsTypeFurniture => 'ఫర్నిచర్';

  @override
  String get goodsTypeElectronics => 'ఎలక్ట్రానిక్స్';

  @override
  String get goodsTypeFoodGroceries => 'ఆహారం & కిరాణా';

  @override
  String get goodsTypeDocuments => 'పత్రాలు';

  @override
  String get goodsTypeIndustrialEquipment => 'పారిశ్రామిక పరికరాలు';

  @override
  String get goodsTypeOther => 'ఇతర';

  @override
  String get enterValidWeightKg =>
      'కేజీలలో చెల్లుబాటు అయ్యే బరువును నమోదు చేయండి.';

  @override
  String vehicleCanCarryUpTo(String name, String maxWeight) {
    return '$name గరిష్టంగా $maxWeightకేజీ వరకు మోయగలదు - పెద్ద వాహనాన్ని ఎంచుకోండి లేదా బరువు తగ్గించండి.';
  }

  @override
  String get couldNotGetFareEstimateTryAgain =>
      'చార్జీ అంచనాను పొందడం సాధ్యం కాలేదు. మీ కనెక్షన్‌ను తనిఖీ చేసి మళ్లీ ప్రయత్నించండి.';

  @override
  String get loadDetails => 'లోడ్ వివరాలు';

  @override
  String get goodsType => 'సరుకు రకం';

  @override
  String get fragile => 'పెళుసైనది';

  @override
  String get fragileSubtitle => 'నిర్వహణ సమయంలో అదనపు జాగ్రత్త';

  @override
  String get addInsurance => 'బీమాను జోడించండి';

  @override
  String get addInsuranceSubtitle =>
      'రవాణాలో నష్టం లేదా డ్యామేజీని కవర్ చేస్తుంది';

  @override
  String get receiverDetails => 'స్వీకర్త వివరాలు';

  @override
  String get receiverDetailsSubtitle =>
      'ఐచ్ఛికం - మీ ఇన్‌వాయిస్/వేబిల్‌లో నింపబడుతుంది';

  @override
  String get receiversName => 'స్వీకర్త పేరు';

  @override
  String get receiversPhone => 'స్వీకర్త ఫోన్';

  @override
  String get receiversGstinOptional => 'స్వీకర్త GSTIN (ఐచ్ఛికం)';

  @override
  String get getFareEstimate => 'చార్జీ అంచనాను పొందండి';

  @override
  String get couldNotConfirmBookingTryAgain =>
      'ఈ బుకింగ్‌ను నిర్ధారించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get priceSummary => 'ధర సారాంశం';

  @override
  String get noEstimateFoundForBooking => 'ఈ బుకింగ్ కోసం అంచనా కనుగొనబడలేదు.';

  @override
  String get startNewBooking => 'కొత్త బుకింగ్‌ను ప్రారంభించండి';

  @override
  String get vehicleLabel => 'వాహనం';

  @override
  String get distanceLabel => 'దూరం';

  @override
  String get weightLabel => 'బరువు';

  @override
  String get fareBreakdown => 'చార్జీ వివరాలు';

  @override
  String get baseFare => 'ప్రాథమిక చార్జీ';

  @override
  String get distanceCharge => 'దూర చార్జీ';

  @override
  String get weightCharge => 'బరువు చార్జీ';

  @override
  String surgeMultiplierLabel(String multiplier) {
    return 'సర్జ్ (${multiplier}x)';
  }

  @override
  String get totalAmount => 'మొత్తం మొత్తం';

  @override
  String get finalAmountMayVarySlightly => 'తుది మొత్తం కొద్దిగా మారవచ్చు';

  @override
  String get confirmBooking => 'బుకింగ్‌ను నిర్ధారించండి';

  @override
  String get paymentMethod => 'చెల్లింపు విధానం';

  @override
  String get payOnline => 'ఆన్‌లైన్‌లో చెల్లించండి';

  @override
  String payOnlineAdvanceSubtitle(String advance, String remaining) {
    return 'ఇప్పుడు ఆన్‌లైన్‌లో ₹$advance చెల్లించాలి, మిగిలిన ₹$remaining డెలివరీ సమయంలో ఆన్‌లైన్‌లో చెల్లించాలి';
  }

  @override
  String get payOnlineFullSubtitle =>
      'కార్డ్/UPI ద్వారా ఇప్పుడు పూర్తి మొత్తాన్ని చెల్లించండి';

  @override
  String get cashOnDelivery => 'డెలివరీ వద్ద నగదు చెల్లింపు';

  @override
  String codAdvanceSubtitle(String advance, String remaining) {
    return 'ఇప్పుడు ఆన్‌లైన్‌లో ₹$advance చెల్లించాలి, మిగిలిన ₹$remaining డెలివరీ వద్ద నగదులో';
  }

  @override
  String get codFullSubtitle =>
      'డెలివరీ వద్ద నగదులో పూర్తి మొత్తాన్ని చెల్లించండి';

  @override
  String get enterBothPickupDropLocations =>
      'పికప్ మరియు డ్రాప్ రెండు స్థానాలను నమోదు చేయండి.';

  @override
  String get selectAVehicleType => 'ఒక వాహన రకాన్ని ఎంచుకోండి.';

  @override
  String vehicleCanCarryUpToShort(String name, String maxWeight) {
    return '$name గరిష్టంగా $maxWeight కేజీ వరకు మోయగలదు.';
  }

  @override
  String get couldNotCalculatePriceTryAgain =>
      'ధరను లెక్కించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get vehicleTypeLabel => 'వాహన రకం';

  @override
  String get couldNotLoadVehicleTypesShort =>
      'వాహన రకాలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get weightKgOptionalHint => 'బరువు (కేజీ) - ఐచ్ఛికం';

  @override
  String get calculate => 'లెక్కించండి';

  @override
  String get recalculate => 'మళ్లీ లెక్కించండి';

  @override
  String get estimatedFare => 'అంచనా చార్జీ';

  @override
  String get thisIsOnlyEstimateNotBooking =>
      'ఇది కేవలం అంచనా మాత్రమే - బుకింగ్ కాదు.';

  @override
  String get filterAll => 'అన్నీ';

  @override
  String get filterActive => 'యాక్టివ్';

  @override
  String get couldNotLoadYourOrders =>
      'మీ ఆర్డర్‌లను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get noOrdersHereYet => 'ఇక్కడ ఇంకా ఆర్డర్‌లు లేవు.';

  @override
  String get tapStarToRate =>
      'మీ డ్రైవర్‌ను రేట్ చేయడానికి ఒక స్టార్‌ను నొక్కండి.';

  @override
  String get couldNotSubmitReviewTryAgain =>
      'మీ సమీక్షను సమర్పించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get couldNotLoadThisBooking =>
      'ఈ బుకింగ్‌ను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get reportAnIssue => 'సమస్యను నివేదించండి';

  @override
  String get disputeCategoryLabel => 'వర్గం';

  @override
  String get disputeCategoryPayment => 'చెల్లింపు';

  @override
  String get disputeCategoryDamage => 'దెబ్బతిన్న సరుకు';

  @override
  String get disputeCategoryDelay => 'ఆలస్యం';

  @override
  String get disputeCategoryBehavior => 'డ్రైవర్ ప్రవర్తన';

  @override
  String get disputeCategoryPricing => 'ధర నిర్ణయం';

  @override
  String get disputeCategoryOther => 'ఇతర';

  @override
  String get whatHappenedLabel => 'ఏమి జరిగింది?';

  @override
  String get describeWhatHappened => 'ఏమి జరిగిందో వివరించండి.';

  @override
  String get reportedTeamWillLookIntoIt =>
      'నివేదించబడింది - మా బృందం దీన్ని పరిశీలిస్తుంది.';

  @override
  String get couldNotSubmitThisTryAgain =>
      'దీన్ని సమర్పించడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get submittingEllipsis => 'సమర్పిస్తోంది…';

  @override
  String get submit => 'సమర్పించండి';

  @override
  String get cancelBookingQuestion => 'బుకింగ్‌ను రద్దు చేయాలా?';

  @override
  String cancellationFeeWarning(String fee) {
    return 'ఒక డ్రైవర్ ఇప్పటికే ఈ పనిని అంగీకరించారు. డ్రైవర్ పరిహారంగా మీ రీఫండ్ నుండి ₹$fee రద్దు రుసుము తీసివేయబడుతుంది.';
  }

  @override
  String get cannotBeUndone => 'దీన్ని రద్దు చేయడం సాధ్యం కాదు.';

  @override
  String get keepBooking => 'బుకింగ్‌ను ఉంచండి';

  @override
  String get cancelBooking => 'బుకింగ్‌ను రద్దు చేయండి';

  @override
  String get couldNotCancelThisBooking =>
      'ఈ బుకింగ్‌ను రద్దు చేయడం సాధ్యం కాలేదు.';

  @override
  String get orderDetails => 'ఆర్డర్ వివరాలు';

  @override
  String get paymentPendingTitle => 'చెల్లింపు పెండింగ్‌లో ఉంది';

  @override
  String get payAdvanceToConfirmTrackingAvailable =>
      'ఈ బుకింగ్‌ను నిర్ధారించడానికి అడ్వాన్స్ చెల్లించండి - వెంటనే ట్రాకింగ్ అందుబాటులో ఉంటుంది.';

  @override
  String get findingADriver => 'డ్రైవర్‌ను వెతుకుతోంది…';

  @override
  String get pickupSuccessfulDriverAtLocation =>
      'పికప్ విజయవంతమైంది! మీ డ్రైవర్ పికప్ స్థానంలో ఉన్నారు.';

  @override
  String get shipmentDeliveredExclaim => 'మీ షిప్‌మెంట్ డెలివరీ చేయబడింది!';

  @override
  String payToCompleteOrder(String amount) {
    return 'ఈ ఆర్డర్‌ను పూర్తి చేయడానికి ₹$amount చెల్లించండి.';
  }

  @override
  String get giveCodeToStartTrip =>
      'ప్రయాణాన్ని ప్రారంభించడానికి ఈ కోడ్‌ను మీ డ్రైవర్‌కు ఇవ్వండి';

  @override
  String get giveCodeAtDropOff =>
      'డ్రాప్-ఆఫ్ వద్ద ఈ కోడ్‌ను మీ డ్రైవర్‌కు ఇవ్వండి';

  @override
  String get onlineValue => 'ఆన్‌లైన్';

  @override
  String get advancePaid => 'అడ్వాన్స్ చెల్లించబడింది';

  @override
  String get advanceDueNow => 'అడ్వాన్స్ ఇప్పుడు చెల్లించాలి';

  @override
  String get dueInCashAtDelivery => 'డెలివరీ వద్ద నగదులో చెల్లించాలి';

  @override
  String get remainderPaid => 'మిగిలినది చెల్లించబడింది';

  @override
  String get remainderDueOnline => 'మిగిలినది ఆన్‌లైన్‌లో చెల్లించాలి';

  @override
  String get preparingEllipsis => 'సిద్ధమవుతోంది…';

  @override
  String get downloadInvoice => 'ఇన్‌వాయిస్‌ను డౌన్‌లోడ్ చేయండి';

  @override
  String get couldNotDownloadInvoice =>
      'ఇన్‌వాయిస్‌ను డౌన్‌లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get yourRating => 'మీ రేటింగ్';

  @override
  String get rateYourDriver => 'మీ డ్రైవర్‌ను రేట్ చేయండి';

  @override
  String get addCommentOptional => 'వ్యాఖ్యను జోడించండి (ఐచ్ఛికం)';

  @override
  String get submitReview => 'సమీక్షను సమర్పించండి';

  @override
  String get showThisToDriverAtPickup =>
      'పికప్ వద్ద దీన్ని మీ డ్రైవర్‌కు చూపించండి';

  @override
  String get waitingForDriverGpsSignal =>
      'మీ డ్రైవర్ GPS సిగ్నల్ కోసం వేచి ఉంది…';

  @override
  String get cancellingEllipsis => 'రద్దు చేస్తోంది…';

  @override
  String get couldNotLoadNotifications =>
      'నోటిఫికేషన్‌లను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get markAllRead => 'అన్నింటినీ చదివినట్లు గుర్తు పెట్టండి';

  @override
  String get allCaughtUpNothingHereYet =>
      'మీరు పూర్తిగా అప్‌డేట్‌గా ఉన్నారు - ఇక్కడ ఇంకా ఏమీ లేదు.';

  @override
  String get couldNotLoadMessages => 'సందేశాలను లోడ్ చేయడం సాధ్యం కాలేదు.';

  @override
  String get chatWithDriver => 'డ్రైవర్‌తో చాట్ చేయండి';

  @override
  String get sayHelloToYourDriver => 'మీ డ్రైవర్‌కు హలో చెప్పండి.';

  @override
  String get typeAMessageHint => 'సందేశాన్ని టైప్ చేయండి…';

  @override
  String get shipmentPaymentDescription => 'షిప్‌మెంట్ చెల్లింపు';

  @override
  String get paymentWasNotCompleted => 'చెల్లింపు పూర్తి కాలేదు.';

  @override
  String get couldNotCompletePaymentTryAgain =>
      'చెల్లింపును పూర్తి చేయడం సాధ్యం కాలేదు. మళ్లీ ప్రయత్నించండి.';

  @override
  String get openingPaymentEllipsis => 'చెల్లింపును తెరుస్తోంది…';

  @override
  String get payRemainingAmount => 'మిగిలిన మొత్తాన్ని చెల్లించండి';

  @override
  String get payAdvance => 'అడ్వాన్స్ చెల్లించండి';

  @override
  String get payNow => 'ఇప్పుడే చెల్లించండి';

  @override
  String get useMyCurrentLocation => 'నా ప్రస్తుత స్థానాన్ని ఉపయోగించండి';

  @override
  String get textSize => 'టెక్స్ట్ పరిమాణం';

  @override
  String get textSizeScreenHint =>
      'యాప్ మొత్తంలో టెక్స్ట్ ఎంత పెద్దదిగా కనిపించాలో ఎంచుకోండి.';

  @override
  String get textSizeSmall => 'చిన్నది';

  @override
  String get textSizeStandard => 'డిఫాల్ట్';

  @override
  String get textSizeLarge => 'పెద్దది';

  @override
  String get textSizeExtraLarge => 'మరింత పెద్దది';

  @override
  String get textSizeSampleText => 'ఇది ఒక నమూనా వచనం';
}
