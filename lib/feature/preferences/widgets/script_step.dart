import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';

class ScriptStep extends StatefulWidget {
  const ScriptStep({super.key});

  @override
  State<ScriptStep> createState() => _ScriptStepState();
}

class _ScriptStepState extends State<ScriptStep> {
  String selectedScript = 'Imlaei';

  @override
  void initState() {
    super.initState();
    _loadScript();
  }

  Future<void> _loadScript() async {
    final script = await SharedPreferencesHelper.getArabicScript();
    if (mounted) {
      setState(() {
        selectedScript = script;
      });
    }
  }

  Future<void> _selectScript(String script) async {
    setState(() {
      selectedScript = script;
    });
    await SharedPreferencesHelper.saveArabicScript(script);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        children: [
          SizedBox(height: 40.h),
          Text(
            "Select your Arabic script",
            style: GoogleFonts.abhayaLibre(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          Text(
            "Choose how you want to read the Quran.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
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
                        fontFamily: selectedScript == 'IndoPak'
                            ? 'IndoPakFont'
                            : 'Amiri', // Placeholder fonts
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
              "App recommended",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 10.h),

          _buildOption(
            title: "IndoPak",
            subtitle: "South Asian style",
            value: "IndoPak",
          ),

          SizedBox(height: 20.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Other Fonts",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
            ),
          ),
          SizedBox(height: 10.h),

          _buildOption(
            title: "Imlaei",
            subtitle: "Simplified text",
            value: "Imlaei",
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required String title,
    required String subtitle,
    required String value,
  }) {
    final isSelected = selectedScript == value;
    return GestureDetector(
      onTap: () => _selectScript(value),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isSelected ? Border.all(color: Colors.green, width: 2) : null,
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12.sp),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.green : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
