import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart'; // Tambahkan import ini
import 'package:chewie/chewie.dart';             // Tambahkan import ini
import '../providers/player_provider.dart';

// ... (bagian atas file tetap sama)

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        if (!playerProvider.isPlayerVisible) {
          return const SizedBox.shrink();
        }

        return Miniplayer(
          controller: playerProvider.miniController,
          minHeight: 70,
          maxHeight: MediaQuery.of(context).size.height,
          builder: (height, percentage) {
            if (percentage < 0.3) {
              return _buildMiniPlayer(context, playerProvider);
            }
            return _buildFullPlayer(context, playerProvider);
          },
        );
      },
    );
  }

  // --- PERUBAHAN ADA DI FUNGSI INI ---
  Widget _buildMiniPlayer(BuildContext context, PlayerProvider player) {
    return Container(
      color: const Color.fromARGB(255, 43, 41, 41),
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            // Tambahkan container dengan latar belakang hitam
            child: Container(
              color: Colors.black,
              // Berikan tinggi yang jelas untuk mencegah overflow
              height: 54, // 70 (minHeight) - 16 (padding atas & bawah)
              child: player.videoController != null && player.videoController!.value.isInitialized
                  ? AspectRatio(
                      // Gunakan rasio aspek video asli
                      aspectRatio: player.videoController!.value.aspectRatio,
                      child: VideoPlayer(player.videoController!),
                    )
                  : const Center(child: CircularProgressIndicator(color: Colors.pink)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(player.currentTitle ?? 'Loading...', style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis),
                Text(player.currentChannel ?? '...', style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              player.videoController?.value.isPlaying == true ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            onPressed: player.togglePlayPause,
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: player.hidePlayer,
          ),
        ],
      ),
    );
  }
  // ... (bagian _buildFullPlayer dan lainnya tetap sama)
}

  Widget _buildFullPlayer(BuildContext context, PlayerProvider player) {
    return Container(
      color: Colors.black,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 50,
            height: 5,
            decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
          ),
          if (player.isLoading || player.chewieController == null)
            const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.pink)))
          else
            Expanded(
              flex: 2,
              child: AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: player.chewieController!)),
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(player.currentTitle ?? 'Loading...', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                Text(player.currentChannel ?? '...', style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
