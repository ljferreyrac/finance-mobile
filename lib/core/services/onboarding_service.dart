import 'package:shared_preferences/shared_preferences.dart';

/// Persists flags that track progress through the two-step onboarding flow.
///
/// Two separate flags are used so the app can resume at the correct step if
/// the user leaves between step 1 (accounts) and step 2 (categories):
///   - [_accountsKey]: set after step 1 is confirmed
///   - [_key]: set after step 2 is confirmed (onboarding fully done)
class OnboardingService {
  static const _key = 'has_completed_onboarding';
  static const _accountsKey = 'has_completed_onboarding_accounts';

  /// True only once both onboarding steps are done.
  Future<bool> hasCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  /// Marks the full onboarding flow as complete. Call at the end of step 2.
  Future<void> markComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  /// True once step 1 (accounts) is confirmed, even if step 2 is not done yet.
  Future<bool> hasCompletedAccounts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_accountsKey) ?? false;
  }

  /// Marks step 1 (accounts) as done. Call when the user taps Continue after
  /// creating at least one account.
  Future<void> markAccountsComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_accountsKey, true);
  }
}
