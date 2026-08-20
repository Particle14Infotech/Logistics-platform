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
}
