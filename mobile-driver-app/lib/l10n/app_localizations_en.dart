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
}
