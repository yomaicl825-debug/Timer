// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TaskEntriesTable extends TaskEntries
    with TableInfo<$TaskEntriesTable, TaskEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    name,
    normalizedName,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $TaskEntriesTable createAlias(String alias) {
    return $TaskEntriesTable(attachedDatabase, alias);
  }
}

class TaskEntry extends DataClass implements Insertable<TaskEntry> {
  final String id;
  final String ownerId;
  final String name;
  final String normalizedName;
  final DateTime? deletedAt;
  const TaskEntry({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.normalizedName,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  TaskEntriesCompanion toCompanion(bool nullToAbsent) {
    return TaskEntriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      name: Value(name),
      normalizedName: Value(normalizedName),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskEntry copyWith({
    String? id,
    String? ownerId,
    String? name,
    String? normalizedName,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskEntry copyWithCompanion(TaskEntriesCompanion data) {
    return TaskEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, name, normalizedName, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName &&
          other.deletedAt == this.deletedAt);
}

class TaskEntriesCompanion extends UpdateCompanion<TaskEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> name;
  final Value<String> normalizedName;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const TaskEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskEntriesCompanion.insert({
    required String id,
    required String ownerId,
    required String name,
    required String normalizedName,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<TaskEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? name,
    Expression<String>? normalizedName,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? name,
    Value<String>? normalizedName,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return TaskEntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionEntriesTable extends SessionEntries
    with TableInfo<$SessionEntriesTable, SessionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<String> taskId = GeneratedColumn<String>(
    'task_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    taskId,
    payload,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}task_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $SessionEntriesTable createAlias(String alias) {
    return $SessionEntriesTable(attachedDatabase, alias);
  }
}

class SessionEntry extends DataClass implements Insertable<SessionEntry> {
  final String id;
  final String ownerId;
  final String? taskId;
  final String payload;
  final DateTime? deletedAt;
  const SessionEntry({
    required this.id,
    required this.ownerId,
    this.taskId,
    required this.payload,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    if (!nullToAbsent || taskId != null) {
      map['task_id'] = Variable<String>(taskId);
    }
    map['payload'] = Variable<String>(payload);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  SessionEntriesCompanion toCompanion(bool nullToAbsent) {
    return SessionEntriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      taskId: taskId == null && nullToAbsent
          ? const Value.absent()
          : Value(taskId),
      payload: Value(payload),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory SessionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      taskId: serializer.fromJson<String?>(json['taskId']),
      payload: serializer.fromJson<String>(json['payload']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'taskId': serializer.toJson<String?>(taskId),
      'payload': serializer.toJson<String>(payload),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  SessionEntry copyWith({
    String? id,
    String? ownerId,
    Value<String?> taskId = const Value.absent(),
    String? payload,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => SessionEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    taskId: taskId.present ? taskId.value : this.taskId,
    payload: payload ?? this.payload,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  SessionEntry copyWithCompanion(SessionEntriesCompanion data) {
    return SessionEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      payload: data.payload.present ? data.payload.value : this.payload,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('taskId: $taskId, ')
          ..write('payload: $payload, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, ownerId, taskId, payload, deletedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.taskId == this.taskId &&
          other.payload == this.payload &&
          other.deletedAt == this.deletedAt);
}

class SessionEntriesCompanion extends UpdateCompanion<SessionEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String?> taskId;
  final Value<String> payload;
  final Value<DateTime?> deletedAt;
  final Value<int> rowid;
  const SessionEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.taskId = const Value.absent(),
    this.payload = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionEntriesCompanion.insert({
    required String id,
    required String ownerId,
    this.taskId = const Value.absent(),
    required String payload,
    this.deletedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       payload = Value(payload);
  static Insertable<SessionEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? taskId,
    Expression<String>? payload,
    Expression<DateTime>? deletedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (taskId != null) 'task_id': taskId,
      if (payload != null) 'payload': payload,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String?>? taskId,
    Value<String>? payload,
    Value<DateTime?>? deletedAt,
    Value<int>? rowid,
  }) {
    return SessionEntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      taskId: taskId ?? this.taskId,
      payload: payload ?? this.payload,
      deletedAt: deletedAt ?? this.deletedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<String>(taskId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('taskId: $taskId, ')
          ..write('payload: $payload, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimerSnapshotsTable extends TimerSnapshots
    with TableInfo<$TimerSnapshotsTable, TimerSnapshot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimerSnapshotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ownerId, payload];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'timer_snapshots';
  @override
  VerificationContext validateIntegrity(
    Insertable<TimerSnapshot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId};
  @override
  TimerSnapshot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimerSnapshot(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $TimerSnapshotsTable createAlias(String alias) {
    return $TimerSnapshotsTable(attachedDatabase, alias);
  }
}

class TimerSnapshot extends DataClass implements Insertable<TimerSnapshot> {
  final String ownerId;
  final String payload;
  const TimerSnapshot({required this.ownerId, required this.payload});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  TimerSnapshotsCompanion toCompanion(bool nullToAbsent) {
    return TimerSnapshotsCompanion(
      ownerId: Value(ownerId),
      payload: Value(payload),
    );
  }

  factory TimerSnapshot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimerSnapshot(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'payload': serializer.toJson<String>(payload),
    };
  }

  TimerSnapshot copyWith({String? ownerId, String? payload}) => TimerSnapshot(
    ownerId: ownerId ?? this.ownerId,
    payload: payload ?? this.payload,
  );
  TimerSnapshot copyWithCompanion(TimerSnapshotsCompanion data) {
    return TimerSnapshot(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimerSnapshot(')
          ..write('ownerId: $ownerId, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerId, payload);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimerSnapshot &&
          other.ownerId == this.ownerId &&
          other.payload == this.payload);
}

class TimerSnapshotsCompanion extends UpdateCompanion<TimerSnapshot> {
  final Value<String> ownerId;
  final Value<String> payload;
  final Value<int> rowid;
  const TimerSnapshotsCompanion({
    this.ownerId = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TimerSnapshotsCompanion.insert({
    required String ownerId,
    required String payload,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       payload = Value(payload);
  static Insertable<TimerSnapshot> custom({
    Expression<String>? ownerId,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TimerSnapshotsCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return TimerSnapshotsCompanion(
      ownerId: ownerId ?? this.ownerId,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimerSnapshotsCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingEntriesTable extends SettingEntries
    with TableInfo<$SettingEntriesTable, SettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [ownerId, key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'setting_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {ownerId, key};
  @override
  SettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingEntry(
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingEntriesTable createAlias(String alias) {
    return $SettingEntriesTable(attachedDatabase, alias);
  }
}

class SettingEntry extends DataClass implements Insertable<SettingEntry> {
  final String ownerId;
  final String key;
  final String value;
  const SettingEntry({
    required this.ownerId,
    required this.key,
    required this.value,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['owner_id'] = Variable<String>(ownerId);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return SettingEntriesCompanion(
      ownerId: Value(ownerId),
      key: Value(key),
      value: Value(value),
    );
  }

  factory SettingEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingEntry(
      ownerId: serializer.fromJson<String>(json['ownerId']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'ownerId': serializer.toJson<String>(ownerId),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingEntry copyWith({String? ownerId, String? key, String? value}) =>
      SettingEntry(
        ownerId: ownerId ?? this.ownerId,
        key: key ?? this.key,
        value: value ?? this.value,
      );
  SettingEntry copyWithCompanion(SettingEntriesCompanion data) {
    return SettingEntry(
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingEntry(')
          ..write('ownerId: $ownerId, ')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(ownerId, key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingEntry &&
          other.ownerId == this.ownerId &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingEntriesCompanion extends UpdateCompanion<SettingEntry> {
  final Value<String> ownerId;
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingEntriesCompanion({
    this.ownerId = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingEntriesCompanion.insert({
    required String ownerId,
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : ownerId = Value(ownerId),
       key = Value(key),
       value = Value(value);
  static Insertable<SettingEntry> custom({
    Expression<String>? ownerId,
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (ownerId != null) 'owner_id': ownerId,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingEntriesCompanion copyWith({
    Value<String>? ownerId,
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingEntriesCompanion(
      ownerId: ownerId ?? this.ownerId,
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
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
    return (StringBuffer('SettingEntriesCompanion(')
          ..write('ownerId: $ownerId, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingChangesTable extends PendingChanges
    with TableInfo<$PendingChangesTable, PendingChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _recordIdMeta = const VerificationMeta(
    'recordId',
  );
  @override
  late final GeneratedColumn<String> recordId = GeneratedColumn<String>(
    'record_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    kind,
    recordId,
    payload,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('record_id')) {
      context.handle(
        _recordIdMeta,
        recordId.isAcceptableOrUnknown(data['record_id']!, _recordIdMeta),
      );
    } else if (isInserting) {
      context.missing(_recordIdMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingChange(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      recordId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}record_id'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PendingChangesTable createAlias(String alias) {
    return $PendingChangesTable(attachedDatabase, alias);
  }
}

class PendingChange extends DataClass implements Insertable<PendingChange> {
  final String id;
  final String ownerId;
  final String kind;
  final String recordId;
  final String payload;
  final DateTime createdAt;
  const PendingChange({
    required this.id,
    required this.ownerId,
    required this.kind,
    required this.recordId,
    required this.payload,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['kind'] = Variable<String>(kind);
    map['record_id'] = Variable<String>(recordId);
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PendingChangesCompanion toCompanion(bool nullToAbsent) {
    return PendingChangesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      kind: Value(kind),
      recordId: Value(recordId),
      payload: Value(payload),
      createdAt: Value(createdAt),
    );
  }

  factory PendingChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingChange(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      kind: serializer.fromJson<String>(json['kind']),
      recordId: serializer.fromJson<String>(json['recordId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'kind': serializer.toJson<String>(kind),
      'recordId': serializer.toJson<String>(recordId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  PendingChange copyWith({
    String? id,
    String? ownerId,
    String? kind,
    String? recordId,
    String? payload,
    DateTime? createdAt,
  }) => PendingChange(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    kind: kind ?? this.kind,
    recordId: recordId ?? this.recordId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
  );
  PendingChange copyWithCompanion(PendingChangesCompanion data) {
    return PendingChange(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      kind: data.kind.present ? data.kind.value : this.kind,
      recordId: data.recordId.present ? data.recordId.value : this.recordId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingChange(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, ownerId, kind, recordId, payload, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingChange &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.kind == this.kind &&
          other.recordId == this.recordId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt);
}

class PendingChangesCompanion extends UpdateCompanion<PendingChange> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> kind;
  final Value<String> recordId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const PendingChangesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.kind = const Value.absent(),
    this.recordId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingChangesCompanion.insert({
    required String id,
    required String ownerId,
    required String kind,
    required String recordId,
    required String payload,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       kind = Value(kind),
       recordId = Value(recordId),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingChange> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? kind,
    Expression<String>? recordId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (kind != null) 'kind': kind,
      if (recordId != null) 'record_id': recordId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingChangesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? kind,
    Value<String>? recordId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return PendingChangesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      kind: kind ?? this.kind,
      recordId: recordId ?? this.recordId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (recordId.present) {
      map['record_id'] = Variable<String>(recordId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingChangesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('kind: $kind, ')
          ..write('recordId: $recordId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ConflictEntriesTable extends ConflictEntries
    with TableInfo<$ConflictEntriesTable, ConflictEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConflictEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<String> ownerId = GeneratedColumn<String>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _firstSessionIdMeta = const VerificationMeta(
    'firstSessionId',
  );
  @override
  late final GeneratedColumn<String> firstSessionId = GeneratedColumn<String>(
    'first_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondSessionIdMeta = const VerificationMeta(
    'secondSessionId',
  );
  @override
  late final GeneratedColumn<String> secondSessionId = GeneratedColumn<String>(
    'second_session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _winningSessionIdMeta = const VerificationMeta(
    'winningSessionId',
  );
  @override
  late final GeneratedColumn<String> winningSessionId = GeneratedColumn<String>(
    'winning_session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ownerId,
    firstSessionId,
    secondSessionId,
    winningSessionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conflict_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConflictEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    if (data.containsKey('first_session_id')) {
      context.handle(
        _firstSessionIdMeta,
        firstSessionId.isAcceptableOrUnknown(
          data['first_session_id']!,
          _firstSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstSessionIdMeta);
    }
    if (data.containsKey('second_session_id')) {
      context.handle(
        _secondSessionIdMeta,
        secondSessionId.isAcceptableOrUnknown(
          data['second_session_id']!,
          _secondSessionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_secondSessionIdMeta);
    }
    if (data.containsKey('winning_session_id')) {
      context.handle(
        _winningSessionIdMeta,
        winningSessionId.isAcceptableOrUnknown(
          data['winning_session_id']!,
          _winningSessionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ConflictEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConflictEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      ownerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_id'],
      )!,
      firstSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}first_session_id'],
      )!,
      secondSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}second_session_id'],
      )!,
      winningSessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}winning_session_id'],
      ),
    );
  }

  @override
  $ConflictEntriesTable createAlias(String alias) {
    return $ConflictEntriesTable(attachedDatabase, alias);
  }
}

class ConflictEntry extends DataClass implements Insertable<ConflictEntry> {
  final String id;
  final String ownerId;
  final String firstSessionId;
  final String secondSessionId;
  final String? winningSessionId;
  const ConflictEntry({
    required this.id,
    required this.ownerId,
    required this.firstSessionId,
    required this.secondSessionId,
    this.winningSessionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['owner_id'] = Variable<String>(ownerId);
    map['first_session_id'] = Variable<String>(firstSessionId);
    map['second_session_id'] = Variable<String>(secondSessionId);
    if (!nullToAbsent || winningSessionId != null) {
      map['winning_session_id'] = Variable<String>(winningSessionId);
    }
    return map;
  }

  ConflictEntriesCompanion toCompanion(bool nullToAbsent) {
    return ConflictEntriesCompanion(
      id: Value(id),
      ownerId: Value(ownerId),
      firstSessionId: Value(firstSessionId),
      secondSessionId: Value(secondSessionId),
      winningSessionId: winningSessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(winningSessionId),
    );
  }

  factory ConflictEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConflictEntry(
      id: serializer.fromJson<String>(json['id']),
      ownerId: serializer.fromJson<String>(json['ownerId']),
      firstSessionId: serializer.fromJson<String>(json['firstSessionId']),
      secondSessionId: serializer.fromJson<String>(json['secondSessionId']),
      winningSessionId: serializer.fromJson<String?>(json['winningSessionId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'ownerId': serializer.toJson<String>(ownerId),
      'firstSessionId': serializer.toJson<String>(firstSessionId),
      'secondSessionId': serializer.toJson<String>(secondSessionId),
      'winningSessionId': serializer.toJson<String?>(winningSessionId),
    };
  }

  ConflictEntry copyWith({
    String? id,
    String? ownerId,
    String? firstSessionId,
    String? secondSessionId,
    Value<String?> winningSessionId = const Value.absent(),
  }) => ConflictEntry(
    id: id ?? this.id,
    ownerId: ownerId ?? this.ownerId,
    firstSessionId: firstSessionId ?? this.firstSessionId,
    secondSessionId: secondSessionId ?? this.secondSessionId,
    winningSessionId: winningSessionId.present
        ? winningSessionId.value
        : this.winningSessionId,
  );
  ConflictEntry copyWithCompanion(ConflictEntriesCompanion data) {
    return ConflictEntry(
      id: data.id.present ? data.id.value : this.id,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
      firstSessionId: data.firstSessionId.present
          ? data.firstSessionId.value
          : this.firstSessionId,
      secondSessionId: data.secondSessionId.present
          ? data.secondSessionId.value
          : this.secondSessionId,
      winningSessionId: data.winningSessionId.present
          ? data.winningSessionId.value
          : this.winningSessionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConflictEntry(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('firstSessionId: $firstSessionId, ')
          ..write('secondSessionId: $secondSessionId, ')
          ..write('winningSessionId: $winningSessionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ownerId,
    firstSessionId,
    secondSessionId,
    winningSessionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConflictEntry &&
          other.id == this.id &&
          other.ownerId == this.ownerId &&
          other.firstSessionId == this.firstSessionId &&
          other.secondSessionId == this.secondSessionId &&
          other.winningSessionId == this.winningSessionId);
}

class ConflictEntriesCompanion extends UpdateCompanion<ConflictEntry> {
  final Value<String> id;
  final Value<String> ownerId;
  final Value<String> firstSessionId;
  final Value<String> secondSessionId;
  final Value<String?> winningSessionId;
  final Value<int> rowid;
  const ConflictEntriesCompanion({
    this.id = const Value.absent(),
    this.ownerId = const Value.absent(),
    this.firstSessionId = const Value.absent(),
    this.secondSessionId = const Value.absent(),
    this.winningSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConflictEntriesCompanion.insert({
    required String id,
    required String ownerId,
    required String firstSessionId,
    required String secondSessionId,
    this.winningSessionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       ownerId = Value(ownerId),
       firstSessionId = Value(firstSessionId),
       secondSessionId = Value(secondSessionId);
  static Insertable<ConflictEntry> custom({
    Expression<String>? id,
    Expression<String>? ownerId,
    Expression<String>? firstSessionId,
    Expression<String>? secondSessionId,
    Expression<String>? winningSessionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ownerId != null) 'owner_id': ownerId,
      if (firstSessionId != null) 'first_session_id': firstSessionId,
      if (secondSessionId != null) 'second_session_id': secondSessionId,
      if (winningSessionId != null) 'winning_session_id': winningSessionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConflictEntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? ownerId,
    Value<String>? firstSessionId,
    Value<String>? secondSessionId,
    Value<String?>? winningSessionId,
    Value<int>? rowid,
  }) {
    return ConflictEntriesCompanion(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      firstSessionId: firstSessionId ?? this.firstSessionId,
      secondSessionId: secondSessionId ?? this.secondSessionId,
      winningSessionId: winningSessionId ?? this.winningSessionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<String>(ownerId.value);
    }
    if (firstSessionId.present) {
      map['first_session_id'] = Variable<String>(firstSessionId.value);
    }
    if (secondSessionId.present) {
      map['second_session_id'] = Variable<String>(secondSessionId.value);
    }
    if (winningSessionId.present) {
      map['winning_session_id'] = Variable<String>(winningSessionId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConflictEntriesCompanion(')
          ..write('id: $id, ')
          ..write('ownerId: $ownerId, ')
          ..write('firstSessionId: $firstSessionId, ')
          ..write('secondSessionId: $secondSessionId, ')
          ..write('winningSessionId: $winningSessionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TaskEntriesTable taskEntries = $TaskEntriesTable(this);
  late final $SessionEntriesTable sessionEntries = $SessionEntriesTable(this);
  late final $TimerSnapshotsTable timerSnapshots = $TimerSnapshotsTable(this);
  late final $SettingEntriesTable settingEntries = $SettingEntriesTable(this);
  late final $PendingChangesTable pendingChanges = $PendingChangesTable(this);
  late final $ConflictEntriesTable conflictEntries = $ConflictEntriesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    taskEntries,
    sessionEntries,
    timerSnapshots,
    settingEntries,
    pendingChanges,
    conflictEntries,
  ];
}

typedef $$TaskEntriesTableCreateCompanionBuilder =
    TaskEntriesCompanion Function({
      required String id,
      required String ownerId,
      required String name,
      required String normalizedName,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$TaskEntriesTableUpdateCompanionBuilder =
    TaskEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> name,
      Value<String> normalizedName,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$TaskEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TaskEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TaskEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskEntriesTable> {
  $$TaskEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$TaskEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskEntriesTable,
          TaskEntry,
          $$TaskEntriesTableFilterComposer,
          $$TaskEntriesTableOrderingComposer,
          $$TaskEntriesTableAnnotationComposer,
          $$TaskEntriesTableCreateCompanionBuilder,
          $$TaskEntriesTableUpdateCompanionBuilder,
          (
            TaskEntry,
            BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>,
          ),
          TaskEntry,
          PrefetchHooks Function()
        > {
  $$TaskEntriesTableTableManager(_$AppDatabase db, $TaskEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskEntriesCompanion(
                id: id,
                ownerId: ownerId,
                name: name,
                normalizedName: normalizedName,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String name,
                required String normalizedName,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskEntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                name: name,
                normalizedName: normalizedName,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TaskEntriesTable, TaskEntry>(table),
                  BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TaskEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskEntriesTable,
      TaskEntry,
      $$TaskEntriesTableFilterComposer,
      $$TaskEntriesTableOrderingComposer,
      $$TaskEntriesTableAnnotationComposer,
      $$TaskEntriesTableCreateCompanionBuilder,
      $$TaskEntriesTableUpdateCompanionBuilder,
      (TaskEntry, BaseReferences<_$AppDatabase, $TaskEntriesTable, TaskEntry>),
      TaskEntry,
      PrefetchHooks Function()
    >;
typedef $$SessionEntriesTableCreateCompanionBuilder =
    SessionEntriesCompanion Function({
      required String id,
      required String ownerId,
      Value<String?> taskId,
      required String payload,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });
typedef $$SessionEntriesTableUpdateCompanionBuilder =
    SessionEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String?> taskId,
      Value<String> payload,
      Value<DateTime?> deletedAt,
      Value<int> rowid,
    });

class $$SessionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SessionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get taskId => $composableBuilder(
    column: $table.taskId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionEntriesTable> {
  $$SessionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get taskId =>
      $composableBuilder(column: $table.taskId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);
}

class $$SessionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionEntriesTable,
          SessionEntry,
          $$SessionEntriesTableFilterComposer,
          $$SessionEntriesTableOrderingComposer,
          $$SessionEntriesTableAnnotationComposer,
          $$SessionEntriesTableCreateCompanionBuilder,
          $$SessionEntriesTableUpdateCompanionBuilder,
          (
            SessionEntry,
            BaseReferences<_$AppDatabase, $SessionEntriesTable, SessionEntry>,
          ),
          SessionEntry,
          PrefetchHooks Function()
        > {
  $$SessionEntriesTableTableManager(
    _$AppDatabase db,
    $SessionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String?> taskId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEntriesCompanion(
                id: id,
                ownerId: ownerId,
                taskId: taskId,
                payload: payload,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                Value<String?> taskId = const Value.absent(),
                required String payload,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionEntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                taskId: taskId,
                payload: payload,
                deletedAt: deletedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SessionEntriesTable, SessionEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SessionEntriesTable,
                    SessionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SessionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionEntriesTable,
      SessionEntry,
      $$SessionEntriesTableFilterComposer,
      $$SessionEntriesTableOrderingComposer,
      $$SessionEntriesTableAnnotationComposer,
      $$SessionEntriesTableCreateCompanionBuilder,
      $$SessionEntriesTableUpdateCompanionBuilder,
      (
        SessionEntry,
        BaseReferences<_$AppDatabase, $SessionEntriesTable, SessionEntry>,
      ),
      SessionEntry,
      PrefetchHooks Function()
    >;
typedef $$TimerSnapshotsTableCreateCompanionBuilder =
    TimerSnapshotsCompanion Function({
      required String ownerId,
      required String payload,
      Value<int> rowid,
    });
typedef $$TimerSnapshotsTableUpdateCompanionBuilder =
    TimerSnapshotsCompanion Function({
      Value<String> ownerId,
      Value<String> payload,
      Value<int> rowid,
    });

class $$TimerSnapshotsTableFilterComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTable> {
  $$TimerSnapshotsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TimerSnapshotsTableOrderingComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTable> {
  $$TimerSnapshotsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TimerSnapshotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TimerSnapshotsTable> {
  $$TimerSnapshotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$TimerSnapshotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TimerSnapshotsTable,
          TimerSnapshot,
          $$TimerSnapshotsTableFilterComposer,
          $$TimerSnapshotsTableOrderingComposer,
          $$TimerSnapshotsTableAnnotationComposer,
          $$TimerSnapshotsTableCreateCompanionBuilder,
          $$TimerSnapshotsTableUpdateCompanionBuilder,
          (
            TimerSnapshot,
            BaseReferences<_$AppDatabase, $TimerSnapshotsTable, TimerSnapshot>,
          ),
          TimerSnapshot,
          PrefetchHooks Function()
        > {
  $$TimerSnapshotsTableTableManager(
    _$AppDatabase db,
    $TimerSnapshotsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TimerSnapshotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TimerSnapshotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TimerSnapshotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TimerSnapshotsCompanion(
                ownerId: ownerId,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String payload,
                Value<int> rowid = const Value.absent(),
              }) => TimerSnapshotsCompanion.insert(
                ownerId: ownerId,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TimerSnapshotsTable, TimerSnapshot>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TimerSnapshotsTable,
                    TimerSnapshot
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TimerSnapshotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TimerSnapshotsTable,
      TimerSnapshot,
      $$TimerSnapshotsTableFilterComposer,
      $$TimerSnapshotsTableOrderingComposer,
      $$TimerSnapshotsTableAnnotationComposer,
      $$TimerSnapshotsTableCreateCompanionBuilder,
      $$TimerSnapshotsTableUpdateCompanionBuilder,
      (
        TimerSnapshot,
        BaseReferences<_$AppDatabase, $TimerSnapshotsTable, TimerSnapshot>,
      ),
      TimerSnapshot,
      PrefetchHooks Function()
    >;
typedef $$SettingEntriesTableCreateCompanionBuilder =
    SettingEntriesCompanion Function({
      required String ownerId,
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingEntriesTableUpdateCompanionBuilder =
    SettingEntriesCompanion Function({
      Value<String> ownerId,
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingEntriesTable> {
  $$SettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingEntriesTable,
          SettingEntry,
          $$SettingEntriesTableFilterComposer,
          $$SettingEntriesTableOrderingComposer,
          $$SettingEntriesTableAnnotationComposer,
          $$SettingEntriesTableCreateCompanionBuilder,
          $$SettingEntriesTableUpdateCompanionBuilder,
          (
            SettingEntry,
            BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
          ),
          SettingEntry,
          PrefetchHooks Function()
        > {
  $$SettingEntriesTableTableManager(
    _$AppDatabase db,
    $SettingEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> ownerId = const Value.absent(),
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion(
                ownerId: ownerId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String ownerId,
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingEntriesCompanion.insert(
                ownerId: ownerId,
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SettingEntriesTable, SettingEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $SettingEntriesTable,
                    SettingEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingEntriesTable,
      SettingEntry,
      $$SettingEntriesTableFilterComposer,
      $$SettingEntriesTableOrderingComposer,
      $$SettingEntriesTableAnnotationComposer,
      $$SettingEntriesTableCreateCompanionBuilder,
      $$SettingEntriesTableUpdateCompanionBuilder,
      (
        SettingEntry,
        BaseReferences<_$AppDatabase, $SettingEntriesTable, SettingEntry>,
      ),
      SettingEntry,
      PrefetchHooks Function()
    >;
typedef $$PendingChangesTableCreateCompanionBuilder =
    PendingChangesCompanion Function({
      required String id,
      required String ownerId,
      required String kind,
      required String recordId,
      required String payload,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$PendingChangesTableUpdateCompanionBuilder =
    PendingChangesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> kind,
      Value<String> recordId,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$PendingChangesTableFilterComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recordId => $composableBuilder(
    column: $table.recordId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PendingChangesTable> {
  $$PendingChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get recordId =>
      $composableBuilder(column: $table.recordId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$PendingChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PendingChangesTable,
          PendingChange,
          $$PendingChangesTableFilterComposer,
          $$PendingChangesTableOrderingComposer,
          $$PendingChangesTableAnnotationComposer,
          $$PendingChangesTableCreateCompanionBuilder,
          $$PendingChangesTableUpdateCompanionBuilder,
          (
            PendingChange,
            BaseReferences<_$AppDatabase, $PendingChangesTable, PendingChange>,
          ),
          PendingChange,
          PrefetchHooks Function()
        > {
  $$PendingChangesTableTableManager(
    _$AppDatabase db,
    $PendingChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> recordId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingChangesCompanion(
                id: id,
                ownerId: ownerId,
                kind: kind,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String kind,
                required String recordId,
                required String payload,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => PendingChangesCompanion.insert(
                id: id,
                ownerId: ownerId,
                kind: kind,
                recordId: recordId,
                payload: payload,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PendingChangesTable, PendingChange>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PendingChangesTable,
                    PendingChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PendingChangesTable,
      PendingChange,
      $$PendingChangesTableFilterComposer,
      $$PendingChangesTableOrderingComposer,
      $$PendingChangesTableAnnotationComposer,
      $$PendingChangesTableCreateCompanionBuilder,
      $$PendingChangesTableUpdateCompanionBuilder,
      (
        PendingChange,
        BaseReferences<_$AppDatabase, $PendingChangesTable, PendingChange>,
      ),
      PendingChange,
      PrefetchHooks Function()
    >;
typedef $$ConflictEntriesTableCreateCompanionBuilder =
    ConflictEntriesCompanion Function({
      required String id,
      required String ownerId,
      required String firstSessionId,
      required String secondSessionId,
      Value<String?> winningSessionId,
      Value<int> rowid,
    });
typedef $$ConflictEntriesTableUpdateCompanionBuilder =
    ConflictEntriesCompanion Function({
      Value<String> id,
      Value<String> ownerId,
      Value<String> firstSessionId,
      Value<String> secondSessionId,
      Value<String?> winningSessionId,
      Value<int> rowid,
    });

class $$ConflictEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ConflictEntriesTable> {
  $$ConflictEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firstSessionId => $composableBuilder(
    column: $table.firstSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondSessionId => $composableBuilder(
    column: $table.secondSessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get winningSessionId => $composableBuilder(
    column: $table.winningSessionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConflictEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ConflictEntriesTable> {
  $$ConflictEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firstSessionId => $composableBuilder(
    column: $table.firstSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondSessionId => $composableBuilder(
    column: $table.secondSessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get winningSessionId => $composableBuilder(
    column: $table.winningSessionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConflictEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConflictEntriesTable> {
  $$ConflictEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);

  GeneratedColumn<String> get firstSessionId => $composableBuilder(
    column: $table.firstSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get secondSessionId => $composableBuilder(
    column: $table.secondSessionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get winningSessionId => $composableBuilder(
    column: $table.winningSessionId,
    builder: (column) => column,
  );
}

class $$ConflictEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConflictEntriesTable,
          ConflictEntry,
          $$ConflictEntriesTableFilterComposer,
          $$ConflictEntriesTableOrderingComposer,
          $$ConflictEntriesTableAnnotationComposer,
          $$ConflictEntriesTableCreateCompanionBuilder,
          $$ConflictEntriesTableUpdateCompanionBuilder,
          (
            ConflictEntry,
            BaseReferences<_$AppDatabase, $ConflictEntriesTable, ConflictEntry>,
          ),
          ConflictEntry,
          PrefetchHooks Function()
        > {
  $$ConflictEntriesTableTableManager(
    _$AppDatabase db,
    $ConflictEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConflictEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConflictEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConflictEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> ownerId = const Value.absent(),
                Value<String> firstSessionId = const Value.absent(),
                Value<String> secondSessionId = const Value.absent(),
                Value<String?> winningSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictEntriesCompanion(
                id: id,
                ownerId: ownerId,
                firstSessionId: firstSessionId,
                secondSessionId: secondSessionId,
                winningSessionId: winningSessionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String ownerId,
                required String firstSessionId,
                required String secondSessionId,
                Value<String?> winningSessionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConflictEntriesCompanion.insert(
                id: id,
                ownerId: ownerId,
                firstSessionId: firstSessionId,
                secondSessionId: secondSessionId,
                winningSessionId: winningSessionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConflictEntriesTable, ConflictEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ConflictEntriesTable,
                    ConflictEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConflictEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConflictEntriesTable,
      ConflictEntry,
      $$ConflictEntriesTableFilterComposer,
      $$ConflictEntriesTableOrderingComposer,
      $$ConflictEntriesTableAnnotationComposer,
      $$ConflictEntriesTableCreateCompanionBuilder,
      $$ConflictEntriesTableUpdateCompanionBuilder,
      (
        ConflictEntry,
        BaseReferences<_$AppDatabase, $ConflictEntriesTable, ConflictEntry>,
      ),
      ConflictEntry,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TaskEntriesTableTableManager get taskEntries =>
      $$TaskEntriesTableTableManager(_db, _db.taskEntries);
  $$SessionEntriesTableTableManager get sessionEntries =>
      $$SessionEntriesTableTableManager(_db, _db.sessionEntries);
  $$TimerSnapshotsTableTableManager get timerSnapshots =>
      $$TimerSnapshotsTableTableManager(_db, _db.timerSnapshots);
  $$SettingEntriesTableTableManager get settingEntries =>
      $$SettingEntriesTableTableManager(_db, _db.settingEntries);
  $$PendingChangesTableTableManager get pendingChanges =>
      $$PendingChangesTableTableManager(_db, _db.pendingChanges);
  $$ConflictEntriesTableTableManager get conflictEntries =>
      $$ConflictEntriesTableTableManager(_db, _db.conflictEntries);
}
