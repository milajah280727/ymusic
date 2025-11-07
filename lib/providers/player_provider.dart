import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:miniplayer/miniplayer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PlayerProvider extends ChangeNotifier {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  final MiniplayerController miniController = MiniplayerController();

  bool _isLoading = true;
  bool _isPlayerVisible = false;
  String? _currentVideoId;
  String? _currentTitle;
  String? _currentChannel;

  // Getters
  VideoPlayerController? get videoController => _videoController;
  ChewieController? get chewieController => _chewieController;
  bool get isLoading => _isLoading;
  bool get isPlayerVisible => _isPlayerVisible;
  String? get currentVideoId => _currentVideoId;
  String? get currentTitle => _currentTitle;
  String? get currentChannel => _currentChannel;

  Future<void> playVideo({
    required String videoId,
    required String title,
    required String channel,
  }) async {
    if (_currentVideoId == videoId && _isPlayerVisible) {
      miniController.animateToHeight(state: PanelState.MAX);
      return;
    }

    _disposeControllers();
    _isLoading = true;
    _currentVideoId = videoId;
    _currentTitle = title;
    _currentChannel = channel;
    _isPlayerVisible = true;
    notifyListeners();

    final yt = YoutubeExplode();
    try {
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final stream = manifest.muxed.withHighestBitrate();
      
      _videoController = VideoPlayerController.networkUrl(Uri.parse(stream.url.toString()));
      await _videoController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.pink,
          handleColor: Colors.pinkAccent,
        ),
      );

      // Simpan ke recent setelah video berhasil di-load
      await _saveToRecent();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading video: $e');
      hidePlayer();
    } finally {
      yt.close();
    }
  }

  void togglePlayPause() {
    if (_videoController != null && _videoController!.value.isInitialized) {
      _videoController!.value.isPlaying ? _videoController!.pause() : _videoController!.play();
      notifyListeners();
    }
  }

  void hidePlayer() {
    _isPlayerVisible = false;
    _disposeControllers();
    notifyListeners();
  }

  void _disposeControllers() {
    _chewieController?.dispose();
    _videoController?.dispose();
    _chewieController = null;
    _videoController = null;
  }

  /// Fungsi untuk menyimpan video yang diputar ke "recently played"
  Future<void> _saveToRecent() async {
    if (_videoController == null || !_videoController!.value.isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final item = [
      _currentVideoId,
      _currentTitle,
      _currentChannel,
      _videoController!.value.duration.toString().split('.').first,
      'https://i.ytimg.com/vi/$_currentVideoId/hqdefault.jpg',
    ].join('|||');

    List<String> recent = prefs.getStringList('recent_played') ?? [];
    recent.removeWhere((e) => e.startsWith(_currentVideoId ?? ''));
    recent.add(item);

    if (recent.length > 50) recent.removeAt(0);
    await prefs.setStringList('recent_played', recent);
  }

  @override
  void dispose() {
    _disposeControllers();
    miniController.dispose();
    super.dispose();
  }
}