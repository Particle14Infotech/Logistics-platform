// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'RaahMitr';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get signOut => 'Sign out';

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
  String get personalInformation => 'Personal Information';

  @override
  String get addresses => 'Addresses';

  @override
  String get paymentMethods => 'Payment Methods';

  @override
  String get notifications => 'Notifications';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get language => 'Language';

  @override
  String get changePassword => 'Change Password';

  @override
  String get helpAndSupport => 'Help & Support';

  @override
  String get about => 'About';

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
  String get logInWithEmailToContinue => 'Log in with your email to continue';

  @override
  String get signUpWithEmailToGetStarted =>
      'Sign up with your email to get started';

  @override
  String weveSentVerificationLinkTo(String email) {
    return 'We\'ve sent a verification link to\n$email';
  }

  @override
  String get emailAddress => 'Email address';

  @override
  String get password => 'Password';

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
  String get sixDigitCode => '6-digit code';

  @override
  String get verifyAndContinue => 'Verify & Continue';

  @override
  String resendCodeInSeconds(int seconds) {
    return 'Resend code in ${seconds}s';
  }

  @override
  String get resendCode => 'Resend code';

  @override
  String get tenDigitMobileNumber => '10-digit mobile number';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get passwordMinCharsHint => 'Password (min 6 characters)';

  @override
  String get confirmPassword => 'Confirm password';

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
  String get onboardingTitle1 => 'Easy Shipping,\nSmarter Business';

  @override
  String get onboardingBody1 =>
      'Smart shipping saves time, cuts costs\nand grows businesses faster.';

  @override
  String get onboardingTitle2 => 'Track Live,\nDoor to Door';

  @override
  String get onboardingBody2 =>
      'Watch your driver approach on the map\nwith real-time ETA updates.';

  @override
  String get onboardingTitle3 => 'Pay Your Way,\nEvery Time';

  @override
  String get onboardingBody3 =>
      'UPI, cards, net banking, or wallet -\nyour choice, every booking.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get next => 'Next';

  @override
  String get pressBackAgainToExit => 'Press back again to exit';

  @override
  String get view => 'View';

  @override
  String get home => 'Home';

  @override
  String get orders => 'Orders';

  @override
  String get couldNotLoadYourBookings => 'Could not load your bookings.';

  @override
  String heyNameWave(String name) {
    return 'Hey $name 👋';
  }

  @override
  String get thereFallbackName => 'there';

  @override
  String get whereAreWeShippingToday => 'Where are we shipping today?';

  @override
  String get searchShipmentsHint => 'Search shipments by waybill or address';

  @override
  String get bookNewShipment => 'Book a New Shipment';

  @override
  String get getInstantPriceBookDelivery =>
      'Get instant price and book your delivery';

  @override
  String get priceCalculator => 'Price Calculator';

  @override
  String get myOrders => 'My Orders';

  @override
  String get support => 'Support';

  @override
  String get searchResults => 'Search results';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get viewAll => 'View All';

  @override
  String noShipmentsMatch(String query) {
    return 'No shipments match \"$query\".';
  }

  @override
  String get noBookingsYetTapAway =>
      'No bookings yet - your first one is just a tap away.';

  @override
  String get statusPaymentPending => 'Payment Pending';

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
  String get raahmitrCustomerAppLine => 'RaahMitr Customer App';

  @override
  String versionNumber(String number) {
    return 'Version $number';
  }

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
  String get notificationsNotAllowedWarning =>
      'Notifications are not allowed - booking and delivery updates won\'t reach you until you enable them.';

  @override
  String get enableNotifications => 'Enable notifications';

  @override
  String get notificationsBlockedManualEnableHint =>
      'If nothing happens when you tap that, your phone has already blocked this app - enable it manually in your phone\'s Settings > Apps > Notifications.';

  @override
  String get pushNotifications => 'Push notifications';

  @override
  String get pushNotificationsDescription =>
      'Booking updates, driver assignment, and delivery confirmations.';

  @override
  String get saved => 'Saved.';

  @override
  String get email => 'Email';

  @override
  String get phone => 'Phone';

  @override
  String get businessGstinOptional => 'Business GSTIN (optional)';

  @override
  String get usedOnInvoicesIfAny =>
      'Used on your booking invoices, if you have one.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get couldNotLoadYourAddresses => 'Could not load your addresses.';

  @override
  String get addAddress => 'Add address';

  @override
  String get editAddress => 'Edit address';

  @override
  String get labelHint => 'Label (e.g. Home, Office)';

  @override
  String get fullAddress => 'Full address';

  @override
  String get couldNotSaveThisAddress => 'Could not save this address.';

  @override
  String get couldNotRemoveThisAddress => 'Could not remove this address.';

  @override
  String get noSavedAddressesYet =>
      'No saved addresses yet - tap + to add one.';

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get couldNotLoadPaymentHistory => 'Could not load payment history.';

  @override
  String get removeCardQuestion => 'Remove card?';

  @override
  String removeCardConfirm(String network, String last4) {
    return 'Remove the $network card ending in $last4?';
  }

  @override
  String get remove => 'Remove';

  @override
  String get couldNotRemoveThatCard => 'Could not remove that card.';

  @override
  String get savedCards => 'Saved cards';

  @override
  String get noSavedCardsYet =>
      'No saved cards yet - check \"Save this card\" during your next payment.';

  @override
  String get transactionHistory => 'Transaction history';

  @override
  String get noPaymentsYet => 'No payments yet.';

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
  String get newPassword => 'New password';

  @override
  String get confirmNewPassword => 'Confirm new password';

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
  String get turnOnLocationServices =>
      'Turn on location services to use your current location.';

  @override
  String get locationPermissionRequired =>
      'Location permission is required to use your current location.';

  @override
  String get couldNotDetermineAddressTryAgain =>
      'Could not determine your address. Try again.';

  @override
  String get couldNotGetCurrentLocationTryAgain =>
      'Could not get your current location. Try again.';

  @override
  String get enterBothPickupAndDrop => 'Enter both a pickup and drop location.';

  @override
  String get pickupDropCannotBeSame =>
      'Pickup and drop can\'t be the same place.';

  @override
  String get couldNotVerifyAddressPickSuggestion =>
      'Could not verify one of these addresses. Pick a suggestion from the list, or use current location for pickup.';

  @override
  String get whereTo => 'Where to?';

  @override
  String get pickupLocation => 'Pickup location';

  @override
  String get dropLocation => 'Drop location';

  @override
  String get continueLabel => 'Continue';

  @override
  String get bookingConfirmed => 'Booking Confirmed!';

  @override
  String get shipmentBookedSuccessfully =>
      'Your shipment has been successfully booked.';

  @override
  String get estimatedPrice => 'Estimated Price';

  @override
  String payAdvanceNowCashAtDelivery(String advance, String remaining) {
    return 'Pay ₹$advance now, ₹$remaining in cash at delivery';
  }

  @override
  String payCashAtDeliveryNoAdvance(String amount) {
    return 'Pay ₹$amount in cash at delivery - no advance required';
  }

  @override
  String payAdvanceNowRemainingOnlineNearDelivery(
      String advance, String remaining) {
    return 'Pay ₹$advance now, remaining ₹$remaining due online near delivery';
  }

  @override
  String get trackShipment => 'Track Shipment';

  @override
  String get trackShipmentAvailableOnceAdvanceConfirmed =>
      'Track Shipment will be available once your advance payment is confirmed.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get bodyTypeBike => 'Bike';

  @override
  String get bodyTypeAuto => 'Auto';

  @override
  String get bodyTypeOpen => 'Open';

  @override
  String get bodyTypeContainer => 'Container';

  @override
  String get bodyTypeTrailer => 'Trailer';

  @override
  String get filterByCargoWeight => 'Filter by cargo weight';

  @override
  String get weightKgFieldLabel => 'Weight (kg)';

  @override
  String get weightFilterChipLabel => 'Weight';

  @override
  String weightKgChipValue(String weight) {
    return '$weight kg';
  }

  @override
  String get clear => 'Clear';

  @override
  String get apply => 'Apply';

  @override
  String get selectVehicle => 'Select Vehicle';

  @override
  String get couldNotLoadVehicleTypes =>
      'Could not load vehicle types. Check your connection and try again.';

  @override
  String get noVehicleTypesAvailable =>
      'No vehicle types are available right now.';

  @override
  String get noVehiclesMatchThisWeight =>
      'No vehicles match this weight in this category.';

  @override
  String get goodsTypeGeneralCargo => 'General cargo';

  @override
  String get goodsTypeFurniture => 'Furniture';

  @override
  String get goodsTypeElectronics => 'Electronics';

  @override
  String get goodsTypeFoodGroceries => 'Food & groceries';

  @override
  String get goodsTypeDocuments => 'Documents';

  @override
  String get goodsTypeIndustrialEquipment => 'Industrial equipment';

  @override
  String get goodsTypeOther => 'Other';

  @override
  String get enterValidWeightKg => 'Enter a valid weight in kg.';

  @override
  String vehicleCanCarryUpTo(String name, String maxWeight) {
    return '$name can carry up to ${maxWeight}kg - choose a bigger vehicle or reduce the weight.';
  }

  @override
  String get couldNotGetFareEstimateTryAgain =>
      'Could not get a fare estimate. Check your connection and try again.';

  @override
  String get loadDetails => 'Load details';

  @override
  String get goodsType => 'Goods type';

  @override
  String get fragile => 'Fragile';

  @override
  String get fragileSubtitle => 'Extra care during handling';

  @override
  String get addInsurance => 'Add insurance';

  @override
  String get addInsuranceSubtitle => 'Covers loss or damage in transit';

  @override
  String get receiverDetails => 'Receiver details';

  @override
  String get receiverDetailsSubtitle =>
      'Optional - filled into your invoice/waybill';

  @override
  String get receiversName => 'Receiver\'s name';

  @override
  String get receiversPhone => 'Receiver\'s phone';

  @override
  String get receiversGstinOptional => 'Receiver\'s GSTIN (optional)';

  @override
  String get getFareEstimate => 'Get fare estimate';

  @override
  String get couldNotConfirmBookingTryAgain =>
      'Could not confirm this booking. Try again.';

  @override
  String get priceSummary => 'Price Summary';

  @override
  String get noEstimateFoundForBooking => 'No estimate found for this booking.';

  @override
  String get startNewBooking => 'Start a new booking';

  @override
  String get vehicleLabel => 'Vehicle';

  @override
  String get distanceLabel => 'Distance';

  @override
  String get weightLabel => 'Weight';

  @override
  String get fareBreakdown => 'Fare Breakdown';

  @override
  String get baseFare => 'Base Fare';

  @override
  String get distanceCharge => 'Distance Charge';

  @override
  String get weightCharge => 'Weight Charge';

  @override
  String surgeMultiplierLabel(String multiplier) {
    return 'Surge (${multiplier}x)';
  }

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get finalAmountMayVarySlightly => 'Final amount may vary slightly';

  @override
  String get confirmBooking => 'Confirm Booking';

  @override
  String get paymentMethod => 'Payment Method';

  @override
  String get payOnline => 'Pay Online';

  @override
  String payOnlineAdvanceSubtitle(String advance, String remaining) {
    return '₹$advance due now online, remaining ₹$remaining due online near delivery';
  }

  @override
  String get payOnlineFullSubtitle => 'Pay the full amount now via card/UPI';

  @override
  String get cashOnDelivery => 'Cash on Delivery';

  @override
  String codAdvanceSubtitle(String advance, String remaining) {
    return '₹$advance due now online, remaining ₹$remaining in cash at delivery';
  }

  @override
  String get codFullSubtitle => 'Pay the full amount in cash at delivery';

  @override
  String get enterBothPickupDropLocations =>
      'Enter both pickup and drop locations.';

  @override
  String get selectAVehicleType => 'Select a vehicle type.';

  @override
  String vehicleCanCarryUpToShort(String name, String maxWeight) {
    return '$name can carry up to $maxWeight kg.';
  }

  @override
  String get couldNotCalculatePriceTryAgain =>
      'Could not calculate a price. Try again.';

  @override
  String get vehicleTypeLabel => 'Vehicle type';

  @override
  String get couldNotLoadVehicleTypesShort => 'Could not load vehicle types.';

  @override
  String get weightKgOptionalHint => 'Weight (kg) - optional';

  @override
  String get calculate => 'Calculate';

  @override
  String get recalculate => 'Recalculate';

  @override
  String get estimatedFare => 'Estimated Fare';

  @override
  String get thisIsOnlyEstimateNotBooking =>
      'This is only an estimate - not a booking.';

  @override
  String get filterAll => 'All';

  @override
  String get filterActive => 'Active';

  @override
  String get couldNotLoadYourOrders => 'Could not load your orders.';

  @override
  String get noOrdersHereYet => 'No orders here yet.';

  @override
  String get tapStarToRate => 'Tap a star to rate your driver.';

  @override
  String get couldNotSubmitReviewTryAgain =>
      'Could not submit your review. Try again.';

  @override
  String get couldNotLoadThisBooking => 'Could not load this booking.';

  @override
  String get reportAnIssue => 'Report an issue';

  @override
  String get disputeCategoryLabel => 'Category';

  @override
  String get disputeCategoryPayment => 'Payment';

  @override
  String get disputeCategoryDamage => 'Damaged goods';

  @override
  String get disputeCategoryDelay => 'Delay';

  @override
  String get disputeCategoryBehavior => 'Driver behavior';

  @override
  String get disputeCategoryPricing => 'Pricing';

  @override
  String get disputeCategoryOther => 'Other';

  @override
  String get whatHappenedLabel => 'What happened?';

  @override
  String get describeWhatHappened => 'Describe what happened.';

  @override
  String get reportedTeamWillLookIntoIt =>
      'Reported - our team will look into it.';

  @override
  String get couldNotSubmitThisTryAgain => 'Could not submit this. Try again.';

  @override
  String get submittingEllipsis => 'Submitting…';

  @override
  String get submit => 'Submit';

  @override
  String get cancelBookingQuestion => 'Cancel booking?';

  @override
  String cancellationFeeWarning(String fee) {
    return 'A driver has already accepted this job. A ₹$fee cancellation fee will be deducted from your refund as driver compensation.';
  }

  @override
  String get cannotBeUndone => 'This cannot be undone.';

  @override
  String get keepBooking => 'Keep booking';

  @override
  String get cancelBooking => 'Cancel booking';

  @override
  String get couldNotCancelThisBooking => 'Could not cancel this booking.';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get paymentPendingTitle => 'Payment pending';

  @override
  String get payAdvanceToConfirmTrackingAvailable =>
      'Pay the advance to confirm this booking - tracking will be available right after.';

  @override
  String get findingADriver => 'Finding a driver…';

  @override
  String get pickupSuccessfulDriverAtLocation =>
      'Pickup successful! Your driver is at the pickup location.';

  @override
  String get shipmentDeliveredExclaim => 'Your shipment has been delivered!';

  @override
  String payToCompleteOrder(String amount) {
    return 'Pay ₹$amount to complete this order.';
  }

  @override
  String get giveCodeToStartTrip =>
      'Give this code to your driver to start the trip';

  @override
  String get giveCodeAtDropOff => 'Give this code to your driver at drop-off';

  @override
  String get onlineValue => 'Online';

  @override
  String get advancePaid => 'Advance Paid';

  @override
  String get advanceDueNow => 'Advance Due Now';

  @override
  String get dueInCashAtDelivery => 'Due in Cash at Delivery';

  @override
  String get remainderPaid => 'Remainder Paid';

  @override
  String get remainderDueOnline => 'Remainder Due Online';

  @override
  String get preparingEllipsis => 'Preparing…';

  @override
  String get downloadInvoice => 'Download invoice';

  @override
  String get couldNotDownloadInvoice => 'Could not download the invoice.';

  @override
  String get yourRating => 'Your rating';

  @override
  String get rateYourDriver => 'Rate your driver';

  @override
  String get addCommentOptional => 'Add a comment (optional)';

  @override
  String get submitReview => 'Submit review';

  @override
  String get showThisToDriverAtPickup => 'Show this to your driver at pickup';

  @override
  String get waitingForDriverGpsSignal =>
      'Waiting for your driver\'s GPS signal…';

  @override
  String get cancellingEllipsis => 'Cancelling…';

  @override
  String get couldNotLoadNotifications => 'Could not load notifications.';

  @override
  String get markAllRead => 'Mark all read';

  @override
  String get allCaughtUpNothingHereYet =>
      'You\'re all caught up - nothing here yet.';

  @override
  String get couldNotLoadMessages => 'Could not load messages.';

  @override
  String get chatWithDriver => 'Chat with driver';

  @override
  String get sayHelloToYourDriver => 'Say hello to your driver.';

  @override
  String get typeAMessageHint => 'Type a message…';

  @override
  String get shipmentPaymentDescription => 'Shipment payment';

  @override
  String get paymentWasNotCompleted => 'Payment was not completed.';

  @override
  String get couldNotCompletePaymentTryAgain =>
      'Could not complete the payment. Try again.';

  @override
  String get openingPaymentEllipsis => 'Opening payment…';

  @override
  String get payRemainingAmount => 'Pay Remaining Amount';

  @override
  String get payAdvance => 'Pay Advance';

  @override
  String get payNow => 'Pay Now';

  @override
  String get useMyCurrentLocation => 'Use my current location';
}
