import 'dart:convert';
import 'dart:isolate';

import 'package:http/http.dart' as http;

import '../models/space_weather.dart';

List<dynamic> _decodeJsonList(String body) {
  final decoded = jsonDecode(body);
  if (decoded is! List) {
    throw const FormatException('Expected JSON array');
  }
  return decoded;
}

/// Raw SWPC / DONKI HTTP access with current public endpoints.
class SwpcService {
  static const _swpc = 'https://services.swpc.noaa.gov';
  static const _donki = 'https://kauai.ccmc.gsfc.nasa.gov/DONKI/WS/get';

  SwpcService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<SpaceWeatherState> fetchAll() async {
    final failures = <String>[];

    final solarWind = await _safe(
      'solar wind',
      failures,
      _fetchSolarWind,
      SolarWindData.empty(),
    );
    final geomag = await _safe(
      'geomagnetic',
      failures,
      _fetchGeomag,
      GeomagData.empty(),
    );
    final xray = await _safe(
      'x-ray',
      failures,
      _fetchXrayFlux,
      XrayData.empty(),
    );
    final cmes = await _safe(
      'CME',
      failures,
      _fetchCmeList,
      <CmeEvent>[],
    );
    final flares = await _safe(
      'flares',
      failures,
      _fetchFlareList,
      <FlareEvent>[],
    );
    final kpForecast = await _safe(
      'Kp forecast',
      failures,
      _fetchKpForecast,
      <KpForecast>[],
    );
    final activeRegions = await _safe(
      'active regions',
      failures,
      _fetchActiveRegions,
      <SolarRegion>[],
    );

    if (failures.length == 7) {
      throw Exception('全部数据源请求失败: ${failures.join(", ")}');
    }

    return SpaceWeatherState(
      solarWind: solarWind,
      geomag: geomag,
      xray: xray,
      cmes: cmes,
      flares: flares,
      kpForecast: kpForecast,
      activeRegions: activeRegions,
      ionosphere: _deriveIonosphere(geomag),
      aurora: _deriveAurora(geomag),
      lastUpdated: DateTime.now().toUtc(),
      error: failures.isEmpty
          ? null
          : '部分数据源失败: ${failures.join(", ")}',
    );
  }

  Future<T> _safe<T>(
    String name,
    List<String> failures,
    Future<T> Function() fetch,
    T fallback,
  ) async {
    try {
      return await fetch();
    } catch (e) {
      failures.add(name);
      // ignore: avoid_print
      print('SWPC $name failed: $e');
      return fallback;
    }
  }

  Future<String> _getBody(String url) async {
    final resp = await _client.get(
      Uri.parse(url),
      headers: const {
        'User-Agent': 'SpaceWeather/1.0 (Flutter; educational)',
        'Accept': 'application/json',
      },
    );
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $url');
    }
    return resp.body;
  }

  Future<List<dynamic>> _getJsonList(String url) async {
    return _decodeJsonList(await _getBody(url));
  }

  Future<SolarWindData> _fetchSolarWind() async {
    final windBody = await _getBody('$_swpc/json/rtsw/rtsw_wind_1m.json');
    final magBody = await _getBody('$_swpc/json/rtsw/rtsw_mag_1m.json');

    final windList = await Isolate.run(() => _decodeJsonList(windBody));
    final magList = await Isolate.run(() => _decodeJsonList(magBody));

    final wind = _latestActiveOrLast(windList);
    final mag = _latestActiveOrLast(magList);
    if (wind == null && mag == null) return SolarWindData.empty();

    final speed = _parseDouble(wind?['proton_speed']);
    final density = _parseDouble(wind?['proton_density']);
    final temperature = _parseDouble(wind?['proton_temperature']);
    final dynamicPressure = (speed != null && density != null)
        ? 1.6726e-6 * density * speed * speed
        : null;

    return SolarWindData(
      timeTag: _parseTime(wind?['time_tag'] ?? mag?['time_tag']),
      speed: speed,
      density: density,
      temperature: temperature,
      dynamicPressure: dynamicPressure,
      bt: _parseDouble(mag?['bt']),
      bz: _parseDouble(mag?['bz_gsm'] ?? mag?['bz_gse']),
      bx: _parseDouble(mag?['bx_gsm'] ?? mag?['bx_gse']),
      by: _parseDouble(mag?['by_gsm'] ?? mag?['by_gse']),
    );
  }

  Map<String, dynamic>? _latestActiveOrLast(List<dynamic> data) {
    for (var i = data.length - 1; i >= 0; i--) {
      final item = data[i];
      if (item is Map && item['active'] == true) {
        return Map<String, dynamic>.from(item);
      }
    }
    if (data.isEmpty) return null;
    final last = data.last;
    return last is Map ? Map<String, dynamic>.from(last) : null;
  }

  Future<GeomagData> _fetchGeomag() async {
    final kpData =
        await _getJsonList('$_swpc/products/noaa-planetary-k-index.json');
    final dstData = await _getJsonList('$_swpc/products/kyoto-dst.json');

    if (kpData.isEmpty) return GeomagData.empty();
    final latestKp = Map<String, dynamic>.from(kpData.last as Map);
    final latestDst = dstData.isNotEmpty
        ? Map<String, dynamic>.from(dstData.last as Map)
        : <String, dynamic>{};

    final kp = _parseDouble(latestKp['Kp'] ?? latestKp['kp']) ?? 0;
    final dst = _parseInt(latestDst['dst']);
    return GeomagData(
      kp: kp,
      dst: dst,
      kpSummary: _kpToSummary(kp),
      dstSummary: _dstToSummary(dst ?? 0),
    );
  }

  Future<XrayData> _fetchXrayFlux() async {
    final data =
        await _getJsonList('$_swpc/json/goes/primary/xrays-1-day.json');
    if (data.isEmpty) return XrayData.empty();

    double? shortWave;
    double? longWave;
    for (var i = data.length - 1; i >= 0; i--) {
      final item = data[i];
      if (item is! Map) continue;
      final energy = item['energy']?.toString() ?? '';
      final flux = _parseDouble(item['flux']);
      if (flux == null || flux <= 0) continue;
      if (shortWave == null && energy.contains('0.05-0.4')) {
        shortWave = flux;
      } else if (longWave == null && energy.contains('0.1-0.8')) {
        longWave = flux;
      }
      if (shortWave != null && longWave != null) break;
    }

    final long = longWave ?? shortWave ?? 1e-6;
    return XrayData(
      shortWave: shortWave ?? long,
      longWave: long,
      classification: _classifyFlare(long),
    );
  }

  Future<List<CmeEvent>> _fetchCmeList() async {
    final start = DateTime.now()
        .toUtc()
        .subtract(const Duration(days: 7))
        .toIso8601String()
        .substring(0, 10);
    final data = await _getJsonList('$_donki/CME?startDate=$start');
    return data.whereType<Map>().map((raw) {
      final e = Map<String, dynamic>.from(raw);
      final analyses = e['cmeAnalyses'];
      Map<String, dynamic>? best;
      if (analyses is List) {
        for (final a in analyses) {
          if (a is Map && a['isMostAccurate'] == true) {
            best = Map<String, dynamic>.from(a);
            break;
          }
        }
        if (best == null && analyses.isNotEmpty && analyses.first is Map) {
          best = Map<String, dynamic>.from(analyses.first as Map);
        }
      }
      final longitude = _parseDouble(best?['longitude']);
      final halfAngle = _parseDouble(best?['halfAngle']);
      return CmeEvent(
        startTime: _parseTime(e['startTime']) ?? DateTime.now().toUtc(),
        latitude: _parseDouble(best?['latitude']),
        longitude: longitude,
        halfAngle: halfAngle,
        speed: _parseDouble(best?['speed']),
        cpa: halfAngle ?? 0,
        isEarthDirected: (longitude?.abs() ?? 180) < 60,
      );
    }).toList();
  }

  Future<List<FlareEvent>> _fetchFlareList() async {
    final data = await _getJsonList('$_swpc/json/edited_events.json');
    return data
        .whereType<Map>()
        .where((e) => e['type']?.toString() == 'XRA')
        .map((raw) {
      final e = Map<String, dynamic>.from(raw);
      return FlareEvent(
        startTime:
            _parseTime(e['begin_datetime']) ?? DateTime.now().toUtc(),
        classType: e['particulars1']?.toString() ?? 'A',
        peakWatts: _parseDouble(e['particulars10'] ?? e['particulars2']),
      );
    }).take(50).toList();
  }

  Future<List<KpForecast>> _fetchKpForecast() async {
    final data = await _getJsonList(
      '$_swpc/products/noaa-planetary-k-index-forecast.json',
    );
    return data.whereType<Map>().map((raw) {
      final e = Map<String, dynamic>.from(raw);
      return KpForecast(
        time: _parseTime(e['time_tag']) ?? DateTime.now().toUtc(),
        kp: _parseDouble(e['kp'] ?? e['Kp']) ?? 0,
      );
    }).toList();
  }

  Future<List<SolarRegion>> _fetchActiveRegions() async {
    final data = await _getJsonList('$_swpc/json/solar_regions.json');
    final today = DateTime.now().toUtc();
    final todayStr =
        '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    final recent = data.whereType<Map>().where((e) {
      final date = e['observed_date']?.toString() ?? '';
      return date == todayStr || date.isEmpty;
    });

    final source = recent.isNotEmpty ? recent : data.whereType<Map>();
    return source.map((raw) {
      final e = Map<String, dynamic>.from(raw);
      return SolarRegion(
        id: e['region']?.toString() ?? '',
        location: e['location']?.toString() ?? '',
        area: _parseInt(e['area']) ?? 0,
        hasFlareC: (_parseInt(e['c_xray_events']) ?? 0) > 0,
        hasFlareM: (_parseInt(e['m_xray_events']) ?? 0) > 0,
        hasFlareX: (_parseInt(e['x_xray_events']) ?? 0) > 0,
        magneticClass: e['mag_class']?.toString() ??
            e['mag_string']?.toString() ??
            'Alpha',
      );
    }).toList();
  }

  IonosphereData _deriveIonosphere(GeomagData geomag) {
    final baseTec = 10.0 + geomag.kp * 3.0;
    final scintLevel = geomag.kp >= 7
        ? 'Strong'
        : geomag.kp >= 5
            ? 'Moderate'
            : geomag.kp >= 3
                ? 'Low'
                : 'None';
    return IonosphereData(
      maxTelemetry: baseTec + 15,
      tecValues: List.generate(7, (i) => baseTec + (i - 3) * 2.5),
      avgTec: baseTec + 5,
      scintillationLevel: scintLevel,
    );
  }

  AuroraData _deriveAurora(GeomagData geomag) {
    final level = geomag.kp >= 9
        ? 9
        : geomag.kp >= 7
            ? 6
            : geomag.kp >= 5
                ? 4
                : geomag.kp >= 3
                    ? 2
                    : 1;
    final baseLat = 75.0 - geomag.kp * 3;
    return AuroraData(
      kp: geomag.kp,
      estimatedLevel: level,
      ovalLatitudes: List.generate(4, (i) => baseLat + i),
    );
  }

  String _kpToSummary(double kp) {
    if (kp >= 7) return 'Geomagnetic Storm';
    if (kp >= 5) return 'Unsettled';
    if (kp >= 3) return 'Active';
    return 'Quiet';
  }

  String _dstToSummary(int dst) {
    if (dst <= -200) return 'Intense Storm';
    if (dst <= -100) return 'Severe Storm';
    if (dst <= -50) return 'Strong Storm';
    if (dst <= -30) return 'Moderate Storm';
    if (dst <= -10) return 'Minor Storm';
    return 'Quiet';
  }

  String _classifyFlare(double? fluxWm2) {
    if (fluxWm2 == null || fluxWm2 <= 0) return 'A';
    if (fluxWm2 >= 1e-4) return 'X${(fluxWm2 / 1e-4).toStringAsFixed(1)}';
    if (fluxWm2 >= 1e-5) return 'M${(fluxWm2 / 1e-5).toStringAsFixed(1)}';
    if (fluxWm2 >= 1e-6) return 'C${(fluxWm2 / 1e-6).toStringAsFixed(1)}';
    if (fluxWm2 >= 1e-7) return 'B${(fluxWm2 / 1e-7).toStringAsFixed(1)}';
    return 'A${(fluxWm2 / 1e-8).toStringAsFixed(1)}';
  }

  DateTime? _parseTime(dynamic val) {
    if (val == null) return null;
    try {
      return DateTime.parse(val.toString().replaceAll(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  double? _parseDouble(dynamic val) {
    if (val == null || val.toString().isEmpty) return null;
    return double.tryParse(val.toString());
  }

  int? _parseInt(dynamic val) {
    if (val == null || val.toString().isEmpty) return null;
    return int.tryParse(val.toString());
  }

  void dispose() {
    _client.close();
  }
}
