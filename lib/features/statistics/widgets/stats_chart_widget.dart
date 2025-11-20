import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';

class StatsChartWidget extends StatelessWidget {
  final String period;

  const StatsChartWidget({
    super.key,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _buildChartBars(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _buildChartLabels(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildChartBars() {
    final data = _getChartData();
    final maxValue = data.reduce((a, b) => a > b ? a : b);

    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final value = entry.value;
      final height = (value / maxValue) * 150;

      return Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                value.toString(),
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: height,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppTheme.primaryColor,
                      AppTheme.primaryColor.withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildChartLabels() {
    final labels = _getChartLabels();
    return labels.map((label) {
      return Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 10,
          color: AppTheme.textSecondary,
        ),
      );
    }).toList();
  }

  List<int> _getChartData() {
    // Mock data - replace with actual data from provider
    switch (period) {
      case 'Daily':
        return [2, 4, 1, 3, 5, 2, 3]; // Last 7 hours
      case 'Weekly':
        return [12, 18, 15, 22, 19, 25, 18]; // Last 7 days
      case 'Monthly':
        return [45, 52, 38, 65, 48, 72, 58, 61, 55, 68, 42, 75]; // Last 12 months
      default:
        return [0, 0, 0, 0, 0, 0, 0];
    }
  }

  List<String> _getChartLabels() {
    switch (period) {
      case 'Daily':
        return ['6h', '12h', '18h', '24h', '6h', '12h', '18h'];
      case 'Weekly':
        return ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      case 'Monthly':
        return ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      default:
        return [];
    }
  }
}