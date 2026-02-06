import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/lista_rifugi_screen.dart';
import '../screens/mappa_rifugi_screen.dart';
import '../screens/profilo_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import '../providers/filtro_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    ListaRifugiScreen(),
    MappaRifugiScreen(),
    ProfiloScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Carica i dati del passaporto quando l'utente è loggato
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final passaportoProvider = Provider.of<PassaportoProvider>(
        context,
        listen: false,
      );
      final preferitiProvider = Provider.of<PreferitiProvider>(
        context,
        listen: false,
      );

      if (authProvider.user != null) {
        passaportoProvider.loadCheckIns(authProvider.user!.uid);
        preferitiProvider.loadPreferiti(authProvider.user!.uid);
      }

      // Listener per cambi di stato auth
      authProvider.addListener(() {
        if (authProvider.user != null) {
          passaportoProvider.loadCheckIns(authProvider.user!.uid);
          preferitiProvider.loadPreferiti(authProvider.user!.uid);
        } else {
          passaportoProvider.reset();
          preferitiProvider.reset();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.landscape, size: 28),
            SizedBox(width: 8),
            Text('Rifugi e Bivacchi'),
          ],
        ),
        actions: [
          // Pulsante filtro preferiti (visibile solo nella tab Lista)
          if (_currentIndex == 0)
            Consumer2<PreferitiProvider, FiltroProvider>(
              builder: (context, preferitiProvider, filtroProvider, child) {
                if (preferitiProvider.preferiti.isEmpty) {
                  return const SizedBox.shrink();
                }

                return IconButton(
                  icon: Icon(
                    filtroProvider.soloPreferiti ? Icons.star : Icons.star_border,
                    color: filtroProvider.soloPreferiti ? Colors.amber[700] : null,
                  ),
                  tooltip: filtroProvider.soloPreferiti ? 'Mostra tutti' : 'Solo preferiti',
                  onPressed: () {
                    filtroProvider.togglePreferiti();
                  },
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Impostazioni',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_outlined),
            selectedIcon: Icon(Icons.list),
            label: 'Lista',
          ),
          NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Mappa',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profilo',
          ),
        ],
      ),
    );
  }
}
