"""Pre-record the Profe's fixed Spanish lines with Microsoft's es-MX Jorge voice.

Writes web/voz/<n>.mp3 plus web/voz/index.json ({normalized text: file}).
Extra lines (e.g. exported `tts_miss` events) can be passed as a text file,
one per line. Run: python3 tool/voz_jorge.py [extra.txt]
"""
import asyncio, glob, json, os, re, sys
import edge_tts

VOICE = 'es-MX-JorgeNeural'
OUT = 'web/voz'
MIN = 80  # kVoiceMinChars
EMOJI = re.compile('[\U0001F000-\U0001FAFF\u2600-\u27BF\uFE0F\u200D]')
LIT = r"""(?:'(?:[^'\\\n]|\\.)*'|"(?:[^"\\\n]|\\.)*")"""
SEQ = re.compile(r'(?<![r\w])' + LIT + r'(?:\s*' + LIT + r')*')
ESC = {'n': '\n', 't': '\t', '\\': '\\', "'": "'", '"': '"', '$': '$'}


def norm(t):
    t = EMOJI.sub('', t.replace('`', ''))
    return re.sub(r'\s+', ' ', t).strip()


def unescape(s):
    return re.sub(r'\\(.)', lambda m: ESC.get(m.group(1), m.group(1)), s)


def lines():
    out = set()
    for f in glob.glob('lib/**/*.dart', recursive=True):
        for m in SEQ.finditer(open(f, encoding='utf-8').read()):
            parts = re.findall(LIT, m.group(0))
            raw = ''.join(p[1:-1] for p in parts)
            if re.search(r'(?<!\\)\$', raw):
                continue
            t = norm(unescape(raw))
            if len(t) >= MIN and re.search(r'[áéíóúñ¿¡]|\b(el|la|que|tu|un)\b', t):
                out.add(t)
    for extra in sys.argv[1:]:
        out.update(norm(x) for x in open(extra, encoding='utf-8') if norm(x))
    return sorted(out)


async def main():
    os.makedirs(OUT, exist_ok=True)
    path = f'{OUT}/index.json'
    index = json.load(open(path)) if os.path.exists(path) else {}
    todo = [t for t in lines() if t not in index]
    n = max([int(v.split('.')[0]) for v in index.values()] + [0])
    sem = asyncio.Semaphore(6)

    async def one(t, f):
        async with sem:
            for _ in range(4):
                try:
                    await edge_tts.Communicate(t, VOICE).save(f'{OUT}/{f}')
                    index[t] = f
                    return
                except Exception as e:
                    err = e
                    await asyncio.sleep(3)
            print('FAIL', err, t[:60])

    jobs = []
    for t in todo:
        n += 1
        jobs.append(one(t, f'{n}.mp3'))
    await asyncio.gather(*jobs)
    json.dump(dict(sorted(index.items())), open(path, 'w'), ensure_ascii=False, indent=0)
    print(len(todo), 'new;', len(index), 'total')


asyncio.run(main())
