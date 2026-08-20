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
}
