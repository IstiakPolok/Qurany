import 'package:flutter/material.dart';

// 1. DATA MODEL (Renamed to Reciter)
class Reciter {
  final String name;
  final String title;
  final String imageUrl;

  Reciter({required this.name, required this.title, required this.imageUrl});
}

// 2. THE MAIN LIST WIDGET
class HorizontalReciterList extends StatelessWidget {
  HorizontalReciterList({super.key});

  // Sample data for Reciters
  final List<Reciter> reciters = [
    Reciter(
      name: "Mishary Al-Afasy",
      title: "The Voice of Devotion",
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ4ITFPD413vKjV0PespKY0StV0CJBePAZrXdxqtb2zj6SMIPQVaYf6vNcXb7kLDoMgwHQW55fFAlYn4sJe9-A5cEh3Obm2gbOpmlKrgjg&s=10",
    ),
    Reciter(
      name: "Sheikh Sudais",
      title: "Imam of Masjid al-Haram",
      imageUrl:
          "https://i0.wp.com/www.middleeastmonitor.com/wp-content/uploads/2020/09/Abdul-Rahman-Al-Sudais.jpg?fit=920%2C613&ssl=1",
    ),
    Reciter(
      name: "Maher Al Muaiqly",
      title: "Imam of Masjid Al-Haram",
      imageUrl:
          "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkIhUZ2LpPTse0VvW-roPi1L5cGLFCQm9zPERRQJUgy2ZvDTI_aek9PHHE5HVZqIa_eh9sbS0fiMtJ8HAkloqNCVrpHkbIDK_x8qfzCQ&s=10",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: reciters.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          return ReciterCard(reciter: reciters[index]);
        },
      ),
    );
  }
}

// 3. REUSABLE CARD WIDGET
class ReciterCard extends StatelessWidget {
  final Reciter reciter;

  const ReciterCard({super.key, required this.reciter});

  @override
  Widget build(BuildContext context) {
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
                  _buildCircleButton(
                    Icons.play_arrow_rounded,
                    Colors.green[800]!,
                  ),
                  _buildCircleButton(Icons.download_rounded, Colors.black),
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
