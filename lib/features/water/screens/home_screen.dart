import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import '../../../app.dart';
import '../../../core/services/notification_service.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/water_bloc.dart';
import '../bloc/water_event.dart';
import '../bloc/water_state.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'wave_painter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _controller;
  int _currentIndex = 0;
  bool _hasRequestedPermissions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();


    // Request permissions after a short delay when on home screen
    if (!_hasRequestedPermissions) {
      Future.delayed(const Duration(milliseconds: 500), () {
        _requestNotificationPermissions();
      });
    }
  }

  Future<void> _requestNotificationPermissions() async {
    if (_hasRequestedPermissions) return;
    _hasRequestedPermissions = true;

    try {
      final permissions = await NotificationService.requestPermissions();
      debugPrint('Permissions status: $permissions');
    } catch (e) {
      debugPrint('Error requesting permissions: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _playWaterSound() {
    SystemSound.play(SystemSoundType.click);
  }

  void _triggerCelebration() {
    // Celebration removed as requested
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeView(
            controller: _controller,
            onWaterSound: _playWaterSound,
            onCelebration: _triggerCelebration,
          ),
          HistoryScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.water_drop_outlined, Icons.water_drop, AppLocalizations.of(context)!.home),
                _buildNavItem(1, Icons.history_outlined, Icons.history, AppLocalizations.of(context)!.history),
                _buildNavItem(2, Icons.settings_outlined, Icons.settings, AppLocalizations.of(context)!.settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData outlinedIcon, IconData filledIcon, String label) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _currentIndex = index),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? filledIcon : outlinedIcon,
                color: isSelected ? WaterReminderApp.primaryWater : Colors.grey[400],
                size: 26,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? WaterReminderApp.primaryWater : Colors.grey[400],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeView extends StatefulWidget {
  static const List<int> standardCupSizes = [100, 125, 150, 175, 200, 250, 300, 400];
  
  final AnimationController controller;
  final VoidCallback onWaterSound;
  final VoidCallback onCelebration;

  const HomeView({
    super.key,
    required this.controller,
    required this.onWaterSound,
    required this.onCelebration,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        return SafeArea(
          child: Column(
            children: [
              _buildHeader(context, state),
              const SizedBox(height: 10),
              _buildMascotSection(context, state),
              const SizedBox(height: 20),
              _buildProgressCircle(context, state, widget.controller),
              const SizedBox(height: 20),
              _buildGoalCard(context, state),
              const SizedBox(height: 16),
              _buildQuickActions(context, state),
            ],
          ),
        );
      },
    );
  }


  Widget _buildHeader(BuildContext context, WaterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                state.name.isNotEmpty ? 'Hello, ${state.name}!' : 'WaterTrack',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Stay hydrated 💧',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),

        ],
      ),
    );
  }

  Widget _buildMascotSection(BuildContext context, WaterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildWaveMascot(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Great day, ${state.name.isNotEmpty ? state.name : "Friend"}!',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WaterReminderApp.deepWater,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.sipSmallSips,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaveMascot() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            WaterReminderApp.primaryWaterLight,
            WaterReminderApp.primaryWater,
          ],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: WaterReminderApp.primaryWater.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(
        Icons.water_drop,
        size: 36,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProgressCircle(BuildContext context, WaterState state, AnimationController controller) {
    final isGoalReached = state.progress >= 1.0;

    return GestureDetector(
      onTap: () {
        if (!isGoalReached) {
          context.read<WaterBloc>().add(const AddWater());
          widget.onWaterSound();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('+${state.selectedCupSize}${AppLocalizations.of(context)!.ml}'),
                ],
              ),
              duration: const Duration(milliseconds: 800),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.emoji_events, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '🎉 Goal Reached! Great job!',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              duration: const Duration(milliseconds: 2000),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.green,
            ),
          );
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: WaterReminderApp.primaryWater.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: controller,
            builder: (context, child) {
              return SizedBox(
                width: 280,
                height: 280,
                child: CustomPaint(
                  painter: WavePainter(
                    progress: state.progress.clamp(0.0, 1.0),
                    waveOffset: controller.value * 2 * 3.14159,
                  ),
                ),
              );
            },
          ),
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: WaterReminderApp.primaryWater.withOpacity(0.3),
                width: 8,
              ),
            ),
          ),
          Positioned(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isGoalReached) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 15,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Goal Reached!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '🎉',
                    style: TextStyle(
                      fontSize: 40,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.todayIntake} ml',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: WaterReminderApp.deepWater,
                    ),
                  ),
                ] else ...[
                  Text(
                    '${(state.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: state.progress > 0.5 ? Colors.white : WaterReminderApp.deepWater,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${state.todayIntake} / ${state.dailyGoal} ml',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: state.progress > 0.5 ? Colors.white70 : WaterReminderApp.primaryWaterDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_cafe, size: 16, color: WaterReminderApp.primaryWater),
                        const SizedBox(width: 4),
                        Text(
                          '${state.selectedCupSize} ml',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: WaterReminderApp.primaryWaterDark,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.touch_app, size: 14, color: Colors.grey[400]),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            right: 0,
            bottom: 30,
            child: GestureDetector(
              onTap: () => _showCupSelectionSheet(context, context.read<WaterBloc>().state),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [WaterReminderApp.primaryWaterLight, WaterReminderApp.primaryWater],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: WaterReminderApp.primaryWater.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(BuildContext context, WaterState state) {
    final remaining = (state.dailyGoal - state.todayIntake).clamp(0, state.dailyGoal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: WaterReminderApp.getGlassBox(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.dailyGoalLabel,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${state.dailyGoal} ml',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: WaterReminderApp.deepWater,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey[200],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                AppLocalizations.of(context)!.remaining,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '$remaining ml',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: remaining == 0 ? Colors.green : WaterReminderApp.primaryWater,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context, WaterState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showCupSelectionSheet(context, state),
              icon: const Icon(Icons.local_cafe_outlined),
              label: const Text('Change Cup'),
              style: OutlinedButton.styleFrom(
                foregroundColor: WaterReminderApp.primaryWaterDark,
                side: BorderSide(color: WaterReminderApp.primaryWater.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => context.read<WaterBloc>().add(ResetWater()),
              icon: const Icon(Icons.refresh_outlined),
              label: Text(AppLocalizations.of(context)!.resetToday),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[600],
                side: BorderSide(color: Colors.grey.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCupSelectionSheet(BuildContext context, WaterState state) {

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => BlocBuilder<WaterBloc, WaterState>(
        builder: (context, state) {
          final allCups = [...HomeView.standardCupSizes, ...state.customCups];
          
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select Cup Size',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: WaterReminderApp.deepWater,
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      childAspectRatio: 1,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemCount: allCups.length + 1,
                    itemBuilder: (itemContext, index) {
                      if (index < allCups.length) {
                        final size = allCups[index];
                        final isSelected = state.selectedCupSize == size;
                        final isCustom = !HomeView.standardCupSizes.contains(size);
                        return _buildCupItem(context, state, size, isSelected, isCustom: isCustom);
                      } else {
                        return _buildCustomCupItem(context, state);
                      }
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCupItem(BuildContext context, WaterState state, int size, bool isSelected, {bool isCustom = false}) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            context.read<WaterBloc>().add(SetCupSize(size));
            Navigator.pop(context);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [WaterReminderApp.primaryWaterLight, WaterReminderApp.primaryWater],
                    )
                  : null,
              color: isSelected ? null : WaterReminderApp.primaryWater.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? WaterReminderApp.primaryWater : WaterReminderApp.primaryWater.withOpacity(0.3),
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_cafe,
                  size: 24,
                  color: isSelected ? Colors.white : WaterReminderApp.primaryWater,
                ),
                const SizedBox(height: 6),
                Text(
                  '$size',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : WaterReminderApp.primaryWaterDark,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (isCustom)
          Positioned(
            top: -5,
            right: -5,
            child: GestureDetector(
              onTap: () {
                context.read<WaterBloc>().add(DeleteCustomCup(size));
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCustomCupItem(BuildContext context, WaterState state) {
    return GestureDetector(
      onTap: () {
        final bloc = context.read<WaterBloc>();
        Navigator.pop(context);
        _showCustomAmountDialog(context, state, bloc);
      },
      child: Container(
        decoration: BoxDecoration(
          color: WaterReminderApp.primaryWater.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: WaterReminderApp.primaryWater.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              size: 24,
              color: WaterReminderApp.primaryWater,
            ),
            const SizedBox(height: 6),
            Text(
              'Custom',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: WaterReminderApp.primaryWaterDark,
              ),
            ),
          ])
        ),
      );
  }

  void _showCustomAmountDialog(BuildContext context, WaterState state, WaterBloc waterBloc) {
    final controller = TextEditingController();
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(l10n.customiseCup),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: l10n.enterAmount,
            suffixText: 'ml',
            filled: true,
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val > 0) {
                waterBloc.add(SetCupSize(val));
                Navigator.pop(dialogContext);
              }
            },
            child: Text(l10n.set),
          ),
        ],
      ),
    );
  }
}
