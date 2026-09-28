async function assertTagTarget({repository, tag, expectedSha, request}) {
  if (!/^[\w.-]+\/[\w.-]+$/.test(repository) || !/^[a-f0-9]{40}$/i.test(expectedSha)) {
    throw new Error('Invalid release repository or source SHA');
  }
  const get = request ?? (async route => {
    const response = await fetch(`https://api.github.com/repos/${repository}/${route}`, {
      headers: {Accept: 'application/vnd.github+json', Authorization: `Bearer ${process.env.GH_TOKEN}`},
    });
    return {status: response.status, body: response.ok ? await response.json() : null};
  });
  let response = await get(`git/ref/tags/${encodeURIComponent(tag)}`);
  if (response.status === 404) return 'absent';
  if (response.status !== 200) throw new Error(`Unable to check release tag (${response.status})`);
  let object = response.body?.object;
  for (let depth = 0; object?.type === 'tag' && depth < 8; depth++) {
    response = await get(`git/tags/${object.sha}`);
    if (response.status !== 200) throw new Error('Unable to resolve annotated release tag');
    object = response.body?.object;
  }
  if (object?.type !== 'commit' || object.sha !== expectedSha) {
    throw new Error('Existing version tag does not point to the tested source; refusing publication');
  }
  return 'matching';
}

module.exports = {assertTagTarget};
if (require.main === module) {
  assertTagTarget({repository: process.env.GH_REPO, tag: process.env.VERSION_TAG, expectedSha: process.env.EXPECTED_SHA})
    .then(result => process.stdout.write(`Release tag verified: ${result}\n`))
    .catch(error => {process.stderr.write(error.message+'\n');process.exitCode=1;});
}
