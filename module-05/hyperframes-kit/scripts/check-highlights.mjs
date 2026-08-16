#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════
// check-highlights.mjs — проверка рамок-подсветок ДО превью и рендера.
//
//   node scripts/check-highlights.mjs queue/video-104/composition.html
//   node scripts/check-highlights.mjs 104 [dark|light]
//
// Зачем. Рамка (.shot-hl) живёт внутри зумящегося контейнера и должна
// приезжать ровно на объект — счётчик звёзд, кнопку, строку. Это место
// системно ломалось: правки зума меняют кадр, рамка остаётся на старых
// процентах и «съезжает» на пустой фон. Ловилось только глазами на
// QA-кадрах, то есть уже ПОСЛЕ рендера — и правка стоила перерендера.
//
// Что делает скрипт:
//   1. Грузит композицию в headless-Chrome, сам управляет видимостью
//      клипов и перематывает GSAP-таймлайн (рантайм движка не нужен —
//      важна только геометрия на конкретной секунде).
//   2. Для каждой рамки находит окно, где она видима (opacity ≥ 0.9),
//      и берёт момент, когда зум уже доехал (последняя треть окна).
//   3. Считает в этот момент:
//      • clipped — вылезает ли рамка за пределы кадра .shot-frame;
//      • ink — доля «непустых» пикселей под рамкой. Рамка на тексте или
//        кнопке даёт высокий ink; рамка, уехавшая на однотонный фон, —
//        близкий к нулю. Это и есть автолов «съехала на пустое место»;
//      • hold — сколько времени рамка видна (правило ≥1с на разглядывание).
//   4. Кладёт кроп вокруг каждой рамки в renders/hl-check/ — финальная
//      проверка всё равно глазами, но смотреть надо 3 картинки, а не 24.
//
// Коды выхода: 0 — всё чисто, 1 — есть FAIL (рамку чинить до превью).
// ══════════════════════════════════════════════════════════════
import { createRequire } from 'module';
import { existsSync, mkdirSync, rmSync, copyFileSync, unlinkSync } from 'fs';
import { resolve } from 'path';

function loadPuppeteer() {
  try { return createRequire(resolve('package.json'))('puppeteer'); }
  catch {
    console.error('✗ Puppeteer не найден в проекте. Поставить: npm i puppeteer');
    process.exit(1);
  }
}

const HOLD_MIN = 1.0;   // сек — минимум на разглядывание детали
const INK_MIN  = 1.5;   // % непустых пикселей под рамкой

const arg = process.argv[2];
const theme = (process.argv[3] || 'dark').toLowerCase();
if (!arg) {
  console.error('Использование: node scripts/check-highlights.mjs <композиция.html | NN> [dark|light]');
  process.exit(1);
}
const compPath = /^\d+$/.test(arg)
  ? `queue/video-${arg}/composition${theme === 'light' ? '-light' : ''}.html`
  : arg;
if (!existsSync(compPath)) {
  console.error(`✗ Нет файла: ${compPath}`);
  process.exit(1);
}

const OUT = 'renders/hl-check';
rmSync(OUT, { recursive: true, force: true });
mkdirSync(OUT, { recursive: true });

// shared/*.css и assets/* композиция адресует относительно КОРНЯ проекта
// (в рендере её туда кладёт queue-render.sh). Грузим копию из корня, иначе
// helpers.js не найдётся и таймлайн не построится.
const TMP = '.hl-check.tmp.html';
copyFileSync(compPath, TMP);
const cleanupTmp = () => { try { unlinkSync(TMP); } catch {} };
process.on('exit', cleanupTmp);

const puppeteer = loadPuppeteer();
const browser = await puppeteer.launch({ headless: 'new', args: ['--allow-file-access-from-files'] });
const page = await browser.newPage();
await page.setViewport({ width: 1080, height: 1920, deviceScaleFactor: 1 });
page.on('pageerror', e => console.error('  [page error]', e.message));

await page.goto('file://' + resolve(TMP), { waitUntil: 'networkidle0' });

// Таймлайн строится синхронно при загрузке. Локальные шрифты/аудио по file://
// не грузятся (пути от корня) — на геометрию рамок это не влияет, ждать их не надо.
// Опрашиваем через evaluate, а НЕ waitForFunction: тот исполняется в изолированном
// мире, где глобалы страницы (window.__timelines) не видны.
let ready = false;
for (let i = 0; i < 50 && !ready; i++) {
  ready = await page.evaluate(() => !!(window.__timelines && window.__timelines.root));
  if (!ready) await new Promise(r => setTimeout(r, 200));
}
if (!ready) {
  const d = await page.evaluate(() => ({ gsap: typeof window.gsap, helpers: typeof window.createHFHelpers,
                                          tls: Object.keys(window.__timelines || {}) }));
  console.error(`✗ Таймлайн не зарегистрировался: ${JSON.stringify(d)}`);
  await browser.close();
  process.exit(1);
}

// Перемотка: сами управляем видимостью клипов (рантайма движка тут нет).
await page.evaluate(() => {
  window.__seek = (t) => {
    document.querySelectorAll('.clip[data-start]').forEach(el => {
      const s = parseFloat(el.dataset.start);
      const d = parseFloat(el.dataset.duration || '0');
      el.style.visibility = (t >= s && t < s + d) ? 'visible' : 'hidden';
    });
    const tl = window.__timelines.root;
    tl.pause();
    tl.time(t, false);
  };
});

const hls = await page.evaluate(() => {
  return [...document.querySelectorAll('[class*="shot-hl"]')].map(el => {
    const scene = el.closest('.clip[data-start]');
    return {
      id: el.id || '(без id)',
      sceneId: scene ? scene.id : null,
      start: scene ? parseFloat(scene.dataset.start) : 0,
      dur: scene ? parseFloat(scene.dataset.duration) : 0,
    };
  });
});

if (!hls.length) {
  console.log(`→ ${compPath}: рамок-подсветок (.shot-hl) нет — проверять нечего.`);
  await browser.close();
  process.exit(0);
}

console.log(`\n◆ Проверка рамок: ${compPath}  (найдено ${hls.length})\n`);

let failed = 0;
for (const hl of hls) {
  // 1) окно видимости рамки
  const step = 0.05;
  const times = [];
  for (let t = hl.start; t < hl.start + hl.dur; t += step) times.push(+t.toFixed(2));
  const vis = [];
  for (const t of times) {
    const o = await page.evaluate((t, id) => {
      window.__seek(t);
      const el = document.getElementById(id);
      if (!el) return 0;
      return parseFloat(getComputedStyle(el).opacity) || 0;
    }, t, hl.id);
    if (o >= 0.9) vis.push(t);
  }

  if (!vis.length) {
    console.log(`  ✗ FAIL  ${hl.id} — рамка ни разу не видна (opacity < 0.9) внутри своей сцены.`);
    failed++;
    continue;
  }
  const holdFrom = vis[0], holdTo = vis[vis.length - 1];
  const hold = +(holdTo - holdFrom + step).toFixed(2);
  // момент замера: зум уже доехал — берём ближе к концу окна
  const at = +(holdFrom + (holdTo - holdFrom) * 0.8).toFixed(2);

  const m = await page.evaluate((t, id) => {
    window.__seek(t);
    const el = document.getElementById(id);
    const frame = el.closest('[class*="shot-frame"]');
    const img = el.parentElement.querySelector('img');
    const r = el.getBoundingClientRect();
    const fr = frame.getBoundingClientRect();
    const ir = img.getBoundingClientRect();

    const clipped = {
      left: Math.max(0, fr.left - r.left),
      right: Math.max(0, r.right - fr.right),
      top: Math.max(0, fr.top - r.top),
      bottom: Math.max(0, r.bottom - fr.bottom),
    };
    const maxClip = Math.max(clipped.left, clipped.right, clipped.top, clipped.bottom);

    // «Ink» под рамкой: доля пикселей, заметно отличающихся от медианы фона.
    const sx = (r.left - ir.left) / ir.width * img.naturalWidth;
    const sy = (r.top - ir.top) / ir.height * img.naturalHeight;
    const sw = r.width / ir.width * img.naturalWidth;
    const sh = r.height / ir.height * img.naturalHeight;
    let ink = null;
    if (sw > 2 && sh > 2 && sx >= 0 && sy >= 0 && sx + sw <= img.naturalWidth && sy + sh <= img.naturalHeight) {
      const c = document.createElement('canvas');
      c.width = Math.round(sw); c.height = Math.round(sh);
      const ctx = c.getContext('2d', { willReadFrequently: true });
      ctx.drawImage(img, sx, sy, sw, sh, 0, 0, c.width, c.height);
      const d = ctx.getImageData(0, 0, c.width, c.height).data;
      const lum = [];
      for (let i = 0; i < d.length; i += 4) lum.push(0.2126*d[i] + 0.7152*d[i+1] + 0.0722*d[i+2]);
      const sorted = [...lum].sort((a, b) => a - b);
      const med = sorted[sorted.length >> 1];
      const off = lum.filter(v => Math.abs(v - med) > 22).length;
      ink = +(off / lum.length * 100).toFixed(1);
    }
    return { rect: { x: r.left, y: r.top, w: r.width, h: r.height }, maxClip: +maxClip.toFixed(1), ink };
  }, at, hl.id);

  // 2) кроп вокруг рамки — для проверки глазами
  const pad = 70;
  const clip = {
    x: Math.max(0, Math.round(m.rect.x - pad)),
    y: Math.max(0, Math.round(m.rect.y - pad)),
    width: Math.min(1080, Math.round(m.rect.w + pad * 2)),
    height: Math.min(1920, Math.round(m.rect.h + pad * 2)),
  };
  const shot = `${OUT}/${hl.id}-${at}s.png`;
  await page.evaluate(t => window.__seek(t), at);
  await page.screenshot({ path: shot, clip });

  const probs = [];
  if (m.maxClip > 2) probs.push(`вылезает за кадр на ${m.maxClip}px`);
  if (m.ink === null) probs.push('рамка вне картинки (нечего подсвечивать)');
  else if (m.ink < INK_MIN) probs.push(`под рамкой пусто (ink ${m.ink}% < ${INK_MIN}%)`);
  if (hold < HOLD_MIN) probs.push(`видна всего ${hold}с (нужно ≥${HOLD_MIN}с)`);

  const tag = probs.length ? '✗ FAIL' : '✓ ok  ';
  if (probs.length) failed++;
  console.log(`  ${tag} ${hl.id} @${at}s · hold ${hold}с · ink ${m.ink === null ? '—' : m.ink + '%'} · clip ${m.maxClip}px`);
  if (probs.length) console.log(`         ${probs.join('; ')}`);
  console.log(`         кроп: ${shot}`);
}

await browser.close();
console.log(`\n${failed ? `✗ Проблемных рамок: ${failed} — чинить ДО превью.` : '✓ Все рамки на месте.'}`);
console.log(`  Кропы посмотреть глазами: ${OUT}/\n`);
process.exit(failed ? 1 : 0);
