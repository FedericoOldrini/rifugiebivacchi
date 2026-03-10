import 'package:flutter/material.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import 'lista_rifugi_screen.dart';
import 'mappa_rifugi_screen.dart';

enum ExploraView { lista, mappa }

class ExploraScreen extends StatefulWidget {
  const ExploraScreen({super.key});

  @override
  State<ExploraScreen> createState() => _ExploraScreenState();
}

class _ExploraScreenState extends State<ExploraScreen> {
  ExploraView _currentView = ExploraView.lista;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        // Toggle Lista / Mappa
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SegmentedButton<ExploraView>(
            segments: [
              ButtonSegment<ExploraView>(
                value: ExploraView.lista,
                label: Text(l10n.tabList),
                icon: const Icon(Icons.list, size: 18),
              ),
              ButtonSegment<ExploraView>(
                value: ExploraView.mappa,
                label: Text(l10n.tabMap),
                icon: const Icon(Icons.map, size: 18),
              ),
            ],
            selected: {_currentView},
            onSelectionChanged: (Set<ExploraView> selected) {
              setState(() {
                _currentView = selected.first;
              });
            },
            showSelectedIcon: false,
          ),
        ),
        // Contenuto: Lista o Mappa
        Expanded(
          child: _currentView == ExploraView.lista
              ? const ListaRifugiScreen()
              : const MappaRifugiScreen(),
        ),
      ],
    );
  }
}
