import 'package:flutter/material.dart';
import '../models/space_weather.dart';

class IonospherePage extends StatefulWidget {
  final IonosphereData ionosphere;
  final AuroraData aurora;
  final GeomagData geomag;
  final DateTime lastUpdated;

  const IonospherePage({
    super.key,
    required this.ionosphere,
    required this.aurora,
    required this.geomag,
    required this.lastUpdated,
  });

  @override
  State<IonospherePage> createState() => _IonospherePageState();
}

class _IonospherePageState extends State<IonospherePage> {
  IonosphereData get ionosphere => widget.ionosphere;
  AuroraData get aurora => widget.aurora;
  GeomagData get geomag => widget.geomag;
  DateTime get lastUpdated => widget.lastUpdated;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewBanner(),
          const SizedBox(height: 16),
          _buildIonosphereSection(),
          const SizedBox(height: 16),
          _buildTecProfile(),
          const SizedBox(height: 16),
          _buildAuroraSection(),
          const SizedBox(height: 16),
          _buildImpactSection(),
        ],
      ),
    );
  }

  Widget _buildOverviewBanner() {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.teal.withValues(alpha: 0.15),
            Colors.green.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.graphic_eq, color: Colors.teal, size: 18),
              const SizedBox(width: 8),
              const Text(
                '电离层与极光态势',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '电离层（60-1000km高度）中的自由电子影响无线电波传播。'
            'TEC（总电子含量）以TECU为单位（1 TECU = 6.28×10¹⁶ e⁻/m²）。'
            '地磁暴期间电离层扰动可导致GNSS定位误差增大、短波通信中断。'
            '极光由太阳风粒子沿磁力线沉降到高层大气激发。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIonosphereSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final tec = ionosphere.avgTec;
    final scint = ionosphere.scintillationLevel;

    Color scintColor;
    switch (scint) {
      case 'Strong':
        scintColor = Colors.red;
        break;
      case 'Moderate':
        scintColor = Colors.orange;
        break;
      case 'Low':
        scintColor = Colors.yellow;
        break;
      default:
        scintColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.waves, color: Colors.teal, size: 16),
              const SizedBox(width: 8),
              Text(
                '电离层参数',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _bigMetric(
                  '平均 TEC',
                  '${tec.toStringAsFixed(1)} TECU',
                  Colors.teal,
                  _tecLabel(tec),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigMetric(
                  '闪烁等级',
                  scint,
                  scintColor,
                  _scintLabel(scint),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _tecGauge(tec),
          const SizedBox(height: 12),
          _scintIndicator(scint, scintColor),
        ],
      ),
    );
  }

  Widget _buildTecProfile() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final values = ionosphere.tecValues;
    if (values.isEmpty) return const SizedBox.shrink();

    final maxVal = values.reduce((a, b) => a > b ? a : b).clamp(1.0, 100.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.show_chart, color: Colors.teal, size: 16),
              const SizedBox(width: 8),
              Text(
                'TEC 空间分布剖面',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '沿磁力线纬度方向的TEC分布示意（模拟值）',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: CustomPaint(
              size: Size.infinite,
              painter: _TecChartPainter(
                values: values,
                maxValue: maxVal,
                color: Colors.teal,
                onSurface: onSurface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                '低纬',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                '磁赤道',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              ),
              const Spacer(),
              Text(
                '高纬',
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAuroraSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final level = aurora.estimatedLevel;
    final kp = aurora.kp;
    final lats = aurora.ovalLatitudes;

    Color levelColor;
    if (level >= 4) {
      levelColor = Colors.red;
    } else if (level >= 2) {
      levelColor = Colors.yellow;
    } else {
      levelColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.green.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Text(
                '极光预报',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _bigMetric(
                  'G 等级',
                  'G$level',
                  levelColor,
                  _auroraLabel(level),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _bigMetric(
                  '极光椭圆纬度',
                  lats.isNotEmpty ? '${lats.first.toStringAsFixed(0)}°' : '-',
                  Colors.green,
                  '可见边界',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _auroraOvalVisual(kp),
          const SizedBox(height: 12),
          _auroraVisibilityInfo(level, lats),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final scint = ionosphere.scintillationLevel;
    final level = aurora.estimatedLevel;
    final tec = ionosphere.avgTec;

    final impacts = <_ImpactItem>[];

    if (scint == 'Strong' || scint == 'Moderate') {
      impacts.add(_ImpactItem('GNSS 定位精度下降', Colors.orange, true));
      impacts.add(_ImpactItem('短波通信可能中断', Colors.orange, true));
    }
    if (tec > 30) {
      impacts.add(_ImpactItem('TEC 异常偏高，可能影响卫星信号传播', Colors.yellow, true));
    }
    if (level >= 4) {
      impacts.add(_ImpactItem('中纬度地区可见极光', Colors.green, true));
    }
    if (impacts.isEmpty) {
      impacts.add(_ImpactItem('电离层状态平稳，无显著影响', Colors.green, false));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.teal, size: 16),
              const SizedBox(width: 8),
              Text(
                '影响评估',
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in impacts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.text,
                      style: TextStyle(
                        color: onSurface.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                  if (item.active)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: item.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '活跃',
                        style: TextStyle(
                          color: item.color,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bigMetric(String label, String value, Color color, String sublabel) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            sublabel,
            style: TextStyle(
              color: color.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tecGauge(double tec) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('TEC 强度',
                style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11)),
            const Spacer(),
            Text(
              '${tec.toStringAsFixed(1)} / 60 TECU',
              style: TextStyle(
                color: Colors.teal,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: (tec / 60.0).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: const AlwaysStoppedAnimation(Colors.teal),
          ),
        ),
      ],
    );
  }

  Widget _scintIndicator(String level, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final levels = ['None', 'Low', 'Moderate', 'Strong'];
    final currentIdx = levels.indexOf(level);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '电离层闪烁',
          style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11),
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(levels.length, (i) {
            final isActive = i <= currentIdx;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                height: 8,
                decoration: BoxDecoration(
                  color: isActive ? color : Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 4),
        Row(
          children: levels.map((l) {
            return Expanded(
              child: Text(
                l,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.4),
                  fontSize: 9,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _auroraOvalVisual(double kp) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final ovalRadius = (90.0 - kp * 3).clamp(10.0, 40.0);

    return SizedBox(
      height: 160,
      child: CustomPaint(
        size: Size.infinite,
        painter: _AuroraOvalPainter(
          ovalRadius: ovalRadius,
          kp: kp,
          onSurface: onSurface,
          dividerColor: theme.dividerColor,
        ),
      ),
    );
  }

  Widget _auroraVisibilityInfo(int level, List<double> lats) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    String visibility;
    if (level >= 5) {
      visibility = '低纬度地区（<40°）可见极光';
    } else if (level >= 4) {
      visibility = '中纬度地区（40-50°）可见极光';
    } else if (level >= 3) {
      visibility = '较高纬度地区（50-60°）可见极光';
    } else if (level >= 2) {
      visibility = '极区和高纬度（>60°）可见极光';
    } else {
      visibility = '仅极区内部可见微弱极光';
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.visibility, color: Colors.green, size: 14),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              visibility,
              style: TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (lats.isNotEmpty)
            Text(
              '椭圆边界: ${lats.first.toStringAsFixed(0)}°-${lats.last.toStringAsFixed(0)}°',
              style: TextStyle(
                color: onSurface.withValues(alpha: 0.5),
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  String _tecLabel(double tec) {
    if (tec < 10) return '低';
    if (tec < 25) return '正常';
    if (tec < 40) return '偏高';
    return '异常高';
  }

  String _scintLabel(String level) {
    switch (level) {
      case 'Strong':
        return '严重影响';
      case 'Moderate':
        return '中等影响';
      case 'Low':
        return '轻微';
      default:
        return '无闪烁';
    }
  }

  String _auroraLabel(int level) {
    if (level >= 5) return '极端';
    if (level >= 4) return '强';
    if (level >= 3) return '中等';
    if (level >= 2) return '弱';
    return '平静';
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}

class _ImpactItem {
  final String text;
  final Color color;
  final bool active;

  _ImpactItem(this.text, this.color, this.active);
}

class _TecChartPainter extends CustomPainter {
  final List<double> values;
  final double maxValue;
  final Color color;
  final Color onSurface;

  _TecChartPainter({
    required this.values,
    required this.maxValue,
    required this.color,
    required this.onSurface,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final barWidth = size.width / values.length * 0.6;
    final gap = size.width / values.length * 0.4;

    for (int i = 0; i < values.length; i++) {
      final x = i * (barWidth + gap) + gap / 2;
      final barHeight = (values[i] / maxValue * size.height * 0.85).clamp(4.0, size.height * 0.85);
      final y = size.height - barHeight;

      final paint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        ),
        paint,
      );

      final valuePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, barWidth, barHeight),
          const Radius.circular(3),
        ),
        valuePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TecChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.maxValue != maxValue;
  }
}

class _AuroraOvalPainter extends CustomPainter {
  final double ovalRadius;
  final double kp;
  final Color onSurface;
  final Color dividerColor;

  _AuroraOvalPainter({
    required this.ovalRadius,
    required this.kp,
    required this.onSurface,
    required this.dividerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final earthRadius = size.height * 0.15;
    final maxOvalRadius = size.height * 0.45;

    final earthPaint = Paint()
      ..color = const Color(0xFF1565C0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, earthRadius, earthPaint);

    final earthOutline = Paint()
      ..color = const Color(0xFF42A5F5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, earthRadius, earthOutline);

    final ovalScreenRadius = (ovalRadius / 40.0 * maxOvalRadius).clamp(
      earthRadius + 5,
      maxOvalRadius,
    );

    final ovalPaint = Paint()
      ..color = Colors.green.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawOval(
      Rect.fromCircle(center: center, radius: ovalScreenRadius),
      ovalPaint,
    );

    final ovalGlow = Paint()
      ..color = Colors.green.withValues(alpha: 0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16;
    canvas.drawOval(
      Rect.fromCircle(center: center, radius: ovalScreenRadius),
      ovalGlow,
    );

    final gridPaint = Paint()
      ..color = dividerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    for (int r = 1; r <= 3; r++) {
      canvas.drawCircle(center, earthRadius + r * 20.0, gridPaint);
    }

    final labelPaint = TextPainter(
      text: TextSpan(
        text: 'N',
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.5),
          fontSize: 10,
        ),
      ),
      textAlign: TextAlign.center,
    )..layout();
    labelPaint.paint(canvas, Offset(center.dx - 4, center.dy - earthRadius - 14));

    final kpLabel = TextPainter(
      text: TextSpan(
        text: 'Kp=${kp.toStringAsFixed(1)}',
        style: TextStyle(
          color: onSurface.withValues(alpha: 0.4),
          fontSize: 9,
        ),
      ),
      textAlign: TextAlign.center,
    )..layout();
    kpLabel.paint(canvas, Offset(center.dx - 20, size.height - 14));
  }

  @override
  bool shouldRepaint(covariant _AuroraOvalPainter oldDelegate) {
    return oldDelegate.ovalRadius != ovalRadius || oldDelegate.kp != kp;
  }
}
