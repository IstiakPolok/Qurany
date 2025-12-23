import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DownloadedRecitersScreen extends StatelessWidget {
  const DownloadedRecitersScreen({super.key});

  final List<Map<String, String>> items = const [
    {
      'name': "Mishary Al-Afasy",
      'description': "The Voice of Devotion",
      'image':
          'https://images.unsplash.com/photo-1564121211835-e88c852648ab?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Sheikh Sudais",
      'description': "Imam of Masjid al-Haram",
      'image':
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Sheikh Abdul Basit",
      'description': "The Golden Voice of Egypt",
      'image':
          'https://images.unsplash.com/photo-1519817650390-64a93db51149?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Sheikh Abdullah Zahir",
      'description': "The Voice of the UAE",
      'image':
          'https://images.unsplash.com/photo-1542353436-312f0e1f67ff?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Sheikh Mansour",
      'description': "The Guiding Light of Mecca",
      'image':
          'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Yasir al-Dawsari",
      'description': "Saudi Islamic scholar",
      'image':
          'https://images.unsplash.com/photo-1602693822003-8d689b0d1e0d?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
    {
      'name': "Saud Al-Shuraim",
      'description': "The voice of Saudi Arabia",
      'image':
          'https://images.unsplash.com/photo-1554508494-b295996fdef1?q=80&w=500&auto=format&fit=crop', // Placeholder
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          "Reciters",
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 12.h,
          childAspectRatio: 0.8,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: DecorationImage(
                image: NetworkImage(item['image']!),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                // Gradient Overlay
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(
                          0.9,
                        ), // Darker for text readability
                        Colors.transparent,
                      ],
                      stops: [0.0, 0.5],
                    ),
                  ),
                ),

                // Play Button (Top Left)
                Positioned(
                  top: 12.h,
                  left: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(
                      Icons.play_arrow,
                      size: 20.sp,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),

                // Download Button (Top Right)
                Positioned(
                  top: 12.h,
                  right: 12.w,
                  child: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.delete, size: 20.sp, color: Colors.red),
                  ),
                ),

                // Text (Bottom Left)
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['name']!,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          item['description']!,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
