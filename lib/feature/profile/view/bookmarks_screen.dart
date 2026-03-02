import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../quran/view/quran_screen.dart';
import '../../home/model/surah_model.dart';
import '../../home/controller/azkar_controller.dart';
import '../../home/model/azkar_model.dart';
import '../../home/view/azkar_detail_screen.dart';
import '../../quran/model/bookmarked_verse_model.dart';

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

    // Initialize QuranController if not already registered and fetch data
    if (!Get.isRegistered<QuranController>()) {
      Get.put(QuranController());
    }
    final QuranController controller = Get.find<QuranController>();
    controller.fetchFavoriteSurahs(forceRefresh: true);
    controller.fetchBookmarkedVerses(forceRefresh: true);

    if (!Get.isRegistered<AzkarController>()) {
      Get.put(AzkarController());
    } else {
      final AzkarController azkarController = Get.find<AzkarController>();
      azkarController.fetchAllAzkar();
      azkarController.fetchBookmarkedAzkarGroups();
    }
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
    final QuranController controller = Get.find<QuranController>();

    return Obx(() {
      final favSurahs = controller.filteredFavoriteSurahs;
      final isLoadingSurahs = controller.isLoadingFavorites.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bookmarked Surah",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildSearchBar(controller),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: isLoadingSurahs
                ? const Center(child: CircularProgressIndicator())
                : favSurahs.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text("No bookmarked surahs found"),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: favSurahs.length,
                    itemBuilder: (context, index) {
                      final surah = favSurahs[index];
                      return _buildSurahItem(surah, controller);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildSurahItem(SurahModel surah, QuranController controller) {
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
            child: Center(
              child: Text(
                surah.number.toString(),
                style: TextStyle(
                  color: const Color(0xFF2E7D32),
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          // Surah info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  surah.englishName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${surah.revelationType} • ${surah.totalVerses} VERSES',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          // Arabic name
          Text(
            surah.arabicName,
            style: TextStyle(fontSize: 18.sp, fontFamily: 'Arial'),
          ),
          SizedBox(width: 8.w),
          // Remove bookmark button
          GestureDetector(
            onTap: () {
              Get.dialog(
                AlertDialog(
                  title: const Text("Remove Bookmark"),
                  content: Text(
                    "Are you sure you want to remove ${surah.englishName} from your bookmarks?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Get.back();
                        controller.removeFavoriteSurah(surah.number);
                      },
                      child: const Text(
                        "Remove",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: Icon(
              Icons.bookmark,
              color: const Color(0xFF2E7D32),
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== AYAH TAB ====================
  Widget _buildAyahTab() {
    final QuranController controller = Get.find<QuranController>();

    return Obx(() {
      final favVerses = controller.filteredBookmarkedVerses;
      final isLoadingVerses = controller.isLoadingBookmarkedVerses.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bookmarked Ayah",
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildSearchBar(controller),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: isLoadingVerses
                ? const Center(child: CircularProgressIndicator())
                : favVerses.isEmpty
                ? Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.h),
                      child: Text("No bookmarked verses found"),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: favVerses.length,
                    itemBuilder: (context, index) {
                      return _buildAyahItem(favVerses[index], controller);
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildAyahItem(
    BookmarkedVerseModel verse,
    QuranController controller,
  ) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${verse.name} • Verse ${verse.verseId}",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      controller.getFormattedSavedDate(verse.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => controller.removeBookmarkedVerse(
                  verse.surahId,
                  verse.verseId,
                  verse.name,
                ),
                child: Icon(
                  Icons.bookmark,
                  color: const Color(0xFF2E7D32),
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          // Arabic text
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              verse.text,
              style: TextStyle(
                fontSize: 20.sp,
                fontFamily: 'Arial',
                height: 1.8,
              ),
              textAlign: TextAlign.right,
            ),
          ),
          SizedBox(height: 12.h),
          // Translation
          Text(
            verse.translation,
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
    final AzkarController controller = Get.find<AzkarController>();

    return Obx(() {
      final isLoading =
          controller.isLoading.value || controller.isLoadingBookmarks.value;
      final bookmarkedIds = controller.bookmarkedAzkarGroupIds;
      final bookmarkedAzkar = controller.allAzkar
          .where((g) => bookmarkedIds.contains(g.id))
          .toList();

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
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : bookmarkedAzkar.isEmpty
                ? const Center(child: Text('No bookmarked azkar found'))
                : GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: bookmarkedAzkar.length,
                    itemBuilder: (context, index) {
                      return _buildAzkarCard(
                        context,
                        bookmarkedAzkar[index],
                        controller,
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }

  Widget _buildAzkarCard(
    BuildContext context,
    AzkarGroupModel azkar,
    AzkarController controller,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AzkarDetailScreen(
              categoryData: {
                'title': azkar.name,
                'time': azkar.time,
                'duration': azkar.duration,
                'image': azkar.image ?? '',
              },
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            children: [
              if ((azkar.image ?? '').isNotEmpty)
                Image.network(
                  azkar.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(color: Colors.grey[300]);
                  },
                )
              else
                Container(color: Colors.grey[300]),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                  ),
                ),
              ),
              // Bookmark icon top right
              Positioned(
                top: 8.h,
                right: 8.w,
                child: GestureDetector(
                  onTap: () => controller.bookmarkAzkarGroup(azkar.id),
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
                      azkar.name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '(${azkar.duration})',
                      style: TextStyle(fontSize: 10.sp, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
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
  Widget _buildSearchBar(QuranController controller) {
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
            child: TextField(
              controller: controller.searchTextController,
              decoration: InputDecoration(
                hintText: "Search",
                hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Icon(Icons.search, color: Colors.grey[400], size: 20.sp),
        ],
      ),
    );
  }
}
