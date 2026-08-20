// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Tamil (`ta`).
class AppLocalizationsTa extends AppLocalizations {
  AppLocalizationsTa([String locale = 'ta']) : super(locale);

  @override
  String get appTitle => 'ராம்மித்ரா';

  @override
  String get cancel => 'ரத்து செய்';

  @override
  String get save => 'சேமி';

  @override
  String get signOut => 'வெளியேறு';

  @override
  String get profile => 'சுயவிவரம்';

  @override
  String get fullName => 'முழு பெயர்';

  @override
  String get noNameSet => 'பெயர் அமைக்கப்படவில்லை';

  @override
  String get nameCannotBeEmpty => 'பெயர் காலியாக இருக்கக்கூடாது.';

  @override
  String get couldNotSaveChangesTryAgain =>
      'மாற்றங்களைச் சேமிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get signOutQuestion => 'வெளியேற வேண்டுமா?';

  @override
  String get signOutBody => 'தொடர மீண்டும் உள்நுழைய வேண்டும்.';

  @override
  String get personalInformation => 'தனிப்பட்ட தகவல்';

  @override
  String get addresses => 'முகவரிகள்';

  @override
  String get paymentMethods => 'கட்டண முறைகள்';

  @override
  String get notifications => 'அறிவிப்புகள்';

  @override
  String get notificationSettings => 'அறிவிப்பு அமைப்புகள்';

  @override
  String get language => 'மொழி';

  @override
  String get changePassword => 'கடவுச்சொல்லை மாற்று';

  @override
  String get helpAndSupport => 'உதவி மற்றும் ஆதரவு';

  @override
  String get about => 'பயன்பாடு பற்றி';

  @override
  String get enterValidEmail => 'சரியான மின்னஞ்சல் முகவரியை உள்ளிடவும்.';

  @override
  String get enterYourPassword => 'உங்கள் கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get couldNotLogInTryAgain =>
      'உள்நுழைய முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get passwordMinLength =>
      'கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்.';

  @override
  String get passwordsDoNotMatch => 'கடவுச்சொற்கள் பொருந்தவில்லை.';

  @override
  String get couldNotCreateAccountTryAgain =>
      'உங்கள் கணக்கை உருவாக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get notVerifiedYetTapLink =>
      'இன்னும் சரிபார்க்கப்படவில்லை - நாங்கள் அனுப்பிய மின்னஞ்சலில் உள்ள இணைப்பைத் தட்டவும்.';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'சரிபார்ப்பு நிலையை சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get couldNotResendEmailTryAgain =>
      'மின்னஞ்சலை மீண்டும் அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get couldNotSendCodeTryAgain =>
      'குறியீட்டை அனுப்ப முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get enterSixDigitCode => '6-இலக்க குறியீட்டை உள்ளிடவும்.';

  @override
  String get incorrectOrExpiredCode => 'தவறான அல்லது காலாவதியான குறியீடு.';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'அந்த குறியீட்டை சரிபார்க்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get enterEmailFirstThenForgot =>
      'முதலில் மேலே உங்கள் மின்னஞ்சலை உள்ளிடவும், பின்னர் \"கடவுச்சொல் மறந்துவிட்டதா?\" என்பதைத் தட்டவும்.';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'கடவுச்சொல் மீட்டமைப்பு இணைப்பு $emailக்கு அனுப்பப்பட்டது';
  }

  @override
  String get enterValidMobileNumber =>
      'சரியான 10-இலக்க மொபைல் எண்ணை உள்ளிடவும்.';

  @override
  String get accountExistsForEmailTryLogin =>
      'அந்த மின்னஞ்சலுக்கு ஏற்கனவே ஒரு கணக்கு உள்ளது. அதற்கு பதிலாக உள்நுழைய முயற்சிக்கவும்.';

  @override
  String get emailLooksInvalid => 'அந்த மின்னஞ்சல் முகவரி தவறானதாக தெரிகிறது.';

  @override
  String get chooseStrongerPassword =>
      'வலுவான கடவுச்சொல்லைத் தேர்ந்தெடுக்கவும்.';

  @override
  String get incorrectEmailOrPassword => 'தவறான மின்னஞ்சல் அல்லது கடவுச்சொல்.';

  @override
  String get tooManyAttemptsTryAgain =>
      'மிக அதிக முயற்சிகள். சிறிது நேரம் கழித்து மீண்டும் முயற்சிக்கவும்.';

  @override
  String get phoneNumberLooksInvalid => 'அந்த தொலைபேசி எண் தவறானதாக தெரிகிறது.';

  @override
  String get codeExpiredRequestNew =>
      'அந்த குறியீடு காலாவதியானது - புதிய ஒன்றை கோரவும்.';

  @override
  String get somethingWentWrongTryAgain =>
      'ஏதோ தவறு நடந்தது. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get verifyYourNumber => 'உங்கள் எண்ணை சரிபார்க்கவும்';

  @override
  String get welcomeExclaim => 'வரவேற்கிறோம்!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'நாங்கள் +91 $phone க்கு 6-இலக்க குறியீட்டை அனுப்பியுள்ளோம்';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'உங்கள் மொபைல் எண்ணுடன் உள்நுழையவும் அல்லது பதிவு செய்யவும்';

  @override
  String get welcomeBack => 'மீண்டும் வரவேற்கிறோம்!';

  @override
  String get createAccount => 'கணக்கை உருவாக்கு';

  @override
  String get verifyYourEmail => 'உங்கள் மின்னஞ்சலை சரிபார்க்கவும்';

  @override
  String get logInWithEmailToContinue =>
      'தொடர உங்கள் மின்னஞ்சலுடன் உள்நுழையவும்';

  @override
  String get signUpWithEmailToGetStarted =>
      'தொடங்க உங்கள் மின்னஞ்சலுடன் பதிவு செய்யவும்';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'நாங்கள் $email க்கு சரிபார்ப்பு இணைப்பை அனுப்பியுள்ளோம்';
  }

  @override
  String get emailAddress => 'மின்னஞ்சல் முகவரி';

  @override
  String get password => 'கடவுச்சொல்';

  @override
  String get forgotPassword => 'கடவுச்சொல் மறந்துவிட்டதா?';

  @override
  String get logIn => 'உள்நுழை';

  @override
  String get dontHaveAccountSignUp => 'கணக்கு இல்லையா? பதிவு செய்யவும்';

  @override
  String get emailMethod => 'மின்னஞ்சல்';

  @override
  String get phoneMethod => 'தொலைபேசி';

  @override
  String get sixDigitCode => '6-இலக்க குறியீடு';

  @override
  String get verifyAndContinue => 'சரிபார்த்து தொடரவும்';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds வினாடிகளில் குறியீட்டை மீண்டும் அனுப்பு';
  }

  @override
  String get resendCode => 'குறியீட்டை மீண்டும் அனுப்பு';

  @override
  String get tenDigitMobileNumber => '10-இலக்க மொபைல் எண்';

  @override
  String get sendOtp => 'OTP அனுப்பு';

  @override
  String get passwordMinCharsHint => 'கடவுச்சொல் (குறைந்தது 6 எழுத்துகள்)';

  @override
  String get confirmPassword => 'கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get signUp => 'பதிவு செய்';

  @override
  String get alreadyHaveAccountLogIn => 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழையவும்';

  @override
  String get sendCode => 'குறியீட்டை அனுப்பு';

  @override
  String get verifyCode => 'குறியீட்டை சரிபார்';

  @override
  String get useLinkInstead => 'அதற்கு பதிலாக இணைப்பைப் பயன்படுத்தவும்';

  @override
  String get iveVerifiedMyEmail => 'நான் என் மின்னஞ்சலை சரிபார்த்துவிட்டேன்';

  @override
  String get verificationEmailSentAgain =>
      'சரிபார்ப்பு மின்னஞ்சல் மீண்டும் அனுப்பப்பட்டது';

  @override
  String get resendVerificationEmail =>
      'சரிபார்ப்பு மின்னஞ்சலை மீண்டும் அனுப்பு';

  @override
  String get enterCodeInstead => 'அதற்கு பதிலாக குறியீட்டை உள்ளிடவும்';

  @override
  String get onboardingTitle1 => 'எளிதான ஷிப்பிங்,\nஸ்மார்ட் வணிகம்';

  @override
  String get onboardingBody1 =>
      'ஸ்மார்ட் ஷிப்பிங் நேரத்தை மிச்சப்படுத்தி, செலவைக் குறைத்து\nவணிகங்களை வேகமாக வளர்க்கிறது.';

  @override
  String get onboardingTitle2 => 'லைவ் டிராக் செய்யுங்கள்,\nவீட்டு வாசல் வரை';

  @override
  String get onboardingBody2 =>
      'மேப்பில் உங்கள் டிரைவர் நெருங்குவதை பாருங்கள்\nரியல்-டைம் ETA புதுப்பிப்புகளுடன்.';

  @override
  String get onboardingTitle3 =>
      'உங்கள் விருப்பப்படி பணம் செலுத்துங்கள்,\nஒவ்வொரு முறையும்';

  @override
  String get onboardingBody3 =>
      'UPI, கார்டுகள், நெட் பேங்கிங் அல்லது வாலட் -\nஉங்கள் தேர்வு, ஒவ்வொரு முன்பதிவிலும்.';

  @override
  String get getStarted => 'தொடங்குங்கள்';

  @override
  String get next => 'அடுத்து';

  @override
  String get pressBackAgainToExit => 'வெளியேற மீண்டும் பேக் அழுத்தவும்';

  @override
  String get view => 'பார்';

  @override
  String get home => 'முகப்பு';

  @override
  String get orders => 'ஆர்டர்கள்';

  @override
  String get couldNotLoadYourBookings =>
      'உங்கள் முன்பதிவுகளை ஏற்ற முடியவில்லை.';

  @override
  String heyNameWave(String name) {
    return 'வணக்கம் $name 👋';
  }

  @override
  String get thereFallbackName => 'நண்பரே';

  @override
  String get whereAreWeShippingToday => 'இன்று நாம் எங்கு அனுப்புகிறோம்?';

  @override
  String get searchShipmentsHint =>
      'வேபில் அல்லது முகவரி மூலம் ஷிப்மென்ட்களைத் தேடுங்கள்';

  @override
  String get bookNewShipment => 'புதிய ஷிப்மென்ட் முன்பதிவு செய்யுங்கள்';

  @override
  String get getInstantPriceBookDelivery =>
      'உடனடி விலையைப் பெற்று உங்கள் டெலிவரியை முன்பதிவு செய்யுங்கள்';

  @override
  String get priceCalculator => 'விலை கால்குலேட்டர்';

  @override
  String get myOrders => 'எனது ஆர்டர்கள்';

  @override
  String get support => 'ஆதரவு';

  @override
  String get searchResults => 'தேடல் முடிவுகள்';

  @override
  String get recentOrders => 'சமீபத்திய ஆர்டர்கள்';

  @override
  String get viewAll => 'அனைத்தையும் காண்க';

  @override
  String noShipmentsMatch(String query) {
    return '\"$query\" உடன் பொருந்தும் ஷிப்மென்ட் இல்லை.';
  }

  @override
  String get noBookingsYetTapAway =>
      'இதுவரை முன்பதிவுகள் இல்லை - உங்கள் முதல் முன்பதிவு ஒரு தட்டு தூரத்தில் உள்ளது.';

  @override
  String get statusPaymentPending => 'பணம் செலுத்த வேண்டும்';

  @override
  String get statusPending => 'நிலுவையில்';

  @override
  String get statusAccepted => 'ஏற்றுக்கொள்ளப்பட்டது';

  @override
  String get statusInTransit => 'போக்குவரத்தில்';

  @override
  String get statusAwaitingPayment => 'பணம் செலுத்த காத்திருக்கிறது';

  @override
  String get statusDelivered => 'டெலிவரி ஆனது';

  @override
  String get statusCancelled => 'ரத்து செய்யப்பட்டது';

  @override
  String get raahmitrCustomerAppLine => 'ராம்மித்ரா கஸ்டமர் ஆப்';

  @override
  String versionNumber(String number) {
    return 'பதிப்பு $number';
  }

  @override
  String get couldNotLoadNotificationSettings =>
      'அறிவிப்பு அமைப்புகளை ஏற்ற முடியவில்லை.';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'அறிவிப்பு விருப்பத்தேர்வை புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get devicePermission => 'சாதன அனுமதி';

  @override
  String get notificationsAllowedOnDevice =>
      'இந்த சாதனத்தில் அறிவிப்புகள் அனுமதிக்கப்பட்டுள்ளன.';

  @override
  String get notificationsNotAllowedWarning =>
      'அறிவிப்புகள் அனுமதிக்கப்படவில்லை - நீங்கள் அவற்றை இயக்கும் வரை முன்பதிவு மற்றும் டெலிவரி புதுப்பிப்புகள் உங்களை சென்றடையாது.';

  @override
  String get enableNotifications => 'அறிவிப்புகளை இயக்கு';

  @override
  String get notificationsBlockedManualEnableHint =>
      'அதைத் தட்டும்போது எதுவும் நடக்கவில்லை என்றால், உங்கள் ஃபோன் ஏற்கனவே இந்த ஆப்பை தடுத்துவிட்டது - உங்கள் ஃபோனின் Settings > Apps > Notifications இல் கைமுறையாக இயக்கவும்.';

  @override
  String get pushNotifications => 'புஷ் அறிவிப்புகள்';

  @override
  String get pushNotificationsDescription =>
      'முன்பதிவு புதுப்பிப்புகள், டிரைவர் ஒதுக்கீடு மற்றும் டெலிவரி உறுதிப்படுத்தல்கள்.';

  @override
  String get saved => 'சேமிக்கப்பட்டது.';

  @override
  String get email => 'மின்னஞ்சல்';

  @override
  String get phone => 'தொலைபேசி';

  @override
  String get businessGstinOptional => 'வணிக GSTIN (விருப்பத்தேர்வு)';

  @override
  String get usedOnInvoicesIfAny =>
      'உங்களிடம் இருந்தால், இது உங்கள் முன்பதிவு விலைப்பட்டியல்களில் பயன்படுத்தப்படும்.';

  @override
  String get saveChanges => 'மாற்றங்களை சேமி';

  @override
  String get couldNotLoadYourAddresses => 'உங்கள் முகவரிகளை ஏற்ற முடியவில்லை.';

  @override
  String get addAddress => 'முகவரியைச் சேர்';

  @override
  String get editAddress => 'முகவரியைத் திருத்து';

  @override
  String get labelHint => 'லேபிள் (எ.கா. வீடு, அலுவலகம்)';

  @override
  String get fullAddress => 'முழு முகவரி';

  @override
  String get couldNotSaveThisAddress => 'இந்த முகவரியை சேமிக்க முடியவில்லை.';

  @override
  String get couldNotRemoveThisAddress => 'இந்த முகவரியை அகற்ற முடியவில்லை.';

  @override
  String get noSavedAddressesYet =>
      'இதுவரை சேமிக்கப்பட்ட முகவரிகள் இல்லை - ஒன்றைச் சேர்க்க + ஐத் தட்டவும்.';

  @override
  String get edit => 'திருத்து';

  @override
  String get delete => 'நீக்கு';

  @override
  String get couldNotLoadPaymentHistory =>
      'பணம் செலுத்திய வரலாற்றை ஏற்ற முடியவில்லை.';

  @override
  String get removeCardQuestion => 'கார்டை அகற்றவா?';

  @override
  String removeCardConfirm(String network, String last4) {
    return '$last4 இல் முடிவடையும் $network கார்டை அகற்றவா?';
  }

  @override
  String get remove => 'அகற்று';

  @override
  String get couldNotRemoveThatCard => 'அந்த கார்டை அகற்ற முடியவில்லை.';

  @override
  String get savedCards => 'சேமிக்கப்பட்ட கார்டுகள்';

  @override
  String get noSavedCardsYet =>
      'இதுவரை சேமிக்கப்பட்ட கார்டுகள் இல்லை - உங்கள் அடுத்த கட்டணத்தின் போது \"இந்த கார்டை சேமி\" எனத் தேர்வு செய்யவும்.';

  @override
  String get transactionHistory => 'பரிவர்த்தனை வரலாறு';

  @override
  String get noPaymentsYet => 'இதுவரை பணம் செலுத்தல் இல்லை.';

  @override
  String get enterCurrentPassword => 'உங்கள் தற்போதைய கடவுச்சொல்லை உள்ளிடவும்.';

  @override
  String get newPasswordMinLength =>
      'புதிய கடவுச்சொல் குறைந்தது 6 எழுத்துகள் இருக்க வேண்டும்.';

  @override
  String get newPasswordsDoNotMatch => 'புதிய கடவுச்சொற்கள் பொருந்தவில்லை.';

  @override
  String get passwordUpdated => 'கடவுச்சொல் புதுப்பிக்கப்பட்டது';

  @override
  String get currentPasswordIncorrect => 'தற்போதைய கடவுச்சொல் தவறானது.';

  @override
  String get couldNotUpdatePassword => 'கடவுச்சொல்லை புதுப்பிக்க முடியவில்லை.';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'கடவுச்சொல்லை புதுப்பிக்க முடியவில்லை. மீண்டும் முயற்சிக்கவும்.';

  @override
  String get currentPassword => 'தற்போதைய கடவுச்சொல்';

  @override
  String get newPassword => 'புதிய கடவுச்சொல்';

  @override
  String get confirmNewPassword => 'புதிய கடவுச்சொல்லை உறுதிப்படுத்தவும்';

  @override
  String get updatePassword => 'கடவுச்சொல்லை புதுப்பிக்கவும்';

  @override
  String get couldNotLoadHelpContent => 'உதவி உள்ளடக்கத்தை ஏற்ற முடியவில்லை.';

  @override
  String get needMoreHelp => 'மேலும் உதவி வேண்டுமா?';

  @override
  String get emailSupportAddress => 'மின்னஞ்சல் support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'அடிக்கடி கேட்கப்படும் கேள்விகள்';

  @override
  String get noFaqsAvailable => 'தற்போது FAQகள் எதுவும் இல்லை.';
}
