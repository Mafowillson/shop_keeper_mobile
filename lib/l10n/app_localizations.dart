import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

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
    Locale('fr')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'ShopKeeper'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your shop, grow your business'**
  String get tagline;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @success.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get success;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get tryAgain;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No data found'**
  String get noDataFound;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @required.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// No description provided for @fieldRequired.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get fieldRequired;

  /// No description provided for @enterValidEmail.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email address'**
  String get enterValidEmail;

  /// No description provided for @passwordMinLength.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters long'**
  String get passwordMinLength;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required'**
  String get passwordRequired;

  /// No description provided for @passwordMinSixChars.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinSixChars;

  /// No description provided for @pleaseConfirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Please confirm your password'**
  String get pleaseConfirmPassword;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// No description provided for @fcfa.
  ///
  /// In en, this message translates to:
  /// **'FCFA'**
  String get fcfa;

  /// No description provided for @savingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Saving…'**
  String get savingEllipsis;

  /// No description provided for @loadingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loadingEllipsis;

  /// No description provided for @processingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Processing…'**
  String get processingEllipsis;

  /// No description provided for @recordingEllipsis.
  ///
  /// In en, this message translates to:
  /// **'Recording…'**
  String get recordingEllipsis;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @notSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get notSet;

  /// No description provided for @enterWholeNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter a whole number'**
  String get enterWholeNumber;

  /// No description provided for @mustBePositive.
  ///
  /// In en, this message translates to:
  /// **'Must be > 0'**
  String get mustBePositive;

  /// No description provided for @minOne.
  ///
  /// In en, this message translates to:
  /// **'Min 1'**
  String get minOne;

  /// No description provided for @nameMinTwoChars.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get nameMinTwoChars;

  /// No description provided for @enterValidEmailAddress.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get enterValidEmailAddress;

  /// No description provided for @enterValidPhone.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid phone number (min 9 digits)'**
  String get enterValidPhone;

  /// No description provided for @hintEmail.
  ///
  /// In en, this message translates to:
  /// **'your@email.com'**
  String get hintEmail;

  /// No description provided for @hintExEmail.
  ///
  /// In en, this message translates to:
  /// **'e.g. your@email.com'**
  String get hintExEmail;

  /// No description provided for @hintExFullName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Jean-Paul Mbassi'**
  String get hintExFullName;

  /// No description provided for @hintExPhone.
  ///
  /// In en, this message translates to:
  /// **'e.g. 677 000 000'**
  String get hintExPhone;

  /// No description provided for @hintExPhoneIntl.
  ///
  /// In en, this message translates to:
  /// **'e.g. 237612345678'**
  String get hintExPhoneIntl;

  /// No description provided for @hintExShopName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Willson\'s Boutique'**
  String get hintExShopName;

  /// No description provided for @hintExShopLocation.
  ///
  /// In en, this message translates to:
  /// **'e.g. Bamenda, Cameroon'**
  String get hintExShopLocation;

  /// No description provided for @hintExProductName.
  ///
  /// In en, this message translates to:
  /// **'e.g. Top Cube Sugar'**
  String get hintExProductName;

  /// No description provided for @hintExUnitName.
  ///
  /// In en, this message translates to:
  /// **'e.g. carton'**
  String get hintExUnitName;

  /// No description provided for @hintExThreshold.
  ///
  /// In en, this message translates to:
  /// **'e.g. 5'**
  String get hintExThreshold;

  /// No description provided for @hintExQtyInBase.
  ///
  /// In en, this message translates to:
  /// **'e.g. 25'**
  String get hintExQtyInBase;

  /// No description provided for @hintExPrice.
  ///
  /// In en, this message translates to:
  /// **'e.g. 21 000'**
  String get hintExPrice;

  /// No description provided for @welcomeBack.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get welcomeBack;

  /// No description provided for @signInToContinue.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// No description provided for @newHere.
  ///
  /// In en, this message translates to:
  /// **'New here?'**
  String get newHere;

  /// No description provided for @createAnAccount.
  ///
  /// In en, this message translates to:
  /// **'Create an account'**
  String get createAnAccount;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @ownerRole.
  ///
  /// In en, this message translates to:
  /// **'Owner'**
  String get ownerRole;

  /// No description provided for @staffRole.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffRole;

  /// No description provided for @registerOwnerAccount.
  ///
  /// In en, this message translates to:
  /// **'Register Owner Account'**
  String get registerOwnerAccount;

  /// No description provided for @createSecureAccount.
  ///
  /// In en, this message translates to:
  /// **'Create a secure account to manage your retail business'**
  String get createSecureAccount;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @minimumSixChars.
  ///
  /// In en, this message translates to:
  /// **'Minimum 6 characters'**
  String get minimumSixChars;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @growRetailBusiness.
  ///
  /// In en, this message translates to:
  /// **'Grow your retail business efficiently'**
  String get growRetailBusiness;

  /// No description provided for @forgotPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Forgot Password'**
  String get forgotPasswordTitle;

  /// No description provided for @forgotPasswordDescription.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address and we will send you instructions to reset your password.'**
  String get forgotPasswordDescription;

  /// No description provided for @sendRecoveryEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Recovery Email'**
  String get sendRecoveryEmail;

  /// No description provided for @backToSignIn.
  ///
  /// In en, this message translates to:
  /// **'Back to Sign In'**
  String get backToSignIn;

  /// No description provided for @checkYourInbox.
  ///
  /// In en, this message translates to:
  /// **'Check Your Inbox'**
  String get checkYourInbox;

  /// No description provided for @passwordRecoveryInstructions.
  ///
  /// In en, this message translates to:
  /// **'We\'ve sent password recovery instructions to:'**
  String get passwordRecoveryInstructions;

  /// No description provided for @enterResetCode.
  ///
  /// In en, this message translates to:
  /// **'Enter Reset Code'**
  String get enterResetCode;

  /// No description provided for @verifyYourEmail.
  ///
  /// In en, this message translates to:
  /// **'Verify Your Email'**
  String get verifyYourEmail;

  /// No description provided for @enterCodeSentTo.
  ///
  /// In en, this message translates to:
  /// **'Enter the 6-digit code sent to'**
  String get enterCodeSentTo;

  /// No description provided for @verifyEmailButton.
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get verifyEmailButton;

  /// No description provided for @didntReceiveCode.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive the code?'**
  String get didntReceiveCode;

  /// No description provided for @resend.
  ///
  /// In en, this message translates to:
  /// **'Resend'**
  String get resend;

  /// No description provided for @resendInSeconds.
  ///
  /// In en, this message translates to:
  /// **'Resend in {seconds}s'**
  String resendInSeconds(int seconds);

  /// No description provided for @useDifferentAccount.
  ///
  /// In en, this message translates to:
  /// **'Use a different account'**
  String get useDifferentAccount;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get resetPasswordTitle;

  /// No description provided for @newPassword.
  ///
  /// In en, this message translates to:
  /// **'New Password'**
  String get newPassword;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @didntReceiveIt.
  ///
  /// In en, this message translates to:
  /// **'Didn\'t receive it?'**
  String get didntReceiveIt;

  /// No description provided for @registerYourShop.
  ///
  /// In en, this message translates to:
  /// **'Register Your Shop'**
  String get registerYourShop;

  /// No description provided for @shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get shopName;

  /// No description provided for @shopLocation.
  ///
  /// In en, this message translates to:
  /// **'Shop Location / Address (Optional)'**
  String get shopLocation;

  /// No description provided for @completeOnboarding.
  ///
  /// In en, this message translates to:
  /// **'Complete Onboarding'**
  String get completeOnboarding;

  /// No description provided for @welcomeToShopKeeper.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ShopKeeper'**
  String get welcomeToShopKeeper;

  /// No description provided for @setUpBusinessDetails.
  ///
  /// In en, this message translates to:
  /// **'Let\'s set up your business details'**
  String get setUpBusinessDetails;

  /// No description provided for @recoverPasswordSecurely.
  ///
  /// In en, this message translates to:
  /// **'Recover your password securely'**
  String get recoverPasswordSecurely;

  /// No description provided for @accountCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Account created successfully!'**
  String get accountCreatedSuccessfully;

  /// No description provided for @shopRegisteredSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Shop registered successfully!'**
  String get shopRegisteredSuccessfully;

  /// No description provided for @passwordResetSuccess.
  ///
  /// In en, this message translates to:
  /// **'Password reset! Please log in with your new password.'**
  String get passwordResetSuccess;

  /// No description provided for @invalidCodeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get invalidCodeTryAgain;

  /// No description provided for @newCodeSent.
  ///
  /// In en, this message translates to:
  /// **'A new code has been sent.'**
  String get newCodeSent;

  /// No description provided for @couldNotSendCode.
  ///
  /// In en, this message translates to:
  /// **'Could not send code. Try again.'**
  String get couldNotSendCode;

  /// No description provided for @passwordResetFailed.
  ///
  /// In en, this message translates to:
  /// **'Password reset failed. Please try again.'**
  String get passwordResetFailed;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// No description provided for @sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @customers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get customers;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @helloName.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String helloName(String name);

  /// No description provided for @todaysRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get todaysRevenue;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// No description provided for @revenueLastSevenDays.
  ///
  /// In en, this message translates to:
  /// **'Revenue — Last 7 Days'**
  String get revenueLastSevenDays;

  /// No description provided for @weeklyTotal.
  ///
  /// In en, this message translates to:
  /// **'Weekly total'**
  String get weeklyTotal;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// No description provided for @recentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// No description provided for @noRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'No recent activity'**
  String get noRecentActivity;

  /// No description provided for @timeAgoMinutes.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String timeAgoMinutes(int count);

  /// No description provided for @timeAgoHours.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String timeAgoHours(int count);

  /// No description provided for @timeAgoDays.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String timeAgoDays(int count);

  /// No description provided for @stockOk.
  ///
  /// In en, this message translates to:
  /// **'Stock OK'**
  String get stockOk;

  /// No description provided for @noDebts.
  ///
  /// In en, this message translates to:
  /// **'No debts'**
  String get noDebts;

  /// No description provided for @addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get addProduct;

  /// No description provided for @viewSales.
  ///
  /// In en, this message translates to:
  /// **'View Sales'**
  String get viewSales;

  /// No description provided for @debts.
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debts;

  /// No description provided for @aiInsights.
  ///
  /// In en, this message translates to:
  /// **'AI Insights'**
  String get aiInsights;

  /// No description provided for @editProduct.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get editProduct;

  /// No description provided for @searchProductsHint.
  ///
  /// In en, this message translates to:
  /// **'Search products…'**
  String get searchProductsHint;

  /// No description provided for @productName.
  ///
  /// In en, this message translates to:
  /// **'Product name'**
  String get productName;

  /// No description provided for @productCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get productCreatedSuccessfully;

  /// No description provided for @productUpdated.
  ///
  /// In en, this message translates to:
  /// **'Product updated'**
  String get productUpdated;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categoryBeverages.
  ///
  /// In en, this message translates to:
  /// **'Beverages'**
  String get categoryBeverages;

  /// No description provided for @categorySnacksSweets.
  ///
  /// In en, this message translates to:
  /// **'Snacks & Sweets'**
  String get categorySnacksSweets;

  /// No description provided for @categoryGrainsStaples.
  ///
  /// In en, this message translates to:
  /// **'Grains & Staples'**
  String get categoryGrainsStaples;

  /// No description provided for @categoryDairyEggs.
  ///
  /// In en, this message translates to:
  /// **'Dairy & Eggs'**
  String get categoryDairyEggs;

  /// No description provided for @categoryCleaningHygiene.
  ///
  /// In en, this message translates to:
  /// **'Cleaning & Hygiene'**
  String get categoryCleaningHygiene;

  /// No description provided for @categoryHousehold.
  ///
  /// In en, this message translates to:
  /// **'Household'**
  String get categoryHousehold;

  /// No description provided for @categoryToiletries.
  ///
  /// In en, this message translates to:
  /// **'Toiletries'**
  String get categoryToiletries;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;

  /// No description provided for @productInfo.
  ///
  /// In en, this message translates to:
  /// **'Product Info'**
  String get productInfo;

  /// No description provided for @nameAndCategory.
  ///
  /// In en, this message translates to:
  /// **'Name and category'**
  String get nameAndCategory;

  /// No description provided for @units.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get units;

  /// No description provided for @unitName.
  ///
  /// In en, this message translates to:
  /// **'Unit name'**
  String get unitName;

  /// No description provided for @qtyInBase.
  ///
  /// In en, this message translates to:
  /// **'Qty in base'**
  String get qtyInBase;

  /// No description provided for @priceFCFA.
  ///
  /// In en, this message translates to:
  /// **'Price (FCFA)'**
  String get priceFCFA;

  /// No description provided for @perUnit.
  ///
  /// In en, this message translates to:
  /// **'/ unit'**
  String get perUnit;

  /// No description provided for @addAnotherUnit.
  ///
  /// In en, this message translates to:
  /// **'Add another unit'**
  String get addAnotherUnit;

  /// No description provided for @openingStock.
  ///
  /// In en, this message translates to:
  /// **'Opening Stock'**
  String get openingStock;

  /// No description provided for @currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get currentStock;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// No description provided for @removeProduct.
  ///
  /// In en, this message translates to:
  /// **'Remove product?'**
  String get removeProduct;

  /// No description provided for @noProductsYet.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get noProductsYet;

  /// No description provided for @addFirstProduct.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start tracking inventory.'**
  String get addFirstProduct;

  /// No description provided for @noProductsMatchSearch.
  ///
  /// In en, this message translates to:
  /// **'No products match your search'**
  String get noProductsMatchSearch;

  /// No description provided for @addProductTooltip.
  ///
  /// In en, this message translates to:
  /// **'Add product'**
  String get addProductTooltip;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'available'**
  String get available;

  /// No description provided for @baseUnitHint.
  ///
  /// In en, this message translates to:
  /// **'This is the base unit — stock is tracked in this unit'**
  String get baseUnitHint;

  /// No description provided for @howManyBaseUnits.
  ///
  /// In en, this message translates to:
  /// **'How many base units fit in this unit'**
  String get howManyBaseUnits;

  /// No description provided for @inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get inStock;

  /// No description provided for @outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get outOfStock;

  /// No description provided for @lowStockLabel.
  ///
  /// In en, this message translates to:
  /// **'Low ({qty})'**
  String lowStockLabel(int qty);

  /// No description provided for @deactivateProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'This will deactivate \"{name}\" from your inventory.'**
  String deactivateProductConfirm(String name);

  /// No description provided for @unitsFallback.
  ///
  /// In en, this message translates to:
  /// **'units'**
  String get unitsFallback;

  /// No description provided for @baseUnitBadge.
  ///
  /// In en, this message translates to:
  /// **'BASE'**
  String get baseUnitBadge;

  /// No description provided for @openingStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Enter how much you have now — leave blank if starting at zero'**
  String get openingStockSubtitle;

  /// No description provided for @currentStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Stock is updated automatically when sales are recorded'**
  String get currentStockSubtitle;

  /// No description provided for @errorOneUnitMustBeBase.
  ///
  /// In en, this message translates to:
  /// **'One unit must have quantity-in-base = 1 (the base unit).'**
  String get errorOneUnitMustBeBase;

  /// No description provided for @errorOnlyOneBase.
  ///
  /// In en, this message translates to:
  /// **'Only one unit can have quantity-in-base = 1.'**
  String get errorOnlyOneBase;

  /// No description provided for @errorUnitNamesUnique.
  ///
  /// In en, this message translates to:
  /// **'Unit names must be unique.'**
  String get errorUnitNamesUnique;

  /// No description provided for @unitNumber.
  ///
  /// In en, this message translates to:
  /// **'Unit {number}'**
  String unitNumber(int number);

  /// No description provided for @stockTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} {unit}'**
  String stockTotal(int count, String unit);

  /// No description provided for @lowStockAlertSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Alert when stock falls below this many {unit}'**
  String lowStockAlertSubtitle(String unit);

  /// No description provided for @thresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Threshold (in {unit})'**
  String thresholdLabel(String unit);

  /// No description provided for @newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get newSale;

  /// No description provided for @salesHistory.
  ///
  /// In en, this message translates to:
  /// **'Sales History'**
  String get salesHistory;

  /// No description provided for @saleDetail.
  ///
  /// In en, this message translates to:
  /// **'Sale Detail'**
  String get saleDetail;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @payment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get payment;

  /// No description provided for @paymentType.
  ///
  /// In en, this message translates to:
  /// **'Payment type'**
  String get paymentType;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @credit.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get credit;

  /// No description provided for @paid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paid;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @change.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get change;

  /// No description provided for @amountPaid.
  ///
  /// In en, this message translates to:
  /// **'Amount paid'**
  String get amountPaid;

  /// No description provided for @saleTotal.
  ///
  /// In en, this message translates to:
  /// **'Sale Total'**
  String get saleTotal;

  /// No description provided for @selectCustomerHint.
  ///
  /// In en, this message translates to:
  /// **'Select customer…'**
  String get selectCustomerHint;

  /// No description provided for @customerRequiredForCredit.
  ///
  /// In en, this message translates to:
  /// **'A customer is required for credit sales.'**
  String get customerRequiredForCredit;

  /// No description provided for @fullAmountAsDebt.
  ///
  /// In en, this message translates to:
  /// **'Full amount will be recorded as debt.'**
  String get fullAmountAsDebt;

  /// No description provided for @partialPaymentNote.
  ///
  /// In en, this message translates to:
  /// **'Shortfall will be recorded as a debt for this customer.'**
  String get partialPaymentNote;

  /// No description provided for @checkout.
  ///
  /// In en, this message translates to:
  /// **'Checkout'**
  String get checkout;

  /// No description provided for @proceedToPayment.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Payment'**
  String get proceedToPayment;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @noSalesFound.
  ///
  /// In en, this message translates to:
  /// **'No sales found'**
  String get noSalesFound;

  /// No description provided for @saleRef.
  ///
  /// In en, this message translates to:
  /// **'Sale #{ref}'**
  String saleRef(String ref);

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 item} other{{count} items}}'**
  String itemCount(int count);

  /// No description provided for @saleRecorded.
  ///
  /// In en, this message translates to:
  /// **'Sale Recorded'**
  String get saleRecorded;

  /// No description provided for @paymentSuccessful.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful!'**
  String get paymentSuccessful;

  /// No description provided for @receipt.
  ///
  /// In en, this message translates to:
  /// **'Receipt'**
  String get receipt;

  /// No description provided for @shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get shareReceipt;

  /// No description provided for @pdfReceipt.
  ///
  /// In en, this message translates to:
  /// **'PDF Receipt'**
  String get pdfReceipt;

  /// No description provided for @owedCredit.
  ///
  /// In en, this message translates to:
  /// **'Owed (credit)'**
  String get owedCredit;

  /// No description provided for @noSalesYet.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded yet today'**
  String get noSalesYet;

  /// No description provided for @transactionsWillAppear.
  ///
  /// In en, this message translates to:
  /// **'Your transactions will appear here'**
  String get transactionsWillAppear;

  /// No description provided for @startRecordingSale.
  ///
  /// In en, this message translates to:
  /// **'Tap to start recording a sale'**
  String get startRecordingSale;

  /// No description provided for @todayTransactions.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Transactions'**
  String get todayTransactions;

  /// No description provided for @cashSale.
  ///
  /// In en, this message translates to:
  /// **'Cash sale'**
  String get cashSale;

  /// No description provided for @creditSale.
  ///
  /// In en, this message translates to:
  /// **'Credit sale'**
  String get creditSale;

  /// No description provided for @noProductsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No products in this category'**
  String get noProductsInCategory;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get totalRevenue;

  /// No description provided for @owed.
  ///
  /// In en, this message translates to:
  /// **'Owed'**
  String get owed;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @addCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get addCustomer;

  /// No description provided for @totalOutstandingDebt.
  ///
  /// In en, this message translates to:
  /// **'Total Outstanding Debt'**
  String get totalOutstandingDebt;

  /// No description provided for @recordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// No description provided for @amount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// No description provided for @transactionHistory.
  ///
  /// In en, this message translates to:
  /// **'Transaction History'**
  String get transactionHistory;

  /// No description provided for @saveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get saveCustomer;

  /// No description provided for @noCustomersFound.
  ///
  /// In en, this message translates to:
  /// **'No customers found'**
  String get noCustomersFound;

  /// No description provided for @searchByNameOrPhone.
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone…'**
  String get searchByNameOrPhone;

  /// No description provided for @debtLabel.
  ///
  /// In en, this message translates to:
  /// **'Debt:'**
  String get debtLabel;

  /// No description provided for @outstandingDebt.
  ///
  /// In en, this message translates to:
  /// **'Outstanding Debt'**
  String get outstandingDebt;

  /// No description provided for @debtRecords.
  ///
  /// In en, this message translates to:
  /// **'Debt Records'**
  String get debtRecords;

  /// No description provided for @noTransactionsYet.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet'**
  String get noTransactionsYet;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @phoneOptional.
  ///
  /// In en, this message translates to:
  /// **'Phone (optional)'**
  String get phoneOptional;

  /// No description provided for @newCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get newCustomer;

  /// No description provided for @saveAndSelect.
  ///
  /// In en, this message translates to:
  /// **'Save & Select'**
  String get saveAndSelect;

  /// No description provided for @selectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get selectCustomer;

  /// No description provided for @walkInCustomer.
  ///
  /// In en, this message translates to:
  /// **'Walk-in Customer'**
  String get walkInCustomer;

  /// No description provided for @newButton.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newButton;

  /// No description provided for @createNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create new customer'**
  String get createNewCustomer;

  /// No description provided for @creditRecord.
  ///
  /// In en, this message translates to:
  /// **'Credit'**
  String get creditRecord;

  /// No description provided for @paymentRecord.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentRecord;

  /// No description provided for @balance.
  ///
  /// In en, this message translates to:
  /// **'Balance:'**
  String get balance;

  /// No description provided for @withDebt.
  ///
  /// In en, this message translates to:
  /// **'With Debt'**
  String get withDebt;

  /// No description provided for @addStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get addStaffMember;

  /// No description provided for @createStaffAccount.
  ///
  /// In en, this message translates to:
  /// **'Create Staff Account'**
  String get createStaffAccount;

  /// No description provided for @staffCreatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Staff account created successfully'**
  String get staffCreatedSuccessfully;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @manageStaff.
  ///
  /// In en, this message translates to:
  /// **'Manage Staff'**
  String get manageStaff;

  /// No description provided for @activateOrDeactivateTeam.
  ///
  /// In en, this message translates to:
  /// **'Activate or deactivate team members'**
  String get activateOrDeactivateTeam;

  /// No description provided for @noStaffYet.
  ///
  /// In en, this message translates to:
  /// **'No staff members yet'**
  String get noStaffYet;

  /// No description provided for @addStaffFromProfile.
  ///
  /// In en, this message translates to:
  /// **'Add staff from your profile screen.'**
  String get addStaffFromProfile;

  /// No description provided for @couldNotLoadStaff.
  ///
  /// In en, this message translates to:
  /// **'Could not load staff'**
  String get couldNotLoadStaff;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @accountDetails.
  ///
  /// In en, this message translates to:
  /// **'Account details'**
  String get accountDetails;

  /// No description provided for @newStaffAccount.
  ///
  /// In en, this message translates to:
  /// **'New Staff Account'**
  String get newStaffAccount;

  /// No description provided for @fillInStaffDetails.
  ///
  /// In en, this message translates to:
  /// **'Fill in the details below to create login credentials for your staff member.'**
  String get fillInStaffDetails;

  /// No description provided for @phoneAsPassword.
  ///
  /// In en, this message translates to:
  /// **'The phone number serves as this staff member\'s password. Share their email and phone number so they can log in to ShopKeeper.'**
  String get phoneAsPassword;

  /// No description provided for @salesToday.
  ///
  /// In en, this message translates to:
  /// **'Sales today'**
  String get salesToday;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @priceList.
  ///
  /// In en, this message translates to:
  /// **'Price List'**
  String get priceList;

  /// No description provided for @viewAllProducts.
  ///
  /// In en, this message translates to:
  /// **'View all products and prices'**
  String get viewAllProducts;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @availableLabel.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get availableLabel;

  /// No description provided for @failedCreateStaff.
  ///
  /// In en, this message translates to:
  /// **'Failed to create staff'**
  String get failedCreateStaff;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @noNotifications.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get noNotifications;

  /// No description provided for @allCaughtUp.
  ///
  /// In en, this message translates to:
  /// **'All caught up'**
  String get allCaughtUp;

  /// No description provided for @allCaughtUpPeriod.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up.'**
  String get allCaughtUpPeriod;

  /// No description provided for @tapToDismiss.
  ///
  /// In en, this message translates to:
  /// **'Tap to dismiss'**
  String get tapToDismiss;

  /// No description provided for @unreadCount.
  ///
  /// In en, this message translates to:
  /// **'{count} unread'**
  String unreadCount(int count);

  /// No description provided for @customizeExperience.
  ///
  /// In en, this message translates to:
  /// **'Customize your experience'**
  String get customizeExperience;

  /// No description provided for @languageSetting.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSetting;

  /// No description provided for @appDisplayLanguage.
  ///
  /// In en, this message translates to:
  /// **'App display language'**
  String get appDisplayLanguage;

  /// No description provided for @displayLanguage.
  ///
  /// In en, this message translates to:
  /// **'Display language'**
  String get displayLanguage;

  /// No description provided for @alertPreferences.
  ///
  /// In en, this message translates to:
  /// **'Alert Preferences'**
  String get alertPreferences;

  /// No description provided for @chooseAlerts.
  ///
  /// In en, this message translates to:
  /// **'Choose which events notify you'**
  String get chooseAlerts;

  /// No description provided for @lowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low stock alerts'**
  String get lowStockAlerts;

  /// No description provided for @notifyWhenLowStock.
  ///
  /// In en, this message translates to:
  /// **'Notify when a product runs low'**
  String get notifyWhenLowStock;

  /// No description provided for @largeSaleAlerts.
  ///
  /// In en, this message translates to:
  /// **'Large sale alerts'**
  String get largeSaleAlerts;

  /// No description provided for @notifyHighValue.
  ///
  /// In en, this message translates to:
  /// **'Notify on high-value transactions'**
  String get notifyHighValue;

  /// No description provided for @debtPaymentAlerts.
  ///
  /// In en, this message translates to:
  /// **'Debt payment alerts'**
  String get debtPaymentAlerts;

  /// No description provided for @notifyCustomerPays.
  ///
  /// In en, this message translates to:
  /// **'Notify when a customer pays'**
  String get notifyCustomerPays;

  /// No description provided for @staffLoginAlerts.
  ///
  /// In en, this message translates to:
  /// **'Staff login alerts'**
  String get staffLoginAlerts;

  /// No description provided for @notifyStaffSignIn.
  ///
  /// In en, this message translates to:
  /// **'Notify when staff signs in'**
  String get notifyStaffSignIn;

  /// No description provided for @largeSaleThresholdLabel.
  ///
  /// In en, this message translates to:
  /// **'Large sale threshold'**
  String get largeSaleThresholdLabel;

  /// No description provided for @salesAboveThisAmount.
  ///
  /// In en, this message translates to:
  /// **'Sales above this amount trigger an alert'**
  String get salesAboveThisAmount;

  /// No description provided for @largeSaleThresholdTitle.
  ///
  /// In en, this message translates to:
  /// **'Large Sale Threshold'**
  String get largeSaleThresholdTitle;

  /// No description provided for @youWillBeAlerted.
  ///
  /// In en, this message translates to:
  /// **'You\'ll be alerted when a single sale exceeds this'**
  String get youWillBeAlerted;

  /// No description provided for @currentThreshold.
  ///
  /// In en, this message translates to:
  /// **'Current threshold'**
  String get currentThreshold;

  /// No description provided for @quickSelect.
  ///
  /// In en, this message translates to:
  /// **'Quick select'**
  String get quickSelect;

  /// No description provided for @customAmount.
  ///
  /// In en, this message translates to:
  /// **'Custom amount'**
  String get customAmount;

  /// No description provided for @pushNotifications.
  ///
  /// In en, this message translates to:
  /// **'Push notifications'**
  String get pushNotifications;

  /// No description provided for @pushNotifDescription.
  ///
  /// In en, this message translates to:
  /// **'You receive instant push alerts when the owner adds, updates, or removes products. These are managed by your device.'**
  String get pushNotifDescription;

  /// No description provided for @newProductsAdded.
  ///
  /// In en, this message translates to:
  /// **'New products added'**
  String get newProductsAdded;

  /// No description provided for @priceStockUpdates.
  ///
  /// In en, this message translates to:
  /// **'Price / stock updates'**
  String get priceStockUpdates;

  /// No description provided for @productsRemoved.
  ///
  /// In en, this message translates to:
  /// **'Products removed'**
  String get productsRemoved;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact Support'**
  String get contactSupport;

  /// No description provided for @getHelpOrReport.
  ///
  /// In en, this message translates to:
  /// **'Get help or report an issue'**
  String get getHelpOrReport;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// No description provided for @howWeHandleData.
  ///
  /// In en, this message translates to:
  /// **'How we handle your data'**
  String get howWeHandleData;

  /// No description provided for @termsOfService.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;

  /// No description provided for @usageTerms.
  ///
  /// In en, this message translates to:
  /// **'Usage terms and conditions'**
  String get usageTerms;

  /// No description provided for @languageAutoDetected.
  ///
  /// In en, this message translates to:
  /// **'Automatically detected from your device'**
  String get languageAutoDetected;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @onboarding1Title.
  ///
  /// In en, this message translates to:
  /// **'Welcome to ShopKeeper'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Description.
  ///
  /// In en, this message translates to:
  /// **'Your complete shop management solution — built for businesses like yours.'**
  String get onboarding1Description;

  /// No description provided for @onboarding2Title.
  ///
  /// In en, this message translates to:
  /// **'Smart Inventory'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Description.
  ///
  /// In en, this message translates to:
  /// **'Always know what you have. Never run out of what matters.'**
  String get onboarding2Description;

  /// No description provided for @onboarding3Title.
  ///
  /// In en, this message translates to:
  /// **'Record Sales Fast'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Description.
  ///
  /// In en, this message translates to:
  /// **'Log cash and credit sales in seconds. Daily totals update automatically.'**
  String get onboarding3Description;

  /// No description provided for @onboarding4Title.
  ///
  /// In en, this message translates to:
  /// **'Manage Customer Debts'**
  String get onboarding4Title;

  /// No description provided for @onboarding4Description.
  ///
  /// In en, this message translates to:
  /// **'Track who owes what, flag risky accounts, and record payments on the spot.'**
  String get onboarding4Description;

  /// No description provided for @onboarding5Title.
  ///
  /// In en, this message translates to:
  /// **'AI-Powered Insights'**
  String get onboarding5Title;

  /// No description provided for @onboarding5Description.
  ///
  /// In en, this message translates to:
  /// **'Ask your AI assistant anything. Get weekly reports and smart recommendations.'**
  String get onboarding5Description;

  /// No description provided for @onboardingFeatureLiveStock.
  ///
  /// In en, this message translates to:
  /// **'Live stock levels'**
  String get onboardingFeatureLiveStock;

  /// No description provided for @onboardingFeatureLowStockAlerts.
  ///
  /// In en, this message translates to:
  /// **'Low-stock alerts'**
  String get onboardingFeatureLowStockAlerts;

  /// No description provided for @onboardingFeatureRisk.
  ///
  /// In en, this message translates to:
  /// **'Risk categorisation'**
  String get onboardingFeatureRisk;

  /// No description provided for @onboardingFeatureQuickSale.
  ///
  /// In en, this message translates to:
  /// **'Quick sale entry'**
  String get onboardingFeatureQuickSale;

  /// No description provided for @onboardingFeatureHistory.
  ///
  /// In en, this message translates to:
  /// **'Full transaction history'**
  String get onboardingFeatureHistory;

  /// No description provided for @onboardingFeatureReports.
  ///
  /// In en, this message translates to:
  /// **'Daily & weekly reports'**
  String get onboardingFeatureReports;

  /// No description provided for @onboardingFeatureProfiles.
  ///
  /// In en, this message translates to:
  /// **'Customer profiles'**
  String get onboardingFeatureProfiles;

  /// No description provided for @onboardingFeatureRiskScoring.
  ///
  /// In en, this message translates to:
  /// **'Risk scoring'**
  String get onboardingFeatureRiskScoring;

  /// No description provided for @onboardingFeaturePaymentTracking.
  ///
  /// In en, this message translates to:
  /// **'Payment tracking'**
  String get onboardingFeaturePaymentTracking;

  /// No description provided for @onboardingFeatureWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly summaries'**
  String get onboardingFeatureWeekly;

  /// No description provided for @onboardingFeatureAnomaly.
  ///
  /// In en, this message translates to:
  /// **'Anomaly detection'**
  String get onboardingFeatureAnomaly;

  /// No description provided for @onboardingFeatureChat.
  ///
  /// In en, this message translates to:
  /// **'Natural language chat'**
  String get onboardingFeatureChat;

  /// No description provided for @shopkeeperAI.
  ///
  /// In en, this message translates to:
  /// **'ShopKeeper AI'**
  String get shopkeeperAI;

  /// No description provided for @poweredByGroq.
  ///
  /// In en, this message translates to:
  /// **'Powered by Groq'**
  String get poweredByGroq;

  /// No description provided for @clearChat.
  ///
  /// In en, this message translates to:
  /// **'Clear chat'**
  String get clearChat;

  /// No description provided for @startNewChat.
  ///
  /// In en, this message translates to:
  /// **'Start new chat'**
  String get startNewChat;

  /// No description provided for @deleteConversation.
  ///
  /// In en, this message translates to:
  /// **'This will delete your entire conversation history.'**
  String get deleteConversation;

  /// No description provided for @howCanIHelp.
  ///
  /// In en, this message translates to:
  /// **'How can I help you today?'**
  String get howCanIHelp;

  /// No description provided for @askAboutSales.
  ///
  /// In en, this message translates to:
  /// **'Ask me about sales, inventory, or\nbusiness insights for your shop.'**
  String get askAboutSales;

  /// No description provided for @suggested.
  ///
  /// In en, this message translates to:
  /// **'SUGGESTED'**
  String get suggested;

  /// No description provided for @askAnything.
  ///
  /// In en, this message translates to:
  /// **'Ask anything about your shop…'**
  String get askAnything;

  /// No description provided for @aiSuggestion1.
  ///
  /// In en, this message translates to:
  /// **'Today\'s sales summary'**
  String get aiSuggestion1;

  /// No description provided for @aiSuggestion2.
  ///
  /// In en, this message translates to:
  /// **'What needs restocking?'**
  String get aiSuggestion2;

  /// No description provided for @aiSuggestion3.
  ///
  /// In en, this message translates to:
  /// **'Top products this week'**
  String get aiSuggestion3;

  /// No description provided for @aiSuggestion4.
  ///
  /// In en, this message translates to:
  /// **'Give me business insights'**
  String get aiSuggestion4;

  /// No description provided for @weAreHereToHelp.
  ///
  /// In en, this message translates to:
  /// **'We\'re here to help — reach out any time'**
  String get weAreHereToHelp;

  /// No description provided for @getInTouch.
  ///
  /// In en, this message translates to:
  /// **'Get in touch'**
  String get getInTouch;

  /// No description provided for @frequentlyAskedQuestions.
  ///
  /// In en, this message translates to:
  /// **'Frequently asked questions'**
  String get frequentlyAskedQuestions;

  /// No description provided for @emailSupport.
  ///
  /// In en, this message translates to:
  /// **'Email Support'**
  String get emailSupport;

  /// No description provided for @whatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get whatsApp;

  /// No description provided for @fastestBadge.
  ///
  /// In en, this message translates to:
  /// **'Fastest'**
  String get fastestBadge;

  /// No description provided for @reportABug.
  ///
  /// In en, this message translates to:
  /// **'Report a Bug'**
  String get reportABug;

  /// No description provided for @helpUsImprove.
  ///
  /// In en, this message translates to:
  /// **'Help us improve the app'**
  String get helpUsImprove;

  /// No description provided for @averageResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Average response time'**
  String get averageResponseTime;

  /// No description provided for @responseTimeDetails.
  ///
  /// In en, this message translates to:
  /// **'Email: within 24 hours  ·  WhatsApp: within 2 hours'**
  String get responseTimeDetails;

  /// No description provided for @wellGetBackWithin24h.
  ///
  /// In en, this message translates to:
  /// **'We\'ll get back to you within 24 hours'**
  String get wellGetBackWithin24h;

  /// No description provided for @bugTitle.
  ///
  /// In en, this message translates to:
  /// **'Bug title'**
  String get bugTitle;

  /// No description provided for @bugTitleHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. App crashes when adding a product'**
  String get bugTitleHint;

  /// No description provided for @description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// No description provided for @bugDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Describe what happened and steps to reproduce it…'**
  String get bugDescriptionHint;

  /// No description provided for @sendReport.
  ///
  /// In en, this message translates to:
  /// **'Send Report'**
  String get sendReport;

  /// No description provided for @couldNotOpenEmail.
  ///
  /// In en, this message translates to:
  /// **'Could not open email app.'**
  String get couldNotOpenEmail;

  /// No description provided for @couldNotOpenWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Could not open WhatsApp.'**
  String get couldNotOpenWhatsApp;

  /// No description provided for @faq1Q.
  ///
  /// In en, this message translates to:
  /// **'How do I add a product with multiple units?'**
  String get faq1Q;

  /// No description provided for @faq1A.
  ///
  /// In en, this message translates to:
  /// **'Go to Products → Add Product. In the Units section, add each unit (e.g. carton, pack) with its price and quantity relative to the base unit. The unit with \"Qty in base = 1\" is your base unit — all stock is tracked in this unit.'**
  String get faq1A;

  /// No description provided for @faq2Q.
  ///
  /// In en, this message translates to:
  /// **'Why is a staff login notification not showing?'**
  String get faq2Q;

  /// No description provided for @faq2A.
  ///
  /// In en, this message translates to:
  /// **'Make sure \"Staff login alerts\" is enabled in Settings → Alert Preferences. Also ensure the staff member is assigned a Shop ID and that your FCM device token is registered.'**
  String get faq2A;

  /// No description provided for @faq3Q.
  ///
  /// In en, this message translates to:
  /// **'How is my stock calculated?'**
  String get faq3Q;

  /// No description provided for @faq3A.
  ///
  /// In en, this message translates to:
  /// **'Stock is always stored in base units. When you record a sale, the sold quantity (in the chosen unit) is multiplied by that unit\'s \"quantity in base\" and subtracted from stock. The dashboard shows how much is available in each unit.'**
  String get faq3A;

  /// No description provided for @faq4Q.
  ///
  /// In en, this message translates to:
  /// **'Can I change the large sale threshold?'**
  String get faq4Q;

  /// No description provided for @faq4A.
  ///
  /// In en, this message translates to:
  /// **'Yes — go to Settings → Alert Preferences and tap the \"Large sale threshold\" row. Enter the FCFA amount above which a sale should trigger an alert.'**
  String get faq4A;

  /// No description provided for @faq5Q.
  ///
  /// In en, this message translates to:
  /// **'How do I create a staff account?'**
  String get faq5Q;

  /// No description provided for @faq5A.
  ///
  /// In en, this message translates to:
  /// **'From your profile screen, tap \"Add Staff Member\". Fill in their name, email, and phone number. Their phone number is their login password.'**
  String get faq5A;

  /// No description provided for @lastUpdatedJune2026.
  ///
  /// In en, this message translates to:
  /// **'Last updated: June 2026'**
  String get lastUpdatedJune2026;

  /// No description provided for @privacyPolicyIntro.
  ///
  /// In en, this message translates to:
  /// **'ShopKeeper is committed to protecting your privacy. This policy explains what data we collect, how we use it, and your rights as a user.'**
  String get privacyPolicyIntro;

  /// No description provided for @privacySec1Title.
  ///
  /// In en, this message translates to:
  /// **'Information We Collect'**
  String get privacySec1Title;

  /// No description provided for @privacySec1B1.
  ///
  /// In en, this message translates to:
  /// **'Account information: name, email address, and role (owner or staff).'**
  String get privacySec1B1;

  /// No description provided for @privacySec1B2.
  ///
  /// In en, this message translates to:
  /// **'Shop data: product catalogue, sales records, customer debts, and stock levels.'**
  String get privacySec1B2;

  /// No description provided for @privacySec1B3.
  ///
  /// In en, this message translates to:
  /// **'Device information: FCM token for push notifications.'**
  String get privacySec1B3;

  /// No description provided for @privacySec1B4.
  ///
  /// In en, this message translates to:
  /// **'Usage data: app activity logs for debugging and service improvement.'**
  String get privacySec1B4;

  /// No description provided for @privacySec2Title.
  ///
  /// In en, this message translates to:
  /// **'How We Use Your Data'**
  String get privacySec2Title;

  /// No description provided for @privacySec2B1.
  ///
  /// In en, this message translates to:
  /// **'To authenticate you and secure your account.'**
  String get privacySec2B1;

  /// No description provided for @privacySec2B2.
  ///
  /// In en, this message translates to:
  /// **'To sync your shop data across sessions and devices.'**
  String get privacySec2B2;

  /// No description provided for @privacySec2B3.
  ///
  /// In en, this message translates to:
  /// **'To send push notifications relevant to your business (stock alerts, sales, debts).'**
  String get privacySec2B3;

  /// No description provided for @privacySec2B4.
  ///
  /// In en, this message translates to:
  /// **'To generate AI-powered business insights on request.'**
  String get privacySec2B4;

  /// No description provided for @privacySec2B5.
  ///
  /// In en, this message translates to:
  /// **'To improve the app and fix issues.'**
  String get privacySec2B5;

  /// No description provided for @privacySec3Title.
  ///
  /// In en, this message translates to:
  /// **'Data Storage & Security'**
  String get privacySec3Title;

  /// No description provided for @privacySec3B1.
  ///
  /// In en, this message translates to:
  /// **'Your data is stored on secured servers with encrypted connections (HTTPS).'**
  String get privacySec3B1;

  /// No description provided for @privacySec3B2.
  ///
  /// In en, this message translates to:
  /// **'Passwords are hashed using bcrypt — we never store them in plain text.'**
  String get privacySec3B2;

  /// No description provided for @privacySec3B3.
  ///
  /// In en, this message translates to:
  /// **'Auth tokens are stored in encrypted secure storage on your device.'**
  String get privacySec3B3;

  /// No description provided for @privacySec3B4.
  ///
  /// In en, this message translates to:
  /// **'We do not sell your data to third parties.'**
  String get privacySec3B4;

  /// No description provided for @privacySec4Title.
  ///
  /// In en, this message translates to:
  /// **'Third-Party Services'**
  String get privacySec4Title;

  /// No description provided for @privacySec4B1.
  ///
  /// In en, this message translates to:
  /// **'Firebase Cloud Messaging (FCM) — for push notifications. Google Privacy Policy applies.'**
  String get privacySec4B1;

  /// No description provided for @privacySec4B2.
  ///
  /// In en, this message translates to:
  /// **'MongoDB Atlas — for cloud data storage. MongoDB Privacy Policy applies.'**
  String get privacySec4B2;

  /// No description provided for @privacySec4B3.
  ///
  /// In en, this message translates to:
  /// **'We do not use advertising networks or analytics platforms.'**
  String get privacySec4B3;

  /// No description provided for @privacySec5Title.
  ///
  /// In en, this message translates to:
  /// **'Your Rights'**
  String get privacySec5Title;

  /// No description provided for @privacySec5B1.
  ///
  /// In en, this message translates to:
  /// **'Access: you may request a copy of your stored data at any time.'**
  String get privacySec5B1;

  /// No description provided for @privacySec5B2.
  ///
  /// In en, this message translates to:
  /// **'Correction: you may update your account details in the app.'**
  String get privacySec5B2;

  /// No description provided for @privacySec5B3.
  ///
  /// In en, this message translates to:
  /// **'Deletion: you may request account and data deletion by contacting support.'**
  String get privacySec5B3;

  /// No description provided for @privacySec5B4.
  ///
  /// In en, this message translates to:
  /// **'Portability: your sales and inventory data can be exported on request.'**
  String get privacySec5B4;

  /// No description provided for @privacySec6Title.
  ///
  /// In en, this message translates to:
  /// **'Data Retention'**
  String get privacySec6Title;

  /// No description provided for @privacySec6B1.
  ///
  /// In en, this message translates to:
  /// **'Active account data is retained for as long as your account exists.'**
  String get privacySec6B1;

  /// No description provided for @privacySec6B2.
  ///
  /// In en, this message translates to:
  /// **'After account deletion, data is purged within 30 days.'**
  String get privacySec6B2;

  /// No description provided for @privacySec6B3.
  ///
  /// In en, this message translates to:
  /// **'Anonymised aggregate data may be retained for service analytics.'**
  String get privacySec6B3;

  /// No description provided for @privacySec7Title.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get privacySec7Title;

  /// No description provided for @privacySec7B1.
  ///
  /// In en, this message translates to:
  /// **'For privacy-related questions or requests, contact us at:'**
  String get privacySec7B1;

  /// No description provided for @privacySec7B2.
  ///
  /// In en, this message translates to:
  /// **'privacy@shopkeeper.cm'**
  String get privacySec7B2;

  /// No description provided for @privacySec7B3.
  ///
  /// In en, this message translates to:
  /// **'We respond within 5 business days.'**
  String get privacySec7B3;

  /// No description provided for @termsOfServiceIntro.
  ///
  /// In en, this message translates to:
  /// **'By using ShopKeeper, you agree to these terms. Please read them carefully. If you do not agree, please stop using the app.'**
  String get termsOfServiceIntro;

  /// No description provided for @termsSec1Title.
  ///
  /// In en, this message translates to:
  /// **'Acceptance of Terms'**
  String get termsSec1Title;

  /// No description provided for @termsSec1B1.
  ///
  /// In en, this message translates to:
  /// **'By creating an account or using ShopKeeper, you confirm that you are at least 18 years old.'**
  String get termsSec1B1;

  /// No description provided for @termsSec1B2.
  ///
  /// In en, this message translates to:
  /// **'You agree to use the app only for legitimate business management purposes.'**
  String get termsSec1B2;

  /// No description provided for @termsSec1B3.
  ///
  /// In en, this message translates to:
  /// **'These terms may be updated periodically. Continued use constitutes acceptance.'**
  String get termsSec1B3;

  /// No description provided for @termsSec2Title.
  ///
  /// In en, this message translates to:
  /// **'Account Responsibilities'**
  String get termsSec2Title;

  /// No description provided for @termsSec2B1.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for maintaining the confidentiality of your login credentials.'**
  String get termsSec2B1;

  /// No description provided for @termsSec2B2.
  ///
  /// In en, this message translates to:
  /// **'You must not share your owner account with unauthorised individuals.'**
  String get termsSec2B2;

  /// No description provided for @termsSec2B3.
  ///
  /// In en, this message translates to:
  /// **'You are responsible for all activity that occurs under your account.'**
  String get termsSec2B3;

  /// No description provided for @termsSec2B4.
  ///
  /// In en, this message translates to:
  /// **'Report any suspected unauthorised access to support immediately.'**
  String get termsSec2B4;

  /// No description provided for @termsSec3Title.
  ///
  /// In en, this message translates to:
  /// **'Permitted Use'**
  String get termsSec3Title;

  /// No description provided for @termsSec3B1.
  ///
  /// In en, this message translates to:
  /// **'ShopKeeper may only be used for legitimate shop and inventory management.'**
  String get termsSec3B1;

  /// No description provided for @termsSec3B2.
  ///
  /// In en, this message translates to:
  /// **'You must not use the app to record fraudulent transactions or falsify records.'**
  String get termsSec3B2;

  /// No description provided for @termsSec3B3.
  ///
  /// In en, this message translates to:
  /// **'You must not attempt to reverse-engineer, hack, or abuse the service.'**
  String get termsSec3B3;

  /// No description provided for @termsSec3B4.
  ///
  /// In en, this message translates to:
  /// **'Automated access (bots, scrapers) is strictly prohibited.'**
  String get termsSec3B4;

  /// No description provided for @termsSec4Title.
  ///
  /// In en, this message translates to:
  /// **'Data & Content Ownership'**
  String get termsSec4Title;

  /// No description provided for @termsSec4B1.
  ///
  /// In en, this message translates to:
  /// **'You retain full ownership of all business data you enter into ShopKeeper.'**
  String get termsSec4B1;

  /// No description provided for @termsSec4B2.
  ///
  /// In en, this message translates to:
  /// **'By using the service, you grant us a limited licence to store and process your data solely to provide the service.'**
  String get termsSec4B2;

  /// No description provided for @termsSec4B3.
  ///
  /// In en, this message translates to:
  /// **'We do not claim ownership of your product catalogue, sales records, or customer data.'**
  String get termsSec4B3;

  /// No description provided for @termsSec5Title.
  ///
  /// In en, this message translates to:
  /// **'Service Availability'**
  String get termsSec5Title;

  /// No description provided for @termsSec5B1.
  ///
  /// In en, this message translates to:
  /// **'We aim for high availability but do not guarantee uninterrupted service.'**
  String get termsSec5B1;

  /// No description provided for @termsSec5B2.
  ///
  /// In en, this message translates to:
  /// **'Scheduled maintenance will be communicated in advance where possible.'**
  String get termsSec5B2;

  /// No description provided for @termsSec5B3.
  ///
  /// In en, this message translates to:
  /// **'We are not liable for losses caused by service interruptions beyond our control.'**
  String get termsSec5B3;

  /// No description provided for @termsSec6Title.
  ///
  /// In en, this message translates to:
  /// **'Limitation of Liability'**
  String get termsSec6Title;

  /// No description provided for @termsSec6B1.
  ///
  /// In en, this message translates to:
  /// **'ShopKeeper is provided \"as is\" without warranties of any kind.'**
  String get termsSec6B1;

  /// No description provided for @termsSec6B2.
  ///
  /// In en, this message translates to:
  /// **'We are not liable for business decisions made based on data in the app.'**
  String get termsSec6B2;

  /// No description provided for @termsSec6B3.
  ///
  /// In en, this message translates to:
  /// **'Our total liability for any claim shall not exceed the amount you paid for the service in the preceding 3 months.'**
  String get termsSec6B3;

  /// No description provided for @termsSec7Title.
  ///
  /// In en, this message translates to:
  /// **'Termination'**
  String get termsSec7Title;

  /// No description provided for @termsSec7B1.
  ///
  /// In en, this message translates to:
  /// **'You may stop using ShopKeeper and request account deletion at any time.'**
  String get termsSec7B1;

  /// No description provided for @termsSec7B2.
  ///
  /// In en, this message translates to:
  /// **'We reserve the right to suspend or terminate accounts that violate these terms.'**
  String get termsSec7B2;

  /// No description provided for @termsSec7B3.
  ///
  /// In en, this message translates to:
  /// **'Upon termination, your data will be deleted within 30 days per our Privacy Policy.'**
  String get termsSec7B3;

  /// No description provided for @termsSec8Title.
  ///
  /// In en, this message translates to:
  /// **'Governing Law'**
  String get termsSec8Title;

  /// No description provided for @termsSec8B1.
  ///
  /// In en, this message translates to:
  /// **'These terms are governed by the laws of the Republic of Cameroon.'**
  String get termsSec8B1;

  /// No description provided for @termsSec8B2.
  ///
  /// In en, this message translates to:
  /// **'Any disputes shall be resolved through good-faith negotiation first.'**
  String get termsSec8B2;

  /// No description provided for @termsSec8B3.
  ///
  /// In en, this message translates to:
  /// **'For questions, contact us at: legal@shopkeeper.cm'**
  String get termsSec8B3;

  /// No description provided for @myProfile.
  ///
  /// In en, this message translates to:
  /// **'My Profile'**
  String get myProfile;

  /// No description provided for @shopNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopNameLabel;

  /// No description provided for @ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner name'**
  String get ownerName;

  /// No description provided for @shopDescription.
  ///
  /// In en, this message translates to:
  /// **'Shop description'**
  String get shopDescription;

  /// No description provided for @statusLabel.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get statusLabel;

  /// No description provided for @roleLabel.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get roleLabel;

  /// No description provided for @shopLabel.
  ///
  /// In en, this message translates to:
  /// **'Shop'**
  String get shopLabel;

  /// No description provided for @verified.
  ///
  /// In en, this message translates to:
  /// **'Verified'**
  String get verified;

  /// No description provided for @assigned.
  ///
  /// In en, this message translates to:
  /// **'Assigned'**
  String get assigned;

  /// No description provided for @unassigned.
  ///
  /// In en, this message translates to:
  /// **'Unassigned'**
  String get unassigned;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// No description provided for @signOutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get signOutQuestion;

  /// No description provided for @signOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Sign out of your ShopKeeper account'**
  String get signOutDescription;

  /// No description provided for @ownerSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will need to log back in to access your account.'**
  String get ownerSignOutSubtitle;

  /// No description provided for @staffSignOutSubtitle.
  ///
  /// In en, this message translates to:
  /// **'You will need your email and phone number to log back in.'**
  String get staffSignOutSubtitle;

  /// No description provided for @staffName.
  ///
  /// In en, this message translates to:
  /// **'Staff name'**
  String get staffName;

  /// No description provided for @actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get actions;

  /// No description provided for @createLoginCredentialsForNewStaff.
  ///
  /// In en, this message translates to:
  /// **'Create login credentials for new staff'**
  String get createLoginCredentialsForNewStaff;

  /// No description provided for @managePreferencesAndSecurity.
  ///
  /// In en, this message translates to:
  /// **'Manage preferences and security'**
  String get managePreferencesAndSecurity;

  /// No description provided for @manageAppPreferences.
  ///
  /// In en, this message translates to:
  /// **'Manage app preferences'**
  String get manageAppPreferences;

  /// No description provided for @editShopDetails.
  ///
  /// In en, this message translates to:
  /// **'Edit Shop Details'**
  String get editShopDetails;

  /// No description provided for @editShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Update shop name and description'**
  String get editShopSubtitle;

  /// No description provided for @editShop.
  ///
  /// In en, this message translates to:
  /// **'Edit Shop'**
  String get editShop;

  /// No description provided for @shopUpdatedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Shop updated successfully'**
  String get shopUpdatedSuccessfully;

  /// No description provided for @createNewShop.
  ///
  /// In en, this message translates to:
  /// **'Create New Shop'**
  String get createNewShop;

  /// No description provided for @createNewShopSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Register an additional shop for your account'**
  String get createNewShopSubtitle;

  /// No description provided for @hintExShopDescription.
  ///
  /// In en, this message translates to:
  /// **'e.g. Your everyday essentials store'**
  String get hintExShopDescription;

  /// No description provided for @yourShops.
  ///
  /// In en, this message translates to:
  /// **'Your Shops'**
  String get yourShops;

  /// No description provided for @switchShop.
  ///
  /// In en, this message translates to:
  /// **'Switch'**
  String get switchShop;

  /// No description provided for @switchedToShop.
  ///
  /// In en, this message translates to:
  /// **'Switched to {name}'**
  String switchedToShop(String name);

  /// No description provided for @switchingToShop.
  ///
  /// In en, this message translates to:
  /// **'Switching to {name}'**
  String switchingToShop(String name);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
