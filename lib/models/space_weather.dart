class SolarWindData {
  final DateTime? timeTag;
  final double? speed;
  final double? density;
  final double? temperature;
  final double? dynamicPressure;
  final double? bt;
  final double? bz;
  final double? bx;
  final double? by;

  const SolarWindData({
    this.timeTag,
    this.speed,
    this.density,
    this.temperature,
    this.dynamicPressure,
    this.bt,
    this.bz,
    this.bx,
    this.by,
  });

  double get pressure => dynamicPressure ?? 0;

  factory SolarWindData.empty() => const SolarWindData(
        speed: 400,
        density: 5,
        temperature: 100000,
        dynamicPressure: 2.0,
        bt: 5.0,
        bz: 0.0,
        bx: 0.0,
        by: 0.0,
      );

  factory SolarWindData.fromJson(Map<String, dynamic> json) {
    return SolarWindData(
      timeTag: _parseTime(json['time_tag']),
      speed: _parseDouble(json['speed']),
      density: _parseDouble(json['density']),
      temperature: _parseDouble(json['temperature']),
      dynamicPressure: _parseDouble(json['dynamic_pressure']),
      bt: _parseDouble(json['bt']),
      bz: _parseDouble(json['bz']),
      bx: _parseDouble(json['bx']),
      by: _parseDouble(json['by']),
    );
  }

  Map<String, dynamic> toJson() => {
        'time_tag': timeTag?.toIso8601String(),
        'speed': speed,
        'density': density,
        'temperature': temperature,
        'dynamic_pressure': dynamicPressure,
        'bt': bt,
        'bz': bz,
        'bx': bx,
        'by': by,
      };
}

class GeomagData {
  final double kp;
  final int? dst;
  final String kpSummary;
  final String dstSummary;

  const GeomagData({
    this.kp = 0,
    this.dst = 0,
    this.kpSummary = 'Quiet',
    this.dstSummary = 'Quiet',
  });

  factory GeomagData.empty() => const GeomagData(
        kp: 2.0,
        dst: 0,
        kpSummary: 'Quiet',
        dstSummary: 'Quiet',
      );

  factory GeomagData.fromJson(Map<String, dynamic> json) {
    final kp = _parseDouble(json['kp_index']) ?? 0;
    final dst = _parseInt(json['dst_index']);
    return GeomagData(
      kp: kp,
      dst: dst,
      kpSummary: _kpToSummary(kp),
      dstSummary: _dstToSummary(dst ?? 0),
    );
  }

  Map<String, dynamic> toJson() => {
        'kp_index': kp,
        'dst_index': dst,
        'kp_summary': kpSummary,
        'dst_summary': dstSummary,
      };
}

class XrayData {
  final double? shortWave;
  final double? longWave;
  final String classification;

  const XrayData({
    this.shortWave,
    this.longWave,
    this.classification = 'A',
  });

  factory XrayData.empty() => const XrayData(
        shortWave: 1e-6,
        longWave: 1e-6,
        classification: 'A',
      );

  factory XrayData.fromJson(Map<String, dynamic> json) {
    final shortWave = _parseDouble(json['xrsa_flux']) ?? 1e-6;
    final longWave = _parseDouble(json['xrsb_flux']) ?? 1e-6;
    return XrayData(
      shortWave: shortWave,
      longWave: longWave,
      classification: _classifyFlare(longWave),
    );
  }

  Map<String, dynamic> toJson() => {
        'xrsa_flux': shortWave,
        'xrsb_flux': longWave,
        'classification': classification,
      };
}

class CmeEvent {
  final DateTime startTime;
  final double? latitude;
  final double? longitude;
  final double? halfAngle;
  final double? speed;
  final double? cpa;
  final bool isEarthDirected;

  const CmeEvent({
    required this.startTime,
    this.latitude,
    this.longitude,
    this.halfAngle,
    this.speed,
    this.cpa,
    this.isEarthDirected = false,
  });

  factory CmeEvent.fromJson(Map<String, dynamic> json) {
    final longitude = _parseDouble(json['longitude']);
    final halfAngle = _parseDouble(json['half_angle']);
    return CmeEvent(
      startTime: _parseTime(json['start_time']) ?? DateTime.now().toUtc(),
      latitude: _parseDouble(json['latitude']),
      longitude: longitude,
      halfAngle: halfAngle,
      speed: _parseDouble(json['speed']),
      cpa: halfAngle ?? 0,
      isEarthDirected: (longitude?.abs() ?? 180) < 60,
    );
  }

  Map<String, dynamic> toJson() => {
        'start_time': startTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'half_angle': halfAngle,
        'speed': speed,
        'cpa': cpa,
        'is_earth_directed': isEarthDirected,
      };
}

class FlareEvent {
  final DateTime startTime;
  final String classType;
  final double? peakWatts;

  const FlareEvent({
    required this.startTime,
    required this.classType,
    this.peakWatts,
  });

  factory FlareEvent.fromJson(Map<String, dynamic> json) {
    return FlareEvent(
      startTime: _parseTime(json['time_tag']) ?? DateTime.now().toUtc(),
      classType: json['flag']?.toString() ?? 'A',
      peakWatts: _parseDouble(json['flux_w_m2']),
    );
  }

  Map<String, dynamic> toJson() => {
        'time_tag': startTime.toIso8601String(),
        'flag': classType,
        'flux_w_m2': peakWatts,
      };
}

class KpForecast {
  final DateTime time;
  final double kp;

  const KpForecast({required this.time, required this.kp});

  factory KpForecast.fromJson(Map<String, dynamic> json) {
    return KpForecast(
      time: _parseTime(json['time_tag']) ?? DateTime.now().toUtc(),
      kp: _parseDouble(json['kp_index']) ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'time_tag': time.toIso8601String(),
        'kp_index': kp,
      };
}

class IonosphereData {
  final double? maxTelemetry;
  final List<double> tecValues;
  final double avgTec;
  final String scintillationLevel;

  const IonosphereData({
    this.maxTelemetry,
    this.tecValues = const [],
    this.avgTec = 0,
    this.scintillationLevel = 'Low',
  });

  factory IonosphereData.empty() => const IonosphereData(
        maxTelemetry: 30,
        tecValues: [10, 15, 20, 25, 20, 15, 10],
        avgTec: 16.4,
        scintillationLevel: 'Low',
      );
}

class AuroraData {
  final double kp;
  final int estimatedLevel;
  final List<double> ovalLatitudes;

  const AuroraData({
    this.kp = 0,
    this.estimatedLevel = 0,
    this.ovalLatitudes = const [],
  });

  factory AuroraData.empty() => const AuroraData(
        kp: 2,
        estimatedLevel: 2,
        ovalLatitudes: [67, 68, 69, 70],
      );
}

class SolarRegion {
  final String id;
  final String location;
  final int area;
  final bool hasFlareC;
  final bool hasFlareM;
  final bool hasFlareX;
  final String magneticClass;

  const SolarRegion({
    required this.id,
    required this.location,
    required this.area,
    this.hasFlareC = false,
    this.hasFlareM = false,
    this.hasFlareX = false,
    this.magneticClass = 'Beta',
  });

  factory SolarRegion.fromJson(Map<String, dynamic> json) {
    return SolarRegion(
      id: json['region_id']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      area: _parseInt(json['area']) ?? 0,
      hasFlareC: (_parseInt(json['c_class_flares']) ?? 0) > 0,
      hasFlareM: (_parseInt(json['m_class_flares']) ?? 0) > 0,
      hasFlareX: (_parseInt(json['x_class_flares']) ?? 0) > 0,
      magneticClass: json['mag_class']?.toString() ?? 'Alpha',
    );
  }

  Map<String, dynamic> toJson() => {
        'region_id': id,
        'location': location,
        'area': area,
        'c_class_flares': hasFlareC ? 1 : 0,
        'm_class_flares': hasFlareM ? 1 : 0,
        'x_class_flares': hasFlareX ? 1 : 0,
        'mag_class': magneticClass,
      };
}

class SpaceWeatherState {
  final SolarWindData solarWind;
  final GeomagData geomag;
  final XrayData xray;
  final List<CmeEvent> cmes;
  final List<FlareEvent> flares;
  final List<KpForecast> kpForecast;
  final IonosphereData ionosphere;
  final AuroraData aurora;
  final List<SolarRegion> activeRegions;
  final DateTime lastUpdated;
  final bool isLoading;
  final String? error;

  SpaceWeatherState({
    SolarWindData? solarWind,
    GeomagData? geomag,
    XrayData? xray,
    List<CmeEvent>? cmes,
    List<FlareEvent>? flares,
    List<KpForecast>? kpForecast,
    IonosphereData? ionosphere,
    AuroraData? aurora,
    List<SolarRegion>? activeRegions,
    DateTime? lastUpdated,
    this.isLoading = false,
    this.error,
  })  : solarWind = solarWind ?? SolarWindData.empty(),
        geomag = geomag ?? GeomagData.empty(),
        xray = xray ?? XrayData.empty(),
        cmes = cmes ?? const [],
        flares = flares ?? const [],
        kpForecast = kpForecast ?? const [],
        ionosphere = ionosphere ?? IonosphereData.empty(),
        aurora = aurora ?? AuroraData.empty(),
        activeRegions = activeRegions ?? const [],
        lastUpdated = lastUpdated ?? DateTime.now().toUtc();

  SpaceWeatherState copyWith({
    SolarWindData? solarWind,
    GeomagData? geomag,
    XrayData? xray,
    List<CmeEvent>? cmes,
    List<FlareEvent>? flares,
    List<KpForecast>? kpForecast,
    IonosphereData? ionosphere,
    AuroraData? aurora,
    List<SolarRegion>? activeRegions,
    DateTime? lastUpdated,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return SpaceWeatherState(
      solarWind: solarWind ?? this.solarWind,
      geomag: geomag ?? this.geomag,
      xray: xray ?? this.xray,
      cmes: cmes ?? this.cmes,
      flares: flares ?? this.flares,
      kpForecast: kpForecast ?? this.kpForecast,
      ionosphere: ionosphere ?? this.ionosphere,
      aurora: aurora ?? this.aurora,
      activeRegions: activeRegions ?? this.activeRegions,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
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
  if (fluxWm2 == null) return 'A';
  if (fluxWm2 >= 1e-4) return 'X${(fluxWm2 / 1e-4).toStringAsFixed(1)}';
  if (fluxWm2 >= 1e-5) return 'M${(fluxWm2 / 1e-5).toStringAsFixed(1)}';
  if (fluxWm2 >= 1e-6) return 'C${(fluxWm2 / 1e-6).toStringAsFixed(1)}';
  if (fluxWm2 >= 1e-7) return 'B${(fluxWm2 / 1e-7).toStringAsFixed(1)}';
  return 'A${(fluxWm2 / 1e-8).toStringAsFixed(1)}';
}
