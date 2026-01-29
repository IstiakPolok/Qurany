import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'recitersCardwidget.dart';
import 'package:qurany/feature/home/view/did_you_know_screen.dart';
import 'package:qurany/feature/home/view/quranic_stories_screen.dart';
import 'package:qurany/feature/home/view/reciters_screen.dart';
import 'package:qurany/feature/home/view/azkar_screen.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/azkar_controller.dart';
import 'package:qurany/feature/home/controller/history_controller.dart';
import 'package:qurany/feature/home/view/azkar_detail_screen.dart';
import 'package:qurany/feature/home/view/detail_screen.dart';

import 'package:qurany/feature/home/controller/knowledge_controller.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;

  const SectionHeader({super.key, required this.title, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              "See all",
              style: TextStyle(fontSize: 12.sp, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }
}

class ReusableHorizontalSection extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final double height;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double? separatorWidth;

  const ReusableHorizontalSection({
    super.key,
    required this.title,
    required this.onSeeAll,
    required this.height,
    required this.itemCount,
    required this.itemBuilder,
    this.separatorWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(title: title, onSeeAll: onSeeAll),
        SizedBox(
          height: height,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            scrollDirection: Axis.horizontal,
            itemCount: itemCount,
            separatorBuilder: (_, __) =>
                SizedBox(width: separatorWidth ?? 12.w),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}

class DidYouKnowSection extends StatelessWidget {
  const DidYouKnowSection({super.key});

  @override
  Widget build(BuildContext context) {
    final KnowledgeController controller = Get.put(KnowledgeController());

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 200.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.knowledgeList.isEmpty) {
        return const SizedBox.shrink();
      }

      return ReusableHorizontalSection(
        title: "Did you know",
        onSeeAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const DidYouKnowScreen()),
          );
        },
        height: 200.h,
        itemCount: controller.knowledgeList.length,
        itemBuilder: (context, index) {
          final item = controller.knowledgeList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(data: item.toMap()),
                ),
              );
            },
            child: Container(
              width: 220.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: [
                  Image.network(
                    item.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(12.w),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      item.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class RecitersSection extends StatelessWidget {
  const RecitersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionHeader(
          title: "Reciters",
          onSeeAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecitersScreen()),
            );
          },
        ),
        HorizontalReciterList(),
      ],
    );
  }
}

class StoriesSection extends StatelessWidget {
  const StoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryController controller = Get.put(HistoryController());

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 200.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      if (controller.historyList.isEmpty) {
        return const SizedBox.shrink();
      }

      return ReusableHorizontalSection(
        title: "Quranic Stories",
        onSeeAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const QuranicStoriesScreen(),
            ),
          );
        },
        height: 200.h,
        itemCount: controller.historyList.length,
        itemBuilder: (context, index) {
          final story = controller.historyList[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(
                    data: {
                      'title': story.name,
                      'image': story.image,
                      'description': story.description,
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 220.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Stack(
                children: [
                  Image.network(
                    story.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade300,
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(12.w),
                    alignment: Alignment.bottomLeft,
                    child: Text(
                      story.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class AzkarSection extends StatelessWidget {
  const AzkarSection({super.key});

  @override
  Widget build(BuildContext context) {
    final AzkarController controller = Get.put(AzkarController());

    return Obx(() {
      if (controller.isLoading.value) {
        return SizedBox(
          height: 200.h,
          child: const Center(child: CircularProgressIndicator()),
        );
      }

      final azkarGroups = controller.uniqueAzkarGroups;

      if (azkarGroups.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            children: [
              SectionHeader(
                title: "Azkar",
                onSeeAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AzkarScreen(),
                    ),
                  );
                },
              ),
              SizedBox(
                height: 80.h,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "No Azkar available yet",
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 8.h),
                      GestureDetector(
                        onTap: () => controller.fetchAllAzkar(),
                        child: Text(
                          "Retry",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
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

      return ReusableHorizontalSection(
        title: "Azkar",
        onSeeAll: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AzkarScreen()),
          );
        },
        height: 180.h,
        itemCount: azkarGroups.length,
        itemBuilder: (context, index) {
          final item = azkarGroups[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AzkarDetailScreen(
                    categoryData: {
                      'title': item['title'],
                      'time': item['time'],
                      'duration': item['duration'],
                      'image': item['image'],
                    },
                  ),
                ),
              );
            },
            child: Container(
              width: 220.w,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.grey[200],
              ),
              child: Stack(
                children: [
                  Image.network(
                    item['image'],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported_outlined,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: EdgeInsets.all(12.w),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          item['duration'],
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}
