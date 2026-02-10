import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/rifugio.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/preferiti_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/share_checkin_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/image_gallery.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

class DettaglioRifugioScreen extends StatefulWidget {
  final Rifugio rifugio;

  const DettaglioRifugioScreen({super.key, required this.rifugio});

  @override
  State<DettaglioRifugioScreen> createState() => _DettaglioRifugioScreenState();
}

class _DettaglioRifugioScreenState extends State<DettaglioRifugioScreen> {
  GoogleMapController? _mapController;
  bool _hasVisited = false;
  bool _isCheckingIn = false;
  final ScreenshotController _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
    _checkIfVisited();
  }

  Future<void> _checkIfVisited() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final passaportoProvider = Provider.of<PassaportoProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
      // Verifica se c'è almeno una visita
      final visitCount = passaportoProvider.getVisitCount(widget.rifugio.id);
      if (mounted) {
        setState(() {
          _hasVisited = visitCount > 0;
        });
      }
    }
  }

  Future<void> _doCheckIn() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final passaportoProvider = Provider.of<PassaportoProvider>(
      context,
      listen: false,
    );

    if (authProvider.user == null) return;

    setState(() {
      _isCheckingIn = true;
    });

    final success = await passaportoProvider.checkInRifugio(
      authProvider.user!.uid,
      widget.rifugio,
    );

    setState(() {
      _isCheckingIn = false;
    });

    if (mounted) {
      if (success) {
        setState(() {
          _hasVisited = true;
        });

        // Mostra dialog di condivisione
        _showShareDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    passaportoProvider.error ??
                        AppLocalizations.of(context)!.nearRifugioRequired,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'gen',
      'feb',
      'mar',
      'apr',
      'mag',
      'giu',
      'lug',
      'ago',
      'set',
      'ott',
      'nov',
      'dic',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _showShareDialog() {
    final passaportoProvider = Provider.of<PassaportoProvider>(
      context,
      listen: false,
    );
    final visitCount = passaportoProvider.getVisitCount(widget.rifugio.id);

    showDialog(
      context: context,
      builder: (context) =>
          _ShareDialog(visitCount: visitCount, onShare: _shareCheckIn),
    );
  }

  Future<void> _shareCheckIn() async {
    try {
      final imageBytes = await _screenshotController.captureFromWidget(
        _buildShareCard(),
        delay: const Duration(milliseconds: 100),
      );

      if (imageBytes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context)!.imageGenerationError),
            ),
          );
        }
        return;
      }

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/checkin_${DateTime.now().millisecondsSinceEpoch}.png';

      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(imageBytes);

      final passaportoProvider = Provider.of<PassaportoProvider>(
        context,
        listen: false,
      );
      final visitCount = passaportoProvider.getVisitCount(widget.rifugio.id);

      final shareText = AppLocalizations.of(context)!.checkInShareText(widget.rifugio.nome, visitCount);

      final size = MediaQuery.of(context).size;
      final sharePositionOrigin = Rect.fromLTWH(
        size.width / 2 - 50,
        size.height / 2 - 50,
        100,
        100,
      );

      await Share.shareXFiles(
        [XFile(imagePath)],
        text: shareText,
        sharePositionOrigin: sharePositionOrigin,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.shareError(e.toString())),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Widget _buildShareCard() {
    final passaportoProvider = Provider.of<PassaportoProvider>(
      context,
      listen: false,
    );
    final visitCount = passaportoProvider.getVisitCount(widget.rifugio.id);

    return ShareCheckinCard.fromRifugio(
      rifugioNome: widget.rifugio.nome,
      rifugioImmagine: widget.rifugio.immagine,
      altitudine: widget.rifugio.altitudine,
      visitCount: visitCount,
      dataCheckin: DateTime.now(),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  String _buildMarkerSnippet() {
    final parts = <String>[];

    // Tipo
    final tipo = widget.rifugio.tipo == 'rifugio'
        ? AppLocalizations.of(context)!.rifugio
        : widget.rifugio.tipo == 'bivacco'
        ? AppLocalizations.of(context)!.bivacco
        : AppLocalizations.of(context)!.malga;
    parts.add(tipo);

    // Altitudine
    if (widget.rifugio.altitudine != null) {
      parts.add('${widget.rifugio.altitudine!.toInt()} m s.l.m.');
    }

    // Posti letto
    if (widget.rifugio.postiLetto != null && widget.rifugio.postiLetto! > 0) {
      parts.add('🛏️ ${widget.rifugio.postiLetto} posti');
    }

    return parts.join(' • ');
  }

  Set<Marker> _createMarker() {
    // Colori uniformi allo stile dell'app
    final hue = widget.rifugio.tipo == 'rifugio'
        ? BitmapDescriptor
              .hueAzure // Blu per rifugi
        : widget.rifugio.tipo == 'bivacco'
        ? BitmapDescriptor
              .hueOrange // Arancione per bivacchi
        : BitmapDescriptor.hueGreen; // Verde per malghe

    return {
      Marker(
        markerId: MarkerId(widget.rifugio.id),
        position: LatLng(widget.rifugio.latitudine, widget.rifugio.longitudine),
        infoWindow: InfoWindow(
          title: widget.rifugio.nome,
          snippet: _buildMarkerSnippet(),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
      ),
    };
  }

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchMaps(double lat, double lng) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildMap() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(
              widget.rifugio.latitudine,
              widget.rifugio.longitudine,
            ),
            zoom: 13,
          ),
          markers: _createMarker(),
          onMapCreated: (controller) {
            _mapController = controller;
          },
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final preferitiProvider = Provider.of<PreferitiProvider>(context);
    final isPreferito = preferitiProvider.isPreferito(widget.rifugio.id);

    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                foregroundColor: Colors.white,
                actions: [
                  // Pulsante preferito
                  if (authProvider.user != null)
                    IconButton(
                      icon: Icon(
                        isPreferito ? Icons.star : Icons.star_border,
                        color: isPreferito ? Colors.amber[700] : Colors.white,
                      ),
                      onPressed: () async {
                        await preferitiProvider.togglePreferito(
                          authProvider.user!.uid,
                          widget.rifugio.id,
                        );

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(
                                    isPreferito
                                        ? Icons.star_border
                                        : Icons.star,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      isPreferito
                                          ? AppLocalizations.of(context)!.removedFromFavorites
                                          : AppLocalizations.of(context)!.addedToFavorites,
                                    ),
                                  ),
                                ],
                              ),
                              duration: const Duration(seconds: 2),
                              backgroundColor: isPreferito
                                  ? Colors.grey[700]
                                  : Colors.amber[700],
                            ),
                          );
                        }
                      },
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    widget.rifugio.nome,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  background:
                      widget.rifugio.immagine != null &&
                          widget.rifugio.immagine!.isNotEmpty
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: widget.rifugio.immagine!,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(
                                        context,
                                      ).colorScheme.secondary.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) {
                                return Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Theme.of(context).colorScheme.primary,
                                        Theme.of(context).colorScheme.secondary,
                                      ],
                                    ),
                                  ),
                                  child: Icon(
                                    widget.rifugio.tipo == 'rifugio'
                                        ? Icons.home
                                        : Icons.cabin,
                                    size: 80,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                                );
                              },
                            ),
                            // Scrim gradient per leggibilità (Material You)
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.3),
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.6),
                                  ],
                                  stops: const [0.0, 0.4, 1.0],
                                ),
                              ),
                            ),
                          ],
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: Icon(
                            widget.rifugio.tipo == 'rifugio'
                                ? Icons.home
                                : Icons.cabin,
                            size: 80,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tipo rifugio e stato
                      Row(
                        children: [
                          Chip(
                            avatar: Icon(
                              _getIconForType(widget.rifugio.tipo),
                              size: 18,
                            ),
                            label: Text(_getLabelForType(widget.rifugio.tipo)),
                          ),
                          if (widget.rifugio.status != null) ...[
                            const SizedBox(width: 8),
                            Chip(
                              label: Text(widget.rifugio.status!),
                              backgroundColor:
                                  widget.rifugio.status == 'In attività'
                                  ? Colors.green[100]
                                  : Colors.orange[100],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Mappa
                      _buildMap(),
                      const SizedBox(height: 16),

                      // Previsioni Meteo
                      WeatherWidget(
                        latitude: widget.rifugio.latitudine,
                        longitude: widget.rifugio.longitudine,
                      ),
                      const SizedBox(height: 16),

                      // Galleria immagini
                      if (widget.rifugio.imageUrls != null &&
                          widget.rifugio.imageUrls!.isNotEmpty)
                        ...[                        
                          ImageGallery(
                            imageUrls: widget.rifugio.imageUrls!,
                            rifugioName: widget.rifugio.nome,
                          ),
                          const SizedBox(height: 16),
                        ],

                      // Pulsante Check-in (per utenti loggati)
                      Consumer2<AuthProvider, PassaportoProvider>(
                        builder: (context, authProvider, passaportoProvider, child) {
                          final isAuthenticated = authProvider.isAuthenticated;

                          if (isAuthenticated) {
                            final visitCount = passaportoProvider.getVisitCount(
                              widget.rifugio.id,
                            );
                            final hasCheckedInToday = passaportoProvider
                                .hasCheckedInToday(widget.rifugio.id);
                            final firstVisit = passaportoProvider.getFirstVisit(
                              widget.rifugio.id,
                            );
                            final lastVisit = passaportoProvider.getLastVisit(
                              widget.rifugio.id,
                            );

                            return Column(
                              children: [
                                if (_hasVisited)
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.green[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.green[200]!,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green[700],
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                visitCount == 1
                                                    ? AppLocalizations.of(context)!.visitedOnce
                                                    : AppLocalizations.of(context)!.visitedMultiple(visitCount),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (firstVisit != null) ...[
                                          const SizedBox(height: 8),
                                          Text(
                                            AppLocalizations.of(context)!.firstVisit(_formatDate(firstVisit)),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          if (visitCount > 1 &&
                                              lastVisit != null)
                                            Text(
                                              AppLocalizations.of(context)!.lastVisit(_formatDate(lastVisit)),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                        ],
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),
                                if (!hasCheckedInToday)
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _isCheckingIn
                                          ? null
                                          : _doCheckIn,
                                      icon: _isCheckingIn
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                      Color
                                                    >(Colors.white),
                                              ),
                                            )
                                          : const Icon(Icons.location_on),
                                      label: Text(
                                        _isCheckingIn
                                            ? AppLocalizations.of(context)!.checkInProgress
                                            : _hasVisited
                                            ? AppLocalizations.of(context)!.checkInAgain
                                            : AppLocalizations.of(context)!.checkIn,
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        backgroundColor: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                    ),
                                  )
                                else ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.orange[50],
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.orange[200]!,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.info_outline,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            AppLocalizations.of(context)!.checkInAlreadyToday,
                                            style: TextStyle(fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.of(context)!.checkInRadius,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 16),
                              ],
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),

                      // Descrizione
                      if (widget.rifugio.descrizione != null &&
                          widget.rifugio.descrizione!.isNotEmpty) ...[
                        Text(
                          widget.rifugio.descrizione!,
                          style: const TextStyle(fontSize: 16, height: 1.5),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Descrizione del sito
                      if (widget.rifugio.siteDescription != null &&
                          widget.rifugio.siteDescription!.isNotEmpty) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      AppLocalizations.of(context)!.position,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  widget.rifugio.siteDescription!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Informazioni principali
                      _SectionTitle(title: AppLocalizations.of(context)!.informazioni),
                      const SizedBox(height: 12),
                      if (widget.rifugio.altitudine != null)
                        _InfoRow(
                          icon: Icons.terrain,
                          label: AppLocalizations.of(context)!.altitude,
                          value:
                              '${widget.rifugio.altitudine!.toInt()} m s.l.m.',
                        ),
                      if (widget.rifugio.locality != null)
                        _InfoRow(
                          icon: Icons.location_city,
                          label: AppLocalizations.of(context)!.locality,
                          value: widget.rifugio.locality!,
                        ),
                      if (widget.rifugio.municipality != null)
                        _InfoRow(
                          icon: Icons.business,
                          label: AppLocalizations.of(context)!.municipality,
                          value: widget.rifugio.municipality!,
                        ),
                      if (widget.rifugio.valley != null)
                        _InfoRow(
                          icon: Icons.landscape,
                          label: AppLocalizations.of(context)!.valley,
                          value: widget.rifugio.valley!,
                        ),
                      if (widget.rifugio.region != null)
                        _InfoRow(
                          icon: Icons.map,
                          label: AppLocalizations.of(context)!.region,
                          value:
                              '${widget.rifugio.region!}${widget.rifugio.province != null ? ' (${widget.rifugio.province})' : ''}',
                        ),
                      if (widget.rifugio.buildYear != null)
                        _InfoRow(
                          icon: Icons.calendar_today,
                          label: AppLocalizations.of(context)!.buildYear,
                          value: widget.rifugio.buildYear.toString(),
                        ),
                      _InfoRow(
                        icon: Icons.location_on,
                        label: AppLocalizations.of(context)!.coordinates,
                        value:
                            '${widget.rifugio.latitudine.toStringAsFixed(4)}, ${widget.rifugio.longitudine.toStringAsFixed(4)}',
                      ),
                      const SizedBox(height: 24),

                      // Servizi
                      if (_hasServices()) ...[
                        _SectionTitle(title: AppLocalizations.of(context)!.services),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                if (widget.rifugio.postiLetto != null &&
                                    widget.rifugio.postiLetto! > 0)
                                  _ServiceChip(
                                    icon: Icons.bed,
                                    label:
                                        AppLocalizations.of(context)!.bedsCount(widget.rifugio.postiLetto!),
                                  ),
                                if (widget.rifugio.ristorante == true)
                                  _ServiceChip(
                                    icon: Icons.restaurant,
                                    label:
                                        widget.rifugio.restaurantSeats != null
                                        ? AppLocalizations.of(context)!.restaurantWithSeats(widget.rifugio.restaurantSeats!)
                                        : AppLocalizations.of(context)!.restaurant,
                                  ),
                                if (widget.rifugio.wifi == true)
                                  _ServiceChip(icon: Icons.wifi, label: AppLocalizations.of(context)!.wifi),
                                if (widget.rifugio.elettricita == true)
                                  _ServiceChip(
                                    icon: Icons.electrical_services,
                                    label: AppLocalizations.of(context)!.electricity,
                                  ),
                                if (widget.rifugio.pagamentoPos == true)
                                  _ServiceChip(
                                    icon: Icons.credit_card,
                                    label: AppLocalizations.of(context)!.pos,
                                  ),
                                if (widget.rifugio.defibrillatore == true)
                                  _ServiceChip(
                                    icon: Icons.favorite,
                                    label: AppLocalizations.of(context)!.defibrillator,
                                  ),
                                if (widget.rifugio.hotWater == true)
                                  _ServiceChip(
                                    icon: Icons.hot_tub,
                                    label: AppLocalizations.of(context)!.hotWater,
                                  ),
                                if (widget.rifugio.showers == true)
                                  _ServiceChip(
                                    icon: Icons.shower,
                                    label: AppLocalizations.of(context)!.showers,
                                  ),
                                if (widget.rifugio.insideWater == true)
                                  _ServiceChip(
                                    icon: Icons.water_drop,
                                    label: AppLocalizations.of(context)!.insideWater,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Accessibilità
                      if (_hasAccessibility()) ...[
                        _SectionTitle(title: AppLocalizations.of(context)!.accessibility),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Wrap(
                              spacing: 16,
                              runSpacing: 16,
                              children: [
                                if (widget.rifugio.carAccess == true)
                                  _ServiceChip(
                                    icon: Icons.directions_car,
                                    label: AppLocalizations.of(context)!.car,
                                  ),
                                if (widget.rifugio.mountainBikeAccess == true)
                                  _ServiceChip(
                                    icon: Icons.pedal_bike,
                                    label: AppLocalizations.of(context)!.mtb,
                                  ),
                                if (widget.rifugio.disabledAccess == true)
                                  _ServiceChip(
                                    icon: Icons.accessible,
                                    label: AppLocalizations.of(context)!.disabled,
                                  ),
                                if (widget.rifugio.disabledWc == true)
                                  _ServiceChip(
                                    icon: Icons.wc,
                                    label: AppLocalizations.of(context)!.disabledWc,
                                  ),
                                if (widget.rifugio.familiesChildrenAccess ==
                                    true)
                                  _ServiceChip(
                                    icon: Icons.family_restroom,
                                    label: AppLocalizations.of(context)!.families,
                                  ),
                                if (widget.rifugio.petAccess == true)
                                  _ServiceChip(
                                    icon: Icons.pets,
                                    label: AppLocalizations.of(context)!.pets,
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Gestione
                      if (widget.rifugio.propertyName != null ||
                          widget.rifugio.owner != null) ...[
                        _SectionTitle(title: AppLocalizations.of(context)!.management),
                        const SizedBox(height: 12),
                        if (widget.rifugio.propertyName != null)
                          _InfoRow(
                            icon: Icons.business,
                            label: AppLocalizations.of(context)!.manager,
                            value: widget.rifugio.propertyName!,
                          ),
                        if (widget.rifugio.owner != null)
                          _InfoRow(
                            icon: Icons.account_balance,
                            label: AppLocalizations.of(context)!.property,
                            value: widget.rifugio.owner!,
                          ),
                        if (widget.rifugio.regionalType != null)
                          _InfoRow(
                            icon: Icons.category,
                            label: AppLocalizations.of(context)!.type,
                            value: widget.rifugio.regionalType!,
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Contatti
                      if (widget.rifugio.telefono != null ||
                          widget.rifugio.email != null ||
                          widget.rifugio.sitoWeb != null) ...[
                        _SectionTitle(title: AppLocalizations.of(context)!.contacts),
                        const SizedBox(height: 12),
                        if (widget.rifugio.telefono != null)
                          _ContactButton(
                            icon: Icons.phone,
                            label: widget.rifugio.telefono!,
                            onTap: () => _launchPhone(widget.rifugio.telefono!),
                          ),
                        if (widget.rifugio.email != null)
                          _ContactButton(
                            icon: Icons.email,
                            label: widget.rifugio.email!,
                            onTap: () => _launchEmail(widget.rifugio.email!),
                          ),
                        if (widget.rifugio.sitoWeb != null)
                          _ContactButton(
                            icon: Icons.language,
                            label: AppLocalizations.of(context)!.website,
                            onTap: () => _launchUrl(widget.rifugio.sitoWeb!),
                          ),
                        const SizedBox(height: 24),
                      ],

                      // Pulsante navigazione
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _launchMaps(
                            widget.rifugio.latitudine,
                            widget.rifugio.longitudine,
                          ),
                          icon: const Icon(Icons.directions),
                          label: Text(AppLocalizations.of(context)!.openInGoogleMaps),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pulsante donazioni
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/donations');
                          },
                          icon: const Icon(Icons.favorite),
                          label: Text(AppLocalizations.of(context)!.supportDevelopment),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.pink[700],
                            side: BorderSide(color: Colors.pink[700]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return Icons.cabin;
      case 'malga':
        return Icons.cottage;
      case 'rifugio':
      default:
        return Icons.home;
    }
  }

  String _getLabelForType(String tipo) {
    switch (tipo.toLowerCase()) {
      case 'bivacco':
        return AppLocalizations.of(context)!.bivacco;
      case 'malga':
        return AppLocalizations.of(context)!.malga;
      case 'rifugio':
      default:
        return AppLocalizations.of(context)!.rifugio;
    }
  }

  bool _hasServices() {
    return widget.rifugio.postiLetto != null ||
        widget.rifugio.ristorante == true ||
        widget.rifugio.wifi == true ||
        widget.rifugio.elettricita == true ||
        widget.rifugio.pagamentoPos == true ||
        widget.rifugio.defibrillatore == true ||
        widget.rifugio.hotWater == true ||
        widget.rifugio.showers == true ||
        widget.rifugio.insideWater == true;
  }

  bool _hasAccessibility() {
    return widget.rifugio.carAccess == true ||
        widget.rifugio.mountainBikeAccess == true ||
        widget.rifugio.disabledAccess == true ||
        widget.rifugio.disabledWc == true ||
        widget.rifugio.familiesChildrenAccess == true ||
        widget.rifugio.petAccess == true;
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 12),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        Text(value, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(label, style: const TextStyle(fontSize: 14)),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}

// Dialog per condivisione con input hashtag personalizzati
class _ShareDialog extends StatelessWidget {
  final int visitCount;
  final VoidCallback onShare;

  const _ShareDialog({required this.visitCount, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.deepTeal.withOpacity(0.95),
              AppTheme.deepTeal.withGreen(120).withOpacity(0.95),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header con icona animata
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.check_circle,
                        color: Colors.green[700],
                        size: 48,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.checkInDone,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Contenuto
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          if (visitCount > 1) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    AppLocalizations.of(context)!.visitNumber(visitCount),
                                    style: TextStyle(
                                      color: AppTheme.deepTeal,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.congratsVisit(visitCount),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ] else ...[
                            const Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              AppLocalizations.of(context)!.firstTimeWelcome,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      AppLocalizations.of(context)!.shareCheckIn,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              // Pulsanti
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.close,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          onShare();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: AppTheme.deepTeal,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.share),
                        label: Text(
                          AppLocalizations.of(context)!.share,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
