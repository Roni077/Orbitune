import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/helpers/settings_provider.dart';
import '../../../../core/helpers/providers.dart';

class FolderSelectionDialog extends ConsumerStatefulWidget {
  const FolderSelectionDialog({super.key});

  @override
  ConsumerState<FolderSelectionDialog> createState() => _FolderSelectionDialogState();
}

class _FolderSelectionDialogState extends ConsumerState<FolderSelectionDialog> {
  List<String> _availableFolders = [];
  Set<String> _selectedFolders = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    final localAudioService = ref.read(localAudioServiceProvider);
    final settings = ref.read(settingsProvider);
    
    _selectedFolders = settings.selectedFolders.toSet();
    
    final result = await localAudioService.getAudioFolders();
    result.match(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failure.message)),
          );
        }
        setState(() => _isLoading = false);
      },
      (folders) {
        setState(() {
          _availableFolders = folders;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Music Folders'),
      content: SizedBox(
        width: double.maxFinite,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _availableFolders.isEmpty
                ? const Text('No audio folders found on device.')
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _availableFolders.length,
                    itemBuilder: (context, index) {
                      final folder = _availableFolders[index];
                      final isSelected = _selectedFolders.contains(folder);
                      
                      return CheckboxListTile(
                        title: Text(folder.split('/').last),
                        subtitle: Text(folder, style: const TextStyle(fontSize: 12)),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedFolders.add(folder);
                            } else {
                              _selectedFolders.remove(folder);
                            }
                          });
                        },
                      );
                    },
                  ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            ref.read(settingsProvider.notifier).updateSelectedFolders(_selectedFolders.toList());
            Navigator.of(context).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
