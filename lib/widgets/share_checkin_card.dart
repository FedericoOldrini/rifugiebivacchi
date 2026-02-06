import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';

/// Widget per generare l'immagine di condivisione del check-in
/// Usato sia dal dettaglio rifugio che dal passaporto
class ShareCheckinCard extends StatelessWidget {
  final String rifugioNome;
  final String? rifugioImmagine;
  final double? altitudine;
  final int visitCount;
  final DateTime dataCheckin;
  final String? customHashtags;

  const ShareCheckinCard({
    super.key,
    required this.rifugioNome,
    this.rifugioImmagine,
    this.altitudine,
    required this.visitCount,
    required this.dataCheckin,
    this.customHashtags,
  });

  /// Factory per creare la card da un oggetto Rifugio
  factory ShareCheckinCard.fromRifugio({
    required String rifugioNome,
    String? rifugioImmagine,
    double? altitudine,
    required int visitCount,
    DateTime? dataCheckin,
    String? customHashtags,
  }) {
    return ShareCheckinCard(
      rifugioNome: rifugioNome,
      rifugioImmagine: rifugioImmagine,
      altitudine: altitudine,
      visitCount: visitCount,
      dataCheckin: dataCheckin ?? DateTime.now(),
      customHashtags: customHashtags,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              // Pattern di sfondo
              Positioned.fill(
                child: Opacity(
                  opacity: 0.1,
                  child: CustomPaint(painter: _MountainPatternPainter()),
                ),
              ),
              // Contenuto
              Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.landscape,
                                color: AppTheme.deepTeal,
                                size: 36,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Rifugi e Bivacchi',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (visitCount > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Text(
                              'VISITA N. $visitCount',
                              style: TextStyle(
                                color: AppTheme.deepTeal,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  // Foto del rifugio (grande e accattivante)
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child:
                          rifugioImmagine != null && rifugioImmagine!.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: CachedNetworkImage(
                                imageUrl: rifugioImmagine!,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    _buildPlaceholderImage(),
                              ),
                            )
                          : _buildPlaceholderImage(),
                    ),
                  ),
                  // Informazioni rifugio
                  Container(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        // Badge check-in
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green[700],
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'CHECK-IN',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Nome rifugio
                        Text(
                          rifugioNome,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        // Dettagli in box
                        if (altitudine != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 20,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.terrain,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${altitudine!.toInt()} m s.l.m.',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 32),
                        // Hashtag
                        Text(
                          customHashtags ??
                              '#RifugiEBivacchi #Montagna #Trekking',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
      ),
      child: const Center(
        child: Icon(Icons.landscape, size: 120, color: Colors.white),
      ),
    );
  }
}

// Pattern painter per lo sfondo - stile app con alberi e montagne
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
