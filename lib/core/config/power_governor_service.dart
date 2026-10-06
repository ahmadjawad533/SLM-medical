/// ---------------------------------------------------------------------------
/// SOLAR / BATTERY-AWARE POWER GOVERNOR SERVICE
/// ---------------------------------------------------------------------------
/// Monitors battery charge level and solar input. Dynamically throttles CPU threads,
/// reduces screen brightness, and disables heavy LLM inference when running on low battery.

import 'dart:async';

enum PowerStateMode {
  fullPerformance, // Battery > 50%: 4 threads, 2048 context
  balancedEco,     // Battery 20-50%: 2-3 threads, 1024 context
  batterySaver     // Battery < 20%: 2 threads, LLM disabled, low-power dark UI
}

class PowerGovernorService {
  int _batteryLevel = 85; // Default 85%
  bool _isSolarCharging = true;
  PowerStateMode _currentMode = PowerStateMode.fullPerformance;

  final StreamController<PowerStateMode> _powerStateController = StreamController<PowerStateMode>.broadcast();

  Stream<PowerStateMode> get powerStateStream => _powerStateController.stream;
  int get batteryLevel => _batteryLevel;
  bool get isSolarCharging => _isSolarCharging;
  PowerStateMode get currentMode => _currentMode;

  /// Updates battery status and adjusts power state governor.
  void updateBatteryStatus(int percentage, {bool isCharging = false}) {
    _batteryLevel = percentage;
    _isSolarCharging = isCharging;

    if (_batteryLevel < 20 && !_isSolarCharging) {
      _currentMode = PowerStateMode.batterySaver;
    } else if (_batteryLevel < 50 && !_isSolarCharging) {
      _currentMode = PowerStateMode.balancedEco;
    } else {
      _currentMode = PowerStateMode.fullPerformance;
    }

    _powerStateController.add(_currentMode);
    print("[⚡ POWER GOVERNOR] Battery: $_batteryLevel% | Solar Charging: $_isSolarCharging | Mode: ${_currentMode.name.toUpperCase()}");
  }
}
