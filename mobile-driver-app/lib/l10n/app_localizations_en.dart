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
}
