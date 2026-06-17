// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_meta_dao.dart';

// ignore_for_file: type=lint
mixin _$AppMetaDaoMixin on DatabaseAccessor<HifzDatabase> {
  $AppMetaTable get appMeta => attachedDatabase.appMeta;
  AppMetaDaoManager get managers => AppMetaDaoManager(this);
}

class AppMetaDaoManager {
  final _$AppMetaDaoMixin _db;
  AppMetaDaoManager(this._db);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db.attachedDatabase, _db.appMeta);
}
