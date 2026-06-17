// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_log_dao.dart';

// ignore_for_file: type=lint
mixin _$ReviewLogDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SurahsTable get surahs => attachedDatabase.surahs;
  $PagesTable get pages => attachedDatabase.pages;
  $ReviewLogTable get reviewLog => attachedDatabase.reviewLog;
  ReviewLogDaoManager get managers => ReviewLogDaoManager(this);
}

class ReviewLogDaoManager {
  final _$ReviewLogDaoMixin _db;
  ReviewLogDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db.attachedDatabase, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db.attachedDatabase, _db.pages);
  $$ReviewLogTableTableManager get reviewLog =>
      $$ReviewLogTableTableManager(_db.attachedDatabase, _db.reviewLog);
}
