import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:finanzas_ia/l10n/app_localizations.dart';

import '../../../core/locale/locale_cubit.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../auth/bloc/auth_event.dart';
import '../../categories/bloc/category_bloc.dart';
import '../../categories/screens/categories_screen.dart';
import '../../transactions/bloc/tag_bloc.dart';
import '../../transactions/screens/tags_screen.dart';

/// "Mas" tab hub for Categories, Tags, language, and session management.
/// Categories and Tags are pushed as sub-pages rather than owning their own
/// bottom-nav slots.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<CategoryBloc>.value(
              value: context.read<CategoryBloc>(),
            ),
          ],
          child: const CategoriesScreen(),
        ),
      ),
    );
  }

  void _openTags(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider<TagBloc>.value(
              value: context.read<TagBloc>(),
            ),
          ],
          child: const TagsScreen(),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final authBloc = context.read<AuthBloc>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.logoutConfirm),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      authBloc.add(const LogoutRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: false,
            snap: true,
            backgroundColor: colorScheme.surface,
            surfaceTintColor: Colors.transparent,
            title: Text(
              l10n.moreTitle,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionHeader(label: l10n.organizationSection),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.category_outlined,
                      title: l10n.categoriesTitle,
                      subtitle: l10n.categoriesSubtitle,
                      onTap: () => _openCategories(context),
                    ),
                    _Divider(),
                    _SettingsTile(
                      icon: Icons.label_outlined,
                      title: l10n.tagsTitle,
                      subtitle: l10n.tagsSubtitle,
                      onTap: () => _openTags(context),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionHeader(label: l10n.languageSection),
                const SizedBox(height: 8),
                BlocBuilder<LocaleCubit, Locale>(
                  builder: (context, currentLocale) {
                    return _SettingsCard(
                      children: [
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Icon(
                            currentLocale.languageCode == 'es'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: currentLocale.languageCode == 'es'
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            l10n.spanishLanguage,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => context
                              .read<LocaleCubit>()
                              .setLocale(const Locale('es')),
                        ),
                        _Divider(),
                        ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          leading: Icon(
                            currentLocale.languageCode == 'en'
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            color: currentLocale.languageCode == 'en'
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                          ),
                          title: Text(
                            l10n.englishLanguage,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          onTap: () => context
                              .read<LocaleCubit>()
                              .setLocale(const Locale('en')),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                _SectionHeader(label: l10n.accountSection),
                const SizedBox(height: 8),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.logout,
                      title: l10n.logout,
                      iconColor: colorScheme.error,
                      titleColor: colorScheme.error,
                      onTap: () => _confirmLogout(context),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 2),
      child: Text(
        label.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: colorScheme.surfaceContainerLow,
      elevation: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor,
    this.titleColor,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.primary;
    final resolvedTitleColor = titleColor ?? colorScheme.onSurface;

    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(icon, color: resolvedIconColor),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: resolvedTitleColor,
              fontWeight: FontWeight.w500,
            ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            )
          : null,
      trailing: subtitle != null
          ? Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant,
            )
          : null,
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Divider(
      height: 1,
      thickness: 1,
      indent: 56,
      endIndent: 0,
      color: colorScheme.outlineVariant.withValues(alpha: 0.5),
    );
  }
}
