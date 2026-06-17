// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $MushafsTable extends Mushafs with TableInfo<$MushafsTable, MushafRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MushafsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _mushafIdMeta =
      const VerificationMeta('mushafId');
  @override
  late final GeneratedColumn<String> mushafId = GeneratedColumn<String>(
      'mushaf_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _riwayahMeta =
      const VerificationMeta('riwayah');
  @override
  late final GeneratedColumn<String> riwayah = GeneratedColumn<String>(
      'riwayah', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lineCountMeta =
      const VerificationMeta('lineCount');
  @override
  late final GeneratedColumn<int> lineCount = GeneratedColumn<int>(
      'line_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageCountMeta =
      const VerificationMeta('pageCount');
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
      'page_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _fontFamilyMeta =
      const VerificationMeta('fontFamily');
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
      'font_family', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _checksumSha256Meta =
      const VerificationMeta('checksumSha256');
  @override
  late final GeneratedColumn<String> checksumSha256 = GeneratedColumn<String>(
      'checksum_sha256', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        mushafId,
        riwayah,
        name,
        lineCount,
        pageCount,
        fontFamily,
        checksumSha256
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mushaf';
  @override
  VerificationContext validateIntegrity(Insertable<MushafRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('mushaf_id')) {
      context.handle(_mushafIdMeta,
          mushafId.isAcceptableOrUnknown(data['mushaf_id']!, _mushafIdMeta));
    } else if (isInserting) {
      context.missing(_mushafIdMeta);
    }
    if (data.containsKey('riwayah')) {
      context.handle(_riwayahMeta,
          riwayah.isAcceptableOrUnknown(data['riwayah']!, _riwayahMeta));
    } else if (isInserting) {
      context.missing(_riwayahMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('line_count')) {
      context.handle(_lineCountMeta,
          lineCount.isAcceptableOrUnknown(data['line_count']!, _lineCountMeta));
    } else if (isInserting) {
      context.missing(_lineCountMeta);
    }
    if (data.containsKey('page_count')) {
      context.handle(_pageCountMeta,
          pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta));
    } else if (isInserting) {
      context.missing(_pageCountMeta);
    }
    if (data.containsKey('font_family')) {
      context.handle(
          _fontFamilyMeta,
          fontFamily.isAcceptableOrUnknown(
              data['font_family']!, _fontFamilyMeta));
    } else if (isInserting) {
      context.missing(_fontFamilyMeta);
    }
    if (data.containsKey('checksum_sha256')) {
      context.handle(
          _checksumSha256Meta,
          checksumSha256.isAcceptableOrUnknown(
              data['checksum_sha256']!, _checksumSha256Meta));
    } else if (isInserting) {
      context.missing(_checksumSha256Meta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {mushafId};
  @override
  MushafRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MushafRow(
      mushafId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mushaf_id'])!,
      riwayah: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}riwayah'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      lineCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_count'])!,
      pageCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_count'])!,
      fontFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_family'])!,
      checksumSha256: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}checksum_sha256'])!,
    );
  }

  @override
  $MushafsTable createAlias(String alias) {
    return $MushafsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MushafRow extends DataClass implements Insertable<MushafRow> {
  /// The stable edition id (PK).
  final String mushafId;

  /// The named riwāyah (e.g. `hafs_an_asim`) — stated explicitly (R2).
  final String riwayah;

  /// The display name of the edition.
  final String name;

  /// Lines per page (a field, never hardcoded — the muṣḥaf is swappable).
  final int lineCount;

  /// Pages in the edition (a field, never hardcoded).
  final int pageCount;

  /// The page-glyph font family.
  final String fontFamily;

  /// The pinned SHA-256 verified against the asset manifest (E05).
  final String checksumSha256;
  const MushafRow(
      {required this.mushafId,
      required this.riwayah,
      required this.name,
      required this.lineCount,
      required this.pageCount,
      required this.fontFamily,
      required this.checksumSha256});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['mushaf_id'] = Variable<String>(mushafId);
    map['riwayah'] = Variable<String>(riwayah);
    map['name'] = Variable<String>(name);
    map['line_count'] = Variable<int>(lineCount);
    map['page_count'] = Variable<int>(pageCount);
    map['font_family'] = Variable<String>(fontFamily);
    map['checksum_sha256'] = Variable<String>(checksumSha256);
    return map;
  }

  MushafsCompanion toCompanion(bool nullToAbsent) {
    return MushafsCompanion(
      mushafId: Value(mushafId),
      riwayah: Value(riwayah),
      name: Value(name),
      lineCount: Value(lineCount),
      pageCount: Value(pageCount),
      fontFamily: Value(fontFamily),
      checksumSha256: Value(checksumSha256),
    );
  }

  factory MushafRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MushafRow(
      mushafId: serializer.fromJson<String>(json['mushafId']),
      riwayah: serializer.fromJson<String>(json['riwayah']),
      name: serializer.fromJson<String>(json['name']),
      lineCount: serializer.fromJson<int>(json['lineCount']),
      pageCount: serializer.fromJson<int>(json['pageCount']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      checksumSha256: serializer.fromJson<String>(json['checksumSha256']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'mushafId': serializer.toJson<String>(mushafId),
      'riwayah': serializer.toJson<String>(riwayah),
      'name': serializer.toJson<String>(name),
      'lineCount': serializer.toJson<int>(lineCount),
      'pageCount': serializer.toJson<int>(pageCount),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'checksumSha256': serializer.toJson<String>(checksumSha256),
    };
  }

  MushafRow copyWith(
          {String? mushafId,
          String? riwayah,
          String? name,
          int? lineCount,
          int? pageCount,
          String? fontFamily,
          String? checksumSha256}) =>
      MushafRow(
        mushafId: mushafId ?? this.mushafId,
        riwayah: riwayah ?? this.riwayah,
        name: name ?? this.name,
        lineCount: lineCount ?? this.lineCount,
        pageCount: pageCount ?? this.pageCount,
        fontFamily: fontFamily ?? this.fontFamily,
        checksumSha256: checksumSha256 ?? this.checksumSha256,
      );
  MushafRow copyWithCompanion(MushafsCompanion data) {
    return MushafRow(
      mushafId: data.mushafId.present ? data.mushafId.value : this.mushafId,
      riwayah: data.riwayah.present ? data.riwayah.value : this.riwayah,
      name: data.name.present ? data.name.value : this.name,
      lineCount: data.lineCount.present ? data.lineCount.value : this.lineCount,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      checksumSha256: data.checksumSha256.present
          ? data.checksumSha256.value
          : this.checksumSha256,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MushafRow(')
          ..write('mushafId: $mushafId, ')
          ..write('riwayah: $riwayah, ')
          ..write('name: $name, ')
          ..write('lineCount: $lineCount, ')
          ..write('pageCount: $pageCount, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('checksumSha256: $checksumSha256')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(mushafId, riwayah, name, lineCount, pageCount,
      fontFamily, checksumSha256);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MushafRow &&
          other.mushafId == this.mushafId &&
          other.riwayah == this.riwayah &&
          other.name == this.name &&
          other.lineCount == this.lineCount &&
          other.pageCount == this.pageCount &&
          other.fontFamily == this.fontFamily &&
          other.checksumSha256 == this.checksumSha256);
}

class MushafsCompanion extends UpdateCompanion<MushafRow> {
  final Value<String> mushafId;
  final Value<String> riwayah;
  final Value<String> name;
  final Value<int> lineCount;
  final Value<int> pageCount;
  final Value<String> fontFamily;
  final Value<String> checksumSha256;
  final Value<int> rowid;
  const MushafsCompanion({
    this.mushafId = const Value.absent(),
    this.riwayah = const Value.absent(),
    this.name = const Value.absent(),
    this.lineCount = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.checksumSha256 = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MushafsCompanion.insert({
    required String mushafId,
    required String riwayah,
    required String name,
    required int lineCount,
    required int pageCount,
    required String fontFamily,
    required String checksumSha256,
    this.rowid = const Value.absent(),
  })  : mushafId = Value(mushafId),
        riwayah = Value(riwayah),
        name = Value(name),
        lineCount = Value(lineCount),
        pageCount = Value(pageCount),
        fontFamily = Value(fontFamily),
        checksumSha256 = Value(checksumSha256);
  static Insertable<MushafRow> custom({
    Expression<String>? mushafId,
    Expression<String>? riwayah,
    Expression<String>? name,
    Expression<int>? lineCount,
    Expression<int>? pageCount,
    Expression<String>? fontFamily,
    Expression<String>? checksumSha256,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (mushafId != null) 'mushaf_id': mushafId,
      if (riwayah != null) 'riwayah': riwayah,
      if (name != null) 'name': name,
      if (lineCount != null) 'line_count': lineCount,
      if (pageCount != null) 'page_count': pageCount,
      if (fontFamily != null) 'font_family': fontFamily,
      if (checksumSha256 != null) 'checksum_sha256': checksumSha256,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MushafsCompanion copyWith(
      {Value<String>? mushafId,
      Value<String>? riwayah,
      Value<String>? name,
      Value<int>? lineCount,
      Value<int>? pageCount,
      Value<String>? fontFamily,
      Value<String>? checksumSha256,
      Value<int>? rowid}) {
    return MushafsCompanion(
      mushafId: mushafId ?? this.mushafId,
      riwayah: riwayah ?? this.riwayah,
      name: name ?? this.name,
      lineCount: lineCount ?? this.lineCount,
      pageCount: pageCount ?? this.pageCount,
      fontFamily: fontFamily ?? this.fontFamily,
      checksumSha256: checksumSha256 ?? this.checksumSha256,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (mushafId.present) {
      map['mushaf_id'] = Variable<String>(mushafId.value);
    }
    if (riwayah.present) {
      map['riwayah'] = Variable<String>(riwayah.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lineCount.present) {
      map['line_count'] = Variable<int>(lineCount.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (checksumSha256.present) {
      map['checksum_sha256'] = Variable<String>(checksumSha256.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MushafsCompanion(')
          ..write('mushafId: $mushafId, ')
          ..write('riwayah: $riwayah, ')
          ..write('name: $name, ')
          ..write('lineCount: $lineCount, ')
          ..write('pageCount: $pageCount, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('checksumSha256: $checksumSha256, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SurahsTable extends Surahs with TableInfo<$SurahsTable, SurahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SurahsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _surahIdMeta =
      const VerificationMeta('surahId');
  @override
  late final GeneratedColumn<int> surahId = GeneratedColumn<int>(
      'surah_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameArMeta = const VerificationMeta('nameAr');
  @override
  late final GeneratedColumn<String> nameAr = GeneratedColumn<String>(
      'name_ar', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _revelationMeta =
      const VerificationMeta('revelation');
  @override
  late final GeneratedColumn<String> revelation = GeneratedColumn<String>(
      'revelation', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ayahCountMeta =
      const VerificationMeta('ayahCount');
  @override
  late final GeneratedColumn<int> ayahCount = GeneratedColumn<int>(
      'ayah_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _bismillahPreMeta =
      const VerificationMeta('bismillahPre');
  @override
  late final GeneratedColumn<bool> bismillahPre = GeneratedColumn<bool>(
      'bismillah_pre', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bismillah_pre" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [surahId, nameAr, revelation, ayahCount, bismillahPre];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'surah';
  @override
  VerificationContext validateIntegrity(Insertable<SurahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('surah_id')) {
      context.handle(_surahIdMeta,
          surahId.isAcceptableOrUnknown(data['surah_id']!, _surahIdMeta));
    }
    if (data.containsKey('name_ar')) {
      context.handle(_nameArMeta,
          nameAr.isAcceptableOrUnknown(data['name_ar']!, _nameArMeta));
    } else if (isInserting) {
      context.missing(_nameArMeta);
    }
    if (data.containsKey('revelation')) {
      context.handle(
          _revelationMeta,
          revelation.isAcceptableOrUnknown(
              data['revelation']!, _revelationMeta));
    } else if (isInserting) {
      context.missing(_revelationMeta);
    }
    if (data.containsKey('ayah_count')) {
      context.handle(_ayahCountMeta,
          ayahCount.isAcceptableOrUnknown(data['ayah_count']!, _ayahCountMeta));
    } else if (isInserting) {
      context.missing(_ayahCountMeta);
    }
    if (data.containsKey('bismillah_pre')) {
      context.handle(
          _bismillahPreMeta,
          bismillahPre.isAcceptableOrUnknown(
              data['bismillah_pre']!, _bismillahPreMeta));
    } else if (isInserting) {
      context.missing(_bismillahPreMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {surahId};
  @override
  SurahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SurahRow(
      surahId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_id'])!,
      nameAr: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name_ar'])!,
      revelation: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}revelation'])!,
      ayahCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_count'])!,
      bismillahPre: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}bismillah_pre'])!,
    );
  }

  @override
  $SurahsTable createAlias(String alias) {
    return $SurahsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class SurahRow extends DataClass implements Insertable<SurahRow> {
  /// The sūrah number 1–114 (PK).
  final int surahId;

  /// The Arabic name of the sūrah.
  final String nameAr;

  /// Meccan or Medinan.
  final String revelation;

  /// The number of āyāt (`> 0`).
  final int ayahCount;

  /// Whether a basmala precedes the sūrah (stored 0/1).
  final bool bismillahPre;
  const SurahRow(
      {required this.surahId,
      required this.nameAr,
      required this.revelation,
      required this.ayahCount,
      required this.bismillahPre});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['surah_id'] = Variable<int>(surahId);
    map['name_ar'] = Variable<String>(nameAr);
    map['revelation'] = Variable<String>(revelation);
    map['ayah_count'] = Variable<int>(ayahCount);
    map['bismillah_pre'] = Variable<bool>(bismillahPre);
    return map;
  }

  SurahsCompanion toCompanion(bool nullToAbsent) {
    return SurahsCompanion(
      surahId: Value(surahId),
      nameAr: Value(nameAr),
      revelation: Value(revelation),
      ayahCount: Value(ayahCount),
      bismillahPre: Value(bismillahPre),
    );
  }

  factory SurahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SurahRow(
      surahId: serializer.fromJson<int>(json['surahId']),
      nameAr: serializer.fromJson<String>(json['nameAr']),
      revelation: serializer.fromJson<String>(json['revelation']),
      ayahCount: serializer.fromJson<int>(json['ayahCount']),
      bismillahPre: serializer.fromJson<bool>(json['bismillahPre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'surahId': serializer.toJson<int>(surahId),
      'nameAr': serializer.toJson<String>(nameAr),
      'revelation': serializer.toJson<String>(revelation),
      'ayahCount': serializer.toJson<int>(ayahCount),
      'bismillahPre': serializer.toJson<bool>(bismillahPre),
    };
  }

  SurahRow copyWith(
          {int? surahId,
          String? nameAr,
          String? revelation,
          int? ayahCount,
          bool? bismillahPre}) =>
      SurahRow(
        surahId: surahId ?? this.surahId,
        nameAr: nameAr ?? this.nameAr,
        revelation: revelation ?? this.revelation,
        ayahCount: ayahCount ?? this.ayahCount,
        bismillahPre: bismillahPre ?? this.bismillahPre,
      );
  SurahRow copyWithCompanion(SurahsCompanion data) {
    return SurahRow(
      surahId: data.surahId.present ? data.surahId.value : this.surahId,
      nameAr: data.nameAr.present ? data.nameAr.value : this.nameAr,
      revelation:
          data.revelation.present ? data.revelation.value : this.revelation,
      ayahCount: data.ayahCount.present ? data.ayahCount.value : this.ayahCount,
      bismillahPre: data.bismillahPre.present
          ? data.bismillahPre.value
          : this.bismillahPre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SurahRow(')
          ..write('surahId: $surahId, ')
          ..write('nameAr: $nameAr, ')
          ..write('revelation: $revelation, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('bismillahPre: $bismillahPre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(surahId, nameAr, revelation, ayahCount, bismillahPre);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SurahRow &&
          other.surahId == this.surahId &&
          other.nameAr == this.nameAr &&
          other.revelation == this.revelation &&
          other.ayahCount == this.ayahCount &&
          other.bismillahPre == this.bismillahPre);
}

class SurahsCompanion extends UpdateCompanion<SurahRow> {
  final Value<int> surahId;
  final Value<String> nameAr;
  final Value<String> revelation;
  final Value<int> ayahCount;
  final Value<bool> bismillahPre;
  const SurahsCompanion({
    this.surahId = const Value.absent(),
    this.nameAr = const Value.absent(),
    this.revelation = const Value.absent(),
    this.ayahCount = const Value.absent(),
    this.bismillahPre = const Value.absent(),
  });
  SurahsCompanion.insert({
    this.surahId = const Value.absent(),
    required String nameAr,
    required String revelation,
    required int ayahCount,
    required bool bismillahPre,
  })  : nameAr = Value(nameAr),
        revelation = Value(revelation),
        ayahCount = Value(ayahCount),
        bismillahPre = Value(bismillahPre);
  static Insertable<SurahRow> custom({
    Expression<int>? surahId,
    Expression<String>? nameAr,
    Expression<String>? revelation,
    Expression<int>? ayahCount,
    Expression<bool>? bismillahPre,
  }) {
    return RawValuesInsertable({
      if (surahId != null) 'surah_id': surahId,
      if (nameAr != null) 'name_ar': nameAr,
      if (revelation != null) 'revelation': revelation,
      if (ayahCount != null) 'ayah_count': ayahCount,
      if (bismillahPre != null) 'bismillah_pre': bismillahPre,
    });
  }

  SurahsCompanion copyWith(
      {Value<int>? surahId,
      Value<String>? nameAr,
      Value<String>? revelation,
      Value<int>? ayahCount,
      Value<bool>? bismillahPre}) {
    return SurahsCompanion(
      surahId: surahId ?? this.surahId,
      nameAr: nameAr ?? this.nameAr,
      revelation: revelation ?? this.revelation,
      ayahCount: ayahCount ?? this.ayahCount,
      bismillahPre: bismillahPre ?? this.bismillahPre,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (surahId.present) {
      map['surah_id'] = Variable<int>(surahId.value);
    }
    if (nameAr.present) {
      map['name_ar'] = Variable<String>(nameAr.value);
    }
    if (revelation.present) {
      map['revelation'] = Variable<String>(revelation.value);
    }
    if (ayahCount.present) {
      map['ayah_count'] = Variable<int>(ayahCount.value);
    }
    if (bismillahPre.present) {
      map['bismillah_pre'] = Variable<bool>(bismillahPre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SurahsCompanion(')
          ..write('surahId: $surahId, ')
          ..write('nameAr: $nameAr, ')
          ..write('revelation: $revelation, ')
          ..write('ayahCount: $ayahCount, ')
          ..write('bismillahPre: $bismillahPre')
          ..write(')'))
        .toString();
  }
}

class $PagesTable extends Pages with TableInfo<$PagesTable, PageRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _juzMeta = const VerificationMeta('juz');
  @override
  late final GeneratedColumn<int> juz = GeneratedColumn<int>(
      'juz', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _hizbMeta = const VerificationMeta('hizb');
  @override
  late final GeneratedColumn<int> hizb = GeneratedColumn<int>(
      'hizb', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rubMeta = const VerificationMeta('rub');
  @override
  late final GeneratedColumn<int> rub = GeneratedColumn<int>(
      'rub', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _surahStartMeta =
      const VerificationMeta('surahStart');
  @override
  late final GeneratedColumn<int> surahStart = GeneratedColumn<int>(
      'surah_start', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surah (surah_id)'));
  static const VerificationMeta _ayahStartMeta =
      const VerificationMeta('ayahStart');
  @override
  late final GeneratedColumn<int> ayahStart = GeneratedColumn<int>(
      'ayah_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _surahEndMeta =
      const VerificationMeta('surahEnd');
  @override
  late final GeneratedColumn<int> surahEnd = GeneratedColumn<int>(
      'surah_end', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surah (surah_id)'));
  static const VerificationMeta _ayahEndMeta =
      const VerificationMeta('ayahEnd');
  @override
  late final GeneratedColumn<int> ayahEnd = GeneratedColumn<int>(
      'ayah_end', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineCountMeta =
      const VerificationMeta('lineCount');
  @override
  late final GeneratedColumn<int> lineCount = GeneratedColumn<int>(
      'line_count', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qpcFontNameMeta =
      const VerificationMeta('qpcFontName');
  @override
  late final GeneratedColumn<String> qpcFontName = GeneratedColumn<String>(
      'qpc_font_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        pageId,
        juz,
        hizb,
        rub,
        surahStart,
        ayahStart,
        surahEnd,
        ayahEnd,
        lineCount,
        qpcFontName
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'page';
  @override
  VerificationContext validateIntegrity(Insertable<PageRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    }
    if (data.containsKey('juz')) {
      context.handle(
          _juzMeta, juz.isAcceptableOrUnknown(data['juz']!, _juzMeta));
    } else if (isInserting) {
      context.missing(_juzMeta);
    }
    if (data.containsKey('hizb')) {
      context.handle(
          _hizbMeta, hizb.isAcceptableOrUnknown(data['hizb']!, _hizbMeta));
    } else if (isInserting) {
      context.missing(_hizbMeta);
    }
    if (data.containsKey('rub')) {
      context.handle(
          _rubMeta, rub.isAcceptableOrUnknown(data['rub']!, _rubMeta));
    } else if (isInserting) {
      context.missing(_rubMeta);
    }
    if (data.containsKey('surah_start')) {
      context.handle(
          _surahStartMeta,
          surahStart.isAcceptableOrUnknown(
              data['surah_start']!, _surahStartMeta));
    } else if (isInserting) {
      context.missing(_surahStartMeta);
    }
    if (data.containsKey('ayah_start')) {
      context.handle(_ayahStartMeta,
          ayahStart.isAcceptableOrUnknown(data['ayah_start']!, _ayahStartMeta));
    } else if (isInserting) {
      context.missing(_ayahStartMeta);
    }
    if (data.containsKey('surah_end')) {
      context.handle(_surahEndMeta,
          surahEnd.isAcceptableOrUnknown(data['surah_end']!, _surahEndMeta));
    } else if (isInserting) {
      context.missing(_surahEndMeta);
    }
    if (data.containsKey('ayah_end')) {
      context.handle(_ayahEndMeta,
          ayahEnd.isAcceptableOrUnknown(data['ayah_end']!, _ayahEndMeta));
    } else if (isInserting) {
      context.missing(_ayahEndMeta);
    }
    if (data.containsKey('line_count')) {
      context.handle(_lineCountMeta,
          lineCount.isAcceptableOrUnknown(data['line_count']!, _lineCountMeta));
    } else if (isInserting) {
      context.missing(_lineCountMeta);
    }
    if (data.containsKey('qpc_font_name')) {
      context.handle(
          _qpcFontNameMeta,
          qpcFontName.isAcceptableOrUnknown(
              data['qpc_font_name']!, _qpcFontNameMeta));
    } else if (isInserting) {
      context.missing(_qpcFontNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {pageId};
  @override
  PageRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PageRow(
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      juz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}juz'])!,
      hizb: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}hizb'])!,
      rub: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}rub'])!,
      surahStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_start'])!,
      ayahStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_start'])!,
      surahEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah_end'])!,
      ayahEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah_end'])!,
      lineCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_count'])!,
      qpcFontName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}qpc_font_name'])!,
    );
  }

  @override
  $PagesTable createAlias(String alias) {
    return $PagesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class PageRow extends DataClass implements Insertable<PageRow> {
  /// The page number 1–604 (PK).
  final int pageId;

  /// The juz (1–30).
  final int juz;

  /// The ḥizb (1–60).
  final int hizb;

  /// The rub' (1–240).
  final int rub;

  /// The sūrah the page starts in (FK into `surah`).
  final int surahStart;

  /// The first āyah on the page.
  final int ayahStart;

  /// The sūrah the page ends in (FK into `surah`).
  final int surahEnd;

  /// The last āyah on the page.
  final int ayahEnd;

  /// The number of lines on the page.
  final int lineCount;

  /// This page's dedicated KFGQPC glyph-font family (§08).
  final String qpcFontName;
  const PageRow(
      {required this.pageId,
      required this.juz,
      required this.hizb,
      required this.rub,
      required this.surahStart,
      required this.ayahStart,
      required this.surahEnd,
      required this.ayahEnd,
      required this.lineCount,
      required this.qpcFontName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['page_id'] = Variable<int>(pageId);
    map['juz'] = Variable<int>(juz);
    map['hizb'] = Variable<int>(hizb);
    map['rub'] = Variable<int>(rub);
    map['surah_start'] = Variable<int>(surahStart);
    map['ayah_start'] = Variable<int>(ayahStart);
    map['surah_end'] = Variable<int>(surahEnd);
    map['ayah_end'] = Variable<int>(ayahEnd);
    map['line_count'] = Variable<int>(lineCount);
    map['qpc_font_name'] = Variable<String>(qpcFontName);
    return map;
  }

  PagesCompanion toCompanion(bool nullToAbsent) {
    return PagesCompanion(
      pageId: Value(pageId),
      juz: Value(juz),
      hizb: Value(hizb),
      rub: Value(rub),
      surahStart: Value(surahStart),
      ayahStart: Value(ayahStart),
      surahEnd: Value(surahEnd),
      ayahEnd: Value(ayahEnd),
      lineCount: Value(lineCount),
      qpcFontName: Value(qpcFontName),
    );
  }

  factory PageRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PageRow(
      pageId: serializer.fromJson<int>(json['pageId']),
      juz: serializer.fromJson<int>(json['juz']),
      hizb: serializer.fromJson<int>(json['hizb']),
      rub: serializer.fromJson<int>(json['rub']),
      surahStart: serializer.fromJson<int>(json['surahStart']),
      ayahStart: serializer.fromJson<int>(json['ayahStart']),
      surahEnd: serializer.fromJson<int>(json['surahEnd']),
      ayahEnd: serializer.fromJson<int>(json['ayahEnd']),
      lineCount: serializer.fromJson<int>(json['lineCount']),
      qpcFontName: serializer.fromJson<String>(json['qpcFontName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'pageId': serializer.toJson<int>(pageId),
      'juz': serializer.toJson<int>(juz),
      'hizb': serializer.toJson<int>(hizb),
      'rub': serializer.toJson<int>(rub),
      'surahStart': serializer.toJson<int>(surahStart),
      'ayahStart': serializer.toJson<int>(ayahStart),
      'surahEnd': serializer.toJson<int>(surahEnd),
      'ayahEnd': serializer.toJson<int>(ayahEnd),
      'lineCount': serializer.toJson<int>(lineCount),
      'qpcFontName': serializer.toJson<String>(qpcFontName),
    };
  }

  PageRow copyWith(
          {int? pageId,
          int? juz,
          int? hizb,
          int? rub,
          int? surahStart,
          int? ayahStart,
          int? surahEnd,
          int? ayahEnd,
          int? lineCount,
          String? qpcFontName}) =>
      PageRow(
        pageId: pageId ?? this.pageId,
        juz: juz ?? this.juz,
        hizb: hizb ?? this.hizb,
        rub: rub ?? this.rub,
        surahStart: surahStart ?? this.surahStart,
        ayahStart: ayahStart ?? this.ayahStart,
        surahEnd: surahEnd ?? this.surahEnd,
        ayahEnd: ayahEnd ?? this.ayahEnd,
        lineCount: lineCount ?? this.lineCount,
        qpcFontName: qpcFontName ?? this.qpcFontName,
      );
  PageRow copyWithCompanion(PagesCompanion data) {
    return PageRow(
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      juz: data.juz.present ? data.juz.value : this.juz,
      hizb: data.hizb.present ? data.hizb.value : this.hizb,
      rub: data.rub.present ? data.rub.value : this.rub,
      surahStart:
          data.surahStart.present ? data.surahStart.value : this.surahStart,
      ayahStart: data.ayahStart.present ? data.ayahStart.value : this.ayahStart,
      surahEnd: data.surahEnd.present ? data.surahEnd.value : this.surahEnd,
      ayahEnd: data.ayahEnd.present ? data.ayahEnd.value : this.ayahEnd,
      lineCount: data.lineCount.present ? data.lineCount.value : this.lineCount,
      qpcFontName:
          data.qpcFontName.present ? data.qpcFontName.value : this.qpcFontName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PageRow(')
          ..write('pageId: $pageId, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rub: $rub, ')
          ..write('surahStart: $surahStart, ')
          ..write('ayahStart: $ayahStart, ')
          ..write('surahEnd: $surahEnd, ')
          ..write('ayahEnd: $ayahEnd, ')
          ..write('lineCount: $lineCount, ')
          ..write('qpcFontName: $qpcFontName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(pageId, juz, hizb, rub, surahStart, ayahStart,
      surahEnd, ayahEnd, lineCount, qpcFontName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PageRow &&
          other.pageId == this.pageId &&
          other.juz == this.juz &&
          other.hizb == this.hizb &&
          other.rub == this.rub &&
          other.surahStart == this.surahStart &&
          other.ayahStart == this.ayahStart &&
          other.surahEnd == this.surahEnd &&
          other.ayahEnd == this.ayahEnd &&
          other.lineCount == this.lineCount &&
          other.qpcFontName == this.qpcFontName);
}

class PagesCompanion extends UpdateCompanion<PageRow> {
  final Value<int> pageId;
  final Value<int> juz;
  final Value<int> hizb;
  final Value<int> rub;
  final Value<int> surahStart;
  final Value<int> ayahStart;
  final Value<int> surahEnd;
  final Value<int> ayahEnd;
  final Value<int> lineCount;
  final Value<String> qpcFontName;
  const PagesCompanion({
    this.pageId = const Value.absent(),
    this.juz = const Value.absent(),
    this.hizb = const Value.absent(),
    this.rub = const Value.absent(),
    this.surahStart = const Value.absent(),
    this.ayahStart = const Value.absent(),
    this.surahEnd = const Value.absent(),
    this.ayahEnd = const Value.absent(),
    this.lineCount = const Value.absent(),
    this.qpcFontName = const Value.absent(),
  });
  PagesCompanion.insert({
    this.pageId = const Value.absent(),
    required int juz,
    required int hizb,
    required int rub,
    required int surahStart,
    required int ayahStart,
    required int surahEnd,
    required int ayahEnd,
    required int lineCount,
    required String qpcFontName,
  })  : juz = Value(juz),
        hizb = Value(hizb),
        rub = Value(rub),
        surahStart = Value(surahStart),
        ayahStart = Value(ayahStart),
        surahEnd = Value(surahEnd),
        ayahEnd = Value(ayahEnd),
        lineCount = Value(lineCount),
        qpcFontName = Value(qpcFontName);
  static Insertable<PageRow> custom({
    Expression<int>? pageId,
    Expression<int>? juz,
    Expression<int>? hizb,
    Expression<int>? rub,
    Expression<int>? surahStart,
    Expression<int>? ayahStart,
    Expression<int>? surahEnd,
    Expression<int>? ayahEnd,
    Expression<int>? lineCount,
    Expression<String>? qpcFontName,
  }) {
    return RawValuesInsertable({
      if (pageId != null) 'page_id': pageId,
      if (juz != null) 'juz': juz,
      if (hizb != null) 'hizb': hizb,
      if (rub != null) 'rub': rub,
      if (surahStart != null) 'surah_start': surahStart,
      if (ayahStart != null) 'ayah_start': ayahStart,
      if (surahEnd != null) 'surah_end': surahEnd,
      if (ayahEnd != null) 'ayah_end': ayahEnd,
      if (lineCount != null) 'line_count': lineCount,
      if (qpcFontName != null) 'qpc_font_name': qpcFontName,
    });
  }

  PagesCompanion copyWith(
      {Value<int>? pageId,
      Value<int>? juz,
      Value<int>? hizb,
      Value<int>? rub,
      Value<int>? surahStart,
      Value<int>? ayahStart,
      Value<int>? surahEnd,
      Value<int>? ayahEnd,
      Value<int>? lineCount,
      Value<String>? qpcFontName}) {
    return PagesCompanion(
      pageId: pageId ?? this.pageId,
      juz: juz ?? this.juz,
      hizb: hizb ?? this.hizb,
      rub: rub ?? this.rub,
      surahStart: surahStart ?? this.surahStart,
      ayahStart: ayahStart ?? this.ayahStart,
      surahEnd: surahEnd ?? this.surahEnd,
      ayahEnd: ayahEnd ?? this.ayahEnd,
      lineCount: lineCount ?? this.lineCount,
      qpcFontName: qpcFontName ?? this.qpcFontName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (juz.present) {
      map['juz'] = Variable<int>(juz.value);
    }
    if (hizb.present) {
      map['hizb'] = Variable<int>(hizb.value);
    }
    if (rub.present) {
      map['rub'] = Variable<int>(rub.value);
    }
    if (surahStart.present) {
      map['surah_start'] = Variable<int>(surahStart.value);
    }
    if (ayahStart.present) {
      map['ayah_start'] = Variable<int>(ayahStart.value);
    }
    if (surahEnd.present) {
      map['surah_end'] = Variable<int>(surahEnd.value);
    }
    if (ayahEnd.present) {
      map['ayah_end'] = Variable<int>(ayahEnd.value);
    }
    if (lineCount.present) {
      map['line_count'] = Variable<int>(lineCount.value);
    }
    if (qpcFontName.present) {
      map['qpc_font_name'] = Variable<String>(qpcFontName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PagesCompanion(')
          ..write('pageId: $pageId, ')
          ..write('juz: $juz, ')
          ..write('hizb: $hizb, ')
          ..write('rub: $rub, ')
          ..write('surahStart: $surahStart, ')
          ..write('ayahStart: $ayahStart, ')
          ..write('surahEnd: $surahEnd, ')
          ..write('ayahEnd: $ayahEnd, ')
          ..write('lineCount: $lineCount, ')
          ..write('qpcFontName: $qpcFontName')
          ..write(')'))
        .toString();
  }
}

class $LinesTable extends Lines with TableInfo<$LinesTable, LineRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _lineIdMeta = const VerificationMeta('lineId');
  @override
  late final GeneratedColumn<int> lineId = GeneratedColumn<int>(
      'line_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES page (page_id)'));
  static const VerificationMeta _lineNoMeta = const VerificationMeta('lineNo');
  @override
  late final GeneratedColumn<int> lineNo = GeneratedColumn<int>(
      'line_no', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineTypeMeta =
      const VerificationMeta('lineType');
  @override
  late final GeneratedColumn<String> lineType = GeneratedColumn<String>(
      'line_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ayahRefsJsonMeta =
      const VerificationMeta('ayahRefsJson');
  @override
  late final GeneratedColumn<String> ayahRefsJson = GeneratedColumn<String>(
      'ayah_refs_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _textGlyphRefMeta =
      const VerificationMeta('textGlyphRef');
  @override
  late final GeneratedColumn<String> textGlyphRef = GeneratedColumn<String>(
      'text_glyph_ref', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [lineId, pageId, lineNo, lineType, ayahRefsJson, textGlyphRef];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line';
  @override
  VerificationContext validateIntegrity(Insertable<LineRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('line_id')) {
      context.handle(_lineIdMeta,
          lineId.isAcceptableOrUnknown(data['line_id']!, _lineIdMeta));
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('line_no')) {
      context.handle(_lineNoMeta,
          lineNo.isAcceptableOrUnknown(data['line_no']!, _lineNoMeta));
    } else if (isInserting) {
      context.missing(_lineNoMeta);
    }
    if (data.containsKey('line_type')) {
      context.handle(_lineTypeMeta,
          lineType.isAcceptableOrUnknown(data['line_type']!, _lineTypeMeta));
    } else if (isInserting) {
      context.missing(_lineTypeMeta);
    }
    if (data.containsKey('ayah_refs_json')) {
      context.handle(
          _ayahRefsJsonMeta,
          ayahRefsJson.isAcceptableOrUnknown(
              data['ayah_refs_json']!, _ayahRefsJsonMeta));
    } else if (isInserting) {
      context.missing(_ayahRefsJsonMeta);
    }
    if (data.containsKey('text_glyph_ref')) {
      context.handle(
          _textGlyphRefMeta,
          textGlyphRef.isAcceptableOrUnknown(
              data['text_glyph_ref']!, _textGlyphRefMeta));
    } else if (isInserting) {
      context.missing(_textGlyphRefMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {lineId};
  @override
  LineRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineRow(
      lineId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_id'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      lineNo: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_no'])!,
      lineType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_type'])!,
      ayahRefsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ayah_refs_json'])!,
      textGlyphRef: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}text_glyph_ref'])!,
    );
  }

  @override
  $LinesTable createAlias(String alias) {
    return $LinesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class LineRow extends DataClass implements Insertable<LineRow> {
  /// The line's stable id (PK).
  final int lineId;

  /// The page this line is on (FK into `page`).
  final int pageId;

  /// The line number on the page (1–15).
  final int lineNo;

  /// What the line holds (`ayah` / `surah_header` / `basmala`).
  final String lineType;

  /// Which āyāt occupy this line — small structural refs, never text.
  final String ayahRefsJson;

  /// Opaque glyph-code reference — never parsed as Quran text (R1).
  final String textGlyphRef;
  const LineRow(
      {required this.lineId,
      required this.pageId,
      required this.lineNo,
      required this.lineType,
      required this.ayahRefsJson,
      required this.textGlyphRef});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['line_id'] = Variable<int>(lineId);
    map['page_id'] = Variable<int>(pageId);
    map['line_no'] = Variable<int>(lineNo);
    map['line_type'] = Variable<String>(lineType);
    map['ayah_refs_json'] = Variable<String>(ayahRefsJson);
    map['text_glyph_ref'] = Variable<String>(textGlyphRef);
    return map;
  }

  LinesCompanion toCompanion(bool nullToAbsent) {
    return LinesCompanion(
      lineId: Value(lineId),
      pageId: Value(pageId),
      lineNo: Value(lineNo),
      lineType: Value(lineType),
      ayahRefsJson: Value(ayahRefsJson),
      textGlyphRef: Value(textGlyphRef),
    );
  }

  factory LineRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineRow(
      lineId: serializer.fromJson<int>(json['lineId']),
      pageId: serializer.fromJson<int>(json['pageId']),
      lineNo: serializer.fromJson<int>(json['lineNo']),
      lineType: serializer.fromJson<String>(json['lineType']),
      ayahRefsJson: serializer.fromJson<String>(json['ayahRefsJson']),
      textGlyphRef: serializer.fromJson<String>(json['textGlyphRef']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'lineId': serializer.toJson<int>(lineId),
      'pageId': serializer.toJson<int>(pageId),
      'lineNo': serializer.toJson<int>(lineNo),
      'lineType': serializer.toJson<String>(lineType),
      'ayahRefsJson': serializer.toJson<String>(ayahRefsJson),
      'textGlyphRef': serializer.toJson<String>(textGlyphRef),
    };
  }

  LineRow copyWith(
          {int? lineId,
          int? pageId,
          int? lineNo,
          String? lineType,
          String? ayahRefsJson,
          String? textGlyphRef}) =>
      LineRow(
        lineId: lineId ?? this.lineId,
        pageId: pageId ?? this.pageId,
        lineNo: lineNo ?? this.lineNo,
        lineType: lineType ?? this.lineType,
        ayahRefsJson: ayahRefsJson ?? this.ayahRefsJson,
        textGlyphRef: textGlyphRef ?? this.textGlyphRef,
      );
  LineRow copyWithCompanion(LinesCompanion data) {
    return LineRow(
      lineId: data.lineId.present ? data.lineId.value : this.lineId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      lineNo: data.lineNo.present ? data.lineNo.value : this.lineNo,
      lineType: data.lineType.present ? data.lineType.value : this.lineType,
      ayahRefsJson: data.ayahRefsJson.present
          ? data.ayahRefsJson.value
          : this.ayahRefsJson,
      textGlyphRef: data.textGlyphRef.present
          ? data.textGlyphRef.value
          : this.textGlyphRef,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineRow(')
          ..write('lineId: $lineId, ')
          ..write('pageId: $pageId, ')
          ..write('lineNo: $lineNo, ')
          ..write('lineType: $lineType, ')
          ..write('ayahRefsJson: $ayahRefsJson, ')
          ..write('textGlyphRef: $textGlyphRef')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(lineId, pageId, lineNo, lineType, ayahRefsJson, textGlyphRef);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineRow &&
          other.lineId == this.lineId &&
          other.pageId == this.pageId &&
          other.lineNo == this.lineNo &&
          other.lineType == this.lineType &&
          other.ayahRefsJson == this.ayahRefsJson &&
          other.textGlyphRef == this.textGlyphRef);
}

class LinesCompanion extends UpdateCompanion<LineRow> {
  final Value<int> lineId;
  final Value<int> pageId;
  final Value<int> lineNo;
  final Value<String> lineType;
  final Value<String> ayahRefsJson;
  final Value<String> textGlyphRef;
  const LinesCompanion({
    this.lineId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.lineNo = const Value.absent(),
    this.lineType = const Value.absent(),
    this.ayahRefsJson = const Value.absent(),
    this.textGlyphRef = const Value.absent(),
  });
  LinesCompanion.insert({
    this.lineId = const Value.absent(),
    required int pageId,
    required int lineNo,
    required String lineType,
    required String ayahRefsJson,
    required String textGlyphRef,
  })  : pageId = Value(pageId),
        lineNo = Value(lineNo),
        lineType = Value(lineType),
        ayahRefsJson = Value(ayahRefsJson),
        textGlyphRef = Value(textGlyphRef);
  static Insertable<LineRow> custom({
    Expression<int>? lineId,
    Expression<int>? pageId,
    Expression<int>? lineNo,
    Expression<String>? lineType,
    Expression<String>? ayahRefsJson,
    Expression<String>? textGlyphRef,
  }) {
    return RawValuesInsertable({
      if (lineId != null) 'line_id': lineId,
      if (pageId != null) 'page_id': pageId,
      if (lineNo != null) 'line_no': lineNo,
      if (lineType != null) 'line_type': lineType,
      if (ayahRefsJson != null) 'ayah_refs_json': ayahRefsJson,
      if (textGlyphRef != null) 'text_glyph_ref': textGlyphRef,
    });
  }

  LinesCompanion copyWith(
      {Value<int>? lineId,
      Value<int>? pageId,
      Value<int>? lineNo,
      Value<String>? lineType,
      Value<String>? ayahRefsJson,
      Value<String>? textGlyphRef}) {
    return LinesCompanion(
      lineId: lineId ?? this.lineId,
      pageId: pageId ?? this.pageId,
      lineNo: lineNo ?? this.lineNo,
      lineType: lineType ?? this.lineType,
      ayahRefsJson: ayahRefsJson ?? this.ayahRefsJson,
      textGlyphRef: textGlyphRef ?? this.textGlyphRef,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (lineId.present) {
      map['line_id'] = Variable<int>(lineId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (lineNo.present) {
      map['line_no'] = Variable<int>(lineNo.value);
    }
    if (lineType.present) {
      map['line_type'] = Variable<String>(lineType.value);
    }
    if (ayahRefsJson.present) {
      map['ayah_refs_json'] = Variable<String>(ayahRefsJson.value);
    }
    if (textGlyphRef.present) {
      map['text_glyph_ref'] = Variable<String>(textGlyphRef.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LinesCompanion(')
          ..write('lineId: $lineId, ')
          ..write('pageId: $pageId, ')
          ..write('lineNo: $lineNo, ')
          ..write('lineType: $lineType, ')
          ..write('ayahRefsJson: $ayahRefsJson, ')
          ..write('textGlyphRef: $textGlyphRef')
          ..write(')'))
        .toString();
  }
}

class $AyatTable extends Ayat with TableInfo<$AyatTable, AyahRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AyatTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<String> ayahId = GeneratedColumn<String>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _surahMeta = const VerificationMeta('surah');
  @override
  late final GeneratedColumn<int> surah = GeneratedColumn<int>(
      'surah', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES surah (surah_id)'));
  static const VerificationMeta _ayahMeta = const VerificationMeta('ayah');
  @override
  late final GeneratedColumn<int> ayah = GeneratedColumn<int>(
      'ayah', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES page (page_id)'));
  static const VerificationMeta _lineRefsJsonMeta =
      const VerificationMeta('lineRefsJson');
  @override
  late final GeneratedColumn<String> lineRefsJson = GeneratedColumn<String>(
      'line_refs_json', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _sajdaMeta = const VerificationMeta('sajda');
  @override
  late final GeneratedColumn<bool> sajda = GeneratedColumn<bool>(
      'sajda', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("sajda" IN (0, 1))'));
  @override
  List<GeneratedColumn> get $columns =>
      [ayahId, surah, ayah, pageId, lineRefsJson, sajda];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ayah';
  @override
  VerificationContext validateIntegrity(Insertable<AyahRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('surah')) {
      context.handle(
          _surahMeta, surah.isAcceptableOrUnknown(data['surah']!, _surahMeta));
    } else if (isInserting) {
      context.missing(_surahMeta);
    }
    if (data.containsKey('ayah')) {
      context.handle(
          _ayahMeta, ayah.isAcceptableOrUnknown(data['ayah']!, _ayahMeta));
    } else if (isInserting) {
      context.missing(_ayahMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('line_refs_json')) {
      context.handle(
          _lineRefsJsonMeta,
          lineRefsJson.isAcceptableOrUnknown(
              data['line_refs_json']!, _lineRefsJsonMeta));
    } else if (isInserting) {
      context.missing(_lineRefsJsonMeta);
    }
    if (data.containsKey('sajda')) {
      context.handle(
          _sajdaMeta, sajda.isAcceptableOrUnknown(data['sajda']!, _sajdaMeta));
    } else if (isInserting) {
      context.missing(_sajdaMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ayahId};
  @override
  AyahRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AyahRow(
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ayah_id'])!,
      surah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}surah'])!,
      ayah: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ayah'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      lineRefsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}line_refs_json'])!,
      sajda: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}sajda'])!,
    );
  }

  @override
  $AyatTable createAlias(String alias) {
    return $AyatTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class AyahRow extends DataClass implements Insertable<AyahRow> {
  /// The `'surah:ayah'` id, e.g. `'2:255'` (PK).
  final String ayahId;

  /// The sūrah number (FK into `surah`).
  final int surah;

  /// The āyah number within its sūrah.
  final int ayah;

  /// The page this āyah falls on (FK into `page`).
  final int pageId;

  /// Which lines this āyah occupies — small structural refs.
  final String lineRefsJson;

  /// Whether this is a sajda āyah (stored 0/1).
  final bool sajda;
  const AyahRow(
      {required this.ayahId,
      required this.surah,
      required this.ayah,
      required this.pageId,
      required this.lineRefsJson,
      required this.sajda});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['ayah_id'] = Variable<String>(ayahId);
    map['surah'] = Variable<int>(surah);
    map['ayah'] = Variable<int>(ayah);
    map['page_id'] = Variable<int>(pageId);
    map['line_refs_json'] = Variable<String>(lineRefsJson);
    map['sajda'] = Variable<bool>(sajda);
    return map;
  }

  AyatCompanion toCompanion(bool nullToAbsent) {
    return AyatCompanion(
      ayahId: Value(ayahId),
      surah: Value(surah),
      ayah: Value(ayah),
      pageId: Value(pageId),
      lineRefsJson: Value(lineRefsJson),
      sajda: Value(sajda),
    );
  }

  factory AyahRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AyahRow(
      ayahId: serializer.fromJson<String>(json['ayahId']),
      surah: serializer.fromJson<int>(json['surah']),
      ayah: serializer.fromJson<int>(json['ayah']),
      pageId: serializer.fromJson<int>(json['pageId']),
      lineRefsJson: serializer.fromJson<String>(json['lineRefsJson']),
      sajda: serializer.fromJson<bool>(json['sajda']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ayahId': serializer.toJson<String>(ayahId),
      'surah': serializer.toJson<int>(surah),
      'ayah': serializer.toJson<int>(ayah),
      'pageId': serializer.toJson<int>(pageId),
      'lineRefsJson': serializer.toJson<String>(lineRefsJson),
      'sajda': serializer.toJson<bool>(sajda),
    };
  }

  AyahRow copyWith(
          {String? ayahId,
          int? surah,
          int? ayah,
          int? pageId,
          String? lineRefsJson,
          bool? sajda}) =>
      AyahRow(
        ayahId: ayahId ?? this.ayahId,
        surah: surah ?? this.surah,
        ayah: ayah ?? this.ayah,
        pageId: pageId ?? this.pageId,
        lineRefsJson: lineRefsJson ?? this.lineRefsJson,
        sajda: sajda ?? this.sajda,
      );
  AyahRow copyWithCompanion(AyatCompanion data) {
    return AyahRow(
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      surah: data.surah.present ? data.surah.value : this.surah,
      ayah: data.ayah.present ? data.ayah.value : this.ayah,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      lineRefsJson: data.lineRefsJson.present
          ? data.lineRefsJson.value
          : this.lineRefsJson,
      sajda: data.sajda.present ? data.sajda.value : this.sajda,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AyahRow(')
          ..write('ayahId: $ayahId, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('pageId: $pageId, ')
          ..write('lineRefsJson: $lineRefsJson, ')
          ..write('sajda: $sajda')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(ayahId, surah, ayah, pageId, lineRefsJson, sajda);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AyahRow &&
          other.ayahId == this.ayahId &&
          other.surah == this.surah &&
          other.ayah == this.ayah &&
          other.pageId == this.pageId &&
          other.lineRefsJson == this.lineRefsJson &&
          other.sajda == this.sajda);
}

class AyatCompanion extends UpdateCompanion<AyahRow> {
  final Value<String> ayahId;
  final Value<int> surah;
  final Value<int> ayah;
  final Value<int> pageId;
  final Value<String> lineRefsJson;
  final Value<bool> sajda;
  final Value<int> rowid;
  const AyatCompanion({
    this.ayahId = const Value.absent(),
    this.surah = const Value.absent(),
    this.ayah = const Value.absent(),
    this.pageId = const Value.absent(),
    this.lineRefsJson = const Value.absent(),
    this.sajda = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AyatCompanion.insert({
    required String ayahId,
    required int surah,
    required int ayah,
    required int pageId,
    required String lineRefsJson,
    required bool sajda,
    this.rowid = const Value.absent(),
  })  : ayahId = Value(ayahId),
        surah = Value(surah),
        ayah = Value(ayah),
        pageId = Value(pageId),
        lineRefsJson = Value(lineRefsJson),
        sajda = Value(sajda);
  static Insertable<AyahRow> custom({
    Expression<String>? ayahId,
    Expression<int>? surah,
    Expression<int>? ayah,
    Expression<int>? pageId,
    Expression<String>? lineRefsJson,
    Expression<bool>? sajda,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ayahId != null) 'ayah_id': ayahId,
      if (surah != null) 'surah': surah,
      if (ayah != null) 'ayah': ayah,
      if (pageId != null) 'page_id': pageId,
      if (lineRefsJson != null) 'line_refs_json': lineRefsJson,
      if (sajda != null) 'sajda': sajda,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AyatCompanion copyWith(
      {Value<String>? ayahId,
      Value<int>? surah,
      Value<int>? ayah,
      Value<int>? pageId,
      Value<String>? lineRefsJson,
      Value<bool>? sajda,
      Value<int>? rowid}) {
    return AyatCompanion(
      ayahId: ayahId ?? this.ayahId,
      surah: surah ?? this.surah,
      ayah: ayah ?? this.ayah,
      pageId: pageId ?? this.pageId,
      lineRefsJson: lineRefsJson ?? this.lineRefsJson,
      sajda: sajda ?? this.sajda,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ayahId.present) {
      map['ayah_id'] = Variable<String>(ayahId.value);
    }
    if (surah.present) {
      map['surah'] = Variable<int>(surah.value);
    }
    if (ayah.present) {
      map['ayah'] = Variable<int>(ayah.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (lineRefsJson.present) {
      map['line_refs_json'] = Variable<String>(lineRefsJson.value);
    }
    if (sajda.present) {
      map['sajda'] = Variable<bool>(sajda.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AyatCompanion(')
          ..write('ayahId: $ayahId, ')
          ..write('surah: $surah, ')
          ..write('ayah: $ayah, ')
          ..write('pageId: $pageId, ')
          ..write('lineRefsJson: $lineRefsJson, ')
          ..write('sajda: $sajda, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MutashabihGroupsTable extends MutashabihGroups
    with TableInfo<$MutashabihGroupsTable, MutashabihGroupRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MutashabihGroupsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteKeyMeta =
      const VerificationMeta('noteKey');
  @override
  late final GeneratedColumn<String> noteKey = GeneratedColumn<String>(
      'note_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [groupId, type, noteKey];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mutashabih_group';
  @override
  VerificationContext validateIntegrity(Insertable<MutashabihGroupRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('note_key')) {
      context.handle(_noteKeyMeta,
          noteKey.isAcceptableOrUnknown(data['note_key']!, _noteKeyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId};
  @override
  MutashabihGroupRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MutashabihGroupRow(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      noteKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note_key']),
    );
  }

  @override
  $MutashabihGroupsTable createAlias(String alias) {
    return $MutashabihGroupsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MutashabihGroupRow extends DataClass
    implements Insertable<MutashabihGroupRow> {
  /// The group's stable id (PK).
  final String groupId;

  /// The kind of similarity (`identical` / `near_identical` / `structural`).
  final String type;

  /// An optional localizable note resource key (a key into `l10n`), or null.
  final String? noteKey;
  const MutashabihGroupRow(
      {required this.groupId, required this.type, this.noteKey});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || noteKey != null) {
      map['note_key'] = Variable<String>(noteKey);
    }
    return map;
  }

  MutashabihGroupsCompanion toCompanion(bool nullToAbsent) {
    return MutashabihGroupsCompanion(
      groupId: Value(groupId),
      type: Value(type),
      noteKey: noteKey == null && nullToAbsent
          ? const Value.absent()
          : Value(noteKey),
    );
  }

  factory MutashabihGroupRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MutashabihGroupRow(
      groupId: serializer.fromJson<String>(json['groupId']),
      type: serializer.fromJson<String>(json['type']),
      noteKey: serializer.fromJson<String?>(json['noteKey']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'type': serializer.toJson<String>(type),
      'noteKey': serializer.toJson<String?>(noteKey),
    };
  }

  MutashabihGroupRow copyWith(
          {String? groupId,
          String? type,
          Value<String?> noteKey = const Value.absent()}) =>
      MutashabihGroupRow(
        groupId: groupId ?? this.groupId,
        type: type ?? this.type,
        noteKey: noteKey.present ? noteKey.value : this.noteKey,
      );
  MutashabihGroupRow copyWithCompanion(MutashabihGroupsCompanion data) {
    return MutashabihGroupRow(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      type: data.type.present ? data.type.value : this.type,
      noteKey: data.noteKey.present ? data.noteKey.value : this.noteKey,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MutashabihGroupRow(')
          ..write('groupId: $groupId, ')
          ..write('type: $type, ')
          ..write('noteKey: $noteKey')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, type, noteKey);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MutashabihGroupRow &&
          other.groupId == this.groupId &&
          other.type == this.type &&
          other.noteKey == this.noteKey);
}

class MutashabihGroupsCompanion extends UpdateCompanion<MutashabihGroupRow> {
  final Value<String> groupId;
  final Value<String> type;
  final Value<String?> noteKey;
  final Value<int> rowid;
  const MutashabihGroupsCompanion({
    this.groupId = const Value.absent(),
    this.type = const Value.absent(),
    this.noteKey = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MutashabihGroupsCompanion.insert({
    required String groupId,
    required String type,
    this.noteKey = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        type = Value(type);
  static Insertable<MutashabihGroupRow> custom({
    Expression<String>? groupId,
    Expression<String>? type,
    Expression<String>? noteKey,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (type != null) 'type': type,
      if (noteKey != null) 'note_key': noteKey,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MutashabihGroupsCompanion copyWith(
      {Value<String>? groupId,
      Value<String>? type,
      Value<String?>? noteKey,
      Value<int>? rowid}) {
    return MutashabihGroupsCompanion(
      groupId: groupId ?? this.groupId,
      type: type ?? this.type,
      noteKey: noteKey ?? this.noteKey,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (noteKey.present) {
      map['note_key'] = Variable<String>(noteKey.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MutashabihGroupsCompanion(')
          ..write('groupId: $groupId, ')
          ..write('type: $type, ')
          ..write('noteKey: $noteKey, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MutashabihMembersTable extends MutashabihMembers
    with TableInfo<$MutashabihMembersTable, MutashabihMemberRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MutashabihMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<String> groupId = GeneratedColumn<String>(
      'group_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES mutashabih_group (group_id)'));
  static const VerificationMeta _ayahIdMeta = const VerificationMeta('ayahId');
  @override
  late final GeneratedColumn<String> ayahId = GeneratedColumn<String>(
      'ayah_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ayah (ayah_id)'));
  static const VerificationMeta _distinguishingWordIndexJsonMeta =
      const VerificationMeta('distinguishingWordIndexJson');
  @override
  late final GeneratedColumn<String> distinguishingWordIndexJson =
      GeneratedColumn<String>(
          'distinguishing_word_index_json', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [groupId, ayahId, distinguishingWordIndexJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mutashabih_member';
  @override
  VerificationContext validateIntegrity(
      Insertable<MutashabihMemberRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('ayah_id')) {
      context.handle(_ayahIdMeta,
          ayahId.isAcceptableOrUnknown(data['ayah_id']!, _ayahIdMeta));
    } else if (isInserting) {
      context.missing(_ayahIdMeta);
    }
    if (data.containsKey('distinguishing_word_index_json')) {
      context.handle(
          _distinguishingWordIndexJsonMeta,
          distinguishingWordIndexJson.isAcceptableOrUnknown(
              data['distinguishing_word_index_json']!,
              _distinguishingWordIndexJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {groupId, ayahId};
  @override
  MutashabihMemberRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MutashabihMemberRow(
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}group_id'])!,
      ayahId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ayah_id'])!,
      distinguishingWordIndexJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}distinguishing_word_index_json']),
    );
  }

  @override
  $MutashabihMembersTable createAlias(String alias) {
    return $MutashabihMembersTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class MutashabihMemberRow extends DataClass
    implements Insertable<MutashabihMemberRow> {
  /// The owning group (FK into `mutashabih_group`).
  final String groupId;

  /// The member āyah (FK into `ayah`).
  final String ayahId;

  /// Structural distinguishing-word indices, or null.
  final String? distinguishingWordIndexJson;
  const MutashabihMemberRow(
      {required this.groupId,
      required this.ayahId,
      this.distinguishingWordIndexJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['group_id'] = Variable<String>(groupId);
    map['ayah_id'] = Variable<String>(ayahId);
    if (!nullToAbsent || distinguishingWordIndexJson != null) {
      map['distinguishing_word_index_json'] =
          Variable<String>(distinguishingWordIndexJson);
    }
    return map;
  }

  MutashabihMembersCompanion toCompanion(bool nullToAbsent) {
    return MutashabihMembersCompanion(
      groupId: Value(groupId),
      ayahId: Value(ayahId),
      distinguishingWordIndexJson:
          distinguishingWordIndexJson == null && nullToAbsent
              ? const Value.absent()
              : Value(distinguishingWordIndexJson),
    );
  }

  factory MutashabihMemberRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MutashabihMemberRow(
      groupId: serializer.fromJson<String>(json['groupId']),
      ayahId: serializer.fromJson<String>(json['ayahId']),
      distinguishingWordIndexJson:
          serializer.fromJson<String?>(json['distinguishingWordIndexJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'groupId': serializer.toJson<String>(groupId),
      'ayahId': serializer.toJson<String>(ayahId),
      'distinguishingWordIndexJson':
          serializer.toJson<String?>(distinguishingWordIndexJson),
    };
  }

  MutashabihMemberRow copyWith(
          {String? groupId,
          String? ayahId,
          Value<String?> distinguishingWordIndexJson = const Value.absent()}) =>
      MutashabihMemberRow(
        groupId: groupId ?? this.groupId,
        ayahId: ayahId ?? this.ayahId,
        distinguishingWordIndexJson: distinguishingWordIndexJson.present
            ? distinguishingWordIndexJson.value
            : this.distinguishingWordIndexJson,
      );
  MutashabihMemberRow copyWithCompanion(MutashabihMembersCompanion data) {
    return MutashabihMemberRow(
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      ayahId: data.ayahId.present ? data.ayahId.value : this.ayahId,
      distinguishingWordIndexJson: data.distinguishingWordIndexJson.present
          ? data.distinguishingWordIndexJson.value
          : this.distinguishingWordIndexJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MutashabihMemberRow(')
          ..write('groupId: $groupId, ')
          ..write('ayahId: $ayahId, ')
          ..write('distinguishingWordIndexJson: $distinguishingWordIndexJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(groupId, ayahId, distinguishingWordIndexJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MutashabihMemberRow &&
          other.groupId == this.groupId &&
          other.ayahId == this.ayahId &&
          other.distinguishingWordIndexJson ==
              this.distinguishingWordIndexJson);
}

class MutashabihMembersCompanion extends UpdateCompanion<MutashabihMemberRow> {
  final Value<String> groupId;
  final Value<String> ayahId;
  final Value<String?> distinguishingWordIndexJson;
  final Value<int> rowid;
  const MutashabihMembersCompanion({
    this.groupId = const Value.absent(),
    this.ayahId = const Value.absent(),
    this.distinguishingWordIndexJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MutashabihMembersCompanion.insert({
    required String groupId,
    required String ayahId,
    this.distinguishingWordIndexJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : groupId = Value(groupId),
        ayahId = Value(ayahId);
  static Insertable<MutashabihMemberRow> custom({
    Expression<String>? groupId,
    Expression<String>? ayahId,
    Expression<String>? distinguishingWordIndexJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (groupId != null) 'group_id': groupId,
      if (ayahId != null) 'ayah_id': ayahId,
      if (distinguishingWordIndexJson != null)
        'distinguishing_word_index_json': distinguishingWordIndexJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MutashabihMembersCompanion copyWith(
      {Value<String>? groupId,
      Value<String>? ayahId,
      Value<String?>? distinguishingWordIndexJson,
      Value<int>? rowid}) {
    return MutashabihMembersCompanion(
      groupId: groupId ?? this.groupId,
      ayahId: ayahId ?? this.ayahId,
      distinguishingWordIndexJson:
          distinguishingWordIndexJson ?? this.distinguishingWordIndexJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (groupId.present) {
      map['group_id'] = Variable<String>(groupId.value);
    }
    if (ayahId.present) {
      map['ayah_id'] = Variable<String>(ayahId.value);
    }
    if (distinguishingWordIndexJson.present) {
      map['distinguishing_word_index_json'] =
          Variable<String>(distinguishingWordIndexJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MutashabihMembersCompanion(')
          ..write('groupId: $groupId, ')
          ..write('ayahId: $ayahId, ')
          ..write('distinguishingWordIndexJson: $distinguishingWordIndexJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$HifzDatabase extends GeneratedDatabase {
  _$HifzDatabase(QueryExecutor e) : super(e);
  $HifzDatabaseManager get managers => $HifzDatabaseManager(this);
  late final $MushafsTable mushafs = $MushafsTable(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $LinesTable lines = $LinesTable(this);
  late final $AyatTable ayat = $AyatTable(this);
  late final $MutashabihGroupsTable mutashabihGroups =
      $MutashabihGroupsTable(this);
  late final $MutashabihMembersTable mutashabihMembers =
      $MutashabihMembersTable(this);
  late final Index lineByPage = Index(
      'line_by_page', 'CREATE INDEX line_by_page ON line (page_id, line_no)');
  late final Index ayahByPage =
      Index('ayah_by_page', 'CREATE INDEX ayah_by_page ON ayah (page_id)');
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        mushafs,
        surahs,
        pages,
        lines,
        ayat,
        mutashabihGroups,
        mutashabihMembers,
        lineByPage,
        ayahByPage
      ];
}

typedef $$MushafsTableCreateCompanionBuilder = MushafsCompanion Function({
  required String mushafId,
  required String riwayah,
  required String name,
  required int lineCount,
  required int pageCount,
  required String fontFamily,
  required String checksumSha256,
  Value<int> rowid,
});
typedef $$MushafsTableUpdateCompanionBuilder = MushafsCompanion Function({
  Value<String> mushafId,
  Value<String> riwayah,
  Value<String> name,
  Value<int> lineCount,
  Value<int> pageCount,
  Value<String> fontFamily,
  Value<String> checksumSha256,
  Value<int> rowid,
});

class $$MushafsTableFilterComposer
    extends Composer<_$HifzDatabase, $MushafsTable> {
  $$MushafsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get mushafId => $composableBuilder(
      column: $table.mushafId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get riwayah => $composableBuilder(
      column: $table.riwayah, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineCount => $composableBuilder(
      column: $table.lineCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnFilters(column));
}

class $$MushafsTableOrderingComposer
    extends Composer<_$HifzDatabase, $MushafsTable> {
  $$MushafsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get mushafId => $composableBuilder(
      column: $table.mushafId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get riwayah => $composableBuilder(
      column: $table.riwayah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineCount => $composableBuilder(
      column: $table.lineCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get pageCount => $composableBuilder(
      column: $table.pageCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256,
      builder: (column) => ColumnOrderings(column));
}

class $$MushafsTableAnnotationComposer
    extends Composer<_$HifzDatabase, $MushafsTable> {
  $$MushafsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get mushafId =>
      $composableBuilder(column: $table.mushafId, builder: (column) => column);

  GeneratedColumn<String> get riwayah =>
      $composableBuilder(column: $table.riwayah, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get lineCount =>
      $composableBuilder(column: $table.lineCount, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => column);

  GeneratedColumn<String> get checksumSha256 => $composableBuilder(
      column: $table.checksumSha256, builder: (column) => column);
}

class $$MushafsTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $MushafsTable,
    MushafRow,
    $$MushafsTableFilterComposer,
    $$MushafsTableOrderingComposer,
    $$MushafsTableAnnotationComposer,
    $$MushafsTableCreateCompanionBuilder,
    $$MushafsTableUpdateCompanionBuilder,
    (MushafRow, BaseReferences<_$HifzDatabase, $MushafsTable, MushafRow>),
    MushafRow,
    PrefetchHooks Function()> {
  $$MushafsTableTableManager(_$HifzDatabase db, $MushafsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MushafsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MushafsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MushafsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> mushafId = const Value.absent(),
            Value<String> riwayah = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> lineCount = const Value.absent(),
            Value<int> pageCount = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<String> checksumSha256 = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MushafsCompanion(
            mushafId: mushafId,
            riwayah: riwayah,
            name: name,
            lineCount: lineCount,
            pageCount: pageCount,
            fontFamily: fontFamily,
            checksumSha256: checksumSha256,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String mushafId,
            required String riwayah,
            required String name,
            required int lineCount,
            required int pageCount,
            required String fontFamily,
            required String checksumSha256,
            Value<int> rowid = const Value.absent(),
          }) =>
              MushafsCompanion.insert(
            mushafId: mushafId,
            riwayah: riwayah,
            name: name,
            lineCount: lineCount,
            pageCount: pageCount,
            fontFamily: fontFamily,
            checksumSha256: checksumSha256,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MushafsTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $MushafsTable,
    MushafRow,
    $$MushafsTableFilterComposer,
    $$MushafsTableOrderingComposer,
    $$MushafsTableAnnotationComposer,
    $$MushafsTableCreateCompanionBuilder,
    $$MushafsTableUpdateCompanionBuilder,
    (MushafRow, BaseReferences<_$HifzDatabase, $MushafsTable, MushafRow>),
    MushafRow,
    PrefetchHooks Function()>;
typedef $$SurahsTableCreateCompanionBuilder = SurahsCompanion Function({
  Value<int> surahId,
  required String nameAr,
  required String revelation,
  required int ayahCount,
  required bool bismillahPre,
});
typedef $$SurahsTableUpdateCompanionBuilder = SurahsCompanion Function({
  Value<int> surahId,
  Value<String> nameAr,
  Value<String> revelation,
  Value<int> ayahCount,
  Value<bool> bismillahPre,
});

final class $$SurahsTableReferences
    extends BaseReferences<_$HifzDatabase, $SurahsTable, SurahRow> {
  $$SurahsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PagesTable, List<PageRow>>
      _pagesStartingInSurahTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.pages,
              aliasName:
                  $_aliasNameGenerator(db.surahs.surahId, db.pages.surahStart));

  $$PagesTableProcessedTableManager get pagesStartingInSurah {
    final manager = $$PagesTableTableManager($_db, $_db.pages).filter(
        (f) => f.surahStart.surahId.sqlEquals($_itemColumn<int>('surah_id')!));

    final cache =
        $_typedResult.readTableOrNull(_pagesStartingInSurahTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$PagesTable, List<PageRow>>
      _pagesEndingInSurahTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.pages,
              aliasName:
                  $_aliasNameGenerator(db.surahs.surahId, db.pages.surahEnd));

  $$PagesTableProcessedTableManager get pagesEndingInSurah {
    final manager = $$PagesTableTableManager($_db, $_db.pages).filter(
        (f) => f.surahEnd.surahId.sqlEquals($_itemColumn<int>('surah_id')!));

    final cache = $_typedResult.readTableOrNull(_pagesEndingInSurahTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AyatTable, List<AyahRow>> _ayatRefsTable(
          _$HifzDatabase db) =>
      MultiTypedResultKey.fromTable(db.ayat,
          aliasName: $_aliasNameGenerator(db.surahs.surahId, db.ayat.surah));

  $$AyatTableProcessedTableManager get ayatRefs {
    final manager = $$AyatTableTableManager($_db, $_db.ayat).filter(
        (f) => f.surah.surahId.sqlEquals($_itemColumn<int>('surah_id')!));

    final cache = $_typedResult.readTableOrNull(_ayatRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SurahsTableFilterComposer
    extends Composer<_$HifzDatabase, $SurahsTable> {
  $$SurahsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get surahId => $composableBuilder(
      column: $table.surahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get revelation => $composableBuilder(
      column: $table.revelation, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahCount => $composableBuilder(
      column: $table.ayahCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre, builder: (column) => ColumnFilters(column));

  Expression<bool> pagesStartingInSurah(
      Expression<bool> Function($$PagesTableFilterComposer f) f) {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.surahStart,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> pagesEndingInSurah(
      Expression<bool> Function($$PagesTableFilterComposer f) f) {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.surahEnd,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ayatRefs(
      Expression<bool> Function($$AyatTableFilterComposer f) f) {
    final $$AyatTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.surah,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableFilterComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurahsTableOrderingComposer
    extends Composer<_$HifzDatabase, $SurahsTable> {
  $$SurahsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get surahId => $composableBuilder(
      column: $table.surahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get nameAr => $composableBuilder(
      column: $table.nameAr, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get revelation => $composableBuilder(
      column: $table.revelation, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahCount => $composableBuilder(
      column: $table.ayahCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre,
      builder: (column) => ColumnOrderings(column));
}

class $$SurahsTableAnnotationComposer
    extends Composer<_$HifzDatabase, $SurahsTable> {
  $$SurahsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get surahId =>
      $composableBuilder(column: $table.surahId, builder: (column) => column);

  GeneratedColumn<String> get nameAr =>
      $composableBuilder(column: $table.nameAr, builder: (column) => column);

  GeneratedColumn<String> get revelation => $composableBuilder(
      column: $table.revelation, builder: (column) => column);

  GeneratedColumn<int> get ayahCount =>
      $composableBuilder(column: $table.ayahCount, builder: (column) => column);

  GeneratedColumn<bool> get bismillahPre => $composableBuilder(
      column: $table.bismillahPre, builder: (column) => column);

  Expression<T> pagesStartingInSurah<T extends Object>(
      Expression<T> Function($$PagesTableAnnotationComposer a) f) {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.surahStart,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> pagesEndingInSurah<T extends Object>(
      Expression<T> Function($$PagesTableAnnotationComposer a) f) {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.surahEnd,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ayatRefs<T extends Object>(
      Expression<T> Function($$AyatTableAnnotationComposer a) f) {
    final $$AyatTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.surah,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableAnnotationComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SurahsTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, $$SurahsTableReferences),
    SurahRow,
    PrefetchHooks Function(
        {bool pagesStartingInSurah, bool pagesEndingInSurah, bool ayatRefs})> {
  $$SurahsTableTableManager(_$HifzDatabase db, $SurahsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SurahsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SurahsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SurahsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> surahId = const Value.absent(),
            Value<String> nameAr = const Value.absent(),
            Value<String> revelation = const Value.absent(),
            Value<int> ayahCount = const Value.absent(),
            Value<bool> bismillahPre = const Value.absent(),
          }) =>
              SurahsCompanion(
            surahId: surahId,
            nameAr: nameAr,
            revelation: revelation,
            ayahCount: ayahCount,
            bismillahPre: bismillahPre,
          ),
          createCompanionCallback: ({
            Value<int> surahId = const Value.absent(),
            required String nameAr,
            required String revelation,
            required int ayahCount,
            required bool bismillahPre,
          }) =>
              SurahsCompanion.insert(
            surahId: surahId,
            nameAr: nameAr,
            revelation: revelation,
            ayahCount: ayahCount,
            bismillahPre: bismillahPre,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SurahsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {pagesStartingInSurah = false,
              pagesEndingInSurah = false,
              ayatRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (pagesStartingInSurah) db.pages,
                if (pagesEndingInSurah) db.pages,
                if (ayatRefs) db.ayat
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (pagesStartingInSurah)
                    await $_getPrefetchedData<SurahRow, $SurahsTable, PageRow>(
                        currentTable: table,
                        referencedTable: $$SurahsTableReferences
                            ._pagesStartingInSurahTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurahsTableReferences(db, table, p0)
                                .pagesStartingInSurah,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.surahStart == item.surahId),
                        typedResults: items),
                  if (pagesEndingInSurah)
                    await $_getPrefetchedData<SurahRow, $SurahsTable, PageRow>(
                        currentTable: table,
                        referencedTable: $$SurahsTableReferences
                            ._pagesEndingInSurahTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurahsTableReferences(db, table, p0)
                                .pagesEndingInSurah,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.surahEnd == item.surahId),
                        typedResults: items),
                  if (ayatRefs)
                    await $_getPrefetchedData<SurahRow, $SurahsTable, AyahRow>(
                        currentTable: table,
                        referencedTable:
                            $$SurahsTableReferences._ayatRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SurahsTableReferences(db, table, p0).ayatRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.surah == item.surahId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SurahsTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $SurahsTable,
    SurahRow,
    $$SurahsTableFilterComposer,
    $$SurahsTableOrderingComposer,
    $$SurahsTableAnnotationComposer,
    $$SurahsTableCreateCompanionBuilder,
    $$SurahsTableUpdateCompanionBuilder,
    (SurahRow, $$SurahsTableReferences),
    SurahRow,
    PrefetchHooks Function(
        {bool pagesStartingInSurah, bool pagesEndingInSurah, bool ayatRefs})>;
typedef $$PagesTableCreateCompanionBuilder = PagesCompanion Function({
  Value<int> pageId,
  required int juz,
  required int hizb,
  required int rub,
  required int surahStart,
  required int ayahStart,
  required int surahEnd,
  required int ayahEnd,
  required int lineCount,
  required String qpcFontName,
});
typedef $$PagesTableUpdateCompanionBuilder = PagesCompanion Function({
  Value<int> pageId,
  Value<int> juz,
  Value<int> hizb,
  Value<int> rub,
  Value<int> surahStart,
  Value<int> ayahStart,
  Value<int> surahEnd,
  Value<int> ayahEnd,
  Value<int> lineCount,
  Value<String> qpcFontName,
});

final class $$PagesTableReferences
    extends BaseReferences<_$HifzDatabase, $PagesTable, PageRow> {
  $$PagesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahsTable _surahStartTable(_$HifzDatabase db) =>
      db.surahs.createAlias(
          $_aliasNameGenerator(db.pages.surahStart, db.surahs.surahId));

  $$SurahsTableProcessedTableManager get surahStart {
    final $_column = $_itemColumn<int>('surah_start')!;

    final manager = $$SurahsTableTableManager($_db, $_db.surahs)
        .filter((f) => f.surahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahStartTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $SurahsTable _surahEndTable(_$HifzDatabase db) => db.surahs
      .createAlias($_aliasNameGenerator(db.pages.surahEnd, db.surahs.surahId));

  $$SurahsTableProcessedTableManager get surahEnd {
    final $_column = $_itemColumn<int>('surah_end')!;

    final manager = $$SurahsTableTableManager($_db, $_db.surahs)
        .filter((f) => f.surahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahEndTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$LinesTable, List<LineRow>> _linesRefsTable(
          _$HifzDatabase db) =>
      MultiTypedResultKey.fromTable(db.lines,
          aliasName: $_aliasNameGenerator(db.pages.pageId, db.lines.pageId));

  $$LinesTableProcessedTableManager get linesRefs {
    final manager = $$LinesTableTableManager($_db, $_db.lines).filter(
        (f) => f.pageId.pageId.sqlEquals($_itemColumn<int>('page_id')!));

    final cache = $_typedResult.readTableOrNull(_linesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$AyatTable, List<AyahRow>> _ayatRefsTable(
          _$HifzDatabase db) =>
      MultiTypedResultKey.fromTable(db.ayat,
          aliasName: $_aliasNameGenerator(db.pages.pageId, db.ayat.pageId));

  $$AyatTableProcessedTableManager get ayatRefs {
    final manager = $$AyatTableTableManager($_db, $_db.ayat).filter(
        (f) => f.pageId.pageId.sqlEquals($_itemColumn<int>('page_id')!));

    final cache = $_typedResult.readTableOrNull(_ayatRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$PagesTableFilterComposer extends Composer<_$HifzDatabase, $PagesTable> {
  $$PagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get pageId => $composableBuilder(
      column: $table.pageId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get rub => $composableBuilder(
      column: $table.rub, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahStart => $composableBuilder(
      column: $table.ayahStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayahEnd => $composableBuilder(
      column: $table.ayahEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineCount => $composableBuilder(
      column: $table.lineCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get qpcFontName => $composableBuilder(
      column: $table.qpcFontName, builder: (column) => ColumnFilters(column));

  $$SurahsTableFilterComposer get surahStart {
    final $$SurahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahStart,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableFilterComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SurahsTableFilterComposer get surahEnd {
    final $$SurahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahEnd,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableFilterComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> linesRefs(
      Expression<bool> Function($$LinesTableFilterComposer f) f) {
    final $$LinesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.lines,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LinesTableFilterComposer(
              $db: $db,
              $table: $db.lines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> ayatRefs(
      Expression<bool> Function($$AyatTableFilterComposer f) f) {
    final $$AyatTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableFilterComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagesTableOrderingComposer
    extends Composer<_$HifzDatabase, $PagesTable> {
  $$PagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get pageId => $composableBuilder(
      column: $table.pageId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get juz => $composableBuilder(
      column: $table.juz, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get hizb => $composableBuilder(
      column: $table.hizb, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get rub => $composableBuilder(
      column: $table.rub, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahStart => $composableBuilder(
      column: $table.ayahStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayahEnd => $composableBuilder(
      column: $table.ayahEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineCount => $composableBuilder(
      column: $table.lineCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get qpcFontName => $composableBuilder(
      column: $table.qpcFontName, builder: (column) => ColumnOrderings(column));

  $$SurahsTableOrderingComposer get surahStart {
    final $$SurahsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahStart,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableOrderingComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SurahsTableOrderingComposer get surahEnd {
    final $$SurahsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahEnd,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableOrderingComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$PagesTableAnnotationComposer
    extends Composer<_$HifzDatabase, $PagesTable> {
  $$PagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get pageId =>
      $composableBuilder(column: $table.pageId, builder: (column) => column);

  GeneratedColumn<int> get juz =>
      $composableBuilder(column: $table.juz, builder: (column) => column);

  GeneratedColumn<int> get hizb =>
      $composableBuilder(column: $table.hizb, builder: (column) => column);

  GeneratedColumn<int> get rub =>
      $composableBuilder(column: $table.rub, builder: (column) => column);

  GeneratedColumn<int> get ayahStart =>
      $composableBuilder(column: $table.ayahStart, builder: (column) => column);

  GeneratedColumn<int> get ayahEnd =>
      $composableBuilder(column: $table.ayahEnd, builder: (column) => column);

  GeneratedColumn<int> get lineCount =>
      $composableBuilder(column: $table.lineCount, builder: (column) => column);

  GeneratedColumn<String> get qpcFontName => $composableBuilder(
      column: $table.qpcFontName, builder: (column) => column);

  $$SurahsTableAnnotationComposer get surahStart {
    final $$SurahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahStart,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableAnnotationComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$SurahsTableAnnotationComposer get surahEnd {
    final $$SurahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surahEnd,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableAnnotationComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> linesRefs<T extends Object>(
      Expression<T> Function($$LinesTableAnnotationComposer a) f) {
    final $$LinesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.lines,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LinesTableAnnotationComposer(
              $db: $db,
              $table: $db.lines,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> ayatRefs<T extends Object>(
      Expression<T> Function($$AyatTableAnnotationComposer a) f) {
    final $$AyatTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableAnnotationComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$PagesTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $PagesTable,
    PageRow,
    $$PagesTableFilterComposer,
    $$PagesTableOrderingComposer,
    $$PagesTableAnnotationComposer,
    $$PagesTableCreateCompanionBuilder,
    $$PagesTableUpdateCompanionBuilder,
    (PageRow, $$PagesTableReferences),
    PageRow,
    PrefetchHooks Function(
        {bool surahStart, bool surahEnd, bool linesRefs, bool ayatRefs})> {
  $$PagesTableTableManager(_$HifzDatabase db, $PagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> pageId = const Value.absent(),
            Value<int> juz = const Value.absent(),
            Value<int> hizb = const Value.absent(),
            Value<int> rub = const Value.absent(),
            Value<int> surahStart = const Value.absent(),
            Value<int> ayahStart = const Value.absent(),
            Value<int> surahEnd = const Value.absent(),
            Value<int> ayahEnd = const Value.absent(),
            Value<int> lineCount = const Value.absent(),
            Value<String> qpcFontName = const Value.absent(),
          }) =>
              PagesCompanion(
            pageId: pageId,
            juz: juz,
            hizb: hizb,
            rub: rub,
            surahStart: surahStart,
            ayahStart: ayahStart,
            surahEnd: surahEnd,
            ayahEnd: ayahEnd,
            lineCount: lineCount,
            qpcFontName: qpcFontName,
          ),
          createCompanionCallback: ({
            Value<int> pageId = const Value.absent(),
            required int juz,
            required int hizb,
            required int rub,
            required int surahStart,
            required int ayahStart,
            required int surahEnd,
            required int ayahEnd,
            required int lineCount,
            required String qpcFontName,
          }) =>
              PagesCompanion.insert(
            pageId: pageId,
            juz: juz,
            hizb: hizb,
            rub: rub,
            surahStart: surahStart,
            ayahStart: ayahStart,
            surahEnd: surahEnd,
            ayahEnd: ayahEnd,
            lineCount: lineCount,
            qpcFontName: qpcFontName,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$PagesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {surahStart = false,
              surahEnd = false,
              linesRefs = false,
              ayatRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (linesRefs) db.lines,
                if (ayatRefs) db.ayat
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (surahStart) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surahStart,
                    referencedTable:
                        $$PagesTableReferences._surahStartTable(db),
                    referencedColumn:
                        $$PagesTableReferences._surahStartTable(db).surahId,
                  ) as T;
                }
                if (surahEnd) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surahEnd,
                    referencedTable: $$PagesTableReferences._surahEndTable(db),
                    referencedColumn:
                        $$PagesTableReferences._surahEndTable(db).surahId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (linesRefs)
                    await $_getPrefetchedData<PageRow, $PagesTable, LineRow>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._linesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0).linesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pageId == item.pageId),
                        typedResults: items),
                  if (ayatRefs)
                    await $_getPrefetchedData<PageRow, $PagesTable, AyahRow>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._ayatRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0).ayatRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pageId == item.pageId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$PagesTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $PagesTable,
    PageRow,
    $$PagesTableFilterComposer,
    $$PagesTableOrderingComposer,
    $$PagesTableAnnotationComposer,
    $$PagesTableCreateCompanionBuilder,
    $$PagesTableUpdateCompanionBuilder,
    (PageRow, $$PagesTableReferences),
    PageRow,
    PrefetchHooks Function(
        {bool surahStart, bool surahEnd, bool linesRefs, bool ayatRefs})>;
typedef $$LinesTableCreateCompanionBuilder = LinesCompanion Function({
  Value<int> lineId,
  required int pageId,
  required int lineNo,
  required String lineType,
  required String ayahRefsJson,
  required String textGlyphRef,
});
typedef $$LinesTableUpdateCompanionBuilder = LinesCompanion Function({
  Value<int> lineId,
  Value<int> pageId,
  Value<int> lineNo,
  Value<String> lineType,
  Value<String> ayahRefsJson,
  Value<String> textGlyphRef,
});

final class $$LinesTableReferences
    extends BaseReferences<_$HifzDatabase, $LinesTable, LineRow> {
  $$LinesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PagesTable _pageIdTable(_$HifzDatabase db) => db.pages
      .createAlias($_aliasNameGenerator(db.lines.pageId, db.pages.pageId));

  $$PagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<int>('page_id')!;

    final manager = $$PagesTableTableManager($_db, $_db.pages)
        .filter((f) => f.pageId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$LinesTableFilterComposer extends Composer<_$HifzDatabase, $LinesTable> {
  $$LinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get lineId => $composableBuilder(
      column: $table.lineId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineNo => $composableBuilder(
      column: $table.lineNo, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineType => $composableBuilder(
      column: $table.lineType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get ayahRefsJson => $composableBuilder(
      column: $table.ayahRefsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get textGlyphRef => $composableBuilder(
      column: $table.textGlyphRef, builder: (column) => ColumnFilters(column));

  $$PagesTableFilterComposer get pageId {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LinesTableOrderingComposer
    extends Composer<_$HifzDatabase, $LinesTable> {
  $$LinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get lineId => $composableBuilder(
      column: $table.lineId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineNo => $composableBuilder(
      column: $table.lineNo, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineType => $composableBuilder(
      column: $table.lineType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get ayahRefsJson => $composableBuilder(
      column: $table.ayahRefsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get textGlyphRef => $composableBuilder(
      column: $table.textGlyphRef,
      builder: (column) => ColumnOrderings(column));

  $$PagesTableOrderingComposer get pageId {
    final $$PagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableOrderingComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LinesTableAnnotationComposer
    extends Composer<_$HifzDatabase, $LinesTable> {
  $$LinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get lineId =>
      $composableBuilder(column: $table.lineId, builder: (column) => column);

  GeneratedColumn<int> get lineNo =>
      $composableBuilder(column: $table.lineNo, builder: (column) => column);

  GeneratedColumn<String> get lineType =>
      $composableBuilder(column: $table.lineType, builder: (column) => column);

  GeneratedColumn<String> get ayahRefsJson => $composableBuilder(
      column: $table.ayahRefsJson, builder: (column) => column);

  GeneratedColumn<String> get textGlyphRef => $composableBuilder(
      column: $table.textGlyphRef, builder: (column) => column);

  $$PagesTableAnnotationComposer get pageId {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$LinesTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $LinesTable,
    LineRow,
    $$LinesTableFilterComposer,
    $$LinesTableOrderingComposer,
    $$LinesTableAnnotationComposer,
    $$LinesTableCreateCompanionBuilder,
    $$LinesTableUpdateCompanionBuilder,
    (LineRow, $$LinesTableReferences),
    LineRow,
    PrefetchHooks Function({bool pageId})> {
  $$LinesTableTableManager(_$HifzDatabase db, $LinesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> lineId = const Value.absent(),
            Value<int> pageId = const Value.absent(),
            Value<int> lineNo = const Value.absent(),
            Value<String> lineType = const Value.absent(),
            Value<String> ayahRefsJson = const Value.absent(),
            Value<String> textGlyphRef = const Value.absent(),
          }) =>
              LinesCompanion(
            lineId: lineId,
            pageId: pageId,
            lineNo: lineNo,
            lineType: lineType,
            ayahRefsJson: ayahRefsJson,
            textGlyphRef: textGlyphRef,
          ),
          createCompanionCallback: ({
            Value<int> lineId = const Value.absent(),
            required int pageId,
            required int lineNo,
            required String lineType,
            required String ayahRefsJson,
            required String textGlyphRef,
          }) =>
              LinesCompanion.insert(
            lineId: lineId,
            pageId: pageId,
            lineNo: lineNo,
            lineType: lineType,
            ayahRefsJson: ayahRefsJson,
            textGlyphRef: textGlyphRef,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$LinesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({pageId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable: $$LinesTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$LinesTableReferences._pageIdTable(db).pageId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$LinesTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $LinesTable,
    LineRow,
    $$LinesTableFilterComposer,
    $$LinesTableOrderingComposer,
    $$LinesTableAnnotationComposer,
    $$LinesTableCreateCompanionBuilder,
    $$LinesTableUpdateCompanionBuilder,
    (LineRow, $$LinesTableReferences),
    LineRow,
    PrefetchHooks Function({bool pageId})>;
typedef $$AyatTableCreateCompanionBuilder = AyatCompanion Function({
  required String ayahId,
  required int surah,
  required int ayah,
  required int pageId,
  required String lineRefsJson,
  required bool sajda,
  Value<int> rowid,
});
typedef $$AyatTableUpdateCompanionBuilder = AyatCompanion Function({
  Value<String> ayahId,
  Value<int> surah,
  Value<int> ayah,
  Value<int> pageId,
  Value<String> lineRefsJson,
  Value<bool> sajda,
  Value<int> rowid,
});

final class $$AyatTableReferences
    extends BaseReferences<_$HifzDatabase, $AyatTable, AyahRow> {
  $$AyatTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SurahsTable _surahTable(_$HifzDatabase db) => db.surahs
      .createAlias($_aliasNameGenerator(db.ayat.surah, db.surahs.surahId));

  $$SurahsTableProcessedTableManager get surah {
    final $_column = $_itemColumn<int>('surah')!;

    final manager = $$SurahsTableTableManager($_db, $_db.surahs)
        .filter((f) => f.surahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_surahTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PagesTable _pageIdTable(_$HifzDatabase db) => db.pages
      .createAlias($_aliasNameGenerator(db.ayat.pageId, db.pages.pageId));

  $$PagesTableProcessedTableManager get pageId {
    final $_column = $_itemColumn<int>('page_id')!;

    final manager = $$PagesTableTableManager($_db, $_db.pages)
        .filter((f) => f.pageId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_pageIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$MutashabihMembersTable, List<MutashabihMemberRow>>
      _mutashabihMembersRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.mutashabihMembers,
              aliasName: $_aliasNameGenerator(
                  db.ayat.ayahId, db.mutashabihMembers.ayahId));

  $$MutashabihMembersTableProcessedTableManager get mutashabihMembersRefs {
    final manager = $$MutashabihMembersTableTableManager(
            $_db, $_db.mutashabihMembers)
        .filter(
            (f) => f.ayahId.ayahId.sqlEquals($_itemColumn<String>('ayah_id')!));

    final cache =
        $_typedResult.readTableOrNull(_mutashabihMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$AyatTableFilterComposer extends Composer<_$HifzDatabase, $AyatTable> {
  $$AyatTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get ayah => $composableBuilder(
      column: $table.ayah, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lineRefsJson => $composableBuilder(
      column: $table.lineRefsJson, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get sajda => $composableBuilder(
      column: $table.sajda, builder: (column) => ColumnFilters(column));

  $$SurahsTableFilterComposer get surah {
    final $$SurahsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surah,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableFilterComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagesTableFilterComposer get pageId {
    final $$PagesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableFilterComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> mutashabihMembersRefs(
      Expression<bool> Function($$MutashabihMembersTableFilterComposer f) f) {
    final $$MutashabihMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.mutashabihMembers,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MutashabihMembersTableFilterComposer(
              $db: $db,
              $table: $db.mutashabihMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$AyatTableOrderingComposer extends Composer<_$HifzDatabase, $AyatTable> {
  $$AyatTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ayahId => $composableBuilder(
      column: $table.ayahId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get ayah => $composableBuilder(
      column: $table.ayah, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lineRefsJson => $composableBuilder(
      column: $table.lineRefsJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get sajda => $composableBuilder(
      column: $table.sajda, builder: (column) => ColumnOrderings(column));

  $$SurahsTableOrderingComposer get surah {
    final $$SurahsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surah,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableOrderingComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagesTableOrderingComposer get pageId {
    final $$PagesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableOrderingComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$AyatTableAnnotationComposer
    extends Composer<_$HifzDatabase, $AyatTable> {
  $$AyatTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ayahId =>
      $composableBuilder(column: $table.ayahId, builder: (column) => column);

  GeneratedColumn<int> get ayah =>
      $composableBuilder(column: $table.ayah, builder: (column) => column);

  GeneratedColumn<String> get lineRefsJson => $composableBuilder(
      column: $table.lineRefsJson, builder: (column) => column);

  GeneratedColumn<bool> get sajda =>
      $composableBuilder(column: $table.sajda, builder: (column) => column);

  $$SurahsTableAnnotationComposer get surah {
    final $$SurahsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.surah,
        referencedTable: $db.surahs,
        getReferencedColumn: (t) => t.surahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SurahsTableAnnotationComposer(
              $db: $db,
              $table: $db.surahs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$PagesTableAnnotationComposer get pageId {
    final $$PagesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.pages,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$PagesTableAnnotationComposer(
              $db: $db,
              $table: $db.pages,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> mutashabihMembersRefs<T extends Object>(
      Expression<T> Function($$MutashabihMembersTableAnnotationComposer a) f) {
    final $$MutashabihMembersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.ayahId,
            referencedTable: $db.mutashabihMembers,
            getReferencedColumn: (t) => t.ayahId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MutashabihMembersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.mutashabihMembers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$AyatTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $AyatTable,
    AyahRow,
    $$AyatTableFilterComposer,
    $$AyatTableOrderingComposer,
    $$AyatTableAnnotationComposer,
    $$AyatTableCreateCompanionBuilder,
    $$AyatTableUpdateCompanionBuilder,
    (AyahRow, $$AyatTableReferences),
    AyahRow,
    PrefetchHooks Function(
        {bool surah, bool pageId, bool mutashabihMembersRefs})> {
  $$AyatTableTableManager(_$HifzDatabase db, $AyatTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AyatTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AyatTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AyatTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> ayahId = const Value.absent(),
            Value<int> surah = const Value.absent(),
            Value<int> ayah = const Value.absent(),
            Value<int> pageId = const Value.absent(),
            Value<String> lineRefsJson = const Value.absent(),
            Value<bool> sajda = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AyatCompanion(
            ayahId: ayahId,
            surah: surah,
            ayah: ayah,
            pageId: pageId,
            lineRefsJson: lineRefsJson,
            sajda: sajda,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String ayahId,
            required int surah,
            required int ayah,
            required int pageId,
            required String lineRefsJson,
            required bool sajda,
            Value<int> rowid = const Value.absent(),
          }) =>
              AyatCompanion.insert(
            ayahId: ayahId,
            surah: surah,
            ayah: ayah,
            pageId: pageId,
            lineRefsJson: lineRefsJson,
            sajda: sajda,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$AyatTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {surah = false, pageId = false, mutashabihMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mutashabihMembersRefs) db.mutashabihMembers
              ],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (surah) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.surah,
                    referencedTable: $$AyatTableReferences._surahTable(db),
                    referencedColumn:
                        $$AyatTableReferences._surahTable(db).surahId,
                  ) as T;
                }
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable: $$AyatTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$AyatTableReferences._pageIdTable(db).pageId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mutashabihMembersRefs)
                    await $_getPrefetchedData<AyahRow, $AyatTable,
                            MutashabihMemberRow>(
                        currentTable: table,
                        referencedTable: $$AyatTableReferences
                            ._mutashabihMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AyatTableReferences(db, table, p0)
                                .mutashabihMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ayahId == item.ayahId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$AyatTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $AyatTable,
    AyahRow,
    $$AyatTableFilterComposer,
    $$AyatTableOrderingComposer,
    $$AyatTableAnnotationComposer,
    $$AyatTableCreateCompanionBuilder,
    $$AyatTableUpdateCompanionBuilder,
    (AyahRow, $$AyatTableReferences),
    AyahRow,
    PrefetchHooks Function(
        {bool surah, bool pageId, bool mutashabihMembersRefs})>;
typedef $$MutashabihGroupsTableCreateCompanionBuilder
    = MutashabihGroupsCompanion Function({
  required String groupId,
  required String type,
  Value<String?> noteKey,
  Value<int> rowid,
});
typedef $$MutashabihGroupsTableUpdateCompanionBuilder
    = MutashabihGroupsCompanion Function({
  Value<String> groupId,
  Value<String> type,
  Value<String?> noteKey,
  Value<int> rowid,
});

final class $$MutashabihGroupsTableReferences extends BaseReferences<
    _$HifzDatabase, $MutashabihGroupsTable, MutashabihGroupRow> {
  $$MutashabihGroupsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MutashabihMembersTable, List<MutashabihMemberRow>>
      _mutashabihMembersRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.mutashabihMembers,
              aliasName: $_aliasNameGenerator(
                  db.mutashabihGroups.groupId, db.mutashabihMembers.groupId));

  $$MutashabihMembersTableProcessedTableManager get mutashabihMembersRefs {
    final manager =
        $$MutashabihMembersTableTableManager($_db, $_db.mutashabihMembers)
            .filter((f) =>
                f.groupId.groupId.sqlEquals($_itemColumn<String>('group_id')!));

    final cache =
        $_typedResult.readTableOrNull(_mutashabihMembersRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$MutashabihGroupsTableFilterComposer
    extends Composer<_$HifzDatabase, $MutashabihGroupsTable> {
  $$MutashabihGroupsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get noteKey => $composableBuilder(
      column: $table.noteKey, builder: (column) => ColumnFilters(column));

  Expression<bool> mutashabihMembersRefs(
      Expression<bool> Function($$MutashabihMembersTableFilterComposer f) f) {
    final $$MutashabihMembersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.mutashabihMembers,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MutashabihMembersTableFilterComposer(
              $db: $db,
              $table: $db.mutashabihMembers,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$MutashabihGroupsTableOrderingComposer
    extends Composer<_$HifzDatabase, $MutashabihGroupsTable> {
  $$MutashabihGroupsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get noteKey => $composableBuilder(
      column: $table.noteKey, builder: (column) => ColumnOrderings(column));
}

class $$MutashabihGroupsTableAnnotationComposer
    extends Composer<_$HifzDatabase, $MutashabihGroupsTable> {
  $$MutashabihGroupsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get noteKey =>
      $composableBuilder(column: $table.noteKey, builder: (column) => column);

  Expression<T> mutashabihMembersRefs<T extends Object>(
      Expression<T> Function($$MutashabihMembersTableAnnotationComposer a) f) {
    final $$MutashabihMembersTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.groupId,
            referencedTable: $db.mutashabihMembers,
            getReferencedColumn: (t) => t.groupId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$MutashabihMembersTableAnnotationComposer(
                  $db: $db,
                  $table: $db.mutashabihMembers,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$MutashabihGroupsTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $MutashabihGroupsTable,
    MutashabihGroupRow,
    $$MutashabihGroupsTableFilterComposer,
    $$MutashabihGroupsTableOrderingComposer,
    $$MutashabihGroupsTableAnnotationComposer,
    $$MutashabihGroupsTableCreateCompanionBuilder,
    $$MutashabihGroupsTableUpdateCompanionBuilder,
    (MutashabihGroupRow, $$MutashabihGroupsTableReferences),
    MutashabihGroupRow,
    PrefetchHooks Function({bool mutashabihMembersRefs})> {
  $$MutashabihGroupsTableTableManager(
      _$HifzDatabase db, $MutashabihGroupsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MutashabihGroupsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MutashabihGroupsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MutashabihGroupsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> groupId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> noteKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MutashabihGroupsCompanion(
            groupId: groupId,
            type: type,
            noteKey: noteKey,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String groupId,
            required String type,
            Value<String?> noteKey = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MutashabihGroupsCompanion.insert(
            groupId: groupId,
            type: type,
            noteKey: noteKey,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MutashabihGroupsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({mutashabihMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (mutashabihMembersRefs) db.mutashabihMembers
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (mutashabihMembersRefs)
                    await $_getPrefetchedData<MutashabihGroupRow,
                            $MutashabihGroupsTable, MutashabihMemberRow>(
                        currentTable: table,
                        referencedTable: $$MutashabihGroupsTableReferences
                            ._mutashabihMembersRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MutashabihGroupsTableReferences(db, table, p0)
                                .mutashabihMembersRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.groupId == item.groupId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$MutashabihGroupsTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $MutashabihGroupsTable,
    MutashabihGroupRow,
    $$MutashabihGroupsTableFilterComposer,
    $$MutashabihGroupsTableOrderingComposer,
    $$MutashabihGroupsTableAnnotationComposer,
    $$MutashabihGroupsTableCreateCompanionBuilder,
    $$MutashabihGroupsTableUpdateCompanionBuilder,
    (MutashabihGroupRow, $$MutashabihGroupsTableReferences),
    MutashabihGroupRow,
    PrefetchHooks Function({bool mutashabihMembersRefs})>;
typedef $$MutashabihMembersTableCreateCompanionBuilder
    = MutashabihMembersCompanion Function({
  required String groupId,
  required String ayahId,
  Value<String?> distinguishingWordIndexJson,
  Value<int> rowid,
});
typedef $$MutashabihMembersTableUpdateCompanionBuilder
    = MutashabihMembersCompanion Function({
  Value<String> groupId,
  Value<String> ayahId,
  Value<String?> distinguishingWordIndexJson,
  Value<int> rowid,
});

final class $$MutashabihMembersTableReferences extends BaseReferences<
    _$HifzDatabase, $MutashabihMembersTable, MutashabihMemberRow> {
  $$MutashabihMembersTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $MutashabihGroupsTable _groupIdTable(_$HifzDatabase db) =>
      db.mutashabihGroups.createAlias($_aliasNameGenerator(
          db.mutashabihMembers.groupId, db.mutashabihGroups.groupId));

  $$MutashabihGroupsTableProcessedTableManager get groupId {
    final $_column = $_itemColumn<String>('group_id')!;

    final manager =
        $$MutashabihGroupsTableTableManager($_db, $_db.mutashabihGroups)
            .filter((f) => f.groupId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_groupIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AyatTable _ayahIdTable(_$HifzDatabase db) => db.ayat.createAlias(
      $_aliasNameGenerator(db.mutashabihMembers.ayahId, db.ayat.ayahId));

  $$AyatTableProcessedTableManager get ayahId {
    final $_column = $_itemColumn<String>('ayah_id')!;

    final manager = $$AyatTableTableManager($_db, $_db.ayat)
        .filter((f) => f.ayahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$MutashabihMembersTableFilterComposer
    extends Composer<_$HifzDatabase, $MutashabihMembersTable> {
  $$MutashabihMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get distinguishingWordIndexJson => $composableBuilder(
      column: $table.distinguishingWordIndexJson,
      builder: (column) => ColumnFilters(column));

  $$MutashabihGroupsTableFilterComposer get groupId {
    final $$MutashabihGroupsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.mutashabihGroups,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MutashabihGroupsTableFilterComposer(
              $db: $db,
              $table: $db.mutashabihGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableFilterComposer get ayahId {
    final $$AyatTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableFilterComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MutashabihMembersTableOrderingComposer
    extends Composer<_$HifzDatabase, $MutashabihMembersTable> {
  $$MutashabihMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get distinguishingWordIndexJson => $composableBuilder(
      column: $table.distinguishingWordIndexJson,
      builder: (column) => ColumnOrderings(column));

  $$MutashabihGroupsTableOrderingComposer get groupId {
    final $$MutashabihGroupsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.mutashabihGroups,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MutashabihGroupsTableOrderingComposer(
              $db: $db,
              $table: $db.mutashabihGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableOrderingComposer get ayahId {
    final $$AyatTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableOrderingComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MutashabihMembersTableAnnotationComposer
    extends Composer<_$HifzDatabase, $MutashabihMembersTable> {
  $$MutashabihMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get distinguishingWordIndexJson => $composableBuilder(
      column: $table.distinguishingWordIndexJson, builder: (column) => column);

  $$MutashabihGroupsTableAnnotationComposer get groupId {
    final $$MutashabihGroupsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.groupId,
        referencedTable: $db.mutashabihGroups,
        getReferencedColumn: (t) => t.groupId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MutashabihGroupsTableAnnotationComposer(
              $db: $db,
              $table: $db.mutashabihGroups,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableAnnotationComposer get ayahId {
    final $$AyatTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.ayat,
        getReferencedColumn: (t) => t.ayahId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$AyatTableAnnotationComposer(
              $db: $db,
              $table: $db.ayat,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$MutashabihMembersTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $MutashabihMembersTable,
    MutashabihMemberRow,
    $$MutashabihMembersTableFilterComposer,
    $$MutashabihMembersTableOrderingComposer,
    $$MutashabihMembersTableAnnotationComposer,
    $$MutashabihMembersTableCreateCompanionBuilder,
    $$MutashabihMembersTableUpdateCompanionBuilder,
    (MutashabihMemberRow, $$MutashabihMembersTableReferences),
    MutashabihMemberRow,
    PrefetchHooks Function({bool groupId, bool ayahId})> {
  $$MutashabihMembersTableTableManager(
      _$HifzDatabase db, $MutashabihMembersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MutashabihMembersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MutashabihMembersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MutashabihMembersTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> groupId = const Value.absent(),
            Value<String> ayahId = const Value.absent(),
            Value<String?> distinguishingWordIndexJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MutashabihMembersCompanion(
            groupId: groupId,
            ayahId: ayahId,
            distinguishingWordIndexJson: distinguishingWordIndexJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String groupId,
            required String ayahId,
            Value<String?> distinguishingWordIndexJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MutashabihMembersCompanion.insert(
            groupId: groupId,
            ayahId: ayahId,
            distinguishingWordIndexJson: distinguishingWordIndexJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$MutashabihMembersTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({groupId = false, ayahId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (groupId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.groupId,
                    referencedTable:
                        $$MutashabihMembersTableReferences._groupIdTable(db),
                    referencedColumn: $$MutashabihMembersTableReferences
                        ._groupIdTable(db)
                        .groupId,
                  ) as T;
                }
                if (ayahId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ayahId,
                    referencedTable:
                        $$MutashabihMembersTableReferences._ayahIdTable(db),
                    referencedColumn: $$MutashabihMembersTableReferences
                        ._ayahIdTable(db)
                        .ayahId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$MutashabihMembersTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $MutashabihMembersTable,
    MutashabihMemberRow,
    $$MutashabihMembersTableFilterComposer,
    $$MutashabihMembersTableOrderingComposer,
    $$MutashabihMembersTableAnnotationComposer,
    $$MutashabihMembersTableCreateCompanionBuilder,
    $$MutashabihMembersTableUpdateCompanionBuilder,
    (MutashabihMemberRow, $$MutashabihMembersTableReferences),
    MutashabihMemberRow,
    PrefetchHooks Function({bool groupId, bool ayahId})>;

class $HifzDatabaseManager {
  final _$HifzDatabase _db;
  $HifzDatabaseManager(this._db);
  $$MushafsTableTableManager get mushafs =>
      $$MushafsTableTableManager(_db, _db.mushafs);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$LinesTableTableManager get lines =>
      $$LinesTableTableManager(_db, _db.lines);
  $$AyatTableTableManager get ayat => $$AyatTableTableManager(_db, _db.ayat);
  $$MutashabihGroupsTableTableManager get mutashabihGroups =>
      $$MutashabihGroupsTableTableManager(_db, _db.mutashabihGroups);
  $$MutashabihMembersTableTableManager get mutashabihMembers =>
      $$MutashabihMembersTableTableManager(_db, _db.mutashabihMembers);
}
