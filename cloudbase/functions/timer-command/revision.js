'use strict';

function canWriteSession(incomingPayload, currentPayload) {
  try {
    const incoming = JSON.parse(incomingPayload);
    if (!Number.isSafeInteger(incoming.revision) || incoming.revision < 0) return false;
    if (currentPayload == null) return incoming.revision === 0;
    const current = JSON.parse(currentPayload);
    return Number.isSafeInteger(current.revision) &&
      incoming.revision === current.revision + 1;
  } catch (_) {
    return false;
  }
}

module.exports = {canWriteSession};
