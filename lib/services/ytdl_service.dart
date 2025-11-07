import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class YTDLService {
  static final YoutubeExplode _yt = YoutubeExplode();

  static Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      final results = await _yt.search.search(query);
      return results.map((video) {
        return {
          'id': video.id.value,
          'title': video.title,
          'channel': video.author,
          'duration': video.duration?.toString().split('.').first ?? 'Live',
          'thumbnail': video.thumbnails.highResUrl,
        };
      }).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<String> getStream(String videoId) async {
    final manifest = await _yt.videos.streamsClient.getManifest(videoId);
    final streamInfo = manifest.muxed.withHighestBitrate();
    return streamInfo.url.toString();
  }

  static Future<Video> getInfo(String videoId) async {
    return await _yt.videos.get(videoId);
  }
}