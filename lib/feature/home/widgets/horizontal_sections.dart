import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'recitersCardwidget.dart';
import 'package:qurany/feature/home/view/did_you_know_screen.dart';
import 'package:qurany/feature/home/view/quranic_stories_screen.dart';
import 'package:qurany/feature/home/view/reciters_screen.dart';
import 'package:qurany/feature/home/view/azkar_screen.dart';

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

  final List<Map<String, String>> items = const [
    {
      'title': "Masjid Quba is the first mosque in Islam",
      'image':
          'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': "The Quran was revealed over 23 years",
      'image':
          'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': "Surah Al-Ikhlas is equal to one-third of the Quran",
      'image':
          'https://images.unsplash.com/photo-1584281723358-461f7555806e?q=80&w=500&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ReusableHorizontalSection(
      title: "Did you know",
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DidYouKnowScreen()),
        );
      },
      height: 200.h,
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          width: 220.w,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: Stack(
            children: [
              Image.network(
                item['image']!,
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
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                alignment: Alignment.bottomLeft,
                child: Text(
                  item['title']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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

  final List<Map<String, String>> stories = const [
    {
      'title': "Story of Prophet Yusuf",
      'image':
          'https://images.unsplash.com/photo-1564121211835-e88c852648ab?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': "Story of Prophet Musa",
      'image':
          'https://images.unsplash.com/photo-1585032226651-759b368d7246?q=80&w=500&auto=format&fit=crop',
    },
    {
      'title': "Story of Prophet Ibrahim",
      'image':
          'https://images.unsplash.com/photo-1519817650390-64a93db51149?q=80&w=500&auto=format&fit=crop',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ReusableHorizontalSection(
      title: "Quranic Stories",
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const QuranicStoriesScreen()),
        );
      },
      height: 200.h,
      itemCount: stories.length,
      itemBuilder: (context, index) {
        final story = stories[index];
        return Container(
          width: 220.w,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.r)),
          child: Stack(
            children: [
              Image.network(
                story['image']!,
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
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                padding: EdgeInsets.all(12.w),
                alignment: Alignment.bottomLeft,
                child: Text(
                  story['title']!,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AzkarSection extends StatelessWidget {
  const AzkarSection({super.key});

  final List<Map<String, dynamic>> azkar = const [
    {
      'title': "Morning Azkar",
      'time': "08:00 AM",
      'image':
          'https://images.unsplash.com/photo-1531353826977-0941b4779a1c?q=80&w=500&auto=format&fit=crop',
      'color': Color(0xFFFFE0B2),
    },
    {
      'title': "Evening Azkar",
      'time': "05:00 PM",
      'image':
          'https://images.unsplash.com/photo-1506466010722-395aa2bef877?q=80&w=500&auto=format&fit=crop',
      'color': Color(0xFFC5CAE9),
    },
    {
      'title': "Before Sleep",
      'time': "10:00 PM",
      'image':
          'https://images.unsplash.com/photo-1531353826977-0941b4779a1c?q=80&w=500&auto=format&fit=crop',
      'color': Color(0xFFD1C4E9),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ReusableHorizontalSection(
      title: "Azkar",
      onSeeAll: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AzkarScreen()),
        );
      },
      height: 200.h,
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final item = azkar[index];
        return Container(
          width: 220.w,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            color: item['color'],
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
                    color: item['color'],
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
                    colors: [Colors.black.withOpacity(0.7), Colors.transparent],
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Padding(
                        padding: EdgeInsets.all(12.w),
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
                              item['time'],
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
