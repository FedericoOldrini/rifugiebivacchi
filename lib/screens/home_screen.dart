import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../screens/lista_rifugi_screen.dart';
import '../screens/mappa_rifugi_screen.dart';
import '../screens/profilo_screen.dart';
import '../screens/settings_screen.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import '../providers/filtro_provider.dart';
import '../widgets/filtri_sheet.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.landscape, size: 28),
            const SizedBox(width: 8),
            Text(l10n.appTitle),
          ],
        ),
        actions: [
          // Pulsante filtri avanzati (visibile solo nella tab Lista e Mappa)
          if (_currentIndex == 0 || _currentIndex == 1)
            Consumer<FiltroProvider>(
              builder: (context, filtroProvider, child) {
                final count = filtroProvider.activeFilterCount;
                return IconButton(
                  icon: Badge(
                    isLabelVisible: count > 0,
                    label: Text('$count'),
                    child: Icon(
                      filtroProvider.hasActiveFilters
                          ? Icons.filter_list
                          : Icons.filter_list_outlined,
                    ),
                  ),
                  tooltip: l10n.filtersTitle,
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      builder: (_) => const FiltriSheet(),
                    );
                  },
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n.settings,
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
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.list_outlined),
            selectedIcon: const Icon(Icons.list),
            label: l10n.tabList,
          ),
          NavigationDestination(
            icon: const Icon(Icons.map_outlined),
            selectedIcon: const Icon(Icons.map),
            label: l10n.tabMap,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: l10n.tabProfile,
          ),
        ],
      ),
    );
  }
}
