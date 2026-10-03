import 'package:flutter/material.dart';
import '../models/user_account.dart';
import '../models/workout_routine.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import '../widgets/routine_card.dart';
import 'active_timer_screen.dart';
import 'custom_workout_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'ALL';
  int _currentNavIndex = 0;
  final SoundService _soundService = SoundService();
  final AuthService _authService = AuthService();

  final List<String> _categories = const [
    'ALL',
    'CUSTOM',
    'TABATA',
    'HIIT',
    'BOXING',
    'EMOM',
    'CORE',
  ];

  String _formatShortName(String? name) {
    if (name == null || name.isEmpty) return 'Athlete';
    if (name.toLowerCase().contains('adrian')) return 'Adrian-M.';
    if (name.contains('-')) {
      final parts = name.split('-');
      return '${parts[0]}-${parts[1].isNotEmpty ? parts[1][0] : ''}.';
    }
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length > 1) {
      return '${words[0]}-${words[1][0]}.';
    }
    return name;
  }

  Future<void> _showStatsModal(BuildContext context, UserAccount? user) async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75, maxWidth: 500),
        decoration: const BoxDecoration(
          color: Color(0xFF111824),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.bar_chart_rounded, color: Color(0xFF00FFA3), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Workout Statistics',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  splashRadius: 20,
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Workouts',
                    value: '${user?.totalWorkoutsCompleted ?? 0}',
                    color: const Color(0xFF00FFA3),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Active Minutes',
                    value: '${user?.totalActiveMinutes ?? 0}m',
                    color: const Color(0xFF00D2FF),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Calories',
                    value: '${user?.totalCaloriesBurned ?? 0}',
                    color: const Color(0xFFFF5722),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
    if (mounted) {
      setState(() => _currentNavIndex = 0);
    }
  }

  Widget _buildStatCard({required String title, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF141D2B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Color(0xFF8E9CAE), fontSize: 11, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }

  Future<void> _showHistoryModal(BuildContext context, UserAccount? user) async {
    final history = user?.workoutHistory ?? [];

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.75, maxWidth: 500),
        decoration: const BoxDecoration(
          color: Color(0xFF111824),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFA3).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.history_rounded, color: Color(0xFF00FFA3), size: 24),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Workout History',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  splashRadius: 20,
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (history.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No completed workouts recorded yet.\nStart a routine to track your progress!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF8E9CAE), fontSize: 13, height: 1.4),
                  ),
                ),
              )
            else
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: history.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (_, index) {
                    final log = history[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141D2B),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFF1E2C3D)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Color(0xFF00FFA3), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  log.routineName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${log.formattedDuration} • ${log.setsCompleted} sets • ${log.caloriesBurned} kcal',
                                  style: const TextStyle(color: Color(0xFF8E9CAE), fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
    if (mounted) {
      setState(() => _currentNavIndex = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();

    return AnimatedBuilder(
      animation: Listenable.merge([_authService, settingsService]),
      builder: (context, _) {
        final theme = settingsService.currentTheme;
        final currentUser = _authService.currentUser;
        final allRoutines = [
          ..._authService.customRoutines,
          ...WorkoutRoutine.presets,
        ];

        final filteredRoutines = _selectedCategory == 'ALL'
            ? allRoutines
            : allRoutines.where((r) => r.tag == _selectedCategory).toList();

        final shortProfileName = _formatShortName(currentUser?.displayName);

        return Scaffold(
          backgroundColor: theme.background,
          body: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(
                  children: [
                    // Top App Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
                      child: Row(
                        children: [
                          // Neon Bolt Icon
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: theme.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(Icons.bolt_rounded, color: theme.onPrimary, size: 26),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Brand Titles
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text(
                                  'TITAN INTERVALS',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.3,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Gym & HIIT Training Timer',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: theme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Sound Toggle Button
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF131D2B),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF1E2C3D)),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              icon: Icon(
                                _soundService.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                                color: Colors.white,
                                size: 17,
                              ),
                              onPressed: () {
                                setState(() {
                                  _soundService.toggleMute();
                                });
                              },
                              tooltip: _soundService.isMuted ? 'Unmute Sound' : 'Mute Sound',
                            ),
                          ),
                          const SizedBox(width: 8),

                          // User Account Profile Pill
                          if (currentUser != null)
                            InkWell(
                              borderRadius: BorderRadius.circular(22),
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const SettingsScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(4, 4, 10, 4),
                                decoration: BoxDecoration(
                                  color: theme.surface,
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(color: theme.cardBorder),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 13,
                                      backgroundColor: theme.primary,
                                      backgroundImage: (currentUser.photoUrl != null &&
                                              currentUser.photoUrl!.isNotEmpty &&
                                              currentUser.photoUrl!.startsWith('http'))
                                          ? NetworkImage(currentUser.photoUrl!)
                                          : null,
                                      child: (currentUser.photoUrl == null ||
                                              currentUser.photoUrl!.isEmpty ||
                                              !currentUser.photoUrl!.startsWith('http'))
                                          ? Text(
                                              currentUser.displayName.isNotEmpty
                                                  ? currentUser.displayName[0].toUpperCase()
                                                  : 'A',
                                              style: TextStyle(
                                                color: theme.onPrimary,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 80),
                                      child: Text(
                                        shortProfileName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Compact Athlete Mode Welcome Banner
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [theme.surface, theme.background],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: theme.cardBorder, width: 1.2),
                          boxShadow: [
                            BoxShadow(
                              color: theme.primary.withValues(alpha: 0.08),
                              blurRadius: 16,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Athlete Mode Pill Badge
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: theme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'ATHLETE MODE',
                                        style: TextStyle(
                                          color: theme.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: 0.8,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),

                                  // Welcome Heading
                                  Text(
                                    'WELCOME, ${(currentUser?.displayName ?? 'ADRIAN-MARIUS').toUpperCase()}!',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Glowing Dumbbell Badge
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: theme.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: theme.primary.withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: theme.primary.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.fitness_center_rounded,
                                  size: 22,
                                  color: theme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Routines List
                    Expanded(
                      child: filteredRoutines.isEmpty
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(32.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.tune_rounded,
                                      size: 40,
                                      color: Colors.white.withValues(alpha: 0.3),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No Workouts In This Category',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Tap "BUILD CUSTOM" to create your customized routine.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF8E9CAE),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              itemCount: filteredRoutines.length,
                              itemBuilder: (context, index) {
                                final routine = filteredRoutines[index];
                                final isUserCustom = _authService.customRoutines.any((r) => r.id == routine.id);

                                return RoutineCard(
                                  routine: routine,
                                  onStart: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ActiveTimerScreen(routine: routine),
                                      ),
                                    );
                                  },
                                  onEdit: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => CustomWorkoutScreen(initialRoutine: routine),
                                      ),
                                    );
                                  },
                                  onDelete: isUserCustom
                                      ? () async {
                                          final confirm = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              backgroundColor: const Color(0xFF161B26),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                              title: const Text('Delete Routine?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                                              content: Text('Remove "${routine.name}" from your account?', style: const TextStyle(color: Colors.white70)),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(false),
                                                  child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(ctx).pop(true),
                                                  child: const Text('DELETE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                                                ),
                                              ],
                                            ),
                                          );
                                          if (confirm == true) {
                                            await _authService.deleteCustomRoutine(routine.id);
                                          }
                                        }
                                      : null,
                                );
                              },
                            ),
                    ),

                    // Filter Categories Chips (Positioned right above Bottom Nav Bar)
                    Container(
                      height: 46,
                      padding: const EdgeInsets.only(bottom: 6),
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = _categories[index];
                          final isSelected = cat == _selectedCategory;

                          return InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              setState(() => _selectedCategory = cat);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: isSelected ? 18 : 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? theme.primary : theme.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: isSelected ? null : Border.all(color: theme.cardBorder),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: TextStyle(
                                    color: isSelected ? theme.onPrimary : const Color(0xFFCBD5E1),
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Navigation Bar
                    _buildBottomNavigationBar(context, currentUser),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, UserAccount? currentUser) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF070A11),
        border: Border(
          top: BorderSide(color: Color(0xFF141C29), width: 1.2),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding > 0 ? bottomPadding : 10, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Workouts
          _buildNavItem(
            icon: Icons.play_circle_fill_rounded,
            label: 'Workouts',
            isSelected: _currentNavIndex == 0,
            onTap: () => setState(() => _currentNavIndex = 0),
          ),

          // 2. History
          _buildNavItem(
            icon: Icons.access_time_rounded,
            label: 'History',
            isSelected: _currentNavIndex == 1,
            onTap: () {
              setState(() => _currentNavIndex = 1);
              _showHistoryModal(context, currentUser);
            },
          ),

          // 3. Center Elevated Create Button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const CustomWorkoutScreen(),
                ),
              );
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SettingsService().primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: SettingsService().primaryColor.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(Icons.add_rounded, color: SettingsService().currentTheme.onPrimary, size: 28),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Create',
                  style: TextStyle(
                    color: SettingsService().primaryColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // 4. Stats
          _buildNavItem(
            icon: Icons.bar_chart_rounded,
            label: 'Stats',
            isSelected: _currentNavIndex == 3,
            onTap: () {
              setState(() => _currentNavIndex = 3);
              _showStatsModal(context, currentUser);
            },
          ),

          // 5. Settings
          _buildNavItem(
            icon: Icons.settings_outlined,
            label: 'Settings',
            isSelected: _currentNavIndex == 4,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final activeColor = SettingsService().primaryColor;
    final inactiveColor = const Color(0xFF627184);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : inactiveColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
