// MIT — original clean-room implementation for KATA-000024.
export type Event =
  | { type: 'post'; user: string; text: string }
  | { type: 'follow'; user: string; target: string }
  | { type: 'dm'; from: string; to: string; text: string };
export type Query =
  | { type: 'timeline'; user: string }
  | { type: 'feed'; user: string }
  | { type: 'mentions'; user: string }
  | { type: 'inbox'; user: string };
export type Post = { id: number; author: string; text: string; mentions: string[]; links: string[] };
export type Message = { id: number; from: string; to: string; text: string };
export type Response = { results: Array<Post[] | Message[]> };
const validUser = (s: unknown): s is string => typeof s === 'string' && /^[A-Za-z][A-Za-z0-9_]{0,31}$/.test(s);
const validText = (s: unknown): s is string => typeof s === 'string' && s.length > 0 && s.length <= 2000 && !s.includes('\u0000');
const own = (x: object, k: string): boolean => Object.prototype.hasOwnProperty.call(x, k);

function mentions(text: string): string[] {
  const out: string[] = [];
  const seen = new Set<string>();
  for (const match of text.matchAll(/(?<![A-Za-z0-9_])@([A-Za-z][A-Za-z0-9_]{0,31})(?![A-Za-z0-9_])/g)) {
    if (!seen.has(match[1])) { out.push(match[1]); seen.add(match[1]); }
  }
  return out;
}
function links(text: string): string[] {
  const out: string[] = [];
  for (const match of text.matchAll(/https?:\/\/[^\s<>"']+/g)) {
    const url = match[0].replace(/[.,!?:;)]+$/g, '');
    if (/^https?:\/\/[A-Za-z0-9]/.test(url)) out.push(url);
  }
  return out;
}
function validate(event: unknown, query = false): void {
  if (!event || typeof event !== 'object' || Array.isArray(event)) throw Error('invalid-event');
  const e = event as Record<string, unknown>;
  if (query) {
    if (!['timeline','feed','mentions','inbox'].includes(String(e.type)) || !validUser(e.user)) throw Error('invalid-query');
    return;
  }
  if (e.type === 'post' && validUser(e.user) && validText(e.text)) return;
  if (e.type === 'follow' && validUser(e.user) && validUser(e.target)) return;
  if (e.type === 'dm' && validUser(e.from) && validUser(e.to) && validText(e.text)) return;
  throw Error('invalid-event');
}
export function evaluate(input: unknown): Response {
  if (!input || typeof input !== 'object' || Array.isArray(input)) throw Error('invalid-request');
  const req = input as Record<string, unknown>;
  if (!Array.isArray(req.events) || !Array.isArray(req.queries) || req.events.length > 2000 || req.queries.length > 2000) throw Error('invalid-request');
  for (const event of req.events) validate(event);
  for (const query of req.queries) validate(query, true);
  const timelines = new Map<string, Post[]>();
  const inboxes = new Map<string, Message[]>();
  const followers = new Map<string, Set<string>>();
  const tagged = new Map<string, Post[]>();
  req.events.forEach((item, i) => {
    const e = item as Event;
    if (e.type === 'post') {
      const post: Post = { id: i + 1, author: e.user, text: e.text, mentions: mentions(e.text), links: links(e.text) };
      timelines.set(e.user, [post, ...(timelines.get(e.user) ?? [])]);
      for (const who of post.mentions) tagged.set(who, [post, ...(tagged.get(who) ?? [])]);
    } else if (e.type === 'follow') {
      if (e.user !== e.target) {
        const set = followers.get(e.user) ?? new Set<string>();
        set.add(e.target);
        followers.set(e.user, set);
      }
    } else {
      const dm: Message = { id: i + 1, from: e.from, to: e.to, text: e.text };
      inboxes.set(e.to, [dm, ...(inboxes.get(e.to) ?? [])]);
    }
  });
  const results = (req.queries as Query[]).map(q => {
    if (q.type === 'timeline') return timelines.get(q.user) ?? [];
    if (q.type === 'mentions') return tagged.get(q.user) ?? [];
    if (q.type === 'inbox') return inboxes.get(q.user) ?? [];
    const allowed = followers.get(q.user) ?? new Set<string>();
    return [...allowed].flatMap(u => timelines.get(u) ?? []).sort((a,b) => b.id - a.id);
  });
  return { results };
}
