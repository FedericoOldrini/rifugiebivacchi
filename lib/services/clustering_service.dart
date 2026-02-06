import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/rifugio.dart';
import 'dart:math' as math;

/// Classe che rappresenta un cluster di rifugi
class RifugioCluster {
  final List<Rifugio> rifugi;
  final LatLng center;
  
  RifugioCluster(this.rifugi, this.center);
  
  bool get isMultiple => rifugi.length > 1;
  int get count => rifugi.length;
  
  Rifugio get singleRifugio => rifugi.first;
}

/// Gestore del clustering basato sullo zoom
class ClusteringService {
  /// Distanze di clustering in base allo zoom (in gradi di latitudine/longitudine)
  static double getClusterDistance(double zoom) {
    if (zoom < 8) return 1.0;
    if (zoom < 10) return 0.5;
    if (zoom < 12) return 0.2;
    if (zoom < 14) return 0.1;
    if (zoom < 15) return 0.05;
    return 0; // Nessun clustering a zoom elevato
  }
  
  /// Raggruppa i rifugi in cluster in base allo zoom
  static List<RifugioCluster> clusterRifugi(
    List<Rifugio> rifugi,
    double zoom,
  ) {
    final distance = getClusterDistance(zoom);
    
    // Se distanza è 0, nessun clustering
    if (distance == 0) {
      return rifugi
          .map((r) => RifugioCluster([r], LatLng(r.latitudine, r.longitudine)))
          .toList();
    }
    
    final List<RifugioCluster> clusters = [];
    final Set<String> processed = {};
    
    for (final rifugio in rifugi) {
      if (processed.contains(rifugio.id)) continue;
      
      final List<Rifugio> clusterItems = [rifugio];
      processed.add(rifugio.id);
      
      // Trova rifugi vicini
      for (final other in rifugi) {
        if (processed.contains(other.id)) continue;
        
        final d = _calculateDistance(
          rifugio.latitudine,
          rifugio.longitudine,
          other.latitudine,
          other.longitudine,
        );
        
        if (d <= distance) {
          clusterItems.add(other);
          processed.add(other.id);
        }
      }
      
      // Calcola il centro del cluster
      final centerLat = clusterItems
              .map((r) => r.latitudine)
              .reduce((a, b) => a + b) /
          clusterItems.length;
      final centerLng = clusterItems
              .map((r) => r.longitudine)
              .reduce((a, b) => a + b) /
          clusterItems.length;
      
      clusters.add(
        RifugioCluster(
          clusterItems,
          LatLng(centerLat, centerLng),
        ),
      );
    }
    
    return clusters;
  }
  
  /// Calcola la distanza approssimativa tra due punti (in gradi)
  static double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    return math.sqrt(dLat * dLat + dLon * dLon);
  }
}
