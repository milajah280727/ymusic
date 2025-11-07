import 'dart:collection';

import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YoutubeService {
  static final YoutubeExplode _yt = YoutubeExplode();

  // Ambil URL streaming terbaik (mp4)
  static Future<String> getVideoStream(String videoId) async {
    try {
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.withHighestVideoQuality();
      return streamInfo.url.toString();
    } catch (e) {
      throw Exception('Gagal ambil video: $e');
    }
  }

  // Ambil info video (judul, channel, dll)
  static Future<Video> getVideoInfo(String videoId) async {
    return await _yt.videos.get(videoId);
  }
}

extension on UnmodifiableListView<MuxedStreamInfo> {
  withHighestVideoQuality() {}
}