import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AzkarDetailScreen extends StatefulWidget {
  final Map<String, String> categoryData;

  const AzkarDetailScreen({super.key, required this.categoryData});

  @override
  State<AzkarDetailScreen> createState() => _AzkarDetailScreenState();
}

class _AzkarDetailScreenState extends State<AzkarDetailScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentIndex = 0;

  final List<Map<String, dynamic>> _azkarItems = [
    {
      'title': "Ayah al-Kursi: The Greatest Protection",
      'arabic':
          "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ\nاللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ",
      'english':
          "I seek the protection of Allah from the accursed Shayṭān.\nAllah, there is no god worthy of worship but He, the Ever Living, The Sustainer of all. Neither drowsiness overtakes Him nor sleep. To Him Alone belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except with His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursī extends over the heavens and the earth, and their preservation does not tire Him. And He is the Most High, the Magnificent.",
      'count': 1,
      'reference': "(Al-Baqarah: 255)",
    },
    {
      'title': "3 Quls: Be Sufficed in All Your Matters",
      'arabic':
          "بِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ هُوَ اللهُ أَحَدٌ ، اللهُ الصَّمَدُ ، لَمْ يَلِدْ وَلَمْ يُولَدْ ، وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ\n\nبِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ، مِنْ شَرِّ مَا خَلَقَ ، وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ ، وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ، وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ\n\nبِسْمِ اللهِ الرَّحْمَنِ الرَّحِيمِ\nقُلْ أَعُوذُ بِرَبِّ النَّاسِ ، مَلِكِ النَّاسِ ، إِلَهِ النَّاسِ ، مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ، الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ، مِنَ الْجِنَّةِ وَالنَّاسِ",
      'english':
          "In the name of Allah, the All-Merciful, the Very Merciful.\nSay, He is Allah, the One, the Self-Sufficient Master, Who has not given birth and was not born, and to Whom no one is equal.\nSay, I seek protection of the Lord of the daybreak, from the evil of what He has created, and from the evil of the darkening night when it settles, and from the evil of the blowers in knots, and from the evil of the envier when he envies.\nSay, I seek protection of the Lord of mankind, the King of mankind, the God of mankind, from the evil of the whisperer who withdraws, who whispers in the hearts of mankind, whether they be Jinn or people.",
      'count': 3,
      'reference': "",
    },
    {
      'title': "Sayyid al-Istighfar: The Best Way of Seeking Forgiveness",
      'arabic':
          "اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ ، خَلَقْتَنِي وَأَنَا عَبْدُكَ ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ وَأَبُوءُ لَكَ بِذَنْبِي ، فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ",
      'english':
          "O Allah, You are my Lord. There is no god worthy of worship except You. You have created me, and I am Your slave, and I am under Your covenant and pledge (to fulfil it) to the best of my ability. I seek Your protection from the evil that I have done. I acknowledge the favours that You have bestowed upon me, and I admit my sins. Forgive me, for none forgives sins but You.",
      'count': 1,
      'reference': "",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: EdgeInsets.all(8.0),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black54),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16.sp,
                color: Colors.black,
              ),
            ),
          ),
        ),
        title: Text(
          widget.categoryData['title'] ?? 'Azkar',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          SizedBox(height: 20.h),
          // PageView for Azkar Cards
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemCount: _azkarItems.length,
              itemBuilder: (context, index) {
                final item = _azkarItems[index];
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Column(
                    children: [
                      // Azkar Title
                      Text(
                        item['title'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      // Card Data
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: Colors.green, width: 1.5),
                          ),
                          padding: EdgeInsets.all(20.w),
                          child: Stack(
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Align(
                                      alignment: Alignment.topRight,
                                      child: Text(
                                        item['arabic'],
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 22.sp,
                                          fontFamily:
                                              'Amiri', // Assuming Amiri font is available or fallback
                                          height: 1.8,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 24.h),
                                    Text(
                                      item['english'],
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.black87,
                                        height: 1.5,
                                      ),
                                    ),
                                    if (item['reference'] != null &&
                                        item['reference'].isNotEmpty)
                                      Padding(
                                        padding: EdgeInsets.only(top: 8.h),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item['reference'],
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                      ),
                                    SizedBox(
                                      height: 60.h,
                                    ), // Space for bottom icons
                                  ],
                                ),
                              ),
                              // Bottom Action Icons
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.copy_all_outlined,
                                      color: Colors.grey,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 16.w),
                                    Icon(
                                      Icons.bookmark_border,
                                      color: Colors.grey,
                                      size: 24.sp,
                                    ),
                                    SizedBox(width: 16.w),
                                    Icon(
                                      Icons.share_outlined,
                                      color: Colors.grey,
                                      size: 24.sp,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Controls Area
          SizedBox(height: 20.h),

          // Hexagon Counter
          Stack(
            alignment: Alignment.center,
            children: [
              // Simple hexagon shape representation using RotationTransition or just a styled container
              // For a perfect hexagon, a CustomPainter or ShapeBorder is best, but a rotated box works for simple visuals or an image
              Transform.rotate(
                angle: 0.785398, // 45 degrees in radians
                child: Container(
                  width: 50.w,
                  height: 50.w,
                  decoration: BoxDecoration(
                    color: Color(0xFF388E3C), // Green
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
              Text(
                "0 / ${_azkarItems[_currentIndex]['count']}",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Playback Controls
          Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            margin: EdgeInsets.symmetric(horizontal: 40.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(50.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Icon(
                    Icons.skip_previous_outlined,
                    color: Colors.grey,
                    size: 28.sp,
                  ),
                ),
                Icon(Icons.play_arrow, color: Color(0xFF388E3C), size: 36.sp),
                GestureDetector(
                  onTap: () {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Icon(
                    Icons.skip_next_outlined,
                    color: Colors.grey,
                    size: 28.sp,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 12.h),
          Text(
            "Swipe right for more",
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 30.h),
        ],
      ),
    );
  }
}
