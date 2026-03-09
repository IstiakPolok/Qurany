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
      backgroundColor: const Color(0xFFFFF9F0), // Cream background
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
      body: Obx(() {
        if (controller.isLoading.value ||
            controller.randomVerse.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final audioData = controller.randomVerse.value!.data.verse.verse.audio;
        if (audioData == null || audioData.isEmpty) {
          return const Center(child: Text("No audio available"));
        }

        final List<Map<String, String>> reciters = audioData.values.map((
          audioInfo,
        ) {
          String placeholderImg =
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";

          if (audioInfo.reciter.contains("Sudais")) {
            placeholderImg =
                "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1";
          } else if (audioInfo.reciter.contains("Yasser") ||
              audioInfo.reciter.contains("Dussary")) {
            placeholderImg =
                "https://i.scdn.co/image/ab67616100005174e4bd7040657e8e61dc4667be";
          } else if (audioInfo.reciter.contains("Nasser") ||
              audioInfo.reciter.contains("Qatami")) {
            placeholderImg =
                "https://scontent.fdac207-1.fna.fbcdn.net/v/t39.30808-6/470019064_1119048786249564_9159029543174380749_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=7b2446&_nc_ohc=O9kA8gkeLGMQ7kNvwGNr5oH&_nc_oc=AdnT-OiSE9RjU0v0kTD07qPFSudAeHeqDozhECy78a0zZ8DxGG4kud8d2Wg7InObuBY&_nc_zt=23&_nc_ht=scontent.fdac207-1.fna&_nc_gid=7xGR-giX8dhXhYZ-X3B0xg&_nc_ss=8&oh=00_AfwTIfRlr9uHLOvZeNeCuTaXLMyn9KiQObXJwr7oy-Ctmg&oe=69B44A59";
          } else if (audioInfo.reciter.contains("Mishary") ||
              audioInfo.reciter.contains("Alafasy")) {
            placeholderImg =
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
          } else if (audioInfo.reciter.contains("Abu Bakr") ||
              audioInfo.reciter.contains("Shatri")) {
            placeholderImg =
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUmPkcySF56YidTERKU54hBnQ0lf734dwb4w&s";
          }

          return {
            'name': audioInfo.reciter,
            'description': "Qurany Reciter",
            'image': placeholderImg,
            'audio': audioInfo.url,
          };
        }).toList();

        return GridView.builder(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 0.8,
          ),
          itemCount: reciters.length,
          itemBuilder: (context, index) {
            final item = reciters[index];
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
                          Colors.black.withOpacity(0.9),
                          Colors.transparent,
                        ],
                        stops: const [0.0, 0.5],
                      ),
                    ),
                  ),

                  // Play Button (Top Left)
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Obx(() {
                      final bool isPlaying =
                          controller.currentlyPlayingUrl.value == item['audio'];
                      return GestureDetector(
                        onTap: () {
                          if (item['audio'] != null) {
                            controller.toggleAudio(item['audio']!);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: Icon(
                            isPlaying ? Icons.pause : Icons.play_arrow,
                            size: 20.sp,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      );
                    }),
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
        );
      }),
    );
  }
}
