// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}
