import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class ReciterStep extends StatefulWidget {
  const ReciterStep({super.key});

  @override
  State<ReciterStep> createState() => _ReciterStepState();
}

class _ReciterStepState extends State<ReciterStep> {
  String selectedReciter = 'Mishary Rashid Alafasy';

  final List<String> reciters = [
    "Mishary Rashid Alafasy",
    "Abdul Basit Abdul Samad",
    "Saad Al-Ghamdi",
    "Maher Al Muaiqly",
    "Ahmed Al Ajmy",
  ]; 

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
              color: const Color(0xFFE0E8D9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ ۝",
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 12.h),
                Text(
                  "[All] praise is [due] to Allah, Lord of the worlds -",
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
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
              return _buildReciterOption(reciters[index]);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildReciterOption(String name) {
    bool isSelected = selectedReciter == name;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedReciter = name;
        });
      },
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
