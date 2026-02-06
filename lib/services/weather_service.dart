import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Ottiene le previsioni meteo per una posizione specifica
  /// 
  /// [latitude] e [longitude] specificano la posizione
  /// Ritorna un oggetto [Weather] con dati attuali e previsioni a 7 giorni
  Future<Weather?> getWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m&'
        'daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum&'
        'timezone=Europe/Rome&'
        'forecast_days=7',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(data);
      } else {
        print('Errore nel recupero dei dati meteo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Errore nella chiamata alle API meteo: $e');
      return null;
    }
  }

  /// Ottiene solo i dati meteo correnti (più veloce)
  Future<Weather?> getCurrentWeather(double latitude, double longitude) async {
    try {
      final url = Uri.parse(
        '$_baseUrl?'
        'latitude=$latitude&'
        'longitude=$longitude&'
        'current=temperature_2m,relative_humidity_2m,precipitation,weather_code,wind_speed_10m&'
        'timezone=Europe/Rome',
      );

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return Weather.fromJson(data);
      } else {
        print('Errore nel recupero dei dati meteo: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Errore nella chiamata alle API meteo: $e');
      return null;
    }
  }
}
