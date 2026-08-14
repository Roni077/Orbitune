import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_service/audio_service.dart';
import '../../core/helpers/settings_provider.dart';


enum DownloadStatus { queued, downloading, paused, completed, failed, canceled }

class DownloadTask {
  final String id;
  final MediaItem mediaItem;
  final DownloadStatus status;
  final double progress;
  final String? error;
  final String? savePath;
  final CancelToken? cancelToken;

  DownloadTask({
    required this.id,
    required this.mediaItem,
    this.status = DownloadStatus.queued,
    this.progress = 0.0,
    this.error,
    this.savePath,
    this.cancelToken,
  });

  DownloadTask copyWith({
    DownloadStatus? status,
    double? progress,
    String? error,
    String? savePath,
    CancelToken? cancelToken,
  }) {
    return DownloadTask(
      id: id,
      mediaItem: mediaItem,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error ?? this.error,
      savePath: savePath ?? this.savePath,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }
}

class DownloadManagerNotifier extends Notifier<List<DownloadTask>> {
  final Dio _dio = Dio();
  bool _isProcessing = false;

  @override
  List<DownloadTask> build() {
    return [];
  }

  void enqueue(MediaItem item) {
    if (state.any((t) => t.id == item.id && (t.status == DownloadStatus.downloading || t.status == DownloadStatus.queued || t.status == DownloadStatus.completed))) {
      return; // Already in queue or completed
    }

    final task = DownloadTask(
      id: item.id,
      mediaItem: item,
      status: DownloadStatus.queued,
    );

    state = [...state, task];
    _processQueue();
  }

  void cancel(String id) {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      task.cancelToken?.cancel();
      
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == taskIndex)
            task.copyWith(status: DownloadStatus.canceled)
          else
            state[i]
      ];
    }
  }
  
  void retry(String id) {
    final taskIndex = state.indexWhere((t) => t.id == id);
    if (taskIndex != -1) {
      final task = state[taskIndex];
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == taskIndex)
            task.copyWith(status: DownloadStatus.queued, error: null, progress: 0.0)
          else
            state[i]
      ];
      _processQueue();
    }
  }

  void clearCompleted() {
    state = state.where((t) => t.status != DownloadStatus.completed && t.status != DownloadStatus.canceled).toList();
  }

  Future<void> _processQueue() async {
    if (_isProcessing) return;
    
    final settings = ref.read(settingsProvider);
    if (settings.wifiOnlyDownload) {
      // Offline/Wi-Fi detection was removed. We proceed as if online.
    }

    final queuedTaskIndex = state.indexWhere((t) => t.status == DownloadStatus.queued);
    if (queuedTaskIndex == -1) return;

    _isProcessing = true;
    final task = state[queuedTaskIndex];
    final cancelToken = CancelToken();

    state = [
      for (int i = 0; i < state.length; i++)
        if (i == queuedTaskIndex)
          task.copyWith(status: DownloadStatus.downloading, cancelToken: cancelToken)
        else
          state[i]
    ];

    try {
      var dataUrl = task.mediaItem.extras?['url'] as String?;
      if (dataUrl == null || dataUrl.isEmpty) {
        dataUrl = task.mediaItem.id;
      }

      if (dataUrl.startsWith('yt:')) {
        dataUrl = dataUrl.substring(3);
      }
      
      // If it's a bare video ID, point to proxy
      if (!dataUrl.startsWith('http') && !dataUrl.startsWith('/')) {
        dataUrl = 'http://127.0.0.1:8080/?videoId=$dataUrl';
      }

      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory();
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) throw Exception('Storage not available');

      final orbituneDir = Directory('${directory.path}/Orbitune');
      if (!await orbituneDir.exists()) {
        await orbituneDir.create(recursive: true);
      }

      final safeTitle = task.mediaItem.title.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final safeArtist = task.mediaItem.artist?.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_') ?? 'Unknown';
      final savePath = '${orbituneDir.path}/$safeTitle - $safeArtist.m4a';

      await _dio.download(
        dataUrl,
        savePath,
        cancelToken: cancelToken,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            _updateTaskProgress(task.id, progress);
          }
        },
      );

      _updateTaskStatus(task.id, DownloadStatus.completed, savePath: savePath);
    } catch (e) {
      if (cancelToken.isCancelled) {
        _updateTaskStatus(task.id, DownloadStatus.canceled);
      } else {
        _updateTaskStatus(task.id, DownloadStatus.failed, error: e.toString());
      }
    } finally {
      _isProcessing = false;
      _processQueue(); // Process next in queue
    }
  }

  void _updateTaskProgress(String id, double progress) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(progress: progress) else t
    ];
  }

  void _updateTaskStatus(String id, DownloadStatus status, {String? error, String? savePath}) {
    state = [
      for (final t in state)
        if (t.id == id) t.copyWith(status: status, error: error, savePath: savePath) else t
    ];
  }
}

final downloadManagerProvider = NotifierProvider<DownloadManagerNotifier, List<DownloadTask>>(() {
  return DownloadManagerNotifier();
});
