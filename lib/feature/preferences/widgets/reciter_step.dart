import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class ReciterStep extends StatefulWidget {
  const ReciterStep({super.key});

  @override
  State<ReciterStep> createState() => _ReciterStepState();
}

class _ReciterStepState extends State<ReciterStep> {
  String selectedReciter = 'Mishary Rashid Alafasy';
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<Map<String, String>> reciters = [
    {
      "name": "Mishary Rashid Alafasy",
      "path": "audio/Mishary Rashid Al-Afasy.mp3",
    },
    {"name": "Abu Bakr Al-Shatri", "path": "audio/Abu Bakr Al-Shatri.mp3"},
    {"name": "Nasser Al-Qatami", "path": "audio/Nasser Al-Qatami.mp3"},
    {"name": "Yasser Al-Dosari", "path": "audio/Yasser Al-Dosari.mp3"},
  ];

  @override
  void initState() {
    super.initState();
    _loadReciter();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadReciter() async {
    final reciter = await SharedPreferencesHelper.getReciter();
    if (mounted) {
      setState(() {
        selectedReciter = reciter;
      });
    }
  }

  Future<void> _selectReciter(String reciter, String audioPath) async {
    setState(() {
      selectedReciter = reciter;
    });
    await SharedPreferencesHelper.saveReciter(reciter);

    // Play preview
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(audioPath));
    } catch (e) {
      debugPrint("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "Select Your Reciter",
            style: GoogleFonts.abhayaLibre(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            "Choose your preferred Quran reciter.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 30.h),

          // Preview Card
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2D0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/image/Layer_1.png',
                      width: 32.w,
                      height: 32.h,
                    ),
                    Text(
                      "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        // Placeholder fonts
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "[All] praise is [due] to Allah, Lord of the worlds -",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 30.h),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Recommended Reciter",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 10.h),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: reciters.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final reciter = reciters[index];
              return _buildReciterOption(reciter['name']!, reciter['path']!);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReciterOption(String name, String path) {
    bool isSelected = selectedReciter == name;
    return GestureDetector(
      onTap: () => _selectReciter(name, path),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: Colors.green.withOpacity(0.5))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: Colors.black87,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: isSelected ? Colors.green[700] : Colors.white,
                shape: BoxShape.circle,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.all(6.w),
              child: Icon(
                isSelected ? Icons.volume_up : CupertinoIcons.volume_up,
                color: isSelected ? Colors.white : Colors.grey,
                size: 18.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
