import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qurany/feature/home/controller/verse_of_day_controller.dart';

// 1. DATA MODEL (Enhanced to handle API audio)
class Reciter {
  final String name;
  final String title;
  final String imageUrl;
  final String? audioUrl;

  Reciter({
    required this.name,
    required this.title,
    required this.imageUrl,
    this.audioUrl,
  });
}

// 2. THE MAIN LIST WIDGET
class HorizontalReciterList extends StatelessWidget {
  const HorizontalReciterList({super.key});

  @override
  Widget build(BuildContext context) {
    final VerseOfDayController controller = Get.find<VerseOfDayController>();

    return SizedBox(
      height: 200,
      child: Obx(() {
        if (controller.isLoading.value ||
            controller.randomVerse.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final audioData = controller.randomVerse.value!.data.verse.verse.audio;
        if (audioData == null || audioData.isEmpty) {
          return const Center(child: Text("No audio available"));
        }

        // Map API reciters to our Reciter model
        final List<Reciter> reciters = audioData.values.map((audioInfo) {
          // Determine placeholder image based on reciter name
          String placeholderImg =
              "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";

          if (audioInfo.reciter.contains("Sudais")) {
            placeholderImg =
                "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1";
          } else if (audioInfo.reciter.contains("Yasser") ||
              audioInfo.reciter.contains("Dussary")) {
            placeholderImg =
                "https://i.scdn.co/image/ab67616100005174e4bd7040657e8e61dc4667be";
          } else if (audioInfo.reciter.contains("Nasser") ||
              audioInfo.reciter.contains("Qatami")) {
            placeholderImg =
                "https://scontent.fdac207-1.fna.fbcdn.net/v/t39.30808-6/470019064_1119048786249564_9159029543174380749_n.jpg?_nc_cat=105&ccb=1-7&_nc_sid=7b2446&_nc_ohc=O9kA8gkeLGMQ7kNvwGNr5oH&_nc_oc=AdnT-OiSE9RjU0v0kTD07qPFSudAeHeqDozhECy78a0zZ8DxGG4kud8d2Wg7InObuBY&_nc_zt=23&_nc_ht=scontent.fdac207-1.fna&_nc_gid=7xGR-giX8dhXhYZ-X3B0xg&_nc_ss=8&oh=00_AfwTIfRlr9uHLOvZeNeCuTaXLMyn9KiQObXJwr7oy-Ctmg&oe=69B44A59"; // Spotify profile style placeholder for Nasser
          } else if (audioInfo.reciter.contains("Mishary") ||
              audioInfo.reciter.contains("Alafasy")) {
            placeholderImg =
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10";
          } else if (audioInfo.reciter.contains("Abu Bakr") ||
              audioInfo.reciter.contains("Shatri")) {
            placeholderImg =
                "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRUmPkcySF56YidTERKU54hBnQ0lf734dwb4w&s";
          }

          return Reciter(
            name: audioInfo.reciter,
            title: "Qurany Reciter",
            imageUrl: placeholderImg,
            audioUrl: audioInfo.url,
          );
        }).toList();

        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: reciters.length,
          separatorBuilder: (context, index) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            return ReciterCard(reciter: reciters[index]);
          },
        );
      }),
    );
  }
}

// 3. REUSABLE CARD WIDGET
class ReciterCard extends StatelessWidget {
  final Reciter reciter;

  const ReciterCard({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
    final VerseOfDayController controller = Get.find<VerseOfDayController>();

    return Container(
      width: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: Colors.grey[900],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Background Image
            Positioned.fill(
              child: Image.network(
                reciter.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[800],
                  child: const Center(
                    child: Icon(
                      Icons.person_outline,
                      color: Colors.white54,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

            // Gradient Overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.4, 1.0],
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.95),
                    ],
                  ),
                ),
              ),
            ),

            // Top Buttons
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(() {
                    final bool isPlaying =
                        controller.currentlyPlayingUrl.value ==
                        reciter.audioUrl;
                    return GestureDetector(
                      onTap: () {
                        if (reciter.audioUrl != null) {
                          controller.toggleAudio(reciter.audioUrl!);
                        }
                      },
                      child: _buildCircleButton(
                        isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        Colors.green[800]!,
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Bottom Text
            Positioned(
              bottom: 24,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reciter.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    reciter.title,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for the small circular buttons
  Widget _buildCircleButton(IconData icon, Color iconColor) {
    return Container(
      width: 30,
      height: 30,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 20),
    );
  }
}
