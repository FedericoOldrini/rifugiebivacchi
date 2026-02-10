import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
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

  // Calcola il numero totale di items considerando le card donazioni
  int _calculateTotalItems(int rifugiCount) {
    if (rifugiCount <= 3) return rifugiCount;
    
    // Dopo i primi 3, inserisci una card ogni 6 rifugi
    final afterFirst = rifugiCount - 3;
    final donationCardsAfterFirst = (afterFirst / 6).floor();
    
    return rifugiCount + 1 + donationCardsAfterFirst; // +1 per la prima card dopo i 3 rifugi
  }

  // Determina se in questa posizione va mostrata una card donazioni
  bool _shouldShowDonationCard(int listIndex) {
    // Prima card donazioni dopo il 3° elemento (indice 3)
    if (listIndex == 3) return true;
    
    // Successive card donazioni ogni 6 rifugi
    // Posizioni: 3, 10, 17, 24, ecc.
    if (listIndex > 3 && (listIndex - 3) % 7 == 0) {
      return true;
    }
    
    return false;
  }

  // Ottieni l'indice del rifugio dalla posizione nella lista
  int _getRifugioIndexFromListIndex(int listIndex) {
    if (listIndex < 3) return listIndex;
    
    // Calcola quante card donazioni ci sono prima di questo indice
    int donationCardsBefore = 0;
    if (listIndex >= 3) {
      donationCardsBefore = 1; // Prima card dopo i 3 rifugi
      if (listIndex > 3) {
        donationCardsBefore += ((listIndex - 4) / 7).floor();
      }
    }
    
    return listIndex - donationCardsBefore;
  }

  Widget _buildDonationCard(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.pink[50]!,
              Colors.purple[50]!,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/donations');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.pink.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.favorite,
                    color: Colors.pink[700],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.likeThisApp,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppLocalizations.of(context)!.supportDevelopment,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: Colors.pink[700],
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
                      AppLocalizations.of(context)!.syncingFirebase,
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
                      hintText: AppLocalizations.of(context)!.searchHint,
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
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(AppLocalizations.of(context)!.loadingRifugi),
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
                        AppLocalizations.of(context)!.error,
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
                            ? AppLocalizations.of(context)!.noFavoriteRifugi
                            : AppLocalizations.of(context)!.noRifugiFound,
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                      if (provider.searchQuery.isNotEmpty ||
                          filtroProvider.soloPreferiti) ...[
                        const SizedBox(height: 8),
                        Text(
                          filtroProvider.soloPreferiti
                              ? AppLocalizations.of(context)!.addFavoritesHint
                              : AppLocalizations.of(context)!.modifySearchHint,
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

              // Calcola il numero totale di items (rifugi + card donazioni)
              final totalItems = _calculateTotalItems(rifugi.length);
              
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: totalItems,
                itemBuilder: (context, index) {
                  // Determina se questa posizione dovrebbe essere una card donazioni
                  if (_shouldShowDonationCard(index)) {
                    return _buildDonationCard(context);
                  }
                  
                  // Altrimenti mostra una card rifugio
                  final rifugioIndex = _getRifugioIndexFromListIndex(index);
                  if (rifugioIndex >= rifugi.length) {
                    return const SizedBox.shrink();
                  }
                  
                  final rifugio = rifugi[rifugioIndex];
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
