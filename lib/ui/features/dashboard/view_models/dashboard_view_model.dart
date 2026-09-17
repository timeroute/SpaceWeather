import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/space_weather_repository.dart';
import '../../../../models/space_weather.dart';

/// Presentation state and commands for the space-weather dashboard shell.
class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel({
    SpaceWeatherRepository? repository,
    this.refreshInterval = const Duration(minutes: 5),
  }) : _repository = repository ?? SpaceWeatherRepository();

  final SpaceWeatherRepository _repository;
  final Duration refreshInterval;

  SpaceWeatherState _state = SpaceWeatherState(isLoading: true);
  SpaceWeatherState get state => _state;

  int _selectedIndex = 0;
  int get selectedIndex => _selectedIndex;

  Timer? _refreshTimer;
  bool _disposed = false;

  void start() {
    loadData();
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (_) => loadData());
  }

  void selectIndex(int index) {
    if (_selectedIndex == index) return;
    _selectedIndex = index;
    notifyListeners();
  }

  Future<void> loadData() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final next = await _repository.fetchLatest();
      if (_disposed) return;
      _state = next.copyWith(isLoading: false);
      notifyListeners();
    } catch (e) {
      if (_disposed) return;
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _refreshTimer?.cancel();
    _repository.dispose();
    super.dispose();
  }
}
