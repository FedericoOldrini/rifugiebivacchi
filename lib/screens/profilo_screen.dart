import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import '../providers/rifugi_provider.dart';
import 'passaporto_screen.dart';
import 'dettaglio_rifugio_screen.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

class ProfiloScreen extends StatelessWidget {
  const ProfiloScreen({super.key});

  String _resolveAuthError(BuildContext context, String errorCode) {
    final l10n = AppLocalizations.of(context)!;
    // Auth errors use format 'error_code:details'
    // We show a localized prefix + the technical details
    final parts = errorCode.split(':');
    final code = parts.first;
    final details = parts.length > 1 ? parts.sublist(1).join(':') : '';

    switch (code) {
      case 'google_login_error':
        return '${l10n.error}: Google login - $details';
      case 'apple_login_error':
        return '${l10n.error}: Apple login - $details';
      case 'logout_error':
        return '${l10n.error}: Logout - $details';
      case 'delete_account_error':
        return '${l10n.error}: ${l10n.deleteAccount} - $details';
      default:
        return errorCode;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.profile)),
      body: SingleChildScrollView(
        child: Consumer<AuthProvider>(
          builder: (context, authProvider, child) {
            final user = authProvider.user;
            final isAuthenticated = authProvider.isAuthenticated;

            if (isAuthenticated && user != null) {
              return _buildAuthenticatedProfile(context, authProvider, user);
            } else {
              return _buildGuestProfile(context, authProvider);
            }
          },
        ),
      ),
    );
  }

  Widget _buildAuthenticatedProfile(
    BuildContext context,
    AuthProvider authProvider,
    dynamic user,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Avatar e info utente
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: user.photoURL != null
                        ? NetworkImage(user.photoURL!)
                        : null,
                    child: user.photoURL == null
                        ? Text(
                            user.displayName?.substring(0, 1).toUpperCase() ??
                                user.email?.substring(0, 1).toUpperCase() ??
                                'U',
                            style: const TextStyle(fontSize: 32),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Nome
                  if (user.displayName != null)
                    Text(
                      user.displayName!,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  // Email
                  if (user.email != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      user.email!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sezione Passaporto dei Rifugi
          Consumer<PassaportoProvider>(
            builder: (context, passaportoProvider, child) {
              final rifugiVisitati =
                  passaportoProvider.checkInsByRifugio.length;
              return Card(
                child: ListTile(
                  leading: Icon(
                    Icons.card_travel,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  title: Text(AppLocalizations.of(context)!.passaportoRifugi),
                  subtitle: Text(
                    AppLocalizations.of(
                      context,
                    )!.nRifugiVisitati(rifugiVisitati),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PassaportoScreen(),
                      ),
                    );
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Sezione Preferiti
          Consumer2<PreferitiProvider, RifugiProvider>(
            builder: (context, preferitiProvider, rifugiProvider, child) {
              final preferiti = preferitiProvider.preferiti;
              final rifugiPreferiti = rifugiProvider.rifugi
                  .where((r) => preferiti.contains(r.id))
                  .toList();

              return Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.star, color: Colors.amber[700]),
                      title: Text(
                        AppLocalizations.of(context)!.rifugiPreferiti,
                      ),
                      subtitle: Text(
                        AppLocalizations.of(context)!.nRifugi(preferiti.length),
                      ),
                      trailing: preferiti.isEmpty
                          ? null
                          : Icon(
                              Icons.chevron_right,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                    ),
                    if (rifugiPreferiti.isNotEmpty) ...[
                      const Divider(height: 1),
                      ...rifugiPreferiti
                          .take(3)
                          .map(
                            (rifugio) => ListTile(
                              dense: true,
                              leading: Icon(
                                rifugio.tipo == 'rifugio'
                                    ? Icons.home
                                    : rifugio.tipo == 'bivacco'
                                    ? Icons.cabin
                                    : Icons.cottage,
                                color: Theme.of(context).colorScheme.primary,
                                size: 20,
                              ),
                              title: Text(
                                rifugio.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: rifugio.altitudine != null
                                  ? Text('${rifugio.altitudine!.toInt()} m')
                                  : null,
                              trailing: Icon(
                                Icons.chevron_right,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                                size: 20,
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        DettaglioRifugioScreen(
                                          rifugio: rifugio,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                      if (rifugiPreferiti.length > 3)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            AppLocalizations.of(
                              context,
                            )!.andOthers(rifugiPreferiti.length - 3),
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ] else if (preferiti.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          AppLocalizations.of(context)!.noPreferiti,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),

          // Sezione Itinerari (future implementazioni)
          Card(
            child: ListTile(
              leading: Icon(
                Icons.route,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: Text(AppLocalizations.of(context)!.myItineraries),
              subtitle: Text(AppLocalizations.of(context)!.comingSoon),
              trailing: const Icon(Icons.lock_outline),
              enabled: false,
            ),
          ),
          const SizedBox(height: 24),

          // Logout
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: authProvider.isLoading
                  ? null
                  : () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            AppLocalizations.of(context)!.confirmLogout,
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.confirmLogoutMessage,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text(AppLocalizations.of(context)!.logout),
                            ),
                          ],
                        ),
                      );

                      if (shouldLogout == true) {
                        await authProvider.signOut();
                      }
                    },
              icon: const Icon(Icons.logout),
              label: authProvider.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(AppLocalizations.of(context)!.logout),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Elimina account
          TextButton.icon(
            onPressed: authProvider.isLoading
                ? null
                : () async {
                    final shouldDelete = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(
                          AppLocalizations.of(context)!.confirmDeleteAccount,
                        ),
                        content: Text(
                          AppLocalizations.of(
                            context,
                          )!.confirmDeleteAccountMessage,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(AppLocalizations.of(context)!.cancel),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            child: Text(AppLocalizations.of(context)!.delete),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final success = await authProvider.deleteAccount();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppLocalizations.of(context)!.accountDeleted,
                            ),
                          ),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.delete_forever),
            label: Text(AppLocalizations.of(context)!.deleteAccount),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuestProfile(BuildContext context, AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Messaggio per utenti non loggati
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.person_outline,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    AppLocalizations.of(context)!.loginToAccount,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.loginDescription,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bottoni di login
          if (authProvider.isLoading)
            const CircularProgressIndicator()
          else ...[
            // Google Sign In
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.signInWithGoogle();
                },
                icon: Image.asset(
                  'assets/images/google_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata, size: 24),
                ),
                label: Text(
                  AppLocalizations.of(context)!.continueWithGoogle,
                  style: const TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Apple Sign In (solo su iOS/macOS)
            FutureBuilder<bool>(
              future: authProvider.isAppleSignInAvailable(),
              builder: (context, snapshot) {
                if (snapshot.data == true) {
                  return Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await authProvider.signInWithApple();
                          },
                          icon: const Icon(Icons.apple, size: 24),
                          label: Text(
                            AppLocalizations.of(context)!.continueWithApple,
                            style: const TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],

          // Messaggio di errore
          if (authProvider.errorMessage != null) ...[
            const SizedBox(height: 16),
            Text(
              _resolveAuthError(context, authProvider.errorMessage!),
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),

          // Info sull'utilizzo senza account
          Card(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.continueWithoutAccount,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
