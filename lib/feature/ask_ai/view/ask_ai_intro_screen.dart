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
    final AskAIController controller = Get.put(AskAIController());

    return Obx(
      () => controller.showChat.value
          ? _buildChatView(context, controller)
          : _buildIntroView(context, controller),
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
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF2E7D32).withOpacity(0.85),
                const Color(0xFF1B5E20).withOpacity(0.9),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),

                  // Star Icon
                  Container(
                    width: 100.w,
                    height: 100.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E7D32),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.star,
                        size: 50.sp,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),

                  // Title
                  Text(
                    "Meet Your AI Companion",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 20.h),

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

                  SizedBox(height: 32.h),

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
                      Text("✨ ", style: TextStyle(fontSize: 16.sp)),
                      Text(
                        "Start with 5 free questions daily!",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 32.h),

                  // Feature Icons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildFeatureItem(
                        icon: Icons.chat_bubble_outline,
                        label: "Explore Together",
                        bgColor: const Color(0xFF1B5E20),
                      ),
                      _buildFeatureItem(
                        icon: Icons.menu_book_outlined,
                        label: "Verse Guidance",
                        bgColor: Colors.white.withOpacity(0.2),
                      ),
                      _buildFeatureItem(
                        icon: Icons.nightlight_round,
                        label: "Reflection",
                        bgColor: const Color(0xFFFFB74D),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => controller.startChat(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2E7D32),
                        padding: EdgeInsets.symmetric(vertical: 18.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.r),
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
      ),
    );
  }

  Widget _buildChatView(BuildContext context, AskAIController controller) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
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
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2E7D32),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.star,
                          size: 18.sp,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        "Your Reflection Companion",
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        "Online",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0xFF4CAF50),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Info Banner
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8E8E8),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18.sp,
                    color: Colors.grey[600],
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      "AI responses are for educational purposes.\nPlease consult scholars for Islamic rulings.",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20.h),

            // Content area
            Expanded(
              child: Obx(
                () => controller.messages.isEmpty
                    ? _buildQuickActionsView(controller)
                    : _buildMessagesView(controller),
              ),
            ),

            // Current verse indicator
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 20.sp,
                    color: const Color(0xFF2E7D32),
                  ),
                  SizedBox(width: 10.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Ask about current verse",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        "Surah Al-Fatihah, Verse 1",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF2E7D32),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Input area
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: controller.messageController,
                              decoration: InputDecoration(
                                hintText: "Share your thoughts or ask...",
                                hintStyle: TextStyle(
                                  color: Colors.grey[500],
                                  fontSize: 14.sp,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 10.h,
                                ),
                              ),
                            ),
                          ),
                          Icon(
                            Icons.mic_none,
                            color: Colors.grey[500],
                            size: 22.sp,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  GestureDetector(
                    onTap: () => controller.sendMessage(),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.send, color: Colors.white, size: 20.sp),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
                  icon: Icons.menu_book_outlined,
                  label: "Learn about this Surah",
                  onTap: () =>
                      _sendQuickAction(controller, "Tell me about this Surah"),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.lightbulb_outline,
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
                  icon: Icons.favorite_outline,
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
                  icon: Icons.history,
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
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF2E7D32),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 14.sp,
                  color: const Color(0xFFFFD54F),
                ),
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
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: Colors.white, size: 22.sp),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
        return _buildMessageBubble(message['text'], message['isUser']);
      },
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String label,
    required Color bgColor,
  }) {
    return Column(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 28.sp),
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
