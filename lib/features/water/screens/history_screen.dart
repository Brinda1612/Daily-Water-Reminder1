import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smart_task/l10n/app_localizations.dart';
import '../../../app.dart';
import '../bloc/water_bloc.dart';
import '../bloc/water_state.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: BlocBuilder<WaterBloc, WaterState>(
        builder: (context, state) {
          final history = state.history;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 50, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.intakeHistory,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track your hydration journey',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (history.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                WaterReminderApp.primaryWaterLight.withOpacity(0.2),
                                WaterReminderApp.primaryWater.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.water_drop_outlined,
                            size: 64,
                            color: WaterReminderApp.primaryWater,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          AppLocalizations.of(context)!.noHistory,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: WaterReminderApp.deepWater,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.startDrinking,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final item = history[index];
                        final percent = (item.intake / item.goal).clamp(0.0, 1.0);
                        final isGoalReached = percent >= 1.0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: WaterReminderApp.getGlassBox(),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                _buildDateIndicator(item, isGoalReached),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.date,
                                        style:  TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: WaterReminderApp.deepWater,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${item.intake} / ${item.goal} ${AppLocalizations.of(context)!.ml}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Stack(
                                        children: [
                                          Container(
                                            height: 8,
                                            decoration: BoxDecoration(
                                              color: WaterReminderApp.primaryWater.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          FractionallySizedBox(
                                            widthFactor: percent,
                                            child: Container(
                                              height: 8,
                                              decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  colors: isGoalReached
                                                      ? [Colors.green, Colors.green.shade700]
                                                      : [
                                                          WaterReminderApp.primaryWaterLight,
                                                          WaterReminderApp.primaryWater,
                                                        ],
                                                ),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: isGoalReached
                                          ? [Colors.green.shade400, Colors.green.shade600]
                                          : [
                                              WaterReminderApp.primaryWaterLight,
                                              WaterReminderApp.primaryWater,
                                            ],
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '${(percent * 100).toInt()}%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: history.length,
                    ),
                  ),
                ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 20),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDateIndicator(dynamic item, bool isGoalReached) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isGoalReached
              ? [Colors.green.shade400, Colors.green.shade600]
              : [WaterReminderApp.primaryWaterLight, WaterReminderApp.primaryWater],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (isGoalReached ? Colors.green : WaterReminderApp.primaryWater).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isGoalReached ? Icons.emoji_events : Icons.local_drink,
            color: Colors.white,
            size: 20,
          ),
        ],
      ),
    );
  }
}
