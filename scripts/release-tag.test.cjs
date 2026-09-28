const {test}=require('node:test');
const assert=require('node:assert/strict');
const {assertTagTarget}=require('./assert-release-tag.cjs');
const expectedSha='a'.repeat(40);
const options={repository:'owner/repo',tag:'V0.3',expectedSha};
test('new version tag may be created',async()=>{
  const routes=[];
  const result=await assertTagTarget({...options,request:async route=>{routes.push(route);return {status:404};}});
  assert.equal(result,'absent');assert.deepEqual(routes,['git/ref/tags/V0.3']);
});
test('existing lightweight tag must match tested commit',async()=>{
  assert.equal(await assertTagTarget({...options,request:async()=>({status:200,body:{object:{type:'commit',sha:expectedSha}}})}),'matching');
  await assert.rejects(assertTagTarget({...options,request:async()=>({status:200,body:{object:{type:'commit',sha:'b'.repeat(40)}}})}),/refusing publication/);
});
test('annotated tags are peeled before checking source',async()=>{
  const routes=[];
  assert.equal(await assertTagTarget({...options,request:async route=>{routes.push(route);return {status:200,body:{object:route==='git/ref/tags/V0.3'?{type:'tag',sha:'tag-object'}:{type:'commit',sha:expectedSha}}};}}),'matching');
  assert.deepEqual(routes,['git/ref/tags/V0.3','git/tags/tag-object']);
});
test('API failures do not count as a missing tag',async()=>{
  await assert.rejects(assertTagTarget({...options,request:async()=>({status:403})}),/Unable to check/);
});
