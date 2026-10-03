import 'package:flutter/material.dart';
import '../models/app_color_scheme.dart';
import '../models/sound_scheme.dart';
import '../models/user_account.dart';
import '../services/auth_service.dart';
import '../services/settings_service.dart';
import '../services/sound_service.dart';
import 'auth_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsService _settings = SettingsService();
  final SoundService _sound = SoundService();
  String? _previewingSoundId;
  bool _isColorSectionExpanded = false;
  bool _isSoundSectionExpanded = false;

  Future<void> _previewSound(SoundScheme scheme) async {
    if (_previewingSoundId != null) return;
    setState(() => _previewingSoundId = scheme.id);

    try {
      await _sound.previewSoundScheme(scheme);
    } catch (_) {}

    if (mounted) {
      setState(() => _previewingSoundId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_settings, AuthService()]),
      builder: (context, _) {
        final currentTheme = _settings.currentTheme;
        final currentSound = _settings.currentSoundScheme;
        final user = AuthService().currentUser;

        return Scaffold(
          backgroundColor: currentTheme.background,
          appBar: AppBar(
            backgroundColor: currentTheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white70),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'SETTINGS & THEMES',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 650),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                children: [
                  // 1. Account & Profile Header Card
                  if (user != null) ...[
                    _buildAccountCard(user, currentTheme),
                    const SizedBox(height: 24),
                  ],

                  // 2. Color Schemes Section (Expandable Accordion)
                  _buildExpandableHeaderCard(
                    title: 'APP COLOR SCHEME',
                    activeLabel: currentTheme.name,
                    icon: Icons.palette_outlined,
                    isExpanded: _isColorSectionExpanded,
                    onTap: () {
                      setState(() {
                        _isColorSectionExpanded = !_isColorSectionExpanded;
                      });
                    },
                    currentTheme: currentTheme,
                    trailingPreview: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildColorDot(currentTheme.primary),
                        _buildColorDot(currentTheme.secondary),
                        _buildColorDot(currentTheme.surface),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: AppColorScheme.all.map((scheme) {
                          final isSelected = scheme.id == currentTheme.id;
                          return _buildColorSchemeCard(scheme, isSelected, currentTheme);
                        }).toList(),
                      ),
                    ),
                    crossFadeState: _isColorSectionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                    sizeCurve: Curves.fastOutSlowIn,
                  ),
                  const SizedBox(height: 16),

                  // 3. Sound Schemes Section (Expandable Accordion)
                  _buildExpandableHeaderCard(
                    title: 'WORKOUT SOUND SCHEME',
                    activeLabel: currentSound.name,
                    icon: Icons.graphic_eq_rounded,
                    isExpanded: _isSoundSectionExpanded,
                    onTap: () {
                      setState(() {
                        _isSoundSectionExpanded = !_isSoundSectionExpanded;
                      });
                    },
                    currentTheme: currentTheme,
                    trailingPreview: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: currentTheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          currentSound.icon,
                          color: currentTheme.primary,
                          size: 15,
                        ),
                      ),
                    ),
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
                    secondChild: Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Column(
                        children: SoundScheme.all.map((scheme) {
                          final isSelected = scheme.id == currentSound.id;
                          final isPlaying = _previewingSoundId == scheme.id;
                          return _buildSoundSchemeCard(scheme, isSelected, isPlaying, currentTheme);
                        }).toList(),
                      ),
                    ),
                    crossFadeState: _isSoundSectionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 280),
                    sizeCurve: Curves.fastOutSlowIn,
                  ),
                  const SizedBox(height: 24),

                  // 4. Audio & Haptics Preferences
                  _buildSectionHeader(
                    title: 'AUDIO & HAPTICS',
                    subtitle: 'Fine-tune alerts and device feedback',
                    icon: Icons.tune_rounded,
                    accentColor: currentTheme.primary,
                  ),
                  const SizedBox(height: 12),
                  _buildToggleCard(
                    title: 'Workout Audio Cues',
                    subtitle: _settings.isMuted ? 'Muted — No tones during workout' : 'Active — Crisp interval beeps enabled',
                    icon: _settings.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    value: !_settings.isMuted,
                    accentColor: currentTheme.primary,
                    surfaceColor: currentTheme.surface,
                    borderColor: currentTheme.cardBorder,
                    onChanged: (val) => _settings.setMuted(!val),
                  ),
                  const SizedBox(height: 10),
                  _buildToggleCard(
                    title: 'Vibration & Haptic Feedback',
                    subtitle: _settings.isHapticsEnabled ? 'Haptic pulses on interval transitions' : 'Haptics disabled',
                    icon: Icons.vibration_rounded,
                    value: _settings.isHapticsEnabled,
                    accentColor: currentTheme.primary,
                    surfaceColor: currentTheme.surface,
                    borderColor: currentTheme.cardBorder,
                    onChanged: (val) => _settings.setHaptics(val),
                  ),
                  const SizedBox(height: 32),

                  // 5. Version Info
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'TITAN INTERVALS',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.35),
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.0 (Build 42) • Native High-Precision Audio',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.25),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandableHeaderCard({
    required String title,
    required String activeLabel,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
    required AppColorScheme currentTheme,
    Widget? trailingPreview,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: currentTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded ? currentTheme.primary.withValues(alpha: 0.6) : currentTheme.cardBorder,
          width: isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: isExpanded
            ? [
                BoxShadow(
                  color: currentTheme.primary.withValues(alpha: 0.12),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            child: Row(
              children: [
                // Icon Container
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: currentTheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: currentTheme.primary, size: 20),
                ),
                const SizedBox(width: 14),

                // Title & Active Badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              activeLabel,
                              style: TextStyle(
                                color: currentTheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: currentTheme.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: currentTheme.primary,
                                fontSize: 9,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                if (trailingPreview != null) ...[
                  trailingPreview,
                  const SizedBox(width: 10),
                ],

                // Animated Chevron
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.fastOutSlowIn,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: isExpanded ? currentTheme.primary : Colors.white60,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accentColor, size: 18),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountCard(UserAccount user, AppColorScheme theme) {
    final initial = user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'A';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.cardBorder),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.primary.withValues(alpha: 0.18),
              border: Border.all(color: theme.primary, width: 2),
            ),
            child: ClipOval(
              child: (user.photoUrl != null && user.photoUrl!.isNotEmpty && user.photoUrl!.startsWith('http'))
                  ? Image.network(
                      user.photoUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          initial,
                          style: TextStyle(color: theme.primary, fontSize: 22, fontWeight: FontWeight.w900),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: TextStyle(color: theme.primary, fontSize: 22, fontWeight: FontWeight.w900),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 14),

          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.displayName,
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  user.email,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12),
                ),
                const SizedBox(height: 6),
                // Provider Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${user.authProvider.toUpperCase()} ATHLETE • ${user.totalWorkoutsCompleted} WORKOUTS',
                    style: TextStyle(
                      color: theme.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sign Out Button
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
            tooltip: 'Sign Out',
            onPressed: () => _confirmSignOut(context),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSchemeCard(AppColorScheme scheme, bool isSelected, AppColorScheme currentTheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isSelected ? scheme.surface : currentTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? scheme.primary : currentTheme.cardBorder,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.18),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _settings.setColorScheme(scheme.id),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Color swatches preview
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primary,
                    boxShadow: [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: isSelected
                        ? Icon(Icons.check_rounded, color: scheme.onPrimary, size: 24)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Theme Name and Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            scheme.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: scheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'ACTIVE',
                                style: TextStyle(
                                  color: scheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scheme.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Palette dots preview
                Row(
                  children: [
                    _buildColorDot(scheme.primary),
                    _buildColorDot(scheme.secondary),
                    _buildColorDot(scheme.surface),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
      ),
    );
  }

  Widget _buildSoundSchemeCard(
    SoundScheme scheme,
    bool isSelected,
    bool isPlaying,
    AppColorScheme currentTheme,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: currentTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? currentTheme.primary : currentTheme.cardBorder,
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: currentTheme.primary.withValues(alpha: 0.15),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _settings.setSoundScheme(scheme.id),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Radio checkmark indicator
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? currentTheme.primary.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? currentTheme.primary : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      scheme.icon,
                      color: isSelected ? currentTheme.primary : Colors.white60,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            scheme.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: currentTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: currentTheme.primary,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        scheme.description,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        scheme.acousticTag,
                        style: TextStyle(
                          color: currentTheme.primary.withValues(alpha: 0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // TEST / PREVIEW BUTTON
                OutlinedButton.icon(
                  onPressed: isPlaying ? null : () => _previewSound(scheme),
                  icon: isPlaying
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: currentTheme.primary,
                          ),
                        )
                      : Icon(
                          Icons.play_arrow_rounded,
                          size: 18,
                          color: isSelected ? currentTheme.primary : Colors.white70,
                        ),
                  label: Text(
                    isPlaying ? 'PLAYING' : 'TEST',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isSelected ? currentTheme.primary : Colors.white70,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isSelected
                          ? currentTheme.primary.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.15),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required Color accentColor,
    required Color surfaceColor,
    required Color borderColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Icon(icon, color: value ? accentColor : Colors.white38, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: accentColor,
            activeTrackColor: accentColor.withValues(alpha: 0.3),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white10,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign Out?', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
        content: const Text(
          'Your routines and customized settings are safely saved to your account.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('SIGN OUT', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await AuthService().signOut();
      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthScreen()),
          (route) => false,
        );
      }
    }
  }
}
