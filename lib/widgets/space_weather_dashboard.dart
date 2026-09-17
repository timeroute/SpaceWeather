import 'package:flutter/material.dart';

import '../models/space_weather.dart';
import '../ui/features/dashboard/view_models/dashboard_view_model.dart';
import 'geomag_page.dart';
import 'ionosphere_page.dart';
import 'solar_activity_page.dart';
import 'solar_wind_page.dart';

const double _compactBreakpoint = 600;

class SpaceWeatherDashboard extends StatefulWidget {
  const SpaceWeatherDashboard({super.key});

  @override
  State<SpaceWeatherDashboard> createState() => _SpaceWeatherDashboardState();
}

class _SpaceWeatherDashboardState extends State<SpaceWeatherDashboard> {
  late final DashboardViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = DashboardViewModel()..start();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _viewModel,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isCompact = constraints.maxWidth < _compactBreakpoint;
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: isCompact
                  ? AppBar(
                      title: const Text('空间天气'),
                      actions: [
                        if (_viewModel.state.isLoading)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.refresh),
                          onPressed: _viewModel.loadData,
                        ),
                      ],
                    )
                  : null,
              body: SafeArea(
                child: isCompact
                    ? Column(
                        children: [
                          Expanded(child: _buildContent()),
                          _buildBottomNav(),
                        ],
                      )
                    : Row(
                        children: [
                          _buildSidebar(),
                          Expanded(child: _buildContent()),
                        ],
                      ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBottomNav() {
    final theme = Theme.of(context);
    return NavigationBar(
      selectedIndex: _viewModel.selectedIndex,
      onDestinationSelected: _viewModel.selectIndex,
      height: 64,
      destinations: [
        NavigationDestination(
          icon: Icon(Icons.home_outlined, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          selectedIcon: const Icon(Icons.home, color: Colors.cyan),
          label: '首页',
        ),
        const NavigationDestination(
          icon: Icon(Icons.wb_sunny_outlined, color: Colors.orange),
          selectedIcon: Icon(Icons.wb_sunny, color: Colors.orange),
          label: '太阳',
        ),
        const NavigationDestination(
          icon: Icon(Icons.air_outlined, color: Colors.cyan),
          selectedIcon: Icon(Icons.air, color: Colors.cyan),
          label: '太阳风',
        ),
        const NavigationDestination(
          icon: Icon(Icons.explore_outlined, color: Colors.purple),
          selectedIcon: Icon(Icons.explore, color: Colors.purple),
          label: '地磁',
        ),
        const NavigationDestination(
          icon: Icon(Icons.graphic_eq_outlined, color: Colors.teal),
          selectedIcon: Icon(Icons.graphic_eq, color: Colors.teal),
          label: '电离层',
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final state = _viewModel.state;
    final sw = state.solarWind;
    final updated = state.lastUpdated.toUtc();

    return SizedBox(
      width: 200,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          border: Border(
            right: BorderSide(color: onSurface.withValues(alpha: 0.1)),
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.public, color: Colors.cyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '空间天气',
                    style: TextStyle(
                      color: onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  if (state.isLoading)
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: Colors.cyan,
                      ),
                    ),
                  if (state.isLoading) const SizedBox(width: 4),
                  InkWell(
                    onTap: _viewModel.loadData,
                    borderRadius: BorderRadius.circular(4),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        Icons.refresh,
                        color: onSurface.withValues(alpha: 0.5),
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: _buildAlertBadge(),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _buildNavItem(0, Icons.home, '首页', 'Home'),
                  _buildNavItem(1, Icons.wb_sunny, '太阳活动', 'Solar Activity', Colors.orange),
                  _buildNavItem(2, Icons.air, '太阳风', 'Solar Wind', Colors.cyan),
                  _buildNavItem(3, Icons.explore, '地磁场', 'Geomagnetic', Colors.purple),
                  _buildNavItem(4, Icons.graphic_eq, '电离层', 'Ionosphere', Colors.teal),
                ],
              ),
            ),
            if (state.error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  state.error!,
                  style: const TextStyle(color: Colors.orange, fontSize: 10),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.02),
                border: Border(
                  top: BorderSide(color: onSurface.withValues(alpha: 0.1)),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _statusItem('数据源', 'NOAA SWPC'),
                  const SizedBox(height: 4),
                  _statusItem('太阳风', '${sw.speed?.toStringAsFixed(0) ?? '-'} km/s'),
                  const SizedBox(height: 4),
                  _statusItem('IMF Bz', '${sw.bz?.toStringAsFixed(1) ?? '-'} nT'),
                  const SizedBox(height: 4),
                  _statusItem('Kp', state.geomag.kp.toStringAsFixed(1)),
                  const SizedBox(height: 4),
                  _statusItem('Dst', '${state.geomag.dst ?? 0} nT'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _statusItem(
                        '更新',
                        '${updated.hour.toString().padLeft(2, '0')}:${updated.minute.toString().padLeft(2, '0')} UTC',
                      ),
                      const Spacer(),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: state.error != null
                              ? Colors.orange
                              : state.isLoading
                                  ? Colors.yellow
                                  : Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    String label,
    String subtitle, [
    Color? color,
  ]) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;
    final isSelected = _viewModel.selectedIndex == index;
    final itemColor = color ?? onSurface;

    return InkWell(
      onTap: () => _viewModel.selectIndex(index),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? itemColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(6),
          border: isSelected
              ? Border.all(color: itemColor.withValues(alpha: 0.3))
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? itemColor : onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: isSelected
                          ? itemColor
                          : onSurface.withValues(alpha: 0.8),
                      fontSize: 13,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: onSurface.withValues(alpha: 0.4),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final state = _viewModel.state;
    return Column(
      children: [
        if (state.error != null &&
            MediaQuery.sizeOf(context).width < _compactBreakpoint)
          Material(
            color: Colors.orange.withValues(alpha: 0.15),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.error!,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _viewModel.loadData,
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          ),
        Expanded(child: _buildPage(state)),
      ],
    );
  }

  Widget _buildPage(SpaceWeatherState state) {
    // IndexedStack keeps SolarActivityPage (and its loaded images) alive
    // when switching between tabs.
    return IndexedStack(
      index: _viewModel.selectedIndex,
      sizing: StackFit.expand,
      children: [
        _buildHomePage(state),
        const SolarActivityPage(),
        SolarWindPage(
          data: state.solarWind,
          lastUpdated: state.lastUpdated,
        ),
        GeomagPage(
          data: state.geomag,
          forecast: state.kpForecast,
          lastUpdated: state.lastUpdated,
        ),
        IonospherePage(
          ionosphere: state.ionosphere,
          aurora: state.aurora,
          geomag: state.geomag,
          lastUpdated: state.lastUpdated,
        ),
      ],
    );
  }

  Widget _buildHomePage(SpaceWeatherState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildSolarCard(state),
          const SizedBox(height: 16),
          _buildSolarWindCard(state),
          const SizedBox(height: 16),
          _buildGeomagCard(state),
          const SizedBox(height: 16),
          _buildIonosphereCard(state),
        ],
      ),
    );
  }

  Widget _buildAlertBadge() {
    final kp = _viewModel.state.geomag.kp;
    final (label, color) = kp >= 7
        ? ('GEOMAGNETIC STORM', Colors.red)
        : kp >= 5
            ? ('UNSETTLED', Colors.orange)
            : ('NORMAL', Colors.green);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusItem(String label, String value) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.4),
            fontSize: 11,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: onSurface.withValues(alpha: 0.8),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildSolarCard(SpaceWeatherState state) {
    final xray = state.xray;
    final Color flareColor;
    if (xray.classification.startsWith('X')) {
      flareColor = Colors.red;
    } else if (xray.classification.startsWith('M')) {
      flareColor = Colors.orange;
    } else if (xray.classification.startsWith('C')) {
      flareColor = Colors.yellow;
    } else {
      flareColor = Colors.green;
    }

    return _DomainCard(
      title: '太阳活动',
      subtitle: 'Solar Activity',
      icon: Icons.wb_sunny,
      accentColor: Colors.orange,
      onTap: () => _viewModel.selectIndex(1),
      child: Column(
        children: [
          _dataRow('X射线分类', xray.classification, valueColor: flareColor),
          _dataRow('短波 (0.05-0.4nm)', _formatSci(xray.shortWave)),
          _dataRow('长波 (0.1-0.8nm)', _formatSci(xray.longWave)),
          Divider(height: 16, color: Theme.of(context).dividerColor),
          Row(
            children: [
              _miniStat('活动区', '${state.activeRegions.length}', Colors.orange),
              const SizedBox(width: 12),
              _miniStat(
                'CME',
                '${state.cmes.length}',
                state.cmes.isNotEmpty ? Colors.red : Colors.green,
              ),
              const Spacer(),
              if (state.cmes.isNotEmpty)
                Chip(
                  label: const Text('CME 事件'),
                  backgroundColor: Colors.red.withValues(alpha: 0.15),
                  side: BorderSide(color: Colors.red.withValues(alpha: 0.3)),
                  labelStyle: const TextStyle(color: Colors.red, fontSize: 11),
                  padding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSolarWindCard(SpaceWeatherState state) {
    final sw = state.solarWind;
    return _DomainCard(
      title: '太阳风',
      subtitle: 'Solar Wind',
      icon: Icons.air,
      accentColor: Colors.cyan,
      onTap: () => _viewModel.selectIndex(2),
      child: Column(
        children: [
          _dataRow(
            '速度',
            '${sw.speed?.toStringAsFixed(0) ?? '-'} km/s',
            valueColor: _speedColor(sw.speed ?? 400),
          ),
          _dataRow('密度', '${sw.density?.toStringAsFixed(1) ?? '-'} p/cm³'),
          _dataRow(
            '动压',
            '${sw.dynamicPressure?.toStringAsFixed(2) ?? '-'} nPa',
            valueColor: _pressureColor(sw.dynamicPressure ?? 2),
          ),
          _dataRow(
            'IMF Bz',
            '${sw.bz?.toStringAsFixed(1) ?? '-'} nT',
            valueColor: _bzColor(sw.bz ?? 0),
          ),
          _dataRow('IMF |B|', '${sw.bt?.toStringAsFixed(1) ?? '-'} nT'),
          Divider(height: 16, color: Theme.of(context).dividerColor),
          _buildProgressBar(
            '太阳风速度',
            (sw.speed ?? 400) / 1000.0,
            _speedColor(sw.speed ?? 400),
          ),
        ],
      ),
    );
  }

  Widget _buildGeomagCard(SpaceWeatherState state) {
    final theme = Theme.of(context);
    final geo = state.geomag;
    return _DomainCard(
      title: '地磁场',
      subtitle: 'Geomagnetic Field',
      icon: Icons.explore,
      accentColor: Colors.purple,
      onTap: () => _viewModel.selectIndex(3),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _dataRow(
                  'Kp 指数',
                  geo.kp.toStringAsFixed(1),
                  valueColor: _kpColor(geo.kp),
                ),
              ),
              _statusChip(geo.kpSummary, _kpColor(geo.kp)),
            ],
          ),
          _dataRow(
            'Dst',
            '${geo.dst ?? 0} nT',
            valueColor: _dstColor(geo.dst ?? 0),
          ),
          Divider(height: 16, color: theme.dividerColor),
          _buildProgressBar('Kp 等级', geo.kp / 9.0, _kpColor(geo.kp)),
          if (state.kpForecast.isNotEmpty) ...[
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Kp 预报',
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  fontSize: 11,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                for (final f in state.kpForecast.take(8))
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _kpColor(f.kp).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _kpColor(f.kp).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      f.kp.toStringAsFixed(0),
                      style: TextStyle(
                        color: _kpColor(f.kp),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIonosphereCard(SpaceWeatherState state) {
    final iono = state.ionosphere;
    final aurora = state.aurora;
    return _DomainCard(
      title: '电离层 & 极光',
      subtitle: 'Ionosphere & Aurora',
      icon: Icons.graphic_eq,
      accentColor: Colors.teal,
      onTap: () => _viewModel.selectIndex(4),
      child: Column(
        children: [
          _dataRow('TEC (平均)', '${iono.avgTec.toStringAsFixed(1)} TECU'),
          _dataRow(
            '闪烁等级',
            iono.scintillationLevel,
            valueColor: iono.scintillationLevel == 'Strong'
                ? Colors.red
                : iono.scintillationLevel == 'Moderate'
                    ? Colors.orange
                    : Colors.green,
          ),
          _dataRow(
            '极光等级',
            'G${aurora.estimatedLevel}',
            valueColor: aurora.estimatedLevel >= 4
                ? Colors.red
                : aurora.estimatedLevel >= 2
                    ? Colors.yellow
                    : Colors.green,
          ),
          _dataRow(
            '极光纬度',
            aurora.ovalLatitudes.isNotEmpty
                ? '${aurora.ovalLatitudes.first.toStringAsFixed(0)}°'
                : '-',
          ),
          Divider(height: 16, color: Theme.of(context).dividerColor),
          _buildProgressBar(
            'TEC 强度',
            (iono.avgTec / 60.0).clamp(0.0, 1.0),
            Colors.teal,
          ),
        ],
      ),
    );
  }

  Widget _dataRow(String label, String value, {Color? valueColor}) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: onSurface.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? onSurface.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.5),
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double progress, Color color) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontSize: 10,
              ),
            ),
            const Spacer(),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            minHeight: 4,
            backgroundColor: theme.dividerColor,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  String _formatSci(double? val) {
    if (val == null) return '-';
    if (val < 0.001) return val.toStringAsExponential(1);
    return val.toStringAsFixed(4);
  }

  Color _speedColor(double speed) {
    if (speed < 400) return Colors.green;
    if (speed < 600) return Colors.yellow;
    if (speed < 800) return Colors.orange;
    return Colors.red;
  }

  Color _pressureColor(double p) {
    if (p < 3) return Colors.green;
    if (p < 5) return Colors.yellow;
    if (p < 8) return Colors.orange;
    return Colors.red;
  }

  Color? _bzColor(double bz) {
    if (bz < -10) return Colors.red;
    if (bz < -5) return Colors.orange;
    if (bz > 5) return Colors.green;
    return null;
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
}

class _DomainCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final Widget child;
  final VoidCallback? onTap;

  const _DomainCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = Card(
      color: theme.colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: accentColor.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: accentColor),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.35),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (onTap != null)
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: accentColor.withValues(alpha: 0.4),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );

    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}
