// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Finanzas IA';

  @override
  String get loginTitle => 'Sign In';

  @override
  String get loginSubtitle => 'Track your expenses with intelligence';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'you@email.com';

  @override
  String get emailRequired => 'Enter your email';

  @override
  String get emailInvalid => 'Enter a valid email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordRequired => 'Enter your password';

  @override
  String get passwordRequiredRegister => 'Enter a password';

  @override
  String get passwordTooShort => 'Password must be at least 10 characters';

  @override
  String get passwordHelperText => 'Minimum 10 characters';

  @override
  String get showPassword => 'Show password';

  @override
  String get hidePassword => 'Hide password';

  @override
  String get forgotPassword => 'Forgot your password?';

  @override
  String get loginButton => 'Sign In';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get registerLink => 'Sign up';

  @override
  String get registerTitle => 'Create account';

  @override
  String get fullNameLabel => 'Full name';

  @override
  String get fullNameHint => 'Maria Garcia';

  @override
  String get fullNameRequired => 'Enter your full name';

  @override
  String get fullNameTooShort => 'Name must be at least 2 characters';

  @override
  String get confirmPasswordLabel => 'Confirm password';

  @override
  String get confirmPasswordRequired => 'Confirm your password';

  @override
  String get passwordsNoMatch => 'Passwords do not match';

  @override
  String get registerButton => 'Create account';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get loginLink => 'Sign In';

  @override
  String get incorrectCredentials => 'Incorrect email or password';

  @override
  String get mainCurrencyLabel => 'Main currency';

  @override
  String get solesCurrency => 'Soles (S/)';

  @override
  String get dollarsCurrency => 'Dollars (\$)';

  @override
  String get backTooltip => 'Back';

  @override
  String get navTransactions => 'Transactions';

  @override
  String get navAccounts => 'Accounts';

  @override
  String get navReports => 'Reports';

  @override
  String get navMore => 'More';

  @override
  String get accountsTitle => 'My Accounts';

  @override
  String get newAccount => 'New account';

  @override
  String get editAccount => 'Edit account';

  @override
  String get accountTypeLabel => 'Account type';

  @override
  String get accountTypeBankLabel => 'Bank account';

  @override
  String get accountTypeCreditCardLabel => 'Credit card';

  @override
  String get accountTypeCashLabel => 'Cash';

  @override
  String get accountTypeWalletLabel => 'Digital wallet';

  @override
  String get accountNameLabel => 'Name';

  @override
  String get accountNameHint => 'e.g. Chase Checking';

  @override
  String get accountNameRequired => 'Enter a name';

  @override
  String get linkedBankAccount => 'Linked bank account';

  @override
  String get linkedBankAccountHelper =>
      'Wallet expenses will deduct from this account';

  @override
  String get noLinkedAccount => 'No linked account';

  @override
  String get currencyLabel => 'Currency';

  @override
  String get initialBalanceLabel => 'Initial balance';

  @override
  String get colorLabel => 'Color';

  @override
  String get changeColor => 'Change color';

  @override
  String get chooseColor => 'Choose color';

  @override
  String get creditLimitLabel => 'Credit limit';

  @override
  String get closingDayLabel => 'Closing day';

  @override
  String get dueDayLabel => 'Due day';

  @override
  String get dayHint => '1-31';

  @override
  String get dayInvalid => 'Invalid day';

  @override
  String get isDefaultAccount => 'Default account';

  @override
  String get isDefaultAccountSubtitle =>
      'Will be used by default in new transactions';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get createAccount => 'Create account';

  @override
  String get deleteAccount => 'Delete account';

  @override
  String deleteAccountConfirm(String name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String accountInUse(String name, int count) {
    return '\"$name\" has $count transaction(s). Reassign or delete those transactions before deleting the account.';
  }

  @override
  String get netWorthTitle => 'Net worth';

  @override
  String get emptyAccounts => 'No accounts yet. Add one to get started.';

  @override
  String get defaultLabel => 'Default';

  @override
  String get balanceInAccount => 'Balance in account';

  @override
  String get transactionsTitle => 'Transactions';

  @override
  String get newTransaction => 'New transaction';

  @override
  String get editTransaction => 'Edit transaction';

  @override
  String get saveTransaction => 'Save transaction';

  @override
  String get deleteTransaction => 'Delete transaction';

  @override
  String get deleteTransactionConfirm =>
      'This action cannot be undone. Continue?';

  @override
  String get transactionTypeExpense => 'Expense';

  @override
  String get transactionTypeIncome => 'Income';

  @override
  String get transactionTypeTransfer => 'Transfer';

  @override
  String get transactionTypeTransferShort => 'Transfer.';

  @override
  String get amountLabel => 'Amount';

  @override
  String get amountRequired => 'Enter an amount';

  @override
  String get amountInvalid => 'Invalid amount';

  @override
  String get dateLabel => 'Date';

  @override
  String get merchantLabelExpense => 'Merchant (optional)';

  @override
  String get merchantLabelIncome => 'Source (optional)';

  @override
  String get descriptionLabel => 'Description (optional)';

  @override
  String get accountLabel => 'Account';

  @override
  String get selectAccount => 'Select account';

  @override
  String get fromAccountLabel => 'Source account';

  @override
  String get toAccountLabel => 'Destination account';

  @override
  String get selectFromAccount => 'Select source account';

  @override
  String get selectToAccount => 'Select destination account';

  @override
  String get categoryLabel => 'Category';

  @override
  String get categoryRequired => 'Category (required)';

  @override
  String get categoryOptional => 'Category (optional)';

  @override
  String get selectCategory => 'Select category';

  @override
  String get tagsLabel => 'Tags (optional)';

  @override
  String get selectTags => 'Select tags';

  @override
  String get selectAccountsFirst => 'Select source and destination accounts';

  @override
  String get selectCategoryFirst => 'Select a category';

  @override
  String get selectAccountFirst => 'Select an account';

  @override
  String get sameAccountError =>
      'Source and destination accounts must be different';

  @override
  String get transactionCreated => 'Transaction created';

  @override
  String get transactionUpdated => 'Transaction updated';

  @override
  String get transactionDeleted => 'Transaction deleted';

  @override
  String get emptyTransactions =>
      'No transactions yet. Add one to get started.';

  @override
  String get emptyExpenses => 'No expenses recorded this period.';

  @override
  String get emptyIncome => 'No income recorded this period.';

  @override
  String get emptyTransfers => 'No transfers recorded this period.';

  @override
  String get filterAll => 'All';

  @override
  String get filterExpenses => 'Expenses';

  @override
  String get filterIncome => 'Income';

  @override
  String get filterTransfers => 'Transfers';

  @override
  String get noAccountsAvailable => 'No accounts available.';

  @override
  String get noCategoriesAvailable => 'No categories. Create one first.';

  @override
  String get tagsTitle => 'Tags';

  @override
  String get newTag => 'New tag';

  @override
  String get editTag => 'Edit tag';

  @override
  String get createTag => 'Create tag';

  @override
  String get deleteTag => 'Delete tag';

  @override
  String get tagNameLabel => 'Name';

  @override
  String get tagNameHint => 'e.g. Work';

  @override
  String get tagNameRequired => 'Name is required';

  @override
  String get tagColorLabel => 'Color (optional)';

  @override
  String get noColor => 'No color';

  @override
  String get emptyTags =>
      'No tags yet. Create one to organize your transactions.';

  @override
  String get deleteTagConfirm => 'Delete this tag?';

  @override
  String deleteTagMessage(String name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get edit => 'Edit';

  @override
  String get delete => 'Delete';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';

  @override
  String get categoriesTitle => 'My Categories';

  @override
  String get newCategory => 'New category';

  @override
  String get editCategory => 'Edit category';

  @override
  String get createCategory => 'Create category';

  @override
  String get deleteCategory => 'Delete category';

  @override
  String get categoryNameLabel => 'Name';

  @override
  String get categoryNameHint => 'e.g. Food';

  @override
  String get categoryColorLabel => 'Color';

  @override
  String get categoryIconLabel => 'Icon';

  @override
  String get noIcon => 'No icon';

  @override
  String get categoryNameRequired => 'Name is required';

  @override
  String get defaultCategory => 'Set as default category';

  @override
  String get defaultCategorySubtitle =>
      'Will be pre-selected when logging a new expense';

  @override
  String get deleteCategoryTitle => 'Delete category';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Delete \"$name\"? This action cannot be undone.';
  }

  @override
  String get reassignExpenses => 'Reassign expenses';

  @override
  String reassignMessage(String name, int count) {
    return '\"$name\" has $count expense(s). Select a replacement category:';
  }

  @override
  String get noOtherCategories =>
      'No other categories available. Create one first.';

  @override
  String get deleteAndReassign => 'Delete and reassign';

  @override
  String get categoryCreated => 'Category created';

  @override
  String get categoryUpdated => 'Category updated';

  @override
  String get categoryDeleted => 'Category deleted';

  @override
  String get categorySetDefault => 'Category set as default';

  @override
  String get setAsDefault => 'Set as default';

  @override
  String get emptyCategories => 'No categories yet. Create one to get started.';

  @override
  String expenseCount(int count) {
    return '$count expense(s)';
  }

  @override
  String get reportsTitle => 'Reports';

  @override
  String get monthly => 'Monthly';

  @override
  String get yearly => 'Yearly';

  @override
  String get previousPeriod => 'Previous period';

  @override
  String get nextPeriod => 'Next period';

  @override
  String get totalPeriod => 'Period total';

  @override
  String get noDataPeriod => 'No data for this period';

  @override
  String get byCategory => 'By category';

  @override
  String get byWeek => 'By week';

  @override
  String get byMonth => 'By month';

  @override
  String get topCategory => 'Top category';

  @override
  String get topMerchants => 'Top merchants';

  @override
  String get transactions => 'transactions';

  @override
  String transactionCountLabel(int count) {
    return '$count transactions';
  }

  @override
  String get dailyAverage => 'Daily average';

  @override
  String get monthlyAverage => 'Monthly average';

  @override
  String incomeLabel(int count) {
    return 'Income ($count)';
  }

  @override
  String get netBalance => 'Net balance';

  @override
  String vsLastMonth(String amount) {
    return 'vs $amount last month';
  }

  @override
  String get yearHighlights => 'Year highlights';

  @override
  String get peakMonth => 'Peak month';

  @override
  String get lowestMonth => 'Lowest month';

  @override
  String get filterTooltip => 'Filter';

  @override
  String get filterTitle => 'Filters';

  @override
  String get filterAccount => 'Account';

  @override
  String get filterCategory => 'Category';

  @override
  String get filterTag => 'Tag';

  @override
  String get clearFilters => 'Clear';

  @override
  String get applyFilters => 'Apply';

  @override
  String get closeTooltip => 'Close';

  @override
  String get noAccounts => 'No accounts';

  @override
  String get noCategories => 'No categories';

  @override
  String get noTags => 'No tags';

  @override
  String get moreTitle => 'More';

  @override
  String get organizationSection => 'Organization';

  @override
  String get categoriesSubtitle => 'Manage your expense categories';

  @override
  String get tagsSubtitle => 'Organize your transactions with tags';

  @override
  String get languageSection => 'Language';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get englishLanguage => 'English';

  @override
  String get accountSection => 'Account';

  @override
  String get logout => 'Sign out';

  @override
  String get logoutTitle => 'Sign out?';

  @override
  String get logoutMessage =>
      'You will be signed out on this device. You can sign in again at any time.';

  @override
  String get logoutConfirm => 'Sign out';

  @override
  String get retry => 'Retry';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading...';

  @override
  String get noData => 'No data';

  @override
  String get today => 'Today';

  @override
  String get yesterday => 'Yesterday';

  @override
  String get typeLabel => 'Type';

  @override
  String get dateDetailLabel => 'Date';

  @override
  String get currencyDetailLabel => 'Currency';

  @override
  String get merchantDetailLabel => 'Merchant';

  @override
  String get descriptionDetailLabel => 'Description';

  @override
  String get accountDetailLabel => 'Account';

  @override
  String get nameDetailLabel => 'Name';

  @override
  String get transferDetailLabel => 'Transfer';

  @override
  String get fromLabel => 'From';

  @override
  String get toLabel => 'To';

  @override
  String get registeredLabel => 'Registered';

  @override
  String get editTooltip => 'Edit';

  @override
  String get deleteTooltip => 'Delete';

  @override
  String get filtersTooltip => 'Filters';

  @override
  String get searchOrCreateTag => 'Search or create tag';

  @override
  String get newTagColor => 'Color for new tag';

  @override
  String createTagInline(String name) {
    return 'Create tag \"$name\"';
  }

  @override
  String get done => 'Done';

  @override
  String get amountLocalLabel => 'Equivalent in S/';

  @override
  String get amountLocalLabelUsd => 'Equivalent in \$';

  @override
  String exchangeRateHelper(String rate) {
    return 'Exchange rate: S/ $rate';
  }

  @override
  String get onboardingStep1StepLabel => 'Step 1 of 2 - Accounts';

  @override
  String get onboardingStep2StepLabel => 'Step 2 of 2 - Categories';

  @override
  String get onboardingStep1Title => 'Add your accounts';

  @override
  String get onboardingStep1Subtitle =>
      'Add at least one account to start tracking your finances.';

  @override
  String get onboardingAccountTypeQuestion => 'What type of account is it?';

  @override
  String get onboardingAccountNameQuestion => 'What would you like to call it?';

  @override
  String get onboardingAccountNameHint => 'e.g. BCP Salary Account';

  @override
  String get onboardingAccountNameRequired => 'Please enter a name';

  @override
  String get onboardingSavingLabel => 'Saving...';

  @override
  String get onboardingAddAccountButton => 'Add account';

  @override
  String get onboardingAccountsAddedLabel => 'Accounts added';

  @override
  String get onboardingContinueButton => 'Continue';

  @override
  String get onboardingGenericError =>
      'Something went wrong. Please try again.';

  @override
  String get onboardingStep2Title => 'Choose your categories';

  @override
  String get onboardingStep2Subtitle =>
      'Select the categories that match your spending and income. You can add more later.';

  @override
  String get onboardingExpensesGroup => 'Expenses';

  @override
  String get onboardingIncomeGroup => 'Income';

  @override
  String get onboardingAddCustomCategory => 'Add custom category';

  @override
  String get onboardingFinishButton => 'Finish';

  @override
  String get onboardingCategoriesError =>
      'Could not save categories. Please try again.';

  @override
  String get catFood => 'Food';

  @override
  String get catTransport => 'Transport';

  @override
  String get catHousing => 'Housing';

  @override
  String get catHealth => 'Health';

  @override
  String get catEntertainment => 'Entertainment';

  @override
  String get catShopping => 'Shopping';

  @override
  String get catEducation => 'Education';

  @override
  String get catPersonalCare => 'Personal Care';

  @override
  String get catUtilities => 'Utilities';

  @override
  String get catTravel => 'Travel';

  @override
  String get catSalary => 'Salary';

  @override
  String get catFreelance => 'Freelance';

  @override
  String get catInvestments => 'Investments';

  @override
  String get catOtherIncome => 'Other Income';

  @override
  String get onboardingNewCategoryTitle => 'New category';

  @override
  String get onboardingCategoryNameHint => 'Category name';

  @override
  String get onboardingIconSectionLabel => 'Icon';

  @override
  String get onboardingAddButton => 'Add';

  @override
  String get emptyTransactionsHint =>
      'Tap + to record your first transaction, or try the microphone for voice entry.';

  @override
  String get emptyExpensesHint =>
      'Record an expense with the + button or say what you spent by voice.';

  @override
  String get emptyIncomeHint =>
      'Add income whenever you receive money — salary, freelance, anything.';

  @override
  String get emptyTransfersHint =>
      'Transfers between your accounts will appear here.';

  @override
  String get registerLanguageLabel => 'Language';

  @override
  String get netWorthIncludeDebtTooltip => 'Showing net worth (includes debt)';

  @override
  String get netWorthAssetsOnlyTooltip => 'Showing assets only';

  @override
  String get netWorthAssetsOnlyTitle => 'Assets';

  @override
  String get accountActiveLabel => 'Active account';

  @override
  String get accountActiveSubtitle =>
      'Inactive accounts are excluded from net worth';
}
