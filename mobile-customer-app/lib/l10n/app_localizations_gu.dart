// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Gujarati (`gu`).
class AppLocalizationsGu extends AppLocalizations {
  AppLocalizationsGu([String locale = 'gu']) : super(locale);

  @override
  String get appTitle => 'રાહમિત્ર';

  @override
  String get cancel => 'રદ કરો';

  @override
  String get save => 'સાચવો';

  @override
  String get signOut => 'સાઇન આઉટ કરો';

  @override
  String get profile => 'પ્રોફાઇલ';

  @override
  String get fullName => 'પૂરું નામ';

  @override
  String get noNameSet => 'કોઈ નામ સેટ નથી';

  @override
  String get nameCannotBeEmpty => 'નામ ખાલી હોઈ શકે નહીં.';

  @override
  String get couldNotSaveChangesTryAgain =>
      'ફેરફારો સાચવી શકાયા નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get signOutQuestion => 'સાઇન આઉટ કરવું છે?';

  @override
  String get signOutBody => 'ચાલુ રાખવા માટે તમારે ફરીથી લોગ ઇન કરવું પડશે.';

  @override
  String get personalInformation => 'વ્યક્તિગત માહિતી';

  @override
  String get addresses => 'સરનામાં';

  @override
  String get paymentMethods => 'ચુકવણી પદ્ધતિઓ';

  @override
  String get notifications => 'સૂચનાઓ';

  @override
  String get notificationSettings => 'સૂચના સેટિંગ્સ';

  @override
  String get language => 'ભાષા';

  @override
  String get changePassword => 'પાસવર્ડ બદલો';

  @override
  String get helpAndSupport => 'સહાય અને સપોર્ટ';

  @override
  String get about => 'એપ્લિકેશન વિશે';

  @override
  String get enterValidEmail => 'માન્ય ઈમેલ સરનામું દાખલ કરો.';

  @override
  String get enterYourPassword => 'તમારો પાસવર્ડ દાખલ કરો.';

  @override
  String get couldNotLogInTryAgain => 'લોગ ઇન કરી શકાયું નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get passwordMinLength => 'પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરોનો હોવો જોઈએ.';

  @override
  String get passwordsDoNotMatch => 'પાસવર્ડ મેળ ખાતા નથી.';

  @override
  String get couldNotCreateAccountTryAgain =>
      'તમારું ખાતું બનાવી શકાયું નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get notVerifiedYetTapLink =>
      'હજુ ચકાસાયેલ નથી - અમે મોકલેલ ઈમેલમાંની લિંક પર ટેપ કરો.';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'ચકાસણી સ્થિતિ તપાસી શકાઈ નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get couldNotResendEmailTryAgain =>
      'ઈમેલ ફરીથી મોકલી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get couldNotSendCodeTryAgain =>
      'કોડ મોકલી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get enterSixDigitCode => '6-અંકનો કોડ દાખલ કરો.';

  @override
  String get incorrectOrExpiredCode => 'ખોટો અથવા સમય મર્યાદા વીતેલો કોડ.';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'તે કોડ ચકાસી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get enterEmailFirstThenForgot =>
      'પહેલા ઉપર તમારો ઈમેલ દાખલ કરો, પછી \"પાસવર્ડ ભૂલી ગયા?\" પર ટેપ કરો.';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'પાસવર્ડ રીસેટ લિંક $email પર મોકલવામાં આવી';
  }

  @override
  String get enterValidMobileNumber => 'માન્ય 10-અંકનો મોબાઇલ નંબર દાખલ કરો.';

  @override
  String get accountExistsForEmailTryLogin =>
      'તે ઈમેલ માટે પહેલેથી જ ખાતું અસ્તિત્વમાં છે. તેના બદલે લોગ ઇન કરવાનો પ્રયાસ કરો.';

  @override
  String get emailLooksInvalid => 'તે ઈમેલ સરનામું અમાન્ય લાગે છે.';

  @override
  String get chooseStrongerPassword => 'વધુ મજબૂત પાસવર્ડ પસંદ કરો.';

  @override
  String get incorrectEmailOrPassword => 'ખોટો ઈમેલ અથવા પાસવર્ડ.';

  @override
  String get tooManyAttemptsTryAgain =>
      'ઘણા બધા પ્રયાસો. થોડી વાર પછી ફરી પ્રયાસ કરો.';

  @override
  String get phoneNumberLooksInvalid => 'તે ફોન નંબર અમાન્ય લાગે છે.';

  @override
  String get codeExpiredRequestNew =>
      'તે કોડની સમય મર્યાદા વીતી ગઈ - નવો વિનંતી કરો.';

  @override
  String get somethingWentWrongTryAgain => 'કંઈક ખોટું થયું. ફરી પ્રયાસ કરો.';

  @override
  String get verifyYourNumber => 'તમારો નંબર ચકાસો';

  @override
  String get welcomeExclaim => 'સ્વાગત છે!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'અમે +91 $phone પર 6-અંકનો કોડ મોકલ્યો છે';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'તમારા મોબાઇલ નંબરથી લોગ ઇન અથવા સાઇન અપ કરો';

  @override
  String get welcomeBack => 'ફરી સ્વાગત છે!';

  @override
  String get createAccount => 'ખાતું બનાવો';

  @override
  String get verifyYourEmail => 'તમારો ઈમેલ ચકાસો';

  @override
  String get logInWithEmailToContinue =>
      'ચાલુ રાખવા માટે તમારા ઈમેલથી લોગ ઇન કરો';

  @override
  String get signUpWithEmailToGetStarted =>
      'શરૂ કરવા માટે તમારા ઈમેલથી સાઇન અપ કરો';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'અમે $email પર ચકાસણી લિંક મોકલી છે';
  }

  @override
  String get emailAddress => 'ઈમેલ સરનામું';

  @override
  String get password => 'પાસવર્ડ';

  @override
  String get forgotPassword => 'પાસવર્ડ ભૂલી ગયા?';

  @override
  String get logIn => 'લોગ ઇન કરો';

  @override
  String get dontHaveAccountSignUp => 'ખાતું નથી? સાઇન અપ કરો';

  @override
  String get emailMethod => 'ઈમેલ';

  @override
  String get phoneMethod => 'ફોન';

  @override
  String get sixDigitCode => '6-અંકનો કોડ';

  @override
  String get verifyAndContinue => 'ચકાસો અને ચાલુ રાખો';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds સેકંડમાં કોડ ફરી મોકલો';
  }

  @override
  String get resendCode => 'કોડ ફરી મોકલો';

  @override
  String get tenDigitMobileNumber => '10-અંકનો મોબાઇલ નંબર';

  @override
  String get sendOtp => 'OTP મોકલો';

  @override
  String get passwordMinCharsHint => 'પાસવર્ડ (ઓછામાં ઓછા 6 અક્ષરો)';

  @override
  String get confirmPassword => 'પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get signUp => 'સાઇન અપ કરો';

  @override
  String get alreadyHaveAccountLogIn => 'પહેલેથી ખાતું છે? લોગ ઇન કરો';

  @override
  String get sendCode => 'કોડ મોકલો';

  @override
  String get verifyCode => 'કોડ ચકાસો';

  @override
  String get useLinkInstead => 'તેના બદલે લિંકનો ઉપયોગ કરો';

  @override
  String get iveVerifiedMyEmail => 'મેં મારો ઈમેલ ચકાસી લીધો છે';

  @override
  String get verificationEmailSentAgain => 'ચકાસણી ઈમેલ ફરીથી મોકલવામાં આવ્યો';

  @override
  String get resendVerificationEmail => 'ચકાસણી ઈમેલ ફરી મોકલો';

  @override
  String get enterCodeInstead => 'તેના બદલે કોડ દાખલ કરો';

  @override
  String get onboardingTitle1 => 'સરળ શિપિંગ,\nસ્માર્ટ બિઝનેસ';

  @override
  String get onboardingBody1 =>
      'સ્માર્ટ શિપિંગ સમય બચાવે છે, ખર્ચ ઘટાડે છે\nઅને વ્યવસાયને ઝડપથી વધારે છે.';

  @override
  String get onboardingTitle2 => 'લાઇવ ટ્રેક કરો,\nદરવાજા સુધી';

  @override
  String get onboardingBody2 =>
      'નકશા પર તમારા ડ્રાઈવરને નજીક આવતા જુઓ\nરીઅલ-ટાઇમ ETA અપડેટ્સ સાથે.';

  @override
  String get onboardingTitle3 => 'તમારી રીતે ચૂકવો,\nદરેક વખતે';

  @override
  String get onboardingBody3 =>
      'UPI, કાર્ડ, નેટ બેંકિંગ અથવા વોલેટ -\nતમારી પસંદગી, દરેક બુકિંગમાં.';

  @override
  String get getStarted => 'શરૂ કરો';

  @override
  String get next => 'આગળ';

  @override
  String get pressBackAgainToExit => 'બહાર નીકળવા માટે ફરીથી બેક દબાવો';

  @override
  String get view => 'જુઓ';

  @override
  String get home => 'હોમ';

  @override
  String get orders => 'ઓર્ડર';

  @override
  String get couldNotLoadYourBookings => 'તમારી બુકિંગ્સ લોડ કરી શકાઈ નહીં.';

  @override
  String heyNameWave(String name) {
    return 'નમસ્તે $name 👋';
  }

  @override
  String get thereFallbackName => 'જી';

  @override
  String get whereAreWeShippingToday => 'આજે આપણે ક્યાં શિપ કરી રહ્યા છીએ?';

  @override
  String get searchShipmentsHint => 'વેબિલ અથવા સરનામા દ્વારા શિપમેન્ટ શોધો';

  @override
  String get bookNewShipment => 'નવું શિપમેન્ટ બુક કરો';

  @override
  String get getInstantPriceBookDelivery =>
      'તરત જ કિંમત મેળવો અને તમારી ડિલિવરી બુક કરો';

  @override
  String get priceCalculator => 'કિંમત કેલ્ક્યુલેટર';

  @override
  String get myOrders => 'મારા ઓર્ડર';

  @override
  String get support => 'સપોર્ટ';

  @override
  String get searchResults => 'શોધ પરિણામો';

  @override
  String get recentOrders => 'તાજેતરના ઓર્ડર';

  @override
  String get viewAll => 'બધું જુઓ';

  @override
  String noShipmentsMatch(String query) {
    return '\"$query\" સાથે મેળ ખાતું કોઈ શિપમેન્ટ નથી.';
  }

  @override
  String get noBookingsYetTapAway =>
      'હજુ સુધી કોઈ બુકિંગ નથી - તમારી પહેલી બુકિંગ ફક્ત એક ટેપ દૂર છે.';

  @override
  String get statusPaymentPending => 'ચુકવણી બાકી';

  @override
  String get statusPending => 'બાકી';

  @override
  String get statusAccepted => 'સ્વીકૃત';

  @override
  String get statusInTransit => 'પરિવહનમાં';

  @override
  String get statusAwaitingPayment => 'ચુકવણીની રાહમાં';

  @override
  String get statusDelivered => 'ડિલિવર થયું';

  @override
  String get statusCancelled => 'રદ કરાયું';

  @override
  String get raahmitrCustomerAppLine => 'રાહમિત્ર કસ્ટમર એપ';

  @override
  String versionNumber(String number) {
    return 'વર્ઝન $number';
  }

  @override
  String get couldNotLoadNotificationSettings =>
      'સૂચના સેટિંગ્સ લોડ કરી શકાઈ નહીં.';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'સૂચના પસંદગી અપડેટ કરી શકાઈ નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get devicePermission => 'ડિવાઇસ પરવાનગી';

  @override
  String get notificationsAllowedOnDevice => 'આ ડિવાઇસ પર સૂચનાઓની મંજૂરી છે.';

  @override
  String get notificationsNotAllowedWarning =>
      'સૂચનાઓની મંજૂરી નથી - તમે તેમને સક્ષમ ન કરો ત્યાં સુધી બુકિંગ અને ડિલિવરી અપડેટ્સ તમારા સુધી પહોંચશે નહીં.';

  @override
  String get enableNotifications => 'સૂચનાઓ સક્ષમ કરો';

  @override
  String get notificationsBlockedManualEnableHint =>
      'તેના પર ટેપ કરવાથી કંઈ ન થાય, તો તમારા ફોને પહેલેથી જ આ એપને બ્લોક કરી દીધી છે - તેને તમારા ફોનના Settings > Apps > Notifications માં જાતે સક્ષમ કરો.';

  @override
  String get pushNotifications => 'પુશ સૂચનાઓ';

  @override
  String get pushNotificationsDescription =>
      'બુકિંગ અપડેટ્સ, ડ્રાઈવર સોંપણી અને ડિલિવરી પુષ્ટિઓ.';

  @override
  String get saved => 'સાચવ્યું.';

  @override
  String get email => 'ઈમેલ';

  @override
  String get phone => 'ફોન';

  @override
  String get businessGstinOptional => 'બિઝનેસ GSTIN (વૈકલ્પિક)';

  @override
  String get usedOnInvoicesIfAny =>
      'જો તમારી પાસે એક હોય, તો તે તમારા બુકિંગ ઇન્વોઇસ પર વપરાય છે.';

  @override
  String get saveChanges => 'ફેરફારો સાચવો';

  @override
  String get couldNotLoadYourAddresses => 'તમારા સરનામાં લોડ કરી શકાયા નહીં.';

  @override
  String get addAddress => 'સરનામું ઉમેરો';

  @override
  String get editAddress => 'સરનામું સંપાદિત કરો';

  @override
  String get labelHint => 'લેબલ (દા.ત. ઘર, ઓફિસ)';

  @override
  String get fullAddress => 'પૂરું સરનામું';

  @override
  String get couldNotSaveThisAddress => 'આ સરનામું સાચવી શકાયું નહીં.';

  @override
  String get couldNotRemoveThisAddress => 'આ સરનામું દૂર કરી શકાયું નહીં.';

  @override
  String get noSavedAddressesYet =>
      'હજુ સુધી કોઈ સાચવેલું સરનામું નથી - એક ઉમેરવા માટે + ટેપ કરો.';

  @override
  String get edit => 'સંપાદિત કરો';

  @override
  String get delete => 'કાઢી નાખો';

  @override
  String get couldNotLoadPaymentHistory => 'ચુકવણી ઇતિહાસ લોડ કરી શકાયો નહીં.';

  @override
  String get removeCardQuestion => 'કાર્ડ દૂર કરવું છે?';

  @override
  String removeCardConfirm(String network, String last4) {
    return '$last4 પર સમાપ્ત થતું $network કાર્ડ દૂર કરવું છે?';
  }

  @override
  String get remove => 'દૂર કરો';

  @override
  String get couldNotRemoveThatCard => 'તે કાર્ડ દૂર કરી શકાયું નહીં.';

  @override
  String get savedCards => 'સાચવેલા કાર્ડ્સ';

  @override
  String get noSavedCardsYet =>
      'હજુ સુધી કોઈ સાચવેલું કાર્ડ નથી - તમારી આગલી ચુકવણી દરમિયાન \"આ કાર્ડ સાચવો\" ચેક કરો.';

  @override
  String get transactionHistory => 'વ્યવહાર ઇતિહાસ';

  @override
  String get noPaymentsYet => 'હજુ સુધી કોઈ ચુકવણી નથી.';

  @override
  String get enterCurrentPassword => 'તમારો હાલનો પાસવર્ડ દાખલ કરો.';

  @override
  String get newPasswordMinLength =>
      'નવો પાસવર્ડ ઓછામાં ઓછો 6 અક્ષરોનો હોવો જોઈએ.';

  @override
  String get newPasswordsDoNotMatch => 'નવા પાસવર્ડ મેળ ખાતા નથી.';

  @override
  String get passwordUpdated => 'પાસવર્ડ અપડેટ થયો';

  @override
  String get currentPasswordIncorrect => 'હાલનો પાસવર્ડ ખોટો છે.';

  @override
  String get couldNotUpdatePassword => 'પાસવર્ડ અપડેટ કરી શકાયો નહીં.';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'પાસવર્ડ અપડેટ કરી શકાયો નહીં. ફરી પ્રયાસ કરો.';

  @override
  String get currentPassword => 'હાલનો પાસવર્ડ';

  @override
  String get newPassword => 'નવો પાસવર્ડ';

  @override
  String get confirmNewPassword => 'નવા પાસવર્ડની પુષ્ટિ કરો';

  @override
  String get updatePassword => 'પાસવર્ડ અપડેટ કરો';

  @override
  String get couldNotLoadHelpContent => 'સહાય સામગ્રી લોડ કરી શકાઈ નહીં.';

  @override
  String get needMoreHelp => 'વધુ સહાયની જરૂર છે?';

  @override
  String get emailSupportAddress => 'ઈમેલ support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'વારંવાર પુછાતા પ્રશ્નો';

  @override
  String get noFaqsAvailable => 'હાલમાં કોઈ FAQ ઉપલબ્ધ નથી.';
}
