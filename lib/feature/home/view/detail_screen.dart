import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/ask_ai/view/ask_ai_intro_screen.dart';
import 'package:qurany/feature/home/model/history_model.dart';
import 'package:qurany/feature/home/model/knowledge_model.dart';
import 'package:qurany/feature/home/controller/history_controller.dart';

class DetailScreen extends StatelessWidget {
  final Map<String, String> data;
  final HistoryModel? historyData;
  final KnowledgeModel? knowledgeData;

  const DetailScreen({
    super.key,
    required this.data,
    this.historyData,
    this.knowledgeData,
  });

  @override
  Widget build(BuildContext context) {
    final dynamic activeData = historyData ?? knowledgeData;
    final String screenTitle = historyData != null
        ? "Quranic Stories"
        : "Did you know";

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0), // Cream background
      body: Stack(
        children: [
          // Content Scroll
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 100.h), // Space for header
                // Image
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: Image.network(
                      data['image'] ?? '',
                      width: double.infinity,
                      height: 220.h,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          width: double.infinity,
                          height: 220.h,
                          color: Colors.grey.shade200,
                          child: Center(
                            child: SizedBox(
                              width: 30.w,
                              height: 30.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.0,
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                    : null,
                                color: const Color(0xFF2E7D32),
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 220.h,
                          color: Colors.grey.shade300,
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                            size: 50.sp,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['title'] ?? '',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        data['description'] ?? '',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade800,
                          height: 1.5,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      if (activeData != null) ...[
                        // Secondary Images (if exist)
                        if (activeData.image1.isNotEmpty ||
                            activeData.image2.isNotEmpty)
                          Row(
                            children: [
                              if (activeData.image1.isNotEmpty)
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.network(
                                      activeData.image1,
                                      height: 150.h,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 150.h,
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: SizedBox(
                                              width: 24.w,
                                              height: 24.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                    : null,
                                                color: const Color(0xFF2E7D32),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 150.h,
                                                color: Colors.grey.shade300,
                                              ),
                                    ),
                                  ),
                                ),
                              if (activeData.image1.isNotEmpty &&
                                  activeData.image2.isNotEmpty)
                                SizedBox(width: 12.w),
                              if (activeData.image2.isNotEmpty)
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(12.r),
                                    child: Image.network(
                                      activeData.image2,
                                      height: 150.h,
                                      fit: BoxFit.cover,
                                      loadingBuilder: (context, child, loadingProgress) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Container(
                                          height: 150.h,
                                          color: Colors.grey.shade200,
                                          child: Center(
                                            child: SizedBox(
                                              width: 24.w,
                                              height: 24.w,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                value:
                                                    loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          (loadingProgress
                                                                  .expectedTotalBytes ??
                                                              1)
                                                    : null,
                                                color: const Color(0xFF2E7D32),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                                height: 150.h,
                                                color: Colors.grey.shade300,
                                              ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        SizedBox(height: 24.h),

                        // KEY INFORMATION
                        Text(
                          "KEY INFORMATION",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E7D32),
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 16.h),

                        // Sections
                        ...activeData.sections.map<Widget>((section) {
                          bool isFirst = activeData.sections.first == section;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                      top: 6.h,
                                      right: 8.w,
                                    ),
                                    child: Container(
                                      width: 4.w,
                                      height: 4.w,
                                      decoration: const BoxDecoration(
                                        color: Colors.black87,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      "${section.title}:",
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Padding(
                                padding: EdgeInsets.only(left: 12.w),
                                child: Text(
                                  section.description,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade800,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              SizedBox(height: 16.h),

                              if (isFirst &&
                                  activeData.quickFact.isNotEmpty) ...[
                                Container(
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE8F5E9),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            color: const Color(0xFF2E7D32),
                                            size: 18.sp,
                                          ),
                                          SizedBox(width: 8.w),
                                          Text(
                                            "QUICK FACT",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.bold,
                                              color: const Color(0xFF2E7D32),
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        activeData.quickFact,
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 16.h),
                              ],
                            ],
                          );
                        }).toList(),
                      ],
                      SizedBox(height: 100.h), // Space for floating button
                    ],
                  ),
                ),
              ],
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
                      color: Colors.white,
                      border: Border.all(color: Colors.black54, width: 1),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 20.sp,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Text(
                  screenTitle, // Dynamic title based on screen
                  style: TextStyle(
                    fontSize: 18.sp, // Match new app bar text size
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Only show bookmark icon for historyData
                if (historyData != null)
                  GestureDetector(
                    onTap: () {
                      if (Get.isRegistered<HistoryController>()) {
                        Get.find<HistoryController>().toggleBookmark(
                          historyData!.id,
                        );
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.black54, width: 1),
                      ),
                      child: Obx(() {
                        bool isBookmarked = false;
                        if (Get.isRegistered<HistoryController>()) {
                          isBookmarked = Get.find<HistoryController>()
                              .bookmarkedIds
                              .contains(historyData!.id);
                        }
                        return Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          size: 20.sp,
                          color: isBookmarked
                              ? const Color(0xFF2E7D32)
                              : Colors.black87,
                        );
                      }),
                    ),
                  )
                else
                  SizedBox(width: 38.w), // Placeholder to keep title centered
              ],
            ),
          ),

          // Floating Button
          Positioned(
            bottom: 30.h,
            left: 24.w,
            right: 24.w,
            child: ElevatedButton(
              onPressed: () {
                final title = data['title'] ?? '';
                final description = data['description'] ?? '';
                if (Get.isRegistered<AskAIController>()) {
                  Get.delete<AskAIController>();
                }
                final aiController = Get.put(AskAIController());
                final contextMessage =
                    'Tell me more about: $title\n\n$description';
                aiController.messageController.text = contextMessage;
                aiController.showChat.value = true;
                Get.to(() => const AskAIScreen());
                Future.delayed(const Duration(milliseconds: 400), () {
                  aiController.sendMessage();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), // Dark Green
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                elevation: 4,
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
}
