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
  /// **'RaahMitr'**
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

  /// No description provided for @personalInformation.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInformation;

  /// No description provided for @addresses.
  ///
  /// In en, this message translates to:
  /// **'Addresses'**
  String get addresses;

  /// No description provided for @paymentMethods.
  ///
  /// In en, this message translates to:
  /// **'Payment Methods'**
  String get paymentMethods;

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

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

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

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address.'**
  String get enterValidEmail;

  /// No description provided for @enterYourPassword.
  ///
  /// In en, this message translates to:
  /// **'Enter your password.'**
  String get enterYourPassword;

  /// No description provided for @couldNotLogInTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not log in. Try again.'**
  String get couldNotLogInTryAgain;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get passwordMinLength;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match.'**
  String get passwordsDoNotMatch;

  /// No description provided for @couldNotCreateAccountTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not create your account. Try again.'**
  String get couldNotCreateAccountTryAgain;

  /// No description provided for @notVerifiedYetTapLink.
  ///
  /// In en, this message translates to:
  /// **'Not verified yet - tap the link in the email we sent you.'**
  String get notVerifiedYetTapLink;

  /// No description provided for @couldNotCheckVerificationTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not check verification status. Try again.'**
  String get couldNotCheckVerificationTryAgain;

  /// No description provided for @couldNotResendEmailTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not resend the email. Try again.'**
  String get couldNotResendEmailTryAgain;

  /// No description provided for @couldNotSendCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not send the code. Try again.'**
  String get couldNotSendCodeTryAgain;

  /// No description provided for @enterSixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code.'**
  String get enterSixDigitCode;

  /// No description provided for @incorrectOrExpiredCode.
  ///
  /// In en, this message translates to:
  /// **'Incorrect or expired code.'**
  String get incorrectOrExpiredCode;

  /// No description provided for @couldNotVerifyCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not verify that code. Try again.'**
  String get couldNotVerifyCodeTryAgain;

  /// No description provided for @enterEmailFirstThenForgot.
  ///
  /// In en, this message translates to:
  /// **'Enter your email above first, then tap \"Forgot password?\".'**
  String get enterEmailFirstThenForgot;

  /// No description provided for @passwordResetLinkSentTo.
  ///
  /// In en, this message translates to:
  /// **'Password reset link sent to {email}'**
  String passwordResetLinkSentTo(String email);

  /// No description provided for @enterValidMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid 10-digit mobile number.'**
  String get enterValidMobileNumber;

  /// No description provided for @accountExistsForEmailTryLogin.
  ///
  /// In en, this message translates to:
  /// **'An account already exists for that email. Try logging in instead.'**
  String get accountExistsForEmailTryLogin;

  /// No description provided for @emailLooksInvalid.
  ///
  /// In en, this message translates to:
  /// **'That email address looks invalid.'**
  String get emailLooksInvalid;

  /// No description provided for @chooseStrongerPassword.
  ///
  /// In en, this message translates to:
  /// **'Choose a stronger password.'**
  String get chooseStrongerPassword;

  /// No description provided for @incorrectEmailOrPassword.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password.'**
  String get incorrectEmailOrPassword;

  /// No description provided for @tooManyAttemptsTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Too many attempts. Try again in a moment.'**
  String get tooManyAttemptsTryAgain;

  /// No description provided for @phoneNumberLooksInvalid.
  ///
  /// In en, this message translates to:
  /// **'That phone number looks invalid.'**
  String get phoneNumberLooksInvalid;

  /// No description provided for @codeExpiredRequestNew.
  ///
  /// In en, this message translates to:
  /// **'That code expired - request a new one.'**
  String get codeExpiredRequestNew;

  /// No description provided for @somethingWentWrongTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Try again.'**
  String get somethingWentWrongTryAgain;

  /// No description provided for @verifyYourNumber.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Number'**
  String get verifyYourNumber;

  /// No description provided for @welcomeExclaim.
  ///
  /// In en, this message translates to:
  /// **'Welcome!'**
  String get welcomeExclaim;

  /// No description provided for @weveSentCodeToPhone.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a 6-digit code to\n+91 {phone}'**
  String weveSentCodeToPhone(String phone);

  /// No description provided for @logInOrSignUpWithMobile.
  ///
  /// In en, this message translates to:
  /// **'Log in or sign up with your mobile number'**
  String get logInOrSignUpWithMobile;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome Back!'**
  String get welcomeBack;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @logInWithEmailToContinue.
  ///
  /// In en, this message translates to:
  /// **'Log in with your email to continue'**
  String get logInWithEmailToContinue;

  /// No description provided for @signUpWithEmailToGetStarted.
  ///
  /// In en, this message translates to:
  /// **'Sign up with your email to get started'**
  String get signUpWithEmailToGetStarted;

  /// No description provided for @weveSentVerificationLinkTo.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent a verification link to\n{email}'**
  String weveSentVerificationLinkTo(String email);

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @logIn.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get logIn;

  /// No description provided for @dontHaveAccountSignUp.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account? Sign up'**
  String get dontHaveAccountSignUp;

  /// No description provided for @emailMethod.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailMethod;

  /// No description provided for @phoneMethod.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phoneMethod;

  /// No description provided for @sixDigitCode.
  ///
  /// In en, this message translates to:
  /// **'6-digit code'**
  String get sixDigitCode;

  /// No description provided for @verifyAndContinue.
  ///
  /// In en, this message translates to:
  /// **'Verify & Continue'**
  String get verifyAndContinue;

  /// No description provided for @resendCodeInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend code in {seconds}s'**
  String resendCodeInSeconds(int seconds);

  /// No description provided for @resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend code'**
  String get resendCode;

  /// No description provided for @tenDigitMobileNumber.
  ///
  /// In en, this message translates to:
  /// **'10-digit mobile number'**
  String get tenDigitMobileNumber;

  /// No description provided for @sendOtp.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOtp;

  /// No description provided for @passwordMinCharsHint.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6 characters)'**
  String get passwordMinCharsHint;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPassword;

  /// No description provided for @signUp.
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// No description provided for @alreadyHaveAccountLogIn.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get alreadyHaveAccountLogIn;

  /// No description provided for @sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send code'**
  String get sendCode;

  /// No description provided for @verifyCode.
  ///
  /// In en, this message translates to:
  /// **'Verify code'**
  String get verifyCode;

  /// No description provided for @useLinkInstead.
  ///
  /// In en, this message translates to:
  /// **'Use the link instead'**
  String get useLinkInstead;

  /// No description provided for @iveVerifiedMyEmail.
  ///
  /// In en, this message translates to:
  /// **'I\'ve verified my email'**
  String get iveVerifiedMyEmail;

  /// No description provided for @verificationEmailSentAgain.
  ///
  /// In en, this message translates to:
  /// **'Verification email sent again'**
  String get verificationEmailSentAgain;

  /// No description provided for @resendVerificationEmail.
  ///
  /// In en, this message translates to:
  /// **'Resend verification email'**
  String get resendVerificationEmail;

  /// No description provided for @enterCodeInstead.
  ///
  /// In en, this message translates to:
  /// **'Enter code instead'**
  String get enterCodeInstead;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Easy Shipping,\nSmarter Business'**
  String get onboardingTitle1;

  /// No description provided for @onboardingBody1.
  ///
  /// In en, this message translates to:
  /// **'Smart shipping saves time, cuts costs\nand grows businesses faster.'**
  String get onboardingBody1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Track Live,\nDoor to Door'**
  String get onboardingTitle2;

  /// No description provided for @onboardingBody2.
  ///
  /// In en, this message translates to:
  /// **'Watch your driver approach on the map\nwith real-time ETA updates.'**
  String get onboardingBody2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Pay Your Way,\nEvery Time'**
  String get onboardingTitle3;

  /// No description provided for @onboardingBody3.
  ///
  /// In en, this message translates to:
  /// **'UPI, cards, net banking, or wallet -\nyour choice, every booking.'**
  String get onboardingBody3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

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

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @couldNotLoadYourBookings.
  ///
  /// In en, this message translates to:
  /// **'Could not load your bookings.'**
  String get couldNotLoadYourBookings;

  /// No description provided for @heyNameWave.
  ///
  /// In en, this message translates to:
  /// **'Hey {name} 👋'**
  String heyNameWave(String name);

  /// No description provided for @thereFallbackName.
  ///
  /// In en, this message translates to:
  /// **'there'**
  String get thereFallbackName;

  /// No description provided for @whereAreWeShippingToday.
  ///
  /// In en, this message translates to:
  /// **'Where are we shipping today?'**
  String get whereAreWeShippingToday;

  /// No description provided for @searchShipmentsHint.
  ///
  /// In en, this message translates to:
  /// **'Search shipments by waybill or address'**
  String get searchShipmentsHint;

  /// No description provided for @bookNewShipment.
  ///
  /// In en, this message translates to:
  /// **'Book a New Shipment'**
  String get bookNewShipment;

  /// No description provided for @getInstantPriceBookDelivery.
  ///
  /// In en, this message translates to:
  /// **'Get instant price and book your delivery'**
  String get getInstantPriceBookDelivery;

  /// No description provided for @priceCalculator.
  ///
  /// In en, this message translates to:
  /// **'Price Calculator'**
  String get priceCalculator;

  /// No description provided for @myOrders.
  ///
  /// In en, this message translates to:
  /// **'My Orders'**
  String get myOrders;

  /// No description provided for @support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get support;

  /// No description provided for @searchResults.
  ///
  /// In en, this message translates to:
  /// **'Search results'**
  String get searchResults;

  /// No description provided for @recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get recentOrders;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noShipmentsMatch.
  ///
  /// In en, this message translates to:
  /// **'No shipments match \"{query}\".'**
  String noShipmentsMatch(String query);

  /// No description provided for @noBookingsYetTapAway.
  ///
  /// In en, this message translates to:
  /// **'No bookings yet - your first one is just a tap away.'**
  String get noBookingsYetTapAway;

  /// No description provided for @statusPaymentPending.
  ///
  /// In en, this message translates to:
  /// **'Payment Pending'**
  String get statusPaymentPending;

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

  /// No description provided for @raahmitrCustomerAppLine.
  ///
  /// In en, this message translates to:
  /// **'RaahMitr Customer App'**
  String get raahmitrCustomerAppLine;

  /// No description provided for @versionNumber.
  ///
  /// In en, this message translates to:
  /// **'Version {number}'**
  String versionNumber(String number);

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

  /// No description provided for @notificationsNotAllowedWarning.
  ///
  /// In en, this message translates to:
  /// **'Notifications are not allowed - booking and delivery updates won\'t reach you until you enable them.'**
  String get notificationsNotAllowedWarning;

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

  /// No description provided for @pushNotificationsDescription.
  ///
  /// In en, this message translates to:
  /// **'Booking updates, driver assignment, and delivery confirmations.'**
  String get pushNotificationsDescription;

  /// No description provided for @saved.
  ///
  /// In en, this message translates to:
  /// **'Saved.'**
  String get saved;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// No description provided for @businessGstinOptional.
  ///
  /// In en, this message translates to:
  /// **'Business GSTIN (optional)'**
  String get businessGstinOptional;

  /// No description provided for @usedOnInvoicesIfAny.
  ///
  /// In en, this message translates to:
  /// **'Used on your booking invoices, if you have one.'**
  String get usedOnInvoicesIfAny;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @couldNotLoadYourAddresses.
  ///
  /// In en, this message translates to:
  /// **'Could not load your addresses.'**
  String get couldNotLoadYourAddresses;

  /// No description provided for @addAddress.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get addAddress;

  /// No description provided for @editAddress.
  ///
  /// In en, this message translates to:
  /// **'Edit address'**
  String get editAddress;

  /// No description provided for @labelHint.
  ///
  /// In en, this message translates to:
  /// **'Label (e.g. Home, Office)'**
  String get labelHint;

  /// No description provided for @fullAddress.
  ///
  /// In en, this message translates to:
  /// **'Full address'**
  String get fullAddress;

  /// No description provided for @couldNotSaveThisAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not save this address.'**
  String get couldNotSaveThisAddress;

  /// No description provided for @couldNotRemoveThisAddress.
  ///
  /// In en, this message translates to:
  /// **'Could not remove this address.'**
  String get couldNotRemoveThisAddress;

  /// No description provided for @noSavedAddressesYet.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses yet - tap + to add one.'**
  String get noSavedAddressesYet;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @couldNotLoadPaymentHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load payment history.'**
  String get couldNotLoadPaymentHistory;

  /// No description provided for @removeCardQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove card?'**
  String get removeCardQuestion;

  /// No description provided for @removeCardConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove the {network} card ending in {last4}?'**
  String removeCardConfirm(String network, String last4);

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @couldNotRemoveThatCard.
  ///
  /// In en, this message translates to:
  /// **'Could not remove that card.'**
  String get couldNotRemoveThatCard;

  /// No description provided for @savedCards.
  ///
  /// In en, this message translates to:
  /// **'Saved cards'**
  String get savedCards;

  /// No description provided for @noSavedCardsYet.
  ///
  /// In en, this message translates to:
  /// **'No saved cards yet - check \"Save this card\" during your next payment.'**
  String get noSavedCardsYet;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction history'**
  String get transactionHistory;

  /// No description provided for @noPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet.'**
  String get noPaymentsYet;

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

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New password'**
  String get newPassword;

  /// No description provided for @confirmNewPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get confirmNewPassword;

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

  /// No description provided for @turnOnLocationServices.
  ///
  /// In en, this message translates to:
  /// **'Turn on location services to use your current location.'**
  String get turnOnLocationServices;

  /// No description provided for @locationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Location permission is required to use your current location.'**
  String get locationPermissionRequired;

  /// No description provided for @couldNotDetermineAddressTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your address. Try again.'**
  String get couldNotDetermineAddressTryAgain;

  /// No description provided for @couldNotGetCurrentLocationTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not get your current location. Try again.'**
  String get couldNotGetCurrentLocationTryAgain;

  /// No description provided for @enterBothPickupAndDrop.
  ///
  /// In en, this message translates to:
  /// **'Enter both a pickup and drop location.'**
  String get enterBothPickupAndDrop;

  /// No description provided for @pickupDropCannotBeSame.
  ///
  /// In en, this message translates to:
  /// **'Pickup and drop can\'t be the same place.'**
  String get pickupDropCannotBeSame;

  /// No description provided for @couldNotVerifyAddressPickSuggestion.
  ///
  /// In en, this message translates to:
  /// **'Could not verify one of these addresses. Pick a suggestion from the list, or use current location for pickup.'**
  String get couldNotVerifyAddressPickSuggestion;

  /// No description provided for @whereTo.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// No description provided for @pickupLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get pickupLocation;

  /// No description provided for @dropLocation.
  ///
  /// In en, this message translates to:
  /// **'Drop location'**
  String get dropLocation;

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @bookingConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Booking Confirmed!'**
  String get bookingConfirmed;

  /// No description provided for @shipmentBookedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Your shipment has been successfully booked.'**
  String get shipmentBookedSuccessfully;

  /// No description provided for @estimatedPrice.
  ///
  /// In en, this message translates to:
  /// **'Estimated Price'**
  String get estimatedPrice;

  /// No description provided for @payAdvanceNowCashAtDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹{advance} now, ₹{remaining} in cash at delivery'**
  String payAdvanceNowCashAtDelivery(String advance, String remaining);

  /// No description provided for @payCashAtDeliveryNoAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹{amount} in cash at delivery - no advance required'**
  String payCashAtDeliveryNoAdvance(String amount);

  /// No description provided for @payAdvanceNowRemainingOnlineNearDelivery.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹{advance} now, remaining ₹{remaining} due online near delivery'**
  String payAdvanceNowRemainingOnlineNearDelivery(
      String advance, String remaining);

  /// No description provided for @trackShipment.
  ///
  /// In en, this message translates to:
  /// **'Track Shipment'**
  String get trackShipment;

  /// No description provided for @trackShipmentAvailableOnceAdvanceConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Track Shipment will be available once your advance payment is confirmed.'**
  String get trackShipmentAvailableOnceAdvanceConfirmed;

  /// No description provided for @backToHome.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get backToHome;

  /// No description provided for @bodyTypeBike.
  ///
  /// In en, this message translates to:
  /// **'Bike'**
  String get bodyTypeBike;

  /// No description provided for @bodyTypeAuto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get bodyTypeAuto;

  /// No description provided for @bodyTypeOpen.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get bodyTypeOpen;

  /// No description provided for @bodyTypeContainer.
  ///
  /// In en, this message translates to:
  /// **'Container'**
  String get bodyTypeContainer;

  /// No description provided for @bodyTypeTrailer.
  ///
  /// In en, this message translates to:
  /// **'Trailer'**
  String get bodyTypeTrailer;

  /// No description provided for @filterByCargoWeight.
  ///
  /// In en, this message translates to:
  /// **'Filter by cargo weight'**
  String get filterByCargoWeight;

  /// No description provided for @weightKgFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKgFieldLabel;

  /// No description provided for @weightFilterChipLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightFilterChipLabel;

  /// No description provided for @weightKgChipValue.
  ///
  /// In en, this message translates to:
  /// **'{weight} kg'**
  String weightKgChipValue(String weight);

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @selectVehicle.
  ///
  /// In en, this message translates to:
  /// **'Select Vehicle'**
  String get selectVehicle;

  /// No description provided for @couldNotLoadVehicleTypes.
  ///
  /// In en, this message translates to:
  /// **'Could not load vehicle types. Check your connection and try again.'**
  String get couldNotLoadVehicleTypes;

  /// No description provided for @noVehicleTypesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No vehicle types are available right now.'**
  String get noVehicleTypesAvailable;

  /// No description provided for @noVehiclesMatchThisWeight.
  ///
  /// In en, this message translates to:
  /// **'No vehicles match this weight in this category.'**
  String get noVehiclesMatchThisWeight;

  /// No description provided for @goodsTypeGeneralCargo.
  ///
  /// In en, this message translates to:
  /// **'General cargo'**
  String get goodsTypeGeneralCargo;

  /// No description provided for @goodsTypeFurniture.
  ///
  /// In en, this message translates to:
  /// **'Furniture'**
  String get goodsTypeFurniture;

  /// No description provided for @goodsTypeElectronics.
  ///
  /// In en, this message translates to:
  /// **'Electronics'**
  String get goodsTypeElectronics;

  /// No description provided for @goodsTypeFoodGroceries.
  ///
  /// In en, this message translates to:
  /// **'Food & groceries'**
  String get goodsTypeFoodGroceries;

  /// No description provided for @goodsTypeDocuments.
  ///
  /// In en, this message translates to:
  /// **'Documents'**
  String get goodsTypeDocuments;

  /// No description provided for @goodsTypeIndustrialEquipment.
  ///
  /// In en, this message translates to:
  /// **'Industrial equipment'**
  String get goodsTypeIndustrialEquipment;

  /// No description provided for @goodsTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get goodsTypeOther;

  /// No description provided for @enterValidWeightKg.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid weight in kg.'**
  String get enterValidWeightKg;

  /// No description provided for @vehicleCanCarryUpTo.
  ///
  /// In en, this message translates to:
  /// **'{name} can carry up to {maxWeight}kg - choose a bigger vehicle or reduce the weight.'**
  String vehicleCanCarryUpTo(String name, String maxWeight);

  /// No description provided for @couldNotGetFareEstimateTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not get a fare estimate. Check your connection and try again.'**
  String get couldNotGetFareEstimateTryAgain;

  /// No description provided for @loadDetails.
  ///
  /// In en, this message translates to:
  /// **'Load details'**
  String get loadDetails;

  /// No description provided for @goodsType.
  ///
  /// In en, this message translates to:
  /// **'Goods type'**
  String get goodsType;

  /// No description provided for @fragile.
  ///
  /// In en, this message translates to:
  /// **'Fragile'**
  String get fragile;

  /// No description provided for @fragileSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Extra care during handling'**
  String get fragileSubtitle;

  /// No description provided for @addInsurance.
  ///
  /// In en, this message translates to:
  /// **'Add insurance'**
  String get addInsurance;

  /// No description provided for @addInsuranceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Covers loss or damage in transit'**
  String get addInsuranceSubtitle;

  /// No description provided for @receiverDetails.
  ///
  /// In en, this message translates to:
  /// **'Receiver details'**
  String get receiverDetails;

  /// No description provided for @receiverDetailsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Optional - filled into your invoice/waybill'**
  String get receiverDetailsSubtitle;

  /// No description provided for @receiversName.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s name'**
  String get receiversName;

  /// No description provided for @receiversPhone.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s phone'**
  String get receiversPhone;

  /// No description provided for @receiversGstinOptional.
  ///
  /// In en, this message translates to:
  /// **'Receiver\'s GSTIN (optional)'**
  String get receiversGstinOptional;

  /// No description provided for @getFareEstimate.
  ///
  /// In en, this message translates to:
  /// **'Get fare estimate'**
  String get getFareEstimate;

  /// No description provided for @couldNotConfirmBookingTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not confirm this booking. Try again.'**
  String get couldNotConfirmBookingTryAgain;

  /// No description provided for @priceSummary.
  ///
  /// In en, this message translates to:
  /// **'Price Summary'**
  String get priceSummary;

  /// No description provided for @noEstimateFoundForBooking.
  ///
  /// In en, this message translates to:
  /// **'No estimate found for this booking.'**
  String get noEstimateFoundForBooking;

  /// No description provided for @startNewBooking.
  ///
  /// In en, this message translates to:
  /// **'Start a new booking'**
  String get startNewBooking;

  /// No description provided for @vehicleLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle'**
  String get vehicleLabel;

  /// No description provided for @distanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distanceLabel;

  /// No description provided for @weightLabel.
  ///
  /// In en, this message translates to:
  /// **'Weight'**
  String get weightLabel;

  /// No description provided for @fareBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Fare Breakdown'**
  String get fareBreakdown;

  /// No description provided for @baseFare.
  ///
  /// In en, this message translates to:
  /// **'Base Fare'**
  String get baseFare;

  /// No description provided for @distanceCharge.
  ///
  /// In en, this message translates to:
  /// **'Distance Charge'**
  String get distanceCharge;

  /// No description provided for @weightCharge.
  ///
  /// In en, this message translates to:
  /// **'Weight Charge'**
  String get weightCharge;

  /// No description provided for @surgeMultiplierLabel.
  ///
  /// In en, this message translates to:
  /// **'Surge ({multiplier}x)'**
  String surgeMultiplierLabel(String multiplier);

  /// No description provided for @totalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get totalAmount;

  /// No description provided for @finalAmountMayVarySlightly.
  ///
  /// In en, this message translates to:
  /// **'Final amount may vary slightly'**
  String get finalAmountMayVarySlightly;

  /// No description provided for @confirmBooking.
  ///
  /// In en, this message translates to:
  /// **'Confirm Booking'**
  String get confirmBooking;

  /// No description provided for @paymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment Method'**
  String get paymentMethod;

  /// No description provided for @payOnline.
  ///
  /// In en, this message translates to:
  /// **'Pay Online'**
  String get payOnline;

  /// No description provided for @payOnlineAdvanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'₹{advance} due now online, remaining ₹{remaining} due online near delivery'**
  String payOnlineAdvanceSubtitle(String advance, String remaining);

  /// No description provided for @payOnlineFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay the full amount now via card/UPI'**
  String get payOnlineFullSubtitle;

  /// No description provided for @cashOnDelivery.
  ///
  /// In en, this message translates to:
  /// **'Cash on Delivery'**
  String get cashOnDelivery;

  /// No description provided for @codAdvanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'₹{advance} due now online, remaining ₹{remaining} in cash at delivery'**
  String codAdvanceSubtitle(String advance, String remaining);

  /// No description provided for @codFullSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pay the full amount in cash at delivery'**
  String get codFullSubtitle;

  /// No description provided for @enterBothPickupDropLocations.
  ///
  /// In en, this message translates to:
  /// **'Enter both pickup and drop locations.'**
  String get enterBothPickupDropLocations;

  /// No description provided for @selectAVehicleType.
  ///
  /// In en, this message translates to:
  /// **'Select a vehicle type.'**
  String get selectAVehicleType;

  /// No description provided for @vehicleCanCarryUpToShort.
  ///
  /// In en, this message translates to:
  /// **'{name} can carry up to {maxWeight} kg.'**
  String vehicleCanCarryUpToShort(String name, String maxWeight);

  /// No description provided for @couldNotCalculatePriceTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not calculate a price. Try again.'**
  String get couldNotCalculatePriceTryAgain;

  /// No description provided for @vehicleTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Vehicle type'**
  String get vehicleTypeLabel;

  /// No description provided for @couldNotLoadVehicleTypesShort.
  ///
  /// In en, this message translates to:
  /// **'Could not load vehicle types.'**
  String get couldNotLoadVehicleTypesShort;

  /// No description provided for @weightKgOptionalHint.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg) - optional'**
  String get weightKgOptionalHint;

  /// No description provided for @calculate.
  ///
  /// In en, this message translates to:
  /// **'Calculate'**
  String get calculate;

  /// No description provided for @recalculate.
  ///
  /// In en, this message translates to:
  /// **'Recalculate'**
  String get recalculate;

  /// No description provided for @estimatedFare.
  ///
  /// In en, this message translates to:
  /// **'Estimated Fare'**
  String get estimatedFare;

  /// No description provided for @thisIsOnlyEstimateNotBooking.
  ///
  /// In en, this message translates to:
  /// **'This is only an estimate - not a booking.'**
  String get thisIsOnlyEstimateNotBooking;

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

  /// No description provided for @couldNotLoadYourOrders.
  ///
  /// In en, this message translates to:
  /// **'Could not load your orders.'**
  String get couldNotLoadYourOrders;

  /// No description provided for @noOrdersHereYet.
  ///
  /// In en, this message translates to:
  /// **'No orders here yet.'**
  String get noOrdersHereYet;

  /// No description provided for @tapStarToRate.
  ///
  /// In en, this message translates to:
  /// **'Tap a star to rate your driver.'**
  String get tapStarToRate;

  /// No description provided for @couldNotSubmitReviewTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not submit your review. Try again.'**
  String get couldNotSubmitReviewTryAgain;

  /// No description provided for @couldNotLoadThisBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not load this booking.'**
  String get couldNotLoadThisBooking;

  /// No description provided for @reportAnIssue.
  ///
  /// In en, this message translates to:
  /// **'Report an issue'**
  String get reportAnIssue;

  /// No description provided for @disputeCategoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get disputeCategoryLabel;

  /// No description provided for @disputeCategoryPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get disputeCategoryPayment;

  /// No description provided for @disputeCategoryDamage.
  ///
  /// In en, this message translates to:
  /// **'Damaged goods'**
  String get disputeCategoryDamage;

  /// No description provided for @disputeCategoryDelay.
  ///
  /// In en, this message translates to:
  /// **'Delay'**
  String get disputeCategoryDelay;

  /// No description provided for @disputeCategoryBehavior.
  ///
  /// In en, this message translates to:
  /// **'Driver behavior'**
  String get disputeCategoryBehavior;

  /// No description provided for @disputeCategoryPricing.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get disputeCategoryPricing;

  /// No description provided for @disputeCategoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get disputeCategoryOther;

  /// No description provided for @whatHappenedLabel.
  ///
  /// In en, this message translates to:
  /// **'What happened?'**
  String get whatHappenedLabel;

  /// No description provided for @describeWhatHappened.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened.'**
  String get describeWhatHappened;

  /// No description provided for @reportedTeamWillLookIntoIt.
  ///
  /// In en, this message translates to:
  /// **'Reported - our team will look into it.'**
  String get reportedTeamWillLookIntoIt;

  /// No description provided for @couldNotSubmitThisTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not submit this. Try again.'**
  String get couldNotSubmitThisTryAgain;

  /// No description provided for @submittingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Submitting…'**
  String get submittingEllipsis;

  /// No description provided for @submit.
  ///
  /// In en, this message translates to:
  /// **'Submit'**
  String get submit;

  /// No description provided for @cancelBookingQuestion.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking?'**
  String get cancelBookingQuestion;

  /// No description provided for @cancellationFeeWarning.
  ///
  /// In en, this message translates to:
  /// **'A driver has already accepted this job. A ₹{fee} cancellation fee will be deducted from your refund as driver compensation.'**
  String cancellationFeeWarning(String fee);

  /// No description provided for @cannotBeUndone.
  ///
  /// In en, this message translates to:
  /// **'This cannot be undone.'**
  String get cannotBeUndone;

  /// No description provided for @keepBooking.
  ///
  /// In en, this message translates to:
  /// **'Keep booking'**
  String get keepBooking;

  /// No description provided for @cancelBooking.
  ///
  /// In en, this message translates to:
  /// **'Cancel booking'**
  String get cancelBooking;

  /// No description provided for @couldNotCancelThisBooking.
  ///
  /// In en, this message translates to:
  /// **'Could not cancel this booking.'**
  String get couldNotCancelThisBooking;

  /// No description provided for @orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderDetails;

  /// No description provided for @paymentPendingTitle.
  ///
  /// In en, this message translates to:
  /// **'Payment pending'**
  String get paymentPendingTitle;

  /// No description provided for @payAdvanceToConfirmTrackingAvailable.
  ///
  /// In en, this message translates to:
  /// **'Pay the advance to confirm this booking - tracking will be available right after.'**
  String get payAdvanceToConfirmTrackingAvailable;

  /// No description provided for @findingADriver.
  ///
  /// In en, this message translates to:
  /// **'Finding a driver…'**
  String get findingADriver;

  /// No description provided for @pickupSuccessfulDriverAtLocation.
  ///
  /// In en, this message translates to:
  /// **'Pickup successful! Your driver is at the pickup location.'**
  String get pickupSuccessfulDriverAtLocation;

  /// No description provided for @shipmentDeliveredExclaim.
  ///
  /// In en, this message translates to:
  /// **'Your shipment has been delivered!'**
  String get shipmentDeliveredExclaim;

  /// No description provided for @payToCompleteOrder.
  ///
  /// In en, this message translates to:
  /// **'Pay ₹{amount} to complete this order.'**
  String payToCompleteOrder(String amount);

  /// No description provided for @giveCodeToStartTrip.
  ///
  /// In en, this message translates to:
  /// **'Give this code to your driver to start the trip'**
  String get giveCodeToStartTrip;

  /// No description provided for @giveCodeAtDropOff.
  ///
  /// In en, this message translates to:
  /// **'Give this code to your driver at drop-off'**
  String get giveCodeAtDropOff;

  /// No description provided for @onlineValue.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get onlineValue;

  /// No description provided for @advancePaid.
  ///
  /// In en, this message translates to:
  /// **'Advance Paid'**
  String get advancePaid;

  /// No description provided for @advanceDueNow.
  ///
  /// In en, this message translates to:
  /// **'Advance Due Now'**
  String get advanceDueNow;

  /// No description provided for @dueInCashAtDelivery.
  ///
  /// In en, this message translates to:
  /// **'Due in Cash at Delivery'**
  String get dueInCashAtDelivery;

  /// No description provided for @remainderPaid.
  ///
  /// In en, this message translates to:
  /// **'Remainder Paid'**
  String get remainderPaid;

  /// No description provided for @remainderDueOnline.
  ///
  /// In en, this message translates to:
  /// **'Remainder Due Online'**
  String get remainderDueOnline;

  /// No description provided for @preparingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Preparing…'**
  String get preparingEllipsis;

  /// No description provided for @downloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Download invoice'**
  String get downloadInvoice;

  /// No description provided for @couldNotDownloadInvoice.
  ///
  /// In en, this message translates to:
  /// **'Could not download the invoice.'**
  String get couldNotDownloadInvoice;

  /// No description provided for @yourRating.
  ///
  /// In en, this message translates to:
  /// **'Your rating'**
  String get yourRating;

  /// No description provided for @rateYourDriver.
  ///
  /// In en, this message translates to:
  /// **'Rate your driver'**
  String get rateYourDriver;

  /// No description provided for @addCommentOptional.
  ///
  /// In en, this message translates to:
  /// **'Add a comment (optional)'**
  String get addCommentOptional;

  /// No description provided for @submitReview.
  ///
  /// In en, this message translates to:
  /// **'Submit review'**
  String get submitReview;

  /// No description provided for @showThisToDriverAtPickup.
  ///
  /// In en, this message translates to:
  /// **'Show this to your driver at pickup'**
  String get showThisToDriverAtPickup;

  /// No description provided for @waitingForDriverGpsSignal.
  ///
  /// In en, this message translates to:
  /// **'Waiting for your driver\'s GPS signal…'**
  String get waitingForDriverGpsSignal;

  /// No description provided for @cancellingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Cancelling…'**
  String get cancellingEllipsis;

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

  /// No description provided for @couldNotLoadMessages.
  ///
  /// In en, this message translates to:
  /// **'Could not load messages.'**
  String get couldNotLoadMessages;

  /// No description provided for @chatWithDriver.
  ///
  /// In en, this message translates to:
  /// **'Chat with driver'**
  String get chatWithDriver;

  /// No description provided for @sayHelloToYourDriver.
  ///
  /// In en, this message translates to:
  /// **'Say hello to your driver.'**
  String get sayHelloToYourDriver;

  /// No description provided for @typeAMessageHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessageHint;

  /// No description provided for @shipmentPaymentDescription.
  ///
  /// In en, this message translates to:
  /// **'Shipment payment'**
  String get shipmentPaymentDescription;

  /// No description provided for @paymentWasNotCompleted.
  ///
  /// In en, this message translates to:
  /// **'Payment was not completed.'**
  String get paymentWasNotCompleted;

  /// No description provided for @couldNotCompletePaymentTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Could not complete the payment. Try again.'**
  String get couldNotCompletePaymentTryAgain;

  /// No description provided for @openingPaymentEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Opening payment…'**
  String get openingPaymentEllipsis;

  /// No description provided for @payRemainingAmount.
  ///
  /// In en, this message translates to:
  /// **'Pay Remaining Amount'**
  String get payRemainingAmount;

  /// No description provided for @payAdvance.
  ///
  /// In en, this message translates to:
  /// **'Pay Advance'**
  String get payAdvance;

  /// No description provided for @payNow.
  ///
  /// In en, this message translates to:
  /// **'Pay Now'**
  String get payNow;

  /// No description provided for @useMyCurrentLocation.
  ///
  /// In en, this message translates to:
  /// **'Use my current location'**
  String get useMyCurrentLocation;

  /// No description provided for @textSize.
  ///
  /// In en, this message translates to:
  /// **'Text Size'**
  String get textSize;

  /// No description provided for @textSizeScreenHint.
  ///
  /// In en, this message translates to:
  /// **'Choose how large text appears throughout the app.'**
  String get textSizeScreenHint;

  /// No description provided for @textSizeSmall.
  ///
  /// In en, this message translates to:
  /// **'Small'**
  String get textSizeSmall;

  /// No description provided for @textSizeStandard.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get textSizeStandard;

  /// No description provided for @textSizeLarge.
  ///
  /// In en, this message translates to:
  /// **'Large'**
  String get textSizeLarge;

  /// No description provided for @textSizeExtraLarge.
  ///
  /// In en, this message translates to:
  /// **'Extra Large'**
  String get textSizeExtraLarge;

  /// No description provided for @textSizeSampleText.
  ///
  /// In en, this message translates to:
  /// **'The quick brown fox'**
  String get textSizeSampleText;
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
