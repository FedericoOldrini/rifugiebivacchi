import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import 'package:rifugi_bivacchi/l10n/app_localizations.dart';

class WeatherWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  const WeatherWidget({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> {
  final WeatherService _weatherService = WeatherService();
  Weather? _weather;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _error = null;
    });

    try {
      final weather = await _weatherService.getWeather(
        widget.latitude,
        widget.longitude,
      );

      if (mounted) {
        setState(() {
          _weather = weather;
          if (weather == null) {
            _error = 'offline';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'offline';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Non mostrare il widget se c'è un errore (offline) o ancora in caricamento
    if (_error != null || _weather == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_outlined,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  AppLocalizations.of(context)!.meteo,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 18),
                  onPressed: _loadWeather,
                  tooltip: AppLocalizations.of(context)!.refresh,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCurrentWeather(),
            if (_weather!.dailyForecasts != null &&
                _weather!.dailyForecasts!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildForecast(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentWeather() {
    final weather = _weather!;

    return Row(
      children: [
        // Icona e temperatura
        Text(
          weather.weatherIcon,
          style: const TextStyle(fontSize: 40),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature.round()}°',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          weather.weatherDescription,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Dati compatti in riga
              Wrap(
                spacing: 12,
                children: [
                  _buildCompactDetail(
                    icon: Icons.air,
                    value: '${weather.windSpeed.round()} km/h',
                  ),
                  _buildCompactDetail(
                    icon: Icons.water_drop,
                    value: '${weather.humidity}%',
                  ),
                  if (weather.precipitation > 0)
                    _buildCompactDetail(
                      icon: Icons.grain,
                      value: '${weather.precipitation.toStringAsFixed(1)} mm',
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompactDetail({
    required IconData icon,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildForecast() {
    final forecasts = _weather!.dailyForecasts!;
    // Mostra solo i prossimi 5 giorni per un design più compatto
    final displayForecasts = forecasts.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.nextDays,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 93,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: displayForecasts.length,
            itemBuilder: (context, index) {
              final forecast = displayForecasts[index];
              final isToday = index == 0;

              return Container(
                width: 60,
                margin: const EdgeInsets.only(right: 8),
                padding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  color: isToday
                      ? Theme.of(context).colorScheme.primaryContainer
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      isToday
                          ? AppLocalizations.of(context)!.today
                          : DateFormat('E', Localizations.localeOf(context).languageCode).format(forecast.date),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      forecast.weatherIcon,
                      style: const TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 2),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${forecast.temperatureMax.round()}°',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${forecast.temperatureMin.round()}°',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(Icons.info_outline, size: 12, color: Colors.grey[500]),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.dataOpenMeteo,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
