import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/core/const/app_colors.dart';
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
  final int _pageSize = 114;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchSurahs();
    _fetchJuz();
  }

  Future<void> _fetchJuz() async {
    try {
      setState(() {
        _isLoadingJuz = true;
      });
      final juzList = await _quranService.fetchJuz();
      setState(() {
        _allJuz = juzList;
        _filteredJuz = juzList;
        _isLoadingJuz = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingJuz = false;
        });
      }
    }
  }

  Future<void> _fetchSurahs({int? page}) async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        if (page != null) {
          _currentPage = page;
        }
      });
      final response = await _quranService.fetchSurahs(
        page: _currentPage,
        limit: _pageSize,
      );
      setState(() {
        _allSurahs = response.surahs;
        _filteredSurahs = response.surahs;
        _totalItems = response.total;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredSurahs = _allSurahs.where((surah) {
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

  Widget _buildPagination() {
    int totalPages = (_totalItems / _pageSize).ceil();
    if (totalPages <= 1) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Previous Button
          if (_currentPage > 1)
            GestureDetector(
              onTap: () => _fetchSurahs(page: _currentPage - 1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.all(color: primaryColor),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.chevron_left, color: primaryColor, size: 16.sp),
                    SizedBox(width: 4.w),
                    Text(
                      "Previous",
                      style: TextStyle(color: primaryColor, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),

          SizedBox(width: 12.w),

          // Page Numbers
          ...List.generate(totalPages, (index) {
            int pageNum = index + 1;

            // Show first page, last page, current page and adjacent pages
            if (pageNum == 1 ||
                pageNum == totalPages ||
                (pageNum >= _currentPage - 1 && pageNum <= _currentPage + 1)) {
              return GestureDetector(
                onTap: () => _fetchSurahs(page: pageNum),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: pageNum == _currentPage
                        ? primaryColor
                        : Colors.transparent,
                    border: Border.all(color: primaryColor, width: 1.5),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    "$pageNum",
                    style: TextStyle(
                      color: pageNum == _currentPage
                          ? Colors.white
                          : primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.sp,
                    ),
                  ),
                ),
              );
            } else if (pageNum == _currentPage - 2 ||
                pageNum == _currentPage + 2) {
              // Show ellipsis
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Text(
                  "...",
                  style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          SizedBox(width: 12.w),

          // Next Button
          if (_currentPage < totalPages)
            GestureDetector(
              onTap: () => _fetchSurahs(page: _currentPage + 1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Text(
                      "Next",
                      style: TextStyle(color: Colors.white, fontSize: 12.sp),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.chevron_right, color: Colors.white, size: 16.sp),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

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
                          SizedBox(height: 16.h),
                          _buildPagination(),
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
                                  "0 / 286 Aya", // Placeholder for actual progress
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
