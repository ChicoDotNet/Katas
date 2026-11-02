import test from 'node:test';
import assert from 'node:assert/strict';
import { evaluate } from '../dist/src/network.js';
const post = (user, text) => ({type:'post',user,text});
const follow = (user,target) => ({type:'follow',user,target});
const dm = (from,to,text) => ({type:'dm',from,to,text});
const query = (type,user) => ({type,user});
test('BDD posting and reading: reverse chronological with stable event IDs', () => {
  const {results:[timeline]} = evaluate({events:[post('Alice','first'),post('Bob','other'),post('Alice','second')],queries:[query('timeline','Alice')]});
  assert.deepEqual(timeline.map(x=>[x.id,x.text]), [[3,'second'],[1,'first']]);
});
test('BDD following: directional, idempotent, excludes own posts, chronological', () => {
  const {results:[feed,reverse]} = evaluate({events:[post('Alice','a'),follow('Charlie','Alice'),follow('Charlie','Bob'),post('Bob','b'),follow('Charlie','Alice'),post('Charlie','own'),post('Alice','c')],queries:[query('feed','Charlie'),query('feed','Alice')]});
  assert.deepEqual(feed.map(x=>x.id),[7,4,1]); assert.deepEqual(reverse,[]);
});
test('BDD mentions: unique per post and not confused by email address', () => {
  const {results:[found]} = evaluate({events:[post('Bob','Hi @Charlie, @Charlie; not a@Charlie! @Alice')],queries:[query('mentions','Charlie')]});
  assert.deepEqual(found.map(x=>x.mentions),[['Charlie','Alice']]);
});
test('BDD links: metadata only, no network calls', () => {
  const {results:[timeline]} = evaluate({events:[post('Alice','See https://example.org/x?a=1, and http://abc.test!')],queries:[query('timeline','Alice')]});
  assert.deepEqual(timeline[0].links,['https://example.org/x?a=1','http://abc.test']);
});
test('BDD direct messages: private, recipient only, no feed/timeline leak', () => {
  const {results:[inboxA,inboxB,feed,timeline]}=evaluate({events:[dm('Mallory','Alice','secret'),follow('Bob','Mallory')],queries:[query('inbox','Alice'),query('inbox','Bob'),query('feed','Bob'),query('timeline','Mallory')]});
  assert.deepEqual(inboxA.map(x=>x.text),['secret']); assert.deepEqual(inboxB,[]); assert.deepEqual(feed,[]); assert.deepEqual(timeline,[]);
});
test('malformed events rejected before any effects', () => {
  for(const e of [{type:'post',user:'!',text:'bad'},{type:'dm',from:'Alice',to:'Bob',text:''},{type:'follow',user:'Alice',target:3},{type:'delete',user:'Alice'}]) {
    assert.throws(()=>evaluate({events:[post('Alice','valid'),e],queries:[query('timeline','Alice')]}),/invalid-event/);
  }
  assert.throws(()=>evaluate({events:[],queries:[{type:'feed',user:'bad name'}]}),/invalid-query/);
});
test('empty feeds and independent repeated evaluations', () => {
  assert.deepEqual(evaluate({events:[],queries:[query('feed','Nobody')]}),{results:[[]]});
  assert.deepEqual(evaluate({events:[post('Alice','ok')],queries:[query('timeline','Alice')]}).results[0].length,1);
});
