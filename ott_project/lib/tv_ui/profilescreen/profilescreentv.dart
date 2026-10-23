import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ott_project/tv_ui/components/authprovider.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/LibraryScreen/likedmusicitemsTV1.dart';
import 'package:ott_project/tv_ui/LibraryScreen/playlistTV1.dart';
import 'package:ott_project/tv_ui/LibraryScreen/watchlaterTV1.dart';
import 'package:ott_project/tv_ui/profilescreen/changepasswordscreen_tv.dart';
import 'package:ott_project/url.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class TVProfileScreen extends StatefulWidget {
  const TVProfileScreen({super.key});

  @override
  State<TVProfileScreen> createState() => _TVProfileScreenState();
}

class _TVProfileScreenState extends State<TVProfileScreen> {
  final Service service = Service();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final ScrollController _scrollController = ScrollController();

  final FocusNode _keyboardFocusNode = FocusNode(debugLabel: 'profileKeyboard');

  Uint8List? profileImageBytes;
  String username = 'Loading...';
  String email = 'Loading...';
  String phoneNumber = '';
  String subscriptionPlan = 'Free';
  String expiry = '';
  bool isSubscribed = false;
  bool isSubscriptionExpired = false;
  int amount = 0;
  int daysLeft = 0;
  int selectedTab = 0;
  int? userId;

  static const int _zoneEDIT = 0;
  static const int _zoneCHANGE_PW = 1;
  static const int _zoneLOGOUT = 2;
  static const int _zoneSUBSCRIPTION = 3;
  static const int _zoneTAB_WATCH = 4;
  static const int _zoneTAB_LIKED = 5;
  static const int _zoneTAB_PLAYLIST = 6;

  int _focusedZone = _zoneEDIT;

  static const Color _focusBorderColor = Colors.white;
  static const Color _accentColor = Color(0xFF5C6BC0);

  @override
  void initState() {
    super.initState();
    fetchUserProfile();

    FocusManagerService.onLogoutSelectps = () => logout(context);
    FocusManagerService.onSubscriptionSelectedps = () => _showSubscriptionDialog();
    FocusManagerService.onTabSelected = (index) {
      setState(() => selectedTab = index);
    };

    _keyboardFocusNode.addListener(_onFocusChange);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _keyboardFocusNode.requestFocus();
    });
  }

  void _onFocusChange() {
    if (mounted) setState(() {});
  }

  Future<void> fetchUserProfile() async {
    var userData = await service.fetchUserProfile();
    if (userData != null) {
      String? userIdStr = await secureStorage.read(key: 'userId');
      int? parsedUserId = userIdStr != null ? int.tryParse(userIdStr) : null;

      setState(() {
        username = userData['username'] ?? 'Unknown';
        email = userData['email'] ?? 'No Email';
        phoneNumber = userData['phoneNumber']?.toString() ?? '';
        userId = parsedUserId;
      });

      // 404 handled gracefully — shows default avatar instead of crashing
      try {
        Uint8List? image = await service.fetchProfileImage();
        if (image != null && mounted) {
          setState(() => profileImageBytes = image);
        }
      } catch (_) {
        // No profile image uploaded yet — default avatar shown
      }

      if (parsedUserId != null) _loadSubscriptionStatus(parsedUserId);
    }
  }

  Future<void> _loadSubscriptionStatus(int uid) async {
    try {
      var response = await http.get(Uri.parse('$baseUrl/paymentHistory/$uid'));
      debugPrint('Response code Subs: ${response.statusCode}');
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          var sub = data[0];
          setState(() {
            subscriptionPlan = sub['subscriptionTitle'] ?? 'Free';
            expiry = sub['expiryDate'] ?? '';
            amount = sub['amount'] ?? 0;
            if (expiry.isNotEmpty) {
              DateTime expiryDate = DateTime.parse(expiry);
              DateTime now = DateTime.now();
              daysLeft = expiryDate.difference(now).inDays;
              isSubscriptionExpired = now.isAfter(expiryDate);
            }
            isSubscribed = subscriptionPlan != 'Free' && !isSubscriptionExpired;
          });
        } else {
          setState(() {
            subscriptionPlan = 'Free';
            isSubscribed = false;
          });
        }
      } else {
        debugPrint('Failed to load subscription');
      }
    } catch (e) {
      debugPrint('Error loading subscription: $e');
    }
  }

  void _showSubscriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black87,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Manage Subscription', style: TextStyle(color: Colors.white)),
        content: const Text(
          'To manage or renew your subscription, please use the mobile app.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  Future<void> logout(BuildContext context) async {
    final authProvider = Provider.of<AuthProviderTV>(context, listen: false);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (alertContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('You have been logged out successfully.'),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () async {
              Navigator.of(alertContext).pop();
              await authProvider.logout(context);
              Navigator.of(context).popUntil((route) => route.isFirst);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  FocusManagerService.setSidebarFocus();
                  FocusManagerService.globalFocusNode.requestFocus();
                });
              });
            },
          ),
        ],
      ),
    );
  }

  void _openEditProfile() {
    showDialog(
      context: context,
      builder: (ctx) => _EditProfileDialog(
        currentName: username,
        currentPhone: phoneNumber,
        currentEmail: email, // ✅ FIXED: pass email to dialog
        currentImageBytes: profileImageBytes,
        onSaved: (newName, newPhone, newEmail, newImage) async {
          // ✅ Upload image first if a new one was picked
          if (newImage != null) {
            await service.uploadProfileImage(newImage);
            if (mounted) setState(() => profileImageBytes = newImage);
          }
          // ✅ Update profile with all required fields including email
          bool success = await service.updateUserProfile(
            name: newName,
            phone: newPhone,
            email: newEmail, // ✅ FIXED: send email to backend
          );
          if (success && mounted) {
            setState(() {
              username = newName;
              phoneNumber = newPhone;
              email = newEmail;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated successfully')),
            );
          }
        },
      ),
    );
  }

  void _openChangePassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TVChangePasswordScreen()),
    );
  }

  void _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent) return;
    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowRight) {
      setState(() => _focusedZone = (_focusedZone + 1).clamp(_zoneEDIT, _zoneTAB_PLAYLIST));
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      setState(() => _focusedZone = (_focusedZone - 1).clamp(_zoneEDIT, _zoneTAB_PLAYLIST));
    } else if (key == LogicalKeyboardKey.arrowDown) {
      if (_focusedZone <= _zoneSUBSCRIPTION) {
        setState(() => _focusedZone = _zoneTAB_WATCH);
      }
    } else if (key == LogicalKeyboardKey.arrowUp) {
      if (_focusedZone >= _zoneTAB_WATCH) {
        setState(() => _focusedZone = _zoneEDIT);
      } else {
        FocusManagerService.setSidebarFocus();
      }
    } else if (key == LogicalKeyboardKey.select ||
        key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      _activateFocusedZone();
    } else if (key == LogicalKeyboardKey.goBack || key == LogicalKeyboardKey.escape) {
      FocusManagerService.setSidebarFocus();
    }
  }

  void _activateFocusedZone() {
    switch (_focusedZone) {
      case _zoneEDIT:
        _openEditProfile();
        break;
      case _zoneCHANGE_PW:
        _openChangePassword();
        break;
      case _zoneLOGOUT:
        logout(context);
        break;
      case _zoneSUBSCRIPTION:
        _showSubscriptionDialog();
        break;
      case _zoneTAB_WATCH:
        setState(() => selectedTab = 0);
        break;
      case _zoneTAB_LIKED:
        setState(() => selectedTab = 1);
        break;
      case _zoneTAB_PLAYLIST:
        setState(() => selectedTab = 2);
        break;
    }
  }

  @override
  void dispose() {
    _keyboardFocusNode.removeListener(_onFocusChange);
    _keyboardFocusNode.dispose();
    FocusManagerService.onLogoutSelectps = null;
    FocusManagerService.onTabSelected = null;
    FocusManagerService.onLikedSongsSelect = null;
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isTV = size.width > 900;
    final double pad = size.width * 0.04;
    final double avatarRadius = isTV ? size.width * 0.045 : size.width * 0.12;
    final double baseFontSize = isTV ? size.width * 0.014 : size.width * 0.038;

    return KeyboardListener(
      focusNode: _keyboardFocusNode,
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
            child: isTV
                ? _buildTVLayout(size, pad, avatarRadius, baseFontSize)
                : _buildMobileLayout(size, pad, avatarRadius, baseFontSize),
          ),
        ),
      ),
    );
  }

  Widget _buildTVLayout(Size size, double pad, double avatarRadius, double fs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: size.height * 0.04),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              _TVProfileAvatar(imageBytes: profileImageBytes, radius: avatarRadius * 0.6),
              SizedBox(width: pad * 0.8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(username,
                      style: TextStyle(
                          fontSize: fs * 1.3,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  Text(email,
                      style: TextStyle(fontSize: fs * 0.9, color: Colors.white60)),
                  if (phoneNumber.isNotEmpty)
                    Text(phoneNumber,
                        style: TextStyle(fontSize: fs * 0.9, color: Colors.white60)),
                ],
              ),
              const Spacer(),
              _TVActionButton(
                label: 'Edit Profile',
                icon: Icons.edit,
                isFocused: _focusedZone == _zoneEDIT,
                onTap: _openEditProfile,
                fontSize: fs,
              ),
              SizedBox(width: pad * 0.4),
              _TVActionButton(
                label: 'Change Password',
                icon: Icons.lock_outline,
                isFocused: _focusedZone == _zoneCHANGE_PW,
                onTap: _openChangePassword,
                fontSize: fs,
              ),
              SizedBox(width: pad * 0.4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: _focusedZone == _zoneSUBSCRIPTION
                      ? Border.all(color: _focusBorderColor, width: 2.5)
                      : Border.all(color: Colors.transparent, width: 2.5),
                  boxShadow: (!isSubscriptionExpired && daysLeft <= 10)
                      ? [BoxShadow(color: Colors.redAccent.withOpacity(0.8), blurRadius: 18)]
                      : [],
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor:
                        isSubscriptionExpired ? Colors.red : _accentColor.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(vertical: fs * 1.1, horizontal: fs * 1.2),
                    elevation: 0,
                  ),
                  onPressed: _showSubscriptionDialog,
                  focusNode: FocusNode(skipTraversal: true),
                  child: Text(
                    isSubscriptionExpired
                        ? 'Renew Subscription'
                        : 'Expires in $daysLeft day${daysLeft == 1 ? '' : 's'}',
                    style: TextStyle(color: Colors.white, fontSize: fs * 0.85),
                  ),
                ),
              ),
              SizedBox(width: pad * 0.4),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: _focusedZone == _zoneLOGOUT
                      ? Border.all(color: _focusBorderColor, width: 2.5)
                      : Border.all(color: Colors.transparent, width: 2.5),
                ),
                child: IconButton(
                  onPressed: () => logout(context),
                  icon: Icon(
                    Icons.logout,
                    color: _focusedZone == _zoneLOGOUT ? Colors.white : Colors.white60,
                    size: fs * 1.5,
                  ),
                  focusNode: FocusNode(skipTraversal: true),
                  tooltip: 'Logout',
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Row(
            children: [
              _buildTabButton('Watchlist', 0, _zoneTAB_WATCH, fs),
              SizedBox(width: pad * 0.3),
              _buildTabButton('Liked Music', 1, _zoneTAB_LIKED, fs),
              SizedBox(width: pad * 0.3),
              _buildTabButton('Playlist', 2, _zoneTAB_PLAYLIST, fs),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: userId == null
              ? const Center(child: CircularProgressIndicator())
              : selectedTab == 0
                  ? TVWatchlistscreen1(userId: userId!)
                  : selectedTab == 1
                      ? LikedSongsTVProfile(userId: userId!)
                      : TVPlayListTV1(userId: userId!),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(Size size, double pad, double avatarRadius, double fs) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          SizedBox(height: size.height * 0.04),
          Center(
            child: Column(
              children: [
                _TVProfileAvatar(imageBytes: profileImageBytes, radius: avatarRadius),
                const SizedBox(height: 12),
                Text(username,
                    style: TextStyle(
                        fontSize: fs * 1.1,
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.04),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              children: [
                _MobileInfoRow(label: 'Name', value: username),
                _MobileInfoRow(label: 'Email', value: email),
                if (phoneNumber.isNotEmpty)
                  _MobileInfoRow(label: 'Phone Number', value: phoneNumber),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.05),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _openEditProfile,
                    child: Text('Edit Profile',
                        style: TextStyle(
                            fontSize: fs, color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: _openChangePassword,
                    child: Text('Change Password',
                        style: TextStyle(fontSize: fs, color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: size.height * 0.06),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: pad),
            child: Row(
              children: [
                _buildTabButton('Watchlist', 0, _zoneTAB_WATCH, fs),
                const SizedBox(width: 8),
                _buildTabButton('Liked', 1, _zoneTAB_LIKED, fs),
                const SizedBox(width: 8),
                _buildTabButton('Playlist', 2, _zoneTAB_PLAYLIST, fs),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 400,
            child: userId == null
                ? const Center(child: CircularProgressIndicator())
                : selectedTab == 0
                    ? TVWatchlistscreen1(userId: userId!)
                    : selectedTab == 1
                        ? LikedSongsTVProfile(userId: userId!)
                        : TVPlayListTV1(userId: userId!),
          ),
          SizedBox(height: size.height * 0.04),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int tabIndex, int zone, double fs) {
    final bool isFocused = _focusedZone == zone;
    final bool isSelected = selectedTab == tabIndex;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: isFocused
            ? Border.all(color: _focusBorderColor, width: 2.5)
            : Border.all(color: Colors.transparent, width: 2.5),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        scale: isFocused ? 1.1 : 1.0,
        child: ElevatedButton(
          onPressed: () => setState(() => selectedTab = tabIndex),
          focusNode: FocusNode(skipTraversal: true),
          style: ElevatedButton.styleFrom(
            backgroundColor: (isFocused || isSelected) ? _accentColor : Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            side: BorderSide(
              color: isSelected && !isFocused ? _accentColor : Colors.transparent,
            ),
            padding: EdgeInsets.symmetric(vertical: fs * 0.7, horizontal: fs * 1.0),
          ),
          child: Text(label,
              style: TextStyle(fontSize: fs * 0.85, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _TVProfileAvatar extends StatelessWidget {
  final Uint8List? imageBytes;
  final double radius;
  const _TVProfileAvatar({required this.imageBytes, required this.radius});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey.shade800,
      backgroundImage: imageBytes != null ? MemoryImage(imageBytes!) : null,
      child: imageBytes == null
          ? Icon(Icons.account_circle, size: radius * 1.1, color: Colors.white54)
          : null,
    );
  }
}

class _TVActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isFocused;
  final VoidCallback onTap;
  final double fontSize;
  const _TVActionButton({
    required this.label,
    required this.icon,
    required this.isFocused,
    required this.onTap,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: isFocused
            ? Border.all(color: Colors.white, width: 2.5)
            : Border.all(color: Colors.white24, width: 1.5),
        color: isFocused ? Colors.white.withOpacity(0.12) : Colors.transparent,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: fontSize * 1.0, vertical: fontSize * 0.7),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: fontSize * 1.2),
              SizedBox(width: fontSize * 0.4),
              Text(label,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: fontSize * 0.85,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileInfoRow extends StatelessWidget {
  final String label;
  final String value;
  const _MobileInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
          const Text('  :  ', style: TextStyle(color: Colors.white70)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Edit Profile Dialog
// ─────────────────────────────────────────────────────────────────────────────

class _EditProfileDialog extends StatefulWidget {
  final String currentName;
  final String currentPhone;
  final String currentEmail; // ✅ ADDED
  final Uint8List? currentImageBytes;
  // ✅ FIXED: callback now includes email
  final Future<void> Function(String name, String phone, String email, Uint8List? image) onSaved;

  const _EditProfileDialog({
    required this.currentName,
    required this.currentPhone,
    required this.currentEmail, // ✅ ADDED
    required this.currentImageBytes,
    required this.onSaved,
  });

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  Uint8List? _newImage;
  bool _saving = false;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _phoneCtrl = TextEditingController(text: widget.currentPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ✅ Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _newImage = bytes);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open gallery: $e')),
        );
      }
    }
  }

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name cannot be empty')));
      return;
    }
    setState(() => _saving = true);
    // ✅ FIXED: pass currentEmail through so backend doesn't get empty email
    await widget.onSaved(
      _nameCtrl.text.trim(),
      _phoneCtrl.text.trim(),
      widget.currentEmail, // ✅ email is read-only — passed as-is
      _newImage,
    );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final ImageProvider? displayImage = _newImage != null
        ? MemoryImage(_newImage!)
        : widget.currentImageBytes != null
            ? MemoryImage(widget.currentImageBytes!)
            : null;

    return AlertDialog(
      backgroundColor: const Color(0xFF1A1A3E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with camera button — tapping opens gallery
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey.shade700,
                    backgroundImage: displayImage,
                    child: displayImage == null
                        ? const Icon(Icons.account_circle, size: 55, color: Colors.white54)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF5C6BC0),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.camera_alt, size: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _dialogTextField(controller: _nameCtrl, label: 'Name', icon: Icons.person),
            const SizedBox(height: 12),
            _dialogTextField(
                controller: _phoneCtrl,
                label: 'Phone Number',
                icon: Icons.phone,
                keyboardType: TextInputType.phone),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF5C6BC0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Widget _dialogTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white60),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.06),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF5C6BC0), width: 2),
        ),
      ),
    );
  }
}