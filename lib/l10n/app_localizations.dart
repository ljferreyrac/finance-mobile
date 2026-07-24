import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

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
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Finanzas IA'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track your expenses with intelligence'**
  String get loginSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In en, this message translates to:
  /// **'you@email.com'**
  String get emailHint;

  /// No description provided for @emailRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email'**
  String get emailInvalid;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordRequired;

  /// No description provided for @passwordRequiredRegister.
  ///
  /// In en, this message translates to:
  /// **'Enter a password'**
  String get passwordRequiredRegister;

  /// No description provided for @passwordTooShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 10 characters'**
  String get passwordTooShort;

  /// No description provided for @passwordHelperText.
  ///
  /// In en, this message translates to:
  /// **'Minimum 10 characters'**
  String get passwordHelperText;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide password'**
  String get hidePassword;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get forgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginButton;

  /// No description provided for @noAccount.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// No description provided for @registerLink.
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get registerLink;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @fullNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Full name'**
  String get fullNameLabel;

  /// No description provided for @fullNameHint.
  ///
  /// In en, this message translates to:
  /// **'Maria Garcia'**
  String get fullNameHint;

  /// No description provided for @fullNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get fullNameRequired;

  /// No description provided for @fullNameTooShort.
  ///
  /// In en, this message translates to:
  /// **'Name must be at least 2 characters'**
  String get fullNameTooShort;

  /// No description provided for @confirmPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Confirm password'**
  String get confirmPasswordLabel;

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsNoMatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsNoMatch;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// No description provided for @loginLink.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginLink;

  /// No description provided for @incorrectCredentials.
  ///
  /// In en, this message translates to:
  /// **'Incorrect email or password'**
  String get incorrectCredentials;

  /// No description provided for @mainCurrencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Main currency'**
  String get mainCurrencyLabel;

  /// No description provided for @solesCurrency.
  ///
  /// In en, this message translates to:
  /// **'Soles (S/)'**
  String get solesCurrency;

  /// No description provided for @dollarsCurrency.
  ///
  /// In en, this message translates to:
  /// **'Dollars (\$)'**
  String get dollarsCurrency;

  /// No description provided for @backTooltip.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get backTooltip;

  /// No description provided for @navTransactions.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get navTransactions;

  /// No description provided for @navAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get navAccounts;

  /// No description provided for @navReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get navReports;

  /// No description provided for @navMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get navMore;

  /// No description provided for @accountsTitle.
  ///
  /// In en, this message translates to:
  /// **'My Accounts'**
  String get accountsTitle;

  /// No description provided for @newAccount.
  ///
  /// In en, this message translates to:
  /// **'New account'**
  String get newAccount;

  /// No description provided for @editAccount.
  ///
  /// In en, this message translates to:
  /// **'Edit account'**
  String get editAccount;

  /// No description provided for @accountTypeLabel.
  ///
  /// In en, this message translates to:
  /// **'Account type'**
  String get accountTypeLabel;

  /// No description provided for @accountTypeBankLabel.
  ///
  /// In en, this message translates to:
  /// **'Bank account'**
  String get accountTypeBankLabel;

  /// No description provided for @accountTypeCreditCardLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit card'**
  String get accountTypeCreditCardLabel;

  /// No description provided for @accountTypeCashLabel.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get accountTypeCashLabel;

  /// No description provided for @accountTypeWalletLabel.
  ///
  /// In en, this message translates to:
  /// **'Digital wallet'**
  String get accountTypeWalletLabel;

  /// No description provided for @accountNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get accountNameLabel;

  /// No description provided for @accountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chase Checking'**
  String get accountNameHint;

  /// No description provided for @accountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter a name'**
  String get accountNameRequired;

  /// No description provided for @linkedBankAccount.
  ///
  /// In en, this message translates to:
  /// **'Linked bank account'**
  String get linkedBankAccount;

  /// No description provided for @linkedBankAccountHelper.
  ///
  /// In en, this message translates to:
  /// **'Wallet expenses will deduct from this account'**
  String get linkedBankAccountHelper;

  /// No description provided for @noLinkedAccount.
  ///
  /// In en, this message translates to:
  /// **'No linked account'**
  String get noLinkedAccount;

  /// No description provided for @currencyLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyLabel;

  /// No description provided for @initialBalanceLabel.
  ///
  /// In en, this message translates to:
  /// **'Initial balance'**
  String get initialBalanceLabel;

  /// No description provided for @colorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get colorLabel;

  /// No description provided for @changeColor.
  ///
  /// In en, this message translates to:
  /// **'Change color'**
  String get changeColor;

  /// No description provided for @chooseColor.
  ///
  /// In en, this message translates to:
  /// **'Choose color'**
  String get chooseColor;

  /// No description provided for @creditLimitLabel.
  ///
  /// In en, this message translates to:
  /// **'Credit limit'**
  String get creditLimitLabel;

  /// No description provided for @closingDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Closing day'**
  String get closingDayLabel;

  /// No description provided for @dueDayLabel.
  ///
  /// In en, this message translates to:
  /// **'Due day'**
  String get dueDayLabel;

  /// No description provided for @dayHint.
  ///
  /// In en, this message translates to:
  /// **'1-31'**
  String get dayHint;

  /// No description provided for @dayInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid day'**
  String get dayInvalid;

  /// No description provided for @isDefaultAccount.
  ///
  /// In en, this message translates to:
  /// **'Default account'**
  String get isDefaultAccount;

  /// No description provided for @isDefaultAccountSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Will be used by default in new transactions'**
  String get isDefaultAccountSubtitle;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete account'**
  String get deleteAccount;

  /// No description provided for @deleteAccountConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This action cannot be undone.'**
  String deleteAccountConfirm(String name);

  /// No description provided for @accountInUse.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has {count} transaction(s). Reassign or delete those transactions before deleting the account.'**
  String accountInUse(String name, int count);

  /// No description provided for @netWorthTitle.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get netWorthTitle;

  /// No description provided for @emptyAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts yet. Add one to get started.'**
  String get emptyAccounts;

  /// No description provided for @defaultLabel.
  ///
  /// In en, this message translates to:
  /// **'Default'**
  String get defaultLabel;

  /// No description provided for @balanceInAccount.
  ///
  /// In en, this message translates to:
  /// **'Balance in account'**
  String get balanceInAccount;

  /// No description provided for @transactionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsTitle;

  /// No description provided for @newTransaction.
  ///
  /// In en, this message translates to:
  /// **'New transaction'**
  String get newTransaction;

  /// No description provided for @editTransaction.
  ///
  /// In en, this message translates to:
  /// **'Edit transaction'**
  String get editTransaction;

  /// No description provided for @saveTransaction.
  ///
  /// In en, this message translates to:
  /// **'Save transaction'**
  String get saveTransaction;

  /// No description provided for @deleteTransaction.
  ///
  /// In en, this message translates to:
  /// **'Delete transaction'**
  String get deleteTransaction;

  /// No description provided for @deleteTransactionConfirm.
  ///
  /// In en, this message translates to:
  /// **'This action cannot be undone. Continue?'**
  String get deleteTransactionConfirm;

  /// No description provided for @transactionTypeExpense.
  ///
  /// In en, this message translates to:
  /// **'Expense'**
  String get transactionTypeExpense;

  /// No description provided for @transactionTypeIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get transactionTypeIncome;

  /// No description provided for @transactionTypeTransfer.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transactionTypeTransfer;

  /// No description provided for @transactionTypeTransferShort.
  ///
  /// In en, this message translates to:
  /// **'Transfer.'**
  String get transactionTypeTransferShort;

  /// No description provided for @amountLabel.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amountLabel;

  /// No description provided for @amountRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount'**
  String get amountRequired;

  /// No description provided for @amountInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid amount'**
  String get amountInvalid;

  /// No description provided for @dateLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateLabel;

  /// No description provided for @merchantLabelExpense.
  ///
  /// In en, this message translates to:
  /// **'Merchant (optional)'**
  String get merchantLabelExpense;

  /// No description provided for @merchantLabelIncome.
  ///
  /// In en, this message translates to:
  /// **'Source (optional)'**
  String get merchantLabelIncome;

  /// No description provided for @descriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionLabel;

  /// No description provided for @accountLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountLabel;

  /// No description provided for @selectAccount.
  ///
  /// In en, this message translates to:
  /// **'Select account'**
  String get selectAccount;

  /// No description provided for @fromAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Source account'**
  String get fromAccountLabel;

  /// No description provided for @toAccountLabel.
  ///
  /// In en, this message translates to:
  /// **'Destination account'**
  String get toAccountLabel;

  /// No description provided for @selectFromAccount.
  ///
  /// In en, this message translates to:
  /// **'Select source account'**
  String get selectFromAccount;

  /// No description provided for @selectToAccount.
  ///
  /// In en, this message translates to:
  /// **'Select destination account'**
  String get selectToAccount;

  /// No description provided for @categoryLabel.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get categoryLabel;

  /// No description provided for @categoryRequired.
  ///
  /// In en, this message translates to:
  /// **'Category (required)'**
  String get categoryRequired;

  /// No description provided for @categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptional;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select category'**
  String get selectCategory;

  /// No description provided for @tagsLabel.
  ///
  /// In en, this message translates to:
  /// **'Tags (optional)'**
  String get tagsLabel;

  /// No description provided for @selectTags.
  ///
  /// In en, this message translates to:
  /// **'Select tags'**
  String get selectTags;

  /// No description provided for @selectAccountsFirst.
  ///
  /// In en, this message translates to:
  /// **'Select source and destination accounts'**
  String get selectAccountsFirst;

  /// No description provided for @selectCategoryFirst.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategoryFirst;

  /// No description provided for @selectAccountFirst.
  ///
  /// In en, this message translates to:
  /// **'Select an account'**
  String get selectAccountFirst;

  /// No description provided for @sameAccountError.
  ///
  /// In en, this message translates to:
  /// **'Source and destination accounts must be different'**
  String get sameAccountError;

  /// No description provided for @transactionCreated.
  ///
  /// In en, this message translates to:
  /// **'Transaction created'**
  String get transactionCreated;

  /// No description provided for @transactionUpdated.
  ///
  /// In en, this message translates to:
  /// **'Transaction updated'**
  String get transactionUpdated;

  /// No description provided for @transactionDeleted.
  ///
  /// In en, this message translates to:
  /// **'Transaction deleted'**
  String get transactionDeleted;

  /// No description provided for @emptyTransactions.
  ///
  /// In en, this message translates to:
  /// **'No transactions yet. Add one to get started.'**
  String get emptyTransactions;

  /// No description provided for @emptyExpenses.
  ///
  /// In en, this message translates to:
  /// **'No expenses recorded this period.'**
  String get emptyExpenses;

  /// No description provided for @emptyIncome.
  ///
  /// In en, this message translates to:
  /// **'No income recorded this period.'**
  String get emptyIncome;

  /// No description provided for @emptyTransfers.
  ///
  /// In en, this message translates to:
  /// **'No transfers recorded this period.'**
  String get emptyTransfers;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterExpenses.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get filterExpenses;

  /// No description provided for @filterIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get filterIncome;

  /// No description provided for @filterTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get filterTransfers;

  /// No description provided for @noAccountsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No accounts available.'**
  String get noAccountsAvailable;

  /// No description provided for @noCategoriesAvailable.
  ///
  /// In en, this message translates to:
  /// **'No categories. Create one first.'**
  String get noCategoriesAvailable;

  /// No description provided for @tagsTitle.
  ///
  /// In en, this message translates to:
  /// **'Tags'**
  String get tagsTitle;

  /// No description provided for @newTag.
  ///
  /// In en, this message translates to:
  /// **'New tag'**
  String get newTag;

  /// No description provided for @editTag.
  ///
  /// In en, this message translates to:
  /// **'Edit tag'**
  String get editTag;

  /// No description provided for @createTag.
  ///
  /// In en, this message translates to:
  /// **'Create tag'**
  String get createTag;

  /// No description provided for @deleteTag.
  ///
  /// In en, this message translates to:
  /// **'Delete tag'**
  String get deleteTag;

  /// No description provided for @tagNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get tagNameLabel;

  /// No description provided for @tagNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Work'**
  String get tagNameHint;

  /// No description provided for @tagNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get tagNameRequired;

  /// No description provided for @tagColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color (optional)'**
  String get tagColorLabel;

  /// No description provided for @noColor.
  ///
  /// In en, this message translates to:
  /// **'No color'**
  String get noColor;

  /// No description provided for @emptyTags.
  ///
  /// In en, this message translates to:
  /// **'No tags yet. Create one to organize your transactions.'**
  String get emptyTags;

  /// No description provided for @deleteTagConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this tag?'**
  String get deleteTagConfirm;

  /// No description provided for @deleteTagMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This action cannot be undone.'**
  String deleteTagMessage(String name);

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

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @categoriesTitle.
  ///
  /// In en, this message translates to:
  /// **'My Categories'**
  String get categoriesTitle;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get newCategory;

  /// No description provided for @editCategory.
  ///
  /// In en, this message translates to:
  /// **'Edit category'**
  String get editCategory;

  /// No description provided for @createCategory.
  ///
  /// In en, this message translates to:
  /// **'Create category'**
  String get createCategory;

  /// No description provided for @deleteCategory.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategory;

  /// No description provided for @categoryNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get categoryNameLabel;

  /// No description provided for @categoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Food'**
  String get categoryNameHint;

  /// No description provided for @categoryColorLabel.
  ///
  /// In en, this message translates to:
  /// **'Color'**
  String get categoryColorLabel;

  /// No description provided for @categoryIconLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get categoryIconLabel;

  /// No description provided for @noIcon.
  ///
  /// In en, this message translates to:
  /// **'No icon'**
  String get noIcon;

  /// No description provided for @categoryNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get categoryNameRequired;

  /// No description provided for @defaultCategory.
  ///
  /// In en, this message translates to:
  /// **'Set as default category'**
  String get defaultCategory;

  /// No description provided for @defaultCategorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Will be pre-selected when logging a new expense'**
  String get defaultCategorySubtitle;

  /// No description provided for @deleteCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category'**
  String get deleteCategoryTitle;

  /// No description provided for @deleteCategoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete \"{name}\"? This action cannot be undone.'**
  String deleteCategoryConfirm(String name);

  /// No description provided for @reassignExpenses.
  ///
  /// In en, this message translates to:
  /// **'Reassign expenses'**
  String get reassignExpenses;

  /// No description provided for @reassignMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{name}\" has {count} expense(s). Select a replacement category:'**
  String reassignMessage(String name, int count);

  /// No description provided for @noOtherCategories.
  ///
  /// In en, this message translates to:
  /// **'No other categories available. Create one first.'**
  String get noOtherCategories;

  /// No description provided for @deleteAndReassign.
  ///
  /// In en, this message translates to:
  /// **'Delete and reassign'**
  String get deleteAndReassign;

  /// No description provided for @categoryCreated.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categoryCreated;

  /// No description provided for @categoryUpdated.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get categoryUpdated;

  /// No description provided for @categoryDeleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categoryDeleted;

  /// No description provided for @categorySetDefault.
  ///
  /// In en, this message translates to:
  /// **'Category set as default'**
  String get categorySetDefault;

  /// No description provided for @setAsDefault.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get setAsDefault;

  /// No description provided for @emptyCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Create one to get started.'**
  String get emptyCategories;

  /// No description provided for @expenseCount.
  ///
  /// In en, this message translates to:
  /// **'{count} expense(s)'**
  String expenseCount(int count);

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reportsTitle;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @previousPeriod.
  ///
  /// In en, this message translates to:
  /// **'Previous period'**
  String get previousPeriod;

  /// No description provided for @nextPeriod.
  ///
  /// In en, this message translates to:
  /// **'Next period'**
  String get nextPeriod;

  /// No description provided for @totalPeriod.
  ///
  /// In en, this message translates to:
  /// **'Period total'**
  String get totalPeriod;

  /// No description provided for @noDataPeriod.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get noDataPeriod;

  /// No description provided for @byCategory.
  ///
  /// In en, this message translates to:
  /// **'By category'**
  String get byCategory;

  /// No description provided for @byWeek.
  ///
  /// In en, this message translates to:
  /// **'By week'**
  String get byWeek;

  /// No description provided for @byMonth.
  ///
  /// In en, this message translates to:
  /// **'By month'**
  String get byMonth;

  /// No description provided for @topCategory.
  ///
  /// In en, this message translates to:
  /// **'Top category'**
  String get topCategory;

  /// No description provided for @topMerchants.
  ///
  /// In en, this message translates to:
  /// **'Top merchants'**
  String get topMerchants;

  /// No description provided for @transactions.
  ///
  /// In en, this message translates to:
  /// **'transactions'**
  String get transactions;

  /// No description provided for @transactionCountLabel.
  ///
  /// In en, this message translates to:
  /// **'{count} transactions'**
  String transactionCountLabel(int count);

  /// No description provided for @dailyAverage.
  ///
  /// In en, this message translates to:
  /// **'Daily average'**
  String get dailyAverage;

  /// No description provided for @monthlyAverage.
  ///
  /// In en, this message translates to:
  /// **'Monthly average'**
  String get monthlyAverage;

  /// No description provided for @incomeLabel.
  ///
  /// In en, this message translates to:
  /// **'Income ({count})'**
  String incomeLabel(int count);

  /// No description provided for @netBalance.
  ///
  /// In en, this message translates to:
  /// **'Net balance'**
  String get netBalance;

  /// No description provided for @vsLastMonth.
  ///
  /// In en, this message translates to:
  /// **'vs {amount} last month'**
  String vsLastMonth(String amount);

  /// No description provided for @yearHighlights.
  ///
  /// In en, this message translates to:
  /// **'Year highlights'**
  String get yearHighlights;

  /// No description provided for @peakMonth.
  ///
  /// In en, this message translates to:
  /// **'Peak month'**
  String get peakMonth;

  /// No description provided for @lowestMonth.
  ///
  /// In en, this message translates to:
  /// **'Lowest month'**
  String get lowestMonth;

  /// No description provided for @filterTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get filterTooltip;

  /// No description provided for @filterTitle.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filterTitle;

  /// No description provided for @filterAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get filterAccount;

  /// No description provided for @filterCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get filterCategory;

  /// No description provided for @filterTag.
  ///
  /// In en, this message translates to:
  /// **'Tag'**
  String get filterTag;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clearFilters;

  /// No description provided for @applyFilters.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get applyFilters;

  /// No description provided for @closeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get closeTooltip;

  /// No description provided for @noAccounts.
  ///
  /// In en, this message translates to:
  /// **'No accounts'**
  String get noAccounts;

  /// No description provided for @noCategories.
  ///
  /// In en, this message translates to:
  /// **'No categories'**
  String get noCategories;

  /// No description provided for @noTags.
  ///
  /// In en, this message translates to:
  /// **'No tags'**
  String get noTags;

  /// No description provided for @moreTitle.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTitle;

  /// No description provided for @organizationSection.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get organizationSection;

  /// No description provided for @categoriesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your expense categories'**
  String get categoriesSubtitle;

  /// No description provided for @tagsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Organize your transactions with tags'**
  String get tagsSubtitle;

  /// No description provided for @languageSection.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageSection;

  /// No description provided for @spanishLanguage.
  ///
  /// In en, this message translates to:
  /// **'Español'**
  String get spanishLanguage;

  /// No description provided for @englishLanguage.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get englishLanguage;

  /// No description provided for @accountSection.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountSection;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logout;

  /// No description provided for @logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign out?'**
  String get logoutTitle;

  /// No description provided for @logoutMessage.
  ///
  /// In en, this message translates to:
  /// **'You will be signed out on this device. You can sign in again at any time.'**
  String get logoutMessage;

  /// No description provided for @logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutConfirm;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In en, this message translates to:
  /// **'No data'**
  String get noData;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get yesterday;

  /// No description provided for @typeLabel.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get typeLabel;

  /// No description provided for @dateDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get dateDetailLabel;

  /// No description provided for @currencyDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Currency'**
  String get currencyDetailLabel;

  /// No description provided for @merchantDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Merchant'**
  String get merchantDetailLabel;

  /// No description provided for @descriptionDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get descriptionDetailLabel;

  /// No description provided for @accountDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountDetailLabel;

  /// No description provided for @nameDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get nameDetailLabel;

  /// No description provided for @transferDetailLabel.
  ///
  /// In en, this message translates to:
  /// **'Transfer'**
  String get transferDetailLabel;

  /// No description provided for @fromLabel.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get fromLabel;

  /// No description provided for @toLabel.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get toLabel;

  /// No description provided for @registeredLabel.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredLabel;

  /// No description provided for @editTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get editTooltip;

  /// No description provided for @deleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get deleteTooltip;

  /// No description provided for @filtersTooltip.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersTooltip;

  /// No description provided for @searchOrCreateTag.
  ///
  /// In en, this message translates to:
  /// **'Search or create tag'**
  String get searchOrCreateTag;

  /// No description provided for @newTagColor.
  ///
  /// In en, this message translates to:
  /// **'Color for new tag'**
  String get newTagColor;

  /// No description provided for @createTagInline.
  ///
  /// In en, this message translates to:
  /// **'Create tag \"{name}\"'**
  String createTagInline(String name);

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @amountLocalLabel.
  ///
  /// In en, this message translates to:
  /// **'Equivalent in S/'**
  String get amountLocalLabel;

  /// No description provided for @amountLocalLabelUsd.
  ///
  /// In en, this message translates to:
  /// **'Equivalent in \$'**
  String get amountLocalLabelUsd;

  /// No description provided for @exchangeRateHelper.
  ///
  /// In en, this message translates to:
  /// **'Exchange rate: S/ {rate}'**
  String exchangeRateHelper(String rate);

  /// No description provided for @onboardingStep1StepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 1 of 2 - Accounts'**
  String get onboardingStep1StepLabel;

  /// No description provided for @onboardingStep2StepLabel.
  ///
  /// In en, this message translates to:
  /// **'Step 2 of 2 - Categories'**
  String get onboardingStep2StepLabel;

  /// No description provided for @onboardingStep1Title.
  ///
  /// In en, this message translates to:
  /// **'Add your accounts'**
  String get onboardingStep1Title;

  /// No description provided for @onboardingStep1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Add at least one account to start tracking your finances.'**
  String get onboardingStep1Subtitle;

  /// No description provided for @onboardingAccountTypeQuestion.
  ///
  /// In en, this message translates to:
  /// **'What type of account is it?'**
  String get onboardingAccountTypeQuestion;

  /// No description provided for @onboardingAccountNameQuestion.
  ///
  /// In en, this message translates to:
  /// **'What would you like to call it?'**
  String get onboardingAccountNameQuestion;

  /// No description provided for @onboardingAccountNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. BCP Salary Account'**
  String get onboardingAccountNameHint;

  /// No description provided for @onboardingAccountNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name'**
  String get onboardingAccountNameRequired;

  /// No description provided for @onboardingSavingLabel.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get onboardingSavingLabel;

  /// No description provided for @onboardingAddAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Add account'**
  String get onboardingAddAccountButton;

  /// No description provided for @onboardingAccountsAddedLabel.
  ///
  /// In en, this message translates to:
  /// **'Accounts added'**
  String get onboardingAccountsAddedLabel;

  /// No description provided for @onboardingContinueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onboardingContinueButton;

  /// No description provided for @onboardingGenericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get onboardingGenericError;

  /// No description provided for @onboardingStep2Title.
  ///
  /// In en, this message translates to:
  /// **'Choose your categories'**
  String get onboardingStep2Title;

  /// No description provided for @onboardingStep2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Select the categories that match your spending and income. You can add more later.'**
  String get onboardingStep2Subtitle;

  /// No description provided for @onboardingExpensesGroup.
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get onboardingExpensesGroup;

  /// No description provided for @onboardingIncomeGroup.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get onboardingIncomeGroup;

  /// No description provided for @onboardingAddCustomCategory.
  ///
  /// In en, this message translates to:
  /// **'Add custom category'**
  String get onboardingAddCustomCategory;

  /// No description provided for @onboardingFinishButton.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get onboardingFinishButton;

  /// No description provided for @onboardingCategoriesError.
  ///
  /// In en, this message translates to:
  /// **'Could not save categories. Please try again.'**
  String get onboardingCategoriesError;

  /// No description provided for @catFood.
  ///
  /// In en, this message translates to:
  /// **'Food'**
  String get catFood;

  /// No description provided for @catTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get catTransport;

  /// No description provided for @catHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get catHousing;

  /// No description provided for @catHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get catHealth;

  /// No description provided for @catEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get catEntertainment;

  /// No description provided for @catShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get catShopping;

  /// No description provided for @catEducation.
  ///
  /// In en, this message translates to:
  /// **'Education'**
  String get catEducation;

  /// No description provided for @catPersonalCare.
  ///
  /// In en, this message translates to:
  /// **'Personal Care'**
  String get catPersonalCare;

  /// No description provided for @catUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get catUtilities;

  /// No description provided for @catTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get catTravel;

  /// No description provided for @catSalary.
  ///
  /// In en, this message translates to:
  /// **'Salary'**
  String get catSalary;

  /// No description provided for @catFreelance.
  ///
  /// In en, this message translates to:
  /// **'Freelance'**
  String get catFreelance;

  /// No description provided for @catInvestments.
  ///
  /// In en, this message translates to:
  /// **'Investments'**
  String get catInvestments;

  /// No description provided for @catOtherIncome.
  ///
  /// In en, this message translates to:
  /// **'Other Income'**
  String get catOtherIncome;

  /// No description provided for @onboardingNewCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get onboardingNewCategoryTitle;

  /// No description provided for @onboardingCategoryNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get onboardingCategoryNameHint;

  /// No description provided for @onboardingIconSectionLabel.
  ///
  /// In en, this message translates to:
  /// **'Icon'**
  String get onboardingIconSectionLabel;

  /// No description provided for @onboardingAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get onboardingAddButton;

  /// No description provided for @emptyTransactionsHint.
  ///
  /// In en, this message translates to:
  /// **'Tap + to record your first transaction, or try the microphone for voice entry.'**
  String get emptyTransactionsHint;

  /// No description provided for @emptyExpensesHint.
  ///
  /// In en, this message translates to:
  /// **'Record an expense with the + button or say what you spent by voice.'**
  String get emptyExpensesHint;

  /// No description provided for @emptyIncomeHint.
  ///
  /// In en, this message translates to:
  /// **'Add income whenever you receive money — salary, freelance, anything.'**
  String get emptyIncomeHint;

  /// No description provided for @emptyTransfersHint.
  ///
  /// In en, this message translates to:
  /// **'Transfers between your accounts will appear here.'**
  String get emptyTransfersHint;

  /// No description provided for @registerLanguageLabel.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get registerLanguageLabel;

  /// No description provided for @netWorthIncludeDebtTooltip.
  ///
  /// In en, this message translates to:
  /// **'Showing net worth (includes debt)'**
  String get netWorthIncludeDebtTooltip;

  /// No description provided for @netWorthAssetsOnlyTooltip.
  ///
  /// In en, this message translates to:
  /// **'Showing assets only'**
  String get netWorthAssetsOnlyTooltip;

  /// No description provided for @netWorthAssetsOnlyTitle.
  ///
  /// In en, this message translates to:
  /// **'Assets'**
  String get netWorthAssetsOnlyTitle;

  /// No description provided for @accountActiveLabel.
  ///
  /// In en, this message translates to:
  /// **'Active account'**
  String get accountActiveLabel;

  /// No description provided for @accountActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Inactive accounts are excluded from net worth'**
  String get accountActiveSubtitle;
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
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
