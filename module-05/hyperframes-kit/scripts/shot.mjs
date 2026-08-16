#!/usr/bin/env node
// ══════════════════════════════════════════════════════════════
// shot.mjs — скриншот веб-страницы для вставки в ролик.
//
// Агент добывает скрины интерфейсов/сайтов сам (правило в CLAUDE.md,
// раздел «Скриншоты и видеоклипы»): публичные страницы — этим скриптом,
// страницы за логином — расширением Claude in Chrome.
//
//   node scripts/shot.mjs <url> inbox/screenshots/<якорь>.png [--full] [--w 1440] [--h 900] [--wait 2500]
//
//   <якорь>.png — имя-якорь для привязки к транскрипту (n8n-workflow.png)
//   --full      — вся страница целиком, а не только вьюпорт
//   --w/--h     — вьюпорт (по умолчанию 1440×900)
//   --wait      — доп. пауза после загрузки, мс (шрифты/анимации)
//
// Рендерится в retina (×2): PNG 2880×1800 — в кадре 1080 хрустит.
// Puppeteer стоит локально в проекте (ставится на шаге установки: npm i puppeteer).
// ══════════════════════════════════════════════════════════════
import { createRequire } from 'module';
import { existsSync, mkdirSync } from 'fs';
import { dirname, resolve } from 'path';

function loadPuppeteer() {
  try { return createRequire(resolve('package.json'))('puppeteer'); }
  catch {
    console.error('✗ Puppeteer не найден в проекте. Поставить: npm i puppeteer');
    process.exit(1);
  }
}

const args = process.argv.slice(2);
const url = args[0];
const out = args[1];
if (!url || !out) {
  console.error('Использование: node scripts/shot.mjs <url> inbox/screenshots/<якорь>.png [--full] [--w 1440] [--h 900] [--wait 2500]');
  process.exit(1);
}
const opt = (name, dflt) => {
  const i = args.indexOf(name);
  return i > -1 && args[i + 1] ? Number(args[i + 1]) : dflt;
};
const fullPage = args.includes('--full');
const width  = opt('--w', 1440);
const height = opt('--h', 900);
const wait   = opt('--wait', 2500);

const puppeteer = loadPuppeteer();
const browser = await puppeteer.launch({ headless: 'new' });
try {
  const page = await browser.newPage();
  await page.setViewport({ width, height, deviceScaleFactor: 2 });
  await page.goto(url, { waitUntil: 'networkidle2', timeout: 60000 });
  await new Promise(r => setTimeout(r, wait));

  // Кукис-баннеры: жмём первую кнопку согласия/отказа, какую найдём.
  // Проверено на n8n.io — без этого баннер ложится ровно на центр кадра.
  const dismissed = await page.evaluate(() => {
    const rx = /^(accept( all)?|allow( all)?|agree|i agree|got it|ok(ay)?|decline( all)?|reject( all)?|принять|соглас(ен|иться)|разрешить|понятно)/i;
    const els = [...document.querySelectorAll('button, a, [role="button"]')];
    const hit = els.find(el => rx.test((el.textContent || '').trim()) && el.offsetParent !== null);
    if (hit) { hit.click(); return (hit.textContent || '').trim().slice(0, 40); }
    return null;
  });
  if (dismissed) {
    console.log(`  · закрыл баннер: «${dismissed}»`);
    await new Promise(r => setTimeout(r, 800));
  }
  mkdirSync(dirname(out), { recursive: true });
  await page.screenshot({ path: out, fullPage });
  console.log(`✓ ${out}  (${url}, ${width}×${height}${fullPage ? ', full' : ''}, ×2)`);
} finally {
  await browser.close();
}
if (!existsSync(out)) {
  console.error('✗ Файл не создан');
  process.exit(1);
}
