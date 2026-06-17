// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'line_block_dao.dart';

// ignore_for_file: type=lint
mixin _$LineBlockDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SurahsTable get surahs => attachedDatabase.surahs;
  $PagesTable get pages => attachedDatabase.pages;
  $LineBlocksTable get lineBlocks => attachedDatabase.lineBlocks;
  LineBlockDaoManager get managers => LineBlockDaoManager(this);
}

class LineBlockDaoManager {
  final _$LineBlockDaoMixin _db;
  LineBlockDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db.attachedDatabase, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db.attachedDatabase, _db.pages);
  $$LineBlocksTableTableManager get lineBlocks =>
      $$LineBlocksTableTableManager(_db.attachedDatabase, _db.lineBlocks);
}
