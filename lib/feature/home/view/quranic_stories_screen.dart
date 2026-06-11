import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/history_controller.dart';

import 'detail_screen.dart';

class QuranicStoriesScreen extends StatelessWidget {
  const QuranicStoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.find<HistoryController>();

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
          "Quranic Stories",
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

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.historyList.isEmpty) {
                return const Center(child: Text("No stories found"));
              }

              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: controller.historyList.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = controller.historyList[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailScreen(
                            data: {
                              'title': item.name,
                              'image': item.image,
                              'description': item.description,
                            },
                            historyData: item,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Image
                          ClipRRect(
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(16.r),
                            ),
                            child: Image.network(
                              item.image,
                              width: 100.w,
                              height: 100.w,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: 100.w,
                                  height: 100.w,
                                  color: Colors.grey.shade300,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(width: 16.w),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 12.h,
                                horizontal: 8.w,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(width: 8.w),
                                      Obx(() {
                                        final isBookmarked = controller
                                            .bookmarkedIds
                                            .contains(item.id);
                                        final isBookmarking = controller
                                            .bookmarkingIds
                                            .contains(item.id);
                                        return GestureDetector(
                                          onTap: () => controller
                                              .toggleBookmark(item.id),
                                          child: Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.grey.shade300,
                                                width: 1.5,
                                              ),
                                            ),
                                            child: isBookmarking
                                                ? SizedBox(
                                                    width: 14.sp,
                                                    height: 14.sp,
                                                    child:
                                                        const CircularProgressIndicator(
                                                          strokeWidth: 1.5,
                                                          color: Color(
                                                            0xFF2E7D32,
                                                          ),
                                                        ),
                                                  )
                                                : Icon(
                                                    isBookmarked
                                                        ? Icons.bookmark
                                                        : Icons.bookmark_border,
                                                    size: 14.sp,
                                                    color: isBookmarked
                                                        ? const Color(
                                                            0xFF2E7D32,
                                                          )
                                                        : Colors.grey.shade600,
                                                  ),
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey.shade600,
                                      height: 1.3,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
