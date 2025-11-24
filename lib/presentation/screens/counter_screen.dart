import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:al_tadkhira/data/models/zikr.dart';
import 'package:al_tadkhira/data/models/zikr_history.dart';
import 'package:al_tadkhira/presentation/providers/providers.dart';
import 'dart:async';

class CounterScreen extends ConsumerStatefulWidget {
  final Zikr zikr;

  const CounterScreen({super.key, required this.zikr});

  @override
  ConsumerState<CounterScreen> createState() => _CounterScreenState();
}

class _CounterScreenState extends ConsumerState<CounterScreen> {
  late int _currentCount;
  int _currentPartIndex = 0;
  Timer? _autoIncrementTimer;
  bool _isAutoIncrementing = false;

  @override
  void initState() {
    super.initState();
    _currentCount = 0; // Initial load should fetch from DB
    _loadTodayCount();
  }

  Future<void> _loadTodayCount() async {
    final historyRepo = ref.read(historyRepositoryProvider);
    final count = await historyRepo.getCountForZikrToday(
      widget.zikr.id!,
      DateTime.now(),
    );
    setState(() {
      // If simple zikr, load total count.
      // If multi-part, we might want to save state of current part?
      // For MVP, we start from part 0 every time or just don't persist part index.
      // But we should persist the main count.
      // If we are in multi-part mode, _currentCount represents the count for the CURRENT PART.
      // So we start at 0.
      if (widget.zikr.parts.isEmpty) {
        _currentCount = count;
      } else {
        _currentCount = 0;
      }
    });
  }

  @override
  void dispose() {
    _autoIncrementTimer?.cancel();
    super.dispose();
  }

  void _increment() {
    setState(() {
      _currentCount++;
    });
    HapticFeedback.lightImpact();

    if (widget.zikr.parts.isNotEmpty) {
      final currentPart = widget.zikr.parts[_currentPartIndex];
      if (_currentCount >= currentPart.target) {
        // Part completed
        HapticFeedback.mediumImpact();

        if (_currentPartIndex < widget.zikr.parts.length - 1) {
          // Move to next part
          Timer(const Duration(milliseconds: 200), () {
            setState(() {
              _currentCount = 0;
              _currentPartIndex++;
            });
          });
        } else {
          // All parts completed (Wazifa done once)
          HapticFeedback.heavyImpact();
          _logHistory(1); // Log 1 full completion

          // Reset to start
          Timer(const Duration(milliseconds: 500), () {
            setState(() {
              _currentCount = 0;
              _currentPartIndex = 0;
            });
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Wazifa Completed!')));
          });
        }
      }
    } else {
      // Simple Zikr
      _logHistory(1);
    }
  }

  void _decrement() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      HapticFeedback.lightImpact();
      if (widget.zikr.parts.isEmpty) {
        _logHistory(-1);
      }
    }
  }

  Future<void> _logHistory(int amount) async {
    final historyRepo = ref.read(historyRepositoryProvider);
    final history = ZikrHistory(
      zikrId: widget.zikr.id!,
      count: amount,
      timestamp: DateTime.now(),
      source: _isAutoIncrementing ? 'auto' : 'manual',
    );
    await historyRepo.log(history);
  }

  void _toggleAutoIncrement() {
    if (_isAutoIncrementing) {
      _autoIncrementTimer?.cancel();
      setState(() {
        _isAutoIncrementing = false;
      });
    } else {
      setState(() {
        _isAutoIncrementing = true;
      });
      _autoIncrementTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _increment();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasParts = widget.zikr.parts.isNotEmpty;
    final currentPart = hasParts ? widget.zikr.parts[_currentPartIndex] : null;
    final target = hasParts ? currentPart!.target : widget.zikr.dailyTarget;

    final progress = target > 0 ? _currentCount / target : 0.0;

    return Scaffold(
      backgroundColor: Color(widget.zikr.color).withValues(alpha: 0.1),
      appBar: AppBar(
        title: Text(widget.zikr.title),
        backgroundColor: Color(widget.zikr.color),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          if (hasParts)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                currentPart!.description,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Color(widget.zikr.color),
                ),
              ),
            ),
          if (target > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: progress > 1 ? 1 : progress,
                    backgroundColor: Colors.grey[300],
                    color: Color(widget.zikr.color),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: $target',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          Expanded(
            child: GestureDetector(
              onTap: _increment,
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: double.infinity,
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$_currentCount',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 120,
                        fontWeight: FontWeight.bold,
                        color: Color(widget.zikr.color),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Tap to Count',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FloatingActionButton(
                  heroTag: 'decrement',
                  onPressed: _decrement,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.red,
                  child: const Icon(Icons.remove),
                ),
                if (widget.zikr.autoIncrementAllowed)
                  FloatingActionButton(
                    heroTag: 'auto',
                    onPressed: _toggleAutoIncrement,
                    backgroundColor: _isAutoIncrementing
                        ? Colors.red
                        : Colors.white,
                    foregroundColor: _isAutoIncrementing
                        ? Colors.white
                        : Colors.green,
                    child: Icon(
                      _isAutoIncrementing ? Icons.pause : Icons.play_arrow,
                    ),
                  ),
                FloatingActionButton(
                  heroTag: 'reset',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Counter?'),
                        content: const Text(
                          'This will reset the current count.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _currentCount = 0;
                                if (hasParts) {
                                  _currentPartIndex = 0;
                                }
                              });
                              Navigator.pop(context);
                            },
                            child: const Text('Reset'),
                          ),
                        ],
                      ),
                    );
                  },
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
