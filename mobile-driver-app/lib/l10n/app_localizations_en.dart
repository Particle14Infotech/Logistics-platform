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

  @override
  String get fillInAllFields => 'Fill in all fields.';

  @override
  String get phoneAlreadyRegisteredDifferentRole =>
      'This phone number is already registered under a different role (e.g. as a customer). Sign out and use a different phone number to sign up as a driver.';

  @override
  String get enterpriseCodeNotValid =>
      'That enterprise code isn\'t valid. Check it with your company, or leave it blank to drive independently.';

  @override
  String get couldNotSubmitDetailsTryAgain =>
      'Could not submit your details. Try again.';

  @override
  String get takeSelfieRequired =>
      'Take a selfie to continue - this is required for identity verification.';

  @override
  String get couldNotUploadSelfieTryAgain =>
      'Could not upload your selfie. Try again.';

  @override
  String get vehicleDetails => 'Vehicle details';

  @override
  String get tellUsAboutYourVehicle =>
      'Tell us about your vehicle to get started.';

  @override
  String get vehicleRegistrationNumberHint => 'e.g. DL 01 AB 1234';

  @override
  String get drivingLicenseNumber => 'Driving license number';

  @override
  String get enterpriseInviteCodeOptional =>
      'Enterprise invite code (optional)';

  @override
  String get enterpriseInviteCodeHint =>
      'e.g. ENT-A1B2C3D4 - only if a company gave you one';

  @override
  String get continueLabel => 'Continue';

  @override
  String get verifyYourIdentity => 'Verify your identity';

  @override
  String get selfieInstructions =>
      'Take a clear selfie in good lighting. An admin reviews this alongside your documents before approving your account.';

  @override
  String get takeSelfie => 'Take selfie';

  @override
  String get submitForApproval => 'Submit for approval';

  @override
  String get jobRequests => 'Job requests';

  @override
  String get couldNotLoadJobRequests => 'Could not load job requests.';

  @override
  String get jobNoLongerAvailable => 'This job is no longer available.';

  @override
  String get noJobsAvailablePullToRefresh =>
      'No jobs available right now. Pull to refresh.';

  @override
  String get cargoFallback => 'Cargo';

  @override
  String get pass => 'Pass';

  @override
  String get accept => 'Accept';

  @override
  String get jobDetails => 'Job Details';

  @override
  String codCollectAtDropOff(String amount) {
    return 'Cash on Delivery - ₹$amount to collect at drop-off';
  }

  @override
  String onlineAdvancePaidRemainderNearDelivery(String amount) {
    return 'Online - ₹$amount advance paid, remainder collected online near delivery';
  }

  @override
  String get goodsLabel => 'Goods';

  @override
  String get weightLabel => 'Weight';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get customerLabel => 'Customer';

  @override
  String get enterYourCompanyName => 'Enter your company name.';

  @override
  String get couldNotCreateFleetAccountTryAgain =>
      'Could not create your fleet account. Try again.';

  @override
  String get setUpYourFleet => 'Set up your fleet';

  @override
  String get whatsYourCompanyCalled => 'What\'s your company called?';

  @override
  String get companyName => 'Company name';

  @override
  String get couldNotLoadFleetData => 'Could not load fleet data.';

  @override
  String get removeVehicleQuestion => 'Remove vehicle?';

  @override
  String removeVehicleConfirm(String vehicleNumber, String driverName) {
    return '$vehicleNumber will be removed from your fleet. $driverName keeps their account as an independent driver - this does not delete anything, just detaches it from your fleet.';
  }

  @override
  String get remove => 'Remove';

  @override
  String get theDriverFallback => 'The driver';

  @override
  String get couldNotRemoveThatVehicle => 'Could not remove that vehicle.';

  @override
  String get fleet => 'Fleet';

  @override
  String get notificationSettingsMenuItem => 'Notification settings';

  @override
  String get changePasswordMenuItem => 'Change password';

  @override
  String get addVehicle => 'Add vehicle';

  @override
  String get vehiclesLabel => 'Vehicles';

  @override
  String approvedCount(int count) {
    return '$count approved';
  }

  @override
  String get activeNow => 'Active now';

  @override
  String liveOrdersCount(int count) {
    return '$count live orders';
  }

  @override
  String get totalEarnings => 'Total earnings';

  @override
  String get yourVehicles => 'Your vehicles';

  @override
  String get noVehiclesYetTapAddVehicle =>
      'No vehicles yet - tap \"Add vehicle\" to register your first one.';

  @override
  String get unassigned => 'Unassigned';

  @override
  String vehicleSummaryLine(String driverName, String trips, String earnings,
      String docsUploaded, String docsTotal) {
    return '$driverName · $trips trips · ₹$earnings · KYC docs $docsUploaded/$docsTotal';
  }

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get pending => 'Pending';

  @override
  String get removeFromFleet => 'Remove from fleet';

  @override
  String get fillAllFieldsValidPhone =>
      'Fill in all fields with a valid 10-digit phone number.';

  @override
  String get vehicleAdded => 'Vehicle added';

  @override
  String driverStillNeedsSelfie(String driverName) {
    return '$driverName still needs to sign in on their own phone and complete their KYC selfie before this vehicle can be approved - that step can\'t be done from here.';
  }

  @override
  String get gotIt => 'Got it';

  @override
  String get couldNotAddVehiclePhoneMayExist =>
      'Could not add this vehicle. The phone number may already be registered under a different role.';

  @override
  String get driverDetails => 'Driver details';

  @override
  String get driversName => 'Driver\'s name';

  @override
  String get driversPhoneNumber => 'Driver\'s phone number';

  @override
  String get driversLicenseNumber => 'Driver\'s license number';

  @override
  String couldNotLoadYourProfile(String error) {
    return 'Could not load your profile.\n$error';
  }

  @override
  String heyName(String name) {
    return 'Hey $name';
  }

  @override
  String get thereFallbackName => 'there';

  @override
  String get onlineReadyForJobs => 'Online - ready for jobs';

  @override
  String get searchTripsWaybillHint => 'Search trips, waybill no.';

  @override
  String get tripInProgress => 'Trip in progress';

  @override
  String get viewJobRequests => 'View job requests';

  @override
  String get tapToResumeTracking => 'Tap to resume tracking';

  @override
  String get browseBookingsNearYou => 'Browse bookings near you';

  @override
  String get searchResults => 'Search results';

  @override
  String get recentTrips => 'Recent trips';

  @override
  String get viewAll => 'View All';

  @override
  String noTripsMatch(String query) {
    return 'No trips match \"$query\".';
  }

  @override
  String get noTripsYet => 'No trips yet.';

  @override
  String get pendingApproval => 'Pending approval';

  @override
  String get verifyingVehicleDetails =>
      'We\'re verifying your vehicle details. You\'ll be able to go online once an admin approves your account.';

  @override
  String get uploadRemainingDocuments => 'Upload remaining documents';

  @override
  String get checkStatus => 'Check status';

  @override
  String get stillPendingApprovalCheckBack =>
      'Still pending approval - check back soon.';

  @override
  String get enterValidEmail => 'Enter a valid email address.';

  @override
  String get enterYourPassword => 'Enter your password.';

  @override
  String get couldNotLogInTryAgain => 'Could not log in. Try again.';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters.';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match.';

  @override
  String get couldNotCreateAccountTryAgain =>
      'Could not create your account. Try again.';

  @override
  String get notVerifiedYetTapLink =>
      'Not verified yet - tap the link in the email we sent you.';

  @override
  String get couldNotCheckVerificationTryAgain =>
      'Could not check verification status. Try again.';

  @override
  String get couldNotResendEmailTryAgain =>
      'Could not resend the email. Try again.';

  @override
  String get couldNotSendCodeTryAgain => 'Could not send the code. Try again.';

  @override
  String get enterSixDigitCode => 'Enter the 6-digit code.';

  @override
  String get incorrectOrExpiredCode => 'Incorrect or expired code.';

  @override
  String get couldNotVerifyCodeTryAgain =>
      'Could not verify that code. Try again.';

  @override
  String get enterFullName => 'Enter your full name.';

  @override
  String get enterValidPhoneNumber10Digit =>
      'Enter a valid 10-digit phone number.';

  @override
  String get selectYourDob => 'Select your date of birth.';

  @override
  String get couldNotSaveDetailsTryAgain =>
      'Could not save your details. Try again.';

  @override
  String get enterEmailFirstThenForgot =>
      'Enter your email above first, then tap \"Forgot password?\".';

  @override
  String passwordResetLinkSentTo(String email) {
    return 'Password reset link sent to $email';
  }

  @override
  String get enterValidMobileNumber => 'Enter a valid 10-digit mobile number.';

  @override
  String get accountExistsForEmailTryLogin =>
      'An account already exists for that email. Try logging in instead.';

  @override
  String get emailLooksInvalid => 'That email address looks invalid.';

  @override
  String get chooseStrongerPassword => 'Choose a stronger password.';

  @override
  String get incorrectEmailOrPassword => 'Incorrect email or password.';

  @override
  String get tooManyAttemptsTryAgain =>
      'Too many attempts. Try again in a moment.';

  @override
  String get phoneNumberLooksInvalid => 'That phone number looks invalid.';

  @override
  String get codeExpiredRequestNew => 'That code expired - request a new one.';

  @override
  String get somethingWentWrongTryAgain => 'Something went wrong. Try again.';

  @override
  String get verifyYourNumber => 'Verify Your Number';

  @override
  String get welcomeExclaim => 'Welcome!';

  @override
  String weveSentCodeToPhone(String phone) {
    return 'We\'ve sent a 6-digit code to\n+91 $phone';
  }

  @override
  String get logInOrSignUpWithMobile =>
      'Log in or sign up with your mobile number';

  @override
  String get welcomeBack => 'Welcome Back!';

  @override
  String get createAccount => 'Create Account';

  @override
  String get verifyYourEmail => 'Verify Your Email';

  @override
  String get tellUsAboutYourself => 'Tell Us About Yourself';

  @override
  String get logInWithEmailToContinue => 'Log in with your email to continue';

  @override
  String get signUpWithEmailToGetStarted =>
      'Sign up with your email to get started';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'We\'ve sent a verification link to\n$email';
  }

  @override
  String get thisHelpsCustomersSupportIdentifyYou =>
      'This helps customers and support identify you.';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailExampleHint => 'you@example.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get yourPasswordHint => 'Your password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get logIn => 'Log In';

  @override
  String get dontHaveAccountSignUp => 'Don\'t have an account? Sign up';

  @override
  String get emailMethod => 'Email';

  @override
  String get phoneMethod => 'Phone';

  @override
  String get verificationCode => 'Verification code';

  @override
  String get sixDigitCodeHint => '6-digit code';

  @override
  String get verifyAndContinue => 'Verify & Continue';

  @override
  String resendCodeInSeconds(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get phoneNumberLabel => 'Phone number';

  @override
  String get phoneNumberSampleHint => '98765 43210';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get min6CharsHintPassword => 'Min 6 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get reEnterPasswordHint => 'Re-enter password';

  @override
  String get signUp => 'Sign Up';

  @override
  String get alreadyHaveAccountLogIn => 'Already have an account? Log in';

  @override
  String get sendCode => 'Send code';

  @override
  String get verifyCode => 'Verify code';

  @override
  String get useLinkInstead => 'Use the link instead';

  @override
  String get iveVerifiedMyEmail => 'I\'ve verified my email';

  @override
  String get verificationEmailSentAgain => 'Verification email sent again';

  @override
  String get resendVerificationEmail => 'Resend verification email';

  @override
  String get enterCodeInstead => 'Enter code instead';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get yourNameHint => 'Your name';

  @override
  String get dateOfBirth => 'Date of birth';

  @override
  String get selectYourDateOfBirth => 'Select your date of birth';

  @override
  String get turnOnLocationServicesShare =>
      'Turn on location services to share your position with the customer.';

  @override
  String get locationPermissionDeniedNoShare =>
      'Location permission denied - the customer won\'t see your live position.';

  @override
  String get bookingWasCancelled => 'This booking was cancelled.';

  @override
  String get couldNotLoadThisTrip => 'Could not load this trip.';

  @override
  String get couldNotUpdateTripStatus => 'Could not update trip status.';

  @override
  String get markAsPickedUpQuestion => 'Mark as picked up?';

  @override
  String get manualPickupWarning =>
      'Only use this if you can\'t scan the customer\'s QR code. This doesn\'t check anything - it just confirms pickup.';

  @override
  String get confirm => 'Confirm';

  @override
  String get couldNotUploadDocuments => 'Could not upload the document(s).';

  @override
  String get askCustomerStartCode =>
      'Ask the customer for their 6-digit start code.';

  @override
  String get askCustomerDeliveryCode =>
      'Ask the customer for their 6-digit delivery code.';

  @override
  String get confirmCashCollectedBeforeDelivery =>
      'Confirm you\'ve collected the remaining cash before completing delivery.';

  @override
  String get couldNotConfirmDeliveryTryAgain =>
      'Could not confirm delivery. Check your connection and try again.';

  @override
  String get couldNotDownloadInvoice => 'Could not download the invoice.';

  @override
  String get deliveryWaybillShareText => 'Delivery waybill';

  @override
  String get addEwayBillNumberTitle => 'Add E-Way Bill Number';

  @override
  String get ewayBillNoHint => 'E-Way Bill No.';

  @override
  String get ewayBillSaved => 'E-Way Bill number saved.';

  @override
  String get couldNotSaveEwayBillNumber =>
      'Could not save the E-Way Bill number.';

  @override
  String get leaveThisTripQuestion => 'Leave this trip?';

  @override
  String get leaveTripWarning =>
      'Going back stops sharing your live location with the customer until you reopen this trip. The trip itself stays active.';

  @override
  String get stay => 'Stay';

  @override
  String get leave => 'Leave';

  @override
  String get activeTrip => 'Active Trip';

  @override
  String get sharingLiveLocation =>
      'Sharing your live location with the customer';

  @override
  String get reconnectingLiveLocation =>
      'Reconnecting - the customer may not see your live position right now';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get cashToCollect => 'Cash to collect';

  @override
  String get remainingOnline => 'Remaining (online)';

  @override
  String get fareLabel => 'Fare';

  @override
  String get updatingEllipsis => 'Updating…';

  @override
  String get scanPickupQrCode => 'Scan pickup QR code';

  @override
  String get markAsPickedUpManually => 'Mark as picked up manually';

  @override
  String get pickupDocumentsTitle => 'Pickup documents';

  @override
  String get uploadPickupDocHint =>
      'Upload at least one pickup document (LR copy, invoice, gate pass, etc.) handed over at the pickup point before you can start the trip.';

  @override
  String get askCustomerStartCodePrompt =>
      'Ask the customer for their start code to begin the trip:';

  @override
  String get startingEllipsis => 'Starting…';

  @override
  String get startTrip => 'Start trip';

  @override
  String get deliveryDocumentsTitle => 'Delivery documents';

  @override
  String get uploadDeliveryDocHint =>
      'Upload at least one delivery document (signed receipt, POD photo, etc.) before you can confirm delivery.';

  @override
  String get askCustomerDeliveryCodePrompt =>
      'Ask the customer for their delivery code to confirm drop-off:';

  @override
  String collectedCashCheckbox(String amount) {
    return 'I have collected ₹$amount in cash from the customer';
  }

  @override
  String onlineRemainderNote(String amount) {
    return 'The customer still owes ₹$amount online. Confirming will mark drop-off as done and ask them to pay - the trip completes automatically once they do.';
  }

  @override
  String get confirmingEllipsis => 'Confirming…';

  @override
  String get confirmDelivery => 'Confirm delivery';

  @override
  String get savingEllipsis => 'Saving…';

  @override
  String get addEwayBillNo => 'Add E-Way Bill No.';

  @override
  String get deliveryConfirmed => 'Delivery confirmed';

  @override
  String waitingForCustomerPay(String amount) {
    return 'Waiting for the customer to pay the remaining ₹$amount online. This screen updates automatically once paid.';
  }

  @override
  String get refresh => 'Refresh';

  @override
  String get tripComplete => 'This trip is complete.';

  @override
  String get preparingEllipsis => 'Preparing…';

  @override
  String get downloadInvoice => 'Download invoice';

  @override
  String get backToDashboard => 'Back to dashboard';

  @override
  String orderNumberLabel(String number) {
    return 'Order #$number';
  }

  @override
  String get gettingGpsPosition => 'Getting your GPS position…';

  @override
  String kmToDropOff(String km) {
    return '$km km to drop-off';
  }

  @override
  String get scanPackageBarcode => 'Scan package barcode';

  @override
  String get alignBarcodeInFrame => 'Align the barcode within the frame';

  @override
  String get uploadingEllipsis => 'Uploading…';

  @override
  String get addDocuments => 'Add documents';

  @override
  String get textSize => 'Text Size';

  @override
  String get textSizeScreenHint =>
      'Choose how large text appears throughout the app.';

  @override
  String get textSizeSmall => 'Small';

  @override
  String get textSizeStandard => 'Default';

  @override
  String get textSizeLarge => 'Large';

  @override
  String get textSizeExtraLarge => 'Extra Large';

  @override
  String get textSizeSampleText => 'The quick brown fox';
}
