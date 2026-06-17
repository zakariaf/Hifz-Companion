// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reference_read_dao.dart';

// ignore_for_file: type=lint
mixin _$ReferenceReadDaoMixin on DatabaseAccessor<HifzDatabase> {
  $SurahsTable get surahs => attachedDatabase.surahs;
  $PagesTable get pages => attachedDatabase.pages;
  $LinesTable get lines => attachedDatabase.lines;
  $AyatTable get ayat => attachedDatabase.ayat;
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $MutashabihGroupsTable get mutashabihGroups =>
      attachedDatabase.mutashabihGroups;
  $MutashabihMembersTable get mutashabihMembers =>
      attachedDatabase.mutashabihMembers;
  ReferenceReadDaoManager get managers => ReferenceReadDaoManager(this);
}

class ReferenceReadDaoManager {
  final _$ReferenceReadDaoMixin _db;
  ReferenceReadDaoManager(this._db);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db.attachedDatabase, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db.attachedDatabase, _db.pages);
  $$LinesTableTableManager get lines =>
      $$LinesTableTableManager(_db.attachedDatabase, _db.lines);
  $$AyatTableTableManager get ayat =>
      $$AyatTableTableManager(_db.attachedDatabase, _db.ayat);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$MutashabihGroupsTableTableManager get mutashabihGroups =>
      $$MutashabihGroupsTableTableManager(
          _db.attachedDatabase, _db.mutashabihGroups);
  $$MutashabihMembersTableTableManager get mutashabihMembers =>
      $$MutashabihMembersTableTableManager(
          _db.attachedDatabase, _db.mutashabihMembers);
}
