import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> data;

  const DetailScreen({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 350.h,
            child: Image.network(
              data['image'] ?? '',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade300,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: Colors.grey,
                      size: 50.sp,
                    ),
                  ),
                );
              },
            ),
          ),

          // Header Buttons
          Positioned(
            top: 50.h,
            left: 24.w,
            right: 24.w,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(
                        0.1,
                      ), // Semi-transparent for visibility on image
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: Icon(
                    Icons.bookmark_border,
                    size: 20.sp,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          // Content Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.75.sh, // Take up bottom 75% of screen
              width: double.infinity,
              decoration: BoxDecoration(
                color: Color(0xFFFFF9F0), // Cream background
                borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 0),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.only(
                          bottom: 100.h,
                        ), // Space for button
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] ?? '',
                              style: TextStyle(
                                fontSize: 20.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                height: 1.3,
                              ),
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "Masjid e Quba, or Quba Mosque, is the first mosque in Islam, built in 1 AH (622 CE) in Medina, Saudi Arabia, by Prophet Muhammad (peace be upon him). It is a highly significant site for Muslims, known for its spiritual importance and as the first location where Prophet Muhammad and Abu Bakr stayed upon their migration from Makkah. Today, the mosque has undergone several renovations, with the current structure featuring six main domes and four minarets, and is capable of holding around 30,000 worshippers.",
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.black87,
                                height: 1.6,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            _buildBulletPoint(
                              "Historical Significance",
                              "It is considered the first mosque in Islamic history, built by Prophet Muhammad and his companions as they migrated from Makkah to Medina.",
                            ),
                            _buildBulletPoint(
                              "Location",
                              "The mosque is situated in Medina, Saudi Arabia, about 5 to 6 kilometers from the Prophet's Mosque (Masjid-e-Nabavi).",
                            ),
                            _buildBulletPoint(
                              "Religious Virtue",
                              "There is a specific reward for those who pray there. It is said that \"Whoever performs wudu in his house, then comes to Masjid Quba and offers one prayer therein, will have a reward like that for 'Umrah'.\"",
                            ),
                            _buildBulletPoint(
                              "Architecture",
                              "The original mosque was simple but has been renovated multiple times. The current structure is a masterpiece of Islamic architecture with 6 main domes and 4 minarets, notes Wikipedia.",
                            ),
                            _buildBulletPoint(
                              "Current Usage",
                              "The mosque is a place of worship that hosts prayers, including Friday prayers and both Eid prayers, and is a major site for pilgrims.",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Floating Button
          Positioned(
            bottom: 30.h,
            left: 24.w,
            right: 24.w,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E7D32), // Dark Green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.stars, color: Colors.yellow, size: 20.sp),
                  SizedBox(width: 8.w),
                  Text(
                    "Dive deeper in AI Mode",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: RichText(
        text: TextSpan(
          style: TextStyle(height: 1.6, fontSize: 14.sp, color: Colors.black87),
          children: [
            TextSpan(
              text: "• $title: ",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            TextSpan(text: content),
          ],
        ),
      ),
    );
  }
}
