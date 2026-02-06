import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import '../providers/rifugi_provider.dart';
import 'passaporto_screen.dart';
import 'dettaglio_rifugio_screen.dart';

class ProfiloScreen extends StatelessWidget {
  const ProfiloScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profilo')),
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
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
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
                  title: const Text('Passaporto dei Rifugi'),
                  subtitle: Text(
                    '$rifugiVisitati ${rifugiVisitati == 1 ? 'rifugio visitato' : 'rifugi visitati'}',
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
                      title: const Text('Rifugi Preferiti'),
                      subtitle: Text(
                        '${preferiti.length} ${preferiti.length == 1 ? 'rifugio' : 'rifugi'}',
                      ),
                      trailing: preferiti.isEmpty
                          ? null
                          : Icon(Icons.chevron_right, color: Colors.grey[400]),
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
                                color: Colors.grey[400],
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
                            'e altri ${rifugiPreferiti.length - 3}...',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                    ] else if (preferiti.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Nessun rifugio preferito.\nAggiungi i tuoi preferiti dalla lista!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
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
              title: const Text('I Miei Itinerari'),
              subtitle: const Text('Prossimamente disponibile'),
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
                          title: const Text('Conferma Logout'),
                          content: const Text(
                            'Vuoi disconnetterti dal tuo account?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Annulla'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Logout'),
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
                  : const Text('Logout'),
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
                        title: const Text('Elimina Account'),
                        content: const Text(
                          'Sei sicuro di voler eliminare il tuo account? '
                          'Questa azione è irreversibile e perderai tutti i tuoi dati.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Annulla'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.error,
                            ),
                            child: const Text('Elimina'),
                          ),
                        ],
                      ),
                    );

                    if (shouldDelete == true) {
                      final success = await authProvider.deleteAccount();
                      if (success && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Account eliminato con successo'),
                          ),
                        );
                      }
                    }
                  },
            icon: const Icon(Icons.delete_forever),
            label: const Text('Elimina Account'),
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
                  const Text(
                    'Accedi al tuo account',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Accedi per salvare i tuoi rifugi preferiti, '
                    'tenere traccia delle tue visite e sincronizzare i dati tra dispositivi.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
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
                label: const Text(
                  'Accedi con Google',
                  style: TextStyle(fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[300]!),
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
                          label: const Text(
                            'Accedi con Apple',
                            style: TextStyle(fontSize: 16),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: BorderSide(color: Colors.grey[300]!),
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
              authProvider.errorMessage!,
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
            color: Colors.blue[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Puoi continuare ad usare l\'app anche senza effettuare il login.',
                      style: TextStyle(fontSize: 14, color: Colors.blue[900]),
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
