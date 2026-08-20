// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'राहमित्र';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get signOut => 'साइन आउट करा';

  @override
  String get profile => 'प्रोफाइल';

  @override
  String get fullName => 'पूर्ण नाव';

  @override
  String get noNameSet => 'नाव सेट केलेले नाही';

  @override
  String get nameCannotBeEmpty => 'नाव रिकामे असू शकत नाही.';

  @override
  String get couldNotSaveChangesTryAgain =>
      'बदल जतन करता आले नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String get signOutQuestion => 'साइन आउट करायचे?';

  @override
  String get signOutBody =>
      'सुरू ठेवण्यासाठी तुम्हाला पुन्हा लॉग इन करावे लागेल.';

  @override
  String get personalInformation => 'वैयक्तिक माहिती';

  @override
  String get addresses => 'पत्ते';

  @override
  String get paymentMethods => 'पेमेंट पद्धती';

  @override
  String get notifications => 'सूचना';

  @override
  String get notificationSettings => 'सूचना सेटिंग्ज';

  @override
  String get language => 'भाषा';

  @override
  String get changePassword => 'पासवर्ड बदला';

  @override
  String get helpAndSupport => 'मदत आणि समर्थन';

  @override
  String get about => 'अ‍ॅपबद्दल';

  @override
  String get enterValidEmail => 'वैध ईमेल पत्ता टाका.';

  @override
  String get enterYourPassword => 'तुमचा पासवर्ड टाका.';

  @override
  String get couldNotLogInTryAgain =>
      'लॉग इन करता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get passwordMinLength => 'पासवर्ड किमान 6 अक्षरांचा असावा.';

  @override
  String get passwordsDoNotMatch => 'पासवर्ड जुळत नाहीत.';

  @override
  String get couldNotCreateAccountTryAgain =>
      'तुमचे खाते तयार करता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get notVerifiedYetTapLink =>
      'अजून सत्यापित नाही - आम्ही पाठवलेल्या ईमेलमधील लिंकवर टॅप करा.';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'सत्यापन स्थिती तपासता आली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get couldNotResendEmailTryAgain =>
      'ईमेल पुन्हा पाठवता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get couldNotSendCodeTryAgain =>
      'कोड पाठवता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get enterSixDigitCode => '6-अंकी कोड टाका.';

  @override
  String get incorrectOrExpiredCode => 'चुकीचा किंवा कालबाह्य कोड.';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'तो कोड सत्यापित करता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get enterEmailFirstThenForgot =>
      'आधी वर तुमचा ईमेल टाका, नंतर \"पासवर्ड विसरलात?\" वर टॅप करा.';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'पासवर्ड रीसेट लिंक $email वर पाठवली';
  }

  @override
  String get enterValidMobileNumber => 'वैध 10-अंकी मोबाइल नंबर टाका.';

  @override
  String get accountExistsForEmailTryLogin =>
      'त्या ईमेलसाठी आधीच खाते अस्तित्वात आहे. त्याऐवजी लॉग इन करून पहा.';

  @override
  String get emailLooksInvalid => 'तो ईमेल पत्ता अवैध वाटतो.';

  @override
  String get chooseStrongerPassword => 'अधिक मजबूत पासवर्ड निवडा.';

  @override
  String get incorrectEmailOrPassword => 'चुकीचा ईमेल किंवा पासवर्ड.';

  @override
  String get tooManyAttemptsTryAgain =>
      'खूप जास्त प्रयत्न. थोड्या वेळाने पुन्हा प्रयत्न करा.';

  @override
  String get phoneNumberLooksInvalid => 'तो फोन नंबर अवैध वाटतो.';

  @override
  String get codeExpiredRequestNew => 'तो कोड कालबाह्य झाला - नवीन विनंती करा.';

  @override
  String get somethingWentWrongTryAgain =>
      'काहीतरी चूक झाली. पुन्हा प्रयत्न करा.';

  @override
  String get verifyYourNumber => 'तुमचा नंबर सत्यापित करा';

  @override
  String get welcomeExclaim => 'स्वागत आहे!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'आम्ही +91 $phone वर 6-अंकी कोड पाठवला आहे';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'तुमच्या मोबाइल नंबरने लॉग इन किंवा साइन अप करा';

  @override
  String get welcomeBack => 'पुन्हा स्वागत आहे!';

  @override
  String get createAccount => 'खाते तयार करा';

  @override
  String get verifyYourEmail => 'तुमचा ईमेल सत्यापित करा';

  @override
  String get logInWithEmailToContinue =>
      'सुरू ठेवण्यासाठी तुमच्या ईमेलने लॉग इन करा';

  @override
  String get signUpWithEmailToGetStarted =>
      'सुरुवात करण्यासाठी तुमच्या ईमेलने साइन अप करा';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'आम्ही $email वर सत्यापन लिंक पाठवली आहे';
  }

  @override
  String get emailAddress => 'ईमेल पत्ता';

  @override
  String get password => 'पासवर्ड';

  @override
  String get forgotPassword => 'पासवर्ड विसरलात?';

  @override
  String get logIn => 'लॉग इन करा';

  @override
  String get dontHaveAccountSignUp => 'खाते नाही? साइन अप करा';

  @override
  String get emailMethod => 'ईमेल';

  @override
  String get phoneMethod => 'फोन';

  @override
  String get sixDigitCode => '6-अंकी कोड';

  @override
  String get verifyAndContinue => 'सत्यापित करा आणि सुरू ठेवा';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds सेकंदात कोड पुन्हा पाठवा';
  }

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String get tenDigitMobileNumber => '10-अंकी मोबाइल नंबर';

  @override
  String get sendOtp => 'OTP पाठवा';

  @override
  String get passwordMinCharsHint => 'पासवर्ड (किमान 6 अक्षरे)';

  @override
  String get confirmPassword => 'पासवर्डची पुष्टी करा';

  @override
  String get signUp => 'साइन अप करा';

  @override
  String get alreadyHaveAccountLogIn => 'आधीच खाते आहे? लॉग इन करा';

  @override
  String get sendCode => 'कोड पाठवा';

  @override
  String get verifyCode => 'कोड सत्यापित करा';

  @override
  String get useLinkInstead => 'त्याऐवजी लिंक वापरा';

  @override
  String get iveVerifiedMyEmail => 'मी माझा ईमेल सत्यापित केला आहे';

  @override
  String get verificationEmailSentAgain => 'सत्यापन ईमेल पुन्हा पाठवला';

  @override
  String get resendVerificationEmail => 'सत्यापन ईमेल पुन्हा पाठवा';

  @override
  String get enterCodeInstead => 'त्याऐवजी कोड टाका';

  @override
  String get onboardingTitle1 => 'सोपी शिपिंग,\nस्मार्ट व्यवसाय';

  @override
  String get onboardingBody1 =>
      'स्मार्ट शिपिंग वेळ वाचवते, खर्च कमी करते\nआणि व्यवसाय जलद वाढवते.';

  @override
  String get onboardingTitle2 => 'लाइव्ह ट्रॅक करा,\nदारापर्यंत';

  @override
  String get onboardingBody2 =>
      'नकाशावर तुमचा ड्रायव्हर जवळ येताना पहा\nरिअल-टाइम ETA अपडेटसह.';

  @override
  String get onboardingTitle3 => 'तुमच्या पद्धतीने पैसे द्या,\nप्रत्येक वेळी';

  @override
  String get onboardingBody3 =>
      'UPI, कार्ड, नेट बँकिंग किंवा वॉलेट -\nतुमची निवड, प्रत्येक बुकिंगमध्ये.';

  @override
  String get getStarted => 'सुरू करा';

  @override
  String get next => 'पुढे';

  @override
  String get pressBackAgainToExit => 'बाहेर पडण्यासाठी पुन्हा बॅक दाबा';

  @override
  String get view => 'पहा';

  @override
  String get home => 'होम';

  @override
  String get orders => 'ऑर्डर्स';

  @override
  String get couldNotLoadYourBookings =>
      'तुमच्या बुकिंग्ज लोड करता आल्या नाहीत.';

  @override
  String heyNameWave(String name) {
    return 'नमस्कार $name 👋';
  }

  @override
  String get thereFallbackName => 'जी';

  @override
  String get whereAreWeShippingToday => 'आज आपण कुठे शिप करत आहोत?';

  @override
  String get searchShipmentsHint => 'वेबिल किंवा पत्त्याने शिपमेंट शोधा';

  @override
  String get bookNewShipment => 'नवीन शिपमेंट बुक करा';

  @override
  String get getInstantPriceBookDelivery =>
      'त्वरित किंमत मिळवा आणि तुमची डिलिव्हरी बुक करा';

  @override
  String get priceCalculator => 'किंमत कॅल्क्युलेटर';

  @override
  String get myOrders => 'माझे ऑर्डर्स';

  @override
  String get support => 'सहाय्य';

  @override
  String get searchResults => 'शोध निकाल';

  @override
  String get recentOrders => 'अलीकडील ऑर्डर्स';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String noShipmentsMatch(String query) {
    return '\"$query\" शी जुळणारे कोणतेही शिपमेंट नाही.';
  }

  @override
  String get noBookingsYetTapAway =>
      'अजून कोणतीही बुकिंग नाही - तुमची पहिली बुकिंग फक्त एक टॅप दूर आहे.';

  @override
  String get statusPaymentPending => 'पेमेंट प्रलंबित';

  @override
  String get statusPending => 'प्रलंबित';

  @override
  String get statusAccepted => 'स्वीकारले';

  @override
  String get statusInTransit => 'वाहतुकीत';

  @override
  String get statusAwaitingPayment => 'पेमेंटच्या प्रतीक्षेत';

  @override
  String get statusDelivered => 'वितरित झाले';

  @override
  String get statusCancelled => 'रद्द केले';

  @override
  String get raahmitrCustomerAppLine => 'राहमित्र कस्टमर अ‍ॅप';

  @override
  String versionNumber(String number) {
    return 'आवृत्ती $number';
  }

  @override
  String get couldNotLoadNotificationSettings =>
      'सूचना सेटिंग्ज लोड करता आल्या नाहीत.';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'सूचना प्राधान्य अपडेट करता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get devicePermission => 'डिव्हाइस परवानगी';

  @override
  String get notificationsAllowedOnDevice =>
      'या डिव्हाइसवर सूचनांना परवानगी आहे.';

  @override
  String get notificationsNotAllowedWarning =>
      'सूचनांना परवानगी नाही - तुम्ही त्या सक्षम करेपर्यंत बुकिंग आणि डिलिव्हरी अपडेट्स तुमच्यापर्यंत पोहोचणार नाहीत.';

  @override
  String get enableNotifications => 'सूचना सक्षम करा';

  @override
  String get notificationsBlockedManualEnableHint =>
      'त्यावर टॅप केल्यावर काही होत नसेल, तर तुमच्या फोनने आधीच हे अ‍ॅप ब्लॉक केले आहे - ते तुमच्या फोनच्या Settings > Apps > Notifications मध्ये मॅन्युअली सक्षम करा.';

  @override
  String get pushNotifications => 'पुश सूचना';

  @override
  String get pushNotificationsDescription =>
      'बुकिंग अपडेट्स, ड्रायव्हर असाइनमेंट आणि डिलिव्हरी पुष्टीकरणे.';

  @override
  String get saved => 'जतन केले.';

  @override
  String get email => 'ईमेल';

  @override
  String get phone => 'फोन';

  @override
  String get businessGstinOptional => 'व्यवसाय GSTIN (ऐच्छिक)';

  @override
  String get usedOnInvoicesIfAny =>
      'तुमच्याकडे असल्यास, हे तुमच्या बुकिंग इनव्हॉइसवर वापरले जाते.';

  @override
  String get saveChanges => 'बदल जतन करा';

  @override
  String get couldNotLoadYourAddresses => 'तुमचे पत्ते लोड करता आले नाहीत.';

  @override
  String get addAddress => 'पत्ता जोडा';

  @override
  String get editAddress => 'पत्ता संपादित करा';

  @override
  String get labelHint => 'लेबल (उदा. घर, कार्यालय)';

  @override
  String get fullAddress => 'पूर्ण पत्ता';

  @override
  String get couldNotSaveThisAddress => 'हा पत्ता जतन करता आला नाही.';

  @override
  String get couldNotRemoveThisAddress => 'हा पत्ता काढून टाकता आला नाही.';

  @override
  String get noSavedAddressesYet =>
      'अजून कोणताही जतन केलेला पत्ता नाही - एक जोडण्यासाठी + टॅप करा.';

  @override
  String get edit => 'संपादित करा';

  @override
  String get delete => 'काढून टाका';

  @override
  String get couldNotLoadPaymentHistory => 'पेमेंट इतिहास लोड करता आला नाही.';

  @override
  String get removeCardQuestion => 'कार्ड काढायचे?';

  @override
  String removeCardConfirm(String network, String last4) {
    return '$last4 ने संपणारे $network कार्ड काढायचे?';
  }

  @override
  String get remove => 'काढा';

  @override
  String get couldNotRemoveThatCard => 'ते कार्ड काढता आले नाही.';

  @override
  String get savedCards => 'जतन केलेली कार्ड्स';

  @override
  String get noSavedCardsYet =>
      'अजून कोणतेही जतन केलेले कार्ड नाही - तुमच्या पुढील पेमेंट दरम्यान \"हे कार्ड जतन करा\" तपासा.';

  @override
  String get transactionHistory => 'व्यवहार इतिहास';

  @override
  String get noPaymentsYet => 'अजून कोणतेही पेमेंट नाही.';

  @override
  String get enterCurrentPassword => 'तुमचा सध्याचा पासवर्ड टाका.';

  @override
  String get newPasswordMinLength => 'नवीन पासवर्ड किमान 6 अक्षरांचा असावा.';

  @override
  String get newPasswordsDoNotMatch => 'नवीन पासवर्ड जुळत नाहीत.';

  @override
  String get passwordUpdated => 'पासवर्ड अपडेट झाला';

  @override
  String get currentPasswordIncorrect => 'सध्याचा पासवर्ड चुकीचा आहे.';

  @override
  String get couldNotUpdatePassword => 'पासवर्ड अपडेट करता आला नाही.';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'पासवर्ड अपडेट करता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get currentPassword => 'सध्याचा पासवर्ड';

  @override
  String get newPassword => 'नवीन पासवर्ड';

  @override
  String get confirmNewPassword => 'नवीन पासवर्डची पुष्टी करा';

  @override
  String get updatePassword => 'पासवर्ड अपडेट करा';

  @override
  String get couldNotLoadHelpContent => 'मदत सामग्री लोड करता आली नाही.';

  @override
  String get needMoreHelp => 'अधिक मदत हवी आहे?';

  @override
  String get emailSupportAddress => 'ईमेल support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'वारंवार विचारले जाणारे प्रश्न';

  @override
  String get noFaqsAvailable => 'सध्या कोणतेही FAQ उपलब्ध नाहीत.';

  @override
  String get turnOnLocationServices =>
      'तुमचे सध्याचे स्थान वापरण्यासाठी लोकेशन सेवा चालू करा.';

  @override
  String get locationPermissionRequired =>
      'तुमचे सध्याचे स्थान वापरण्यासाठी लोकेशन परवानगी आवश्यक आहे.';

  @override
  String get couldNotDetermineAddressTryAgain =>
      'तुमचा पत्ता निश्चित करता आला नाही. पुन्हा प्रयत्न करा.';

  @override
  String get couldNotGetCurrentLocationTryAgain =>
      'तुमचे सध्याचे स्थान मिळू शकले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get enterBothPickupAndDrop => 'पिकअप आणि ड्रॉप दोन्ही स्थाने टाका.';

  @override
  String get pickupDropCannotBeSame =>
      'पिकअप आणि ड्रॉप एकच ठिकाण असू शकत नाही.';

  @override
  String get couldNotVerifyAddressPickSuggestion =>
      'यापैकी एक पत्ता सत्यापित करता आला नाही. यादीतून एखादे सुचवलेले निवडा, किंवा पिकअपसाठी सध्याचे स्थान वापरा.';

  @override
  String get whereTo => 'कुठे जायचे?';

  @override
  String get pickupLocation => 'पिकअप स्थान';

  @override
  String get dropLocation => 'ड्रॉप स्थान';

  @override
  String get continueLabel => 'सुरू ठेवा';

  @override
  String get bookingConfirmed => 'बुकिंग निश्चित झाले!';

  @override
  String get shipmentBookedSuccessfully =>
      'तुमची शिपमेंट यशस्वीरित्या बुक झाली आहे.';

  @override
  String get estimatedPrice => 'अंदाजे किंमत';

  @override
  String payAdvanceNowCashAtDelivery(String advance, String remaining) {
    return 'आत्ता ₹$advance आणि डिलिव्हरीच्या वेळी रोखीने ₹$remaining भरा';
  }

  @override
  String payCashAtDeliveryNoAdvance(String amount) {
    return 'डिलिव्हरीच्या वेळी रोखीने ₹$amount भरा - कोणतेही अ‍ॅडव्हान्स आवश्यक नाही';
  }

  @override
  String payAdvanceNowRemainingOnlineNearDelivery(
      String advance, String remaining) {
    return 'आत्ता ₹$advance भरा, उर्वरित ₹$remaining डिलिव्हरीच्या वेळी ऑनलाइन देय आहे';
  }

  @override
  String get trackShipment => 'शिपमेंट ट्रॅक करा';

  @override
  String get trackShipmentAvailableOnceAdvanceConfirmed =>
      'तुमचे अ‍ॅडव्हान्स पेमेंट निश्चित झाल्यावर शिपमेंट ट्रॅक करणे उपलब्ध होईल.';

  @override
  String get backToHome => 'होमवर परत जा';

  @override
  String get bodyTypeBike => 'बाईक';

  @override
  String get bodyTypeAuto => 'ऑटो';

  @override
  String get bodyTypeOpen => 'उघडे';

  @override
  String get bodyTypeContainer => 'कंटेनर';

  @override
  String get bodyTypeTrailer => 'ट्रेलर';

  @override
  String get filterByCargoWeight => 'कार्गो वजनानुसार फिल्टर करा';

  @override
  String get weightKgFieldLabel => 'वजन (किलो)';

  @override
  String get weightFilterChipLabel => 'वजन';

  @override
  String weightKgChipValue(String weight) {
    return '$weight किलो';
  }

  @override
  String get clear => 'साफ करा';

  @override
  String get apply => 'लागू करा';

  @override
  String get selectVehicle => 'वाहन निवडा';

  @override
  String get couldNotLoadVehicleTypes =>
      'वाहन प्रकार लोड करता आले नाहीत. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get noVehicleTypesAvailable =>
      'सध्या कोणतेही वाहन प्रकार उपलब्ध नाहीत.';

  @override
  String get noVehiclesMatchThisWeight =>
      'या श्रेणीमध्ये या वजनाशी जुळणारे कोणतेही वाहन नाही.';

  @override
  String get goodsTypeGeneralCargo => 'सामान्य माल';

  @override
  String get goodsTypeFurniture => 'फर्निचर';

  @override
  String get goodsTypeElectronics => 'इलेक्ट्रॉनिक्स';

  @override
  String get goodsTypeFoodGroceries => 'अन्न आणि किराणा';

  @override
  String get goodsTypeDocuments => 'कागदपत्रे';

  @override
  String get goodsTypeIndustrialEquipment => 'औद्योगिक उपकरणे';

  @override
  String get goodsTypeOther => 'इतर';

  @override
  String get enterValidWeightKg => 'किलोमध्ये वैध वजन टाका.';

  @override
  String vehicleCanCarryUpTo(String name, String maxWeight) {
    return '$name जास्तीत जास्त $maxWeightकिलो पर्यंत वाहून नेऊ शकते - मोठे वाहन निवडा किंवा वजन कमी करा.';
  }

  @override
  String get couldNotGetFareEstimateTryAgain =>
      'भाडे अंदाज मिळू शकला नाही. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get loadDetails => 'लोड तपशील';

  @override
  String get goodsType => 'मालाचा प्रकार';

  @override
  String get fragile => 'नाजूक';

  @override
  String get fragileSubtitle => 'हाताळणी दरम्यान अतिरिक्त काळजी';

  @override
  String get addInsurance => 'विमा जोडा';

  @override
  String get addInsuranceSubtitle =>
      'वाहतुकीदरम्यान नुकसान किंवा हानी कव्हर करते';

  @override
  String get receiverDetails => 'प्राप्तकर्ता तपशील';

  @override
  String get receiverDetailsSubtitle =>
      'ऐच्छिक - तुमच्या इनव्हॉइस/वेबिलमध्ये भरले जाते';

  @override
  String get receiversName => 'प्राप्तकर्त्याचे नाव';

  @override
  String get receiversPhone => 'प्राप्तकर्त्याचा फोन';

  @override
  String get receiversGstinOptional => 'प्राप्तकर्त्याचा GSTIN (ऐच्छिक)';

  @override
  String get getFareEstimate => 'भाडे अंदाज मिळवा';

  @override
  String get couldNotConfirmBookingTryAgain =>
      'ही बुकिंग निश्चित करता आली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get priceSummary => 'किंमत सारांश';

  @override
  String get noEstimateFoundForBooking =>
      'या बुकिंगसाठी कोणताही अंदाज सापडला नाही.';

  @override
  String get startNewBooking => 'नवीन बुकिंग सुरू करा';

  @override
  String get vehicleLabel => 'वाहन';

  @override
  String get distanceLabel => 'अंतर';

  @override
  String get weightLabel => 'वजन';

  @override
  String get fareBreakdown => 'भाडे तपशील';

  @override
  String get baseFare => 'मूळ भाडे';

  @override
  String get distanceCharge => 'अंतर शुल्क';

  @override
  String get weightCharge => 'वजन शुल्क';

  @override
  String surgeMultiplierLabel(String multiplier) {
    return 'सर्ज (${multiplier}x)';
  }

  @override
  String get totalAmount => 'एकूण रक्कम';

  @override
  String get finalAmountMayVarySlightly => 'अंतिम रक्कम थोडी वेगळी असू शकते';

  @override
  String get confirmBooking => 'बुकिंग निश्चित करा';

  @override
  String get paymentMethod => 'पेमेंट पद्धत';

  @override
  String get payOnline => 'ऑनलाइन पेमेंट करा';

  @override
  String payOnlineAdvanceSubtitle(String advance, String remaining) {
    return 'आत्ता ऑनलाइन ₹$advance देय, उर्वरित ₹$remaining डिलिव्हरीच्या वेळी ऑनलाइन देय';
  }

  @override
  String get payOnlineFullSubtitle => 'कार्ड/UPI द्वारे आत्ता पूर्ण रक्कम भरा';

  @override
  String get cashOnDelivery => 'डिलिव्हरीच्या वेळी रोख पेमेंट';

  @override
  String codAdvanceSubtitle(String advance, String remaining) {
    return 'आत्ता ऑनलाइन ₹$advance देय, उर्वरित ₹$remaining डिलिव्हरीच्या वेळी रोखीने';
  }

  @override
  String get codFullSubtitle => 'डिलिव्हरीच्या वेळी रोखीने पूर्ण रक्कम भरा';

  @override
  String get enterBothPickupDropLocations =>
      'पिकअप आणि ड्रॉप दोन्ही स्थाने टाका.';

  @override
  String get selectAVehicleType => 'एक वाहन प्रकार निवडा.';

  @override
  String vehicleCanCarryUpToShort(String name, String maxWeight) {
    return '$name जास्तीत जास्त $maxWeight किलो पर्यंत वाहून नेऊ शकते.';
  }

  @override
  String get couldNotCalculatePriceTryAgain =>
      'किंमतीची गणना करता आली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get vehicleTypeLabel => 'वाहन प्रकार';

  @override
  String get couldNotLoadVehicleTypesShort => 'वाहन प्रकार लोड करता आले नाहीत.';

  @override
  String get weightKgOptionalHint => 'वजन (किलो) - ऐच्छिक';

  @override
  String get calculate => 'गणना करा';

  @override
  String get recalculate => 'पुन्हा गणना करा';

  @override
  String get estimatedFare => 'अंदाजे भाडे';

  @override
  String get thisIsOnlyEstimateNotBooking =>
      'हा फक्त एक अंदाज आहे - बुकिंग नाही.';
}
