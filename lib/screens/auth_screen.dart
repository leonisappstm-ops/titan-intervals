import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../widgets/brand_icons.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _authService = AuthService();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _navigateToHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  Future<void> _handleEmailAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 4) {
      setState(() => _errorMessage = 'Password must be at least 4 characters.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    if (_isSignUp) {
      final success = await _authService.signUpWithEmail(email, password, name);
      if (success) {
        _navigateToHome();
      } else {
        setState(() {
          _errorMessage = 'An account with this email already exists. Please Sign In.';
          _isLoading = false;
        });
      }
    } else {
      final success = await _authService.signInWithEmail(email, password);
      if (success) {
        _navigateToHome();
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again or create an account.';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showGoogleDeviceAccountPicker() async {
    final deviceAccounts = await _authService.getDeviceGoogleAccounts();

    if (!mounted) return;

    final selected = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(ctx).size.height * 0.75,
          maxWidth: 480,
        ),
        margin: const EdgeInsets.only(top: 40),
        decoration: const BoxDecoration(
          color: Color(0xFF161B26),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Google Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: GoogleIconWidget(size: 24),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Choose an account',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'from this device to continue to Titan Intervals',
                        style: TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),

            // List of Detected Device Accounts
            Flexible(
              child: ListView.separated(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: deviceAccounts.length,
                separatorBuilder: (_, _) => Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),
                itemBuilder: (context, index) {
                  final acc = deviceAccounts[index];
                  final email = acc['email'] ?? 'athlete@gmail.com';
                  final name = acc['name'] ?? 'Athlete';
                  final photoUrl = acc['photoUrl'];
                  final source = acc['source'] ?? 'Device Account';
                  final isSystem = acc['isSystem'] == 'true';
                  final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';

                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF4285F4).withValues(alpha: 0.6),
                          width: 1.5,
                        ),
                      ),
                      child: ClipOval(
                        child: (photoUrl != null && photoUrl.isNotEmpty && photoUrl.startsWith('http'))
                            ? Image.network(
                                photoUrl,
                                fit: BoxFit.cover,
                                width: 44,
                                height: 44,
                                errorBuilder: (_, _, _) => Container(
                                  color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                                  alignment: Alignment.center,
                                  child: Text(
                                    initial,
                                    style: const TextStyle(
                                      color: Color(0xFF4285F4),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              )
                            : Container(
                                color: const Color(0xFF4285F4).withValues(alpha: 0.2),
                                alignment: Alignment.center,
                                child: Text(
                                  initial,
                                  style: const TextStyle(
                                    color: Color(0xFF4285F4),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Flexible(
                          child: Text(
                            name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (isSystem) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E676).withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Device User',
                              style: TextStyle(
                                color: Color(0xFF00E676),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          source,
                          style: TextStyle(
                            color: const Color(0xFF4285F4).withValues(alpha: 0.75),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                    onTap: () => Navigator.of(ctx).pop(acc),
                  ),
                );
                },
              ),
            ),

            Divider(color: Colors.white.withValues(alpha: 0.08), height: 1),

            // Use Another Account
            Material(
              color: Colors.transparent,
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.white.withValues(alpha: 0.08),
                  child: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white70, size: 18),
                ),
                title: const Text(
                  'Use another Google account',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
                onTap: () async {
                  Navigator.of(ctx).pop(null);
                  await _showAddCustomGoogleAccountDialog();
                },
              ),
            ),

            // Bottom Disclaimer
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
              child: Text(
                'To continue, Google will securely share your profile identity with Titan Intervals to save and sync your workout data.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.35),
                  fontSize: 11,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      setState(() => _isLoading = true);
      await _authService.signInWithGoogle(
        email: selected['email'],
        name: selected['name'],
        photoUrl: selected['photoUrl'],
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1F2637),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Color(0xFF00E676), size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Signed in as ${selected['name']} (${selected['email']})',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        );
      }
      _navigateToHome();
    }
  }

  Future<void> _showAddCustomGoogleAccountDialog() async {
    final emailCtrl = TextEditingController();
    final nameCtrl = TextEditingController();

    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            GoogleIconWidget(size: 24),
            SizedBox(width: 8),
            Text(
              'Add Google Account',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1F2637),
                labelText: 'Account Name',
                labelStyle: const TextStyle(color: Colors.white60),
                hintText: 'e.g. Work Gym Profile',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              autofocus: true,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1F2637),
                labelText: 'Gmail Address',
                labelStyle: const TextStyle(color: Colors.white60),
                hintText: 'user@gmail.com',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('CANCEL', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            onPressed: () {
              final em = emailCtrl.text.trim();
              if (em.isEmpty || !em.contains('@')) return;
              Navigator.of(ctx).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E676),
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('ADD & SIGN IN', style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );

    if (added == true && emailCtrl.text.trim().isNotEmpty) {
      final em = emailCtrl.text.trim();
      final nm = nameCtrl.text.trim().isNotEmpty ? nameCtrl.text.trim() : em.split('@').first;
      setState(() => _isLoading = true);
      await _authService.signInWithGoogle(email: em, name: nm);
      _navigateToHome();
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C1017),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo & Brand
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E676).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF00E676).withValues(alpha: 0.5), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF00E676).withValues(alpha: 0.25),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.bolt, color: Color(0xFF00E676), size: 40),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'TITAN INTERVALS',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  Text(
                    'Sign in to sync your custom workouts & stats',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.65),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Google / Gmail Button
                  _buildSocialButton(
                    label: 'Continue with Google / Gmail',
                    customIcon: const GoogleIconWidget(size: 22),
                    backgroundColor: const Color(0xFF1E2536),
                    textColor: Colors.white,
                    onPressed: _showGoogleDeviceAccountPicker,
                  ),
                  const SizedBox(height: 24),

                  // Divider
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14.0),
                        child: Text(
                          'OR WITH EMAIL',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.45),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.12))),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Tab switch: Sign In vs Create Account
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF161B26),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildAuthTab(
                            title: 'SIGN IN',
                            isSelected: !_isSignUp,
                            onTap: () => setState(() {
                              _isSignUp = false;
                              _errorMessage = null;
                            }),
                          ),
                        ),
                        Expanded(
                          child: _buildAuthTab(
                            title: 'CREATE ACCOUNT',
                            isSelected: _isSignUp,
                            onTap: () => setState(() {
                              _isSignUp = true;
                              _errorMessage = null;
                            }),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF1744).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFFF1744).withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Color(0xFFFF1744), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Form Fields
                  if (_isSignUp) ...[
                    _buildTextField(
                      controller: _nameController,
                      label: 'YOUR NAME',
                      hint: 'Alex Athlete',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 14),
                  ],

                  _buildTextField(
                    controller: _emailController,
                    label: 'EMAIL ADDRESS',
                    hint: 'athlete@example.com',
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    controller: _passwordController,
                    label: 'PASSWORD',
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white54,
                        size: 20,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEmailAuth,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00E676),
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.black),
                            )
                          : Text(
                              _isSignUp ? 'CREATE STANDALONE ACCOUNT' : 'SIGN IN',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.1,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Continue as Guest Link
                  TextButton(
                    onPressed: () async {
                      await _authService.continueAsGuest();
                      _navigateToHome();
                    },
                    child: Text(
                      'Explore as Guest',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAuthTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E2536) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected ? Border.all(color: Colors.white12) : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF00E676) : Colors.white54,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    IconData? icon,
    Widget? customIcon,
    Color? iconColor,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Gradient? gradient,
    required Color textColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: gradient,
        borderRadius: BorderRadius.circular(14),
        border: gradient == null ? Border.all(color: Colors.white12) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (customIcon != null)
                  customIcon
                else if (icon != null)
                  Icon(icon, size: 24, color: iconColor),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF161B26),
            prefixIcon: Icon(icon, color: Colors.white54, size: 20),
            suffixIcon: suffixIcon,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00E676)),
            ),
          ),
        ),
      ],
    );
  }
}
