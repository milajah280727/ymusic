// lib/widgets/mini_player_widget.dart

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:provider/provider.dart';
import 'package:chewie/chewie.dart';
import '../providers/player_provider.dart';
import '../services/audio_player_service.dart';

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

  Widget _buildMiniPlayer(BuildContext context, PlayerProvider player) {
    return StreamBuilder<PlaybackState>(
      stream: player.audioHandler?.playbackState,
      builder: (context, snapshot) {
        final isPlaying = snapshot.data?.playing ?? false;
        final position = snapshot.data?.position ?? Duration.zero;
        final duration = player.duration ?? Duration.zero;

        return Container(
          color: const Color.fromARGB(255, 43, 41, 41),
          child: Column(
            children: [
              LinearProgressIndicator(
                value: duration.inSeconds == 0 ? 0.0 : position.inSeconds / duration.inSeconds,
                backgroundColor: Colors.grey[700],
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          'https://i.ytimg.com/vi/${player.currentVideoId}/mqdefault.jpg',
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[800],
                            child: const Icon(Icons.music_video, color: Colors.white70, size: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(player.currentTitle ?? 'Loading...', style: const TextStyle(color: Colors.white, fontSize: 14), overflow: TextOverflow.ellipsis, maxLines: 1),
                            Text(player.currentChannel ?? '...', style: const TextStyle(color: Colors.grey, fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                          ],
                        ),
                      ),
                      if (!player.isPlayingVideo)
                        IconButton(
                          icon: const Icon(Icons.video_library_outlined, color: Colors.white, size: 24),
                          onPressed: () => player.switchToVideo(),
                          tooltip: 'Tampilkan Video',
                        ),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 28),
                        onPressed: player.togglePlayPause,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white, size: 28),
                        onPressed: player.skipToNext,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }
    );
  }

  Widget _buildFullPlayer(BuildContext context, PlayerProvider player) {
    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(color: Colors.grey[700], borderRadius: BorderRadius.circular(10)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: player.isPlayingVideo ? () => player.switchToAudio() : null,
                    icon: const Icon(Icons.music_note, color: Colors.white),
                    label: const Text('Audio', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: player.isPlayingVideo ? Colors.transparent : Colors.pink,
                    ),
                  ),
                  const SizedBox(width: 20),
                  TextButton.icon(
                    onPressed: !player.isPlayingVideo ? () => player.switchToVideo() : null,
                    icon: const Icon(Icons.videocam, color: Colors.white),
                    label: const Text('Video', style: TextStyle(color: Colors.white)),
                    style: TextButton.styleFrom(
                      backgroundColor: player.isPlayingVideo ? Colors.pink : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: player.isPlayingVideo && player.chewieController != null
                  ? AspectRatio(aspectRatio: 16 / 9, child: Chewie(controller: player.chewieController!))
                  : _buildAudioPlayerView(context, player),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayerView(BuildContext context, PlayerProvider player) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white), onPressed: () => player.miniController.animateToHeight(state: PanelState.MIN)),
                  const Text('Sedang Diputar', style: TextStyle(color: Colors.grey)),
                  _buildMoreOptionsMenu(context, player),
                ],
              ),
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        'https://i.ytimg.com/vi/${player.currentVideoId}/hqdefault.jpg',
                        width: 250,
                        height: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(player.currentTitle ?? 'Loading...', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(player.currentChannel ?? '...', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                  ],
                ),
              ),
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildProgressBarWithTimestamp(player),
                    const SizedBox(height: 16),
                    _buildPlaybackControls(player),
                    const SizedBox(height: 16),
                    _buildQueueStatus(player),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _buildRelatedSongsBar(player),
        ),
      ],
    );
  }

  Widget _buildMoreOptionsMenu(BuildContext context, PlayerProvider player) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.white),
      onSelected: (String value) {
        switch (value) {
          case 'add_to_favorites':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur favorit belum tersedia')),
            );
            break;
          case 'view_details':
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Fitur detail belum tersedia')),
            );
            break;
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'add_to_favorites',
          child: Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.pink),
              SizedBox(width: 8),
              Text('Tambah ke Favorit'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'view_details',
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white),
              SizedBox(width: 8),
              Text('Lihat Detail'),
            ],
          ),
        ),
      ],
    );
  }

  // --- WIDGET PROGRESS BAR DENGAN BUFFER (SUDAH DIPERBAIKI) ---
  Widget _buildProgressBarWithTimestamp(PlayerProvider player) {
    return StreamBuilder<PlaybackState>(
      stream: player.audioHandler?.playbackState,
      builder: (context, snapshot) {
        final position = snapshot.data?.position ?? Duration.zero;
        final bufferedPosition = snapshot.data?.bufferedPosition ?? Duration.zero; // Ambil posisi buffer
        final duration = player.duration ?? Duration.zero;
        return Column(
          children: [
            // Stack untuk menumpuk indikator buffer dan slider
            Stack(
              children: [
                // 1. Indikator Buffer (Latar Belakang)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0), // Sembunyikan thumb
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 0), // Sembunyikan overlay
                    activeTrackColor: Colors.grey[600], // Warna track buffer
                    inactiveTrackColor: Colors.grey[800],
                    thumbColor: Colors.transparent,
                    overlayColor: Colors.transparent,
                  ),
                  child: Slider(
                    min: 0.0,
                    max: duration.inSeconds.toDouble(),
                    value: bufferedPosition.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    onChanged: (_) {}, // Tidak bisa diinteraksi
                  ),
                ),
                // 2. Slider Posisi Aktif (Layar Depan)
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    trackHeight: 4.0,
                    activeTrackColor: Colors.transparent, // Buat track aktif transparan
                    inactiveTrackColor: Colors.transparent, // Buat track tidak aktif transparan
                    thumbColor: Colors.pink,
                    overlayColor: Colors.pink.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    min: 0.0,
                    max: duration.inSeconds.toDouble(),
                    value: position.inSeconds.toDouble().clamp(0.0, duration.inSeconds.toDouble()),
                    onChanged: (value) {
                      player.audioHandler?.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDuration(position), style: const TextStyle(color: Colors.white, fontSize: 12)),
                  Text(_formatDuration(duration), style: const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPlaybackControls(PlayerProvider player) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: Icon(Icons.shuffle, color: player.isShuffled ? Colors.pink : Colors.grey),
          iconSize: 24,
          onPressed: player.toggleShuffle,
        ),
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          iconSize: 40,
          onPressed: player.skipToPrevious,
        ),
        StreamBuilder<PlaybackState>(
          stream: player.audioHandler?.playbackState,
          builder: (context, snapshot) {
            final isPlaying = snapshot.data?.playing ?? false;
            return IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white),
              iconSize: 64,
              onPressed: player.togglePlayPause,
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          iconSize: 40,
          onPressed: player.skipToNext,
        ),
        IconButton(
          icon: _buildRepeatIcon(player.repeatMode),
          iconSize: 24,
          onPressed: player.toggleRepeat,
        ),
      ],
    );
  }

  Widget _buildQueueStatus(PlayerProvider player) {
    final queueLength = player.audioHandler?.queue.value.length ?? 1;
    final repeatStatusText = player.repeatMode == RepeatMode.all ? 'Ulangi semua trek' : (player.repeatMode == RepeatMode.one ? 'Ulangi satu trek' : '');
    
    return Text(
      'Sedang dimainkan 1 / $queueLength [$repeatStatusText]',
      style: const TextStyle(color: Colors.grey, fontSize: 12),
    );
  }

  Widget _buildRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
        return const Icon(Icons.repeat, color: Colors.grey);
      case RepeatMode.all:
        return const Icon(Icons.repeat, color: Colors.pink);
      case RepeatMode.one:
        return const Icon(Icons.repeat_one, color: Colors.pink);
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildRelatedSongsBar(PlayerProvider player) {
    return Miniplayer(
      controller: player.relatedController,
      minHeight: 60,
      maxHeight: 250,
      builder: (height, percentage) {
        return Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 43, 41, 41),
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: percentage > 0.5
              ? _buildRelatedSongsList(player)
              : _buildRelatedSongsHeader(),
        );
      },
    );
  }

  Widget _buildRelatedSongsHeader() {
    return const ListTile(
      leading: Icon(Icons.queue_music, color: Colors.white),
      title: Text('Lagu Terkait', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      trailing: Icon(Icons.keyboard_arrow_up, color: Colors.white),
    );
  }

  Widget _buildRelatedSongsList(PlayerProvider player) {
    if (player.relatedSongs.isEmpty) {
      return const Center(child: Text('Tidak ada lagu terkait', style: TextStyle(color: Colors.grey)));
    }
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.queue_music, color: Colors.white),
          title: const Text('Lagu Terkait', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          trailing: IconButton(icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white), onPressed: () => player.relatedController.animateToHeight(state: PanelState.MIN)),
        ),
        const Divider(height: 1, color: Colors.grey),
        Expanded(
          child: ListView.builder(
            itemCount: player.relatedSongs.length,
            itemBuilder: (context, index) {
              final song = player.relatedSongs[index];
              return ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(song['thumbnail'], width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Container(width: 50, height: 50, color: Colors.grey[800], child: const Icon(Icons.music_video, color: Colors.white70))),
                ),
                title: Text(song['title'], style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(song['channel'], style: const TextStyle(color: Colors.grey)),
                onTap: () {
                  player.playMusic(
                    videoId: song['id'],
                    title: song['title'],
                    channel: song['channel'],
                  );
                  player.relatedController.animateToHeight(state: PanelState.MIN);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}