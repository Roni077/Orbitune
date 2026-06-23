import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio_model.dart';

class AudioRepository {
  late Isar _isar;
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    // Use path_provider to get documents dir
    final dir = await getApplicationDocumentsDirectory();
    _isar = await Isar.open(
      [AudioModelSchema],
      directory: dir.path,
    );
    _isInitialized = true;
  }

  Isar get isar => _isar;

  Future<void> saveAudios(List<AudioModel> audios) async {
    await _isar.writeTxn(() async {
      await _isar.audioModels.putAll(audios);
    });
  }

  Future<List<AudioModel>> getAllAudios() async {
    return await _isar.audioModels.where().sortByDateAddedDesc().findAll();
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.audioModels.clear();
    });
  }
}
