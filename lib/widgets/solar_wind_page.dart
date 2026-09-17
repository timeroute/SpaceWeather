import 'package:flutter/material.dart';
import '../models/space_weather.dart';

class SolarWindPage extends StatefulWidget {
  final SolarWindData data;
  final DateTime lastUpdated;

  const SolarWindPage({
    super.key,
    required this.data,
    required this.lastUpdated,
  });

  @override
  State<SolarWindPage> createState() => _SolarWindPageState();
}

class _SolarWindPageState extends State<SolarWindPage> {
  SolarWindData get data => widget.data;
  DateTime get lastUpdated => widget.lastUpdated;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildOverviewBanner(),
          const SizedBox(height: 16),
          _buildBulkParametersSection(),
          const SizedBox(height: 16),
          _buildImfSection(),
          const SizedBox(height: 16),
          _buildAssessmentSection(),
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
            Colors.cyan.withValues(alpha: 0.15),
            Colors.blue.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.air, color: Colors.cyan, size: 18),
              const SizedBox(width: 8),
              const Text(
                '实时太阳风参数',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '太阳风是从日冕层持续流出的带电粒子流，主要由质子和电子组成。'
            'ACE卫星位于日地L1拉格朗日点，可提前约30-60分钟预警太阳风变化到达地球。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulkParametersSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final speed = data.speed ?? 400;
    final density = data.density ?? 5;
    final temp = data.temperature ?? 100000;
    final pressure = data.dynamicPressure ?? 2.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.cyan.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.speed, color: Colors.cyan, size: 16),
              const SizedBox(width: 8),
              Text(
                '体参数 Bulk Parameters',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _metricCard(
            '太阳风速度',
            'Speed',
            '${speed.toStringAsFixed(0)} km/s',
            _speedGauge(speed),
            _speedColor(speed),
            _speedLabel(speed),
          ),
          const SizedBox(height: 12),
          _metricCard(
            '粒子密度',
            'Density',
            '${density.toStringAsFixed(1)} p/cm³',
            (density / 30.0).clamp(0.0, 1.0),
            _densityColor(density),
            _densityLabel(density),
          ),
          const SizedBox(height: 12),
          _metricCard(
            '离子温度',
            'Temperature',
            '${(temp / 1000).toStringAsFixed(0)}×10³ K',
            (temp / 500000).clamp(0.0, 1.0),
            _tempColor(temp),
            _tempLabel(temp),
          ),
          const SizedBox(height: 12),
          _metricCard(
            '动态压力',
            'Dynamic Pressure',
            '${pressure.toStringAsFixed(2)} nPa',
            (pressure / 10.0).clamp(0.0, 1.0),
            _pressureColor(pressure),
            _pressureLabel(pressure),
          ),
        ],
      ),
    );
  }

  Widget _buildImfSection() {
    final theme = Theme.of(context);
    final bt = data.bt ?? 5.0;
    final bz = data.bz ?? 0.0;
    final bx = data.bx ?? 0.0;
    final by = data.by ?? 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.indigo.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.compass_calibration, color: Colors.indigo, size: 16),
              const SizedBox(width: 8),
              Text(
                '行星际磁场 IMF',
                style: TextStyle(
                  color: Colors.indigo,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '行星际磁场（IMF）由太阳风携带，其南向分量（Bz<0）是触发地磁暴的关键因素。',
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _imfComponent('|B| 总场', bt, 'nT', Colors.indigo)),
              const SizedBox(width: 12),
              Expanded(child: _imfComponent('Bz 南向', bz, 'nT', _bzColor(bz))),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _imfComponent('Bx', bx, 'nT', Colors.teal)),
              const SizedBox(width: 12),
              Expanded(child: _imfComponent('By', by, 'nT', Colors.amber)),
            ],
          ),
          const SizedBox(height: 16),
          _bzAssessment(bz),
        ],
      ),
    );
  }

  Widget _buildAssessmentSection() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final speed = data.speed ?? 400;
    final density = data.density ?? 5;
    final pressure = data.dynamicPressure ?? 2.0;
    final bz = data.bz ?? 0;

    String overall;
    Color overallColor;
    if (speed > 800 || bz < -10 || pressure > 8) {
      overall = '显著扰动';
      overallColor = Colors.red;
    } else if (speed > 600 || bz < -5 || pressure > 5) {
      overall = '轻度扰动';
      overallColor = Colors.orange;
    } else {
      overall = '平静';
      overallColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: overallColor.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield, color: overallColor, size: 16),
              const SizedBox(width: 8),
              Text(
                '综合评估',
                style: TextStyle(
                  color: overallColor,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: overallColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: overallColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  overall,
                  style: TextStyle(
                    color: overallColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _assessRow('速度', speed > 600 ? '高于背景值' : '正常范围',
              speed > 600 ? Colors.orange : Colors.green),
          _assessRow('密度', density > 15 ? '高密度' : '正常范围',
              density > 15 ? Colors.orange : Colors.green),
          _assessRow('动压', pressure > 5 ? '高压脉冲' : '正常范围',
              pressure > 5 ? Colors.orange : Colors.green),
          _assessRow('IMF Bz',
              bz < -5 ? '南向 — 有利于能量耦合' : '非显著南向',
              bz < -5 ? Colors.orange : Colors.green),
          const SizedBox(height: 8),
          Text(
            '注：太阳风参数需结合地磁场响应综合判断。高速流、南向Bz和高动压同时出现时，地磁暴风险最高。',
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.4),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricCard(
    String labelZh,
    String labelEn,
    String value,
    double gauge,
    Color color,
    String label,
  ) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                labelZh,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.6),
                  fontSize: 11,
                ),
              ),
              Text(
                labelEn,
                style: TextStyle(
                  color: onSurface.withValues(alpha: 0.3),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: gauge,
              minHeight: 8,
              backgroundColor: Theme.of(context).dividerColor,
              valueColor: AlwaysStoppedAnimation(color.withValues(alpha: 0.7)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: color.withValues(alpha: 0.7),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _imfComponent(String label, double value, String unit, Color color) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
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
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.5),
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value.toStringAsFixed(1)} $unit',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bzAssessment(double bz) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    String text;
    Color color;
    if (bz < -10) {
      text = '强南向 — 极易触发地磁暴，对磁层能量输入极为有利';
      color = Colors.red;
    } else if (bz < -5) {
      text = '中等南向 — 有利于磁层-太阳风耦合，可能引发地磁扰动';
      color = Colors.orange;
    } else if (bz < 0) {
      text = '弱南向 — 有一定能量输入，但通常不足以引发强风暴';
      color = Colors.yellow;
    } else {
      text = '北向 — 磁层处于低耦合状态，地磁活动受到抑制';
      color = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(
            bz < 0 ? Icons.arrow_downward : Icons.arrow_upward,
            color: color,
            size: 14,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _assessRow(String param, String status, Color color) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            param,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  double _speedGauge(double speed) => (speed / 1000.0).clamp(0.0, 1.0);

  Color _speedColor(double speed) {
    if (speed < 400) return Colors.green;
    if (speed < 600) return Colors.cyan;
    if (speed < 800) return Colors.orange;
    return Colors.red;
  }

  String _speedLabel(double speed) {
    if (speed < 300) return '低速流';
    if (speed < 500) return '背景风';
    if (speed < 700) return '高速流';
    return '极端高速';
  }

  Color _densityColor(double d) {
    if (d < 5) return Colors.green;
    if (d < 15) return Colors.cyan;
    if (d < 30) return Colors.orange;
    return Colors.red;
  }

  String _densityLabel(double d) {
    if (d < 5) return '低密度';
    if (d < 15) return '正常';
    if (d < 30) return '高密度';
    return '极高密度';
  }

  Color _tempColor(double t) {
    if (t < 50000) return Colors.green;
    if (t < 200000) return Colors.cyan;
    if (t < 500000) return Colors.orange;
    return Colors.red;
  }

  String _tempLabel(double t) {
    if (t < 50000) return '冷';
    if (t < 200000) return '正常';
    if (t < 500000) return '偏热';
    return '极热';
  }

  Color _pressureColor(double p) {
    if (p < 3) return Colors.green;
    if (p < 5) return Colors.cyan;
    if (p < 8) return Colors.orange;
    return Colors.red;
  }

  String _pressureLabel(double p) {
    if (p < 2) return '低压';
    if (p < 4) return '正常';
    if (p < 7) return '高压';
    return '极端高压';
  }

  Color _bzColor(double bz) {
    if (bz < -10) return Colors.red;
    if (bz < -5) return Colors.orange;
    if (bz < 0) return Colors.yellow;
    return Colors.green;
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  }
}
