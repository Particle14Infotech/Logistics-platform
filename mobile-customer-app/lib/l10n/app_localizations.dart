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
