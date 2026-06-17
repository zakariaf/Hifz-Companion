// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confusion_edge_dao.dart';

// ignore_for_file: type=lint
mixin _$ConfusionEdgeDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SurahsTable get surahs => attachedDatabase.surahs;
  $PagesTable get pages => attachedDatabase.pages;
  $AyatTable get ayat => attachedDatabase.ayat;
  $ConfusionEdgesTable get confusionEdges => attachedDatabase.confusionEdges;
  ConfusionEdgeDaoManager get managers => ConfusionEdgeDaoManager(this);
}

class ConfusionEdgeDaoManager {
  final _$ConfusionEdgeDaoMixin _db;
  ConfusionEdgeDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db.attachedDatabase, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db.attachedDatabase, _db.pages);
  $$AyatTableTableManager get ayat =>
      $$AyatTableTableManager(_db.attachedDatabase, _db.ayat);
  $$ConfusionEdgesTableTableManager get confusionEdges =>
      $$ConfusionEdgesTableTableManager(
          _db.attachedDatabase, _db.confusionEdges);
}
