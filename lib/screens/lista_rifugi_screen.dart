import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/rifugi_provider.dart';
import '../providers/preferiti_provider.dart';
import '../providers/filtro_provider.dart';
import '../widgets/rifugio_card.dart';
import '../screens/dettaglio_rifugio_screen.dart';

class ListaRifugiScreen extends StatefulWidget {
  const ListaRifugiScreen({super.key});

  @override
  State<ListaRifugiScreen> createState() => _ListaRifugiScreenState();
}

class _ListaRifugiScreenState extends State<ListaRifugiScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RifugiProvider>(
      builder: (context, rifugiProvider, child) {
        return Column(
          children: [
            // Indicatore di sincronizzazione
            if (rifugiProvider.isSyncing)
              Container(
                color: Colors.blue.shade50,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.blue.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Sincronizzazione con Firebase...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            // Barra di ricerca
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cerca rifugi o bivacchi...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                context.read<RifugiProvider>().clearSearch();
                              },
                            )
                          : null,
                    ),
                    onChanged: (value) {
                      context.read<RifugiProvider>().search(value);
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
        // Lista rifugi
        Expanded(
          child: Consumer3<RifugiProvider, PreferitiProvider, FiltroProvider>(
            builder: (context, provider, preferitiProvider, filtroProvider, child) {
              // Mostra loading
              if (provider.isLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Caricamento rifugi...'),
                    ],
                  ),
                );
              }

              // Mostra errore
              if (provider.errorMessage != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Errore',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          provider.errorMessage!,
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
              }

              // Filtra per preferiti se necessario
              var rifugi = provider.rifugi;
              if (filtroProvider.soloPreferiti) {
                rifugi = rifugi
                    .where((r) => preferitiProvider.isPreferito(r.id))
                    .toList();
              }

              if (rifugi.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        filtroProvider.soloPreferiti ? Icons.star_border : Icons.search_off,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        filtroProvider.soloPreferiti 
                            ? 'Nessun rifugio preferito'
                            : 'Nessun rifugio trovato',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      if (provider.searchQuery.isNotEmpty ||
                          filtroProvider.soloPreferiti) ...[
                        const SizedBox(height: 8),
                        Text(
                          filtroProvider.soloPreferiti
                              ? 'Aggiungi dei rifugi ai preferiti'
                              : 'Prova a modificare la ricerca',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: rifugi.length,
                itemBuilder: (context, index) {
                  final rifugio = rifugi[index];
                  return RifugioCard(
                    rifugio: rifugio,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              DettaglioRifugioScreen(rifugio: rifugio),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ],
    );
      },
    );
  }
}
