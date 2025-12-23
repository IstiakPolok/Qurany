import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  final List<Map<String, String>> notes = [
    {
      'title': 'In the Name of Allah, the Most Compassionate, Most Merciful.',
      'date': 'Created Nov 15, 2025',
      'surah': 'Al-Fatiha',
      'verse': '120',
      'note':
          'This verse brings me so much comfort during difficult times. It reminds me that whatever challenge I face, Allah knows I have the strength to handle it. I should trust in His wisdom and my own resilience.',
    },
    {
      'title':
          'And We certainly created man and We know what his soul whispers to him, and We are closer to him than his jugular vein.',
      'date': 'Created Nov 16, 2025',
      'surah': 'Qaf',
      'verse': '16',
      'note':
          "This verse reassures me of Allah's intimacy with my thoughts and feelings. It encourages me to be honest with myself and seek His guidance in every aspect of life.",
    },
    {
      'title': 'Indeed, with hardship comes ease.',
      'date': 'Created Nov 17, 2025',
      'surah': 'Ash-Sharh',
      'verse': '5',
      'note':
          'This verse is a beacon of hope, reminding me that challenges are temporary and that relief will follow. It instills a sense of patience and perseverance within me.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            SizedBox(height: 16.h),

            // Notes List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  return _buildNoteCard(notes[index], index);
                },
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
                "Notes",
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          SizedBox(width: 40.w),
        ],
      ),
    );
  }

  Widget _buildNoteCard(Map<String, String> note, int index) {
    // Different accent colors for cards
    final colors = [
      const Color(0xFF2E7D32), // Green
      const Color(0xFFFF9800), // Orange
      const Color(0xFF2196F3), // Blue
    ];
    final accentColor = colors[index % colors.length];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: accentColor, width: 4.w),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              note['title']!,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
            SizedBox(height: 8.h),

            // Date and Surah info
            Text(
              '${note['date']} • ${note['surah']} : ${note['verse']}',
              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
            ),
            SizedBox(height: 12.h),

            // Note content
            Text(
              note['note']!,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),

            // Bottom row with button and actions
            Row(
              children: [
                // Read Ayah button
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Text(
                    "Read Ayah",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Spacer(),
                // Edit button
                GestureDetector(
                  onTap: () {
                    // Handle edit
                  },
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Delete button
                GestureDetector(
                  onTap: () => _showDeleteDialog(context),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Icon(
                      Icons.delete_outline,
                      size: 18.sp,
                      color: Colors.red[400],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Close button
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(
                    Icons.close,
                    size: 24.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Trash icon in hexagon-like shape
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFEBEE),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.delete_outline,
                  size: 32.sp,
                  color: Colors.red[400],
                ),
              ),

              SizedBox(height: 20.h),

              // Title
              Text(
                "Delete This Note?",
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 8.h),

              // Subtitle
              Text(
                "This action can't be undone. Do you want to continue?",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),

              SizedBox(height: 24.h),

              // Delete button
              GestureDetector(
                onTap: () {
                  // Handle delete
                  Navigator.pop(context);
                },
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                  child: Center(
                    child: Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              // Cancel button
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
