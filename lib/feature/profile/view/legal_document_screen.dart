import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String markdownContent;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.markdownContent,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Markdown(
          data: markdownContent,
          styleSheet: MarkdownStyleSheet(
            p: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.5),
            h1: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2,
            ),
            h2: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 2,
            ),
            listBullet: TextStyle(fontSize: 14.sp, color: Colors.black87),
          ),
          padding: EdgeInsets.all(20.w),
        ),
      ),
    );
  }
}
