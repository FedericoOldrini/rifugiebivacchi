class Rifugio {
  final String id;
  final String nome;
  final String? descrizione;
  final double latitudine;
  final double longitudine;
  final double? altitudine;
  final String tipo;
  final String? operatore;
  final String? telefono;
  final String? email;
  final String? sitoWeb;
  final String? immagine;
  
  // Nuovi campi dal file CAI
  final String? source;
  final String? locality;
  final String? region;
  final String? province;
  final String? municipality;
  final String? valley;
  final String? siteDescription;
  final String? owner;
  final String? status;
  final String? regionalType;
  final int? buildYear;
  
  // Servizi
  final bool? wifi;
  final int? postiLetto;
  final bool? elettricita;
  final bool? ristorante;
  final int? postiTotali;
  final bool? pagamentoPos;
  final bool? defibrillatore;
  final bool? hotWater;
  final bool? showers;
  final bool? insideWater;
  final int? restaurantSeats;
  
  // Accessibilità
  final bool? disabledAccess;
  final bool? disabledWc;
  final bool? familiesChildrenAccess;
  final bool? carAccess;
  final bool? mountainBikeAccess;
  final bool? petAccess;
  
  // Contatti aggiuntivi
  final String? secondaryPhone;
  final String? websiteProperty;
  final String? emailProperty;
  final String? propertyName;
  
  // Media
  final List<String>? imageUrls;

  Rifugio({
    required this.id,
    required this.nome,
    this.descrizione,
    required this.latitudine,
    required this.longitudine,
    this.altitudine,
    this.tipo = 'rifugio',
    this.operatore,
    this.telefono,
    this.email,
    this.sitoWeb,
    this.immagine,
    this.source,
    this.locality,
    this.region,
    this.province,
    this.municipality,
    this.valley,
    this.siteDescription,
    this.owner,
    this.status,
    this.regionalType,
    this.buildYear,
    this.wifi,
    this.postiLetto,
    this.elettricita,
    this.ristorante,
    this.postiTotali,
    this.pagamentoPos,
    this.defibrillatore,
    this.hotWater,
    this.showers,
    this.insideWater,
    this.restaurantSeats,
    this.disabledAccess,
    this.disabledWc,
    this.familiesChildrenAccess,
    this.carAccess,
    this.mountainBikeAccess,
    this.petAccess,
    this.secondaryPhone,
    this.websiteProperty,
    this.emailProperty,
    this.propertyName,
    this.imageUrls,
  });

  factory Rifugio.fromJson(Map<String, dynamic> json) {
    // Parsing dei dati dal nuovo formato CAI
    final geo = json['geo'] as Map<String, dynamic>?;
    final services = json['services'] as Map<String, dynamic>?;
    final contacts = json['contacts'] as Map<String, dynamic>?;
    final accessibilita = json['accessibilita'] as Map<String, dynamic>?;
    final property = json['property'] as Map<String, dynamic>?;
    final mediaList = json['mediaList'] as List?;
    
    // Parsing altitudine
    double? altitude;
    if (geo?['altitude'] != null) {
      try {
        altitude = double.parse(geo!['altitude'].toString());
      } catch (e) {
        altitude = null;
      }
    }
    
    // Estrai URLs immagini
    List<String>? images;
    if (mediaList != null && mediaList.isNotEmpty) {
      images = mediaList
          .map((m) => m['url']?.toString())
          .where((url) => url != null)
          .cast<String>()
          .toList();
    }
    
    // Determina il tipo
    String tipo = 'rifugio';
    final typeStr = json['type']?.toString().toLowerCase() ?? '';
    final nameLower = (json['name'] ?? '').toString().toLowerCase();
    
    if (typeStr.contains('bivacco') || nameLower.contains('bivacco')) {
      tipo = 'bivacco';
    } else if (typeStr.contains('malga') || nameLower.contains('malga') || 
               nameLower.contains('alpe') || nameLower.contains('baita')) {
      tipo = 'malga';
    } else if (typeStr.contains('rifugio')) {
      tipo = 'rifugio';
    }

    return Rifugio(
      id: json['sourceId']?.toString() ?? json['id']?.toString() ?? '',
      nome: json['name'] ?? 'Senza nome',
      descrizione: geo?['description'],
      latitudine: (geo?['lat'] ?? 0.0).toDouble(),
      longitudine: (geo?['lng'] ?? 0.0).toDouble(),
      altitudine: altitude,
      tipo: tipo,
      operatore: property?['name'],
      telefono: contacts?['mainPhone'],
      email: contacts?['email'],
      sitoWeb: contacts?['website'],
      immagine: images?.isNotEmpty == true ? images!.first : null,
      imageUrls: images,
      source: json['source'],
      locality: geo?['locality'],
      region: geo?['region'],
      province: geo?['province'],
      municipality: geo?['municipality'],
      valley: geo?['valley'],
      siteDescription: geo?['site'],
      owner: json['owner'],
      status: json['status'],
      regionalType: json['regionalType'],
      buildYear: json['buildYear'],
      wifi: services?['wifi'],
      postiLetto: services?['postiLetto'],
      elettricita: services?['elettricita'],
      ristorante: services?['ristorante'],
      postiTotali: services?['postiTotali'],
      pagamentoPos: services?['pagamentoPos'],
      defibrillatore: services?['defibrillatore'],
      hotWater: services?['hotWater'],
      showers: services?['showers'],
      insideWater: services?['insideWater'],
      restaurantSeats: services?['restaurantSeats'],
      disabledAccess: accessibilita?['disabledAccess'],
      disabledWc: accessibilita?['disabledWc'],
      familiesChildrenAccess: accessibilita?['familiesChildrenAccess'],
      carAccess: accessibilita?['carAccess'],
      mountainBikeAccess: accessibilita?['mountainBykeAccess'],
      petAccess: accessibilita?['petAccess'],
      secondaryPhone: contacts?['secondaryPhone'],
      websiteProperty: property?['website'],
      emailProperty: property?['email'],
      propertyName: property?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sourceId': id,
      'name': nome,
      'geo': {
        'lat': latitudine,
        'lng': longitudine,
        'altitude': altitudine?.toString(),
        'locality': locality,
        'region': region,
        'province': province,
        'municipality': municipality,
        'valley': valley,
        'description': descrizione,
        'site': siteDescription,
      },
      'contacts': {
        'mainPhone': telefono,
        'secondaryPhone': secondaryPhone,
        'email': email,
        'website': sitoWeb,
      },
      'services': {
        'wifi': wifi,
        'postiLetto': postiLetto,
        'elettricita': elettricita,
        'ristorante': ristorante,
        'postiTotali': postiTotali,
        'pagamentoPos': pagamentoPos,
        'defibrillatore': defibrillatore,
        'hotWater': hotWater,
        'showers': showers,
        'insideWater': insideWater,
        'restaurantSeats': restaurantSeats,
      },
      'accessibilita': {
        'disabledAccess': disabledAccess,
        'disabledWc': disabledWc,
        'familiesChildrenAccess': familiesChildrenAccess,
        'carAccess': carAccess,
        'mountainBykeAccess': mountainBikeAccess,
        'petAccess': petAccess,
      },
      'property': {
        'name': propertyName,
        'website': websiteProperty,
        'email': emailProperty,
      },
      'type': tipo,
      'owner': owner,
      'status': status,
      'regionalType': regionalType,
      'buildYear': buildYear,
      'source': source,
    };
  }
}
