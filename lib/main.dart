import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/locale/locale_cubit.dart';
import 'core/theme/app_theme.dart';
import 'features/onboarding/screens/onboarding_wrapper.dart';
import 'core/api/dio_client.dart';
import 'features/accounts/bloc/account_bloc.dart';
import 'features/accounts/bloc/account_event.dart';
import 'features/accounts/data/account_repository.dart';
import 'features/accounts/screens/accounts_screen.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/bloc/auth_state.dart';
import 'features/auth/data/auth_repository.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/categories/bloc/category_bloc.dart';
import 'features/categories/data/category_repository.dart';
import 'features/reports/screens/reports_shell_screen.dart';
import 'features/transactions/bloc/tag_bloc.dart';
import 'features/transactions/bloc/transaction_bloc.dart';
import 'features/transactions/data/tag_repository.dart';
import 'features/transactions/data/transaction_repository.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/transactions/screens/transaction_list_screen.dart';
import 'features/voice/voice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanzasApp());
}

class FinanzasApp extends StatefulWidget {
  const FinanzasApp({super.key});

  @override
  State<FinanzasApp> createState() => _FinanzasAppState();
}

class _FinanzasAppState extends State<FinanzasApp> {
  late final AuthBloc _authBloc;
  late final GoRouter _router;
  late final StreamSubscription<void> _sessionExpiredSub;

  @override
  void initState() {
    super.initState();
    _authBloc = AuthBloc(
      repository: AuthRepositoryImpl(),
      categoryRepository: CategoryRepositoryImpl(),
    )..add(const AuthCheckRequested());

    // When DioClient can't refresh the token, force a re-auth check so
    // AuthBloc emits AuthUnauthenticated and GoRouter redirects to /login.
    _sessionExpiredSub = DioClient.onSessionExpired.listen((_) {
      _authBloc.add(const AuthCheckRequested());
    });

    _router = GoRouter(
      debugLogDiagnostics: false,
      initialLocation: '/',
      redirect: (context, state) {
        final authState = _authBloc.state;
        final isInitialOrLoading =
            authState is AuthInitial || authState is AuthLoading;

        final loc = state.matchedLocation;
        final onAuthRoute = loc == '/login' || loc == '/register';

        // While the auth check is in progress, stay put.
        if (isInitialOrLoading) return null;

        if (authState is AuthAuthenticated) {
          // New users who need onboarding must go there first.
          if (authState.needsOnboarding) {
            return loc == '/onboarding' ? null : '/onboarding';
          }
          // Onboarding-complete users bounce away from auth / root / onboarding.
          final onPublicRoute =
              onAuthRoute || loc == '/' || loc == '/onboarding';
          return onPublicRoute ? '/transactions' : null;
        }

        // Unauthenticated: only login and register are reachable.
        return onAuthRoute ? null : '/login';
      },
      refreshListenable: _GoRouterBlocStream(_authBloc),
      routes: [
        GoRoute(
          path: '/',
          builder: (_, __) => const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => BlocProvider.value(
            value: _authBloc,
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => BlocProvider.value(
            value: _authBloc,
            child: const RegisterScreen(),
          ),
        ),
        GoRoute(
          path: '/transactions',
          builder: (context, state) => const _HomeShell(initialIndex: 0),
        ),
        GoRoute(
          path: '/accounts',
          builder: (context, state) => const _HomeShell(initialIndex: 1),
        ),
        GoRoute(
          path: '/reports',
          builder: (context, state) => const _HomeShell(initialIndex: 2),
        ),
        GoRoute(
          path: '/mas',
          builder: (context, state) => const _HomeShell(initialIndex: 3),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => BlocProvider.value(
            value: _authBloc,
            child: const OnboardingWrapper(),
          ),
        ),
        GoRoute(
          path: '/voice',
          builder: (context, state) => BlocProvider(
            create: (_) => VoiceBloc(),
            child: const VoiceRecordScreen(),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _sessionExpiredSub.cancel();
    _authBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: _authBloc),
        BlocProvider<LocaleCubit>(create: (_) => LocaleCubit()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Finanzas IA',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: ThemeMode.system,
            routerConfig: _router,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}

class _GoRouterBlocStream extends ChangeNotifier {
  _GoRouterBlocStream(AuthBloc bloc) {
    _subscription = bloc.stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Tabs: 0 Transacciones, 1 Cuentas, 2 Reportes, 3 Mas (Categories/Tags as sub-pages).
class _HomeShell extends StatefulWidget {
  const _HomeShell({this.initialIndex = 0});

  final int initialIndex;

  @override
  State<_HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<_HomeShell> {
  late int _currentIndex;

  late final TransactionBloc _transactionBloc;
  late final AccountBloc _accountBloc;
  late final CategoryBloc _categoryBloc;
  late final TagBloc _tagBloc;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _transactionBloc =
        TransactionBloc(repository: TransactionRepositoryImpl());
    _accountBloc = AccountBloc(repository: AccountRepositoryImpl());
    _categoryBloc = CategoryBloc(repository: CategoryRepositoryImpl());
    _tagBloc = TagBloc(repository: TagRepositoryImpl());
  }

  @override
  void dispose() {
    _transactionBloc.close();
    _accountBloc.close();
    _categoryBloc.close();
    _tagBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<TransactionBloc>.value(value: _transactionBloc),
        BlocProvider<AccountBloc>.value(value: _accountBloc),
        BlocProvider<CategoryBloc>.value(value: _categoryBloc),
        BlocProvider<TagBloc>.value(value: _tagBloc),
      ],
      child: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            TransactionListScreen(),
            AccountsScreen(),
            ReportsShellScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return NavigationBar(
              selectedIndex: _currentIndex,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
                if (index == 1) {
                  context
                      .read<AccountBloc>()
                      .add(const LoadAccounts());
                }
              },
              destinations: [
                NavigationDestination(
                  icon: const Icon(Icons.receipt_long_outlined),
                  selectedIcon: const Icon(Icons.receipt_long),
                  label: l10n.navTransactions,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.account_balance_outlined),
                  selectedIcon: const Icon(Icons.account_balance),
                  label: l10n.navAccounts,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.analytics_outlined),
                  selectedIcon: const Icon(Icons.analytics),
                  label: l10n.navReports,
                ),
                NavigationDestination(
                  icon: const Icon(Icons.grid_view_outlined),
                  selectedIcon: const Icon(Icons.grid_view),
                  label: l10n.navMore,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
