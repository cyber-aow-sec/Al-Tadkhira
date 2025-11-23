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
      _currentCount = count;
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
    _logHistory(1);
  }

  void _decrement() {
    if (_currentCount > 0) {
      setState(() {
        _currentCount--;
      });
      HapticFeedback.lightImpact();
      _logHistory(-1);
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
    final progress = widget.zikr.dailyTarget > 0
        ? _currentCount / widget.zikr.dailyTarget
        : 0.0;

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
          if (widget.zikr.dailyTarget > 0)
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
                    'Target: ${widget.zikr.dailyTarget}',
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
                    // Optional: Reset for today? Or just ignore.
                    // For now, let's just have a reset button that asks confirmation
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Reset Counter?'),
                        content: const Text(
                          'This will not delete history, just reset the view to 0? No, that is confusing. Maybe manual edit?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
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
