import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';

class RecitersScreen extends StatelessWidget {
  const RecitersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final VerseOfDayController controller = Get.find<VerseOfDayController>();

    return Scaffold(
      backgroundColor: const Color(
        0xFFFFFAF3,
      ), // Match overall cream background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search",
                        hintStyle: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
                ],
              ),
            ),
          ),

          // Reciters List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value ||
                  controller.randomVerse.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final audioData =
                  controller.randomVerse.value!.data.verse.verse.audio;
              if (audioData == null || audioData.isEmpty) {
                return const Center(child: Text("No audio available"));
              }

              final List<Map<String, String>> reciters = audioData.values.map((
                audioInfo,
              ) {
                String placeholderImg =
                    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";

                String description = "Qurany Reciter";

                if (audioInfo.reciter.contains("Sudais")) {
                  placeholderImg =
                      "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1";
                  description = "Imam of Masjid al-Haram";
                } else if (audioInfo.reciter.contains("Yasser") ||
                    audioInfo.reciter.contains("Dussary")) {
                  placeholderImg =
                      "https://i.scdn.co/image/ab67616100005174e4bd7040657e8e61dc4667be";
                  description = "Saudi Islamic scholar";
                } else if (audioInfo.reciter.contains("Nasser") ||
                    audioInfo.reciter.contains("Qatami")) {
                  placeholderImg =
                      "https://i1.sndcdn.com/artworks-IUNBxRxsvNOlQ55w-xPQ9Yw-t500x500.jpg";
                  description = "The voice of Saudi Arabia";
                } else if (audioInfo.reciter.contains("Mishary") ||
                    audioInfo.reciter.contains("Alafasy")) {
                  placeholderImg =
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
                  description = "The Voice of Devotion";
                } else if (audioInfo.reciter.contains("Abu Bakr") ||
                    audioInfo.reciter.contains("Shatri")) {
                  placeholderImg =
                      "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUmPkcySF56YidTERKU54hBnQ0lf734dwb4w&s";
                  description = "The Golden Voice of Egypt";
                }

                return {
                  'name': audioInfo.reciter,
                  'description': description,
                  'image': placeholderImg,
                  'audio': audioInfo.url,
                };
              }).toList();

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: reciters.length,
                separatorBuilder: (context, index) => Divider(
                  color: Colors.grey.shade200,
                  height: 32.h,
                  thickness: 1,
                ),
                itemBuilder: (context, index) {
                  final item = reciters[index];

                  return Row(
                    children: [
                      // Reciter Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(
                          item['image']!,
                          width: 56.w,
                          height: 56.w,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 56.w,
                                height: 56.w,
                                color: Colors.grey.shade300,
                                child: Icon(Icons.person, color: Colors.grey),
                              ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      // Reciter Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item['description']!,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Play Button only (No download button per user request)
                      SizedBox(width: 12.w),
                      Obx(() {
                        final bool isPlaying =
                            controller.currentlyPlayingUrl.value ==
                            item['audio'];
                        return GestureDetector(
                          onTap: () {
                            if (item['audio'] != null) {
                              controller.toggleAudio(item['audio']!);
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isPlaying
                                    ? const Color(0xFF2E7D32)
                                    : Colors.grey.shade300,
                                width: 1.5,
                              ),
                              color: Colors.transparent,
                            ),
                            child: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 20.sp,
                              color: isPlaying
                                  ? const Color(0xFF2E7D32)
                                  : Colors.grey.shade600,
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
