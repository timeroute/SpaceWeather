import 'package:flutter/material.dart';
import '../models/space_weather.dart';

class GeomagPage extends StatefulWidget {
  final GeomagData data;
  final List<KpForecast> forecast;
  final DateTime lastUpdated;

  const GeomagPage({
    super.key,
    required this.data,
    required this.forecast,
    required this.lastUpdated,
  });

  @override
  State<GeomagPage> createState() => _GeomagPageState();
}

class _GeomagPageState extends State<GeomagPage> {
  GeomagData get data => widget.data;
  List<KpForecast> get forecast => widget.forecast;
  DateTime get lastUpdated => widget.lastUpdated;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewBanner(),
          const SizedBox(height: 16),
          _buildCurrentSection(),
          const SizedBox(height: 16),
          _buildKpScale(),
          const SizedBox(height: 16),
          if (forecast.isNotEmpty) ...[
            _buildForecastSection(),
            const SizedBox(height: 16),
          ],
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
            Colors.purple.withValues(alpha: 0.15),
            Colors.deepPurple.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.explore, color: Colors.purple, size: 18),
              const SizedBox(width: 8),
              const Text(
                '地磁场活动监测',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '地磁场受太阳风-磁层耦合控制。Kp指数衡量全球地磁活动水平（0-9），'
            'Dst指数反映环电流强度（负值越大表示磁暴越强）。'
            '当Kp≥5时进入地磁暴级别，可能影响卫星运行、导航系统和电力网络。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final kp = data.kp;
    final dst = data.dst ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                '当前地磁状态',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _bigMetric('Kp 指数', kp.toStringAsFixed(1), _kpColor(kp), data.kpSummary)),
              const SizedBox(width: 12),
              Expanded(child: _bigMetric('Dst 指数', '$dst nT', _dstColor(dst), data.dstSummary)),
            ],
          ),
          const SizedBox(height: 16),
          _buildKpGauge(kp),
          const SizedBox(height: 16),
          _buildDstGauge(dst),
        ],
      ),
    );
  }

  Widget _buildKpScale() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.scale, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                'Kp 等级标尺',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Kp（行星际K指数）是全球地磁活动水平的标准化指标，每3小时更新一次。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          _kpScaleRow(),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              _scaleLegend(Colors.green, '平静 (0-2)'),
              _scaleLegend(Colors.yellow, '活跃 (3-4)'),
              _scaleLegend(Colors.orange, '地磁暴 (5-7)'),
              _scaleLegend(Colors.red, '强暴 (8-9)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForecastSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.timeline, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                'Kp 三日预报',
                style: TextStyle(
                  color: Colors.purple,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '基于NOAA SWPC预报模型的未来三日Kp指数预测。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          _buildForecastChart(),
        ],
      ),
    );
  }

  Widget _buildImpactSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final kp = data.kp;

    final impacts = <_ImpactItem>[];
    if (kp >= 5) {
      impacts.add(_ImpactItem('卫星轨道衰减加速', Colors.orange, true));
      impacts.add(_ImpactItem('高频无线电极区吸收', Colors.orange, true));
    }
    if (kp >= 7) {
      impacts.add(_ImpactItem('电力网GIC感应电流风险', Colors.red, true));
      impacts.add(_ImpactItem('极光可见纬度显著南扩', Colors.red, true));
    }
    if ((data.dst ?? 0) <= -50) {
      impacts.add(_ImpactItem('磁暴环电流增强', Colors.red, true));
    }
    if (impacts.isEmpty) {
      impacts.add(_ImpactItem('当前地磁活动平静，无显著影响', Colors.green, false));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.purple.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                '影响评估',
                style: TextStyle(
                  color: Colors.purple,
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

  Widget _bigMetric(String label, String value, Color color, String status) {
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
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Text(
              status,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpGauge(double kp) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Kp', style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11)),
            const Spacer(),
            Text(
              '${kp.toStringAsFixed(1)} / 9.0',
              style: TextStyle(
                color: _kpColor(kp),
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
            value: (kp / 9.0).clamp(0.0, 1.0),
            minHeight: 10,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation(_kpColor(kp)),
          ),
        ),
      ],
    );
  }

  Widget _buildDstGauge(int dst) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final normalized = ((dst + 200) / 200.0).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Dst', style: TextStyle(color: onSurface.withValues(alpha: 0.5), fontSize: 11)),
            const Spacer(),
            Text(
              '$dst nT',
              style: TextStyle(
                color: _dstColor(dst),
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
            value: normalized,
            minHeight: 10,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation(_dstColor(dst)),
          ),
        ),
      ],
    );
  }

  Widget _kpScaleRow() {
    final labels = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    final currentKp = data.kp;
    return Row(
      children: List.generate(9, (i) {
        final color = _kpColor(i.toDouble() + 0.5);
        final isActive = currentKp >= i && currentKp < i + 1;
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? color : color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: isActive
                  ? Border.all(color: color, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isActive ? Colors.white : color,
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _scaleLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildForecastChart() {
    if (forecast.isEmpty) return const SizedBox.shrink();
    final maxKp = forecast.map((f) => f.kp).reduce((a, b) => a > b ? a : b).clamp(1.0, 9.0);
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        SizedBox(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: forecast.take(24).map((f) {
              final height = (f.kp / maxKp * 100).clamp(8.0, 100.0);
              final color = _kpColor(f.kp);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        f.kp.toStringAsFixed(0),
                        style: TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        height: height,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.6),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text(
              '← 近',
              style: TextStyle(color: onSurface.withValues(alpha: 0.4), fontSize: 9),
            ),
            const Spacer(),
            Text(
              '远 →',
              style: TextStyle(color: onSurface.withValues(alpha: 0.4), fontSize: 9),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '每格代表3小时，共显示未来72小时预报',
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.4),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _kpColor(double kp) {
    if (kp < 3) return Colors.green;
    if (kp < 5) return Colors.yellow;
    if (kp < 7) return Colors.orange;
    return Colors.red;
  }

  Color _dstColor(int dst) {
    if (dst >= -10) return Colors.green;
    if (dst >= -30) return Colors.yellow;
    if (dst >= -50) return Colors.orange;
    return Colors.red;
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
