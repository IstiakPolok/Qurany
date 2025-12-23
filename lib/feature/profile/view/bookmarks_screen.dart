import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BookmarksScreen extends StatefulWidget {
  const BookmarksScreen({super.key});

  @override
  State<BookmarksScreen> createState() => _BookmarksScreenState();
}

class _BookmarksScreenState extends State<BookmarksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> tabs = [
    'Surah',
    'Ayah',
    'Quranic Stories',
    'Azkar',
    'Knowledge',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            SizedBox(height: 12.h),

            // Tab Bar
            _buildTabBar(),

            SizedBox(height: 16.h),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSurahTab(),
                  _buildAyahTab(),
                  _buildQuranicStoriesTab(),
                  _buildAzkarTab(),
                  _buildKnowledgeTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Text(
                "Bookmarks",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _tabController.animateTo(index);
              setState(() {});
            },
            child: AnimatedBuilder(
              animation: _tabController,
              builder: (context, child) {
                final isSelected = _tabController.index == index;
                return Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2E7D32) : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF2E7D32)
                          : Colors.grey[300]!,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      tabs[index],
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // ==================== SURAH TAB ====================
  Widget _buildSurahTab() {
    final surahs = [
      {
        'name': 'Al-Fatiah',
        'arabic': 'الفاتحة',
        'location': 'MECCAN',
        'verses': '7 Ayat',
      },
      {
        'name': 'Al-Baqarah',
        'arabic': 'البقرة',
        'location': 'MEDINAN',
        'verses': '286 VERSES',
      },
      {
        'name': "Al 'Imran",
        'arabic': 'آل عمران',
        'location': 'MEDINAN',
        'verses': '200 VERSES',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Ayah",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildSearchBar(),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: surahs.length,
            itemBuilder: (context, index) {
              final surah = surahs[index];
              return _buildSurahItem(surah, index + 1);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSurahItem(Map<String, String> surah, int number) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Surah number icon
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.menu_book_outlined,
              color: const Color(0xFF2E7D32),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          // Surah info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah['name']!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${surah['location']} • ${surah['verses']}',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Arabic name
          Text(
            surah['arabic']!,
            style: TextStyle(fontSize: 18.sp, fontFamily: 'Amiri'),
          ),
        ],
      ),
    );
  }

  // ==================== AYAH TAB ====================
  Widget _buildAyahTab() {
    final ayahs = [
      {
        'surah': 'Al-Baqarah',
        'verse': 'Verse 255',
        'date': 'Saved 2 days ago',
        'arabic': 'بِسْمِ اللّٰهِ الرَّحْمٰنِ الرَّحِيْمِ',
        'translation':
            'In the Name of Allah—the Most Compassionate, Most Merciful.',
      },
      {
        'surah': 'Al-Imran',
        'verse': 'Verse 19',
        'date': 'Saved 2 days ago',
        'arabic': 'إِنَّ الدِّينَ عِندَ اللّٰهِ',
        'translation': 'Indeed, the religion in the sight of Allah is Islam.',
      },
      {
        'surah': 'An-Nisa',
        'verse': 'Verse 36',
        'date': 'Saved 3 days ago',
        'arabic': 'وَاعْبُدُوا اللّٰهَ وَلَا تُشْرِكُوا بِهِ شَيْئًا',
        'translation':
            'And worship Allah and do not associate anything with Him.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Ayah",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildSearchBar(),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: ayahs.length,
            itemBuilder: (context, index) {
              return _buildAyahItem(ayahs[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAyahItem(Map<String, String> ayah) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ayah['surah']} • ${ayah['verse']}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    ayah['date']!,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E7D32),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Icon(Icons.bookmark, size: 14.sp, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Arabic text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              ayah['arabic']!,
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Amiri',
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 12.h),
          // Translation
          Text(
            ayah['translation']!,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== QURANIC STORIES TAB ====================
  Widget _buildQuranicStoriesTab() {
    final stories = [
      {
        'title': 'Story of Prophet Yusuf',
        'image':
            'https://images.unsplash.com/photo-1585036156171-384164a8c675?w=400',
      },
      {
        'title': 'The People of the Cave',
        'image':
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
      },
      {
        'title': 'Musa & Al-Khidr',
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      },
      {
        'title': 'The Story of Maryam',
        'image':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Quranic Stories",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildSearchBar(),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            itemCount: stories.length,
            itemBuilder: (context, index) {
              return _buildStoryCard(stories[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(Map<String, String> story) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(story['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Stack(
          children: [
            // Bookmark icon top right
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.bookmark,
                  size: 14.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Text(
                story['title']!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== AZKAR TAB ====================
  Widget _buildAzkarTab() {
    final azkar = [
      {
        'title': 'Morning Azkar',
        'time': '(5-10 min)',
        'image':
            'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
      },
      {
        'title': 'Evening Azkar',
        'time': '(5-10 min)',
        'image':
            'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
      },
      {
        'title': 'Before Sleeping Azkar',
        'time': '(3-5 min)',
        'image':
            'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400',
      },
      {
        'title': 'After Prayer Azkar',
        'time': '(5-7 min)',
        'image':
            'https://images.unsplash.com/photo-1585036156171-384164a8c675?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Azkar",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildSearchBar(),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
            ),
            itemCount: azkar.length,
            itemBuilder: (context, index) {
              return _buildAzkarCard(azkar[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAzkarCard(Map<String, String> azkar) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(azkar['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
          ),
        ),
        child: Stack(
          children: [
            // Bookmark icon top right
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.bookmark,
                  size: 14.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    azkar['title']!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    azkar['time']!,
                    style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== KNOWLEDGE TAB ====================
  Widget _buildKnowledgeTab() {
    final knowledge = [
      {
        'title': 'Masjid Quba is the first mosque in Islam.',
        'image':
            'https://images.unsplash.com/photo-1564769625905-50e93615e769?w=400',
      },
      {
        'title': "The Qur'an contains 114 chapters (surahs).",
        'image':
            'https://images.unsplash.com/photo-1609599006353-e629aaabfeae?w=400',
      },
      {
        'title': 'The Kaaba is located in Mecca.',
        'image':
            'https://images.unsplash.com/photo-1591604129939-f1efa4d9f7fa?w=400',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Saved Knowledge Informations",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12.h),
              _buildSearchBar(),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        Expanded(
          child: GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 0.85,
            ),
            itemCount: knowledge.length,
            itemBuilder: (context, index) {
              return _buildKnowledgeCard(knowledge[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildKnowledgeCard(Map<String, String> item) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        image: DecorationImage(
          image: NetworkImage(item['image']!),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
          ),
        ),
        child: Stack(
          children: [
            // Bookmark icon top right
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.bookmark,
                  size: 14.sp,
                  color: const Color(0xFF2E7D32),
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              left: 12.w,
              right: 12.w,
              bottom: 12.h,
              child: Text(
                item['title']!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== COMMON WIDGETS ====================
  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Search",
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            ),
          ),
          Icon(Icons.search, color: Colors.grey[400], size: 20.sp),
        ],
      ),
    );
  }
}
