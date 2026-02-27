import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/rifugio.dart';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../widgets/share_checkin_card.dart';
import '../widgets/weather_widget.dart';
import '../widgets/image_gallery.dart';
import '../widgets/dettaglio/header_section.dart';
import '../widgets/dettaglio/map_section.dart';
import '../widgets/dettaglio/checkin_section.dart';
import '../widgets/dettaglio/description_section.dart';
import '../widgets/dettaglio/info_section.dart';
import '../widgets/dettaglio/services_section.dart';
import '../widgets/dettaglio/contacts_section.dart';
import '../widgets/dettaglio/share_dialog.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';
import '../services/analytics_service.dart';

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
    AnalyticsService.instance.logViewRifugio(
      rifugioId: widget.rifugio.id,
      rifugioNome: widget.rifugio.nome,
      tipo: widget.rifugio.tipo,
    );
  }

  Future<void> _checkIfVisited() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final passaportoProvider = Provider.of<PassaportoProvider>(
      context,
      listen: false,
    );

    if (authProvider.user != null) {
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
        AnalyticsService.instance.logCheckin(
          rifugioId: widget.rifugio.id,
          rifugioNome: widget.rifugio.nome,
        );
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
          ShareDialog(visitCount: visitCount, onShare: _shareCheckIn),
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

      final shareText = AppLocalizations.of(
        context,
      )!.checkInShareText(widget.rifugio.nome, visitCount);

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
            content: Text(
              AppLocalizations.of(context)!.shareError(e.toString()),
            ),
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          body: CustomScrollView(
            slivers: [
              // Header con immagine hero e pulsante preferito
              HeaderSection(rifugio: widget.rifugio),

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
                      MapSection(
                        rifugio: widget.rifugio,
                        onMapCreated: (controller) {
                          _mapController = controller;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Previsioni Meteo
                      WeatherWidget(
                        latitude: widget.rifugio.latitudine,
                        longitude: widget.rifugio.longitudine,
                      ),
                      const SizedBox(height: 16),

                      // Galleria immagini
                      if (widget.rifugio.imageUrls != null &&
                          widget.rifugio.imageUrls!.isNotEmpty) ...[
                        ImageGallery(
                          imageUrls: widget.rifugio.imageUrls!,
                          rifugioName: widget.rifugio.nome,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Sezione Check-in
                      CheckinSection(
                        rifugio: widget.rifugio,
                        hasVisited: _hasVisited,
                        isCheckingIn: _isCheckingIn,
                        onCheckIn: _doCheckIn,
                        formatDate: _formatDate,
                      ),

                      // Descrizione
                      DescriptionSection(rifugio: widget.rifugio),

                      // Informazioni principali
                      InfoSection(rifugio: widget.rifugio),

                      // Servizi, accessibilità e gestione
                      ServicesSection(rifugio: widget.rifugio),

                      // Contatti e pulsanti azione
                      ContactsSection(rifugio: widget.rifugio),
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
}
