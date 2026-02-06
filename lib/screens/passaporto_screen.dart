import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:screenshot/screenshot.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../providers/auth_provider.dart';
import '../providers/passaporto_provider.dart';
import '../providers/rifugi_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/share_checkin_card.dart';
import 'dettaglio_rifugio_screen.dart';

class PassaportoScreen extends StatelessWidget {
  const PassaportoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final passaportoProvider = Provider.of<PassaportoProvider>(context);

    if (authProvider.user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passaporto dei Rifugi')),
        body: const Center(
          child: Text('Devi effettuare il login per accedere al passaporto'),
        ),
      );
    }

    final checkIns = passaportoProvider.checkIns;
    final groupedCheckIns = passaportoProvider.checkInsByRifugio;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8), // Colore carta passaporto
      appBar: AppBar(
        title: const Text('Il Mio Passaporto'),
        backgroundColor: AppTheme.deepTeal,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).toInt()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${groupedCheckIns.length} ${groupedCheckIns.length == 1 ? 'rifugio' : 'rifugi'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: checkIns.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.hiking,
                      size: 100,
                      color: AppTheme.deepTeal.withAlpha((0.3 * 255).toInt()),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Nessun timbro ancora',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Visita i rifugi e fai check-in per collezionare i tuoi timbri!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // Pulsante condividi passaporto
                Container(
                  padding: const EdgeInsets.all(16),
                  child: OutlinedButton.icon(
                    onPressed: () => _sharePassaporto(context, checkIns),
                    icon: const Icon(Icons.share),
                    label: const Text('Condividi il mio passaporto'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.deepTeal,
                      side: BorderSide(color: AppTheme.deepTeal),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                // Griglia di timbri (un card per rifugio)
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.65,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    itemCount: groupedCheckIns.length,
                    itemBuilder: (context, index) {
                      final rifugioId = groupedCheckIns.keys.elementAt(index);
                      final rifugioCheckIns = groupedCheckIns[rifugioId]!;

                      return _PassaportoStampCard(
                        checkIns: rifugioCheckIns,
                        index: index,
                        onTap: () => _navigateToRifugio(context, rifugioId),
                        onShare: () =>
                            _shareRifugioCheckIns(context, rifugioCheckIns),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _navigateToRifugio(BuildContext context, String rifugioId) {
    final rifugiProvider = Provider.of<RifugiProvider>(context, listen: false);
    final rifugio = rifugiProvider.getRifugioById(rifugioId);

    if (rifugio == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Rifugio non trovato')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DettaglioRifugioScreen(rifugio: rifugio),
      ),
    );
  }

  Future<void> _shareRifugioCheckIns(
    BuildContext context,
    List<dynamic> checkIns,
  ) async {
    try {
      final latestCheckIn = checkIns.first;
      final screenshotController = ScreenshotController();

      // Trova il rifugio per ottenere l'immagine
      final rifugiProvider = Provider.of<RifugiProvider>(
        context,
        listen: false,
      );
      final rifugio = rifugiProvider.rifugi.firstWhere(
        (r) => r.id == latestCheckIn.rifugioId,
        orElse: () => rifugiProvider.rifugi.first,
      );

      final image = await screenshotController.captureFromWidget(
        ShareCheckinCard.fromRifugio(
          rifugioNome: latestCheckIn.rifugioNome,
          rifugioImmagine: rifugio.immagine,
          altitudine: latestCheckIn.altitudine,
          visitCount: checkIns.length,
          dataCheckin: latestCheckIn.dataVisita,
        ),
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath =
          '${directory.path}/checkin_${latestCheckIn.rifugioId}.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      final screenSize = MediaQuery.of(context).size;
      final shareRect = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2),
        width: 100,
        height: 100,
      );

      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            '🏔️ Check-in al ${latestCheckIn.rifugioNome}!\n'
            '${latestCheckIn.altitudine != null ? "📍 ${latestCheckIn.altitudine!.toInt()} m s.l.m.\n" : ""}'
            '${checkIns.length > 1 ? "✅ Visita n. ${checkIns.length}\n" : ""}'
            '\n#RifugiEBivacchi #Montagna',
        sharePositionOrigin: shareRect,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella condivisione: $e')),
        );
      }
    }
  }

  Future<void> _sharePassaporto(
    BuildContext context,
    List<dynamic> checkIns,
  ) async {
    try {
      final screenshotController = ScreenshotController();

      final image = await screenshotController.captureFromWidget(
        _SharePassaportoWidget(checkIns: checkIns),
        delay: const Duration(milliseconds: 100),
      );

      final directory = await getTemporaryDirectory();
      final imagePath = '${directory.path}/passaporto_completo.png';
      final imageFile = File(imagePath);
      await imageFile.writeAsBytes(image);

      final screenSize = MediaQuery.of(context).size;
      final shareRect = Rect.fromCenter(
        center: Offset(screenSize.width / 2, screenSize.height / 2),
        width: 10,
        height: 10,
      );

      await Share.shareXFiles(
        [XFile(imagePath)],
        text:
            '🏔️ Il mio Passaporto dei Rifugi!\n'
            '📊 ${checkIns.length} ${checkIns.length == 1 ? 'rifugio visitato' : 'rifugi visitati'}\n\n'
            '#RifugiEBivacchi #Montagna #PassaportoDeiRifugi',
        sharePositionOrigin: shareRect,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore nella condivisione: $e')),
        );
      }
    }
  }
}

class _PassaportoStampCard extends StatelessWidget {
  final List<dynamic> checkIns;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onShare;

  const _PassaportoStampCard({
    required this.checkIns,
    required this.index,
    required this.onTap,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy', 'it_IT');
    final latestCheckIn = checkIns.first; // Lista già ordinata per data
    final oldestCheckIn = checkIns.last;
    final visitCount = checkIns.length;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAF8F3), // Colore carta vintage
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.deepTeal.withAlpha((0.5 * 255).toInt()),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.15 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
            // Ombra interna per effetto timbro
            BoxShadow(
              color: AppTheme.deepTeal.withAlpha((0.05 * 255).toInt()),
              blurRadius: 4,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header con numero visite e icona condividi
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.deepTeal.withAlpha((0.1 * 255).toInt()),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.deepTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      visitCount > 1 ? '$visitCount visite' : '1 visita',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share, size: 18),
                    color: AppTheme.deepTeal,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () {
                      onShare();
                    },
                  ),
                ],
              ),
            ),
            // Contenuto - Timbro circolare
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Timbro circolare centrale
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.deepTeal.withAlpha(
                            (0.4 * 255).toInt(),
                          ),
                          width: 2.5,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppTheme.deepTeal.withAlpha(
                              (0.3 * 255).toInt(),
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Icona montagna
                            Icon(
                              Icons.landscape,
                              color: AppTheme.deepTeal,
                              size: 28,
                            ),
                            const SizedBox(height: 4),
                            // Nome rifugio
                            Text(
                              latestCheckIn.rifugioNome,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                height: 1.1,
                                color: AppTheme.deepTeal,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Altitudine
                    if (latestCheckIn.altitudine != null)
                      Text(
                        '${latestCheckIn.altitudine!.toInt()} m',
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    const SizedBox(height: 6),
                    // Prima visita
                    Text(
                      '1ª visita:',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      dateFormat.format(oldestCheckIn.dataVisita),
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    // Ultima visita (se più di una)
                    if (visitCount > 1) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Ultima:',
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        dateFormat.format(latestCheckIn.dataVisita),
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Timbro "VISITATO" ruotato
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.deepTeal.withAlpha((0.05 * 255).toInt()),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(9),
                  bottomRight: Radius.circular(9),
                ),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: -0.05, // Leggera rotazione
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppTheme.deepTeal.withAlpha((0.5 * 255).toInt()),
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'VISITATO',
                      style: TextStyle(
                        color: AppTheme.deepTeal.withAlpha((0.7 * 255).toInt()),
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Widget per condividere l'intero passaporto con design accattivante
class _SharePassaportoWidget extends StatelessWidget {
  final List<dynamic> checkIns;

  const _SharePassaportoWidget({required this.checkIns});

  @override
  Widget build(BuildContext context) {
    // Calcola statistiche
    final totalRifugi = checkIns.length;
    final rifugiUnici = checkIns.map((c) => c.rifugioId).toSet().length;
    final altitudineMax = checkIns
        .where((c) => c.altitudine != null)
        .map((c) => c.altitudine as double)
        .fold(0.0, (max, alt) => alt > max ? alt : max);

    return MediaQuery(
      data: const MediaQueryData(),
      child: Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          width: 1080,
          height: 1080,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.deepTeal, AppTheme.deepTeal.withGreen(120)],
            ),
          ),
          child: Stack(
            children: [
              // Pattern di sfondo montagne (riutilizzo lo stesso pattern)
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(painter: _MountainPatternPainter()),
                ),
              ),
              // Contenuto
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Header con badge passaporto
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.workspace_premium,
                            color: AppTheme.deepTeal,
                            size: 70,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'IL MIO PASSAPORTO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w300,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'DEI RIFUGI',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    // Statistiche in cards
                    Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _StatCard(
                                icon: Icons.check_circle,
                                value: totalRifugi.toString(),
                                label: totalRifugi == 1 ? 'VISITA' : 'VISITE',
                              ),
                            ),
                            const SizedBox(width: 24),
                            Expanded(
                              child: _StatCard(
                                icon: Icons.location_on,
                                value: rifugiUnici.toString(),
                                label: rifugiUnici == 1 ? 'RIFUGIO' : 'RIFUGI',
                              ),
                            ),
                          ],
                        ),
                        if (altitudineMax > 0) ...[
                          const SizedBox(height: 24),
                          _StatCard(
                            icon: Icons.terrain,
                            value: '${altitudineMax.toInt()} m',
                            label: 'QUOTA MASSIMA',
                            fullWidth: true,
                          ),
                        ],
                      ],
                    ),
                    // Lista rifugi in griglia compatta
                    if (totalRifugi <= 6)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'RIFUGI VISITATI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...checkIns.map(
                              (checkIn) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        checkIn.rifugioNome,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.celebration,
                              color: Colors.white,
                              size: 40,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Un vero esploratore!',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Hai visitato $totalRifugi rifugi diversi',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    // Footer
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.landscape,
                                color: AppTheme.deepTeal,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Rifugi e Bivacchi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '#RifugiEBivacchi #Montagna #PassaportoDeiRifugi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

// Widget per le statistiche
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final bool fullWidth;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppTheme.deepTeal, size: fullWidth ? 48 : 40),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.deepTeal,
              fontSize: fullWidth ? 44 : 40,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.deepTeal,
              fontSize: fullWidth ? 16 : 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Pattern painter per le montagne (copiato da share_checkin_card)
class _MountainPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Disegna sagome di montagne in linea
    final mountainPath = Path();
    mountainPath.moveTo(0, size.height * 0.6);

    // Profilo montagne irregolare
    for (var i = 0; i < 8; i++) {
      final x = (size.width / 8) * i;
      final peakHeight = size.height * (0.3 + (i % 3) * 0.15);
      mountainPath.lineTo(x, peakHeight);
      mountainPath.lineTo(x + size.width / 16, size.height * 0.6);
    }
    canvas.drawPath(mountainPath, paint);

    // Disegna piccoli alberi stilizzati sparsi
    final treePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 15; i++) {
      final x = (i * 87.3) % size.width;
      final y = (i * 112.7) % size.height;

      // Triangolo per albero
      final treePath = Path();
      treePath.moveTo(x, y);
      treePath.lineTo(x - 8, y + 20);
      treePath.lineTo(x + 8, y + 20);
      treePath.close();
      canvas.drawPath(treePath, treePaint);

      // Tronco
      canvas.drawRect(Rect.fromLTWH(x - 2, y + 20, 4, 8), treePaint);
    }

    // Disegna stelle alpine (fiori) in alcuni punti
    final flowerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (var i = 0; i < 12; i++) {
      final x = (i * 103.5) % size.width;
      final y = (i * 141.2) % size.height;

      // Stella a 6 punte
      for (var j = 0; j < 6; j++) {
        final angle = (j * 60) * 3.14159 / 180;
        final endX = x + 6 * math.cos(angle);
        final endY = y + 6 * math.sin(angle);
        canvas.drawCircle(Offset(endX, endY), 2, flowerPaint);
      }
    }
  }

  @override
  bool shouldRepaint(_MountainPatternPainter oldDelegate) => false;
}
