import 'package:flutter/material.dart';

class TrialPeriodTile extends StatefulWidget {
  final double progress; // Entre 0.0 et 1.0
  final int daysRemaining;
  final VoidCallback onTap;

  const TrialPeriodTile({
    super.key,
    required this.progress,
    required this.daysRemaining,
    required this.onTap,
  });

  @override
  State<TrialPeriodTile> createState() => _TrialPeriodTileState();
}

class _TrialPeriodTileState extends State<TrialPeriodTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animatedProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );

    _animatedProgress = Tween<double>(
      begin: 0.0,
      end: widget.progress.clamp(0.0, 1.0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = widget.progress >= 0.8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Ma période d’essai",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          GestureDetector(
            onTap: widget.onTap,
            child: Container(
              decoration: BoxDecoration(
                color: isWarning ? Colors.red.shade300 : Colors.red.shade400,
                borderRadius: BorderRadius.circular(14),
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.access_time_filled, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: AnimatedBuilder(
                      animation: _animatedProgress,
                      builder: (context, child) {
                        return Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: _animatedProgress.value,
                              child: Container(
                                height: 8,
                                decoration: BoxDecoration(
                                  color:
                                  isWarning ? Colors.yellow : Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 12),
                  Text(
                    "${widget.daysRemaining} jour${widget.daysRemaining > 1 ? 's' : ''} rest${widget.daysRemaining > 1 ? 'ants' : 'ant'}",
                    style: TextStyle(
                      color: isWarning ? Colors.yellow : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
