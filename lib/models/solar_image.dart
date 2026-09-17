import 'package:flutter/material.dart';

class SolarImageSource {
  final String id;
  final String name;
  final String instrument;
  final String wavelength;
  final String description;
  final String descriptionZh;
  final String urlPattern;
  final List<String> fallbackUrls;
  final Color color;
  final String category;

  const SolarImageSource({
    required this.id,
    required this.name,
    required this.instrument,
    required this.wavelength,
    required this.description,
    required this.descriptionZh,
    required this.urlPattern,
    this.fallbackUrls = const [],
    required this.color,
    required this.category,
  });

  String get currentUrl {
    final now = DateTime.now().toUtc();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return urlPattern.replaceAll('{date}', dateStr);
  }

  List<String> get allUrls {
    final now = DateTime.now().toUtc();
    final dateStr =
        '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    return [
      currentUrl,
      ...fallbackUrls.map((u) => u.replaceAll('{date}', dateStr)),
    ];
  }
}

const List<SolarImageSource> solarImageSources = [
  SolarImageSource(
    id: 'aia_171',
    name: 'AIA 171Å',
    instrument: 'SDO/AIA',
    wavelength: '171Å (EUV)',
    description:
        'Quiet corona, upper chromosphere. Shows coronal loops at ~600,000K.',
    descriptionZh: '宁静日冕和上层色球层。显示约60万K的日冕环结构。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0171_0193_0304.jpg',
    fallbackUrls: [
      'https://sohowww.nascom.nasa.gov/data/realtime-images.html',
    ],
    color: Color(0xFF4FC3F7),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'aia_193',
    name: 'AIA 193Å',
    instrument: 'SDO/AIA',
    wavelength: '193Å (EUV)',
    description:
        'Coronal holes and active regions. Fe XII at ~1.5 million K.',
    descriptionZh: '日冕洞和活动区。Fe XII谱线，约150万K。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0193.jpg',
    color: Color(0xFF66BB6A),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'aia_304',
    name: 'AIA 304Å',
    instrument: 'SDO/AIA',
    wavelength: '304Å (FUV)',
    description:
        'Chromosphere and transition region. He II at ~50,000-80,000K.',
    descriptionZh: '色球层和过渡区。He II谱线，约5万-8万K。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0304.jpg',
    color: Color(0xFFFF7043),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'aia_211',
    name: 'AIA 211Å',
    instrument: 'SDO/AIA',
    wavelength: '211Å (EUV)',
    description:
        'Active region coronal loops. Fe XIV at ~2 million K.',
    descriptionZh: '活动区日冕环。Fe XIV谱线，约200万K。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0211.jpg',
    color: Color(0xFFAB47BC),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'aia_094',
    name: 'AIA 094Å',
    instrument: 'SDO/AIA',
    wavelength: '94Å (EUV)',
    description:
        'Flaring regions. Fe XVIII at ~6-7 million K.',
    descriptionZh: '耀斑区域。Fe XVIII谱线，约600-700万K。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0094.jpg',
    color: Color(0xFFEF5350),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'aia_131',
    name: 'AIA 131Å',
    instrument: 'SDO/AIA',
    wavelength: '131Å (EUV)',
    description:
        'Flaring plasma. Fe VIII/XXI at ~10-16 million K.',
    descriptionZh: '耀斑等离子体。Fe VIII/XXI谱线，约1000-1600万K。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_0131.jpg',
    color: Color(0xFFFFEE58),
    category: 'AIA',
  ),
  SolarImageSource(
    id: 'hmi_mag',
    name: 'HMI Magnetogram',
    instrument: 'SDO/HMI',
    wavelength: '6173Å (Visible)',
    description:
        'Magnetic field polarity and strength. Blue=negative, Yellow=positive.',
    descriptionZh: '磁场极性和强度。蓝色=负极，黄色=正极。',
    urlPattern:
        'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_HMI_M.jpg',
    color: Color(0xFF42A5F5),
    category: 'HMI',
  ),
  SolarImageSource(
    id: 'lasco_c2',
    name: 'LASCO C2',
    instrument: 'SOHO/LASCO',
    wavelength: 'White Light',
    description:
        'Inner corona (2-6 solar radii). CME detection and tracking.',
    descriptionZh: '内日冕（2-6个太阳半径）。CME探测和追踪。',
    urlPattern:
        'https://soho.nascom.nasa.gov/data/realtime/c2/512/latest.jpg',
    fallbackUrls: [
      'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_LASCO_C2.jpg',
    ],
    color: Color(0xFF78909C),
    category: 'LASCO',
  ),
  SolarImageSource(
    id: 'lasco_c3',
    name: 'LASCO C3',
    instrument: 'SOHO/LASCO',
    wavelength: 'White Light',
    description:
        'Outer corona (3.7-30 solar radii). Wide-field CME propagation.',
    descriptionZh: '外日冕（3.7-30个太阳半径）。大视场CME传播观测。',
    urlPattern:
        'https://soho.nascom.nasa.gov/data/realtime/c3/512/latest.jpg',
    fallbackUrls: [
      'https://sdo.gsfc.nasa.gov/assets/img/browse/{date}/2048_LASCO_C3.jpg',
    ],
    color: Color(0xFF546E7A),
    category: 'LASCO',
  ),
];
