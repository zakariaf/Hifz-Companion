// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cycle_config_dao.dart';

// ignore_for_file: type=lint
mixin _$CycleConfigDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $CycleConfigsTable get cycleConfigs => attachedDatabase.cycleConfigs;
  CycleConfigDaoManager get managers => CycleConfigDaoManager(this);
}

class CycleConfigDaoManager {
  final _$CycleConfigDaoMixin _db;
  CycleConfigDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$CycleConfigsTableTableManager get cycleConfigs =>
      $$CycleConfigsTableTableManager(_db.attachedDatabase, _db.cycleConfigs);
}
