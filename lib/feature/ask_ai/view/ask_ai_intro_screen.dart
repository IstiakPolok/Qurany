import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/ask_ai/services/ask_ai_service.dart';
import 'package:qurany/core/services_class/local_service/shared_preferences_helper.dart';
import 'package:qurany/feature/profile/controller/profile_controller.dart';
import 'package:qurany/feature/profile/services/profile_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:share_plus/share_plus.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';

// Controller for Ask AI screen
class AskAIController extends GetxController {
  RxBool showChat = false.obs;
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AskAiService _askAiService = AskAiService();
  final ProfileService _profileService = ProfileService();
  RxBool isLoading = false.obs;
  RxString userName = "ai_user_default".tr.obs;

  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  RxBool isListening = false.obs;
  RxBool isSpeaking = false.obs;
  RxBool isSpeechAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _initSpeech();
    _initTts();
  }

  Future<void> _initSpeech() async {
    try {
      var status = await Permission.microphone.status;
      if (!status.isGranted) {
        await Permission.microphone.request();
      }

      isSpeechAvailable.value = await _speech.initialize(
        onStatus: (status) {
          if (status == 'listening') {
            isListening.value = true;
          } else if (status == 'notListening') {
            isListening.value = false;
          }
        },
        onError: (errorNotification) {
          isListening.value = false;
          print("Speech Error: ${errorNotification.errorMsg}");
        },
      );
    } catch (e) {
      print("Speech initialization error: $e");
    }
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      isSpeaking.value = false;
    });
  }

  void toggleListening() async {
    if (!isSpeechAvailable.value) {
      await _initSpeech();
      if (!isSpeechAvailable.value) return;
    }

    if (isListening.value) {
      _speech.stop();
      isListening.value = false;
    } else {
      await _speech.listen(
        onResult: (result) {
          messageController.text = result.recognizedWords;
          if (result.finalResult) {
            isListening.value = false;
          }
        },
      );
    }
  }

  Future<void> speak(String text) async {
    if (isSpeaking.value) {
      await _flutterTts.stop();
      isSpeaking.value = false;
    } else {
      isSpeaking.value = true;
      await _flutterTts.speak(text);
    }
  }

  void stopSpeaking() async {
    await _flutterTts.stop();
    isSpeaking.value = false;
  }

  Future<void> _loadUserName() async {
    final cachedName = await SharedPreferencesHelper.getName();
    if (cachedName.trim().isNotEmpty) {
      userName.value = cachedName.trim();
    }

    String? dynamicName;

    if (Get.isRegistered<ProfileController>()) {
      final profileController = Get.find<ProfileController>();
      dynamicName = profileController.user.value?.fullName;
      if ((dynamicName == null || dynamicName.trim().isEmpty) &&
          !profileController.isLoading.value) {
        await profileController.fetchProfile();
        dynamicName = profileController.user.value?.fullName;
      }
    }

    if (dynamicName == null || dynamicName.trim().isEmpty) {
      final profile = await _profileService.getProfile();
      dynamicName = profile?.fullName;
    }

    if (dynamicName != null && dynamicName.trim().isNotEmpty) {
      userName.value = dynamicName.trim();
      await SharedPreferencesHelper.saveName(userName.value);
    }
  }

  void startChat() {
    showChat.value = true;
    scrollToBottom();
  }

  void goBack() {
    if (messages.isEmpty) {
      showChat.value = false;
    } else {
      Get.back();
    }
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendMessage() async {
    if (messageController.text.isNotEmpty && !isLoading.value) {
      String userQuery = messageController.text;
      String time = DateFormat('hh:mm a').format(DateTime.now());
      messages.add({'text': userQuery, 'isUser': true, 'time': time});
      messageController.clear();
      scrollToBottom();

      isLoading.value = true;

      final response = await _askAiService.sendMessage(userQuery);

      isLoading.value = false;

      if (response != null && response['success'] == true) {
        String aiResponse = response['data']['response'];
        messages.add({
          'text': aiResponse,
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now()),
        });
      } else {
        messages.add({
          'text': "ai_error_msg".tr,
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now()),
        });
      }
      scrollToBottom();
    }
  }

  Future<void> copyToClipboard(String text) async {
    if (text.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: text));
      Get.snackbar(
        'success'.tr,
        'ai_copy_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF2E7D32),
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> shareMessage(String text) async {
    if (text.isNotEmpty) {
      String shareText = "$text\n\n${'ai_share_footer'.tr}";
      await Share.share(shareText);
    }
  }

  @override
  void onClose() {
    stopSpeaking();
    messageController.dispose();
    scrollController.dispose();
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
                                  "ai_intro_title".tr,
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
                                      TextSpan(text: "ai_intro_desc_1".tr),
                                      TextSpan(
                                        text: "ai_intro_desc_2".tr,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(text: "ai_intro_desc_3".tr),
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
                                        "ai_free_questions_msg".tr,
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
                                        label: "ai_feature_explore".tr,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        imagePath: "assets/icons/📖.png",
                                        label: "ai_feature_guidance".tr,
                                      ),
                                    ),
                                    Expanded(
                                      child: _buildFeatureItem(
                                        label: "ai_feature_reflection".tr,
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
                                      "ai_start_button".tr,
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
                          "ai_chat_title".tr,
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
                        "ai_online_status".tr,
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
                              hintText: "ai_input_hint".tr,
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
                        Obx(
                          () => GestureDetector(
                            onTap: () => controller.toggleListening(),
                            child: Icon(
                              controller.isListening.value
                                  ? Icons.mic
                                  : Icons.mic_outlined,
                              color: controller.isListening.value
                                  ? Colors.redAccent
                                  : Colors.grey[600],
                              size: 24.sp,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : () => controller.sendMessage(),
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
                              child: controller.isLoading.value
                                  ? SizedBox(
                                      width: 20.sp,
                                      height: 20.sp,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Color(0xFF2E7D32),
                                            ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.send,
                                      color: const Color(0xFF2E7D32),
                                      size: 20.sp,
                                    ),
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
                        label: "ai_feature_explore".tr,
                        onTap: () => _sendQuickAction(
                          controller,
                          "ai_feature_explore".tr,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildBottomChip(
                        imagePath: "assets/icons/📖.png",
                        label: "ai_feature_guidance".tr,
                        onTap: () => _sendQuickAction(
                          controller,
                          "ai_feature_guidance".tr,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _buildBottomChip(
                        imagePath: "assets/icons/🌙.png",
                        label: "ai_feature_reflection".tr,
                        onTap: () => _sendQuickAction(
                          controller,
                          "ai_feature_reflection".tr,
                        ),
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
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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
              "ai_guide_question".tr,
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
                  label: "ai_quick_surah".tr,
                  onTap: () =>
                      _sendQuickAction(controller, "ai_quick_surah_cmd".tr),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick2.png",
                  label: "ai_quick_verse".tr,
                  onTap: () =>
                      _sendQuickAction(controller, "ai_quick_verse_cmd".tr),
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
                  label: "ai_quick_reflection".tr,
                  onTap: () => _sendQuickAction(
                    controller,
                    "ai_quick_reflection_cmd".tr,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionCard(
                  imagePath: "assets/icons/quick4.png",
                  label: "ai_quick_history".tr,
                  onTap: () =>
                      _sendQuickAction(controller, "ai_quick_history_cmd".tr),
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
                          "ai_companion_name".tr,
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
                      "ai_welcome_msg".tr,
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
    controller.messageController.selection = TextSelection.fromPosition(
      TextPosition(offset: controller.messageController.text.length),
    );
  }

  Widget _buildMessagesView(AskAIController controller) {
    return ListView.builder(
      controller: controller.scrollController,
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
                        "ai_companion_name".tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        message['time'] ?? "",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  MarkdownBody(
                    data: message['text'],
                    styleSheet: MarkdownStyleSheet(
                      p: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        height: 1.5,
                      ),
                      strong: const TextStyle(fontWeight: FontWeight.bold),
                      em: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => controller.speak(message['text']),
                        child: Icon(
                          Icons.volume_up_outlined,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () =>
                            controller.copyToClipboard(message['text']),
                        child: Icon(
                          Icons.copy_outlined,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(width: 16.w),
                      GestureDetector(
                        onTap: () => controller.shareMessage(message['text']),
                        child: Icon(
                          Icons.share_outlined,
                          size: 18.sp,
                          color: Colors.grey[600],
                        ),
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
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value[0].toUpperCase()
                                : "U",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          controller.userName.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          message['time'] ?? "",
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
