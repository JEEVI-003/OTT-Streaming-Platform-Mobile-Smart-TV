import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';

// ─────────────────────────────────────────────────────────────────────────────
// TV Change Password Screen
// Works on both TV (remote D-pad navigation) and Mobile
// ─────────────────────────────────────────────────────────────────────────────

class TVChangePasswordScreen extends StatefulWidget {
  const TVChangePasswordScreen({super.key});

  @override
  State<TVChangePasswordScreen> createState() => _TVChangePasswordScreenState();
}

class _TVChangePasswordScreenState extends State<TVChangePasswordScreen> {
  final Service service = Service();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  final TextEditingController _currentPwCtrl = TextEditingController();
  final TextEditingController _newPwCtrl = TextEditingController();
  final TextEditingController _confirmPwCtrl = TextEditingController();

  final FocusNode _currentPwFocus = FocusNode();
  final FocusNode _newPwFocus = FocusNode();
  final FocusNode _confirmPwFocus = FocusNode();
  final FocusNode _submitFocus = FocusNode();
  final FocusNode _keyListenerNode = FocusNode();

  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _loading = false;

  // 0 = current, 1 = new, 2 = confirm, 3 = submit
  int _focusZone = 0;

  String? _currentPwError;
  String? _newPwError;
  String? _confirmPwError;

  static const Color _accentColor = Color(0xFF5C6BC0);
  static const Color _focusBorderColor = Colors.white;

  @override
  void initState() {
    super.initState();
    // Request key-listener focus for TV remote
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyListenerNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _currentPwCtrl.dispose();
    _newPwCtrl.dispose();
    _confirmPwCtrl.dispose();
    _currentPwFocus.dispose();
    _newPwFocus.dispose();
    _confirmPwFocus.dispose();
    _submitFocus.dispose();
    _keyListenerNode.dispose();
    super.dispose();
  }

  // ── TV Remote navigation ───────────────────────────────────────────────────

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    // If a text field is active, let it handle keys normally
    final primary = FocusManager.instance.primaryFocus;
    if (primary?.context?.widget is EditableText) return;

    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() => _focusZone = (_focusZone + 1).clamp(0, 3));
      _requestFocusForZone(_focusZone);
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_focusZone > 0) {
        setState(() => _focusZone = (_focusZone - 1).clamp(0, 3));
        _requestFocusForZone(_focusZone);
      } else {
        Navigator.maybePop(context);
      }
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      if (_focusZone == 3) {
        _submit();
      } else {
        // Open keyboard for text field
        _requestFocusForZone(_focusZone);
      }
    } else if (key == LogicalKeyboardKey.goBack ||
        key == LogicalKeyboardKey.escape) {
      Navigator.maybePop(context);
    }
  }

  void _requestFocusForZone(int zone) {
    switch (zone) {
      case 0:
        _currentPwFocus.requestFocus();
        break;
      case 1:
        _newPwFocus.requestFocus();
        break;
      case 2:
        _confirmPwFocus.requestFocus();
        break;
      case 3:
        _submitFocus.requestFocus();
        break;
    }
  }

  // ── Validation & Submit ───────────────────────────────────────────────────

  bool _validate() {
    bool ok = true;
    setState(() {
      _currentPwError = null;
      _newPwError = null;
      _confirmPwError = null;
    });

    if (_currentPwCtrl.text.isEmpty) {
      setState(() => _currentPwError = 'Enter your current password');
      ok = false;
    }
    if (_newPwCtrl.text.length < 6) {
      setState(() => _newPwError = 'New password must be at least 6 characters');
      ok = false;
    }
    if (_confirmPwCtrl.text != _newPwCtrl.text) {
      setState(() => _confirmPwError = 'Passwords do not match');
      ok = false;
    }
    return ok;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    setState(() => _loading = true);

    try {
      bool success = await service.changePassword(
        currentPassword: _currentPwCtrl.text,
        newPassword: _newPwCtrl.text,
      );

      if (!mounted) return;
      setState(() => _loading = false);

      if (success) {
        _showFeedback(
          message: 'Password changed successfully!',
          isSuccess: true,
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.maybePop(context);
        });
      } else {
        _showFeedback(
          message: 'Incorrect current password. Please try again.',
          isSuccess: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showFeedback(message: 'An error occurred. Please try again.', isSuccess: false);
    }
  }

  void _showFeedback({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? Colors.green.shade700 : Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTV = size.width > 900;
    final double maxWidth = isTV ? 520.0 : double.infinity;

    return KeyboardListener(
      focusNode: _keyListenerNode,
      onKeyEvent: _handleKey,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF070708), Color(0xFF1D1B53)],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isTV ? size.width * 0.1 : 24,
                vertical: isTV ? size.height * 0.08 : 24,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button
                      IconButton(
                        onPressed: () => Navigator.maybePop(context),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      SizedBox(height: isTV ? 32 : 16),

                      // Title
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enter your current password and choose a new one.',
                        style: TextStyle(color: Colors.white54, fontSize: 14),
                      ),
                      SizedBox(height: isTV ? 48 : 36),

                      // Current Password
                      _PasswordField(
                        controller: _currentPwCtrl,
                        focusNode: _currentPwFocus,
                        label: 'Current Password',
                        showPassword: _showCurrent,
                        errorText: _currentPwError,
                        isFocused: _focusZone == 0,
                        onToggle: () => setState(() => _showCurrent = !_showCurrent),
                        onChanged: (_) => setState(() => _currentPwError = null),
                        onZoneFocus: () => setState(() => _focusZone = 0),
                        accentColor: _accentColor,
                        focusBorderColor: _focusBorderColor,
                        isTV: isTV,
                      ),
                      SizedBox(height: isTV ? 20 : 16),

                      // New Password
                      _PasswordField(
                        controller: _newPwCtrl,
                        focusNode: _newPwFocus,
                        label: 'New Password',
                        showPassword: _showNew,
                        errorText: _newPwError,
                        isFocused: _focusZone == 1,
                        onToggle: () => setState(() => _showNew = !_showNew),
                        onChanged: (_) => setState(() => _newPwError = null),
                        onZoneFocus: () => setState(() => _focusZone = 1),
                        accentColor: _accentColor,
                        focusBorderColor: _focusBorderColor,
                        isTV: isTV,
                      ),
                      SizedBox(height: isTV ? 20 : 16),

                      // Confirm Password
                      _PasswordField(
                        controller: _confirmPwCtrl,
                        focusNode: _confirmPwFocus,
                        label: 'Confirm Password',
                        showPassword: _showConfirm,
                        errorText: _confirmPwError,
                        isFocused: _focusZone == 2,
                        onToggle: () => setState(() => _showConfirm = !_showConfirm),
                        onChanged: (_) => setState(() => _confirmPwError = null),
                        onZoneFocus: () => setState(() => _focusZone = 2),
                        accentColor: _accentColor,
                        focusBorderColor: _focusBorderColor,
                        isTV: isTV,
                      ),
                      SizedBox(height: isTV ? 40 : 32),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: isTV ? 64 : 52,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: _focusZone == 3
                                ? Border.all(color: _focusBorderColor, width: 2.5)
                                : Border.all(color: Colors.transparent, width: 2.5),
                          ),
                          child: ElevatedButton(
                            focusNode: _submitFocus,
                            onPressed: _loading ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              disabledBackgroundColor: _accentColor.withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                        color: Colors.white, strokeWidth: 2.5))
                                : Text(
                                    'Submit',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: isTV ? 18 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reusable Password Field Widget
// ─────────────────────────────────────────────────────────────────────────────

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final bool showPassword;
  final String? errorText;
  final bool isFocused;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;
  final VoidCallback onZoneFocus;
  final Color accentColor;
  final Color focusBorderColor;
  final bool isTV;

  const _PasswordField({
    required this.controller,
    required this.focusNode,
    required this.label,
    required this.showPassword,
    required this.errorText,
    required this.isFocused,
    required this.onToggle,
    required this.onChanged,
    required this.onZoneFocus,
    required this.accentColor,
    required this.focusBorderColor,
    required this.isTV,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: isFocused
            ? Border.all(color: focusBorderColor, width: 2.5)
            : Border.all(color: Colors.transparent, width: 2.5),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        obscureText: !showPassword,
        onChanged: onChanged,
        onTap: onZoneFocus,
        style: TextStyle(
          color: Colors.white,
          fontSize: isTV ? 18 : 16,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white60),
          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
          suffixIcon: IconButton(
            icon: Icon(
              showPassword ? Icons.visibility_off : Icons.visibility_off_outlined,
              color: Colors.white54,
            ),
            onPressed: onToggle,
            focusNode: FocusNode(skipTraversal: true),
          ),
          errorText: errorText,
          errorStyle: const TextStyle(color: Colors.redAccent),
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isTV ? 22 : 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: accentColor, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.redAccent, width: 2),
          ),
        ),
      ),
    );
  }
}