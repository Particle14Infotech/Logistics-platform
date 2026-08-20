// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RaahMitr Driver';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get signOut => 'Sign out';

  @override
  String get language => 'Language';

  @override
  String get profile => 'Profile';

  @override
  String get fullName => 'Full name';

  @override
  String get noNameSet => 'No name set';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty.';

  @override
  String get couldNotSaveChangesTryAgain =>
      'Could not save changes. Try again.';

  @override
  String get signOutQuestion => 'Sign out?';

  @override
  String get signOutBody => 'You\'ll need to log in again to continue.';

  @override
  String get chooseVehicleTypeAndNumber =>
      'Choose a vehicle type and enter a vehicle number.';

  @override
  String get vehicleUpdatedPendingReapproval =>
      'Vehicle updated - pending re-approval by admin.';

  @override
  String get vehicleRegistrationNumber => 'Vehicle registration number';

  @override
  String get myDocuments => 'My Documents';

  @override
  String get bankDetails => 'Bank Details';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get changePassword => 'Change Password';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get about => 'About';

  @override
  String get raahmitrDriverAppLine => 'RaahMitr Driver App';

  @override
  String versionNumber(String number) {
    return 'Version $number';
  }

  @override
  String get allFieldsAreRequired => 'All fields are required.';

  @override
  String get bankDetailsSaved => 'Bank details saved.';

  @override
  String get couldNotSaveBankDetailsTryAgain =>
      'Could not save bank details. Try again.';

  @override
  String get couldNotLoadYourDetails => 'Could not load your details.';

  @override
  String get usedForWalletPayoutsHint =>
      'Used for wallet payouts - make sure this matches your actual bank account.';

  @override
  String get accountHolderName => 'Account holder name';

  @override
  String get asPerBankRecordsHint => 'As per bank records';

  @override
  String get accountNumber => 'Account number';

  @override
  String get ifscCode => 'IFSC code';

  @override
  String get couldNotLoadNotificationSettings =>
      'Could not load notification settings.';

  @override
  String get couldNotUpdateNotificationPrefTryAgain =>
      'Could not update notification preference. Try again.';

  @override
  String get devicePermission => 'Device permission';

  @override
  String get notificationsAllowedOnDevice =>
      'Notifications are allowed on this device.';

  @override
  String get notificationsNotAllowedWarningDriver =>
      'Notifications are not allowed - job alerts and trip updates won\'t reach you until you enable them.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get notificationsBlockedManualEnableHint =>
      'If nothing happens when you tap that, your phone has already blocked this app - enable it manually in your phone\'s Settings > Apps > Notifications.';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsDescriptionDriver =>
      'New job alerts, trip status updates, and payments.';

  @override
  String get enterCurrentPassword => 'Enter your current password.';

  @override
  String get newPasswordMinLength =>
      'New password must be at least 6 characters.';

  @override
  String get newPasswordsDoNotMatch => 'New passwords do not match.';

  @override
  String get passwordUpdated => 'Password updated';

  @override
  String get currentPasswordIncorrect => 'Current password is incorrect.';

  @override
  String get couldNotUpdatePassword => 'Could not update password.';

  @override
  String get couldNotUpdatePasswordTryAgain =>
      'Could not update password. Try again.';

  @override
  String get currentPassword => 'Current password';

  @override
  String get yourCurrentPasswordHint => 'Your current password';

  @override
  String get newPassword => 'New password';

  @override
  String get min6CharsHint => 'Min 6 characters';

  @override
  String get confirmNewPassword => 'Confirm new password';

  @override
  String get reEnterNewPasswordHint => 'Re-enter new password';

  @override
  String get updatePassword => 'Update Password';

  @override
  String get couldNotLoadHelpContent => 'Could not load help content.';

  @override
  String get needMoreHelp => 'Need more help?';

  @override
  String get emailSupportAddress => 'Email support@raahmitr.com';

  @override
  String get frequentlyAskedQuestions => 'Frequently asked questions';

  @override
  String get noFaqsAvailable => 'No FAQs available right now.';

  @override
  String get accountNotRegisteredAsDriver =>
      'This account isn\'t registered as a driver. Sign out and log in with a driver account.';

  @override
  String get couldNotReachServerCheckConnection =>
      'Couldn\'t reach the server. Check your connection and try again.';

  @override
  String get retry => 'Retry';

  @override
  String get signOutAndLogInAgain => 'Sign out and log in again';

  @override
  String get howWillYouUseTheApp => 'How will you use the app?';

  @override
  String get iDriveMyOwnVehicle => 'I drive my own vehicle';

  @override
  String get acceptJobsEarnPerTrip => 'Accept jobs and earn per trip';

  @override
  String get iManageAFleet => 'I manage a fleet';

  @override
  String get multipleVehiclesAndDrivers => 'Multiple vehicles and drivers';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get view => 'View';

  @override
  String get home => 'Home';

  @override
  String get jobs => 'Jobs';

  @override
  String get history => 'History';

  @override
  String get earnings => 'Earnings';

  @override
  String get couldNotLoadNotifications => 'Could not load notifications.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get allCaughtUpNothingHereYet =>
      'You\'re all caught up - nothing here yet.';

  @override
  String couldNotUploadDocumentTryAgain(String label) {
    return 'Could not upload $label. Try again.';
  }

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get chooseFromGallery => 'Choose from gallery';

  @override
  String get documents => 'Documents';

  @override
  String couldNotLoadDocuments(String error) {
    return 'Could not load documents.\n$error';
  }

  @override
  String get completeVehicleSetupFirst => 'Complete vehicle setup first.';

  @override
  String get uploaded => 'Uploaded';

  @override
  String get requiredNotUploaded => 'Required - not uploaded';

  @override
  String get optionalNotUploaded => 'Optional - not uploaded';

  @override
  String get retake => 'Retake';

  @override
  String get upload => 'Upload';

  @override
  String get docLabelPhotoId => 'Photo ID (Selfie)';

  @override
  String get docLabelLicenseFront => 'Driving License (Front)';

  @override
  String get docLabelLicenseBack => 'Driving License (Back)';

  @override
  String get docLabelRcFront => 'Vehicle RC (Front)';

  @override
  String get docLabelRcBack => 'Vehicle RC (Back)';

  @override
  String get docLabelAadhaarFront => 'Aadhaar Card (Front)';

  @override
  String get docLabelAadhaarBack => 'Aadhaar Card (Back)';

  @override
  String get docLabelInsurance => 'Insurance';

  @override
  String get docLabelPermit => 'Permit';

  @override
  String get docLabelPollution => 'Pollution certificate';

  @override
  String get docLabelPan => 'PAN card';

  @override
  String get docLabelCheque => 'Cancelled Cheque';

  @override
  String get couldNotLoadEarnings => 'Could not load earnings.';

  @override
  String get totalLifetimeEarnings => 'Total lifetime earnings';

  @override
  String tripsCompleted(int count) {
    return '$count trips completed';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String get thisMonth => 'This month';

  @override
  String get walletBalance => 'Wallet balance';

  @override
  String get recentActivity => 'Recent activity';

  @override
  String get walletTxnTripFare => 'Trip fare';

  @override
  String get walletTxnCancellationCompensation => 'Cancellation compensation';

  @override
  String get walletTxnPayout => 'Payout';

  @override
  String get walletTxnAdjustment => 'Adjustment';

  @override
  String tripsCount(int count) {
    return '$count trips';
  }

  @override
  String get couldNotLoadMessages => 'Could not load messages.';

  @override
  String get notConnectedCouldNotSendMessage =>
      'Not connected - couldn\'t send that message. Check your connection and try again.';

  @override
  String get chatWithCustomer => 'Chat with customer';

  @override
  String get sayHelloToYourCustomer => 'Say hello to your customer.';

  @override
  String get typeAMessageHint => 'Type a message…';

  @override
  String get statusPending => 'Pending';

  @override
  String get statusAccepted => 'Accepted';

  @override
  String get statusInTransit => 'In Transit';

  @override
  String get statusAwaitingPayment => 'Awaiting Payment';

  @override
  String get statusDelivered => 'Delivered';

  @override
  String get statusCancelled => 'Cancelled';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get couldNotLoadTripHistory => 'Could not load trip history.';

  @override
  String get noTripsHereYet => 'No trips here yet.';

  @override
  String get tripHistory => 'Trip History';

  @override
  String get customerFallback => 'Customer';
}
