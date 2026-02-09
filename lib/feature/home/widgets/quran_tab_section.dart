import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/core/const/static_surah_data.dart';
import 'package:qurany/core/const/static_juz_data.dart';
import 'package:qurany/feature/home/model/surah_model.dart';
import 'package:qurany/feature/home/services/quran_service.dart';
import 'package:qurany/feature/quran/view/surah_reading_screen.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Removed as not used and caused error

class QuranTabSection extends StatefulWidget {
  const QuranTabSection({super.key});

  @override
  State<QuranTabSection> createState() => _QuranTabSectionState();
}

class _QuranTabSectionState extends State<QuranTabSection> {
  final TextEditingController _searchController = TextEditingController();
  final QuranService _quranService = QuranService();
  List<SurahModel> _allSurahs = [];
  List<SurahModel> _filteredSurahs = [];
  List<JuzModel> _allJuz = [];
  List<JuzModel> _filteredJuz = [];
  bool _isLoading = true;
  bool _isLoadingJuz = false;
  String? _errorMessage;
  String _selectedTab = "Surah";

  // Pagination state
  int _currentPage = 1;
  int _totalItems = 114;
  final int _pageSize = 10;

  Map<int, int> _progressMap = {};
  bool _hasMoreSurahs = true;
  bool _isLoadingMore = false;
  ScrollPosition? _scrollPosition;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _initData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeScrollListener();
    _addScrollListener();
  }

  void _addScrollListener() {
    try {
      final scrollable = Scrollable.of(context);
      _scrollPosition = scrollable.position;
      _scrollPosition?.addListener(_scrollListener);
    } catch (e) {
      print("Error adding scroll listener: $e");
    }
  }

  void _removeScrollListener() {
    try {
      _scrollPosition?.removeListener(_scrollListener);
    } catch (e) {
      // Ignore errors during disposal
    }
  }

  void _scrollListener() {
    if (_selectedTab == "Surah" &&
        !_isLoading &&
        !_isLoadingMore &&
        _hasMoreSurahs &&
        _searchController.text.isEmpty &&
        _scrollPosition != null) {
      if (_scrollPosition!.pixels >= _scrollPosition!.maxScrollExtent - 200) {
        _loadMoreSurahs();
      }
    }
  }

  Future<void> _initData() async {
    try {
      setState(() => _isLoading = true);

      // Fetch progress once
      _progressMap = await _quranService.fetchSurahProgress();

      await _fetchJuz();
      await _fetchInitialSurahs();
    } catch (e) {
      print("Error initializing data: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchInitialSurahs() async {
    _currentPage = 1;
    _filteredSurahs = [];
    await _loadMoreSurahs();
  }

  Future<void> _loadMoreSurahs() async {
    if (_isLoadingMore) return;

    try {
      setState(() => _isLoadingMore = true);

      // Simulate network delay if needed
      await Future.delayed(const Duration(milliseconds: 300));

      final allSurahs = StaticSurahData.getAllSurahs();
      final totalSurahs = allSurahs.length;
      final startIndex = (_currentPage - 1) * _pageSize;

      if (startIndex >= totalSurahs) {
        setState(() {
          _hasMoreSurahs = false;
          _isLoadingMore = false;
        });
        return;
      }

      final endIndex = startIndex + _pageSize;
      final nextBatch = allSurahs.sublist(
        startIndex,
        endIndex > totalSurahs ? totalSurahs : endIndex,
      );

      final processedBatch = nextBatch.map((surah) {
        if (_progressMap.containsKey(surah.number)) {
          return surah.copyWith(revealedVerses: _progressMap[surah.number]);
        }
        return surah;
      }).toList();

      setState(() {
        _filteredSurahs.addAll(processedBatch);
        _currentPage++;
        _isLoadingMore = false;
        _hasMoreSurahs = endIndex < totalSurahs;
      });
    } catch (e) {
      setState(() => _isLoadingMore = false);
      print("Error loading more surahs: $e");
    }
  }

  Future<void> _fetchJuz() async {
    try {
      setState(() => _isLoadingJuz = true);

      final juzList = StaticJuzData.getAllJuz().map((juz) {
        final updatedSurahs = juz.surahs.map((surah) {
          if (_progressMap.containsKey(surah.number)) {
            return surah.copyWith(revealedVerses: _progressMap[surah.number]);
          }
          return surah;
        }).toList();

        return JuzModel(number: juz.number, surahs: updatedSurahs);
      }).toList();

      setState(() {
        _allJuz = juzList;
        _filteredJuz = juzList;
        _isLoadingJuz = false;
      });
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoadingJuz = false);
    }
  }

  @override
  void dispose() {
    _removeScrollListener();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  // Old methods replaced by initData and scroll listener logic
  // Keeping _fetchSurahs only if referenced elsewhere, but better to remove or act as stub
  Future<void> _fetchSurahs({int? page}) async {
    // Legacy support or reset
    if (page == 1) _fetchInitialSurahs();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      // Reset to infinite scroll list
      _fetchInitialSurahs();
      _filteredJuz = _allJuz;
      setState(() {});
      return;
    }

    // When searching, we search across ALL surahs, bypassing pagination for results
    final allSurahsWithProgress = StaticSurahData.getAllSurahs().map((surah) {
      if (_progressMap.containsKey(surah.number)) {
        return surah.copyWith(revealedVerses: _progressMap[surah.number]);
      }
      return surah;
    }).toList();

    setState(() {
      _filteredSurahs = allSurahsWithProgress.where((surah) {
        final matchesName =
            surah.englishName.toLowerCase().contains(query) ||
            surah.arabicName.contains(query);
        return matchesName;
      }).toList();

      // Filter Juz based on surah names within them
      _filteredJuz = _allJuz.where((juz) {
        return juz.surahs.any(
          (surah) =>
              surah.englishName.toLowerCase().contains(query) ||
              surah.arabicName.contains(query),
        );
      }).toList();
    });
  }

  void _onTabSelected(String tab) {
    setState(() {
      _selectedTab = tab;
      // In a real app, you might switch the data source or filter logic here.
      // For this task, we will just keep the visual toggle.
    });
  }

  // Widget _buildPagination() {
  //   // Removed for infinite scroll implementation
  //   return const SizedBox.shrink();
  // }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Quran",
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Text(
                "View all",
                style: TextStyle(fontSize: 12.sp, color: Colors.green),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search",
              hintStyle: TextStyle(color: subheading, fontSize: 14.sp),

              suffixIcon: const Icon(Icons.search, color: Colors.grey),
              contentPadding: EdgeInsets.symmetric(
                vertical: 0,
                horizontal: 16.w,
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: subheading),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: subheading),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: primaryColor, width: 1.5),
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Tabs
          Row(
            children: [
              _buildTab("Surah", _selectedTab == "Surah"),
              SizedBox(width: 8.w),
              _buildTab("Juzz", _selectedTab == "Juzz"),
            ],
          ),
          SizedBox(height: 16.h),

          // List
          _selectedTab == "Surah"
              ? (_isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _errorMessage != null
                    ? Center(
                        child: Column(
                          children: [
                            const Text("Failed to load surahs"),
                            TextButton(
                              onPressed: _fetchSurahs,
                              child: const Text("Retry"),
                            ),
                          ],
                        ),
                      )
                    : _filteredSurahs.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No Surahs found"),
                        ),
                      )
                    : Column(
                        children: [
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: _filteredSurahs.length,
                            separatorBuilder: (_, __) => SizedBox(height: 8.h),
                            itemBuilder: (context, index) {
                              return _buildSurahItem(_filteredSurahs[index]);
                            },
                          ),
                          if (_isLoadingMore)
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.h),
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          SizedBox(height: 16.h),
                          // _buildPagination(), // Removed in favor of infinite scroll
                        ],
                      ))
              : (_isLoadingJuz
                    ? const Center(child: CircularProgressIndicator())
                    : _filteredJuz.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No Juz found"),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _filteredJuz.length,
                        separatorBuilder: (_, __) => SizedBox(height: 16.h),
                        itemBuilder: (context, index) {
                          return _buildJuzItem(_filteredJuz[index]);
                        },
                      )),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildJuzItem(JuzModel juz) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Juz ${juz.number}",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            GestureDetector(
              onTap: () {},
              child: Text(
                "Read Juz",
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9F0),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: juz.surahs.map((surah) {
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => SurahReadingScreen(
                      surahId: surah.number,
                      surahName: surah.englishName,
                      arabicName: surah.arabicName,
                      translation: surah.translation,
                      origin: surah.revelationType,
                      ayaCount: surah.totalVerses,
                      meaning: surah.translation,
                    ),
                  );
                },
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: juz.surahs.last == surah ? 0 : 12.h,
                  ),
                  child: Row(
                    children: [
                      _buildStarNumber(surah.number),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.englishName,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              surah.revelationType,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              children: [
                                Icon(
                                  Icons.done_all,
                                  size: 12.sp,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  "${surah.revealedVerses} / ${surah.totalVerses} Aya",
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            surah.arabicName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Arial',
                              color: primaryColor,
                            ),
                          ),
                          Text(
                            surah.versesRange,
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildStarNumber(int number) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Transform.rotate(
          angle: 45 * 3.1415926535 / 180,
          child: Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              border: Border.all(color: primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
        ),
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            border: Border.all(color: primaryColor, width: 1.5),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        Text(
          "$number",
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () => _onTabSelected(title),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildSurahItem(SurahModel surah) {
    return GestureDetector(
      onTap: () {
        Get.to(
          () => SurahReadingScreen(
            surahId: surah.number,
            surahName: surah.englishName,
            arabicName: surah.arabicName,
            translation: surah.translation,
            origin: surah.revelationType,
            ayaCount: surah.totalVerses,
            meaning: surah.englishName,
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: 45 * 3.1415926535 / 180,
                  child: Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: primaryColor, width: 1.5),
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),
                ),
                Container(
                  width: 32.w,
                  height: 32.w,
                  decoration: BoxDecoration(
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
                Text(
                  "${surah.number}",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Text(
                        surah.revelationType.toUpperCase(),
                        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                      ),
                      SizedBox(width: 4.w),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.done_all, size: 14.sp, color: Colors.green),
                      SizedBox(width: 4.w),
                      Text(
                        "${surah.revealedVerses} / ${surah.totalVerses} Aya",
                        style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  surah.arabicName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    fontFamily: 'Arial', // Ensure font covers Arabic
                    color: primaryColor,
                  ),
                ),
                Text(
                  "${surah.totalVerses} VERSES",
                  style: TextStyle(color: Colors.grey, fontSize: 10.sp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

extension Verify on Widget {
  // Helper just to keep the logic clean in the builder if needed, or remove.
  // Cleaning up the _buildSurahItem to match image exactly:
  // Left: Star with Number.
  // Middle: English Name, then "MECCAN", then Green Check + "0 / X Aya".
  // Right: Arabic Name, then "X VERSES".
  bool networkVerify(bool val) => val;
}
