import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('mr'),
    Locale('ta'),
    Locale('te')
  ];

  /// App name, shown in the OS task switcher etc.
  ///
  /// In en, this message translates to:
  /// **'RaahMitr Driver'**
  String get appTitle;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullName;

  /// No description provided for @noNameSet.
  ///
  /// In en, this message translates to:
  /// **'No name set'**
  String get noNameSet;

  /// No description provided for @nameCannotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Name cannot be empty.'**
  String get nameCannotBeEmpty;

  /// No description provided for @couldNotSaveChangesTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save changes. Try again.'**
  String get couldNotSaveChangesTryAgain;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutBody.
  ///
  /// In en, this message translates to:
  /// **'You\'ll need to log in again to continue.'**
  String get signOutBody;

  /// No description provided for @chooseVehicleTypeAndNumber.
  ///
  /// In en, this message translates to:
  /// **'Choose a vehicle type and enter a vehicle number.'**
  String get chooseVehicleTypeAndNumber;

  /// No description provided for @vehicleUpdatedPendingReapproval.
  ///
  /// In en, this message translates to:
  /// **'Vehicle updated - pending re-approval by admin.'**
  String get vehicleUpdatedPendingReapproval;

  /// No description provided for @vehicleRegistrationNumber.
  ///
  /// In en, this message translates to:
  /// **'Vehicle registration number'**
  String get vehicleRegistrationNumber;

  /// No description provided for @myDocuments.
  ///
  /// In en, this message translates to:
  /// **'My Documents'**
  String get myDocuments;

  /// No description provided for @bankDetails.
  ///
  /// In en, this message translates to:
  /// **'Bank Details'**
  String get bankDetails;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @notificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Notification Settings'**
  String get notificationSettings;

  /// No description provided for @changePassword.
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// No description provided for @helpAndSupport.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get helpAndSupport;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @raahmitrDriverAppLine.
  ///
  /// In en, this message translates to:
  /// **'RaahMitr Driver App'**
  String get raahmitrDriverAppLine;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {number}'**
  String versionNumber(String number);

  /// No description provided for @allFieldsAreRequired.
  ///
  /// In en, this message translates to:
  /// **'All fields are required.'**
  String get allFieldsAreRequired;

  /// No description provided for @bankDetailsSaved.
  ///
  /// In en, this message translates to:
  /// **'Bank details saved.'**
  String get bankDetailsSaved;

  /// No description provided for @couldNotSaveBankDetailsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not save bank details. Try again.'**
  String get couldNotSaveBankDetailsTryAgain;

  /// No description provided for @couldNotLoadYourDetails.
  ///
  /// In en, this message translates to:
  /// **'Could not load your details.'**
  String get couldNotLoadYourDetails;

  /// No description provided for @usedForWalletPayoutsHint.
  ///
  /// In en, this message translates to:
  /// **'Used for wallet payouts - make sure this matches your actual bank account.'**
  String get usedForWalletPayoutsHint;

  /// No description provided for @accountHolderName.
  ///
  /// In en, this message translates to:
  /// **'Account holder name'**
  String get accountHolderName;

  /// No description provided for @asPerBankRecordsHint.
  ///
  /// In en, this message translates to:
  /// **'As per bank records'**
  String get asPerBankRecordsHint;

  /// No description provided for @accountNumber.
  ///
  /// In en, this message translates to:
  /// **'Account number'**
  String get accountNumber;

  /// No description provided for @ifscCode.
  ///
  /// In en, this message translates to:
  /// **'IFSC code'**
  String get ifscCode;

  /// No description provided for @couldNotLoadNotificationSettings.
  ///
  /// In en, this message translates to:
  /// **'Could not load notification settings.'**
  String get couldNotLoadNotificationSettings;

  /// No description provided for @couldNotUpdateNotificationPrefTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not update notification preference. Try again.'**
  String get couldNotUpdateNotificationPrefTryAgain;

  /// No description provided for @devicePermission.
  ///
  /// In en, this message translates to:
  /// **'Device permission'**
  String get devicePermission;

  /// No description provided for @notificationsAllowedOnDevice.
  ///
  /// In en, this message translates to:
  /// **'Notifications are allowed on this device.'**
  String get notificationsAllowedOnDevice;

  /// No description provided for @notificationsNotAllowedWarningDriver.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed - job alerts and trip updates won\'t reach you until you enable them.'**
  String get notificationsNotAllowedWarningDriver;

  /// No description provided for @enableNotifications.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get enableNotifications;

  /// No description provided for @notificationsBlockedManualEnableHint.
  ///
  /// In en, this message translates to:
  /// **'If nothing happens when you tap that, your phone has already blocked this app - enable it manually in your phone\'s Settings > Apps > Notifications.'**
  String get notificationsBlockedManualEnableHint;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotificationsDescriptionDriver.
  ///
  /// In en, this message translates to:
  /// **'New job alerts, trip status updates, and payments.'**
  String get pushNotificationsDescriptionDriver;

  /// No description provided for @enterCurrentPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your current password.'**
  String get enterCurrentPassword;

  /// No description provided for @newPasswordMinLength.
  ///
  /// In en, this message translates to:
  /// **'New password must be at least 6 characters.'**
  String get newPasswordMinLength;

  /// No description provided for @newPasswordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'New passwords do not match.'**
  String get newPasswordsDoNotMatch;

  /// No description provided for @passwordUpdated.
  ///
  /// In en, this message translates to:
  /// **'Password updated'**
  String get passwordUpdated;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In en, this message translates to:
  /// **'Current password is incorrect.'**
  String get currentPasswordIncorrect;

  /// No description provided for @couldNotUpdatePassword.
  ///
  /// In en, this message translates to:
  /// **'Could not update password.'**
  String get couldNotUpdatePassword;

  /// No description provided for @couldNotUpdatePasswordTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not update password. Try again.'**
  String get couldNotUpdatePasswordTryAgain;

  /// No description provided for @currentPassword.
  ///
  /// In en, this message translates to:
  /// **'Current password'**
  String get currentPassword;

  /// No description provided for @yourCurrentPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Your current password'**
  String get yourCurrentPasswordHint;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @min6CharsHint.
  ///
  /// In en, this message translates to:
  /// **'Min 6 characters'**
  String get min6CharsHint;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

  /// No description provided for @reEnterNewPasswordHint.
  ///
  /// In en, this message translates to:
  /// **'Re-enter new password'**
  String get reEnterNewPasswordHint;

  /// No description provided for @updatePassword.
  ///
  /// In en, this message translates to:
  /// **'Update Password'**
  String get updatePassword;

  /// No description provided for @couldNotLoadHelpContent.
  ///
  /// In en, this message translates to:
  /// **'Could not load help content.'**
  String get couldNotLoadHelpContent;

  /// No description provided for @needMoreHelp.
  ///
  /// In en, this message translates to:
  /// **'Need more help?'**
  String get needMoreHelp;

  /// No description provided for @emailSupportAddress.
  ///
  /// In en, this message translates to:
  /// **'Email support@raahmitr.com'**
  String get emailSupportAddress;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @noFaqsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No FAQs available right now.'**
  String get noFaqsAvailable;

  /// No description provided for @accountNotRegisteredAsDriver.
  ///
  /// In en, this message translates to:
  /// **'This account isn\'t registered as a driver. Sign out and log in with a driver account.'**
  String get accountNotRegisteredAsDriver;

  /// No description provided for @couldNotReachServerCheckConnection.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t reach the server. Check your connection and try again.'**
  String get couldNotReachServerCheckConnection;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @signOutAndLogInAgain.
  ///
  /// In en, this message translates to:
  /// **'Sign out and log in again'**
  String get signOutAndLogInAgain;

  /// No description provided for @howWillYouUseTheApp.
  ///
  /// In en, this message translates to:
  /// **'How will you use the app?'**
  String get howWillYouUseTheApp;

  /// No description provided for @iDriveMyOwnVehicle.
  ///
  /// In en, this message translates to:
  /// **'I drive my own vehicle'**
  String get iDriveMyOwnVehicle;

  /// No description provided for @acceptJobsEarnPerTrip.
  ///
  /// In en, this message translates to:
  /// **'Accept jobs and earn per trip'**
  String get acceptJobsEarnPerTrip;

  /// No description provided for @iManageAFleet.
  ///
  /// In en, this message translates to:
  /// **'I manage a fleet'**
  String get iManageAFleet;

  /// No description provided for @multipleVehiclesAndDrivers.
  ///
  /// In en, this message translates to:
  /// **'Multiple vehicles and drivers'**
  String get multipleVehiclesAndDrivers;

  /// No description provided for @pressBackAgainToExit.
  ///
  /// In en, this message translates to:
  /// **'Press back again to exit'**
  String get pressBackAgainToExit;

  /// No description provided for @view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get view;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @jobs.
  ///
  /// In en, this message translates to:
  /// **'Jobs'**
  String get jobs;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings;

  /// No description provided for @couldNotLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Could not load notifications.'**
  String get couldNotLoadNotifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @allCaughtUpNothingHereYet.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up - nothing here yet.'**
  String get allCaughtUpNothingHereYet;

  /// No description provided for @couldNotUploadDocumentTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not upload {label}. Try again.'**
  String couldNotUploadDocumentTryAgain(String label);

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get chooseFromGallery;

  /// No description provided for @documents.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get documents;

  /// No description provided for @couldNotLoadDocuments.
  ///
  /// In en, this message translates to:
  /// **'Could not load documents.\n{error}'**
  String couldNotLoadDocuments(String error);

  /// No description provided for @completeVehicleSetupFirst.
  ///
  /// In en, this message translates to:
  /// **'Complete vehicle setup first.'**
  String get completeVehicleSetupFirst;

  /// No description provided for @uploaded.
  ///
  /// In en, this message translates to:
  /// **'Uploaded'**
  String get uploaded;

  /// No description provided for @requiredNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Required - not uploaded'**
  String get requiredNotUploaded;

  /// No description provided for @optionalNotUploaded.
  ///
  /// In en, this message translates to:
  /// **'Optional - not uploaded'**
  String get optionalNotUploaded;

  /// No description provided for @retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retake;

  /// No description provided for @upload.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get upload;

  /// No description provided for @docLabelPhotoId.
  ///
  /// In en, this message translates to:
  /// **'Photo ID (Selfie)'**
  String get docLabelPhotoId;

  /// No description provided for @docLabelLicenseFront.
  ///
  /// In en, this message translates to:
  /// **'Driving License (Front)'**
  String get docLabelLicenseFront;

  /// No description provided for @docLabelLicenseBack.
  ///
  /// In en, this message translates to:
  /// **'Driving License (Back)'**
  String get docLabelLicenseBack;

  /// No description provided for @docLabelRcFront.
  ///
  /// In en, this message translates to:
  /// **'Vehicle RC (Front)'**
  String get docLabelRcFront;

  /// No description provided for @docLabelRcBack.
  ///
  /// In en, this message translates to:
  /// **'Vehicle RC (Back)'**
  String get docLabelRcBack;

  /// No description provided for @docLabelAadhaarFront.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card (Front)'**
  String get docLabelAadhaarFront;

  /// No description provided for @docLabelAadhaarBack.
  ///
  /// In en, this message translates to:
  /// **'Aadhaar Card (Back)'**
  String get docLabelAadhaarBack;

  /// No description provided for @docLabelInsurance.
  ///
  /// In en, this message translates to:
  /// **'Insurance'**
  String get docLabelInsurance;

  /// No description provided for @docLabelPermit.
  ///
  /// In en, this message translates to:
  /// **'Permit'**
  String get docLabelPermit;

  /// No description provided for @docLabelPollution.
  ///
  /// In en, this message translates to:
  /// **'Pollution certificate'**
  String get docLabelPollution;

  /// No description provided for @docLabelPan.
  ///
  /// In en, this message translates to:
  /// **'PAN card'**
  String get docLabelPan;

  /// No description provided for @docLabelCheque.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Cheque'**
  String get docLabelCheque;

  /// No description provided for @couldNotLoadEarnings.
  ///
  /// In en, this message translates to:
  /// **'Could not load earnings.'**
  String get couldNotLoadEarnings;

  /// No description provided for @totalLifetimeEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total lifetime earnings'**
  String get totalLifetimeEarnings;

  /// No description provided for @tripsCompleted.
  ///
  /// In en, this message translates to:
  /// **'{count} trips completed'**
  String tripsCompleted(int count);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @walletBalance.
  ///
  /// In en, this message translates to:
  /// **'Wallet balance'**
  String get walletBalance;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get recentActivity;

  /// No description provided for @walletTxnTripFare.
  ///
  /// In en, this message translates to:
  /// **'Trip fare'**
  String get walletTxnTripFare;

  /// No description provided for @walletTxnCancellationCompensation.
  ///
  /// In en, this message translates to:
  /// **'Cancellation compensation'**
  String get walletTxnCancellationCompensation;

  /// No description provided for @walletTxnPayout.
  ///
  /// In en, this message translates to:
  /// **'Payout'**
  String get walletTxnPayout;

  /// No description provided for @walletTxnAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get walletTxnAdjustment;

  /// No description provided for @tripsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} trips'**
  String tripsCount(int count);

  /// No description provided for @couldNotLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Could not load messages.'**
  String get couldNotLoadMessages;

  /// No description provided for @notConnectedCouldNotSendMessage.
  ///
  /// In en, this message translates to:
  /// **'Not connected - couldn\'t send that message. Check your connection and try again.'**
  String get notConnectedCouldNotSendMessage;

  /// No description provided for @chatWithCustomer.
  ///
  /// In en, this message translates to:
  /// **'Chat with customer'**
  String get chatWithCustomer;

  /// No description provided for @sayHelloToYourCustomer.
  ///
  /// In en, this message translates to:
  /// **'Say hello to your customer.'**
  String get sayHelloToYourCustomer;

  /// No description provided for @typeAMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessageHint;

  /// No description provided for @statusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get statusPending;

  /// No description provided for @statusAccepted.
  ///
  /// In en, this message translates to:
  /// **'Accepted'**
  String get statusAccepted;

  /// No description provided for @statusInTransit.
  ///
  /// In en, this message translates to:
  /// **'In Transit'**
  String get statusInTransit;

  /// No description provided for @statusAwaitingPayment.
  ///
  /// In en, this message translates to:
  /// **'Awaiting Payment'**
  String get statusAwaitingPayment;

  /// No description provided for @statusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get statusDelivered;

  /// No description provided for @statusCancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get statusCancelled;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterActive.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get filterActive;

  /// No description provided for @couldNotLoadTripHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load trip history.'**
  String get couldNotLoadTripHistory;

  /// No description provided for @noTripsHereYet.
  ///
  /// In en, this message translates to:
  /// **'No trips here yet.'**
  String get noTripsHereYet;

  /// No description provided for @tripHistory.
  ///
  /// In en, this message translates to:
  /// **'Trip History'**
  String get tripHistory;

  /// No description provided for @customerFallback.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerFallback;

  /// No description provided for @fillInAllFields.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields.'**
  String get fillInAllFields;

  /// No description provided for @phoneAlreadyRegisteredDifferentRole.
  ///
  /// In en, this message translates to:
  /// **'This phone number is already registered under a different role (e.g. as a customer). Sign out and use a different phone number to sign up as a driver.'**
  String get phoneAlreadyRegisteredDifferentRole;

  /// No description provided for @enterpriseCodeNotValid.
  ///
  /// In en, this message translates to:
  /// **'That enterprise code isn\'t valid. Check it with your company, or leave it blank to drive independently.'**
  String get enterpriseCodeNotValid;

  /// No description provided for @couldNotSubmitDetailsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your details. Try again.'**
  String get couldNotSubmitDetailsTryAgain;

  /// No description provided for @takeSelfieRequired.
  ///
  /// In en, this message translates to:
  /// **'Take a selfie to continue - this is required for identity verification.'**
  String get takeSelfieRequired;

  /// No description provided for @couldNotUploadSelfieTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not upload your selfie. Try again.'**
  String get couldNotUploadSelfieTryAgain;

  /// No description provided for @vehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'Vehicle details'**
  String get vehicleDetails;

  /// No description provided for @tellUsAboutYourVehicle.
  ///
  /// In en, this message translates to:
  /// **'Tell us about your vehicle to get started.'**
  String get tellUsAboutYourVehicle;

  /// No description provided for @vehicleRegistrationNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. DL 01 AB 1234'**
  String get vehicleRegistrationNumberHint;

  /// No description provided for @drivingLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Driving license number'**
  String get drivingLicenseNumber;

  /// No description provided for @enterpriseInviteCodeOptional.
  ///
  /// In en, this message translates to:
  /// **'Enterprise invite code (optional)'**
  String get enterpriseInviteCodeOptional;

  /// No description provided for @enterpriseInviteCodeHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. ENT-A1B2C3D4 - only if a company gave you one'**
  String get enterpriseInviteCodeHint;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @verifyYourIdentity.
  ///
  /// In en, this message translates to:
  /// **'Verify your identity'**
  String get verifyYourIdentity;

  /// No description provided for @selfieInstructions.
  ///
  /// In en, this message translates to:
  /// **'Take a clear selfie in good lighting. An admin reviews this alongside your documents before approving your account.'**
  String get selfieInstructions;

  /// No description provided for @takeSelfie.
  ///
  /// In en, this message translates to:
  /// **'Take selfie'**
  String get takeSelfie;

  /// No description provided for @submitForApproval.
  ///
  /// In en, this message translates to:
  /// **'Submit for approval'**
  String get submitForApproval;

  /// No description provided for @jobRequests.
  ///
  /// In en, this message translates to:
  /// **'Job requests'**
  String get jobRequests;

  /// No description provided for @couldNotLoadJobRequests.
  ///
  /// In en, this message translates to:
  /// **'Could not load job requests.'**
  String get couldNotLoadJobRequests;

  /// No description provided for @jobNoLongerAvailable.
  ///
  /// In en, this message translates to:
  /// **'This job is no longer available.'**
  String get jobNoLongerAvailable;

  /// No description provided for @noJobsAvailablePullToRefresh.
  ///
  /// In en, this message translates to:
  /// **'No jobs available right now. Pull to refresh.'**
  String get noJobsAvailablePullToRefresh;

  /// No description provided for @cargoFallback.
  ///
  /// In en, this message translates to:
  /// **'Cargo'**
  String get cargoFallback;

  /// No description provided for @pass.
  ///
  /// In en, this message translates to:
  /// **'Pass'**
  String get pass;

  /// No description provided for @accept.
  ///
  /// In en, this message translates to:
  /// **'Accept'**
  String get accept;

  /// No description provided for @jobDetails.
  ///
  /// In en, this message translates to:
  /// **'Job Details'**
  String get jobDetails;

  /// No description provided for @codCollectAtDropOff.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery - ₹{amount} to collect at drop-off'**
  String codCollectAtDropOff(String amount);

  /// No description provided for @onlineAdvancePaidRemainderNearDelivery.
  ///
  /// In en, this message translates to:
  /// **'Online - ₹{amount} advance paid, remainder collected online near delivery'**
  String onlineAdvancePaidRemainderNearDelivery(String amount);

  /// No description provided for @goodsLabel.
  ///
  /// In en, this message translates to:
  /// **'Goods'**
  String get goodsLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @customerLabel.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get customerLabel;

  /// No description provided for @enterYourCompanyName.
  ///
  /// In en, this message translates to:
  /// **'Enter your company name.'**
  String get enterYourCompanyName;

  /// No description provided for @couldNotCreateFleetAccountTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not create your fleet account. Try again.'**
  String get couldNotCreateFleetAccountTryAgain;

  /// No description provided for @setUpYourFleet.
  ///
  /// In en, this message translates to:
  /// **'Set up your fleet'**
  String get setUpYourFleet;

  /// No description provided for @whatsYourCompanyCalled.
  ///
  /// In en, this message translates to:
  /// **'What\'s your company called?'**
  String get whatsYourCompanyCalled;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company name'**
  String get companyName;

  /// No description provided for @couldNotLoadFleetData.
  ///
  /// In en, this message translates to:
  /// **'Could not load fleet data.'**
  String get couldNotLoadFleetData;

  /// No description provided for @removeVehicleQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove vehicle?'**
  String get removeVehicleQuestion;

  /// No description provided for @removeVehicleConfirm.
  ///
  /// In en, this message translates to:
  /// **'{vehicleNumber} will be removed from your fleet. {driverName} keeps their account as an independent driver - this does not delete anything, just detaches it from your fleet.'**
  String removeVehicleConfirm(String vehicleNumber, String driverName);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @theDriverFallback.
  ///
  /// In en, this message translates to:
  /// **'The driver'**
  String get theDriverFallback;

  /// No description provided for @couldNotRemoveThatVehicle.
  ///
  /// In en, this message translates to:
  /// **'Could not remove that vehicle.'**
  String get couldNotRemoveThatVehicle;

  /// No description provided for @fleet.
  ///
  /// In en, this message translates to:
  /// **'Fleet'**
  String get fleet;

  /// No description provided for @notificationSettingsMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get notificationSettingsMenuItem;

  /// No description provided for @changePasswordMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Change password'**
  String get changePasswordMenuItem;

  /// No description provided for @addVehicle.
  ///
  /// In en, this message translates to:
  /// **'Add vehicle'**
  String get addVehicle;

  /// No description provided for @vehiclesLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicles'**
  String get vehiclesLabel;

  /// No description provided for @approvedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} approved'**
  String approvedCount(int count);

  /// No description provided for @activeNow.
  ///
  /// In en, this message translates to:
  /// **'Active now'**
  String get activeNow;

  /// No description provided for @liveOrdersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} live orders'**
  String liveOrdersCount(int count);

  /// No description provided for @totalEarnings.
  ///
  /// In en, this message translates to:
  /// **'Total earnings'**
  String get totalEarnings;

  /// No description provided for @yourVehicles.
  ///
  /// In en, this message translates to:
  /// **'Your vehicles'**
  String get yourVehicles;

  /// No description provided for @noVehiclesYetTapAddVehicle.
  ///
  /// In en, this message translates to:
  /// **'No vehicles yet - tap \"Add vehicle\" to register your first one.'**
  String get noVehiclesYetTapAddVehicle;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @vehicleSummaryLine.
  ///
  /// In en, this message translates to:
  /// **'{driverName} · {trips} trips · ₹{earnings} · KYC docs {docsUploaded}/{docsTotal}'**
  String vehicleSummaryLine(String driverName, String trips, String earnings,
      String docsUploaded, String docsTotal);

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @removeFromFleet.
  ///
  /// In en, this message translates to:
  /// **'Remove from fleet'**
  String get removeFromFleet;

  /// No description provided for @fillAllFieldsValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Fill in all fields with a valid 10-digit phone number.'**
  String get fillAllFieldsValidPhone;

  /// No description provided for @vehicleAdded.
  ///
  /// In en, this message translates to:
  /// **'Vehicle added'**
  String get vehicleAdded;

  /// No description provided for @driverStillNeedsSelfie.
  ///
  /// In en, this message translates to:
  /// **'{driverName} still needs to sign in on their own phone and complete their KYC selfie before this vehicle can be approved - that step can\'t be done from here.'**
  String driverStillNeedsSelfie(String driverName);

  /// No description provided for @gotIt.
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// No description provided for @couldNotAddVehiclePhoneMayExist.
  ///
  /// In en, this message translates to:
  /// **'Could not add this vehicle. The phone number may already be registered under a different role.'**
  String get couldNotAddVehiclePhoneMayExist;

  /// No description provided for @driverDetails.
  ///
  /// In en, this message translates to:
  /// **'Driver details'**
  String get driverDetails;

  /// No description provided for @driversName.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s name'**
  String get driversName;

  /// No description provided for @driversPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s phone number'**
  String get driversPhoneNumber;

  /// No description provided for @driversLicenseNumber.
  ///
  /// In en, this message translates to:
  /// **'Driver\'s license number'**
  String get driversLicenseNumber;

  /// No description provided for @couldNotLoadYourProfile.
  ///
  /// In en, this message translates to:
  /// **'Could not load your profile.\n{error}'**
  String couldNotLoadYourProfile(String error);

  /// No description provided for @heyName.
  ///
  /// In en, this message translates to:
  /// **'Hey {name}'**
  String heyName(String name);

  /// No description provided for @thereFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get thereFallbackName;

  /// No description provided for @onlineReadyForJobs.
  ///
  /// In en, this message translates to:
  /// **'Online - ready for jobs'**
  String get onlineReadyForJobs;

  /// No description provided for @searchTripsWaybillHint.
  ///
  /// In en, this message translates to:
  /// **'Search trips, waybill no.'**
  String get searchTripsWaybillHint;

  /// No description provided for @tripInProgress.
  ///
  /// In en, this message translates to:
  /// **'Trip in progress'**
  String get tripInProgress;

  /// No description provided for @viewJobRequests.
  ///
  /// In en, this message translates to:
  /// **'View job requests'**
  String get viewJobRequests;

  /// No description provided for @tapToResumeTracking.
  ///
  /// In en, this message translates to:
  /// **'Tap to resume tracking'**
  String get tapToResumeTracking;

  /// No description provided for @browseBookingsNearYou.
  ///
  /// In en, this message translates to:
  /// **'Browse bookings near you'**
  String get browseBookingsNearYou;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @recentTrips.
  ///
  /// In en, this message translates to:
  /// **'Recent trips'**
  String get recentTrips;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noTripsMatch.
  ///
  /// In en, this message translates to:
  /// **'No trips match \"{query}\".'**
  String noTripsMatch(String query);

  /// No description provided for @noTripsYet.
  ///
  /// In en, this message translates to:
  /// **'No trips yet.'**
  String get noTripsYet;

  /// No description provided for @pendingApproval.
  ///
  /// In en, this message translates to:
  /// **'Pending approval'**
  String get pendingApproval;

  /// No description provided for @verifyingVehicleDetails.
  ///
  /// In en, this message translates to:
  /// **'We\'re verifying your vehicle details. You\'ll be able to go online once an admin approves your account.'**
  String get verifyingVehicleDetails;

  /// No description provided for @uploadRemainingDocuments.
  ///
  /// In en, this message translates to:
  /// **'Upload remaining documents'**
  String get uploadRemainingDocuments;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get checkStatus;

  /// No description provided for @stillPendingApprovalCheckBack.
  ///
  /// In en, this message translates to:
  /// **'Still pending approval - check back soon.'**
  String get stillPendingApprovalCheckBack;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
        'en',
        'gu',
        'hi',
        'mr',
        'ta',
        'te'
      ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'gu':
      return AppLocalizationsGu();
    case 'hi':
      return AppLocalizationsHi();
    case 'mr':
      return AppLocalizationsMr();
    case 'ta':
      return AppLocalizationsTa();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
