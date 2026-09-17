import '../../models/space_weather.dart';
import '../../services/swpc_service.dart';

/// Single source of truth for space-weather data.
/// Aggregates SWPC endpoints and surfaces partial-failure messages.
class SpaceWeatherRepository {
  SpaceWeatherRepository({SwpcService? service})
      : _service = service ?? SwpcService();

  final SwpcService _service;

  Future<SpaceWeatherState> fetchLatest() => _service.fetchAll();

  void dispose() => _service.dispose();
}
