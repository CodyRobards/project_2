import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String _initialResourceName = 'Stardust';
  static const double _initialClickValue = 1;
  static const double _clickValueIncrease = 1;
  static const double _initialPassiveIncome = 0;
  static const double _passiveIncomeIncrease = 0.5;
  static const double _initialClickUpgradeCost = 10;
  static const double _initialPassiveUpgradeCost = 15;
  static const double _clickCostMultiplier = 1.6;
  static const double _passiveCostMultiplier = 1.7;
  static const int _dayDurationSeconds = 20;
  static const int _nightDurationSeconds = 12;
  static const double _nightClickMultiplier = 1.8;
  static const double _nightPassiveMultiplier = 0.6;

  late String _resourceName;
  late double _resourceAmount;
  late double _clickValue;
  late double _passiveIncome;
  late int _clickUpgradeLevel;
  late int _passiveUpgradeLevel;
  late double _clickUpgradeCost;
  late double _passiveUpgradeCost;
  late bool _isNight;
  late int _cycleSecondsRemaining;

  Timer? _passiveTimer;

  @override
  void initState() {
    super.initState();
    _initializeState();
    _startPassiveTimer();
  }

  @override
  void dispose() {
    _passiveTimer?.cancel();
    super.dispose();
  }

  void _initializeState() {
    _resourceName = _initialResourceName;
    _resourceAmount = 0;
    _clickValue = _initialClickValue;
    _passiveIncome = _initialPassiveIncome;
    _clickUpgradeLevel = 0;
    _passiveUpgradeLevel = 0;
    _clickUpgradeCost = _initialClickUpgradeCost;
    _passiveUpgradeCost = _initialPassiveUpgradeCost;
    _isNight = false;
    _cycleSecondsRemaining = _dayDurationSeconds;
  }

  void _startPassiveTimer() {
    _passiveTimer?.cancel();
    _passiveTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _advanceCycle();
        final passiveGain = _currentPassiveIncome;
        if (passiveGain > 0) {
          _resourceAmount += passiveGain;
        }
      });
    });
  }

  void _advanceCycle() {
    if (_cycleSecondsRemaining > 1) {
      _cycleSecondsRemaining -= 1;
      return;
    }
    _isNight = !_isNight;
    _cycleSecondsRemaining =
        _isNight ? _nightDurationSeconds : _dayDurationSeconds;
  }

  double get _currentClickValue =>
      _isNight ? _clickValue * _nightClickMultiplier : _clickValue;

  double get _currentPassiveIncome =>
      _isNight ? _passiveIncome * _nightPassiveMultiplier : _passiveIncome;

  double get _cycleProgress {
    final totalSeconds =
        _isNight ? _nightDurationSeconds : _dayDurationSeconds;
    if (totalSeconds <= 0) {
      return 0;
    }
    return 1 - (_cycleSecondsRemaining / totalSeconds);
  }

  void _collectResource() {
    final clickGain = _currentClickValue;
    setState(() {
      _resourceAmount += clickGain;
    });
  }

  void _purchaseClickUpgrade() {
    if (_resourceAmount < _clickUpgradeCost) {
      return;
    }
    setState(() {
      _resourceAmount -= _clickUpgradeCost;
      _clickUpgradeLevel += 1;
      _clickValue += _clickValueIncrease;
      _clickUpgradeCost *= _clickCostMultiplier;
    });
  }

  void _purchasePassiveUpgrade() {
    if (_resourceAmount < _passiveUpgradeCost) {
      return;
    }
    setState(() {
      _resourceAmount -= _passiveUpgradeCost;
      _passiveUpgradeLevel += 1;
      _passiveIncome += _passiveIncomeIncrease;
      _passiveUpgradeCost *= _passiveCostMultiplier;
    });
  }

  void _resetGame() {
    setState(() {
      _initializeState();
    });
  }

  String _formatNumber(double value) {
    if (value >= 1000) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    final theme = Theme.of(context);
    final cyclePhase = _isNight ? 'Night' : 'Day';
    final nextPhaseLabel = _isNight ? 'Daybreak' : 'Nightfall';
    final clickBonusPercent = ((_nightClickMultiplier - 1) * 100).round();
    final passivePercent = (_nightPassiveMultiplier * 100).round();
    final cycleMessage = _isNight
        ? 'Night surge: clicks earn +$clickBonusPercent% while passive production coasts at $passivePercent% efficiency until daybreak.'
        : 'Daylight stability keeps passive income at full strength. Prepare for nightfall\'s +$clickBonusPercent% click burst balanced by passive at $passivePercent%.';
    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text('${widget.title} - $_resourceName'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: _resetGame,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              'Resource: $_resourceName',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: ${_formatNumber(_resourceAmount)}',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Celestial Cycle',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current Phase: $cyclePhase',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Next shift in $_cycleSecondsRemaining s ($nextPhaseLabel)',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: _cycleProgress,
                      minHeight: 6,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cycleMessage,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Per Click: ${_formatNumber(_currentClickValue)} (Base ${_formatNumber(_clickValue)}, Level $_clickUpgradeLevel)',
              style: theme.textTheme.bodyLarge,
            ),
            Text(
              'Passive Income: ${_formatNumber(_currentPassiveIncome)} / sec (Base ${_formatNumber(_passiveIncome)}, Level $_passiveUpgradeLevel)',
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _collectResource,
              icon: const Icon(Icons.touch_app),
              label: const Text('Collect Stardust'),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Upgrades',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _resourceAmount >= _clickUpgradeCost
                          ? _purchaseClickUpgrade
                          : null,
                      child: Text(
                        'Upgrade Click Power (Cost: ${_formatNumber(_clickUpgradeCost)})',
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _resourceAmount >= _passiveUpgradeCost
                          ? _purchasePassiveUpgrade
                          : null,
                      child: Text(
                        'Upgrade Passive Income (Cost: ${_formatNumber(_passiveUpgradeCost)})',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            OutlinedButton.icon(
              onPressed: _resetGame,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset Progress'),
            ),
          ],
        ),
      ),
    );
  }
}
