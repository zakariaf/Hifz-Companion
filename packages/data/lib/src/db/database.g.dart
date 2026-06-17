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

class $ProfilesTable extends Profiles
    with TableInfo<$ProfilesTable, ProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _displayNameMeta =
      const VerificationMeta('displayName');
  @override
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
      'display_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
      'role', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _localeMeta = const VerificationMeta('locale');
  @override
  late final GeneratedColumn<String> locale = GeneratedColumn<String>(
      'locale', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mushafIdMeta =
      const VerificationMeta('mushafId');
  @override
  late final GeneratedColumn<String> mushafId = GeneratedColumn<String>(
      'mushaf_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES mushaf (mushaf_id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _settingsJsonMeta =
      const VerificationMeta('settingsJson');
  @override
  late final GeneratedColumn<String> settingsJson = GeneratedColumn<String>(
      'settings_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [profileId, displayName, role, locale, mushafId, createdAt, settingsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile';
  @override
  VerificationContext validateIntegrity(Insertable<ProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
          _displayNameMeta,
          displayName.isAcceptableOrUnknown(
              data['display_name']!, _displayNameMeta));
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
          _roleMeta, role.isAcceptableOrUnknown(data['role']!, _roleMeta));
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('locale')) {
      context.handle(_localeMeta,
          locale.isAcceptableOrUnknown(data['locale']!, _localeMeta));
    } else if (isInserting) {
      context.missing(_localeMeta);
    }
    if (data.containsKey('mushaf_id')) {
      context.handle(_mushafIdMeta,
          mushafId.isAcceptableOrUnknown(data['mushaf_id']!, _mushafIdMeta));
    } else if (isInserting) {
      context.missing(_mushafIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('settings_json')) {
      context.handle(
          _settingsJsonMeta,
          settingsJson.isAcceptableOrUnknown(
              data['settings_json']!, _settingsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  ProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRow(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      displayName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}display_name'])!,
      role: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}role'])!,
      locale: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}locale'])!,
      mushafId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mushaf_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      settingsJson: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}settings_json']),
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ProfileRow extends DataClass implements Insertable<ProfileRow> {
  /// The profile UUID (PK).
  final String profileId;

  /// The user-typed display name — the only PII (PRD §17).
  final String displayName;

  /// `self` / `student` / `child`.
  final String role;

  /// `ar` / `fa` / `ckb`.
  final String locale;

  /// The selected muṣḥaf edition (FK into `mushaf`, no cascade — immutable).
  final String mushafId;

  /// Creation instant — UTC ISO-8601 TEXT, never a scheduling day.
  final String createdAt;

  /// Decode-validated preference JSON, or null — never health/Quran facts.
  final String? settingsJson;
  const ProfileRow(
      {required this.profileId,
      required this.displayName,
      required this.role,
      required this.locale,
      required this.mushafId,
      required this.createdAt,
      this.settingsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['display_name'] = Variable<String>(displayName);
    map['role'] = Variable<String>(role);
    map['locale'] = Variable<String>(locale);
    map['mushaf_id'] = Variable<String>(mushafId);
    map['created_at'] = Variable<String>(createdAt);
    if (!nullToAbsent || settingsJson != null) {
      map['settings_json'] = Variable<String>(settingsJson);
    }
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      profileId: Value(profileId),
      displayName: Value(displayName),
      role: Value(role),
      locale: Value(locale),
      mushafId: Value(mushafId),
      createdAt: Value(createdAt),
      settingsJson: settingsJson == null && nullToAbsent
          ? const Value.absent()
          : Value(settingsJson),
    );
  }

  factory ProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      displayName: serializer.fromJson<String>(json['displayName']),
      role: serializer.fromJson<String>(json['role']),
      locale: serializer.fromJson<String>(json['locale']),
      mushafId: serializer.fromJson<String>(json['mushafId']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      settingsJson: serializer.fromJson<String?>(json['settingsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'displayName': serializer.toJson<String>(displayName),
      'role': serializer.toJson<String>(role),
      'locale': serializer.toJson<String>(locale),
      'mushafId': serializer.toJson<String>(mushafId),
      'createdAt': serializer.toJson<String>(createdAt),
      'settingsJson': serializer.toJson<String?>(settingsJson),
    };
  }

  ProfileRow copyWith(
          {String? profileId,
          String? displayName,
          String? role,
          String? locale,
          String? mushafId,
          String? createdAt,
          Value<String?> settingsJson = const Value.absent()}) =>
      ProfileRow(
        profileId: profileId ?? this.profileId,
        displayName: displayName ?? this.displayName,
        role: role ?? this.role,
        locale: locale ?? this.locale,
        mushafId: mushafId ?? this.mushafId,
        createdAt: createdAt ?? this.createdAt,
        settingsJson:
            settingsJson.present ? settingsJson.value : this.settingsJson,
      );
  ProfileRow copyWithCompanion(ProfilesCompanion data) {
    return ProfileRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      displayName:
          data.displayName.present ? data.displayName.value : this.displayName,
      role: data.role.present ? data.role.value : this.role,
      locale: data.locale.present ? data.locale.value : this.locale,
      mushafId: data.mushafId.present ? data.mushafId.value : this.mushafId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      settingsJson: data.settingsJson.present
          ? data.settingsJson.value
          : this.settingsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRow(')
          ..write('profileId: $profileId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('locale: $locale, ')
          ..write('mushafId: $mushafId, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      profileId, displayName, role, locale, mushafId, createdAt, settingsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRow &&
          other.profileId == this.profileId &&
          other.displayName == this.displayName &&
          other.role == this.role &&
          other.locale == this.locale &&
          other.mushafId == this.mushafId &&
          other.createdAt == this.createdAt &&
          other.settingsJson == this.settingsJson);
}

class ProfilesCompanion extends UpdateCompanion<ProfileRow> {
  final Value<String> profileId;
  final Value<String> displayName;
  final Value<String> role;
  final Value<String> locale;
  final Value<String> mushafId;
  final Value<String> createdAt;
  final Value<String?> settingsJson;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.profileId = const Value.absent(),
    this.displayName = const Value.absent(),
    this.role = const Value.absent(),
    this.locale = const Value.absent(),
    this.mushafId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.settingsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String profileId,
    required String displayName,
    required String role,
    required String locale,
    required String mushafId,
    required String createdAt,
    this.settingsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        displayName = Value(displayName),
        role = Value(role),
        locale = Value(locale),
        mushafId = Value(mushafId),
        createdAt = Value(createdAt);
  static Insertable<ProfileRow> custom({
    Expression<String>? profileId,
    Expression<String>? displayName,
    Expression<String>? role,
    Expression<String>? locale,
    Expression<String>? mushafId,
    Expression<String>? createdAt,
    Expression<String>? settingsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (displayName != null) 'display_name': displayName,
      if (role != null) 'role': role,
      if (locale != null) 'locale': locale,
      if (mushafId != null) 'mushaf_id': mushafId,
      if (createdAt != null) 'created_at': createdAt,
      if (settingsJson != null) 'settings_json': settingsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith(
      {Value<String>? profileId,
      Value<String>? displayName,
      Value<String>? role,
      Value<String>? locale,
      Value<String>? mushafId,
      Value<String>? createdAt,
      Value<String?>? settingsJson,
      Value<int>? rowid}) {
    return ProfilesCompanion(
      profileId: profileId ?? this.profileId,
      displayName: displayName ?? this.displayName,
      role: role ?? this.role,
      locale: locale ?? this.locale,
      mushafId: mushafId ?? this.mushafId,
      createdAt: createdAt ?? this.createdAt,
      settingsJson: settingsJson ?? this.settingsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (locale.present) {
      map['locale'] = Variable<String>(locale.value);
    }
    if (mushafId.present) {
      map['mushaf_id'] = Variable<String>(mushafId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (settingsJson.present) {
      map['settings_json'] = Variable<String>(settingsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('displayName: $displayName, ')
          ..write('role: $role, ')
          ..write('locale: $locale, ')
          ..write('mushafId: $mushafId, ')
          ..write('createdAt: $createdAt, ')
          ..write('settingsJson: $settingsJson, ')
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

class $CardsTable extends Cards with TableInfo<$CardsTable, CardRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES profile (profile_id) ON DELETE CASCADE'));
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES page (page_id)'));
  static const VerificationMeta _trackMeta = const VerificationMeta('track');
  @override
  late final GeneratedColumn<String> track = GeneratedColumn<String>(
      'track', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _difficultyMeta =
      const VerificationMeta('difficulty');
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
      'd', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _stabilityDaysMeta =
      const VerificationMeta('stabilityDays');
  @override
  late final GeneratedColumn<double> stabilityDays = GeneratedColumn<double>(
      's', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _lastReviewAtMeta =
      const VerificationMeta('lastReviewAt');
  @override
  late final GeneratedColumn<int> lastReviewAt = GeneratedColumn<int>(
      'last_review_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<int> dueAt = GeneratedColumn<int>(
      'due_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
      'reps', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lapsesMeta = const VerificationMeta('lapses');
  @override
  late final GeneratedColumn<int> lapses = GeneratedColumn<int>(
      'lapses', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _weakFlagMeta =
      const VerificationMeta('weakFlag');
  @override
  late final GeneratedColumn<bool> weakFlag = GeneratedColumn<bool>(
      'weak_flag', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("weak_flag" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _signoffsMeta =
      const VerificationMeta('signoffs');
  @override
  late final GeneratedColumn<int> signoffs = GeneratedColumn<int>(
      'signoffs', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _manualLockMeta =
      const VerificationMeta('manualLock');
  @override
  late final GeneratedColumn<bool> manualLock = GeneratedColumn<bool>(
      'manual_lock', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("manual_lock" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _prayerCriticalMeta =
      const VerificationMeta('prayerCritical');
  @override
  late final GeneratedColumn<bool> prayerCritical = GeneratedColumn<bool>(
      'prayer_critical', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("prayer_critical" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _enabledMeta =
      const VerificationMeta('enabled');
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
      'enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        profileId,
        pageId,
        track,
        difficulty,
        stabilityDays,
        lastReviewAt,
        dueAt,
        reps,
        lapses,
        weakFlag,
        signoffs,
        manualLock,
        prayerCritical,
        enabled
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card';
  @override
  VerificationContext validateIntegrity(Insertable<CardRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('track')) {
      context.handle(
          _trackMeta, track.isAcceptableOrUnknown(data['track']!, _trackMeta));
    } else if (isInserting) {
      context.missing(_trackMeta);
    }
    if (data.containsKey('d')) {
      context.handle(_difficultyMeta,
          difficulty.isAcceptableOrUnknown(data['d']!, _difficultyMeta));
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('s')) {
      context.handle(_stabilityDaysMeta,
          stabilityDays.isAcceptableOrUnknown(data['s']!, _stabilityDaysMeta));
    } else if (isInserting) {
      context.missing(_stabilityDaysMeta);
    }
    if (data.containsKey('last_review_at')) {
      context.handle(
          _lastReviewAtMeta,
          lastReviewAt.isAcceptableOrUnknown(
              data['last_review_at']!, _lastReviewAtMeta));
    }
    if (data.containsKey('due_at')) {
      context.handle(
          _dueAtMeta, dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta));
    }
    if (data.containsKey('reps')) {
      context.handle(
          _repsMeta, reps.isAcceptableOrUnknown(data['reps']!, _repsMeta));
    }
    if (data.containsKey('lapses')) {
      context.handle(_lapsesMeta,
          lapses.isAcceptableOrUnknown(data['lapses']!, _lapsesMeta));
    }
    if (data.containsKey('weak_flag')) {
      context.handle(_weakFlagMeta,
          weakFlag.isAcceptableOrUnknown(data['weak_flag']!, _weakFlagMeta));
    }
    if (data.containsKey('signoffs')) {
      context.handle(_signoffsMeta,
          signoffs.isAcceptableOrUnknown(data['signoffs']!, _signoffsMeta));
    }
    if (data.containsKey('manual_lock')) {
      context.handle(
          _manualLockMeta,
          manualLock.isAcceptableOrUnknown(
              data['manual_lock']!, _manualLockMeta));
    }
    if (data.containsKey('prayer_critical')) {
      context.handle(
          _prayerCriticalMeta,
          prayerCritical.isAcceptableOrUnknown(
              data['prayer_critical']!, _prayerCriticalMeta));
    }
    if (data.containsKey('enabled')) {
      context.handle(_enabledMeta,
          enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, pageId};
  @override
  CardRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardRow(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      track: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}track'])!,
      difficulty: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}d'])!,
      stabilityDays: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}s'])!,
      lastReviewAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_review_at']),
      dueAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_at']),
      reps: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}reps'])!,
      lapses: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}lapses'])!,
      weakFlag: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}weak_flag'])!,
      signoffs: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}signoffs'])!,
      manualLock: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}manual_lock'])!,
      prayerCritical: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}prayer_critical'])!,
      enabled: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}enabled'])!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class CardRow extends DataClass implements Insertable<CardRow> {
  /// The owning profile (FK, `ON DELETE CASCADE`).
  final String profileId;

  /// The muṣḥaf page (FK into `page`, no cascade — the page is immutable).
  final int pageId;

  /// `NEW` / `NEAR` / `FAR` / `UNMEMORIZED`.
  final String track;

  /// FSRS difficulty `D` (column `d`, 1–10).
  final double difficulty;

  /// FSRS stability `S` in days (column `s`, ≥ 0).
  final double stabilityDays;

  /// Civil day last reviewed — `CalendarDate` serial day, or null if never.
  final int? lastReviewAt;

  /// Civil day next due — `CalendarDate` serial day; null only when unmemorized.
  final int? dueAt;

  /// Successful-review count (≥ 0).
  final int reps;

  /// Lapse count (≥ 0).
  final int lapses;

  /// Whether the engine has flagged this page weak.
  final bool weakFlag;

  /// Teacher (talaqqī) sign-off count — a *sanad* count, never a reward (≥ 0).
  final int signoffs;

  /// Whether the user has manually pinned this page's track.
  final bool manualLock;

  /// Whether this page is prayer-critical (prioritized in catch-up).
  final bool prayerCritical;

  /// Whether this card participates in scheduling (dormant, never dropped).
  final bool enabled;
  const CardRow(
      {required this.profileId,
      required this.pageId,
      required this.track,
      required this.difficulty,
      required this.stabilityDays,
      this.lastReviewAt,
      this.dueAt,
      required this.reps,
      required this.lapses,
      required this.weakFlag,
      required this.signoffs,
      required this.manualLock,
      required this.prayerCritical,
      required this.enabled});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['page_id'] = Variable<int>(pageId);
    map['track'] = Variable<String>(track);
    map['d'] = Variable<double>(difficulty);
    map['s'] = Variable<double>(stabilityDays);
    if (!nullToAbsent || lastReviewAt != null) {
      map['last_review_at'] = Variable<int>(lastReviewAt);
    }
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<int>(dueAt);
    }
    map['reps'] = Variable<int>(reps);
    map['lapses'] = Variable<int>(lapses);
    map['weak_flag'] = Variable<bool>(weakFlag);
    map['signoffs'] = Variable<int>(signoffs);
    map['manual_lock'] = Variable<bool>(manualLock);
    map['prayer_critical'] = Variable<bool>(prayerCritical);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      profileId: Value(profileId),
      pageId: Value(pageId),
      track: Value(track),
      difficulty: Value(difficulty),
      stabilityDays: Value(stabilityDays),
      lastReviewAt: lastReviewAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReviewAt),
      dueAt:
          dueAt == null && nullToAbsent ? const Value.absent() : Value(dueAt),
      reps: Value(reps),
      lapses: Value(lapses),
      weakFlag: Value(weakFlag),
      signoffs: Value(signoffs),
      manualLock: Value(manualLock),
      prayerCritical: Value(prayerCritical),
      enabled: Value(enabled),
    );
  }

  factory CardRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      pageId: serializer.fromJson<int>(json['pageId']),
      track: serializer.fromJson<String>(json['track']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
      stabilityDays: serializer.fromJson<double>(json['stabilityDays']),
      lastReviewAt: serializer.fromJson<int?>(json['lastReviewAt']),
      dueAt: serializer.fromJson<int?>(json['dueAt']),
      reps: serializer.fromJson<int>(json['reps']),
      lapses: serializer.fromJson<int>(json['lapses']),
      weakFlag: serializer.fromJson<bool>(json['weakFlag']),
      signoffs: serializer.fromJson<int>(json['signoffs']),
      manualLock: serializer.fromJson<bool>(json['manualLock']),
      prayerCritical: serializer.fromJson<bool>(json['prayerCritical']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'pageId': serializer.toJson<int>(pageId),
      'track': serializer.toJson<String>(track),
      'difficulty': serializer.toJson<double>(difficulty),
      'stabilityDays': serializer.toJson<double>(stabilityDays),
      'lastReviewAt': serializer.toJson<int?>(lastReviewAt),
      'dueAt': serializer.toJson<int?>(dueAt),
      'reps': serializer.toJson<int>(reps),
      'lapses': serializer.toJson<int>(lapses),
      'weakFlag': serializer.toJson<bool>(weakFlag),
      'signoffs': serializer.toJson<int>(signoffs),
      'manualLock': serializer.toJson<bool>(manualLock),
      'prayerCritical': serializer.toJson<bool>(prayerCritical),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  CardRow copyWith(
          {String? profileId,
          int? pageId,
          String? track,
          double? difficulty,
          double? stabilityDays,
          Value<int?> lastReviewAt = const Value.absent(),
          Value<int?> dueAt = const Value.absent(),
          int? reps,
          int? lapses,
          bool? weakFlag,
          int? signoffs,
          bool? manualLock,
          bool? prayerCritical,
          bool? enabled}) =>
      CardRow(
        profileId: profileId ?? this.profileId,
        pageId: pageId ?? this.pageId,
        track: track ?? this.track,
        difficulty: difficulty ?? this.difficulty,
        stabilityDays: stabilityDays ?? this.stabilityDays,
        lastReviewAt:
            lastReviewAt.present ? lastReviewAt.value : this.lastReviewAt,
        dueAt: dueAt.present ? dueAt.value : this.dueAt,
        reps: reps ?? this.reps,
        lapses: lapses ?? this.lapses,
        weakFlag: weakFlag ?? this.weakFlag,
        signoffs: signoffs ?? this.signoffs,
        manualLock: manualLock ?? this.manualLock,
        prayerCritical: prayerCritical ?? this.prayerCritical,
        enabled: enabled ?? this.enabled,
      );
  CardRow copyWithCompanion(CardsCompanion data) {
    return CardRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      track: data.track.present ? data.track.value : this.track,
      difficulty:
          data.difficulty.present ? data.difficulty.value : this.difficulty,
      stabilityDays: data.stabilityDays.present
          ? data.stabilityDays.value
          : this.stabilityDays,
      lastReviewAt: data.lastReviewAt.present
          ? data.lastReviewAt.value
          : this.lastReviewAt,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      reps: data.reps.present ? data.reps.value : this.reps,
      lapses: data.lapses.present ? data.lapses.value : this.lapses,
      weakFlag: data.weakFlag.present ? data.weakFlag.value : this.weakFlag,
      signoffs: data.signoffs.present ? data.signoffs.value : this.signoffs,
      manualLock:
          data.manualLock.present ? data.manualLock.value : this.manualLock,
      prayerCritical: data.prayerCritical.present
          ? data.prayerCritical.value
          : this.prayerCritical,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardRow(')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('track: $track, ')
          ..write('difficulty: $difficulty, ')
          ..write('stabilityDays: $stabilityDays, ')
          ..write('lastReviewAt: $lastReviewAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('weakFlag: $weakFlag, ')
          ..write('signoffs: $signoffs, ')
          ..write('manualLock: $manualLock, ')
          ..write('prayerCritical: $prayerCritical, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      profileId,
      pageId,
      track,
      difficulty,
      stabilityDays,
      lastReviewAt,
      dueAt,
      reps,
      lapses,
      weakFlag,
      signoffs,
      manualLock,
      prayerCritical,
      enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardRow &&
          other.profileId == this.profileId &&
          other.pageId == this.pageId &&
          other.track == this.track &&
          other.difficulty == this.difficulty &&
          other.stabilityDays == this.stabilityDays &&
          other.lastReviewAt == this.lastReviewAt &&
          other.dueAt == this.dueAt &&
          other.reps == this.reps &&
          other.lapses == this.lapses &&
          other.weakFlag == this.weakFlag &&
          other.signoffs == this.signoffs &&
          other.manualLock == this.manualLock &&
          other.prayerCritical == this.prayerCritical &&
          other.enabled == this.enabled);
}

class CardsCompanion extends UpdateCompanion<CardRow> {
  final Value<String> profileId;
  final Value<int> pageId;
  final Value<String> track;
  final Value<double> difficulty;
  final Value<double> stabilityDays;
  final Value<int?> lastReviewAt;
  final Value<int?> dueAt;
  final Value<int> reps;
  final Value<int> lapses;
  final Value<bool> weakFlag;
  final Value<int> signoffs;
  final Value<bool> manualLock;
  final Value<bool> prayerCritical;
  final Value<bool> enabled;
  final Value<int> rowid;
  const CardsCompanion({
    this.profileId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.track = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.stabilityDays = const Value.absent(),
    this.lastReviewAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.weakFlag = const Value.absent(),
    this.signoffs = const Value.absent(),
    this.manualLock = const Value.absent(),
    this.prayerCritical = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardsCompanion.insert({
    required String profileId,
    required int pageId,
    required String track,
    required double difficulty,
    required double stabilityDays,
    this.lastReviewAt = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.reps = const Value.absent(),
    this.lapses = const Value.absent(),
    this.weakFlag = const Value.absent(),
    this.signoffs = const Value.absent(),
    this.manualLock = const Value.absent(),
    this.prayerCritical = const Value.absent(),
    this.enabled = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        pageId = Value(pageId),
        track = Value(track),
        difficulty = Value(difficulty),
        stabilityDays = Value(stabilityDays);
  static Insertable<CardRow> custom({
    Expression<String>? profileId,
    Expression<int>? pageId,
    Expression<String>? track,
    Expression<double>? difficulty,
    Expression<double>? stabilityDays,
    Expression<int>? lastReviewAt,
    Expression<int>? dueAt,
    Expression<int>? reps,
    Expression<int>? lapses,
    Expression<bool>? weakFlag,
    Expression<int>? signoffs,
    Expression<bool>? manualLock,
    Expression<bool>? prayerCritical,
    Expression<bool>? enabled,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (pageId != null) 'page_id': pageId,
      if (track != null) 'track': track,
      if (difficulty != null) 'd': difficulty,
      if (stabilityDays != null) 's': stabilityDays,
      if (lastReviewAt != null) 'last_review_at': lastReviewAt,
      if (dueAt != null) 'due_at': dueAt,
      if (reps != null) 'reps': reps,
      if (lapses != null) 'lapses': lapses,
      if (weakFlag != null) 'weak_flag': weakFlag,
      if (signoffs != null) 'signoffs': signoffs,
      if (manualLock != null) 'manual_lock': manualLock,
      if (prayerCritical != null) 'prayer_critical': prayerCritical,
      if (enabled != null) 'enabled': enabled,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardsCompanion copyWith(
      {Value<String>? profileId,
      Value<int>? pageId,
      Value<String>? track,
      Value<double>? difficulty,
      Value<double>? stabilityDays,
      Value<int?>? lastReviewAt,
      Value<int?>? dueAt,
      Value<int>? reps,
      Value<int>? lapses,
      Value<bool>? weakFlag,
      Value<int>? signoffs,
      Value<bool>? manualLock,
      Value<bool>? prayerCritical,
      Value<bool>? enabled,
      Value<int>? rowid}) {
    return CardsCompanion(
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      track: track ?? this.track,
      difficulty: difficulty ?? this.difficulty,
      stabilityDays: stabilityDays ?? this.stabilityDays,
      lastReviewAt: lastReviewAt ?? this.lastReviewAt,
      dueAt: dueAt ?? this.dueAt,
      reps: reps ?? this.reps,
      lapses: lapses ?? this.lapses,
      weakFlag: weakFlag ?? this.weakFlag,
      signoffs: signoffs ?? this.signoffs,
      manualLock: manualLock ?? this.manualLock,
      prayerCritical: prayerCritical ?? this.prayerCritical,
      enabled: enabled ?? this.enabled,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (track.present) {
      map['track'] = Variable<String>(track.value);
    }
    if (difficulty.present) {
      map['d'] = Variable<double>(difficulty.value);
    }
    if (stabilityDays.present) {
      map['s'] = Variable<double>(stabilityDays.value);
    }
    if (lastReviewAt.present) {
      map['last_review_at'] = Variable<int>(lastReviewAt.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<int>(dueAt.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (lapses.present) {
      map['lapses'] = Variable<int>(lapses.value);
    }
    if (weakFlag.present) {
      map['weak_flag'] = Variable<bool>(weakFlag.value);
    }
    if (signoffs.present) {
      map['signoffs'] = Variable<int>(signoffs.value);
    }
    if (manualLock.present) {
      map['manual_lock'] = Variable<bool>(manualLock.value);
    }
    if (prayerCritical.present) {
      map['prayer_critical'] = Variable<bool>(prayerCritical.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('track: $track, ')
          ..write('difficulty: $difficulty, ')
          ..write('stabilityDays: $stabilityDays, ')
          ..write('lastReviewAt: $lastReviewAt, ')
          ..write('dueAt: $dueAt, ')
          ..write('reps: $reps, ')
          ..write('lapses: $lapses, ')
          ..write('weakFlag: $weakFlag, ')
          ..write('signoffs: $signoffs, ')
          ..write('manualLock: $manualLock, ')
          ..write('prayerCritical: $prayerCritical, ')
          ..write('enabled: $enabled, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LineBlocksTable extends LineBlocks
    with TableInfo<$LineBlocksTable, LineBlockRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LineBlocksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _blockIdMeta =
      const VerificationMeta('blockId');
  @override
  late final GeneratedColumn<String> blockId = GeneratedColumn<String>(
      'block_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES profile (profile_id) ON DELETE CASCADE'));
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES page (page_id)'));
  static const VerificationMeta _lineStartMeta =
      const VerificationMeta('lineStart');
  @override
  late final GeneratedColumn<int> lineStart = GeneratedColumn<int>(
      'line_start', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _lineEndMeta =
      const VerificationMeta('lineEnd');
  @override
  late final GeneratedColumn<int> lineEnd = GeneratedColumn<int>(
      'line_end', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _errorCountMeta =
      const VerificationMeta('errorCount');
  @override
  late final GeneratedColumn<int> errorCount = GeneratedColumn<int>(
      'error_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [blockId, profileId, pageId, lineStart, lineEnd, errorCount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'line_block';
  @override
  VerificationContext validateIntegrity(Insertable<LineBlockRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('block_id')) {
      context.handle(_blockIdMeta,
          blockId.isAcceptableOrUnknown(data['block_id']!, _blockIdMeta));
    } else if (isInserting) {
      context.missing(_blockIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('line_start')) {
      context.handle(_lineStartMeta,
          lineStart.isAcceptableOrUnknown(data['line_start']!, _lineStartMeta));
    } else if (isInserting) {
      context.missing(_lineStartMeta);
    }
    if (data.containsKey('line_end')) {
      context.handle(_lineEndMeta,
          lineEnd.isAcceptableOrUnknown(data['line_end']!, _lineEndMeta));
    } else if (isInserting) {
      context.missing(_lineEndMeta);
    }
    if (data.containsKey('error_count')) {
      context.handle(
          _errorCountMeta,
          errorCount.isAcceptableOrUnknown(
              data['error_count']!, _errorCountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {blockId};
  @override
  LineBlockRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LineBlockRow(
      blockId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}block_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      lineStart: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_start'])!,
      lineEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}line_end'])!,
      errorCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}error_count'])!,
    );
  }

  @override
  $LineBlocksTable createAlias(String alias) {
    return $LineBlocksTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class LineBlockRow extends DataClass implements Insertable<LineBlockRow> {
  /// The block UUID (PK).
  final String blockId;

  /// The owning profile (FK, `ON DELETE CASCADE`).
  final String profileId;

  /// The muṣḥaf page (FK into `page`, no cascade).
  final int pageId;

  /// The first line of the range (1–15).
  final int lineStart;

  /// The last line of the range (`line_start ≤ line_end ≤ 15`).
  final int lineEnd;

  /// Stumble count for this range (≥ 0).
  final int errorCount;
  const LineBlockRow(
      {required this.blockId,
      required this.profileId,
      required this.pageId,
      required this.lineStart,
      required this.lineEnd,
      required this.errorCount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['block_id'] = Variable<String>(blockId);
    map['profile_id'] = Variable<String>(profileId);
    map['page_id'] = Variable<int>(pageId);
    map['line_start'] = Variable<int>(lineStart);
    map['line_end'] = Variable<int>(lineEnd);
    map['error_count'] = Variable<int>(errorCount);
    return map;
  }

  LineBlocksCompanion toCompanion(bool nullToAbsent) {
    return LineBlocksCompanion(
      blockId: Value(blockId),
      profileId: Value(profileId),
      pageId: Value(pageId),
      lineStart: Value(lineStart),
      lineEnd: Value(lineEnd),
      errorCount: Value(errorCount),
    );
  }

  factory LineBlockRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LineBlockRow(
      blockId: serializer.fromJson<String>(json['blockId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      pageId: serializer.fromJson<int>(json['pageId']),
      lineStart: serializer.fromJson<int>(json['lineStart']),
      lineEnd: serializer.fromJson<int>(json['lineEnd']),
      errorCount: serializer.fromJson<int>(json['errorCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'blockId': serializer.toJson<String>(blockId),
      'profileId': serializer.toJson<String>(profileId),
      'pageId': serializer.toJson<int>(pageId),
      'lineStart': serializer.toJson<int>(lineStart),
      'lineEnd': serializer.toJson<int>(lineEnd),
      'errorCount': serializer.toJson<int>(errorCount),
    };
  }

  LineBlockRow copyWith(
          {String? blockId,
          String? profileId,
          int? pageId,
          int? lineStart,
          int? lineEnd,
          int? errorCount}) =>
      LineBlockRow(
        blockId: blockId ?? this.blockId,
        profileId: profileId ?? this.profileId,
        pageId: pageId ?? this.pageId,
        lineStart: lineStart ?? this.lineStart,
        lineEnd: lineEnd ?? this.lineEnd,
        errorCount: errorCount ?? this.errorCount,
      );
  LineBlockRow copyWithCompanion(LineBlocksCompanion data) {
    return LineBlockRow(
      blockId: data.blockId.present ? data.blockId.value : this.blockId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      lineStart: data.lineStart.present ? data.lineStart.value : this.lineStart,
      lineEnd: data.lineEnd.present ? data.lineEnd.value : this.lineEnd,
      errorCount:
          data.errorCount.present ? data.errorCount.value : this.errorCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LineBlockRow(')
          ..write('blockId: $blockId, ')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('lineStart: $lineStart, ')
          ..write('lineEnd: $lineEnd, ')
          ..write('errorCount: $errorCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(blockId, profileId, pageId, lineStart, lineEnd, errorCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LineBlockRow &&
          other.blockId == this.blockId &&
          other.profileId == this.profileId &&
          other.pageId == this.pageId &&
          other.lineStart == this.lineStart &&
          other.lineEnd == this.lineEnd &&
          other.errorCount == this.errorCount);
}

class LineBlocksCompanion extends UpdateCompanion<LineBlockRow> {
  final Value<String> blockId;
  final Value<String> profileId;
  final Value<int> pageId;
  final Value<int> lineStart;
  final Value<int> lineEnd;
  final Value<int> errorCount;
  final Value<int> rowid;
  const LineBlocksCompanion({
    this.blockId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.lineStart = const Value.absent(),
    this.lineEnd = const Value.absent(),
    this.errorCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LineBlocksCompanion.insert({
    required String blockId,
    required String profileId,
    required int pageId,
    required int lineStart,
    required int lineEnd,
    this.errorCount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : blockId = Value(blockId),
        profileId = Value(profileId),
        pageId = Value(pageId),
        lineStart = Value(lineStart),
        lineEnd = Value(lineEnd);
  static Insertable<LineBlockRow> custom({
    Expression<String>? blockId,
    Expression<String>? profileId,
    Expression<int>? pageId,
    Expression<int>? lineStart,
    Expression<int>? lineEnd,
    Expression<int>? errorCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (blockId != null) 'block_id': blockId,
      if (profileId != null) 'profile_id': profileId,
      if (pageId != null) 'page_id': pageId,
      if (lineStart != null) 'line_start': lineStart,
      if (lineEnd != null) 'line_end': lineEnd,
      if (errorCount != null) 'error_count': errorCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LineBlocksCompanion copyWith(
      {Value<String>? blockId,
      Value<String>? profileId,
      Value<int>? pageId,
      Value<int>? lineStart,
      Value<int>? lineEnd,
      Value<int>? errorCount,
      Value<int>? rowid}) {
    return LineBlocksCompanion(
      blockId: blockId ?? this.blockId,
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      lineStart: lineStart ?? this.lineStart,
      lineEnd: lineEnd ?? this.lineEnd,
      errorCount: errorCount ?? this.errorCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (blockId.present) {
      map['block_id'] = Variable<String>(blockId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (lineStart.present) {
      map['line_start'] = Variable<int>(lineStart.value);
    }
    if (lineEnd.present) {
      map['line_end'] = Variable<int>(lineEnd.value);
    }
    if (errorCount.present) {
      map['error_count'] = Variable<int>(errorCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LineBlocksCompanion(')
          ..write('blockId: $blockId, ')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('lineStart: $lineStart, ')
          ..write('lineEnd: $lineEnd, ')
          ..write('errorCount: $errorCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReviewLogTable extends ReviewLog
    with TableInfo<$ReviewLogTable, ReviewLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReviewLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _logIdMeta = const VerificationMeta('logId');
  @override
  late final GeneratedColumn<String> logId = GeneratedColumn<String>(
      'log_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES profile (profile_id) ON DELETE CASCADE'));
  static const VerificationMeta _pageIdMeta = const VerificationMeta('pageId');
  @override
  late final GeneratedColumn<int> pageId = GeneratedColumn<int>(
      'page_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES page (page_id)'));
  static const VerificationMeta _reviewedAtMeta =
      const VerificationMeta('reviewedAt');
  @override
  late final GeneratedColumn<String> reviewedAt = GeneratedColumn<String>(
      'reviewed_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _trackAtReviewMeta =
      const VerificationMeta('trackAtReview');
  @override
  late final GeneratedColumn<String> trackAtReview = GeneratedColumn<String>(
      'track_at_review', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _gradeMeta = const VerificationMeta('grade');
  @override
  late final GeneratedColumn<String> grade = GeneratedColumn<String>(
      'grade', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _errorLinesJsonMeta =
      const VerificationMeta('errorLinesJson');
  @override
  late final GeneratedColumn<String> errorLinesJson = GeneratedColumn<String>(
      'error_lines_json', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _elapsedDaysMeta =
      const VerificationMeta('elapsedDays');
  @override
  late final GeneratedColumn<int> elapsedDays = GeneratedColumn<int>(
      'elapsed_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _rPredictedMeta =
      const VerificationMeta('rPredicted');
  @override
  late final GeneratedColumn<double> rPredicted = GeneratedColumn<double>(
      'r_predicted', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sBeforeMeta =
      const VerificationMeta('sBefore');
  @override
  late final GeneratedColumn<double> sBefore = GeneratedColumn<double>(
      's_before', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sAfterMeta = const VerificationMeta('sAfter');
  @override
  late final GeneratedColumn<double> sAfter = GeneratedColumn<double>(
      's_after', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dBeforeMeta =
      const VerificationMeta('dBefore');
  @override
  late final GeneratedColumn<double> dBefore = GeneratedColumn<double>(
      'd_before', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _dAfterMeta = const VerificationMeta('dAfter');
  @override
  late final GeneratedColumn<double> dAfter = GeneratedColumn<double>(
      'd_after', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
      'source', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teacherLabelMeta =
      const VerificationMeta('teacherLabel');
  @override
  late final GeneratedColumn<String> teacherLabel = GeneratedColumn<String>(
      'teacher_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        logId,
        profileId,
        pageId,
        reviewedAt,
        trackAtReview,
        grade,
        errorLinesJson,
        elapsedDays,
        rPredicted,
        sBefore,
        sAfter,
        dBefore,
        dAfter,
        source,
        teacherLabel
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'review_log';
  @override
  VerificationContext validateIntegrity(Insertable<ReviewLogRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('log_id')) {
      context.handle(
          _logIdMeta, logId.isAcceptableOrUnknown(data['log_id']!, _logIdMeta));
    } else if (isInserting) {
      context.missing(_logIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('page_id')) {
      context.handle(_pageIdMeta,
          pageId.isAcceptableOrUnknown(data['page_id']!, _pageIdMeta));
    } else if (isInserting) {
      context.missing(_pageIdMeta);
    }
    if (data.containsKey('reviewed_at')) {
      context.handle(
          _reviewedAtMeta,
          reviewedAt.isAcceptableOrUnknown(
              data['reviewed_at']!, _reviewedAtMeta));
    } else if (isInserting) {
      context.missing(_reviewedAtMeta);
    }
    if (data.containsKey('track_at_review')) {
      context.handle(
          _trackAtReviewMeta,
          trackAtReview.isAcceptableOrUnknown(
              data['track_at_review']!, _trackAtReviewMeta));
    } else if (isInserting) {
      context.missing(_trackAtReviewMeta);
    }
    if (data.containsKey('grade')) {
      context.handle(
          _gradeMeta, grade.isAcceptableOrUnknown(data['grade']!, _gradeMeta));
    } else if (isInserting) {
      context.missing(_gradeMeta);
    }
    if (data.containsKey('error_lines_json')) {
      context.handle(
          _errorLinesJsonMeta,
          errorLinesJson.isAcceptableOrUnknown(
              data['error_lines_json']!, _errorLinesJsonMeta));
    }
    if (data.containsKey('elapsed_days')) {
      context.handle(
          _elapsedDaysMeta,
          elapsedDays.isAcceptableOrUnknown(
              data['elapsed_days']!, _elapsedDaysMeta));
    } else if (isInserting) {
      context.missing(_elapsedDaysMeta);
    }
    if (data.containsKey('r_predicted')) {
      context.handle(
          _rPredictedMeta,
          rPredicted.isAcceptableOrUnknown(
              data['r_predicted']!, _rPredictedMeta));
    }
    if (data.containsKey('s_before')) {
      context.handle(_sBeforeMeta,
          sBefore.isAcceptableOrUnknown(data['s_before']!, _sBeforeMeta));
    }
    if (data.containsKey('s_after')) {
      context.handle(_sAfterMeta,
          sAfter.isAcceptableOrUnknown(data['s_after']!, _sAfterMeta));
    }
    if (data.containsKey('d_before')) {
      context.handle(_dBeforeMeta,
          dBefore.isAcceptableOrUnknown(data['d_before']!, _dBeforeMeta));
    }
    if (data.containsKey('d_after')) {
      context.handle(_dAfterMeta,
          dAfter.isAcceptableOrUnknown(data['d_after']!, _dAfterMeta));
    }
    if (data.containsKey('source')) {
      context.handle(_sourceMeta,
          source.isAcceptableOrUnknown(data['source']!, _sourceMeta));
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    if (data.containsKey('teacher_label')) {
      context.handle(
          _teacherLabelMeta,
          teacherLabel.isAcceptableOrUnknown(
              data['teacher_label']!, _teacherLabelMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {logId};
  @override
  ReviewLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReviewLogRow(
      logId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}log_id'])!,
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      pageId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}page_id'])!,
      reviewedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reviewed_at'])!,
      trackAtReview: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}track_at_review'])!,
      grade: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}grade'])!,
      errorLinesJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}error_lines_json']),
      elapsedDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}elapsed_days'])!,
      rPredicted: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}r_predicted']),
      sBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}s_before']),
      sAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}s_after']),
      dBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}d_before']),
      dAfter: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}d_after']),
      source: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source'])!,
      teacherLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher_label']),
    );
  }

  @override
  $ReviewLogTable createAlias(String alias) {
    return $ReviewLogTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ReviewLogRow extends DataClass implements Insertable<ReviewLogRow> {
  /// The log-row UUID (PK).
  final String logId;

  /// The owning profile (FK, `ON DELETE CASCADE`).
  final String profileId;

  /// The muṣḥaf page reviewed (FK into `page`, no cascade).
  final int pageId;

  /// The event wall-clock moment — UTC ISO-8601 TEXT, never a scheduling day.
  final String reviewedAt;

  /// The track at the moment of review.
  final String trackAtReview;

  /// The four-level grade assigned.
  final String grade;

  /// Stumble line indices (small structural list), or null — never text.
  final String? errorLinesJson;

  /// The `CalendarDate`-serial day delta fed to the curve.
  final int elapsedDays;

  /// Predicted retrievability `R` (audit double), or null.
  final double? rPredicted;

  /// Stability `S` before (audit double), or null.
  final double? sBefore;

  /// Stability `S` after (audit double), or null.
  final double? sAfter;

  /// Difficulty `D` before (audit double), or null.
  final double? dBefore;

  /// Difficulty `D` after (audit double), or null.
  final double? dAfter;

  /// `self` (reveal-on-tap) or `teacher` (talaqqī sign-off).
  final String source;

  /// Optional local *sanad* audit hint naming the signing teacher, or null.
  final String? teacherLabel;
  const ReviewLogRow(
      {required this.logId,
      required this.profileId,
      required this.pageId,
      required this.reviewedAt,
      required this.trackAtReview,
      required this.grade,
      this.errorLinesJson,
      required this.elapsedDays,
      this.rPredicted,
      this.sBefore,
      this.sAfter,
      this.dBefore,
      this.dAfter,
      required this.source,
      this.teacherLabel});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['log_id'] = Variable<String>(logId);
    map['profile_id'] = Variable<String>(profileId);
    map['page_id'] = Variable<int>(pageId);
    map['reviewed_at'] = Variable<String>(reviewedAt);
    map['track_at_review'] = Variable<String>(trackAtReview);
    map['grade'] = Variable<String>(grade);
    if (!nullToAbsent || errorLinesJson != null) {
      map['error_lines_json'] = Variable<String>(errorLinesJson);
    }
    map['elapsed_days'] = Variable<int>(elapsedDays);
    if (!nullToAbsent || rPredicted != null) {
      map['r_predicted'] = Variable<double>(rPredicted);
    }
    if (!nullToAbsent || sBefore != null) {
      map['s_before'] = Variable<double>(sBefore);
    }
    if (!nullToAbsent || sAfter != null) {
      map['s_after'] = Variable<double>(sAfter);
    }
    if (!nullToAbsent || dBefore != null) {
      map['d_before'] = Variable<double>(dBefore);
    }
    if (!nullToAbsent || dAfter != null) {
      map['d_after'] = Variable<double>(dAfter);
    }
    map['source'] = Variable<String>(source);
    if (!nullToAbsent || teacherLabel != null) {
      map['teacher_label'] = Variable<String>(teacherLabel);
    }
    return map;
  }

  ReviewLogCompanion toCompanion(bool nullToAbsent) {
    return ReviewLogCompanion(
      logId: Value(logId),
      profileId: Value(profileId),
      pageId: Value(pageId),
      reviewedAt: Value(reviewedAt),
      trackAtReview: Value(trackAtReview),
      grade: Value(grade),
      errorLinesJson: errorLinesJson == null && nullToAbsent
          ? const Value.absent()
          : Value(errorLinesJson),
      elapsedDays: Value(elapsedDays),
      rPredicted: rPredicted == null && nullToAbsent
          ? const Value.absent()
          : Value(rPredicted),
      sBefore: sBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(sBefore),
      sAfter:
          sAfter == null && nullToAbsent ? const Value.absent() : Value(sAfter),
      dBefore: dBefore == null && nullToAbsent
          ? const Value.absent()
          : Value(dBefore),
      dAfter:
          dAfter == null && nullToAbsent ? const Value.absent() : Value(dAfter),
      source: Value(source),
      teacherLabel: teacherLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherLabel),
    );
  }

  factory ReviewLogRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReviewLogRow(
      logId: serializer.fromJson<String>(json['logId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      pageId: serializer.fromJson<int>(json['pageId']),
      reviewedAt: serializer.fromJson<String>(json['reviewedAt']),
      trackAtReview: serializer.fromJson<String>(json['trackAtReview']),
      grade: serializer.fromJson<String>(json['grade']),
      errorLinesJson: serializer.fromJson<String?>(json['errorLinesJson']),
      elapsedDays: serializer.fromJson<int>(json['elapsedDays']),
      rPredicted: serializer.fromJson<double?>(json['rPredicted']),
      sBefore: serializer.fromJson<double?>(json['sBefore']),
      sAfter: serializer.fromJson<double?>(json['sAfter']),
      dBefore: serializer.fromJson<double?>(json['dBefore']),
      dAfter: serializer.fromJson<double?>(json['dAfter']),
      source: serializer.fromJson<String>(json['source']),
      teacherLabel: serializer.fromJson<String?>(json['teacherLabel']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'logId': serializer.toJson<String>(logId),
      'profileId': serializer.toJson<String>(profileId),
      'pageId': serializer.toJson<int>(pageId),
      'reviewedAt': serializer.toJson<String>(reviewedAt),
      'trackAtReview': serializer.toJson<String>(trackAtReview),
      'grade': serializer.toJson<String>(grade),
      'errorLinesJson': serializer.toJson<String?>(errorLinesJson),
      'elapsedDays': serializer.toJson<int>(elapsedDays),
      'rPredicted': serializer.toJson<double?>(rPredicted),
      'sBefore': serializer.toJson<double?>(sBefore),
      'sAfter': serializer.toJson<double?>(sAfter),
      'dBefore': serializer.toJson<double?>(dBefore),
      'dAfter': serializer.toJson<double?>(dAfter),
      'source': serializer.toJson<String>(source),
      'teacherLabel': serializer.toJson<String?>(teacherLabel),
    };
  }

  ReviewLogRow copyWith(
          {String? logId,
          String? profileId,
          int? pageId,
          String? reviewedAt,
          String? trackAtReview,
          String? grade,
          Value<String?> errorLinesJson = const Value.absent(),
          int? elapsedDays,
          Value<double?> rPredicted = const Value.absent(),
          Value<double?> sBefore = const Value.absent(),
          Value<double?> sAfter = const Value.absent(),
          Value<double?> dBefore = const Value.absent(),
          Value<double?> dAfter = const Value.absent(),
          String? source,
          Value<String?> teacherLabel = const Value.absent()}) =>
      ReviewLogRow(
        logId: logId ?? this.logId,
        profileId: profileId ?? this.profileId,
        pageId: pageId ?? this.pageId,
        reviewedAt: reviewedAt ?? this.reviewedAt,
        trackAtReview: trackAtReview ?? this.trackAtReview,
        grade: grade ?? this.grade,
        errorLinesJson:
            errorLinesJson.present ? errorLinesJson.value : this.errorLinesJson,
        elapsedDays: elapsedDays ?? this.elapsedDays,
        rPredicted: rPredicted.present ? rPredicted.value : this.rPredicted,
        sBefore: sBefore.present ? sBefore.value : this.sBefore,
        sAfter: sAfter.present ? sAfter.value : this.sAfter,
        dBefore: dBefore.present ? dBefore.value : this.dBefore,
        dAfter: dAfter.present ? dAfter.value : this.dAfter,
        source: source ?? this.source,
        teacherLabel:
            teacherLabel.present ? teacherLabel.value : this.teacherLabel,
      );
  ReviewLogRow copyWithCompanion(ReviewLogCompanion data) {
    return ReviewLogRow(
      logId: data.logId.present ? data.logId.value : this.logId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      pageId: data.pageId.present ? data.pageId.value : this.pageId,
      reviewedAt:
          data.reviewedAt.present ? data.reviewedAt.value : this.reviewedAt,
      trackAtReview: data.trackAtReview.present
          ? data.trackAtReview.value
          : this.trackAtReview,
      grade: data.grade.present ? data.grade.value : this.grade,
      errorLinesJson: data.errorLinesJson.present
          ? data.errorLinesJson.value
          : this.errorLinesJson,
      elapsedDays:
          data.elapsedDays.present ? data.elapsedDays.value : this.elapsedDays,
      rPredicted:
          data.rPredicted.present ? data.rPredicted.value : this.rPredicted,
      sBefore: data.sBefore.present ? data.sBefore.value : this.sBefore,
      sAfter: data.sAfter.present ? data.sAfter.value : this.sAfter,
      dBefore: data.dBefore.present ? data.dBefore.value : this.dBefore,
      dAfter: data.dAfter.present ? data.dAfter.value : this.dAfter,
      source: data.source.present ? data.source.value : this.source,
      teacherLabel: data.teacherLabel.present
          ? data.teacherLabel.value
          : this.teacherLabel,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogRow(')
          ..write('logId: $logId, ')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('trackAtReview: $trackAtReview, ')
          ..write('grade: $grade, ')
          ..write('errorLinesJson: $errorLinesJson, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('rPredicted: $rPredicted, ')
          ..write('sBefore: $sBefore, ')
          ..write('sAfter: $sAfter, ')
          ..write('dBefore: $dBefore, ')
          ..write('dAfter: $dAfter, ')
          ..write('source: $source, ')
          ..write('teacherLabel: $teacherLabel')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      logId,
      profileId,
      pageId,
      reviewedAt,
      trackAtReview,
      grade,
      errorLinesJson,
      elapsedDays,
      rPredicted,
      sBefore,
      sAfter,
      dBefore,
      dAfter,
      source,
      teacherLabel);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReviewLogRow &&
          other.logId == this.logId &&
          other.profileId == this.profileId &&
          other.pageId == this.pageId &&
          other.reviewedAt == this.reviewedAt &&
          other.trackAtReview == this.trackAtReview &&
          other.grade == this.grade &&
          other.errorLinesJson == this.errorLinesJson &&
          other.elapsedDays == this.elapsedDays &&
          other.rPredicted == this.rPredicted &&
          other.sBefore == this.sBefore &&
          other.sAfter == this.sAfter &&
          other.dBefore == this.dBefore &&
          other.dAfter == this.dAfter &&
          other.source == this.source &&
          other.teacherLabel == this.teacherLabel);
}

class ReviewLogCompanion extends UpdateCompanion<ReviewLogRow> {
  final Value<String> logId;
  final Value<String> profileId;
  final Value<int> pageId;
  final Value<String> reviewedAt;
  final Value<String> trackAtReview;
  final Value<String> grade;
  final Value<String?> errorLinesJson;
  final Value<int> elapsedDays;
  final Value<double?> rPredicted;
  final Value<double?> sBefore;
  final Value<double?> sAfter;
  final Value<double?> dBefore;
  final Value<double?> dAfter;
  final Value<String> source;
  final Value<String?> teacherLabel;
  final Value<int> rowid;
  const ReviewLogCompanion({
    this.logId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.pageId = const Value.absent(),
    this.reviewedAt = const Value.absent(),
    this.trackAtReview = const Value.absent(),
    this.grade = const Value.absent(),
    this.errorLinesJson = const Value.absent(),
    this.elapsedDays = const Value.absent(),
    this.rPredicted = const Value.absent(),
    this.sBefore = const Value.absent(),
    this.sAfter = const Value.absent(),
    this.dBefore = const Value.absent(),
    this.dAfter = const Value.absent(),
    this.source = const Value.absent(),
    this.teacherLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReviewLogCompanion.insert({
    required String logId,
    required String profileId,
    required int pageId,
    required String reviewedAt,
    required String trackAtReview,
    required String grade,
    this.errorLinesJson = const Value.absent(),
    required int elapsedDays,
    this.rPredicted = const Value.absent(),
    this.sBefore = const Value.absent(),
    this.sAfter = const Value.absent(),
    this.dBefore = const Value.absent(),
    this.dAfter = const Value.absent(),
    required String source,
    this.teacherLabel = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : logId = Value(logId),
        profileId = Value(profileId),
        pageId = Value(pageId),
        reviewedAt = Value(reviewedAt),
        trackAtReview = Value(trackAtReview),
        grade = Value(grade),
        elapsedDays = Value(elapsedDays),
        source = Value(source);
  static Insertable<ReviewLogRow> custom({
    Expression<String>? logId,
    Expression<String>? profileId,
    Expression<int>? pageId,
    Expression<String>? reviewedAt,
    Expression<String>? trackAtReview,
    Expression<String>? grade,
    Expression<String>? errorLinesJson,
    Expression<int>? elapsedDays,
    Expression<double>? rPredicted,
    Expression<double>? sBefore,
    Expression<double>? sAfter,
    Expression<double>? dBefore,
    Expression<double>? dAfter,
    Expression<String>? source,
    Expression<String>? teacherLabel,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (logId != null) 'log_id': logId,
      if (profileId != null) 'profile_id': profileId,
      if (pageId != null) 'page_id': pageId,
      if (reviewedAt != null) 'reviewed_at': reviewedAt,
      if (trackAtReview != null) 'track_at_review': trackAtReview,
      if (grade != null) 'grade': grade,
      if (errorLinesJson != null) 'error_lines_json': errorLinesJson,
      if (elapsedDays != null) 'elapsed_days': elapsedDays,
      if (rPredicted != null) 'r_predicted': rPredicted,
      if (sBefore != null) 's_before': sBefore,
      if (sAfter != null) 's_after': sAfter,
      if (dBefore != null) 'd_before': dBefore,
      if (dAfter != null) 'd_after': dAfter,
      if (source != null) 'source': source,
      if (teacherLabel != null) 'teacher_label': teacherLabel,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReviewLogCompanion copyWith(
      {Value<String>? logId,
      Value<String>? profileId,
      Value<int>? pageId,
      Value<String>? reviewedAt,
      Value<String>? trackAtReview,
      Value<String>? grade,
      Value<String?>? errorLinesJson,
      Value<int>? elapsedDays,
      Value<double?>? rPredicted,
      Value<double?>? sBefore,
      Value<double?>? sAfter,
      Value<double?>? dBefore,
      Value<double?>? dAfter,
      Value<String>? source,
      Value<String?>? teacherLabel,
      Value<int>? rowid}) {
    return ReviewLogCompanion(
      logId: logId ?? this.logId,
      profileId: profileId ?? this.profileId,
      pageId: pageId ?? this.pageId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      trackAtReview: trackAtReview ?? this.trackAtReview,
      grade: grade ?? this.grade,
      errorLinesJson: errorLinesJson ?? this.errorLinesJson,
      elapsedDays: elapsedDays ?? this.elapsedDays,
      rPredicted: rPredicted ?? this.rPredicted,
      sBefore: sBefore ?? this.sBefore,
      sAfter: sAfter ?? this.sAfter,
      dBefore: dBefore ?? this.dBefore,
      dAfter: dAfter ?? this.dAfter,
      source: source ?? this.source,
      teacherLabel: teacherLabel ?? this.teacherLabel,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (logId.present) {
      map['log_id'] = Variable<String>(logId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (pageId.present) {
      map['page_id'] = Variable<int>(pageId.value);
    }
    if (reviewedAt.present) {
      map['reviewed_at'] = Variable<String>(reviewedAt.value);
    }
    if (trackAtReview.present) {
      map['track_at_review'] = Variable<String>(trackAtReview.value);
    }
    if (grade.present) {
      map['grade'] = Variable<String>(grade.value);
    }
    if (errorLinesJson.present) {
      map['error_lines_json'] = Variable<String>(errorLinesJson.value);
    }
    if (elapsedDays.present) {
      map['elapsed_days'] = Variable<int>(elapsedDays.value);
    }
    if (rPredicted.present) {
      map['r_predicted'] = Variable<double>(rPredicted.value);
    }
    if (sBefore.present) {
      map['s_before'] = Variable<double>(sBefore.value);
    }
    if (sAfter.present) {
      map['s_after'] = Variable<double>(sAfter.value);
    }
    if (dBefore.present) {
      map['d_before'] = Variable<double>(dBefore.value);
    }
    if (dAfter.present) {
      map['d_after'] = Variable<double>(dAfter.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (teacherLabel.present) {
      map['teacher_label'] = Variable<String>(teacherLabel.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReviewLogCompanion(')
          ..write('logId: $logId, ')
          ..write('profileId: $profileId, ')
          ..write('pageId: $pageId, ')
          ..write('reviewedAt: $reviewedAt, ')
          ..write('trackAtReview: $trackAtReview, ')
          ..write('grade: $grade, ')
          ..write('errorLinesJson: $errorLinesJson, ')
          ..write('elapsedDays: $elapsedDays, ')
          ..write('rPredicted: $rPredicted, ')
          ..write('sBefore: $sBefore, ')
          ..write('sAfter: $sAfter, ')
          ..write('dBefore: $dBefore, ')
          ..write('dAfter: $dAfter, ')
          ..write('source: $source, ')
          ..write('teacherLabel: $teacherLabel, ')
          ..write('rowid: $rowid')
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

class $ConfusionEdgesTable extends ConfusionEdges
    with TableInfo<$ConfusionEdgesTable, ConfusionEdgeRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfusionEdgesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES profile (profile_id) ON DELETE CASCADE'));
  static const VerificationMeta _ayahAMeta = const VerificationMeta('ayahA');
  @override
  late final GeneratedColumn<String> ayahA = GeneratedColumn<String>(
      'ayah_a', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ayah (ayah_id)'));
  static const VerificationMeta _ayahBMeta = const VerificationMeta('ayahB');
  @override
  late final GeneratedColumn<String> ayahB = GeneratedColumn<String>(
      'ayah_b', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ayah (ayah_id)'));
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
      'weight', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _lastConfusedAtMeta =
      const VerificationMeta('lastConfusedAt');
  @override
  late final GeneratedColumn<String> lastConfusedAt = GeneratedColumn<String>(
      'last_confused_at', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [profileId, ayahA, ayahB, weight, lastConfusedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'confusion_edge';
  @override
  VerificationContext validateIntegrity(Insertable<ConfusionEdgeRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('ayah_a')) {
      context.handle(
          _ayahAMeta, ayahA.isAcceptableOrUnknown(data['ayah_a']!, _ayahAMeta));
    } else if (isInserting) {
      context.missing(_ayahAMeta);
    }
    if (data.containsKey('ayah_b')) {
      context.handle(
          _ayahBMeta, ayahB.isAcceptableOrUnknown(data['ayah_b']!, _ayahBMeta));
    } else if (isInserting) {
      context.missing(_ayahBMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(_weightMeta,
          weight.isAcceptableOrUnknown(data['weight']!, _weightMeta));
    }
    if (data.containsKey('last_confused_at')) {
      context.handle(
          _lastConfusedAtMeta,
          lastConfusedAt.isAcceptableOrUnknown(
              data['last_confused_at']!, _lastConfusedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId, ayahA, ayahB};
  @override
  ConfusionEdgeRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfusionEdgeRow(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      ayahA: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ayah_a'])!,
      ayahB: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ayah_b'])!,
      weight: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight'])!,
      lastConfusedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_confused_at']),
    );
  }

  @override
  $ConfusionEdgesTable createAlias(String alias) {
    return $ConfusionEdgesTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class ConfusionEdgeRow extends DataClass
    implements Insertable<ConfusionEdgeRow> {
  /// The owning profile (FK, `ON DELETE CASCADE`).
  final String profileId;

  /// The smaller āyah id of the pair (FK into `ayah`, no cascade).
  final String ayahA;

  /// The larger āyah id of the pair (FK into `ayah`, no cascade).
  final String ayahB;

  /// How strongly this profile confuses the pair — a running count, default 0.
  final double weight;

  /// When last confused — UTC instant TEXT, or null.
  final String? lastConfusedAt;
  const ConfusionEdgeRow(
      {required this.profileId,
      required this.ayahA,
      required this.ayahB,
      required this.weight,
      this.lastConfusedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['ayah_a'] = Variable<String>(ayahA);
    map['ayah_b'] = Variable<String>(ayahB);
    map['weight'] = Variable<double>(weight);
    if (!nullToAbsent || lastConfusedAt != null) {
      map['last_confused_at'] = Variable<String>(lastConfusedAt);
    }
    return map;
  }

  ConfusionEdgesCompanion toCompanion(bool nullToAbsent) {
    return ConfusionEdgesCompanion(
      profileId: Value(profileId),
      ayahA: Value(ayahA),
      ayahB: Value(ayahB),
      weight: Value(weight),
      lastConfusedAt: lastConfusedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastConfusedAt),
    );
  }

  factory ConfusionEdgeRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfusionEdgeRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      ayahA: serializer.fromJson<String>(json['ayahA']),
      ayahB: serializer.fromJson<String>(json['ayahB']),
      weight: serializer.fromJson<double>(json['weight']),
      lastConfusedAt: serializer.fromJson<String?>(json['lastConfusedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'ayahA': serializer.toJson<String>(ayahA),
      'ayahB': serializer.toJson<String>(ayahB),
      'weight': serializer.toJson<double>(weight),
      'lastConfusedAt': serializer.toJson<String?>(lastConfusedAt),
    };
  }

  ConfusionEdgeRow copyWith(
          {String? profileId,
          String? ayahA,
          String? ayahB,
          double? weight,
          Value<String?> lastConfusedAt = const Value.absent()}) =>
      ConfusionEdgeRow(
        profileId: profileId ?? this.profileId,
        ayahA: ayahA ?? this.ayahA,
        ayahB: ayahB ?? this.ayahB,
        weight: weight ?? this.weight,
        lastConfusedAt:
            lastConfusedAt.present ? lastConfusedAt.value : this.lastConfusedAt,
      );
  ConfusionEdgeRow copyWithCompanion(ConfusionEdgesCompanion data) {
    return ConfusionEdgeRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      ayahA: data.ayahA.present ? data.ayahA.value : this.ayahA,
      ayahB: data.ayahB.present ? data.ayahB.value : this.ayahB,
      weight: data.weight.present ? data.weight.value : this.weight,
      lastConfusedAt: data.lastConfusedAt.present
          ? data.lastConfusedAt.value
          : this.lastConfusedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfusionEdgeRow(')
          ..write('profileId: $profileId, ')
          ..write('ayahA: $ayahA, ')
          ..write('ayahB: $ayahB, ')
          ..write('weight: $weight, ')
          ..write('lastConfusedAt: $lastConfusedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(profileId, ayahA, ayahB, weight, lastConfusedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfusionEdgeRow &&
          other.profileId == this.profileId &&
          other.ayahA == this.ayahA &&
          other.ayahB == this.ayahB &&
          other.weight == this.weight &&
          other.lastConfusedAt == this.lastConfusedAt);
}

class ConfusionEdgesCompanion extends UpdateCompanion<ConfusionEdgeRow> {
  final Value<String> profileId;
  final Value<String> ayahA;
  final Value<String> ayahB;
  final Value<double> weight;
  final Value<String?> lastConfusedAt;
  final Value<int> rowid;
  const ConfusionEdgesCompanion({
    this.profileId = const Value.absent(),
    this.ayahA = const Value.absent(),
    this.ayahB = const Value.absent(),
    this.weight = const Value.absent(),
    this.lastConfusedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfusionEdgesCompanion.insert({
    required String profileId,
    required String ayahA,
    required String ayahB,
    this.weight = const Value.absent(),
    this.lastConfusedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        ayahA = Value(ayahA),
        ayahB = Value(ayahB);
  static Insertable<ConfusionEdgeRow> custom({
    Expression<String>? profileId,
    Expression<String>? ayahA,
    Expression<String>? ayahB,
    Expression<double>? weight,
    Expression<String>? lastConfusedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (ayahA != null) 'ayah_a': ayahA,
      if (ayahB != null) 'ayah_b': ayahB,
      if (weight != null) 'weight': weight,
      if (lastConfusedAt != null) 'last_confused_at': lastConfusedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfusionEdgesCompanion copyWith(
      {Value<String>? profileId,
      Value<String>? ayahA,
      Value<String>? ayahB,
      Value<double>? weight,
      Value<String?>? lastConfusedAt,
      Value<int>? rowid}) {
    return ConfusionEdgesCompanion(
      profileId: profileId ?? this.profileId,
      ayahA: ayahA ?? this.ayahA,
      ayahB: ayahB ?? this.ayahB,
      weight: weight ?? this.weight,
      lastConfusedAt: lastConfusedAt ?? this.lastConfusedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (ayahA.present) {
      map['ayah_a'] = Variable<String>(ayahA.value);
    }
    if (ayahB.present) {
      map['ayah_b'] = Variable<String>(ayahB.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (lastConfusedAt.present) {
      map['last_confused_at'] = Variable<String>(lastConfusedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfusionEdgesCompanion(')
          ..write('profileId: $profileId, ')
          ..write('ayahA: $ayahA, ')
          ..write('ayahB: $ayahB, ')
          ..write('weight: $weight, ')
          ..write('lastConfusedAt: $lastConfusedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CycleConfigsTable extends CycleConfigs
    with TableInfo<$CycleConfigsTable, CycleConfigRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CycleConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _profileIdMeta =
      const VerificationMeta('profileId');
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
      'profile_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES profile (profile_id) ON DELETE CASCADE'));
  static const VerificationMeta _cycleTypeMeta =
      const VerificationMeta('cycleType');
  @override
  late final GeneratedColumn<String> cycleType = GeneratedColumn<String>(
      'cycle_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _newLinesPerDayMeta =
      const VerificationMeta('newLinesPerDay');
  @override
  late final GeneratedColumn<int> newLinesPerDay = GeneratedColumn<int>(
      'new_lines_per_day', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _nearWindowJuzMeta =
      const VerificationMeta('nearWindowJuz');
  @override
  late final GeneratedColumn<int> nearWindowJuz = GeneratedColumn<int>(
      'near_window_juz', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _farTargetPerDayMeta =
      const VerificationMeta('farTargetPerDay');
  @override
  late final GeneratedColumn<int> farTargetPerDay = GeneratedColumn<int>(
      'far_target_per_day', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _farCycleDaysMeta =
      const VerificationMeta('farCycleDays');
  @override
  late final GeneratedColumn<int> farCycleDays = GeneratedColumn<int>(
      'far_cycle_days', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dailyBudgetMinutesMeta =
      const VerificationMeta('dailyBudgetMinutes');
  @override
  late final GeneratedColumn<int> dailyBudgetMinutes = GeneratedColumn<int>(
      'daily_budget_minutes', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _pureCycleModeMeta =
      const VerificationMeta('pureCycleMode');
  @override
  late final GeneratedColumn<bool> pureCycleMode = GeneratedColumn<bool>(
      'pure_cycle_mode', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("pure_cycle_mode" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _termLabelSetMeta =
      const VerificationMeta('termLabelSet');
  @override
  late final GeneratedColumn<String> termLabelSet = GeneratedColumn<String>(
      'term_label_set', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _regionPresetMeta =
      const VerificationMeta('regionPreset');
  @override
  late final GeneratedColumn<String> regionPreset = GeneratedColumn<String>(
      'region_preset', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        profileId,
        cycleType,
        newLinesPerDay,
        nearWindowJuz,
        farTargetPerDay,
        farCycleDays,
        dailyBudgetMinutes,
        pureCycleMode,
        termLabelSet,
        regionPreset
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cycle_config';
  @override
  VerificationContext validateIntegrity(Insertable<CycleConfigRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('profile_id')) {
      context.handle(_profileIdMeta,
          profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta));
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('cycle_type')) {
      context.handle(_cycleTypeMeta,
          cycleType.isAcceptableOrUnknown(data['cycle_type']!, _cycleTypeMeta));
    } else if (isInserting) {
      context.missing(_cycleTypeMeta);
    }
    if (data.containsKey('new_lines_per_day')) {
      context.handle(
          _newLinesPerDayMeta,
          newLinesPerDay.isAcceptableOrUnknown(
              data['new_lines_per_day']!, _newLinesPerDayMeta));
    }
    if (data.containsKey('near_window_juz')) {
      context.handle(
          _nearWindowJuzMeta,
          nearWindowJuz.isAcceptableOrUnknown(
              data['near_window_juz']!, _nearWindowJuzMeta));
    } else if (isInserting) {
      context.missing(_nearWindowJuzMeta);
    }
    if (data.containsKey('far_target_per_day')) {
      context.handle(
          _farTargetPerDayMeta,
          farTargetPerDay.isAcceptableOrUnknown(
              data['far_target_per_day']!, _farTargetPerDayMeta));
    } else if (isInserting) {
      context.missing(_farTargetPerDayMeta);
    }
    if (data.containsKey('far_cycle_days')) {
      context.handle(
          _farCycleDaysMeta,
          farCycleDays.isAcceptableOrUnknown(
              data['far_cycle_days']!, _farCycleDaysMeta));
    } else if (isInserting) {
      context.missing(_farCycleDaysMeta);
    }
    if (data.containsKey('daily_budget_minutes')) {
      context.handle(
          _dailyBudgetMinutesMeta,
          dailyBudgetMinutes.isAcceptableOrUnknown(
              data['daily_budget_minutes']!, _dailyBudgetMinutesMeta));
    } else if (isInserting) {
      context.missing(_dailyBudgetMinutesMeta);
    }
    if (data.containsKey('pure_cycle_mode')) {
      context.handle(
          _pureCycleModeMeta,
          pureCycleMode.isAcceptableOrUnknown(
              data['pure_cycle_mode']!, _pureCycleModeMeta));
    }
    if (data.containsKey('term_label_set')) {
      context.handle(
          _termLabelSetMeta,
          termLabelSet.isAcceptableOrUnknown(
              data['term_label_set']!, _termLabelSetMeta));
    } else if (isInserting) {
      context.missing(_termLabelSetMeta);
    }
    if (data.containsKey('region_preset')) {
      context.handle(
          _regionPresetMeta,
          regionPreset.isAcceptableOrUnknown(
              data['region_preset']!, _regionPresetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {profileId};
  @override
  CycleConfigRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CycleConfigRow(
      profileId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}profile_id'])!,
      cycleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}cycle_type'])!,
      newLinesPerDay: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}new_lines_per_day'])!,
      nearWindowJuz: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}near_window_juz'])!,
      farTargetPerDay: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}far_target_per_day'])!,
      farCycleDays: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}far_cycle_days'])!,
      dailyBudgetMinutes: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}daily_budget_minutes'])!,
      pureCycleMode: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}pure_cycle_mode'])!,
      termLabelSet: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}term_label_set'])!,
      regionPreset: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region_preset']),
    );
  }

  @override
  $CycleConfigsTable createAlias(String alias) {
    return $CycleConfigsTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class CycleConfigRow extends DataClass implements Insertable<CycleConfigRow> {
  /// The owning profile — PK and FK (`ON DELETE CASCADE`).
  final String profileId;

  /// The named cycle preset (free TEXT, e.g. `7_manzil`).
  final String cycleType;

  /// New lines introduced per day (≥ 0).
  final int newLinesPerDay;

  /// The near-revision window width in juz (≥ 0).
  final int nearWindowJuz;

  /// The far-revision target pages per day (≥ 0).
  final int farTargetPerDay;

  /// The far-cycle ceiling in days (`> 0`; PRD §7.6).
  final int farCycleDays;

  /// The daily revision time budget in minutes (`> 0`).
  final int dailyBudgetMinutes;

  /// Whether pure-cycle mode is on.
  final bool pureCycleMode;

  /// The sabaq/sabqi/manzil term set the UI renders (a key into `l10n`).
  final String termLabelSet;

  /// An optional regional preset hint, or null.
  final String? regionPreset;
  const CycleConfigRow(
      {required this.profileId,
      required this.cycleType,
      required this.newLinesPerDay,
      required this.nearWindowJuz,
      required this.farTargetPerDay,
      required this.farCycleDays,
      required this.dailyBudgetMinutes,
      required this.pureCycleMode,
      required this.termLabelSet,
      this.regionPreset});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['profile_id'] = Variable<String>(profileId);
    map['cycle_type'] = Variable<String>(cycleType);
    map['new_lines_per_day'] = Variable<int>(newLinesPerDay);
    map['near_window_juz'] = Variable<int>(nearWindowJuz);
    map['far_target_per_day'] = Variable<int>(farTargetPerDay);
    map['far_cycle_days'] = Variable<int>(farCycleDays);
    map['daily_budget_minutes'] = Variable<int>(dailyBudgetMinutes);
    map['pure_cycle_mode'] = Variable<bool>(pureCycleMode);
    map['term_label_set'] = Variable<String>(termLabelSet);
    if (!nullToAbsent || regionPreset != null) {
      map['region_preset'] = Variable<String>(regionPreset);
    }
    return map;
  }

  CycleConfigsCompanion toCompanion(bool nullToAbsent) {
    return CycleConfigsCompanion(
      profileId: Value(profileId),
      cycleType: Value(cycleType),
      newLinesPerDay: Value(newLinesPerDay),
      nearWindowJuz: Value(nearWindowJuz),
      farTargetPerDay: Value(farTargetPerDay),
      farCycleDays: Value(farCycleDays),
      dailyBudgetMinutes: Value(dailyBudgetMinutes),
      pureCycleMode: Value(pureCycleMode),
      termLabelSet: Value(termLabelSet),
      regionPreset: regionPreset == null && nullToAbsent
          ? const Value.absent()
          : Value(regionPreset),
    );
  }

  factory CycleConfigRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CycleConfigRow(
      profileId: serializer.fromJson<String>(json['profileId']),
      cycleType: serializer.fromJson<String>(json['cycleType']),
      newLinesPerDay: serializer.fromJson<int>(json['newLinesPerDay']),
      nearWindowJuz: serializer.fromJson<int>(json['nearWindowJuz']),
      farTargetPerDay: serializer.fromJson<int>(json['farTargetPerDay']),
      farCycleDays: serializer.fromJson<int>(json['farCycleDays']),
      dailyBudgetMinutes: serializer.fromJson<int>(json['dailyBudgetMinutes']),
      pureCycleMode: serializer.fromJson<bool>(json['pureCycleMode']),
      termLabelSet: serializer.fromJson<String>(json['termLabelSet']),
      regionPreset: serializer.fromJson<String?>(json['regionPreset']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'profileId': serializer.toJson<String>(profileId),
      'cycleType': serializer.toJson<String>(cycleType),
      'newLinesPerDay': serializer.toJson<int>(newLinesPerDay),
      'nearWindowJuz': serializer.toJson<int>(nearWindowJuz),
      'farTargetPerDay': serializer.toJson<int>(farTargetPerDay),
      'farCycleDays': serializer.toJson<int>(farCycleDays),
      'dailyBudgetMinutes': serializer.toJson<int>(dailyBudgetMinutes),
      'pureCycleMode': serializer.toJson<bool>(pureCycleMode),
      'termLabelSet': serializer.toJson<String>(termLabelSet),
      'regionPreset': serializer.toJson<String?>(regionPreset),
    };
  }

  CycleConfigRow copyWith(
          {String? profileId,
          String? cycleType,
          int? newLinesPerDay,
          int? nearWindowJuz,
          int? farTargetPerDay,
          int? farCycleDays,
          int? dailyBudgetMinutes,
          bool? pureCycleMode,
          String? termLabelSet,
          Value<String?> regionPreset = const Value.absent()}) =>
      CycleConfigRow(
        profileId: profileId ?? this.profileId,
        cycleType: cycleType ?? this.cycleType,
        newLinesPerDay: newLinesPerDay ?? this.newLinesPerDay,
        nearWindowJuz: nearWindowJuz ?? this.nearWindowJuz,
        farTargetPerDay: farTargetPerDay ?? this.farTargetPerDay,
        farCycleDays: farCycleDays ?? this.farCycleDays,
        dailyBudgetMinutes: dailyBudgetMinutes ?? this.dailyBudgetMinutes,
        pureCycleMode: pureCycleMode ?? this.pureCycleMode,
        termLabelSet: termLabelSet ?? this.termLabelSet,
        regionPreset:
            regionPreset.present ? regionPreset.value : this.regionPreset,
      );
  CycleConfigRow copyWithCompanion(CycleConfigsCompanion data) {
    return CycleConfigRow(
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      cycleType: data.cycleType.present ? data.cycleType.value : this.cycleType,
      newLinesPerDay: data.newLinesPerDay.present
          ? data.newLinesPerDay.value
          : this.newLinesPerDay,
      nearWindowJuz: data.nearWindowJuz.present
          ? data.nearWindowJuz.value
          : this.nearWindowJuz,
      farTargetPerDay: data.farTargetPerDay.present
          ? data.farTargetPerDay.value
          : this.farTargetPerDay,
      farCycleDays: data.farCycleDays.present
          ? data.farCycleDays.value
          : this.farCycleDays,
      dailyBudgetMinutes: data.dailyBudgetMinutes.present
          ? data.dailyBudgetMinutes.value
          : this.dailyBudgetMinutes,
      pureCycleMode: data.pureCycleMode.present
          ? data.pureCycleMode.value
          : this.pureCycleMode,
      termLabelSet: data.termLabelSet.present
          ? data.termLabelSet.value
          : this.termLabelSet,
      regionPreset: data.regionPreset.present
          ? data.regionPreset.value
          : this.regionPreset,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CycleConfigRow(')
          ..write('profileId: $profileId, ')
          ..write('cycleType: $cycleType, ')
          ..write('newLinesPerDay: $newLinesPerDay, ')
          ..write('nearWindowJuz: $nearWindowJuz, ')
          ..write('farTargetPerDay: $farTargetPerDay, ')
          ..write('farCycleDays: $farCycleDays, ')
          ..write('dailyBudgetMinutes: $dailyBudgetMinutes, ')
          ..write('pureCycleMode: $pureCycleMode, ')
          ..write('termLabelSet: $termLabelSet, ')
          ..write('regionPreset: $regionPreset')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      profileId,
      cycleType,
      newLinesPerDay,
      nearWindowJuz,
      farTargetPerDay,
      farCycleDays,
      dailyBudgetMinutes,
      pureCycleMode,
      termLabelSet,
      regionPreset);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CycleConfigRow &&
          other.profileId == this.profileId &&
          other.cycleType == this.cycleType &&
          other.newLinesPerDay == this.newLinesPerDay &&
          other.nearWindowJuz == this.nearWindowJuz &&
          other.farTargetPerDay == this.farTargetPerDay &&
          other.farCycleDays == this.farCycleDays &&
          other.dailyBudgetMinutes == this.dailyBudgetMinutes &&
          other.pureCycleMode == this.pureCycleMode &&
          other.termLabelSet == this.termLabelSet &&
          other.regionPreset == this.regionPreset);
}

class CycleConfigsCompanion extends UpdateCompanion<CycleConfigRow> {
  final Value<String> profileId;
  final Value<String> cycleType;
  final Value<int> newLinesPerDay;
  final Value<int> nearWindowJuz;
  final Value<int> farTargetPerDay;
  final Value<int> farCycleDays;
  final Value<int> dailyBudgetMinutes;
  final Value<bool> pureCycleMode;
  final Value<String> termLabelSet;
  final Value<String?> regionPreset;
  final Value<int> rowid;
  const CycleConfigsCompanion({
    this.profileId = const Value.absent(),
    this.cycleType = const Value.absent(),
    this.newLinesPerDay = const Value.absent(),
    this.nearWindowJuz = const Value.absent(),
    this.farTargetPerDay = const Value.absent(),
    this.farCycleDays = const Value.absent(),
    this.dailyBudgetMinutes = const Value.absent(),
    this.pureCycleMode = const Value.absent(),
    this.termLabelSet = const Value.absent(),
    this.regionPreset = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CycleConfigsCompanion.insert({
    required String profileId,
    required String cycleType,
    this.newLinesPerDay = const Value.absent(),
    required int nearWindowJuz,
    required int farTargetPerDay,
    required int farCycleDays,
    required int dailyBudgetMinutes,
    this.pureCycleMode = const Value.absent(),
    required String termLabelSet,
    this.regionPreset = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : profileId = Value(profileId),
        cycleType = Value(cycleType),
        nearWindowJuz = Value(nearWindowJuz),
        farTargetPerDay = Value(farTargetPerDay),
        farCycleDays = Value(farCycleDays),
        dailyBudgetMinutes = Value(dailyBudgetMinutes),
        termLabelSet = Value(termLabelSet);
  static Insertable<CycleConfigRow> custom({
    Expression<String>? profileId,
    Expression<String>? cycleType,
    Expression<int>? newLinesPerDay,
    Expression<int>? nearWindowJuz,
    Expression<int>? farTargetPerDay,
    Expression<int>? farCycleDays,
    Expression<int>? dailyBudgetMinutes,
    Expression<bool>? pureCycleMode,
    Expression<String>? termLabelSet,
    Expression<String>? regionPreset,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (profileId != null) 'profile_id': profileId,
      if (cycleType != null) 'cycle_type': cycleType,
      if (newLinesPerDay != null) 'new_lines_per_day': newLinesPerDay,
      if (nearWindowJuz != null) 'near_window_juz': nearWindowJuz,
      if (farTargetPerDay != null) 'far_target_per_day': farTargetPerDay,
      if (farCycleDays != null) 'far_cycle_days': farCycleDays,
      if (dailyBudgetMinutes != null)
        'daily_budget_minutes': dailyBudgetMinutes,
      if (pureCycleMode != null) 'pure_cycle_mode': pureCycleMode,
      if (termLabelSet != null) 'term_label_set': termLabelSet,
      if (regionPreset != null) 'region_preset': regionPreset,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CycleConfigsCompanion copyWith(
      {Value<String>? profileId,
      Value<String>? cycleType,
      Value<int>? newLinesPerDay,
      Value<int>? nearWindowJuz,
      Value<int>? farTargetPerDay,
      Value<int>? farCycleDays,
      Value<int>? dailyBudgetMinutes,
      Value<bool>? pureCycleMode,
      Value<String>? termLabelSet,
      Value<String?>? regionPreset,
      Value<int>? rowid}) {
    return CycleConfigsCompanion(
      profileId: profileId ?? this.profileId,
      cycleType: cycleType ?? this.cycleType,
      newLinesPerDay: newLinesPerDay ?? this.newLinesPerDay,
      nearWindowJuz: nearWindowJuz ?? this.nearWindowJuz,
      farTargetPerDay: farTargetPerDay ?? this.farTargetPerDay,
      farCycleDays: farCycleDays ?? this.farCycleDays,
      dailyBudgetMinutes: dailyBudgetMinutes ?? this.dailyBudgetMinutes,
      pureCycleMode: pureCycleMode ?? this.pureCycleMode,
      termLabelSet: termLabelSet ?? this.termLabelSet,
      regionPreset: regionPreset ?? this.regionPreset,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (cycleType.present) {
      map['cycle_type'] = Variable<String>(cycleType.value);
    }
    if (newLinesPerDay.present) {
      map['new_lines_per_day'] = Variable<int>(newLinesPerDay.value);
    }
    if (nearWindowJuz.present) {
      map['near_window_juz'] = Variable<int>(nearWindowJuz.value);
    }
    if (farTargetPerDay.present) {
      map['far_target_per_day'] = Variable<int>(farTargetPerDay.value);
    }
    if (farCycleDays.present) {
      map['far_cycle_days'] = Variable<int>(farCycleDays.value);
    }
    if (dailyBudgetMinutes.present) {
      map['daily_budget_minutes'] = Variable<int>(dailyBudgetMinutes.value);
    }
    if (pureCycleMode.present) {
      map['pure_cycle_mode'] = Variable<bool>(pureCycleMode.value);
    }
    if (termLabelSet.present) {
      map['term_label_set'] = Variable<String>(termLabelSet.value);
    }
    if (regionPreset.present) {
      map['region_preset'] = Variable<String>(regionPreset.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CycleConfigsCompanion(')
          ..write('profileId: $profileId, ')
          ..write('cycleType: $cycleType, ')
          ..write('newLinesPerDay: $newLinesPerDay, ')
          ..write('nearWindowJuz: $nearWindowJuz, ')
          ..write('farTargetPerDay: $farTargetPerDay, ')
          ..write('farCycleDays: $farCycleDays, ')
          ..write('dailyBudgetMinutes: $dailyBudgetMinutes, ')
          ..write('pureCycleMode: $pureCycleMode, ')
          ..write('termLabelSet: $termLabelSet, ')
          ..write('regionPreset: $regionPreset, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(Insertable<AppMetaRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }

  @override
  bool get isStrict => true;
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  /// The meta key (PK).
  final String key;

  /// The meta value.
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppMetaRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) => AppMetaRow(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
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
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $SurahsTable surahs = $SurahsTable(this);
  late final $PagesTable pages = $PagesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $LineBlocksTable lineBlocks = $LineBlocksTable(this);
  late final $ReviewLogTable reviewLog = $ReviewLogTable(this);
  late final $AyatTable ayat = $AyatTable(this);
  late final $ConfusionEdgesTable confusionEdges = $ConfusionEdgesTable(this);
  late final $CycleConfigsTable cycleConfigs = $CycleConfigsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $LinesTable lines = $LinesTable(this);
  late final $MutashabihGroupsTable mutashabihGroups =
      $MutashabihGroupsTable(this);
  late final $MutashabihMembersTable mutashabihMembers =
      $MutashabihMembersTable(this);
  late final Index cardDue = Index(
      'card_due', 'CREATE INDEX card_due ON card (profile_id, track, due_at)');
  late final Index lineBlockByCard = Index('line_block_by_card',
      'CREATE INDEX line_block_by_card ON line_block (profile_id, page_id)');
  late final Index reviewLogByCard = Index('review_log_by_card',
      'CREATE INDEX review_log_by_card ON review_log (profile_id, page_id, reviewed_at)');
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
        profiles,
        surahs,
        pages,
        cards,
        lineBlocks,
        reviewLog,
        ayat,
        confusionEdges,
        cycleConfigs,
        appMeta,
        lines,
        mutashabihGroups,
        mutashabihMembers,
        cardDue,
        lineBlockByCard,
        reviewLogByCard,
        lineByPage,
        ayahByPage
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('profile',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('card', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profile',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('line_block', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profile',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('review_log', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profile',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('confusion_edge', kind: UpdateKind.delete),
            ],
          ),
          WritePropagation(
            on: TableUpdateQuery.onTableName('profile',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('cycle_config', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
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

final class $$MushafsTableReferences
    extends BaseReferences<_$HifzDatabase, $MushafsTable, MushafRow> {
  $$MushafsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProfilesTable, List<ProfileRow>>
      _profilesRefsTable(_$HifzDatabase db) => MultiTypedResultKey.fromTable(
          db.profiles,
          aliasName:
              $_aliasNameGenerator(db.mushafs.mushafId, db.profiles.mushafId));

  $$ProfilesTableProcessedTableManager get profilesRefs {
    final manager = $$ProfilesTableTableManager($_db, $_db.profiles).filter(
        (f) =>
            f.mushafId.mushafId.sqlEquals($_itemColumn<String>('mushaf_id')!));

    final cache = $_typedResult.readTableOrNull(_profilesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

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

  Expression<bool> profilesRefs(
      Expression<bool> Function($$ProfilesTableFilterComposer f) f) {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mushafId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.mushafId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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

  Expression<T> profilesRefs<T extends Object>(
      Expression<T> Function($$ProfilesTableAnnotationComposer a) f) {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mushafId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.mushafId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
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
    (MushafRow, $$MushafsTableReferences),
    MushafRow,
    PrefetchHooks Function({bool profilesRefs})> {
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
              .map((e) =>
                  (e.readTable(table), $$MushafsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({profilesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (profilesRefs) db.profiles],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (profilesRefs)
                    await $_getPrefetchedData<MushafRow, $MushafsTable,
                            ProfileRow>(
                        currentTable: table,
                        referencedTable:
                            $$MushafsTableReferences._profilesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$MushafsTableReferences(db, table, p0)
                                .profilesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.mushafId == item.mushafId),
                        typedResults: items)
                ];
              },
            );
          },
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
    (MushafRow, $$MushafsTableReferences),
    MushafRow,
    PrefetchHooks Function({bool profilesRefs})>;
typedef $$ProfilesTableCreateCompanionBuilder = ProfilesCompanion Function({
  required String profileId,
  required String displayName,
  required String role,
  required String locale,
  required String mushafId,
  required String createdAt,
  Value<String?> settingsJson,
  Value<int> rowid,
});
typedef $$ProfilesTableUpdateCompanionBuilder = ProfilesCompanion Function({
  Value<String> profileId,
  Value<String> displayName,
  Value<String> role,
  Value<String> locale,
  Value<String> mushafId,
  Value<String> createdAt,
  Value<String?> settingsJson,
  Value<int> rowid,
});

final class $$ProfilesTableReferences
    extends BaseReferences<_$HifzDatabase, $ProfilesTable, ProfileRow> {
  $$ProfilesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MushafsTable _mushafIdTable(_$HifzDatabase db) =>
      db.mushafs.createAlias(
          $_aliasNameGenerator(db.profiles.mushafId, db.mushafs.mushafId));

  $$MushafsTableProcessedTableManager get mushafId {
    final $_column = $_itemColumn<String>('mushaf_id')!;

    final manager = $$MushafsTableTableManager($_db, $_db.mushafs)
        .filter((f) => f.mushafId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_mushafIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$CardsTable, List<CardRow>> _cardsRefsTable(
          _$HifzDatabase db) =>
      MultiTypedResultKey.fromTable(db.cards,
          aliasName:
              $_aliasNameGenerator(db.profiles.profileId, db.cards.profileId));

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager($_db, $_db.cards).filter((f) =>
        f.profileId.profileId.sqlEquals($_itemColumn<String>('profile_id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LineBlocksTable, List<LineBlockRow>>
      _lineBlocksRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.lineBlocks,
              aliasName: $_aliasNameGenerator(
                  db.profiles.profileId, db.lineBlocks.profileId));

  $$LineBlocksTableProcessedTableManager get lineBlocksRefs {
    final manager = $$LineBlocksTableTableManager($_db, $_db.lineBlocks).filter(
        (f) => f.profileId.profileId
            .sqlEquals($_itemColumn<String>('profile_id')!));

    final cache = $_typedResult.readTableOrNull(_lineBlocksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReviewLogTable, List<ReviewLogRow>>
      _reviewLogRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.reviewLog,
              aliasName: $_aliasNameGenerator(
                  db.profiles.profileId, db.reviewLog.profileId));

  $$ReviewLogTableProcessedTableManager get reviewLogRefs {
    final manager = $$ReviewLogTableTableManager($_db, $_db.reviewLog).filter(
        (f) => f.profileId.profileId
            .sqlEquals($_itemColumn<String>('profile_id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConfusionEdgesTable, List<ConfusionEdgeRow>>
      _confusionEdgesRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.confusionEdges,
              aliasName: $_aliasNameGenerator(
                  db.profiles.profileId, db.confusionEdges.profileId));

  $$ConfusionEdgesTableProcessedTableManager get confusionEdgesRefs {
    final manager = $$ConfusionEdgesTableTableManager($_db, $_db.confusionEdges)
        .filter((f) => f.profileId.profileId
            .sqlEquals($_itemColumn<String>('profile_id')!));

    final cache = $_typedResult.readTableOrNull(_confusionEdgesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$CycleConfigsTable, List<CycleConfigRow>>
      _cycleConfigsRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.cycleConfigs,
              aliasName: $_aliasNameGenerator(
                  db.profiles.profileId, db.cycleConfigs.profileId));

  $$CycleConfigsTableProcessedTableManager get cycleConfigsRefs {
    final manager = $$CycleConfigsTableTableManager($_db, $_db.cycleConfigs)
        .filter((f) => f.profileId.profileId
            .sqlEquals($_itemColumn<String>('profile_id')!));

    final cache = $_typedResult.readTableOrNull(_cycleConfigsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ProfilesTableFilterComposer
    extends Composer<_$HifzDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson, builder: (column) => ColumnFilters(column));

  $$MushafsTableFilterComposer get mushafId {
    final $$MushafsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mushafId,
        referencedTable: $db.mushafs,
        getReferencedColumn: (t) => t.mushafId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MushafsTableFilterComposer(
              $db: $db,
              $table: $db.mushafs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> cardsRefs(
      Expression<bool> Function($$CardsTableFilterComposer f) f) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableFilterComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> lineBlocksRefs(
      Expression<bool> Function($$LineBlocksTableFilterComposer f) f) {
    final $$LineBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.lineBlocks,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LineBlocksTableFilterComposer(
              $db: $db,
              $table: $db.lineBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reviewLogRefs(
      Expression<bool> Function($$ReviewLogTableFilterComposer f) f) {
    final $$ReviewLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.reviewLog,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewLogTableFilterComposer(
              $db: $db,
              $table: $db.reviewLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> confusionEdgesRefs(
      Expression<bool> Function($$ConfusionEdgesTableFilterComposer f) f) {
    final $$ConfusionEdgesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableFilterComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> cycleConfigsRefs(
      Expression<bool> Function($$CycleConfigsTableFilterComposer f) f) {
    final $$CycleConfigsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.cycleConfigs,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CycleConfigsTableFilterComposer(
              $db: $db,
              $table: $db.cycleConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$HifzDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get profileId => $composableBuilder(
      column: $table.profileId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get role => $composableBuilder(
      column: $table.role, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get locale => $composableBuilder(
      column: $table.locale, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson,
      builder: (column) => ColumnOrderings(column));

  $$MushafsTableOrderingComposer get mushafId {
    final $$MushafsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mushafId,
        referencedTable: $db.mushafs,
        getReferencedColumn: (t) => t.mushafId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MushafsTableOrderingComposer(
              $db: $db,
              $table: $db.mushafs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$HifzDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
      column: $table.displayName, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get locale =>
      $composableBuilder(column: $table.locale, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get settingsJson => $composableBuilder(
      column: $table.settingsJson, builder: (column) => column);

  $$MushafsTableAnnotationComposer get mushafId {
    final $$MushafsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.mushafId,
        referencedTable: $db.mushafs,
        getReferencedColumn: (t) => t.mushafId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$MushafsTableAnnotationComposer(
              $db: $db,
              $table: $db.mushafs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> cardsRefs<T extends Object>(
      Expression<T> Function($$CardsTableAnnotationComposer a) f) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableAnnotationComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> lineBlocksRefs<T extends Object>(
      Expression<T> Function($$LineBlocksTableAnnotationComposer a) f) {
    final $$LineBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.lineBlocks,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LineBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.lineBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> reviewLogRefs<T extends Object>(
      Expression<T> Function($$ReviewLogTableAnnotationComposer a) f) {
    final $$ReviewLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.reviewLog,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewLogTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewLog,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> confusionEdgesRefs<T extends Object>(
      Expression<T> Function($$ConfusionEdgesTableAnnotationComposer a) f) {
    final $$ConfusionEdgesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableAnnotationComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> cycleConfigsRefs<T extends Object>(
      Expression<T> Function($$CycleConfigsTableAnnotationComposer a) f) {
    final $$CycleConfigsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.cycleConfigs,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CycleConfigsTableAnnotationComposer(
              $db: $db,
              $table: $db.cycleConfigs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ProfilesTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $ProfilesTable,
    ProfileRow,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (ProfileRow, $$ProfilesTableReferences),
    ProfileRow,
    PrefetchHooks Function(
        {bool mushafId,
        bool cardsRefs,
        bool lineBlocksRefs,
        bool reviewLogRefs,
        bool confusionEdgesRefs,
        bool cycleConfigsRefs})> {
  $$ProfilesTableTableManager(_$HifzDatabase db, $ProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String> displayName = const Value.absent(),
            Value<String> role = const Value.absent(),
            Value<String> locale = const Value.absent(),
            Value<String> mushafId = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String?> settingsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion(
            profileId: profileId,
            displayName: displayName,
            role: role,
            locale: locale,
            mushafId: mushafId,
            createdAt: createdAt,
            settingsJson: settingsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            required String displayName,
            required String role,
            required String locale,
            required String mushafId,
            required String createdAt,
            Value<String?> settingsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProfilesCompanion.insert(
            profileId: profileId,
            displayName: displayName,
            role: role,
            locale: locale,
            mushafId: mushafId,
            createdAt: createdAt,
            settingsJson: settingsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProfilesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: (
              {mushafId = false,
              cardsRefs = false,
              lineBlocksRefs = false,
              reviewLogRefs = false,
              confusionEdgesRefs = false,
              cycleConfigsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardsRefs) db.cards,
                if (lineBlocksRefs) db.lineBlocks,
                if (reviewLogRefs) db.reviewLog,
                if (confusionEdgesRefs) db.confusionEdges,
                if (cycleConfigsRefs) db.cycleConfigs
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
                if (mushafId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.mushafId,
                    referencedTable:
                        $$ProfilesTableReferences._mushafIdTable(db),
                    referencedColumn:
                        $$ProfilesTableReferences._mushafIdTable(db).mushafId,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (cardsRefs)
                    await $_getPrefetchedData<ProfileRow, $ProfilesTable,
                            CardRow>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._cardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0).cardsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.profileId),
                        typedResults: items),
                  if (lineBlocksRefs)
                    await $_getPrefetchedData<ProfileRow, $ProfilesTable,
                            LineBlockRow>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._lineBlocksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .lineBlocksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.profileId),
                        typedResults: items),
                  if (reviewLogRefs)
                    await $_getPrefetchedData<ProfileRow, $ProfilesTable,
                            ReviewLogRow>(
                        currentTable: table,
                        referencedTable:
                            $$ProfilesTableReferences._reviewLogRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .reviewLogRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.profileId),
                        typedResults: items),
                  if (confusionEdgesRefs)
                    await $_getPrefetchedData<ProfileRow, $ProfilesTable,
                            ConfusionEdgeRow>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._confusionEdgesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .confusionEdgesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.profileId),
                        typedResults: items),
                  if (cycleConfigsRefs)
                    await $_getPrefetchedData<ProfileRow, $ProfilesTable,
                            CycleConfigRow>(
                        currentTable: table,
                        referencedTable: $$ProfilesTableReferences
                            ._cycleConfigsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ProfilesTableReferences(db, table, p0)
                                .cycleConfigsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.profileId == item.profileId),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ProfilesTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $ProfilesTable,
    ProfileRow,
    $$ProfilesTableFilterComposer,
    $$ProfilesTableOrderingComposer,
    $$ProfilesTableAnnotationComposer,
    $$ProfilesTableCreateCompanionBuilder,
    $$ProfilesTableUpdateCompanionBuilder,
    (ProfileRow, $$ProfilesTableReferences),
    ProfileRow,
    PrefetchHooks Function(
        {bool mushafId,
        bool cardsRefs,
        bool lineBlocksRefs,
        bool reviewLogRefs,
        bool confusionEdgesRefs,
        bool cycleConfigsRefs})>;
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

  static MultiTypedResultKey<$CardsTable, List<CardRow>> _cardsRefsTable(
          _$HifzDatabase db) =>
      MultiTypedResultKey.fromTable(db.cards,
          aliasName: $_aliasNameGenerator(db.pages.pageId, db.cards.pageId));

  $$CardsTableProcessedTableManager get cardsRefs {
    final manager = $$CardsTableTableManager($_db, $_db.cards).filter(
        (f) => f.pageId.pageId.sqlEquals($_itemColumn<int>('page_id')!));

    final cache = $_typedResult.readTableOrNull(_cardsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$LineBlocksTable, List<LineBlockRow>>
      _lineBlocksRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.lineBlocks,
              aliasName:
                  $_aliasNameGenerator(db.pages.pageId, db.lineBlocks.pageId));

  $$LineBlocksTableProcessedTableManager get lineBlocksRefs {
    final manager = $$LineBlocksTableTableManager($_db, $_db.lineBlocks).filter(
        (f) => f.pageId.pageId.sqlEquals($_itemColumn<int>('page_id')!));

    final cache = $_typedResult.readTableOrNull(_lineBlocksRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ReviewLogTable, List<ReviewLogRow>>
      _reviewLogRefsTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.reviewLog,
              aliasName:
                  $_aliasNameGenerator(db.pages.pageId, db.reviewLog.pageId));

  $$ReviewLogTableProcessedTableManager get reviewLogRefs {
    final manager = $$ReviewLogTableTableManager($_db, $_db.reviewLog).filter(
        (f) => f.pageId.pageId.sqlEquals($_itemColumn<int>('page_id')!));

    final cache = $_typedResult.readTableOrNull(_reviewLogRefsTable($_db));
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

  Expression<bool> cardsRefs(
      Expression<bool> Function($$CardsTableFilterComposer f) f) {
    final $$CardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableFilterComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> lineBlocksRefs(
      Expression<bool> Function($$LineBlocksTableFilterComposer f) f) {
    final $$LineBlocksTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.lineBlocks,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LineBlocksTableFilterComposer(
              $db: $db,
              $table: $db.lineBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> reviewLogRefs(
      Expression<bool> Function($$ReviewLogTableFilterComposer f) f) {
    final $$ReviewLogTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.reviewLog,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewLogTableFilterComposer(
              $db: $db,
              $table: $db.reviewLog,
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

  Expression<T> cardsRefs<T extends Object>(
      Expression<T> Function($$CardsTableAnnotationComposer a) f) {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.cards,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CardsTableAnnotationComposer(
              $db: $db,
              $table: $db.cards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> lineBlocksRefs<T extends Object>(
      Expression<T> Function($$LineBlocksTableAnnotationComposer a) f) {
    final $$LineBlocksTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.lineBlocks,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$LineBlocksTableAnnotationComposer(
              $db: $db,
              $table: $db.lineBlocks,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> reviewLogRefs<T extends Object>(
      Expression<T> Function($$ReviewLogTableAnnotationComposer a) f) {
    final $$ReviewLogTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.pageId,
        referencedTable: $db.reviewLog,
        getReferencedColumn: (t) => t.pageId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ReviewLogTableAnnotationComposer(
              $db: $db,
              $table: $db.reviewLog,
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
        {bool surahStart,
        bool surahEnd,
        bool cardsRefs,
        bool lineBlocksRefs,
        bool reviewLogRefs,
        bool ayatRefs,
        bool linesRefs})> {
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
              cardsRefs = false,
              lineBlocksRefs = false,
              reviewLogRefs = false,
              ayatRefs = false,
              linesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (cardsRefs) db.cards,
                if (lineBlocksRefs) db.lineBlocks,
                if (reviewLogRefs) db.reviewLog,
                if (ayatRefs) db.ayat,
                if (linesRefs) db.lines
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
                  if (cardsRefs)
                    await $_getPrefetchedData<PageRow, $PagesTable, CardRow>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._cardsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0).cardsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pageId == item.pageId),
                        typedResults: items),
                  if (lineBlocksRefs)
                    await $_getPrefetchedData<PageRow, $PagesTable,
                            LineBlockRow>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._lineBlocksRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0)
                                .lineBlocksRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.pageId == item.pageId),
                        typedResults: items),
                  if (reviewLogRefs)
                    await $_getPrefetchedData<PageRow, $PagesTable,
                            ReviewLogRow>(
                        currentTable: table,
                        referencedTable:
                            $$PagesTableReferences._reviewLogRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$PagesTableReferences(db, table, p0).reviewLogRefs,
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
                        typedResults: items),
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
        {bool surahStart,
        bool surahEnd,
        bool cardsRefs,
        bool lineBlocksRefs,
        bool reviewLogRefs,
        bool ayatRefs,
        bool linesRefs})>;
typedef $$CardsTableCreateCompanionBuilder = CardsCompanion Function({
  required String profileId,
  required int pageId,
  required String track,
  required double difficulty,
  required double stabilityDays,
  Value<int?> lastReviewAt,
  Value<int?> dueAt,
  Value<int> reps,
  Value<int> lapses,
  Value<bool> weakFlag,
  Value<int> signoffs,
  Value<bool> manualLock,
  Value<bool> prayerCritical,
  Value<bool> enabled,
  Value<int> rowid,
});
typedef $$CardsTableUpdateCompanionBuilder = CardsCompanion Function({
  Value<String> profileId,
  Value<int> pageId,
  Value<String> track,
  Value<double> difficulty,
  Value<double> stabilityDays,
  Value<int?> lastReviewAt,
  Value<int?> dueAt,
  Value<int> reps,
  Value<int> lapses,
  Value<bool> weakFlag,
  Value<int> signoffs,
  Value<bool> manualLock,
  Value<bool> prayerCritical,
  Value<bool> enabled,
  Value<int> rowid,
});

final class $$CardsTableReferences
    extends BaseReferences<_$HifzDatabase, $CardsTable, CardRow> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$HifzDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.cards.profileId, db.profiles.profileId));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PagesTable _pageIdTable(_$HifzDatabase db) => db.pages
      .createAlias($_aliasNameGenerator(db.cards.pageId, db.pages.pageId));

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

class $$CardsTableFilterComposer extends Composer<_$HifzDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get track => $composableBuilder(
      column: $table.track, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stabilityDays => $composableBuilder(
      column: $table.stabilityDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastReviewAt => $composableBuilder(
      column: $table.lastReviewAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get weakFlag => $composableBuilder(
      column: $table.weakFlag, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get signoffs => $composableBuilder(
      column: $table.signoffs, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get manualLock => $composableBuilder(
      column: $table.manualLock, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get prayerCritical => $composableBuilder(
      column: $table.prayerCritical,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$CardsTableOrderingComposer
    extends Composer<_$HifzDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get track => $composableBuilder(
      column: $table.track, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stabilityDays => $composableBuilder(
      column: $table.stabilityDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastReviewAt => $composableBuilder(
      column: $table.lastReviewAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueAt => $composableBuilder(
      column: $table.dueAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get reps => $composableBuilder(
      column: $table.reps, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lapses => $composableBuilder(
      column: $table.lapses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get weakFlag => $composableBuilder(
      column: $table.weakFlag, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get signoffs => $composableBuilder(
      column: $table.signoffs, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get manualLock => $composableBuilder(
      column: $table.manualLock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get prayerCritical => $composableBuilder(
      column: $table.prayerCritical,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get enabled => $composableBuilder(
      column: $table.enabled, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
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

class $$CardsTableAnnotationComposer
    extends Composer<_$HifzDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get track =>
      $composableBuilder(column: $table.track, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
      column: $table.difficulty, builder: (column) => column);

  GeneratedColumn<double> get stabilityDays => $composableBuilder(
      column: $table.stabilityDays, builder: (column) => column);

  GeneratedColumn<int> get lastReviewAt => $composableBuilder(
      column: $table.lastReviewAt, builder: (column) => column);

  GeneratedColumn<int> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get lapses =>
      $composableBuilder(column: $table.lapses, builder: (column) => column);

  GeneratedColumn<bool> get weakFlag =>
      $composableBuilder(column: $table.weakFlag, builder: (column) => column);

  GeneratedColumn<int> get signoffs =>
      $composableBuilder(column: $table.signoffs, builder: (column) => column);

  GeneratedColumn<bool> get manualLock => $composableBuilder(
      column: $table.manualLock, builder: (column) => column);

  GeneratedColumn<bool> get prayerCritical => $composableBuilder(
      column: $table.prayerCritical, builder: (column) => column);

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$CardsTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $CardsTable,
    CardRow,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (CardRow, $$CardsTableReferences),
    CardRow,
    PrefetchHooks Function({bool profileId, bool pageId})> {
  $$CardsTableTableManager(_$HifzDatabase db, $CardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<int> pageId = const Value.absent(),
            Value<String> track = const Value.absent(),
            Value<double> difficulty = const Value.absent(),
            Value<double> stabilityDays = const Value.absent(),
            Value<int?> lastReviewAt = const Value.absent(),
            Value<int?> dueAt = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            Value<bool> weakFlag = const Value.absent(),
            Value<int> signoffs = const Value.absent(),
            Value<bool> manualLock = const Value.absent(),
            Value<bool> prayerCritical = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion(
            profileId: profileId,
            pageId: pageId,
            track: track,
            difficulty: difficulty,
            stabilityDays: stabilityDays,
            lastReviewAt: lastReviewAt,
            dueAt: dueAt,
            reps: reps,
            lapses: lapses,
            weakFlag: weakFlag,
            signoffs: signoffs,
            manualLock: manualLock,
            prayerCritical: prayerCritical,
            enabled: enabled,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            required int pageId,
            required String track,
            required double difficulty,
            required double stabilityDays,
            Value<int?> lastReviewAt = const Value.absent(),
            Value<int?> dueAt = const Value.absent(),
            Value<int> reps = const Value.absent(),
            Value<int> lapses = const Value.absent(),
            Value<bool> weakFlag = const Value.absent(),
            Value<int> signoffs = const Value.absent(),
            Value<bool> manualLock = const Value.absent(),
            Value<bool> prayerCritical = const Value.absent(),
            Value<bool> enabled = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardsCompanion.insert(
            profileId: profileId,
            pageId: pageId,
            track: track,
            difficulty: difficulty,
            stabilityDays: stabilityDays,
            lastReviewAt: lastReviewAt,
            dueAt: dueAt,
            reps: reps,
            lapses: lapses,
            weakFlag: weakFlag,
            signoffs: signoffs,
            manualLock: manualLock,
            prayerCritical: prayerCritical,
            enabled: enabled,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$CardsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({profileId = false, pageId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable: $$CardsTableReferences._profileIdTable(db),
                    referencedColumn:
                        $$CardsTableReferences._profileIdTable(db).profileId,
                  ) as T;
                }
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable: $$CardsTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$CardsTableReferences._pageIdTable(db).pageId,
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

typedef $$CardsTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $CardsTable,
    CardRow,
    $$CardsTableFilterComposer,
    $$CardsTableOrderingComposer,
    $$CardsTableAnnotationComposer,
    $$CardsTableCreateCompanionBuilder,
    $$CardsTableUpdateCompanionBuilder,
    (CardRow, $$CardsTableReferences),
    CardRow,
    PrefetchHooks Function({bool profileId, bool pageId})>;
typedef $$LineBlocksTableCreateCompanionBuilder = LineBlocksCompanion Function({
  required String blockId,
  required String profileId,
  required int pageId,
  required int lineStart,
  required int lineEnd,
  Value<int> errorCount,
  Value<int> rowid,
});
typedef $$LineBlocksTableUpdateCompanionBuilder = LineBlocksCompanion Function({
  Value<String> blockId,
  Value<String> profileId,
  Value<int> pageId,
  Value<int> lineStart,
  Value<int> lineEnd,
  Value<int> errorCount,
  Value<int> rowid,
});

final class $$LineBlocksTableReferences
    extends BaseReferences<_$HifzDatabase, $LineBlocksTable, LineBlockRow> {
  $$LineBlocksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$HifzDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.lineBlocks.profileId, db.profiles.profileId));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PagesTable _pageIdTable(_$HifzDatabase db) => db.pages
      .createAlias($_aliasNameGenerator(db.lineBlocks.pageId, db.pages.pageId));

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

class $$LineBlocksTableFilterComposer
    extends Composer<_$HifzDatabase, $LineBlocksTable> {
  $$LineBlocksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get blockId => $composableBuilder(
      column: $table.blockId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineStart => $composableBuilder(
      column: $table.lineStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lineEnd => $composableBuilder(
      column: $table.lineEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$LineBlocksTableOrderingComposer
    extends Composer<_$HifzDatabase, $LineBlocksTable> {
  $$LineBlocksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get blockId => $composableBuilder(
      column: $table.blockId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineStart => $composableBuilder(
      column: $table.lineStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lineEnd => $composableBuilder(
      column: $table.lineEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
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

class $$LineBlocksTableAnnotationComposer
    extends Composer<_$HifzDatabase, $LineBlocksTable> {
  $$LineBlocksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get blockId =>
      $composableBuilder(column: $table.blockId, builder: (column) => column);

  GeneratedColumn<int> get lineStart =>
      $composableBuilder(column: $table.lineStart, builder: (column) => column);

  GeneratedColumn<int> get lineEnd =>
      $composableBuilder(column: $table.lineEnd, builder: (column) => column);

  GeneratedColumn<int> get errorCount => $composableBuilder(
      column: $table.errorCount, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$LineBlocksTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $LineBlocksTable,
    LineBlockRow,
    $$LineBlocksTableFilterComposer,
    $$LineBlocksTableOrderingComposer,
    $$LineBlocksTableAnnotationComposer,
    $$LineBlocksTableCreateCompanionBuilder,
    $$LineBlocksTableUpdateCompanionBuilder,
    (LineBlockRow, $$LineBlocksTableReferences),
    LineBlockRow,
    PrefetchHooks Function({bool profileId, bool pageId})> {
  $$LineBlocksTableTableManager(_$HifzDatabase db, $LineBlocksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LineBlocksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LineBlocksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LineBlocksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> blockId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<int> pageId = const Value.absent(),
            Value<int> lineStart = const Value.absent(),
            Value<int> lineEnd = const Value.absent(),
            Value<int> errorCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LineBlocksCompanion(
            blockId: blockId,
            profileId: profileId,
            pageId: pageId,
            lineStart: lineStart,
            lineEnd: lineEnd,
            errorCount: errorCount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String blockId,
            required String profileId,
            required int pageId,
            required int lineStart,
            required int lineEnd,
            Value<int> errorCount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LineBlocksCompanion.insert(
            blockId: blockId,
            profileId: profileId,
            pageId: pageId,
            lineStart: lineStart,
            lineEnd: lineEnd,
            errorCount: errorCount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$LineBlocksTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false, pageId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$LineBlocksTableReferences._profileIdTable(db),
                    referencedColumn: $$LineBlocksTableReferences
                        ._profileIdTable(db)
                        .profileId,
                  ) as T;
                }
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable:
                        $$LineBlocksTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$LineBlocksTableReferences._pageIdTable(db).pageId,
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

typedef $$LineBlocksTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $LineBlocksTable,
    LineBlockRow,
    $$LineBlocksTableFilterComposer,
    $$LineBlocksTableOrderingComposer,
    $$LineBlocksTableAnnotationComposer,
    $$LineBlocksTableCreateCompanionBuilder,
    $$LineBlocksTableUpdateCompanionBuilder,
    (LineBlockRow, $$LineBlocksTableReferences),
    LineBlockRow,
    PrefetchHooks Function({bool profileId, bool pageId})>;
typedef $$ReviewLogTableCreateCompanionBuilder = ReviewLogCompanion Function({
  required String logId,
  required String profileId,
  required int pageId,
  required String reviewedAt,
  required String trackAtReview,
  required String grade,
  Value<String?> errorLinesJson,
  required int elapsedDays,
  Value<double?> rPredicted,
  Value<double?> sBefore,
  Value<double?> sAfter,
  Value<double?> dBefore,
  Value<double?> dAfter,
  required String source,
  Value<String?> teacherLabel,
  Value<int> rowid,
});
typedef $$ReviewLogTableUpdateCompanionBuilder = ReviewLogCompanion Function({
  Value<String> logId,
  Value<String> profileId,
  Value<int> pageId,
  Value<String> reviewedAt,
  Value<String> trackAtReview,
  Value<String> grade,
  Value<String?> errorLinesJson,
  Value<int> elapsedDays,
  Value<double?> rPredicted,
  Value<double?> sBefore,
  Value<double?> sAfter,
  Value<double?> dBefore,
  Value<double?> dAfter,
  Value<String> source,
  Value<String?> teacherLabel,
  Value<int> rowid,
});

final class $$ReviewLogTableReferences
    extends BaseReferences<_$HifzDatabase, $ReviewLogTable, ReviewLogRow> {
  $$ReviewLogTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$HifzDatabase db) =>
      db.profiles.createAlias(
          $_aliasNameGenerator(db.reviewLog.profileId, db.profiles.profileId));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $PagesTable _pageIdTable(_$HifzDatabase db) => db.pages
      .createAlias($_aliasNameGenerator(db.reviewLog.pageId, db.pages.pageId));

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

class $$ReviewLogTableFilterComposer
    extends Composer<_$HifzDatabase, $ReviewLogTable> {
  $$ReviewLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get logId => $composableBuilder(
      column: $table.logId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get trackAtReview => $composableBuilder(
      column: $table.trackAtReview, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get errorLinesJson => $composableBuilder(
      column: $table.errorLinesJson,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get rPredicted => $composableBuilder(
      column: $table.rPredicted, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sBefore => $composableBuilder(
      column: $table.sBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sAfter => $composableBuilder(
      column: $table.sAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dBefore => $composableBuilder(
      column: $table.dBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get dAfter => $composableBuilder(
      column: $table.dAfter, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get teacherLabel => $composableBuilder(
      column: $table.teacherLabel, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$ReviewLogTableOrderingComposer
    extends Composer<_$HifzDatabase, $ReviewLogTable> {
  $$ReviewLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get logId => $composableBuilder(
      column: $table.logId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get trackAtReview => $composableBuilder(
      column: $table.trackAtReview,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get grade => $composableBuilder(
      column: $table.grade, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get errorLinesJson => $composableBuilder(
      column: $table.errorLinesJson,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get rPredicted => $composableBuilder(
      column: $table.rPredicted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sBefore => $composableBuilder(
      column: $table.sBefore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sAfter => $composableBuilder(
      column: $table.sAfter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dBefore => $composableBuilder(
      column: $table.dBefore, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get dAfter => $composableBuilder(
      column: $table.dAfter, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get source => $composableBuilder(
      column: $table.source, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get teacherLabel => $composableBuilder(
      column: $table.teacherLabel,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
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

class $$ReviewLogTableAnnotationComposer
    extends Composer<_$HifzDatabase, $ReviewLogTable> {
  $$ReviewLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get logId =>
      $composableBuilder(column: $table.logId, builder: (column) => column);

  GeneratedColumn<String> get reviewedAt => $composableBuilder(
      column: $table.reviewedAt, builder: (column) => column);

  GeneratedColumn<String> get trackAtReview => $composableBuilder(
      column: $table.trackAtReview, builder: (column) => column);

  GeneratedColumn<String> get grade =>
      $composableBuilder(column: $table.grade, builder: (column) => column);

  GeneratedColumn<String> get errorLinesJson => $composableBuilder(
      column: $table.errorLinesJson, builder: (column) => column);

  GeneratedColumn<int> get elapsedDays => $composableBuilder(
      column: $table.elapsedDays, builder: (column) => column);

  GeneratedColumn<double> get rPredicted => $composableBuilder(
      column: $table.rPredicted, builder: (column) => column);

  GeneratedColumn<double> get sBefore =>
      $composableBuilder(column: $table.sBefore, builder: (column) => column);

  GeneratedColumn<double> get sAfter =>
      $composableBuilder(column: $table.sAfter, builder: (column) => column);

  GeneratedColumn<double> get dBefore =>
      $composableBuilder(column: $table.dBefore, builder: (column) => column);

  GeneratedColumn<double> get dAfter =>
      $composableBuilder(column: $table.dAfter, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<String> get teacherLabel => $composableBuilder(
      column: $table.teacherLabel, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
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
}

class $$ReviewLogTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $ReviewLogTable,
    ReviewLogRow,
    $$ReviewLogTableFilterComposer,
    $$ReviewLogTableOrderingComposer,
    $$ReviewLogTableAnnotationComposer,
    $$ReviewLogTableCreateCompanionBuilder,
    $$ReviewLogTableUpdateCompanionBuilder,
    (ReviewLogRow, $$ReviewLogTableReferences),
    ReviewLogRow,
    PrefetchHooks Function({bool profileId, bool pageId})> {
  $$ReviewLogTableTableManager(_$HifzDatabase db, $ReviewLogTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReviewLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReviewLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReviewLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> logId = const Value.absent(),
            Value<String> profileId = const Value.absent(),
            Value<int> pageId = const Value.absent(),
            Value<String> reviewedAt = const Value.absent(),
            Value<String> trackAtReview = const Value.absent(),
            Value<String> grade = const Value.absent(),
            Value<String?> errorLinesJson = const Value.absent(),
            Value<int> elapsedDays = const Value.absent(),
            Value<double?> rPredicted = const Value.absent(),
            Value<double?> sBefore = const Value.absent(),
            Value<double?> sAfter = const Value.absent(),
            Value<double?> dBefore = const Value.absent(),
            Value<double?> dAfter = const Value.absent(),
            Value<String> source = const Value.absent(),
            Value<String?> teacherLabel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewLogCompanion(
            logId: logId,
            profileId: profileId,
            pageId: pageId,
            reviewedAt: reviewedAt,
            trackAtReview: trackAtReview,
            grade: grade,
            errorLinesJson: errorLinesJson,
            elapsedDays: elapsedDays,
            rPredicted: rPredicted,
            sBefore: sBefore,
            sAfter: sAfter,
            dBefore: dBefore,
            dAfter: dAfter,
            source: source,
            teacherLabel: teacherLabel,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String logId,
            required String profileId,
            required int pageId,
            required String reviewedAt,
            required String trackAtReview,
            required String grade,
            Value<String?> errorLinesJson = const Value.absent(),
            required int elapsedDays,
            Value<double?> rPredicted = const Value.absent(),
            Value<double?> sBefore = const Value.absent(),
            Value<double?> sAfter = const Value.absent(),
            Value<double?> dBefore = const Value.absent(),
            Value<double?> dAfter = const Value.absent(),
            required String source,
            Value<String?> teacherLabel = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ReviewLogCompanion.insert(
            logId: logId,
            profileId: profileId,
            pageId: pageId,
            reviewedAt: reviewedAt,
            trackAtReview: trackAtReview,
            grade: grade,
            errorLinesJson: errorLinesJson,
            elapsedDays: elapsedDays,
            rPredicted: rPredicted,
            sBefore: sBefore,
            sAfter: sAfter,
            dBefore: dBefore,
            dAfter: dAfter,
            source: source,
            teacherLabel: teacherLabel,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ReviewLogTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false, pageId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ReviewLogTableReferences._profileIdTable(db),
                    referencedColumn: $$ReviewLogTableReferences
                        ._profileIdTable(db)
                        .profileId,
                  ) as T;
                }
                if (pageId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.pageId,
                    referencedTable:
                        $$ReviewLogTableReferences._pageIdTable(db),
                    referencedColumn:
                        $$ReviewLogTableReferences._pageIdTable(db).pageId,
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

typedef $$ReviewLogTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $ReviewLogTable,
    ReviewLogRow,
    $$ReviewLogTableFilterComposer,
    $$ReviewLogTableOrderingComposer,
    $$ReviewLogTableAnnotationComposer,
    $$ReviewLogTableCreateCompanionBuilder,
    $$ReviewLogTableUpdateCompanionBuilder,
    (ReviewLogRow, $$ReviewLogTableReferences),
    ReviewLogRow,
    PrefetchHooks Function({bool profileId, bool pageId})>;
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

  static MultiTypedResultKey<$ConfusionEdgesTable, List<ConfusionEdgeRow>>
      _confusionEdgesAsATable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.confusionEdges,
              aliasName: $_aliasNameGenerator(
                  db.ayat.ayahId, db.confusionEdges.ayahA));

  $$ConfusionEdgesTableProcessedTableManager get confusionEdgesAsA {
    final manager = $$ConfusionEdgesTableTableManager($_db, $_db.confusionEdges)
        .filter(
            (f) => f.ayahA.ayahId.sqlEquals($_itemColumn<String>('ayah_id')!));

    final cache = $_typedResult.readTableOrNull(_confusionEdgesAsATable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$ConfusionEdgesTable, List<ConfusionEdgeRow>>
      _confusionEdgesAsBTable(_$HifzDatabase db) =>
          MultiTypedResultKey.fromTable(db.confusionEdges,
              aliasName: $_aliasNameGenerator(
                  db.ayat.ayahId, db.confusionEdges.ayahB));

  $$ConfusionEdgesTableProcessedTableManager get confusionEdgesAsB {
    final manager = $$ConfusionEdgesTableTableManager($_db, $_db.confusionEdges)
        .filter(
            (f) => f.ayahB.ayahId.sqlEquals($_itemColumn<String>('ayah_id')!));

    final cache = $_typedResult.readTableOrNull(_confusionEdgesAsBTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
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

  Expression<bool> confusionEdgesAsA(
      Expression<bool> Function($$ConfusionEdgesTableFilterComposer f) f) {
    final $$ConfusionEdgesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.ayahA,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableFilterComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> confusionEdgesAsB(
      Expression<bool> Function($$ConfusionEdgesTableFilterComposer f) f) {
    final $$ConfusionEdgesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.ayahB,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableFilterComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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

  Expression<T> confusionEdgesAsA<T extends Object>(
      Expression<T> Function($$ConfusionEdgesTableAnnotationComposer a) f) {
    final $$ConfusionEdgesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.ayahA,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableAnnotationComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> confusionEdgesAsB<T extends Object>(
      Expression<T> Function($$ConfusionEdgesTableAnnotationComposer a) f) {
    final $$ConfusionEdgesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahId,
        referencedTable: $db.confusionEdges,
        getReferencedColumn: (t) => t.ayahB,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ConfusionEdgesTableAnnotationComposer(
              $db: $db,
              $table: $db.confusionEdges,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
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
        {bool surah,
        bool pageId,
        bool confusionEdgesAsA,
        bool confusionEdgesAsB,
        bool mutashabihMembersRefs})> {
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
              {surah = false,
              pageId = false,
              confusionEdgesAsA = false,
              confusionEdgesAsB = false,
              mutashabihMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (confusionEdgesAsA) db.confusionEdges,
                if (confusionEdgesAsB) db.confusionEdges,
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
                  if (confusionEdgesAsA)
                    await $_getPrefetchedData<AyahRow, $AyatTable,
                            ConfusionEdgeRow>(
                        currentTable: table,
                        referencedTable:
                            $$AyatTableReferences._confusionEdgesAsATable(db),
                        managerFromTypedResult: (p0) =>
                            $$AyatTableReferences(db, table, p0)
                                .confusionEdgesAsA,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ayahA == item.ayahId),
                        typedResults: items),
                  if (confusionEdgesAsB)
                    await $_getPrefetchedData<AyahRow, $AyatTable,
                            ConfusionEdgeRow>(
                        currentTable: table,
                        referencedTable:
                            $$AyatTableReferences._confusionEdgesAsBTable(db),
                        managerFromTypedResult: (p0) =>
                            $$AyatTableReferences(db, table, p0)
                                .confusionEdgesAsB,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.ayahB == item.ayahId),
                        typedResults: items),
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
        {bool surah,
        bool pageId,
        bool confusionEdgesAsA,
        bool confusionEdgesAsB,
        bool mutashabihMembersRefs})>;
typedef $$ConfusionEdgesTableCreateCompanionBuilder = ConfusionEdgesCompanion
    Function({
  required String profileId,
  required String ayahA,
  required String ayahB,
  Value<double> weight,
  Value<String?> lastConfusedAt,
  Value<int> rowid,
});
typedef $$ConfusionEdgesTableUpdateCompanionBuilder = ConfusionEdgesCompanion
    Function({
  Value<String> profileId,
  Value<String> ayahA,
  Value<String> ayahB,
  Value<double> weight,
  Value<String?> lastConfusedAt,
  Value<int> rowid,
});

final class $$ConfusionEdgesTableReferences extends BaseReferences<
    _$HifzDatabase, $ConfusionEdgesTable, ConfusionEdgeRow> {
  $$ConfusionEdgesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$HifzDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(
          db.confusionEdges.profileId, db.profiles.profileId));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AyatTable _ayahATable(_$HifzDatabase db) => db.ayat.createAlias(
      $_aliasNameGenerator(db.confusionEdges.ayahA, db.ayat.ayahId));

  $$AyatTableProcessedTableManager get ayahA {
    final $_column = $_itemColumn<String>('ayah_a')!;

    final manager = $$AyatTableTableManager($_db, $_db.ayat)
        .filter((f) => f.ayahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahATable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $AyatTable _ayahBTable(_$HifzDatabase db) => db.ayat.createAlias(
      $_aliasNameGenerator(db.confusionEdges.ayahB, db.ayat.ayahId));

  $$AyatTableProcessedTableManager get ayahB {
    final $_column = $_itemColumn<String>('ayah_b')!;

    final manager = $$AyatTableTableManager($_db, $_db.ayat)
        .filter((f) => f.ayahId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ayahBTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ConfusionEdgesTableFilterComposer
    extends Composer<_$HifzDatabase, $ConfusionEdgesTable> {
  $$ConfusionEdgesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastConfusedAt => $composableBuilder(
      column: $table.lastConfusedAt,
      builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableFilterComposer get ayahA {
    final $$AyatTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahA,
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

  $$AyatTableFilterComposer get ayahB {
    final $$AyatTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahB,
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

class $$ConfusionEdgesTableOrderingComposer
    extends Composer<_$HifzDatabase, $ConfusionEdgesTable> {
  $$ConfusionEdgesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get weight => $composableBuilder(
      column: $table.weight, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastConfusedAt => $composableBuilder(
      column: $table.lastConfusedAt,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableOrderingComposer get ayahA {
    final $$AyatTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahA,
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

  $$AyatTableOrderingComposer get ayahB {
    final $$AyatTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahB,
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

class $$ConfusionEdgesTableAnnotationComposer
    extends Composer<_$HifzDatabase, $ConfusionEdgesTable> {
  $$ConfusionEdgesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get lastConfusedAt => $composableBuilder(
      column: $table.lastConfusedAt, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$AyatTableAnnotationComposer get ayahA {
    final $$AyatTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahA,
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

  $$AyatTableAnnotationComposer get ayahB {
    final $$AyatTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.ayahB,
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

class $$ConfusionEdgesTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $ConfusionEdgesTable,
    ConfusionEdgeRow,
    $$ConfusionEdgesTableFilterComposer,
    $$ConfusionEdgesTableOrderingComposer,
    $$ConfusionEdgesTableAnnotationComposer,
    $$ConfusionEdgesTableCreateCompanionBuilder,
    $$ConfusionEdgesTableUpdateCompanionBuilder,
    (ConfusionEdgeRow, $$ConfusionEdgesTableReferences),
    ConfusionEdgeRow,
    PrefetchHooks Function({bool profileId, bool ayahA, bool ayahB})> {
  $$ConfusionEdgesTableTableManager(
      _$HifzDatabase db, $ConfusionEdgesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfusionEdgesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfusionEdgesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfusionEdgesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String> ayahA = const Value.absent(),
            Value<String> ayahB = const Value.absent(),
            Value<double> weight = const Value.absent(),
            Value<String?> lastConfusedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConfusionEdgesCompanion(
            profileId: profileId,
            ayahA: ayahA,
            ayahB: ayahB,
            weight: weight,
            lastConfusedAt: lastConfusedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            required String ayahA,
            required String ayahB,
            Value<double> weight = const Value.absent(),
            Value<String?> lastConfusedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ConfusionEdgesCompanion.insert(
            profileId: profileId,
            ayahA: ayahA,
            ayahB: ayahB,
            weight: weight,
            lastConfusedAt: lastConfusedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ConfusionEdgesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {profileId = false, ayahA = false, ayahB = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$ConfusionEdgesTableReferences._profileIdTable(db),
                    referencedColumn: $$ConfusionEdgesTableReferences
                        ._profileIdTable(db)
                        .profileId,
                  ) as T;
                }
                if (ayahA) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ayahA,
                    referencedTable:
                        $$ConfusionEdgesTableReferences._ayahATable(db),
                    referencedColumn:
                        $$ConfusionEdgesTableReferences._ayahATable(db).ayahId,
                  ) as T;
                }
                if (ayahB) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.ayahB,
                    referencedTable:
                        $$ConfusionEdgesTableReferences._ayahBTable(db),
                    referencedColumn:
                        $$ConfusionEdgesTableReferences._ayahBTable(db).ayahId,
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

typedef $$ConfusionEdgesTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $ConfusionEdgesTable,
    ConfusionEdgeRow,
    $$ConfusionEdgesTableFilterComposer,
    $$ConfusionEdgesTableOrderingComposer,
    $$ConfusionEdgesTableAnnotationComposer,
    $$ConfusionEdgesTableCreateCompanionBuilder,
    $$ConfusionEdgesTableUpdateCompanionBuilder,
    (ConfusionEdgeRow, $$ConfusionEdgesTableReferences),
    ConfusionEdgeRow,
    PrefetchHooks Function({bool profileId, bool ayahA, bool ayahB})>;
typedef $$CycleConfigsTableCreateCompanionBuilder = CycleConfigsCompanion
    Function({
  required String profileId,
  required String cycleType,
  Value<int> newLinesPerDay,
  required int nearWindowJuz,
  required int farTargetPerDay,
  required int farCycleDays,
  required int dailyBudgetMinutes,
  Value<bool> pureCycleMode,
  required String termLabelSet,
  Value<String?> regionPreset,
  Value<int> rowid,
});
typedef $$CycleConfigsTableUpdateCompanionBuilder = CycleConfigsCompanion
    Function({
  Value<String> profileId,
  Value<String> cycleType,
  Value<int> newLinesPerDay,
  Value<int> nearWindowJuz,
  Value<int> farTargetPerDay,
  Value<int> farCycleDays,
  Value<int> dailyBudgetMinutes,
  Value<bool> pureCycleMode,
  Value<String> termLabelSet,
  Value<String?> regionPreset,
  Value<int> rowid,
});

final class $$CycleConfigsTableReferences
    extends BaseReferences<_$HifzDatabase, $CycleConfigsTable, CycleConfigRow> {
  $$CycleConfigsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProfilesTable _profileIdTable(_$HifzDatabase db) =>
      db.profiles.createAlias($_aliasNameGenerator(
          db.cycleConfigs.profileId, db.profiles.profileId));

  $$ProfilesTableProcessedTableManager get profileId {
    final $_column = $_itemColumn<String>('profile_id')!;

    final manager = $$ProfilesTableTableManager($_db, $_db.profiles)
        .filter((f) => f.profileId.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_profileIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CycleConfigsTableFilterComposer
    extends Composer<_$HifzDatabase, $CycleConfigsTable> {
  $$CycleConfigsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get cycleType => $composableBuilder(
      column: $table.cycleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get newLinesPerDay => $composableBuilder(
      column: $table.newLinesPerDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get nearWindowJuz => $composableBuilder(
      column: $table.nearWindowJuz, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get farTargetPerDay => $composableBuilder(
      column: $table.farTargetPerDay,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get farCycleDays => $composableBuilder(
      column: $table.farCycleDays, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dailyBudgetMinutes => $composableBuilder(
      column: $table.dailyBudgetMinutes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get pureCycleMode => $composableBuilder(
      column: $table.pureCycleMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get termLabelSet => $composableBuilder(
      column: $table.termLabelSet, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get regionPreset => $composableBuilder(
      column: $table.regionPreset, builder: (column) => ColumnFilters(column));

  $$ProfilesTableFilterComposer get profileId {
    final $$ProfilesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableFilterComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CycleConfigsTableOrderingComposer
    extends Composer<_$HifzDatabase, $CycleConfigsTable> {
  $$CycleConfigsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get cycleType => $composableBuilder(
      column: $table.cycleType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get newLinesPerDay => $composableBuilder(
      column: $table.newLinesPerDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get nearWindowJuz => $composableBuilder(
      column: $table.nearWindowJuz,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get farTargetPerDay => $composableBuilder(
      column: $table.farTargetPerDay,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get farCycleDays => $composableBuilder(
      column: $table.farCycleDays,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dailyBudgetMinutes => $composableBuilder(
      column: $table.dailyBudgetMinutes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get pureCycleMode => $composableBuilder(
      column: $table.pureCycleMode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get termLabelSet => $composableBuilder(
      column: $table.termLabelSet,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get regionPreset => $composableBuilder(
      column: $table.regionPreset,
      builder: (column) => ColumnOrderings(column));

  $$ProfilesTableOrderingComposer get profileId {
    final $$ProfilesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableOrderingComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CycleConfigsTableAnnotationComposer
    extends Composer<_$HifzDatabase, $CycleConfigsTable> {
  $$CycleConfigsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get cycleType =>
      $composableBuilder(column: $table.cycleType, builder: (column) => column);

  GeneratedColumn<int> get newLinesPerDay => $composableBuilder(
      column: $table.newLinesPerDay, builder: (column) => column);

  GeneratedColumn<int> get nearWindowJuz => $composableBuilder(
      column: $table.nearWindowJuz, builder: (column) => column);

  GeneratedColumn<int> get farTargetPerDay => $composableBuilder(
      column: $table.farTargetPerDay, builder: (column) => column);

  GeneratedColumn<int> get farCycleDays => $composableBuilder(
      column: $table.farCycleDays, builder: (column) => column);

  GeneratedColumn<int> get dailyBudgetMinutes => $composableBuilder(
      column: $table.dailyBudgetMinutes, builder: (column) => column);

  GeneratedColumn<bool> get pureCycleMode => $composableBuilder(
      column: $table.pureCycleMode, builder: (column) => column);

  GeneratedColumn<String> get termLabelSet => $composableBuilder(
      column: $table.termLabelSet, builder: (column) => column);

  GeneratedColumn<String> get regionPreset => $composableBuilder(
      column: $table.regionPreset, builder: (column) => column);

  $$ProfilesTableAnnotationComposer get profileId {
    final $$ProfilesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.profileId,
        referencedTable: $db.profiles,
        getReferencedColumn: (t) => t.profileId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProfilesTableAnnotationComposer(
              $db: $db,
              $table: $db.profiles,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CycleConfigsTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $CycleConfigsTable,
    CycleConfigRow,
    $$CycleConfigsTableFilterComposer,
    $$CycleConfigsTableOrderingComposer,
    $$CycleConfigsTableAnnotationComposer,
    $$CycleConfigsTableCreateCompanionBuilder,
    $$CycleConfigsTableUpdateCompanionBuilder,
    (CycleConfigRow, $$CycleConfigsTableReferences),
    CycleConfigRow,
    PrefetchHooks Function({bool profileId})> {
  $$CycleConfigsTableTableManager(_$HifzDatabase db, $CycleConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CycleConfigsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CycleConfigsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CycleConfigsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> profileId = const Value.absent(),
            Value<String> cycleType = const Value.absent(),
            Value<int> newLinesPerDay = const Value.absent(),
            Value<int> nearWindowJuz = const Value.absent(),
            Value<int> farTargetPerDay = const Value.absent(),
            Value<int> farCycleDays = const Value.absent(),
            Value<int> dailyBudgetMinutes = const Value.absent(),
            Value<bool> pureCycleMode = const Value.absent(),
            Value<String> termLabelSet = const Value.absent(),
            Value<String?> regionPreset = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleConfigsCompanion(
            profileId: profileId,
            cycleType: cycleType,
            newLinesPerDay: newLinesPerDay,
            nearWindowJuz: nearWindowJuz,
            farTargetPerDay: farTargetPerDay,
            farCycleDays: farCycleDays,
            dailyBudgetMinutes: dailyBudgetMinutes,
            pureCycleMode: pureCycleMode,
            termLabelSet: termLabelSet,
            regionPreset: regionPreset,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String profileId,
            required String cycleType,
            Value<int> newLinesPerDay = const Value.absent(),
            required int nearWindowJuz,
            required int farTargetPerDay,
            required int farCycleDays,
            required int dailyBudgetMinutes,
            Value<bool> pureCycleMode = const Value.absent(),
            required String termLabelSet,
            Value<String?> regionPreset = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CycleConfigsCompanion.insert(
            profileId: profileId,
            cycleType: cycleType,
            newLinesPerDay: newLinesPerDay,
            nearWindowJuz: nearWindowJuz,
            farTargetPerDay: farTargetPerDay,
            farCycleDays: farCycleDays,
            dailyBudgetMinutes: dailyBudgetMinutes,
            pureCycleMode: pureCycleMode,
            termLabelSet: termLabelSet,
            regionPreset: regionPreset,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CycleConfigsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({profileId = false}) {
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
                if (profileId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.profileId,
                    referencedTable:
                        $$CycleConfigsTableReferences._profileIdTable(db),
                    referencedColumn: $$CycleConfigsTableReferences
                        ._profileIdTable(db)
                        .profileId,
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

typedef $$CycleConfigsTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $CycleConfigsTable,
    CycleConfigRow,
    $$CycleConfigsTableFilterComposer,
    $$CycleConfigsTableOrderingComposer,
    $$CycleConfigsTableAnnotationComposer,
    $$CycleConfigsTableCreateCompanionBuilder,
    $$CycleConfigsTableUpdateCompanionBuilder,
    (CycleConfigRow, $$CycleConfigsTableReferences),
    CycleConfigRow,
    PrefetchHooks Function({bool profileId})>;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$HifzDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$HifzDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$HifzDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager extends RootTableManager<
    _$HifzDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$HifzDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()> {
  $$AppMetaTableTableManager(_$HifzDatabase db, $AppMetaTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppMetaCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppMetaTableProcessedTableManager = ProcessedTableManager<
    _$HifzDatabase,
    $AppMetaTable,
    AppMetaRow,
    $$AppMetaTableFilterComposer,
    $$AppMetaTableOrderingComposer,
    $$AppMetaTableAnnotationComposer,
    $$AppMetaTableCreateCompanionBuilder,
    $$AppMetaTableUpdateCompanionBuilder,
    (AppMetaRow, BaseReferences<_$HifzDatabase, $AppMetaTable, AppMetaRow>),
    AppMetaRow,
    PrefetchHooks Function()>;
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
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$SurahsTableTableManager get surahs =>
      $$SurahsTableTableManager(_db, _db.surahs);
  $$PagesTableTableManager get pages =>
      $$PagesTableTableManager(_db, _db.pages);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$LineBlocksTableTableManager get lineBlocks =>
      $$LineBlocksTableTableManager(_db, _db.lineBlocks);
  $$ReviewLogTableTableManager get reviewLog =>
      $$ReviewLogTableTableManager(_db, _db.reviewLog);
  $$AyatTableTableManager get ayat => $$AyatTableTableManager(_db, _db.ayat);
  $$ConfusionEdgesTableTableManager get confusionEdges =>
      $$ConfusionEdgesTableTableManager(_db, _db.confusionEdges);
  $$CycleConfigsTableTableManager get cycleConfigs =>
      $$CycleConfigsTableTableManager(_db, _db.cycleConfigs);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$LinesTableTableManager get lines =>
      $$LinesTableTableManager(_db, _db.lines);
  $$MutashabihGroupsTableTableManager get mutashabihGroups =>
      $$MutashabihGroupsTableTableManager(_db, _db.mutashabihGroups);
  $$MutashabihMembersTableTableManager get mutashabihMembers =>
      $$MutashabihMembersTableTableManager(_db, _db.mutashabihMembers);
}
