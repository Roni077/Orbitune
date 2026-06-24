import 'package:isar/isar.dart';

import '../models/audio_model.dart';

class AudioRepository {
  final Isar _isar;

  AudioRepository(this._isar);

  Isar get isar => _isar;

  Future<void> saveAudios(List<AudioModel> audios) async {
    await _isar.writeTxn(() async {
      await _isar.audioModels.putAll(audios);
    });
  }

  Future<void> deleteAudios(List<Id> ids) async {
    await _isar.writeTxn(() async {
      await _isar.audioModels.deleteAll(ids);
    });
  }

  Future<List<AudioModel>> getAllAudios() async {
    return await _isar.audioModels.where().sortByDateAddedDesc().findAll();
  }

  Stream<List<AudioModel>> watchAllAudios() {
    return _isar.audioModels.where().sortByDateAddedDesc().watch(fireImmediately: true);
  }

  Future<void> clearAll() async {
    await _isar.writeTxn(() async {
      await _isar.audioModels.clear();
    });
  }
}
