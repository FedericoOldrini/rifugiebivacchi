import 'package:flutter/material.dart';
import 'donations_screen.dart';
import '../services/onboarding_service.dart';
import 'onboarding_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Impostazioni'),
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Informazioni App',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Versione'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Informazioni'),
            subtitle: const Text('Rifugi e Bivacchi - App per escursionisti'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Rifugi e Bivacchi',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(
                  Icons.landscape,
                  size: 48,
                  color: Color(0xFF2D5016),
                ),
                children: [
                  const Text(
                    'App per visualizzare rifugi e bivacchi di montagna nelle Alpi italiane. '
                    'Utilizza la mappa per trovare i rifugi vicino a te o cerca per nome.',
                  ),
                ],
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Privacy e Permessi',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.location_on_outlined),
            title: const Text('Permessi posizione'),
            subtitle: const Text('Gestisci i permessi di accesso alla posizione'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Permessi Posizione'),
                  content: const Text(
                    'L\'app richiede l\'accesso alla tua posizione per mostrarti '
                    'i rifugi nelle vicinanze sulla mappa. Puoi modificare i '
                    'permessi nelle impostazioni del sistema.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy'),
            subtitle: const Text('La tua posizione non viene memorizzata'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Privacy'),
                  content: const Text(
                    'Questa app non memorizza né condivide la tua posizione. '
                    'I dati di localizzazione vengono utilizzati solo per '
                    'mostrare la mappa centrata sulla tua posizione corrente.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Aiuto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.help_outline),
            title: const Text('Rivedi introduzione'),
            subtitle: const Text('Visualizza di nuovo l\'onboarding iniziale'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              await OnboardingService.resetOnboarding();
              
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => const OnboardingScreen(),
                  ),
                );
              }
            },
          ),
          const Divider(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Supporta il Progetto',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outlined, color: Colors.red),
            title: const Text('Supportaci'),
            subtitle: const Text('Fai una donazione per supportare lo sviluppo'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DonationsScreen(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.star_outline),
            title: const Text('Valuta l\'app'),
            subtitle: const Text('Lascia una recensione sullo store'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Grazie per il tuo supporto!'),
                ),
              );
            },
          ),
          const SizedBox(height: 32),
          Center(
            child: Text(
              'Made with ❤️ for mountain lovers',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
