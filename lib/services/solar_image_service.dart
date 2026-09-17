import 'package:http/http.dart';

/// Fetches SDO browse-directory listings and caches URL maps in-memory.
class SolarImageService {
  SolarImageService({Client? client}) : _client = client ?? Client();

  final Client _client;

  static const _baseUrl = 'https://sdo.gsfc.nasa.gov/assets/img/browse';
  static const _cacheTtl = Duration(minutes: 15);

  static Map<String, String>? _urlCache;
  static DateTime? _urlCacheAt;

  /// Returns wavelength → latest image URL.
  /// Uses an in-memory cache unless [forceRefresh] is true.
  Future<Map<String, String>> fetchLatestImages({
    bool forceRefresh = false,
  }) async {
    final cached = _urlCache;
    final cachedAt = _urlCacheAt;
    if (!forceRefresh &&
        cached != null &&
        cachedAt != null &&
        DateTime.now().difference(cachedAt) < _cacheTtl) {
      return Map<String, String>.from(cached);
    }

    final now = DateTime.now().toUtc();
    final year = now.year.toString();
    final month = now.month.toString().padLeft(2, '0');
    final day = now.day.toString().padLeft(2, '0');
    final dateStr = '$year$month$day';
    final dirUrl = '$_baseUrl/$year/$month/$day/';

    final response = await _client
        .get(
          Uri.parse(dirUrl),
          headers: const {
            'User-Agent': 'SpaceWeather/1.0 (Flutter; educational)',
            'Accept': 'text/html',
          },
        )
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to load SDO image listing. Status: ${response.statusCode}',
      );
    }

    final html = response.body;
    final imageMap = <String, String>{};
    final regex = RegExp(
      'href="(${RegExp.escape(dateStr)}_\\d{6}_2048_(\\w+)\\.jpg)"',
    );

    for (final match in regex.allMatches(html)) {
      final filename = match.group(1)!;
      final wavelength = match.group(2)!;
      final existing = imageMap[wavelength];
      if (existing == null || filename.compareTo(existing) > 0) {
        imageMap[wavelength] = filename;
      }
    }

    final result = imageMap.map(
      (wavelength, filename) => MapEntry(wavelength, '$dirUrl$filename'),
    );
    _urlCache = result;
    _urlCacheAt = DateTime.now();
    return Map<String, String>.from(result);
  }

  String getWavelengthKey(String instrument, String wavelength) {
    if (instrument.contains('AIA')) {
      final match = RegExp(r'(\d+)').firstMatch(wavelength);
      if (match != null) {
        return match.group(1)!.padLeft(4, '0');
      }
      return '';
    } else if (instrument.contains('HMI')) {
      if (wavelength.contains('6173') || wavelength.contains('Visible')) {
        return 'HMID';
      }
      return 'HMII';
    }
    return '';
  }

  void dispose() {
    _client.close();
  }
}
