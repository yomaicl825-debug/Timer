'use strict';

const cloudbase = require('@cloudbase/node-sdk');
const {canWriteSession} = require('./revision');
const app = cloudbase.init({env: cloudbase.SYMBOL_CURRENT_ENV});
const db = app.database();

function ownerId() {
  const {uid} = app.auth().getUserInfo();
  return typeof uid === 'string' && uid.length ? uid : null;
}

async function once(uid, operationId, apply) {
  if (typeof operationId !== 'string' || !operationId.length) {
    return {status: 'permissionDenied'};
  }
  const result = await db.runTransaction(async tx => {
    const op = tx.collection('timer_operations').doc(`${uid}:${operationId}`);
    const previous = await op.get();
    if (previous.data) return previous.data.result;
    const output = await apply(tx);
    await op.set({ownerId: uid, result: output, createdAt: new Date()});
    return output;
  });
  return result && Object.prototype.hasOwnProperty.call(result, 'result')
    ? result.result : result;
}

async function pull(uid, cursor) {
  let query = db.collection('timer_records').where({ownerId: uid});
  if (cursor) query = query.where({sequence: db.command.gt(Number(cursor))});
  const page = await query.orderBy('sequence', 'asc').limit(100).get();
  const records = page.data || [];
  return {status: 'success', records,
    cursor: records.length ? String(records[records.length - 1].sequence) : cursor,
    hasMore: records.length === 100};
}

async function push(uid, changes) {
  if (!Array.isArray(changes) || changes.length > 40) {
    return {status: 'permissionDenied'};
  }
  const appliedIds = [];
  for (const change of changes) {
    if (!change || change.ownerId !== uid ||
        typeof change.recordId !== 'string' ||
        typeof change.operationId !== 'string' ||
        !['task', 'session', 'timer', 'setting'].includes(change.kind)) {
      return {status: 'permissionDenied'};
    }
    const result = await once(uid, change.operationId, async tx => {
      const record = tx.collection('timer_records')
        .doc(`${uid}:${change.kind}:${change.recordId}`);
      if (change.kind === 'session') {
        const current = (await record.get()).data;
        if (!canWriteSession(change.payload, current?.payload)) {
          return {status: 'conflict', record: current || null,
            recordId: change.recordId, kind: change.kind};
        }
      }
      const sequenceDoc = tx.collection('sync_cursors').doc(uid);
      const current = (await sequenceDoc.get()).data;
      const sequence = (current?.sequence || 0) + 1;
      await sequenceDoc.set({ownerId: uid, sequence});
      await record.set({ownerId: uid, kind: change.kind,
        recordId: change.recordId, payload: change.payload,
        sequence, updatedAt: new Date().toISOString()});
      return {status: 'success'};
    });
    if (result.status !== 'success') return {...result, appliedIds};
    appliedIds.push(change.operationId);
  }
  return {status: 'success', applied: appliedIds.length, appliedIds};
}

async function timerCommand(uid, event) {
  return once(uid, event.operationId, async tx => {
    const lock = tx.collection('timer_locks').doc(uid);
    const current = (await lock.get()).data;
    if (event.action === 'claim') {
      if (current && current.active) return {status: 'conflict'};
      await lock.set({ownerId: uid, active: true,
        revision: (current?.revision || 0) + 1,
        snapshot: event.snapshot, updatedAt: new Date()});
      return {status: 'success', revision: (current?.revision || 0) + 1};
    }
    if (event.action === 'update') {
      if (!current?.active || current.revision !== event.expectedRevision) {
        return {status: 'conflict'};
      }
      await lock.set({...current, revision: current.revision + 1,
        snapshot: event.snapshot, updatedAt: new Date()});
      return {status: 'success', revision: current.revision + 1};
    }
    if (event.action === 'release') {
      if (current?.active) {
        if (!event.startedAt ||
            current.snapshot?.startedAt !== event.startedAt) {
          return {status: 'conflict'};
        }
        await lock.set({...current, active: false, updatedAt: new Date()});
      }
      return {status: 'success'};
    }
    return {status: 'permissionDenied'};
  });
}

exports.main = async (event) => {
  const uid = ownerId();
  if (!uid) return {status: 'unauthenticated'};
  if (!event || typeof event.action !== 'string') {
    return {status: 'permissionDenied'};
  }
  if (event.action === 'inspect') {
    const lock = (await db.collection('timer_locks').doc(uid).get()).data;
    return {status: 'success', active: lock?.active || false,
      revision: lock?.revision || 0, snapshot: lock?.snapshot || null};
  }
  if (event.action === 'pull') return pull(uid, event.cursor);
  if (event.action === 'push') return push(uid, event.changes);
  if (['claim', 'update', 'release'].includes(event.action)) {
    return timerCommand(uid, event);
  }
  return {status: 'permissionDenied'};
};
