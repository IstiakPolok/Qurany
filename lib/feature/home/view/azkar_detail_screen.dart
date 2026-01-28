import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/azkar_controller.dart';
import 'package:qurany/feature/home/model/azkar_model.dart';

class AzkarDetailScreen extends StatefulWidget {
  final Map<String, dynamic> categoryData;

  const AzkarDetailScreen({super.key, required this.categoryData});

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  final AzkarController _controller = Get.find<AzkarController>();
  int _currentIndex = 0;
  final RxInt _counter = 0.obs;

  @override
  void initState() {
    super.initState();
    _controller.fetchAzkarByGroup(widget.categoryData['time']);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
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
          widget.categoryData['title'] ?? 'Azkar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Obx(() {
        if (_controller.isLoadingGroup.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_controller.azkarGroup.isEmpty) {
          return const Center(child: Text("No Azkar found for this group"));
        }

        return Column(
          children: [
            SizedBox(height: 20.h),
            // PageView for Azkar Cards
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                    _counter.value = 0; // Reset counter for new card
                  });
                },
                itemCount: _controller.azkarGroup.length,
                itemBuilder: (context, index) {
                  final item = _controller.azkarGroup[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.w),
                    child: Column(
                      children: [
                        // Azkar Title
                        Text(
                          item.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        // Card Data
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              _counter.value++;
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: Colors.green,
                                  width: 1.5,
                                ),
                              ),
                              padding: EdgeInsets.all(20.w),
                              child: Stack(
                                children: [
                                  SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Align(
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            item.azkar,
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              fontSize: 22.sp,
                                              height: 1.8,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 24.h),
                                        Text(
                                          item.translation,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.black87,
                                            height: 1.5,
                                          ),
                                        ),
                                        SizedBox(height: 60.h),
                                      ],
                                    ),
                                  ),
                                  // Bottom Action Icons
                                  Align(
                                    alignment: Alignment.bottomRight,
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.copy_all_outlined,
                                          color: Colors.grey,
                                          size: 24.sp,
                                        ),
                                        SizedBox(width: 16.w),
                                        Icon(
                                          Icons.bookmark_border,
                                          color: Colors.grey,
                                          size: 24.sp,
                                        ),
                                        SizedBox(width: 16.w),
                                        Icon(
                                          Icons.share_outlined,
                                          color: Colors.grey,
                                          size: 24.sp,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Controls Area
            SizedBox(height: 20.h),

            // Hexagon Counter
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: 0.785398, // 45 degrees
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF388E3C), // Green
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                Text(
                  "${_currentIndex + 1}/${_controller.azkarGroup.length}",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
              ],
            ),

            SizedBox(height: 20.h),

            // Playback Controls
            Container(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              margin: EdgeInsets.symmetric(horizontal: 40.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50.r),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(
                      Icons.skip_previous_outlined,
                      color: Colors.grey,
                      size: 28.sp,
                    ),
                  ),
                  Icon(Icons.play_arrow, color: Color(0xFF388E3C), size: 36.sp),
                  GestureDetector(
                    onTap: () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Icon(
                      Icons.skip_next_outlined,
                      color: Colors.grey,
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 12.h),
            Text(
              "Swipe right for more",
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
            ),
            SizedBox(height: 30.h),
          ],
        );
      }),
    );
  }
}
