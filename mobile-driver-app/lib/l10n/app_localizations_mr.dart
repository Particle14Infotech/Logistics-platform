// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Marathi (`mr`).
class AppLocalizationsMr extends AppLocalizations {
  AppLocalizationsMr([String locale = 'mr']) : super(locale);

  @override
  String get appTitle => 'राहमित्र ड्रायव्हर';

  @override
  String get cancel => 'रद्द करा';

  @override
  String get save => 'जतन करा';

  @override
  String get signOut => 'साइन आउट करा';

  @override
  String get language => 'भाषा';

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
  String get chooseVehicleTypeAndNumber =>
      'वाहन प्रकार निवडा आणि वाहन क्रमांक टाका.';

  @override
  String get vehicleUpdatedPendingReapproval =>
      'वाहन अपडेट झाले - अ‍ॅडमिनद्वारे पुन्हा मंजुरी प्रलंबित आहे.';

  @override
  String get vehicleRegistrationNumber => 'वाहन नोंदणी क्रमांक';

  @override
  String get myDocuments => 'माझी कागदपत्रे';

  @override
  String get bankDetails => 'बँक तपशील';

  @override
  String get notifications => 'सूचना';

  @override
  String get notificationSettings => 'सूचना सेटिंग्ज';

  @override
  String get changePassword => 'पासवर्ड बदला';

  @override
  String get helpAndSupport => 'मदत आणि समर्थन';

  @override
  String get about => 'अ‍ॅपबद्दल';

  @override
  String get raahmitrDriverAppLine => 'राहमित्र ड्रायव्हर अ‍ॅप';

  @override
  String versionNumber(String number) {
    return 'आवृत्ती $number';
  }

  @override
  String get allFieldsAreRequired => 'सर्व फील्ड आवश्यक आहेत.';

  @override
  String get bankDetailsSaved => 'बँक तपशील जतन झाले.';

  @override
  String get couldNotSaveBankDetailsTryAgain =>
      'बँक तपशील जतन करता आले नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String get couldNotLoadYourDetails => 'तुमचे तपशील लोड करता आले नाहीत.';

  @override
  String get usedForWalletPayoutsHint =>
      'वॉलेट पेआउट्ससाठी वापरले जाते - हे तुमच्या प्रत्यक्ष बँक खात्याशी जुळत असल्याची खात्री करा.';

  @override
  String get accountHolderName => 'खातेधारकाचे नाव';

  @override
  String get asPerBankRecordsHint => 'बँक रेकॉर्डनुसार';

  @override
  String get accountNumber => 'खाते क्रमांक';

  @override
  String get ifscCode => 'IFSC कोड';

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
  String get notificationsNotAllowedWarningDriver =>
      'सूचनांना परवानगी नाही - तुम्ही त्या सक्षम करेपर्यंत जॉब अलर्ट आणि ट्रिप अपडेट्स तुमच्यापर्यंत पोहोचणार नाहीत.';

  @override
  String get enableNotifications => 'सूचना सक्षम करा';

  @override
  String get notificationsBlockedManualEnableHint =>
      'त्यावर टॅप केल्यावर काही होत नसेल, तर तुमच्या फोनने आधीच हे अ‍ॅप ब्लॉक केले आहे - ते तुमच्या फोनच्या Settings > Apps > Notifications मध्ये मॅन्युअली सक्षम करा.';

  @override
  String get pushNotifications => 'पुश सूचना';

  @override
  String get pushNotificationsDescriptionDriver =>
      'नवीन जॉब अलर्ट, ट्रिप स्थिती अपडेट्स आणि पेमेंट्स.';

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
  String get yourCurrentPasswordHint => 'तुमचा सध्याचा पासवर्ड';

  @override
  String get newPassword => 'नवीन पासवर्ड';

  @override
  String get min6CharsHint => 'किमान 6 अक्षरे';

  @override
  String get confirmNewPassword => 'नवीन पासवर्डची पुष्टी करा';

  @override
  String get reEnterNewPasswordHint => 'नवीन पासवर्ड पुन्हा टाका';

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
  String get accountNotRegisteredAsDriver =>
      'हे खाते ड्रायव्हर म्हणून नोंदणीकृत नाही. साइन आउट करा आणि ड्रायव्हर खात्याने लॉग इन करा.';

  @override
  String get couldNotReachServerCheckConnection =>
      'सर्व्हरपर्यंत पोहोचता आले नाही. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get retry => 'पुन्हा प्रयत्न करा';

  @override
  String get signOutAndLogInAgain => 'साइन आउट करा आणि पुन्हा लॉग इन करा';

  @override
  String get howWillYouUseTheApp => 'तुम्ही अ‍ॅप कसे वापराल?';

  @override
  String get iDriveMyOwnVehicle => 'मी माझे स्वतःचे वाहन चालवतो';

  @override
  String get acceptJobsEarnPerTrip => 'जॉब स्वीकारा आणि प्रति ट्रिप कमवा';

  @override
  String get iManageAFleet => 'मी एक फ्लीट व्यवस्थापित करतो';

  @override
  String get multipleVehiclesAndDrivers => 'अनेक वाहने आणि ड्रायव्हर्स';

  @override
  String get pressBackAgainToExit => 'बाहेर पडण्यासाठी पुन्हा बॅक दाबा';

  @override
  String get view => 'पहा';

  @override
  String get home => 'होम';

  @override
  String get jobs => 'जॉब्स';

  @override
  String get history => 'इतिहास';

  @override
  String get earnings => 'कमाई';

  @override
  String get couldNotLoadNotifications => 'सूचना लोड करता आल्या नाहीत.';

  @override
  String get markAllRead => 'सर्व वाचले म्हणून चिन्हांकित करा';

  @override
  String get allCaughtUpNothingHereYet =>
      'तुम्ही पूर्णपणे अद्ययावत आहात - इथे अजून काही नाही.';

  @override
  String couldNotUploadDocumentTryAgain(String label) {
    return '$label अपलोड करता आले नाही. पुन्हा प्रयत्न करा.';
  }

  @override
  String get takeAPhoto => 'फोटो घ्या';

  @override
  String get chooseFromGallery => 'गॅलरीमधून निवडा';

  @override
  String get documents => 'कागदपत्रे';

  @override
  String couldNotLoadDocuments(String error) {
    return 'कागदपत्रे लोड करता आली नाहीत.\n$error';
  }

  @override
  String get completeVehicleSetupFirst => 'आधी वाहन सेटअप पूर्ण करा.';

  @override
  String get uploaded => 'अपलोड केले';

  @override
  String get requiredNotUploaded => 'आवश्यक - अपलोड केलेले नाही';

  @override
  String get optionalNotUploaded => 'ऐच्छिक - अपलोड केलेले नाही';

  @override
  String get retake => 'पुन्हा घ्या';

  @override
  String get upload => 'अपलोड करा';

  @override
  String get docLabelPhotoId => 'फोटो ओळख (सेल्फी)';

  @override
  String get docLabelLicenseFront => 'ड्रायव्हिंग लायसन्स (पुढे)';

  @override
  String get docLabelLicenseBack => 'ड्रायव्हिंग लायसन्स (मागे)';

  @override
  String get docLabelRcFront => 'वाहन RC (पुढे)';

  @override
  String get docLabelRcBack => 'वाहन RC (मागे)';

  @override
  String get docLabelAadhaarFront => 'आधार कार्ड (पुढे)';

  @override
  String get docLabelAadhaarBack => 'आधार कार्ड (मागे)';

  @override
  String get docLabelInsurance => 'विमा';

  @override
  String get docLabelPermit => 'परमिट';

  @override
  String get docLabelPollution => 'प्रदूषण प्रमाणपत्र';

  @override
  String get docLabelPan => 'पॅन कार्ड';

  @override
  String get docLabelCheque => 'रद्द केलेला चेक';

  @override
  String get couldNotLoadEarnings => 'कमाई लोड करता आली नाही.';

  @override
  String get totalLifetimeEarnings => 'एकूण आजीवन कमाई';

  @override
  String tripsCompleted(int count) {
    return '$count ट्रिप पूर्ण झाल्या';
  }

  @override
  String get thisWeek => 'या आठवड्यात';

  @override
  String get thisMonth => 'या महिन्यात';

  @override
  String get walletBalance => 'वॉलेट शिल्लक';

  @override
  String get recentActivity => 'अलीकडील क्रियाकलाप';

  @override
  String get walletTxnTripFare => 'ट्रिप भाडे';

  @override
  String get walletTxnCancellationCompensation => 'रद्दीकरण भरपाई';

  @override
  String get walletTxnPayout => 'पेआउट';

  @override
  String get walletTxnAdjustment => 'समायोजन';

  @override
  String tripsCount(int count) {
    return '$count ट्रिप';
  }

  @override
  String get couldNotLoadMessages => 'मेसेज लोड करता आले नाहीत.';

  @override
  String get notConnectedCouldNotSendMessage =>
      'कनेक्ट नाही - तो मेसेज पाठवता आला नाही. तुमचे कनेक्शन तपासा आणि पुन्हा प्रयत्न करा.';

  @override
  String get chatWithCustomer => 'ग्राहकाशी चॅट करा';

  @override
  String get sayHelloToYourCustomer => 'तुमच्या ग्राहकाला हॅलो म्हणा.';

  @override
  String get typeAMessageHint => 'मेसेज टाइप करा…';

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
  String get filterAll => 'सर्व';

  @override
  String get filterActive => 'सक्रिय';

  @override
  String get couldNotLoadTripHistory => 'ट्रिप इतिहास लोड करता आला नाही.';

  @override
  String get noTripsHereYet => 'इथे अजून कोणतेही ट्रिप नाहीत.';

  @override
  String get tripHistory => 'ट्रिप इतिहास';

  @override
  String get customerFallback => 'ग्राहक';

  @override
  String get fillInAllFields => 'सर्व फील्ड भरा.';

  @override
  String get phoneAlreadyRegisteredDifferentRole =>
      'हा फोन नंबर आधीच वेगळ्या भूमिकेखाली नोंदणीकृत आहे (उदा. ग्राहक म्हणून). साइन आउट करा आणि ड्रायव्हर म्हणून साइन अप करण्यासाठी वेगळा फोन नंबर वापरा.';

  @override
  String get enterpriseCodeNotValid =>
      'तो एंटरप्राइझ कोड वैध नाही. तुमच्या कंपनीकडे तपासा, किंवा स्वतंत्रपणे चालवण्यासाठी हे रिकामे सोडा.';

  @override
  String get couldNotSubmitDetailsTryAgain =>
      'तुमचे तपशील सबमिट करता आले नाहीत. पुन्हा प्रयत्न करा.';

  @override
  String get takeSelfieRequired =>
      'सुरू ठेवण्यासाठी सेल्फी घ्या - ओळख पडताळणीसाठी हे आवश्यक आहे.';

  @override
  String get couldNotUploadSelfieTryAgain =>
      'तुमची सेल्फी अपलोड करता आली नाही. पुन्हा प्रयत्न करा.';

  @override
  String get vehicleDetails => 'वाहन तपशील';

  @override
  String get tellUsAboutYourVehicle =>
      'सुरुवात करण्यासाठी आम्हाला तुमच्या वाहनाबद्दल सांगा.';

  @override
  String get vehicleRegistrationNumberHint => 'उदा. DL 01 AB 1234';

  @override
  String get drivingLicenseNumber => 'ड्रायव्हिंग लायसन्स क्रमांक';

  @override
  String get enterpriseInviteCodeOptional => 'एंटरप्राइझ आमंत्रण कोड (ऐच्छिक)';

  @override
  String get enterpriseInviteCodeHint =>
      'उदा. ENT-A1B2C3D4 - फक्त जर एखाद्या कंपनीने तुम्हाला दिला असेल तर';

  @override
  String get continueLabel => 'सुरू ठेवा';

  @override
  String get verifyYourIdentity => 'तुमची ओळख पडताळा';

  @override
  String get selfieInstructions =>
      'चांगल्या प्रकाशात स्पष्ट सेल्फी घ्या. तुमचे खाते मंजूर करण्यापूर्वी अ‍ॅडमिन तुमच्या कागदपत्रांसह याचे पुनरावलोकन करतो.';

  @override
  String get takeSelfie => 'सेल्फी घ्या';

  @override
  String get submitForApproval => 'मंजुरीसाठी सबमिट करा';

  @override
  String get jobRequests => 'जॉब विनंत्या';

  @override
  String get couldNotLoadJobRequests => 'जॉब विनंत्या लोड करता आल्या नाहीत.';

  @override
  String get jobNoLongerAvailable => 'हा जॉब आता उपलब्ध नाही.';

  @override
  String get noJobsAvailablePullToRefresh =>
      'सध्या कोणतेही जॉब उपलब्ध नाहीत. रिफ्रेश करण्यासाठी खाली ओढा.';

  @override
  String get cargoFallback => 'माल';

  @override
  String get pass => 'सोडा';

  @override
  String get accept => 'स्वीकारा';

  @override
  String get jobDetails => 'जॉब तपशील';

  @override
  String codCollectAtDropOff(String amount) {
    return 'डिलिव्हरीच्या वेळी रोख - ड्रॉप-ऑफच्या वेळी ₹$amount गोळा करायचे आहेत';
  }

  @override
  String onlineAdvancePaidRemainderNearDelivery(String amount) {
    return 'ऑनलाइन - ₹$amount अ‍ॅडव्हान्स भरले, उर्वरित डिलिव्हरीच्या वेळी ऑनलाइन गोळा केले जाईल';
  }

  @override
  String get goodsLabel => 'माल';

  @override
  String get weightLabel => 'वजन';

  @override
  String get distanceLabel => 'अंतर';

  @override
  String get customerLabel => 'ग्राहक';

  @override
  String get enterYourCompanyName => 'तुमच्या कंपनीचे नाव टाका.';

  @override
  String get couldNotCreateFleetAccountTryAgain =>
      'तुमचे फ्लीट खाते तयार करता आले नाही. पुन्हा प्रयत्न करा.';

  @override
  String get setUpYourFleet => 'तुमचे फ्लीट सेट करा';

  @override
  String get whatsYourCompanyCalled => 'तुमच्या कंपनीचे नाव काय आहे?';

  @override
  String get companyName => 'कंपनीचे नाव';

  @override
  String get couldNotLoadFleetData => 'फ्लीट डेटा लोड करता आला नाही.';

  @override
  String get removeVehicleQuestion => 'वाहन काढायचे?';

  @override
  String removeVehicleConfirm(String vehicleNumber, String driverName) {
    return '$vehicleNumber तुमच्या फ्लीटमधून काढले जाईल. $driverName स्वतंत्र ड्रायव्हर म्हणून त्यांचे खाते ठेवतो - यामुळे काहीही हटवले जात नाही, फक्त तुमच्या फ्लीटपासून वेगळे होते.';
  }

  @override
  String get remove => 'काढा';

  @override
  String get theDriverFallback => 'ड्रायव्हर';

  @override
  String get couldNotRemoveThatVehicle => 'ते वाहन काढता आले नाही.';

  @override
  String get fleet => 'फ्लीट';

  @override
  String get notificationSettingsMenuItem => 'सूचना सेटिंग्ज';

  @override
  String get changePasswordMenuItem => 'पासवर्ड बदला';

  @override
  String get addVehicle => 'वाहन जोडा';

  @override
  String get vehiclesLabel => 'वाहने';

  @override
  String approvedCount(int count) {
    return '$count मंजूर';
  }

  @override
  String get activeNow => 'आत्ता सक्रिय';

  @override
  String liveOrdersCount(int count) {
    return '$count लाइव्ह ऑर्डर्स';
  }

  @override
  String get totalEarnings => 'एकूण कमाई';

  @override
  String get yourVehicles => 'तुमची वाहने';

  @override
  String get noVehiclesYetTapAddVehicle =>
      'अजून कोणतीही वाहने नाहीत - तुमचे पहिले वाहन नोंदणी करण्यासाठी \"वाहन जोडा\" टॅप करा.';

  @override
  String get unassigned => 'नियुक्त केलेले नाही';

  @override
  String vehicleSummaryLine(String driverName, String trips, String earnings,
      String docsUploaded, String docsTotal) {
    return '$driverName · $trips ट्रिप · ₹$earnings · KYC कागदपत्रे $docsUploaded/$docsTotal';
  }

  @override
  String get online => 'ऑनलाइन';

  @override
  String get offline => 'ऑफलाइन';

  @override
  String get pending => 'प्रलंबित';

  @override
  String get removeFromFleet => 'फ्लीटमधून काढा';

  @override
  String get fillAllFieldsValidPhone =>
      'वैध 10-अंकी फोन नंबरसह सर्व फील्ड भरा.';

  @override
  String get vehicleAdded => 'वाहन जोडले';

  @override
  String driverStillNeedsSelfie(String driverName) {
    return '$driverName ला अजूनही त्यांच्या स्वतःच्या फोनवर साइन इन करावे लागेल आणि हे वाहन मंजूर होण्यापूर्वी त्यांची KYC सेल्फी पूर्ण करावी लागेल - ती पायरी येथून करता येत नाही.';
  }

  @override
  String get gotIt => 'समजले';

  @override
  String get couldNotAddVehiclePhoneMayExist =>
      'हे वाहन जोडता आले नाही. फोन नंबर आधीच वेगळ्या भूमिकेखाली नोंदणीकृत असू शकतो.';

  @override
  String get driverDetails => 'ड्रायव्हर तपशील';

  @override
  String get driversName => 'ड्रायव्हरचे नाव';

  @override
  String get driversPhoneNumber => 'ड्रायव्हरचा फोन नंबर';

  @override
  String get driversLicenseNumber => 'ड्रायव्हरचा लायसन्स क्रमांक';

  @override
  String couldNotLoadYourProfile(String error) {
    return 'तुमची प्रोफाइल लोड करता आली नाही.\n$error';
  }

  @override
  String heyName(String name) {
    return 'नमस्कार $name';
  }

  @override
  String get thereFallbackName => 'जी';

  @override
  String get onlineReadyForJobs => 'ऑनलाइन - जॉबसाठी तयार';

  @override
  String get searchTripsWaybillHint => 'ट्रिप, वेबिल क्रमांक शोधा';

  @override
  String get tripInProgress => 'ट्रिप सुरू आहे';

  @override
  String get viewJobRequests => 'जॉब विनंत्या पहा';

  @override
  String get tapToResumeTracking => 'ट्रॅकिंग पुन्हा सुरू करण्यासाठी टॅप करा';

  @override
  String get browseBookingsNearYou => 'तुमच्या जवळील बुकिंग्ज पहा';

  @override
  String get searchResults => 'शोध निकाल';

  @override
  String get recentTrips => 'अलीकडील ट्रिप';

  @override
  String get viewAll => 'सर्व पहा';

  @override
  String noTripsMatch(String query) {
    return '\"$query\" शी जुळणारे कोणतेही ट्रिप नाही.';
  }

  @override
  String get noTripsYet => 'अजून कोणतेही ट्रिप नाही.';

  @override
  String get pendingApproval => 'मंजुरी प्रलंबित';

  @override
  String get verifyingVehicleDetails =>
      'आम्ही तुमचे वाहन तपशील पडताळत आहोत. अ‍ॅडमिन तुमचे खाते मंजूर केल्यावर तुम्ही ऑनलाइन जाऊ शकाल.';

  @override
  String get uploadRemainingDocuments => 'उर्वरित कागदपत्रे अपलोड करा';

  @override
  String get checkStatus => 'स्थिती तपासा';

  @override
  String get stillPendingApprovalCheckBack =>
      'अजूनही मंजुरी प्रलंबित आहे - लवकरच पुन्हा तपासा.';

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
  String get enterFullName => 'तुमचे पूर्ण नाव टाका.';

  @override
  String get enterValidPhoneNumber10Digit => 'वैध 10-अंकी फोन नंबर टाका.';

  @override
  String get selectYourDob => 'तुमची जन्मतारीख निवडा.';

  @override
  String get couldNotSaveDetailsTryAgain =>
      'तुमचे तपशील जतन करता आले नाहीत. पुन्हा प्रयत्न करा.';

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
  String get tellUsAboutYourself => 'आम्हाला तुमच्याबद्दल सांगा';

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
  String get thisHelpsCustomersSupportIdentifyYou =>
      'यामुळे ग्राहक आणि सपोर्ट टीमला तुम्हाला ओळखण्यास मदत होते.';

  @override
  String get emailLabel => 'ईमेल';

  @override
  String get emailExampleHint => 'you@example.com';

  @override
  String get passwordLabel => 'पासवर्ड';

  @override
  String get yourPasswordHint => 'तुमचा पासवर्ड';

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
  String get verificationCode => 'सत्यापन कोड';

  @override
  String get sixDigitCodeHint => '6-अंकी कोड';

  @override
  String get verifyAndContinue => 'सत्यापित करा आणि सुरू ठेवा';

  @override
  String resendCodeInSeconds(int seconds) {
    return '$seconds सेकंदात कोड पुन्हा पाठवा';
  }

  @override
  String get resendCode => 'कोड पुन्हा पाठवा';

  @override
  String get phoneNumberLabel => 'फोन नंबर';

  @override
  String get phoneNumberSampleHint => '98765 43210';

  @override
  String get sendOtp => 'OTP पाठवा';

  @override
  String get min6CharsHintPassword => 'किमान 6 अक्षरे';

  @override
  String get confirmPasswordLabel => 'पासवर्डची पुष्टी करा';

  @override
  String get reEnterPasswordHint => 'पासवर्ड पुन्हा टाका';

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
  String get fullNameLabel => 'पूर्ण नाव';

  @override
  String get yourNameHint => 'तुमचे नाव';

  @override
  String get dateOfBirth => 'जन्मतारीख';

  @override
  String get selectYourDateOfBirth => 'तुमची जन्मतारीख निवडा';
}
