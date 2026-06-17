// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_dao.dart';

// ignore_for_file: type=lint
mixin _$CardDaoMixin on DatabaseAccessor<HifzDatabase> {
  $MushafsTable get mushafs => attachedDatabase.mushafs;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $SurahsTable get surahs => attachedDatabase.surahs;
  $PagesTable get pages => attachedDatabase.pages;
  $CardsTable get cards => attachedDatabase.cards;
  CardDaoManager get managers => CardDaoManager(this);
}

class CardDaoManager {
  final _$CardDaoMixin _db;
  CardDaoManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db.attachedDatabase, _db.mushafs);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db.attachedDatabase, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db.attachedDatabase, _db.pages);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db.attachedDatabase, _db.cards);
}
