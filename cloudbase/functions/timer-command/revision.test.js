'use strict';
const test = require('node:test');
const assert = require('node:assert/strict');
const {canWriteSession} = require('./revision');

test('new session starts at revision zero', () => {
  assert.equal(canWriteSession('{"revision":0}', null), true);
  assert.equal(canWriteSession('{"revision":2}', null), false);
});
test('stale concurrent session edit cannot overwrite newer revision', () => {
  assert.equal(canWriteSession('{"revision":1}', '{"revision":0}'), true);
  assert.equal(canWriteSession('{"revision":1}', '{"revision":1}'), false);
});
test('malformed revisions fail closed', () => {
  assert.equal(canWriteSession('{"revision":"2"}', '{"revision":1}'), false);
  assert.equal(canWriteSession('{', '{"revision":1}'), false);
});
