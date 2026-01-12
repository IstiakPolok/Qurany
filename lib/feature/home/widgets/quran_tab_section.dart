import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qurany/core/const/app_colors.dart';
import 'package:qurany/feature/home/model/surah_model.dart';
// import 'package:flutter_svg/flutter_svg.dart'; // Removed as not used and caused error

class QuranTabSection extends StatefulWidget {
  const QuranTabSection({super.key});

  @override
  State<QuranTabSection> createState() => _QuranTabSectionState();
}

class _QuranTabSectionState extends State<QuranTabSection> {
  final TextEditingController _searchController = TextEditingController();
  List<SurahModel> _filteredSurahs = SurahModel.sampleSurahs;
  String _selectedTab = "Surah";

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
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
      _filteredSurahs = SurahModel.sampleSurahs.where((surah) {
        final matchesName =
            surah.englishName.toLowerCase().contains(query) ||
            surah.arabicName.contains(query);
        // Can add Juzz logic here if Juzz data exists.
        // For now, if "Juzz" tab is selected, we might want to show different data,
        // but based on "data from list" request and current model, we will stick to Surah search.
        return matchesName;
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
              ? (_filteredSurahs.isEmpty
                    ? Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text("No Surahs found"),
                        ),
                      )
                    : ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _filteredSurahs.length,
                        separatorBuilder: (_, __) => SizedBox(height: 8.h),
                        itemBuilder: (context, index) {
                          return _buildSurahItem(_filteredSurahs[index]);
                        },
                      ))
              : ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: JuzModel.sampleJuz.length,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    return _buildJuzItem(JuzModel.sampleJuz[index]);
                  },
                ),
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
              return Padding(
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
                            fontFamily: 'Amiri',
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          surah.versesRange,
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
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
    return Container(
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
                  fontFamily: 'Amiri', // Ensure font covers Arabic
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
