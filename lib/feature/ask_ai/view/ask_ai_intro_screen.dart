import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// Controller for Ask AI screen
class AskAIController extends GetxController {
  RxBool showChat = false.obs;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();

  void startChat() {
    showChat.value = true;
  }

  void goBack() {
    if (messages.isEmpty) {
      showChat.value = false;
    } else {
      Get.back();
    }
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty) {
      messages.add({'text': messageController.text, 'isUser': true});
      // Simulate AI response
      messages.add({
        'text':
            "Jazak Allah Khair for your question! I'm here to help guide you through Islamic teachings.",
        'isUser': false,
      });
      messageController.clear();
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

class AskAIScreen extends StatelessWidget {
  const AskAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, child) {
        final AskAIController controller = Get.put(AskAIController());
        return Obx(
          () => controller.showChat.value
              ? _buildChatView(context, controller)
              : _buildIntroView(context, controller),
        );
      },
    );
  }

  Widget _buildIntroView(BuildContext context, AskAIController controller) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/GardenNight2.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF2E7D32).withOpacity(0.8),
                    const Color(0xFF1B5E20).withOpacity(0.85),
                  ],
                ),
              ),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: IntrinsicHeight(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 24.w),
                            child: Column(
                              children: [
                                // Star Icon
                                Center(
                                  child: Image.asset(
                                    "assets/icons/chatscreenstar.png",
                                    width: 180.w,
                                    height: 180.w,
                                    fit: BoxFit.contain,
                                  ),
                                ),

                                // Title
                                Text(
                                  "Meet Your AI Companion",
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 10.h),

                                // Description
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.6,
                                    ),
                                    children: [
                                      const TextSpan(text: "Discover "),
                                      TextSpan(
                                        text: "AI Companion",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const TextSpan(
                                        text:
                                            ": Your personal spiritual guide powered by advanced AI and nurtured from the wisdom of the Holy Quran, authentic Hadith collections, and trusted Islamic scholarship on Qurany.",
                                      ),
                                    ],
                                  ),
                                ),

                                SizedBox(height: 20.h),

                                // Divider
                                Container(
                                  width: double.infinity,
                                  height: 1,
                                  color: Colors.white.withOpacity(0.3),
                                ),

                                SizedBox(height: 24.h),

                                // Free questions text
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "✨ ",
                                      style: TextStyle(fontSize: 16.sp),
                                    ),
                                    Flexible(
                                      child: Text(
                                        "Start with 5 free questions daily!",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 20.h),

                                // Feature Icons Row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: _buildFeatureItem(
                                        imagePath: "assets/icons/💬.png",
                                        label: "Explore Together",
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        imagePath: "assets/icons/📖.png",
                                        label: "Verse Guidance",
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        label: "Reflection",
                                        imagePath: "assets/icons/🌙.png",
                                      ),
                                    ),
                                  ],
                                ),

                                const Spacer(),
                                SizedBox(height: 20.h),

                                // Start Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () => controller.startChat(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF2E7D32),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 18.h,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      "Bismillah, Let's Start",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 40.h),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatView(BuildContext context, AskAIController controller) {
    return Scaffold(
      backgroundColor: Color(0xFFFFFDF6),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        "assets/icons/chattopicon.png",
                        width: 32.sp,
                        height: 32.sp,
                      ),
                      SizedBox(width: 8.w),
                      Flexible(
                        child: Text(
                          "Your Reflection Companion",
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF4CAF50),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Content area
            Expanded(
              child: Obx(
                () => controller.messages.isEmpty
                    ? _buildQuickActionsView(controller)
                    : _buildMessagesView(controller),
              ),
            ),

            // Input area
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: const BoxDecoration(
                color: Color(0xffFFFDF6),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Input Field
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: controller.messageController,
                            decoration: InputDecoration(
                              hintText: "Share your thoughts or ask...",
                              hintStyle: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14.sp,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16.h,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.mic_outlined,
                          color: Colors.grey[600],
                          size: 24.sp,
                        ),
                        SizedBox(width: 12.w),
                        GestureDetector(
                          onTap: () => controller.sendMessage(),
                          child: Container(
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.send,
                              color: const Color(0xFF2E7D32),
                              size: 20.sp,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Bottom Action Chips
                  Row(
                    children: [
                      _buildBottomChip(
                        imagePath: "assets/icons/💬.png",
                        label: "Explore Together",
                        onTap: () =>
                            _sendQuickAction(controller, "Explore Together"),
                      ),
                      SizedBox(width: 8.w),
                      _buildBottomChip(
                        imagePath: "assets/icons/📖.png",
                        label: "Verse Guidance",
                        onTap: () =>
                            _sendQuickAction(controller, "Verse Guidance"),
                      ),
                      SizedBox(width: 8.w),
                      _buildBottomChip(
                        imagePath: "assets/icons/🌙.png",
                        label: "Reflection",
                        onTap: () => _sendQuickAction(controller, "Reflection"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomChip({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: const Color(0xFF2E7D32),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(imagePath, width: 14.sp, height: 14.sp),
              SizedBox(width: 4.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionsView(AskAIController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // How can I guide you
          Center(
            child: Text(
              "How can I guide you today?",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Quick action cards - 2x2 grid
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick1.png",
                  label: "Learn about this Surah",
                  onTap: () =>
                      _sendQuickAction(controller, "Tell me about this Surah"),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick2.png",
                  label: "Explain this verse",
                  onTap: () =>
                      _sendQuickAction(controller, "Explain this verse"),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick3.png",
                  label: "Share a reflection",
                  onTap: () => _sendQuickAction(
                    controller,
                    "I want to share a reflection",
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick4.png",
                  label: "Discover Background & history",
                  onTap: () => _sendQuickAction(
                    controller,
                    "Tell me about the background and history",
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // Companion welcome message
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                "assets/icons/chattopicon.png",
                width: 40.sp,
                height: 40.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          "Companion",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "05:29",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "Assalamu-alaikum, dear friend 🌙\nI'm your AI companion for Quranic guidance.\nHow can I help you today?",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard({
    required String imagePath,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 140.h,
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(imagePath, width: 44.sp, height: 44.sp),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _sendQuickAction(AskAIController controller, String message) {
    controller.messageController.text = message;
    controller.sendMessage();
  }

  Widget _buildMessagesView(AskAIController controller) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.messages.length,
      itemBuilder: (context, index) {
        final message = controller.messages[index];
        final bool isCompanion = !message['isUser'];

        if (isCompanion) {
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        "assets/icons/chattopicon.png",
                        width: 40.sp,
                        height: 40.sp,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "Companion",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        "05:29",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    message['text'],
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Icon(
                        Icons.copy_outlined,
                        size: 18.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 16.w),
                      Icon(
                        Icons.share_outlined,
                        size: 18.sp,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        } else {
          // User Message
          return Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Align(
              alignment: Alignment.centerRight,
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "EJ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Emily John",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "05:29",
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      message['text'],
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildFeatureItem({required String imagePath, required String label}) {
    return Column(
      children: [
        ClipOval(
          child: Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Image.asset(imagePath, width: 28.w, height: 28.w),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        constraints: BoxConstraints(maxWidth: 280.w),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
