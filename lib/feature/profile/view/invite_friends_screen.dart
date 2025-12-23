import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InviteFriendsScreen extends StatelessWidget {
  const InviteFriendsScreen({super.key});

  final String inviteCode = 'QURAN2025';
  final String inviteUrl = 'https://qurancompanion.app/invite/QURAN2025';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Green Header with background
            _buildHeader(context),

            // Personal Invite Code Card (overlapping header)
            _buildInviteCodeCard(context),

            SizedBox(height: 20.h),

            // Message Template
            _buildMessageTemplate(context),

            SizedBox(height: 24.h),

            // Referral Benefits
            _buildReferralBenefits(),

            SizedBox(height: 24.h),

            // How It Works
            _buildHowItWorks(),

            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/login_OptionBG.png'),
          fit: BoxFit.fitWidth,
          alignment: Alignment.topCenter,
        ),
      ),
      child: Column(
        children: [
          // App bar with back button
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new,
                      size: 16.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 4.h),

          // Title
          Text(
            "Invite your friends",
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),

          SizedBox(height: 8.h),

          // Subtitle
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: Text(
              "Share the gift of Quran and earn\nPremium rewards together",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.white.withOpacity(0.9),
                height: 1.4,
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // Stats cards
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatCard("12", "Friends Invited"),
              SizedBox(width: 12.w),
              _buildStatCard("4", "Months Earned"),
            ],
          ),

          SizedBox(height: 50.h),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviteCodeCard(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, -30.h),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              "Personal Invite Code",
              style: TextStyle(fontSize: 12.sp, color: const Color(0xFF2E7D32)),
            ),
            SizedBox(height: 8.h),
            Text(
              inviteCode,
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              inviteUrl,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Copy Link button
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: inviteUrl));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Link copied!')),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF2E7D32)),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.copy,
                          size: 16.sp,
                          color: const Color(0xFF2E7D32),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          "Copy Link",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                // Share button
                GestureDetector(
                  onTap: () {
                    // Handle share
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.share, size: 16.sp, color: Colors.white),
                        SizedBox(width: 6.w),
                        Text(
                          "Share",
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildMessageTemplate(BuildContext context) {
    const message = '''As-salamu alaykum! 🌙

I've been using Quran Companion to deepen my connection with the Quran, and it's been truly transformative. The app has beautiful features like AI-guided learning, prayer times, and peaceful recitations.

I thought you might benefit from it too. Join me on this blessed journey! 📖 ✨

Use my code: QURAN2025''';

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Message Template",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border(
                left: BorderSide(color: const Color(0xFF2E7D32), width: 4.w),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(const ClipboardData(text: message));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Message copied!')),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy, size: 18.sp, color: Colors.white),
                        SizedBox(width: 8.w),
                        Text(
                          "Copy Message",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
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
  }

  Widget _buildReferralBenefits() {
    final benefits = [
      {
        'icon': Icons.card_giftcard,
        'title': 'Earn Rewards',
        'description':
            'Get 1 month of Premium free for every 3 friends who join',
      },
      {
        'icon': Icons.people_outline,
        'title': 'Build Community',
        'description':
            'Help your loved ones strengthen their connection with the Quran',
      },
      {
        'icon': Icons.favorite_outline,
        'title': 'Spread Goodness',
        'description':
            'Share the reward of helping others on their spiritual journey',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Referral Benefits",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ...benefits.map(
            (benefit) => _buildBenefitCard(
              benefit['icon'] as IconData,
              benefit['title'] as String,
              benefit['description'] as String,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(IconData icon, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Hexagon-shaped icon container
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: const Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, size: 22.sp, color: Colors.white),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      {
        'number': '1',
        'title': 'Share your invite link',
        'description': 'Send your unique link to friends and family',
      },
      {
        'number': '2',
        'title': 'They sign up',
        'description':
            'Your friends download and create an account using your code',
      },
      {
        'number': '3',
        'title': 'Earn rewards together',
        'description': 'Both of you get Premium benefits as they use the app',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "How It Works",
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          ...steps.map(
            (step) => _buildStepItem(
              step['number']!,
              step['title']!,
              step['description']!,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepItem(String number, String title, String description) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28.w,
            height: 28.w,
            decoration: const BoxDecoration(
              color: Color(0xFF2E7D32),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
