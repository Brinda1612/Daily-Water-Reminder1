import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../l10n/app_localizations.dart';
import '../bloc/water_bloc.dart';
import '../bloc/water_event.dart';
import '../bloc/water_state.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String _selectedGender = 'Male';
  
  double _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    final int page = _currentPage.round();
    if (page < 3) {
      if (page == 1) {
         if (_nameController.text.trim().isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter your name')));
            return;
         }
      }
      if (page == 2) {
        if (!_formKey.currentState!.validate()) return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _submit();
    }
  }

  void _submit() {
    final name = _nameController.text.trim();
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    context.read<WaterBloc>().add(CompleteOnboarding(
      name: name,
      gender: _selectedGender,
      weight: weight,
      height: height,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background Gradient decoration
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withOpacity(0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                _buildHeader(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(),
                      _buildProfileStep(),
                      _buildInputStep(),
                      _buildGoalStep(),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Linear Progress Indicator
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 4,
                backgroundColor: Colors.blue.withOpacity(0.1),
                color: Colors.blue,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Text(
            '${(_currentPage + 1).toInt()} / 4',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: const Duration(seconds: 1),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(opacity: value, child: child),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(40),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop, size: 80, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.onboardingWelcome,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1A1A1A),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.onboardingSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileStep() {
    final l10n = AppLocalizations.of(context)!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.personalInfo,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.aboutYouSubtitle,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _nameController,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              labelText: l10n.name,
              hintText: l10n.enterName,
              prefixIcon: const Icon(Icons.person_outline, color: Colors.blue),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.gender,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1A1A)),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildGenderOption(l10n.male, Icons.male),
              const SizedBox(width: 12),
              _buildGenderOption(l10n.female, Icons.female),
              const SizedBox(width: 12),
              _buildGenderOption(l10n.other, Icons.transgender),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon) {
    final isSelected = _selectedGender == gender;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = gender),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue : Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[200]!,
              width: 2,
            ),
            boxShadow: isSelected
                ? [BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                : [],
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[400],
                size: 30,
              ),
              const SizedBox(height: 8),
              Text(
                gender,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Widget _buildInputStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.aboutYou,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context)!.aboutYouSubtitle,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            _buildTextField(
              controller: _weightController,
              label: AppLocalizations.of(context)!.weight,
              suffix: AppLocalizations.of(context)!.kg,
              icon: Icons.monitor_weight_outlined,
            ),
            const SizedBox(height: 24),
            _buildTextField(
              controller: _heightController,
              label: AppLocalizations.of(context)!.height,
              suffix: AppLocalizations.of(context)!.cm,
              icon: Icons.height_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      decoration: InputDecoration(
        labelText: label,
        suffixText: suffix,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Required';
        }
        if (double.tryParse(value) == null) {
          return 'Invalid number';
        }
        return null;
      },
    );
  }

  int _calculatePreviewGoal() {
    final weight = double.tryParse(_weightController.text) ?? 70.0;
    final height = double.tryParse(_heightController.text) ?? 170.0;
    double multiplier = _selectedGender.toLowerCase() == AppLocalizations.of(context)!.female.toLowerCase() ? 31.0 : 35.0;
    int goal = (weight * multiplier).round();
    if (height > 180) goal += 200;
    if (height < 150) goal -= 200;
    return goal.clamp(1500, 4000);
  }

  Widget _buildGoalStep() {
    final l10n = AppLocalizations.of(context)!;
    final goal = _calculatePreviewGoal();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppLocalizations.of(context)!.personalizedPlan,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.yourDailyGoal,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  '$goal',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Text(
                  AppLocalizations.of(context)!.mlPerDay,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            AppLocalizations.of(context)!.recommendTarget,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Row(
        children: [
          if (_currentPage > 0)
            IconButton(
              onPressed: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.easeInOutCubic,
                );
              },
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.grey),
            ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 10,
                shadowColor: Colors.blue.withOpacity(0.4),
              ),
              child: Text(
                _currentPage.round() < 3 ? AppLocalizations.of(context)!.next : AppLocalizations.of(context)!.finish,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
