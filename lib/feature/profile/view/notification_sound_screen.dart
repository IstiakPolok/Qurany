import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:audioplayers/audioplayers.dart';

class NotificationSoundScreen extends StatefulWidget {
  final String? initialAlert;
  final String? initialAdhan;
  const NotificationSoundScreen({super.key, this.initialAlert, this.initialAdhan});

  @override
  State<NotificationSoundScreen> createState() =>
      _NotificationSoundScreenState();
}

class _NotificationSoundScreenState extends State<NotificationSoundScreen> {
  String selectedAlert = 'silent';
  String selectedAdhan = 'madinah';
  String playingAdhan =
      ''; // Track which adhan is "playing" (showing pause icon)

  @override
  void initState() {
    super.initState();
    if (widget.initialAlert != null) selectedAlert = widget.initialAlert!;
    if (widget.initialAdhan != null) {
      // Map label back to id if needed, or just handle it
      // For now, if it's a label like "Adhan(Makkah)", we might need a reverse map
      // but if the UI is used consistent with labels, we can just use them.
      // However, the screen uses IDs like 'madinah'.
      _mapLabelToId(widget.initialAdhan!);
    }
  }

  void _mapLabelToId(String label) {
    if (label.contains("Azan1")) selectedAdhan = 'azan1';
    else if (label.contains("Madinah")) selectedAdhan = 'madinah';
    else if (label.contains("Makkah")) selectedAdhan = 'makkah';
    else if (label.contains("Indonesia")) selectedAdhan = 'indonesia1';
    else if (label.contains("Without")) selectedAdhan = 'without';
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _togglePlaySound(String value) async {
    if (playingAdhan == value) {
      await _audioPlayer.stop();
      setState(() {
        playingAdhan = 'stopped';
      });
      return;
    }

    String assetPath = "";
    switch (value) {
      case 'azan1':
        assetPath = "audio/azan1.mp3";
        break;
      case 'madinah':
        assetPath = "audio/Mishary Rashid Al-Afasy.mp3";
        break;
      case 'makkah':
        assetPath = "audio/Nasser Al-Qatami.mp3";
        break;
      case 'indonesia1':
        assetPath = "audio/Yasser Al-Dosari.mp3";
        break;
      case 'indonesia2':
        assetPath = "audio/Abu Bakr Al-Shatri.mp3";
        break;
      case 'makkah2':
        assetPath = "audio/azan1.mp3";
        break;
      default:
        return;
    }

    if (assetPath.isNotEmpty) {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(assetPath));
      setState(() {
        playingAdhan = value;
      });
    }
  }

  String _selectedAdhanLabel() {
    switch (selectedAdhan) {
      case 'without':
        return 'Without sound';
      case 'azan1':
        return 'Adhan(Azan1)';
      case 'madinah':
        return 'Adhan(Madinah)';
      case 'makkah':
        return 'Adhan(Makkah)';
      case 'indonesia1':
      case 'indonesia2':
        return 'Adhan(Indonesia)';
      case 'makkah2':
        return 'Adhan(Makkah)';
      default:
        return 'Adhan(Makkah)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Alerts",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildAlertCard(
                      id: 'silent',
                      icon: Icons.notifications_off_outlined,
                      title: "Silent",
                    ),
                    _buildAlertCard(
                      id: 'default',
                      icon: Icons.notifications_outlined,
                      title: "Default Notification Sound",
                    ),
                    _buildAlertCard(
                      id: 'long_beep',
                      icon: Icons.notifications_active_outlined,
                      title: "Long Beep",
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      "Choose the Adhan Sound",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    _buildAdhanCard(
                      id: 'azan1',
                      title: "Adhan(Azan1)",
                      subtitle: "Default Azan Tone",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(id: 'without', title: "Without sound"),
                    _buildAdhanCard(
                      id: 'madinah',
                      title: "Adhan(Madinah)",
                      subtitle: "Mishary Rashid Alafasy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'makkah',
                      title: "Adhan(Makkah)",
                      subtitle: "Abdul Basit Abdul Samad",
                      showPlayButton: true,
                      isInitiallyPlaying: true,
                    ),
                    _buildAdhanCard(
                      id: 'indonesia1',
                      title: "Adhan(Indonesia)",
                      subtitle: "Ahmed Al Ajmy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'indonesia2',
                      title: "Adhan(Indonesia)",
                      subtitle: "Ahmed Al Ajmy",
                      showPlayButton: true,
                    ),
                    _buildAdhanCard(
                      id: 'makkah2',
                      title: "Adhan(Makkah)",
                      subtitle: "Abdul Rehman Sudais",
                      showPlayButton: true,
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  size: 16.sp,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                Navigator.pop(context, _selectedAdhanLabel());
              },
              child: Text(
                'Done',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
          ),
          Text(
            "Notification Sound",
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0F2630),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard({
    required String id,
    required IconData icon,
    required String title,
  }) {
    bool isSelected = selectedAlert == id;
    return GestureDetector(
      onTap: () => setState(() => selectedAlert = id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 24.sp, color: Colors.black87),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            _buildSelectionIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildAdhanCard({
    required String id,
    required String title,
    String? subtitle,
    bool showPlayButton = false,
    bool isInitiallyPlaying = false,
  }) {
    bool isSelected = selectedAdhan == id;
    bool isPlaying =
        playingAdhan == id || (isInitiallyPlaying && playingAdhan == '');

    return GestureDetector(
      onTap: () => setState(() => selectedAdhan = id),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF2E7D32) : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            if (showPlayButton) ...[
              GestureDetector(
                onTap: () {
                  _togglePlaySound(id);
                },
                child: Icon(
                  isPlaying
                      ? Icons.pause_circle_filled
                      : Icons.play_arrow_rounded,
                  size: 32.sp,
                  color: isPlaying ? const Color(0xFF2E7D32) : Colors.black87,
                ),
              ),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ),
            _buildSelectionIndicator(isSelected),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionIndicator(bool isSelected) {
    return Container(
      width: 22.w,
      height: 22.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? const Color(0xFF2E7D32) : Colors.grey[400]!,
          width: 1.5,
        ),
      ),
      child: isSelected
          ? Center(
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
              ),
            )
          : null,
    );
  }
}
