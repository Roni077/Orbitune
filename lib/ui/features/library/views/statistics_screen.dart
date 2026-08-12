import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../domain/repositories/history_repository.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _isLoading = true;
  int _totalMs = 0;
  int _totalSkips = 0;
  List<String> _topArtists = [];
  List<String> _topAlbums = [];

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final historyRepo = ref.read(historyRepositoryProvider);
    
    final msResult = await historyRepo.getTotalListeningTimeMs();
    msResult.fold((l) => null, (ms) => _totalMs = ms);
    
    final skipsResult = await historyRepo.getTotalSkips();
    skipsResult.fold((l) => null, (skips) => _totalSkips = skips);
    
    final artistsResult = await historyRepo.getTopArtists(5);
    artistsResult.fold((l) => null, (artists) => _topArtists = artists);
    
    final albumsResult = await historyRepo.getTopAlbums(5);
    albumsResult.fold((l) => null, (albums) => _topAlbums = albums);
    
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDuration(int ms) {
    final duration = Duration(milliseconds: ms);
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes.remainder(60)}m';
    }
    return '${duration.inMinutes}m';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Stats'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.timer,
                        title: 'Listening Time',
                        value: _formatDuration(_totalMs),
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.skip_next,
                        title: 'Total Skips',
                        value: _totalSkips.toString(),
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text('Top Artists', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_topArtists.isEmpty)
                  const Text('No artist data yet.')
                else
                  ..._topArtists.asMap().entries.map((e) => ListTile(
                        leading: CircleAvatar(
                          child: Text('${e.key + 1}'),
                        ),
                        title: Text(e.value),
                      )),
                const SizedBox(height: 24),
                Text('Top Albums', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                if (_topAlbums.isEmpty)
                  const Text('No album data yet.')
                else
                  ..._topAlbums.asMap().entries.map((e) => ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(child: Text('${e.key + 1}')),
                        ),
                        title: Text(e.value),
                      )),
              ],
            ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: color)),
          const SizedBox(height: 4),
          Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
