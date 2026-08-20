// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hindi (`hi`).
class AppLocalizationsHi extends AppLocalizations {
  AppLocalizationsHi([String locale = 'hi']) : super(locale);

  @override
  String get appTitle => 'राहमित्र';

  @override
  String get cancel => 'रद्द करें';

  @override
  String get save => 'सहेजें';

  @override
  String get signOut => 'साइन आउट करें';

  @override
  String get profile => 'प्रोफ़ाइल';

  @override
  String get fullName => 'पूरा नाम';

  @override
  String get noNameSet => 'कोई नाम सेट नहीं है';

  @override
  String get nameCannotBeEmpty => 'नाम खाली नहीं हो सकता।';

  @override
  String get couldNotSaveChangesTryAgain =>
      'बदलाव सहेजे नहीं जा सके। फिर से कोशिश करें।';

  @override
  String get signOutQuestion => 'साइन आउट करें?';

  @override
  String get signOutBody => 'जारी रखने के लिए आपको फिर से लॉग इन करना होगा।';

  @override
  String get personalInformation => 'व्यक्तिगत जानकारी';

  @override
  String get addresses => 'पते';

  @override
  String get paymentMethods => 'भुगतान के तरीके';

  @override
  String get notifications => 'सूचनाएं';

  @override
  String get notificationSettings => 'सूचना सेटिंग्स';

  @override
  String get language => 'भाषा';

  @override
  String get changePassword => 'पासवर्ड बदलें';

  @override
  String get helpAndSupport => 'सहायता और समर्थन';

  @override
  String get about => 'ऐप के बारे में';

  @override
  String get enterValidEmail => 'एक मान्य ईमेल पता दर्ज करें।';

  @override
  String get enterYourPassword => 'अपना पासवर्ड दर्ज करें।';

  @override
  String get couldNotLogInTryAgain => 'लॉग इन नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get passwordMinLength => 'पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड मेल नहीं खाते।';

  @override
  String get couldNotCreateAccountTryAgain =>
      'आपका खाता नहीं बनाया जा सका। फिर से कोशिश करें।';

  @override
  String get notVerifiedYetTapLink =>
      'अभी सत्यापित नहीं हुआ - हमने भेजे गए ईमेल में लिंक पर टैप करें।';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'सत्यापन स्थिति जांची नहीं जा सकी। फिर से कोशिश करें।';

  @override
  String get couldNotResendEmailTryAgain =>
      'ईमेल दोबारा नहीं भेजा जा सका। फिर से कोशिश करें।';

  @override
  String get couldNotSendCodeTryAgain =>
      'कोड नहीं भेजा जा सका। फिर से कोशिश करें।';

  @override
  String get enterSixDigitCode => '6 अंकों का कोड दर्ज करें।';

  @override
  String get incorrectOrExpiredCode => 'गलत या समय-सीमा समाप्त कोड।';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'वह कोड सत्यापित नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get enterEmailFirstThenForgot =>
      'पहले ऊपर अपना ईमेल दर्ज करें, फिर \"पासवर्ड भूल गए?\" पर टैप करें।';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'पासवर्ड रीसेट लिंक $email पर भेजा गया';
  }

  @override
  String get enterValidMobileNumber =>
      'एक मान्य 10-अंकीय मोबाइल नंबर दर्ज करें।';

  @override
  String get accountExistsForEmailTryLogin =>
      'उस ईमेल के लिए पहले से ही एक खाता मौजूद है। इसके बजाय लॉग इन करने का प्रयास करें।';

  @override
  String get emailLooksInvalid => 'वह ईमेल पता अमान्य लगता है।';

  @override
  String get chooseStrongerPassword => 'एक मज़बूत पासवर्ड चुनें।';

  @override
  String get incorrectEmailOrPassword => 'गलत ईमेल या पासवर्ड।';

  @override
  String get tooManyAttemptsTryAgain =>
      'बहुत अधिक प्रयास। कुछ देर बाद फिर से कोशिश करें।';

  @override
  String get phoneNumberLooksInvalid => 'वह फ़ोन नंबर अमान्य लगता है।';

  @override
  String get codeExpiredRequestNew =>
      'वह कोड समाप्त हो गया - एक नया अनुरोध करें।';

  @override
  String get somethingWentWrongTryAgain =>
      'कुछ गड़बड़ हो गई। फिर से कोशिश करें।';

  @override
  String get verifyYourNumber => 'अपना नंबर सत्यापित करें';

  @override
  String get welcomeExclaim => 'स्वागत है!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'हमने +91 $phone पर 6 अंकों का कोड भेजा है';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'अपने मोबाइल नंबर से लॉग इन या साइन अप करें';

  @override
  String get welcomeBack => 'वापसी पर स्वागत है!';

  @override
  String get createAccount => 'खाता बनाएं';

  @override
  String get verifyYourEmail => 'अपना ईमेल सत्यापित करें';

  @override
  String get logInWithEmailToContinue =>
      'जारी रखने के लिए अपने ईमेल से लॉग इन करें';

  @override
  String get signUpWithEmailToGetStarted =>
      'शुरू करने के लिए अपने ईमेल से साइन अप करें';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'हमने $email पर एक सत्यापन लिंक भेजा है';
  }

  @override
  String get emailAddress => 'ईमेल पता';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड भूल गए?';

  @override
  String get logIn => 'लॉग इन करें';

  @override
  String get dontHaveAccountSignUp => 'खाता नहीं है? साइन अप करें';

  @override
  String get emailMethod => 'ईमेल';

  @override
  String get phoneMethod => 'फ़ोन';

  @override
  String get sixDigitCode => '6 अंकों का कोड';

  @override
  String get verifyAndContinue => 'सत्यापित करें और जारी रखें';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds सेकंड में कोड फिर से भेजें';
  }

  @override
  String get resendCode => 'कोड फिर से भेजें';

  @override
  String get tenDigitMobileNumber => '10-अंकीय मोबाइल नंबर';

  @override
  String get sendOtp => 'OTP भेजें';

  @override
  String get passwordMinCharsHint => 'पासवर्ड (न्यूनतम 6 अक्षर)';

  @override
  String get confirmPassword => 'पासवर्ड की पुष्टि करें';

  @override
  String get signUp => 'साइन अप करें';

  @override
  String get alreadyHaveAccountLogIn => 'पहले से खाता है? लॉग इन करें';

  @override
  String get sendCode => 'कोड भेजें';

  @override
  String get verifyCode => 'कोड सत्यापित करें';

  @override
  String get useLinkInstead => 'इसके बजाय लिंक का उपयोग करें';

  @override
  String get iveVerifiedMyEmail => 'मैंने अपना ईमेल सत्यापित कर लिया है';

  @override
  String get verificationEmailSentAgain => 'सत्यापन ईमेल फिर से भेजा गया';

  @override
  String get resendVerificationEmail => 'सत्यापन ईमेल फिर से भेजें';

  @override
  String get enterCodeInstead => 'इसके बजाय कोड दर्ज करें';

  @override
  String get onboardingTitle1 => 'आसान शिपिंग,\nस्मार्ट बिज़नेस';

  @override
  String get onboardingBody1 =>
      'स्मार्ट शिपिंग समय बचाती है, लागत घटाती है\nऔर व्यवसाय को तेज़ी से बढ़ाती है।';

  @override
  String get onboardingTitle2 => 'लाइव ट्रैक करें,\nदरवाज़े तक';

  @override
  String get onboardingBody2 =>
      'मैप पर अपने ड्राइवर को आते हुए देखें\nरियल-टाइम ETA अपडेट के साथ।';

  @override
  String get onboardingTitle3 => 'अपने तरीके से भुगतान करें,\nहर बार';

  @override
  String get onboardingBody3 =>
      'UPI, कार्ड, नेट बैंकिंग या वॉलेट -\nआपकी पसंद, हर बुकिंग में।';

  @override
  String get getStarted => 'शुरू करें';

  @override
  String get next => 'आगे';

  @override
  String get pressBackAgainToExit => 'बाहर निकलने के लिए फिर से बैक दबाएं';

  @override
  String get view => 'देखें';

  @override
  String get home => 'होम';

  @override
  String get orders => 'ऑर्डर';

  @override
  String get couldNotLoadYourBookings => 'आपकी बुकिंग लोड नहीं हो सकीं।';

  @override
  String heyNameWave(String name) {
    return 'नमस्ते $name 👋';
  }

  @override
  String get thereFallbackName => 'जी';

  @override
  String get whereAreWeShippingToday => 'आज हम कहां शिप कर रहे हैं?';

  @override
  String get searchShipmentsHint => 'वेबिल या पते से शिपमेंट खोजें';

  @override
  String get bookNewShipment => 'नई शिपमेंट बुक करें';

  @override
  String get getInstantPriceBookDelivery =>
      'तुरंत कीमत पाएं और अपनी डिलीवरी बुक करें';

  @override
  String get priceCalculator => 'मूल्य कैलकुलेटर';

  @override
  String get myOrders => 'मेरे ऑर्डर';

  @override
  String get support => 'सहायता';

  @override
  String get searchResults => 'खोज परिणाम';

  @override
  String get recentOrders => 'हाल के ऑर्डर';

  @override
  String get viewAll => 'सभी देखें';

  @override
  String noShipmentsMatch(String query) {
    return '\"$query\" से मेल खाने वाला कोई शिपमेंट नहीं।';
  }

  @override
  String get noBookingsYetTapAway =>
      'अभी तक कोई बुकिंग नहीं - आपकी पहली बुकिंग बस एक टैप दूर है।';

  @override
  String get statusPaymentPending => 'भुगतान लंबित';

  @override
  String get statusPending => 'लंबित';

  @override
  String get statusAccepted => 'स्वीकृत';

  @override
  String get statusInTransit => 'ट्रांज़िट में';

  @override
  String get statusAwaitingPayment => 'भुगतान की प्रतीक्षा में';

  @override
  String get statusDelivered => 'डिलीवर हो गया';

  @override
  String get statusCancelled => 'रद्द किया गया';

  @override
  String get raahmitrCustomerAppLine => 'राहमित्र कस्टमर ऐप';

  @override
  String versionNumber(String number) {
    return 'वर्शन $number';
  }

  @override
  String get couldNotLoadNotificationSettings =>
      'सूचना सेटिंग्स लोड नहीं हो सकीं।';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'सूचना प्राथमिकता अपडेट नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get devicePermission => 'डिवाइस अनुमति';

  @override
  String get notificationsAllowedOnDevice =>
      'इस डिवाइस पर सूचनाओं की अनुमति है।';

  @override
  String get notificationsNotAllowedWarning =>
      'सूचनाओं की अनुमति नहीं है - जब तक आप इन्हें सक्षम नहीं करते, बुकिंग और डिलीवरी अपडेट आप तक नहीं पहुंचेंगे।';

  @override
  String get enableNotifications => 'सूचनाएं सक्षम करें';

  @override
  String get notificationsBlockedManualEnableHint =>
      'अगर उस पर टैप करने पर कुछ नहीं होता, तो आपके फ़ोन ने पहले ही इस ऐप को ब्लॉक कर दिया है - इसे अपने फ़ोन की Settings > Apps > Notifications में मैन्युअल रूप से सक्षम करें।';

  @override
  String get pushNotifications => 'पुश सूचनाएं';

  @override
  String get pushNotificationsDescription =>
      'बुकिंग अपडेट, ड्राइवर असाइनमेंट और डिलीवरी पुष्टि।';

  @override
  String get saved => 'सहेजा गया।';

  @override
  String get email => 'ईमेल';

  @override
  String get phone => 'फ़ोन';

  @override
  String get businessGstinOptional => 'बिज़नेस GSTIN (वैकल्पिक)';

  @override
  String get usedOnInvoicesIfAny =>
      'यदि आपके पास एक है, तो यह आपके बुकिंग इनवॉइस पर उपयोग होता है।';

  @override
  String get saveChanges => 'बदलाव सहेजें';

  @override
  String get couldNotLoadYourAddresses => 'आपके पते लोड नहीं हो सके।';

  @override
  String get addAddress => 'पता जोड़ें';

  @override
  String get editAddress => 'पता संपादित करें';

  @override
  String get labelHint => 'लेबल (जैसे घर, कार्यालय)';

  @override
  String get fullAddress => 'पूरा पता';

  @override
  String get couldNotSaveThisAddress => 'यह पता सहेजा नहीं जा सका।';

  @override
  String get couldNotRemoveThisAddress => 'यह पता हटाया नहीं जा सका।';

  @override
  String get noSavedAddressesYet =>
      'अभी तक कोई सहेजा गया पता नहीं - एक जोड़ने के लिए + टैप करें।';

  @override
  String get edit => 'संपादित करें';

  @override
  String get delete => 'हटाएं';

  @override
  String get couldNotLoadPaymentHistory => 'भुगतान इतिहास लोड नहीं हो सका।';

  @override
  String get removeCardQuestion => 'कार्ड हटाएं?';

  @override
  String removeCardConfirm(String network, String last4) {
    return '$last4 पर समाप्त होने वाला $network कार्ड हटाएं?';
  }

  @override
  String get remove => 'हटाएं';

  @override
  String get couldNotRemoveThatCard => 'वह कार्ड हटाया नहीं जा सका।';

  @override
  String get savedCards => 'सहेजे गए कार्ड';

  @override
  String get noSavedCardsYet =>
      'अभी तक कोई सहेजा गया कार्ड नहीं - अपने अगले भुगतान के दौरान \"इस कार्ड को सहेजें\" चेक करें।';

  @override
  String get transactionHistory => 'लेनदेन इतिहास';

  @override
  String get noPaymentsYet => 'अभी तक कोई भुगतान नहीं।';

  @override
  String get enterCurrentPassword => 'अपना वर्तमान पासवर्ड दर्ज करें।';

  @override
  String get newPasswordMinLength =>
      'नया पासवर्ड कम से कम 6 अक्षरों का होना चाहिए।';

  @override
  String get newPasswordsDoNotMatch => 'नए पासवर्ड मेल नहीं खाते।';

  @override
  String get passwordUpdated => 'पासवर्ड अपडेट किया गया';

  @override
  String get currentPasswordIncorrect => 'वर्तमान पासवर्ड गलत है।';

  @override
  String get couldNotUpdatePassword => 'पासवर्ड अपडेट नहीं हो सका।';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'पासवर्ड अपडेट नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get currentPassword => 'वर्तमान पासवर्ड';

  @override
  String get newPassword => 'नया पासवर्ड';

  @override
  String get confirmNewPassword => 'नए पासवर्ड की पुष्टि करें';

  @override
  String get updatePassword => 'पासवर्ड अपडेट करें';

  @override
  String get couldNotLoadHelpContent => 'सहायता सामग्री लोड नहीं हो सकी।';

  @override
  String get needMoreHelp => 'अधिक सहायता चाहिए?';

  @override
  String get emailSupportAddress => 'ईमेल support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'अक्सर पूछे जाने वाले सवाल';

  @override
  String get noFaqsAvailable => 'अभी कोई FAQ उपलब्ध नहीं है।';

  @override
  String get turnOnLocationServices =>
      'अपने वर्तमान स्थान का उपयोग करने के लिए लोकेशन सेवाएं चालू करें।';

  @override
  String get locationPermissionRequired =>
      'आपके वर्तमान स्थान का उपयोग करने के लिए लोकेशन अनुमति आवश्यक है।';

  @override
  String get couldNotDetermineAddressTryAgain =>
      'आपका पता निर्धारित नहीं हो सका। फिर से कोशिश करें।';

  @override
  String get couldNotGetCurrentLocationTryAgain =>
      'आपका वर्तमान स्थान नहीं मिल सका। फिर से कोशिश करें।';

  @override
  String get enterBothPickupAndDrop => 'पिकअप और ड्रॉप दोनों स्थान दर्ज करें।';

  @override
  String get pickupDropCannotBeSame => 'पिकअप और ड्रॉप एक ही जगह नहीं हो सकते।';

  @override
  String get couldNotVerifyAddressPickSuggestion =>
      'इनमें से किसी एक पते को सत्यापित नहीं किया जा सका। सूची से कोई सुझाव चुनें, या पिकअप के लिए वर्तमान स्थान का उपयोग करें।';

  @override
  String get whereTo => 'कहाँ जाना है?';

  @override
  String get pickupLocation => 'पिकअप स्थान';

  @override
  String get dropLocation => 'ड्रॉप स्थान';

  @override
  String get continueLabel => 'जारी रखें';

  @override
  String get bookingConfirmed => 'बुकिंग की पुष्टि हो गई!';

  @override
  String get shipmentBookedSuccessfully =>
      'आपकी शिपमेंट सफलतापूर्वक बुक हो गई है।';

  @override
  String get estimatedPrice => 'अनुमानित कीमत';

  @override
  String payAdvanceNowCashAtDelivery(String advance, String remaining) {
    return 'अभी ₹$advance और डिलीवरी पर नकद में ₹$remaining भुगतान करें';
  }

  @override
  String payCashAtDeliveryNoAdvance(String amount) {
    return 'डिलीवरी पर नकद में ₹$amount भुगतान करें - कोई एडवांस आवश्यक नहीं';
  }

  @override
  String payAdvanceNowRemainingOnlineNearDelivery(
      String advance, String remaining) {
    return 'अभी ₹$advance भुगतान करें, शेष ₹$remaining डिलीवरी के समय ऑनलाइन देय है';
  }

  @override
  String get trackShipment => 'शिपमेंट ट्रैक करें';

  @override
  String get trackShipmentAvailableOnceAdvanceConfirmed =>
      'आपके एडवांस भुगतान की पुष्टि होने पर शिपमेंट ट्रैक करना उपलब्ध होगा।';

  @override
  String get backToHome => 'होम पर वापस जाएं';

  @override
  String get bodyTypeBike => 'बाइक';

  @override
  String get bodyTypeAuto => 'ऑटो';

  @override
  String get bodyTypeOpen => 'खुला';

  @override
  String get bodyTypeContainer => 'कंटेनर';

  @override
  String get bodyTypeTrailer => 'ट्रेलर';

  @override
  String get filterByCargoWeight => 'कार्गो वज़न के अनुसार फ़िल्टर करें';

  @override
  String get weightKgFieldLabel => 'वज़न (किग्रा)';

  @override
  String get weightFilterChipLabel => 'वज़न';

  @override
  String weightKgChipValue(String weight) {
    return '$weight किग्रा';
  }

  @override
  String get clear => 'साफ़ करें';

  @override
  String get apply => 'लागू करें';

  @override
  String get selectVehicle => 'वाहन चुनें';

  @override
  String get couldNotLoadVehicleTypes =>
      'वाहन प्रकार लोड नहीं हो सके। अपना कनेक्शन जांचें और फिर से कोशिश करें।';

  @override
  String get noVehicleTypesAvailable => 'अभी कोई वाहन प्रकार उपलब्ध नहीं है।';

  @override
  String get noVehiclesMatchThisWeight =>
      'इस श्रेणी में इस वज़न से मेल खाने वाला कोई वाहन नहीं है।';

  @override
  String get goodsTypeGeneralCargo => 'सामान्य माल';

  @override
  String get goodsTypeFurniture => 'फर्नीचर';

  @override
  String get goodsTypeElectronics => 'इलेक्ट्रॉनिक्स';

  @override
  String get goodsTypeFoodGroceries => 'खाद्य और किराना';

  @override
  String get goodsTypeDocuments => 'दस्तावेज़';

  @override
  String get goodsTypeIndustrialEquipment => 'औद्योगिक उपकरण';

  @override
  String get goodsTypeOther => 'अन्य';

  @override
  String get enterValidWeightKg => 'किग्रा में एक मान्य वज़न दर्ज करें।';

  @override
  String vehicleCanCarryUpTo(String name, String maxWeight) {
    return '$name अधिकतम $maxWeightकिग्रा तक ले जा सकता है - बड़ा वाहन चुनें या वज़न कम करें।';
  }

  @override
  String get couldNotGetFareEstimateTryAgain =>
      'किराया अनुमान नहीं मिल सका। अपना कनेक्शन जांचें और फिर से कोशिश करें।';

  @override
  String get loadDetails => 'लोड विवरण';

  @override
  String get goodsType => 'माल का प्रकार';

  @override
  String get fragile => 'नाज़ुक';

  @override
  String get fragileSubtitle => 'हैंडलिंग के दौरान अतिरिक्त सावधानी';

  @override
  String get addInsurance => 'बीमा जोड़ें';

  @override
  String get addInsuranceSubtitle => 'परिवहन में हानि या क्षति को कवर करता है';

  @override
  String get receiverDetails => 'प्राप्तकर्ता विवरण';

  @override
  String get receiverDetailsSubtitle =>
      'वैकल्पिक - आपके इनवॉइस/वेबिल में भरा जाता है';

  @override
  String get receiversName => 'प्राप्तकर्ता का नाम';

  @override
  String get receiversPhone => 'प्राप्तकर्ता का फ़ोन';

  @override
  String get receiversGstinOptional => 'प्राप्तकर्ता का GSTIN (वैकल्पिक)';

  @override
  String get getFareEstimate => 'किराया अनुमान प्राप्त करें';

  @override
  String get couldNotConfirmBookingTryAgain =>
      'इस बुकिंग की पुष्टि नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get priceSummary => 'मूल्य सारांश';

  @override
  String get noEstimateFoundForBooking =>
      'इस बुकिंग के लिए कोई अनुमान नहीं मिला।';

  @override
  String get startNewBooking => 'नई बुकिंग शुरू करें';

  @override
  String get vehicleLabel => 'वाहन';

  @override
  String get distanceLabel => 'दूरी';

  @override
  String get weightLabel => 'वज़न';

  @override
  String get fareBreakdown => 'किराया विवरण';

  @override
  String get baseFare => 'आधार किराया';

  @override
  String get distanceCharge => 'दूरी शुल्क';

  @override
  String get weightCharge => 'वज़न शुल्क';

  @override
  String surgeMultiplierLabel(String multiplier) {
    return 'सर्ज (${multiplier}x)';
  }

  @override
  String get totalAmount => 'कुल राशि';

  @override
  String get finalAmountMayVarySlightly => 'अंतिम राशि थोड़ी भिन्न हो सकती है';

  @override
  String get confirmBooking => 'बुकिंग की पुष्टि करें';

  @override
  String get paymentMethod => 'भुगतान का तरीका';

  @override
  String get payOnline => 'ऑनलाइन भुगतान करें';

  @override
  String payOnlineAdvanceSubtitle(String advance, String remaining) {
    return 'अभी ऑनलाइन ₹$advance देय, शेष ₹$remaining डिलीवरी के समय ऑनलाइन देय';
  }

  @override
  String get payOnlineFullSubtitle =>
      'कार्ड/UPI के माध्यम से अभी पूरी राशि भुगतान करें';

  @override
  String get cashOnDelivery => 'डिलीवरी पर नकद भुगतान';

  @override
  String codAdvanceSubtitle(String advance, String remaining) {
    return 'अभी ऑनलाइन ₹$advance देय, शेष ₹$remaining डिलीवरी पर नकद में';
  }

  @override
  String get codFullSubtitle => 'डिलीवरी पर नकद में पूरी राशि भुगतान करें';

  @override
  String get enterBothPickupDropLocations =>
      'पिकअप और ड्रॉप दोनों स्थान दर्ज करें।';

  @override
  String get selectAVehicleType => 'एक वाहन प्रकार चुनें।';

  @override
  String vehicleCanCarryUpToShort(String name, String maxWeight) {
    return '$name अधिकतम $maxWeight किग्रा तक ले जा सकता है।';
  }

  @override
  String get couldNotCalculatePriceTryAgain =>
      'कीमत की गणना नहीं हो सकी। फिर से कोशिश करें।';

  @override
  String get vehicleTypeLabel => 'वाहन प्रकार';

  @override
  String get couldNotLoadVehicleTypesShort => 'वाहन प्रकार लोड नहीं हो सके।';

  @override
  String get weightKgOptionalHint => 'वज़न (किग्रा) - वैकल्पिक';

  @override
  String get calculate => 'गणना करें';

  @override
  String get recalculate => 'फिर से गणना करें';

  @override
  String get estimatedFare => 'अनुमानित किराया';

  @override
  String get thisIsOnlyEstimateNotBooking =>
      'यह केवल एक अनुमान है - बुकिंग नहीं।';
}
