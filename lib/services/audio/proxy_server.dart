import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'stream_resolver.dart';

class AudioProxyServer {
  static HttpServer? _server;
  static const int port = 8080;

  static Future<void> start() async {
    if (_server != null) return;

    final handler = const Pipeline().addHandler(_handleRequest);

    try {
      _server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
    } catch (e) {
      // Server already in use or failed to start — stream resolution
      // still works directly via StreamResolver without this server.
    }
  }

  static Future<Response> _handleRequest(Request request) async {
    final videoId = request.url.queryParameters['videoId'];

    if (videoId == null || videoId.isEmpty) {
      return Response.badRequest(body: 'Missing videoId parameter');
    }

    final result = await StreamResolver().resolve(videoId);
    return result.fold(
      (failure) => Response.internalServerError(body: failure.message),
      (url) => Response.found(url), // Redirect to the real stream URL
    );
  }

  static void stop() {
    _server?.close();
    _server = null;
  }
}
