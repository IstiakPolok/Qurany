import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/view/detail_screen.dart';
import '../controller/knowledge_controller.dart';

class DidYouKnowScreen extends StatelessWidget {
  const DidYouKnowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final KnowledgeController controller = Get.put(KnowledgeController());

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
          "Did you know",
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
              } else if (controller.error.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
                      SizedBox(height: 16.h),
                      Text(
                        "Error loading data",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                      TextButton(
                        onPressed: () => controller.fetchKnowledgeItems(),
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              } else if (controller.knowledgeList.isEmpty) {
                return const Center(child: Text("No items found"));
              }

              final items = controller.knowledgeList;
              return ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                itemCount: items.length,
                separatorBuilder: (context, index) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final item = items[index];
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
                            knowledgeData: item,
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
                                    ],
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    item.description,
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                      height: 1.4,
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
