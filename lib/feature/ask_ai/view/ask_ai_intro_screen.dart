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
import 'package:qurany/core/services/purchase_api.dart';
import 'package:qurany/core/services/usage_service.dart';

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

  RxInt aiUsageCount = 0.obs;
  RxInt aiCap = 5.obs;

  Future<void> refreshUsageCount() async {
    final userId = UsageService.getActiveUserId();
    aiUsageCount.value = await UsageService.getUsageCount(
      userId,
      'ai_companion',
    );
    final caps = await UsageService.getCaps();
    aiCap.value = caps['ai_companion'] ?? 5;
  }

  @override
  void onInit() {
    super.onInit();
    _loadUserName();
    _initSpeech();
    _initTts();
    refreshUsageCount();
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
      // Entitlement & Usage cap check
      final isPremium = PurchaseApi.isUserPremium();
      if (!isPremium) {
        final userId = UsageService.getActiveUserId();
        final count = await UsageService.getUsageCount(userId, 'ai_companion');
        final caps = await UsageService.getCaps();
        final cap = caps['ai_companion'] ?? 5;

        if (count >= cap) {
          // Present paywall
          await PurchaseApi.presentPaywallIfNeededForPlacement('ai_companion');
          // Update status
          await PurchaseApi.updatePremiumStatus();
          if (!PurchaseApi.isUserPremium()) {
            // Block sending
            Get.snackbar(
              'Premium Required',
              'You have reached your weekly limit of free AI companion queries.',
              backgroundColor: Colors.orange[800],
              colorText: Colors.white,
              snackPosition: SnackPosition.BOTTOM,
            );
            return;
          }
        }
      }

      String userQuery = messageController.text;
      String time = DateFormat('hh:mm a').format(DateTime.now());
      messages.add({'text': userQuery, 'isUser': true, 'time': time});
      messageController.clear();
      scrollToBottom();

      isLoading.value = true;

      final response = await _askAiService.sendMessage(userQuery);

      isLoading.value = false;
      debugPrint('[AskAI] sendMessage raw response: $response');

      if (response != null && response['success'] == true) {
        String aiResponse = response['data']['response'];
        debugPrint('[AskAI] Extracted AI response: $aiResponse');
        messages.add({
          'text': aiResponse,
          'isUser': false,
          'time': DateFormat('hh:mm a').format(DateTime.now()),
        });

        // Increment usage count in the background for free users
        if (!PurchaseApi.isUserPremium()) {
          final userId = UsageService.getActiveUserId();
          UsageService.incrementUsage(userId, 'ai_companion').then((_) {
            refreshUsageCount();
          }).catchError((e) {
            debugPrint('[AskAI] Error incrementing usage: $e');
          });
        }
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
            image: AssetImage('assets/image/askaiintrobg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.2),
                Colors.black.withOpacity(0.6),
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
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        children: [
                          SizedBox(height: 15.h),
                          // Lantern Icon in a glowing circle
                          Center(
                            child: Image.asset(
                              "assets/icons/chatscreenstar.png",
                              width: 100.w,
                              height: 100.w,
                              fit: BoxFit.contain,
                            ),
                          ),

                          // Title
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Meet Your Deen Companion",
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),

                                SizedBox(height: 8.h),

                                // Description Intro
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "A personal space for reflection and learning, carefully nurtured by:",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                                  ),
                                ),

                                SizedBox(height: 8.h),

                                // Bullet Points
                                _buildBulletPoint("The Holy Quran"),
                                _buildBulletPoint(
                                  "Authentic Hadith Collections",
                                ),
                                _buildBulletPoint(
                                  "Trusted Islamic Scholarship",
                                ),

                                SizedBox(height: 8.h),

                                // Support Text
                                Text(
                                  "A protected, specialized AI designed exclusively for Islamic knowledge. Keeping conversations authentic, safe and focused.",
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 12.h),

                          // Divider
                          Container(
                            width: double.infinity,
                            height: 1,
                            color: Colors.white.withOpacity(0.2),
                          ),

                          SizedBox(height: 12.h),

                          // Grid Features
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridFeatureItem(
                                  imagePath: "assets/icons/askintro2.png",
                                  title: "Emotional guidance and Duas",
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildGridFeatureItem(
                                  imagePath: "assets/icons/askintro1.png",
                                  title: "Deepen quranic understanding",
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildGridFeatureItem(
                                  imagePath: "assets/icons/askintro4.png",
                                  title: "Prophetic stories and wisdom",
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: _buildGridFeatureItem(
                                  imagePath: "assets/icons/askintro3.png",
                                  title: "Deepen quranic understanding",
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 40.h),

                          // Bismillah Button
                          GestureDetector(
                            onTap: () => controller.startChat(),
                            child: Container(
                              width: double.infinity,
                              height: 45.h,
                              decoration: const BoxDecoration(
                                image: DecorationImage(
                                  image: AssetImage('assets/image/button.png'),
                                  fit: BoxFit.fill,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  "Bismillah, Let's Start",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),
                          // Info Box
                          Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.white,
                                  size: 24.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    "Enhanced with advanced contextual layers to guide your personal learning. A companion for reflection, alongside traditional knowledge",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        //SizedBox(width: 40.w),
        Container(
          width: 4.w,
          height: 4.w,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildGridFeatureItem({
    required String imagePath,
    required String title,
  }) {
    return Row(
      children: [
        Image.asset(imagePath, width: 44.sp, height: 44.sp),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,

              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => controller.goBack(),
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 20.sp,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/icons/chatscreenstar.png",
                            width: 42.sp,
                            height: 42.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            "ai_chat_title".tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),
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
                              fontSize: 11.sp,
                              color: const Color(0xFF4CAF50),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

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
                  Obx(() {
                    final isPremium = PurchaseApi.isUserPremium();
                    if (!isPremium &&
                        controller.aiUsageCount.value ==
                            controller.aiCap.value - 1) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: Text(
                          "1 free message left this week",
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  Obx(
                    () => controller.messages.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.only(top: 16.h),
                            child: Row(
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
                          )
                        : const SizedBox.shrink(),
                  ),
                  SizedBox(height: 8.h),

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
                            child: Image.asset(
                              "assets/icons/goldenmic.png",
                              width: 35.sp,
                              height: 35.sp,
                              color: controller.isListening.value
                                  ? Colors.redAccent
                                  : null,
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Obx(
                          () => GestureDetector(
                            onTap: controller.isLoading.value
                                ? null
                                : () => controller.sendMessage(),
                            child: controller.isLoading.value
                                ? SizedBox(
                                    width: 35.sp,
                                    height: 35.sp,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Color(0xFF2E7D32),
                                      ),
                                    ),
                                  )
                                : Image.asset(
                                    "assets/icons/goldensend.png",
                                    width: 35.sp,
                                    height: 35.sp,
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Action Chips - only show when messages are present
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
            color: const Color(0xFFECF1E4),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFF2E7D32)),
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
                    color: Colors.black,
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
          Center(
            child: Image.asset(
              "assets/icons/chatscreenstar.png",
              width: 120.sp,
              height: 120.sp,
            ),
          ),
          Center(
            child: Text(
              "السَّلَامُ عَلَيْكُمْ وَرَحْمَةُ اللهِ وَبَرَكَاتُهُ",
              style: TextStyle(
                fontSize: 18.sp,
                fontFamily: 'Arial',
                color: Color(0xFF2F7D33),
              ),
              textAlign: TextAlign.center,
            ),
          ),

          Center(
            child: Text(
              "Assalamu-alaikum, dear friend 🌙",
              style: TextStyle(
                fontFamily: 'Figtree',
                fontWeight: FontWeight.w600,
                fontSize: 16.sp,

                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.h),

          Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                "Welcome to your personal space for reflection. Whether you want to dive deep into a Surah, ask a question about your deen, or simply share what’s on your heart today, I'm here for you.",
                style: TextStyle(
                  fontFamily: 'Figtree',
                  fontWeight: FontWeight.w400,
                  fontSize: 12.sp,

                  color: Colors.black54,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                SizedBox(
                  width: 140.w,
                  child: _buildQuickActionCard(
                    imagePath: "assets/icons/quick1.png",
                    label:
                        "Help me understand the core message of this Surah...",
                    onTap: () =>
                        _sendQuickAction(controller, "ai_quick_surah_cmd".tr),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 140.w,
                  child: _buildQuickActionCard(
                    imagePath: "assets/icons/quick2.png",
                    label:
                        " I'm feeling [anxious/lost/grateful]. Can we reflect on a verse?",
                    onTap: () =>
                        _sendQuickAction(controller, "ai_quick_verse_cmd".tr),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 140.w,
                  child: _buildQuickActionCard(
                    imagePath: "assets/icons/quick3.png",
                    label: "Tell me an inspiring story from the Prophets...",
                    onTap: () => _sendQuickAction(
                      controller,
                      "ai_quick_reflection_cmd".tr,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 140.w,
                  child: _buildQuickActionCard(
                    imagePath: "assets/icons/quick4.png",
                    label: "Learn about the history of Islam...",
                    onTap: () =>
                        _sendQuickAction(controller, "ai_quick_history_cmd".tr),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),
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
        height: 120.h,
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Color(0XFFE2E9D8),
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 32.sp, height: 32.sp),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(fontSize: 10.sp, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
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
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    "assets/icons/chattopicon.png",
                    width: 32.sp,
                    height: 32.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 4.w),
                        child: Container(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: MarkdownBody(
                              data: message['text'],
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.black.withOpacity(0.8),
                                  height: 1.6,
                                  fontFamily: 'Figtree',
                                ),
                                strong: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Figtree',
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          // GestureDetector(
                          //   onTap: () => controller.speak(message['text']),
                          //   child: Icon(
                          //     Icons.volume_up_outlined,
                          //     size: 20.sp,
                          //     color: Colors.grey[400],
                          //   ),
                          // ),
                          //SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () =>
                                controller.copyToClipboard(message['text']),
                            child: Icon(
                              Icons.copy_outlined,
                              size: 20.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                          SizedBox(width: 16.w),
                          GestureDetector(
                            onTap: () =>
                                controller.shareMessage(message['text']),
                            child: Icon(
                              Icons.share_outlined,
                              size: 20.sp,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // User Message
          return Padding(
            padding: EdgeInsets.only(bottom: 24.h),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1E9),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.r),
                            bottomLeft: Radius.circular(20.r),
                            bottomRight: Radius.circular(20.r),
                            topRight: Radius.circular(4.r),
                          ),
                        ),
                        child: Text(
                          message['text'],
                          style: TextStyle(
                            fontSize: 15.sp,
                            color: Colors.black.withOpacity(0.8),
                            height: 1.4,
                            fontFamily: 'Figtree',
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, right: 4.w),
                        child: Text(
                          message['time'] ?? "",
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                Container(
                  width: 36.sp,
                  height: 36.sp,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2E7D32),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      controller.userName.value.isNotEmpty
                          ? controller.userName.value[0].toUpperCase()
                          : "U",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
