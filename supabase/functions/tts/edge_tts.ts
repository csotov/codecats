// Edge read-aloud client (port of the edge-tts Python package) for the
// Profe voice: Jorge, es-MX.

const CS64_ADJUSTMENT0 = 4076407578n;
const CS64_ADJUSTMENT1 = 186253312n;
const CS64_COEFFICIENTS = [[3895366065n, 3005677776n], [1155409094n, 2296378653n], [1005282748n, 693190712n], [3365689651n, 3005795295n], [2367603217n, 3557143765n], [827258325n, 652566332n], [3911487921n, 1618477510n], [4037392853n, 2192753147n], [101076211n, 4199654362n], [3665427040n, 545047652n], [3201434976n, 1010595059n], [2314848760n, 3536931681n], [905590982n, 3137643201n], [3410617286n, 3311559015n]];
const CS64_FACTOR = 2190031155n;
const SHA256_ADJUSTMENT = 3386640039n;
const SHA256_BLOCK_CONSTANTS = [1116352408n, 1899447441n, 3049323471n, 3921009573n, 961987163n, 1508970993n, 2453635748n, 2870763221n, 3624381080n, 310598401n, 607225278n, 1426881987n, 1925078388n, 2162078206n, 3386640039n, 3248222580n, 3835390401n, 4022224774n, 264347078n, 604807628n, 770255983n, 1249150122n, 1555081692n, 1996064986n, 2554220882n, 2821834349n, 2952996808n, 3210313671n, 3336571891n, 3584528711n, 113926993n, 338241895n, 666307205n, 773529912n, 1294757372n, 1396182291n, 1695183700n, 1986661051n, 2177026350n, 2456956037n, 2730485921n, 2820302411n, 3259730800n, 3345764771n, 3516065817n, 3600352804n, 4094571909n, 275423344n, 430227734n, 506948616n, 659060556n, 883997877n, 958139571n, 1322822218n, 1537002063n, 1747873779n, 1955562222n, 2024104815n, 2227730452n, 2361852424n, 2428436474n, 2756734187n, 3204031479n, 3329325298n];
const SHA256_INITIAL = [1779033703n, 3144134277n, 1013904242n, 2773480762n, 1359893119n, 2600822924n, 528734635n, 1541459225n];
const SHA256_ROUND_CONSTANTS = [1116352408n, 1899447441n, 3049323471n, 3921009573n, 961987163n, 1508970993n, 2453635748n, 2870763221n, 3624381080n, 310598401n, 607225278n, 1426881987n, 1925078388n, 2162078206n, 2614888103n, 3248222580n, 3835390401n, 4022224774n, 264347078n, 604807628n, 770255983n, 1249150122n, 1555081692n, 1996064986n, 2554220882n, 2821834349n, 2952996808n, 3210313671n, 3336571891n, 3584528711n, 113926993n, 338241895n, 666307205n, 773529912n, 1294757372n, 1396182291n, 1695183700n, 1986661051n, 2177026350n, 2456956037n, 2730485921n, 2820302411n, 3259730800n, 3345764771n, 3516065817n, 3600352804n, 4094571909n, 275423344n, 430227734n, 506948616n, 659060556n, 883997877n, 958139571n, 1322822218n, 1537002063n, 1747873779n, 1955562222n, 2024104815n, 2227730452n, 2361852424n, 2428436474n, 2756734187n, 3204031479n, 3329325298n];
const SHA256_SCHEDULE = [3945054110n, 358115615n, 2696978146n, 217723578n, 2787307148n, 3520959633n, 3235718560n, 4192668342n, 4039316851n, 1884868174n, 1904797190n, 15051571n, 3529027680n, 1920361828n];
const SHA256_SIGMA0_ADJUSTMENT = 94112640n;
const SHA256_SIGMA1_ADJUSTMENT = 758464n;
const SHA256_STATE = [4255104674n, 2435071207n, 3192492180n, 3442351626n, 1811967817n, 79508907n, 4272990180n, 66059218n];

const M = 0xFFFFFFFFn;
const TOKEN = "6A5AA1D4EAFF4E9FB37E23D68491D6F4";
const rol16 = (v: bigint) => { v &= M; return ((v << 16n) | (v >> 16n)) & M; };
const sigma0 = (v: bigint) => ((v >> 7n) ^ (v << 25n) ^ (v >> 18n) ^ (v << 14n) ^ (v >> 3n)) & M;
const sigma1 = (v: bigint) => ((v >> 17n) ^ (v << 15n) ^ (v >> 19n) ^ (v << 13n) ^ (v >> 10n)) & M;

function rounds(state: bigint[], w: bigint[], first = 0): bigint[] {
  let [a, b, c, d, e, f, g, h] = state;
  const k = first === 14 ? SHA256_BLOCK_CONSTANTS : SHA256_ROUND_CONSTANTS;
  for (let i = first; i < 64; i++) {
    const re = e * 0x100000001n, ra = a * 0x100000001n;
    const t1 = h + ((re >> 6n) ^ (re >> 11n) ^ (re >> 25n)) + (g ^ (e & (f ^ g))) + k[i] + w[i];
    const t2 = ((ra >> 2n) ^ (ra >> 13n) ^ (ra >> 22n)) + ((a & b) | (c & (a | b)));
    [a, b, c, d, e, f, g, h] = [(t1 + t2) & M, a, b, c, (d + t1) & M, e, f, g];
  }
  return [a, b, c, d, e, f, g, h];
}

function expand(w: bigint[], first = 16) {
  for (let i = first; i < 64; i++) {
    const x = w[i - 2], y = w[i - 15];
    const s1 = (x >> 17n) ^ (x << 15n) ^ (x >> 19n) ^ (x << 13n) ^ (x >> 10n);
    const s0 = (y >> 7n) ^ (y << 25n) ^ (y >> 18n) ^ (y << 14n) ^ (y >> 3n);
    w.push((s1 + w[i - 7] + s0 + w[i - 16]) & M);
  }
}

const be = (b: Uint8Array) => b.reduce((acc, x) => (acc << 8n) | BigInt(x), 0n);

function shaInit(data: Uint8Array): bigint[] {
  const w: bigint[] = [...Array(14).fill(0n), be(data.slice(0, 3)), be(data.slice(3, 7))];
  for (let i = 16; i < 30; i++) {
    let v = SHA256_SCHEDULE[i - 16];
    if (i - 2 >= 14) v += i === 16 ? (sigma1(w[i - 2]) ^ SHA256_SIGMA1_ADJUSTMENT) : sigma1(w[i - 2]);
    if (i - 7 >= 14) v += w[i - 7];
    if (i - 15 >= 14) v += i === 29 ? (sigma0(w[i - 15]) ^ SHA256_SIGMA0_ADJUSTMENT) : sigma0(w[i - 15]);
    w.push(v & M);
  }
  w.push((sigma1(w[28]) + w[23] + sigma0(w[15]) + w[14] + SHA256_ADJUSTMENT - SHA256_ROUND_CONSTANTS[14]) & ((1n << 64n) - 1n) & M);
  expand(w, 31);
  const r = rounds([...SHA256_STATE], w, 14);
  return SHA256_INITIAL.map((x, i) => (x + r[i]) & M);
}

function shaDigest(data: Uint8Array): Uint8Array {
  const length = 57 + data.length;
  const padLen = (((55 - length) % 64) + 64) % 64;
  const rest = data.slice(7);
  const padded = new Uint8Array(rest.length + 1 + padLen + 8);
  padded.set(rest); padded[rest.length] = 0x80;
  new DataView(padded.buffer).setBigUint64(padded.length - 8, BigInt(length * 8));
  let state = shaInit(data.slice(0, 7));
  const dv = new DataView(padded.buffer);
  for (let off = 0; off < padded.length; off += 64) {
    const w: bigint[] = [];
    for (let j = 0; j < 16; j++) w.push(BigInt(dv.getUint32(off + 4 * j)));
    expand(w);
    const r = rounds(state, w);
    state = state.map((x, i) => (x + r[i]) & M);
  }
  const out = new Uint8Array(32), o = new DataView(out.buffer);
  state.forEach((x, i) => o.setUint32(4 * i, Number(x)));
  return out;
}

function wordsLe4Even(data: Uint8Array): bigint[] {
  const n = Math.ceil(data.length / 4) * 4;
  const p = new Uint8Array(n); p.set(data);
  const dv = new DataView(p.buffer);
  const w: bigint[] = [];
  for (let i = 0; i < n; i += 4) w.push(BigInt(dv.getUint32(i, true)));
  if (w.length % 2) w.push(0n);
  return w;
}

function cs64(data: Uint8Array, digest: Uint8Array): [bigint, bigint] {
  const dv = new DataView(digest.buffer);
  const ka = BigInt(dv.getUint32(0, true)) | 1n, kb = BigInt(dv.getUint32(4, true)) | 1n;
  const factors = [(ka * CS64_FACTOR) & M, (kb * CS64_FACTOR) & M];
  const terms = CS64_COEFFICIENTS.map((c, i) => (c[0] * factors[i % 2]) & M);
  const offsets = CS64_COEFFICIENTS.map((c) => c[1]);
  const pre = new Uint8Array(data.length + 1); pre.set(data, 1);
  wordsLe4Even(pre).forEach((word, i) => {
    let term = word * (i % 2 === 0 ? ka : kb);
    let offset = rol16(word) * (i % 2 === 0 ? 0xEF0569FBn : 0xC31713DBn);
    if (i === 0) { term += CS64_ADJUSTMENT0 * factors[0]; offset += CS64_ADJUSTMENT1; }
    terms.push(term & M); offsets.push(offset & M);
  });
  let swapAcc = 0n, swapLast = 0n, state = 0n, acc = 0n;
  for (let i = 0; i < terms.length; i += 2) {
    const x = terms[i], y = terms[i + 1];
    let t = rol16((offsets[i] + x) & M);
    let q = (t * 0x76F50F34n) & M;
    swapAcc += (rol16(q) * 0xC3EFEA97n + q) & M;
    t = rol16((offsets[i + 1] + y) & M);
    q = (t * 0x1881CE3Cn) & M;
    swapLast = (rol16(q) * 0x35BD1EC9n + q) & M;
    swapAcc = (swapAcc + swapLast) & M;
    state = (state * ka + x) & M;
    state = (rol16(state) * 0xCF98B111n) & M;
    state = (rol16(state) * 0x87085B9Fn) & M;
    state = (rol16(state) * 0x12CEB96Dn) & M;
    state = (rol16(state) * 0x257E1D83n) & M;
    acc += state;
    t = (state * kb + y) & M;
    t = (rol16(t) * 0xA27416F5n) & M;
    t = (rol16(t) * 0xD38396FFn) & M;
    state = (rol16((rol16(t) * 0x7C932B89n) & M) * 0xBFA49F69n) & M;
    acc = (acc + state) & M;
  }
  return [swapLast ^ state, swapAcc ^ acc];
}

const hex = (b: Uint8Array) => [...b].map((x) => x.toString(16).padStart(2, "0")).join("").toUpperCase();

/// Sec-MS-GEC v2 token (port of edge-tts drm.generate_sec_ms_gec_v2).
export function secMsGec(unixSeconds = Date.now() / 1000): string {
  let ticks = Math.floor(unixSeconds) + 11644473600;
  ticks -= ticks % 300;
  const s = `${BigInt(ticks) * 10000000n}${TOKEN}`;
  const data = new TextEncoder().encode(s);
  const digest = shaDigest(data);
  const [c0, c1] = cs64(data, digest);
  const c = new Uint8Array(8), dv = new DataView(c.buffer);
  dv.setUint32(0, Number(c0), true); dv.setUint32(4, Number(c1), true);
  return `${hex(c)}-${hex(digest)}`;
}

const VOICE = "es-MX-JorgeNeural";
const CHROME = "143.0.3650.75";
const MAJOR = CHROME.split(".")[0];
const WSS =
  "wss://speech.platform.bing.com/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4";
const UA =
  `Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/${MAJOR}.0.0.0 Safari/537.36 Edg/${MAJOR}.0.0.0`;

const id = () => crypto.randomUUID().replaceAll("-", "");
const muid = () => id().toUpperCase();
const date = () => new Date().toUTCString().replace("GMT", "GMT+0000 (Coordinated Universal Time)");
const esc = (s: string) =>
  s.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");

// Deno's WebSocket negotiates HTTP/2 with this host and fails, so this
// is a tiny HTTP/1.1 WebSocket client over TLS.
class Ws {
  private buf = new Uint8Array(0);
  private constructor(private conn: Deno.TlsConn) {}

  static async open(host: string, path: string, headers: Record<string, string>) {
    const conn = await Deno.connectTls({ hostname: host, port: 443, alpnProtocols: ["http/1.1"] });
    const ws = new Ws(conn);
    const key = btoa(String.fromCharCode(...crypto.getRandomValues(new Uint8Array(16))));
    const lines = [
      `GET ${path} HTTP/1.1`, `Host: ${host}`, "Upgrade: websocket", "Connection: Upgrade",
      `Sec-WebSocket-Key: ${key}`, "Sec-WebSocket-Version: 13",
      ...Object.entries(headers).map(([k, v]) => `${k}: ${v}`),
    ];
    await ws.write(new TextEncoder().encode(lines.join("\r\n") + "\r\n\r\n"));
    let end = -1;
    while ((end = ws.find()) < 0) await ws.fill();
    const head = new TextDecoder().decode(ws.buf.slice(0, end));
    ws.buf = ws.buf.slice(end + 4);
    if (!head.startsWith("HTTP/1.1 101")) throw new Error(head.split("\r\n")[0]);
    return ws;
  }

  private find() {
    for (let i = 0; i + 3 < this.buf.length; i++) {
      if (this.buf[i] === 13 && this.buf[i + 1] === 10 && this.buf[i + 2] === 13 && this.buf[i + 3] === 10) return i;
    }
    return -1;
  }

  private async fill() {
    const chunk = new Uint8Array(65536);
    const n = await this.conn.read(chunk);
    if (n === null) throw new Error("closed");
    const b = new Uint8Array(this.buf.length + n);
    b.set(this.buf); b.set(chunk.subarray(0, n), this.buf.length);
    this.buf = b;
  }

  private async need(n: number) { while (this.buf.length < n) await this.fill(); }

  private async write(b: Uint8Array) {
    for (let o = 0; o < b.length;) o += await this.conn.write(b.subarray(o));
  }

  async sendText(s: string) {
    const p = new TextEncoder().encode(s);
    const ext = p.length < 126 ? 0 : p.length < 65536 ? 2 : 8;
    const f = new Uint8Array(2 + ext + 4 + p.length);
    f[0] = 0x81;
    const dv = new DataView(f.buffer);
    if (ext === 0) f[1] = 0x80 | p.length;
    else if (ext === 2) { f[1] = 0x80 | 126; dv.setUint16(2, p.length); }
    else { f[1] = 0x80 | 127; dv.setBigUint64(2, BigInt(p.length)); }
    const mask = crypto.getRandomValues(new Uint8Array(4));
    f.set(mask, 2 + ext);
    for (let i = 0; i < p.length; i++) f[6 + ext + i] = p[i] ^ mask[i & 3];
    await this.write(f);
  }

  /// Next whole message: [opcode, payload].
  async recv(): Promise<[number, Uint8Array]> {
    let op = 0;
    const parts: Uint8Array[] = [];
    for (;;) {
      await this.need(2);
      const fin = (this.buf[0] & 0x80) !== 0, code = this.buf[0] & 0x0f;
      let len = this.buf[1] & 0x7f, at = 2;
      if (len === 126) { await this.need(4); len = (this.buf[2] << 8) | this.buf[3]; at = 4; }
      else if (len === 127) { await this.need(10); len = Number(new DataView(this.buf.buffer, this.buf.byteOffset).getBigUint64(2)); at = 10; }
      await this.need(at + len);
      const payload = this.buf.slice(at, at + len);
      this.buf = this.buf.slice(at + len);
      if (code >= 8) { if (code === 8) return [8, payload]; continue; }
      if (code !== 0) op = code;
      parts.push(payload);
      if (fin) break;
    }
    const n = parts.reduce((a, p) => a + p.length, 0), out = new Uint8Array(n);
    let o = 0;
    for (const p of parts) { out.set(p, o); o += p.length; }
    return [op, out];
  }

  close() { try { this.conn.close(); } catch (_) { /* already closed */ } }
}

/// Speaks [text] with Jorge (es-MX) through the Edge read-aloud service; mp3 bytes.
export async function synth(text: string): Promise<Uint8Array> {
  const host = "speech.platform.bing.com";
  const path = `/consumer/speech/synthesize/readaloud/edge/v1?TrustedClientToken=6A5AA1D4EAFF4E9FB37E23D68491D6F4&ConnectionId=${id()}&Sec-MS-GEC=${secMsGec()}&Sec-MS-GEC-Version=2-${CHROME}`;
  const ws = await Ws.open(host, path, {
    Pragma: "no-cache",
    "Cache-Control": "no-cache",
    Origin: "chrome-extension://jdiccldimpdaibmpdkjnbmckianbfold",
    "User-Agent": UA,
    "Accept-Language": "en-US,en;q=0.9",
    Cookie: `muid=${muid()};`,
  });
  const timer = setTimeout(() => ws.close(), 20000);
  try {
    await ws.sendText(
      `X-Timestamp:${date()}\r\nContent-Type:application/json; charset=utf-8\r\nPath:speech.config\r\n\r\n` +
        '{"context":{"synthesis":{"audio":{"metadataoptions":{"sentenceBoundaryEnabled":"false","wordBoundaryEnabled":"false"},"outputFormat":"audio-24khz-48kbitrate-mono-mp3"}}}}\r\n',
    );
    await ws.sendText(
      `X-RequestId:${id()}\r\nContent-Type:application/ssml+xml\r\nX-Timestamp:${date()}Z\r\nPath:ssml\r\n\r\n` +
        `<speak version='1.0' xmlns='http://www.w3.org/2001/10/synthesis' xml:lang='en-US'><voice name='${VOICE}'><prosody pitch='+0Hz' rate='+0%' volume='+0%'>${esc(text)}</prosody></voice></speak>`,
    );
    const parts: Uint8Array[] = [];
    for (;;) {
      const [op, data] = await ws.recv();
      if (op === 8) break;
      if (op === 1) {
        if (new TextDecoder().decode(data).includes("Path:turn.end")) break;
        continue;
      }
      const h = (data[0] << 8) | data[1];
      if (data.length > h + 2) parts.push(data.slice(h + 2));
    }
    const n = parts.reduce((a, p) => a + p.length, 0);
    if (!n) throw new Error("no audio");
    const out = new Uint8Array(n);
    let o = 0;
    for (const p of parts) { out.set(p, o); o += p.length; }
    return out;
  } finally {
    clearTimeout(timer);
    ws.close();
  }
}
