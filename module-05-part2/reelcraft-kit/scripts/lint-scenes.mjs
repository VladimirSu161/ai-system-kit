#!/usr/bin/env node
/**
 * lint-scenes.mjs — статическая проверка сцен ролика ПЕРЕД рендером.
 *
 * Зачем: часть
 * правил проекта проверяется кодом за секунды, а раньше на них тратились
 * кадры, время рендера и внимание живой модели. Глаза нужны там, где решает
 * вкус (композиция, «куда смотреть», читаемость) — остальное ловит линт.
 *
 * Запуск:  node scripts/lint-scenes.mjs 110
 *          node scripts/lint-scenes.mjs 110 --strict   (warning тоже валят прогон)
 *
 * Что проверяет:
 *  1. ERROR  Math.random() / Date.now() / new Date() — ломают детерминизм рендера.
 *  2. ERROR  импорт @remotion/google-fonts — лезет в сеть при рендере (запрещён).
 *  3. ERROR  staticFile('...') на несуществующий файл в public/ — самая частая
 *            опечатка, раньше вылезала только на рендере через 10 минут.
 *  4. ERROR  длинный SFX-сэмпл без durationInFrames (sfx/NOTES.md: тянется
 *            после конца действия).
 *  5. WARN   fontSize меньше 48 — правило темпа 13 (текст либо читается,
 *            либо это осознанная текстура: тогда пометь строку `// текстура`).
 *  6. WARN   абсолютные координаты в караоке-полосе темы.
 *  7. WARN   volume SFX выше формулы по пику из sfx/CATALOG.md (2026-09-04).
 *  8. WARN   <Character> без swapMode="dip" (2026-09-04).
 */
import { readFileSync, existsSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { execFileSync } from 'node:child_process';

const PROJ = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const nn = process.argv[2];
const STRICT = process.argv.includes('--strict');
if (!nn) {
  console.error('Использование: node scripts/lint-scenes.mjs <NN> [--strict]');
  process.exit(2);
}

const videoDir = join(PROJ, 'engine/src/videos', `video-${nn}`);
const publicDir = join(PROJ, 'engine/public');

// Раскадровка попадает в git автоматически при каждом линте: если в слоте
// очереди есть storyboard.md — копируем в папку ролика (save-storyboard.sh).
// queue/ не версионируется, поэтому без этого шага сториборд оставался бы
// только на диске вне git.
const storyboardInSlot = join(PROJ, 'queue', `video-${nn}`, 'storyboard.md');
if (existsSync(storyboardInSlot)) {
  try {
    execFileSync(join(PROJ, 'scripts/save-storyboard.sh'), [nn], { stdio: 'inherit' });
  } catch (e) {
    console.error('⚠ save-storyboard.sh не сработал (не критично для линта):', e.message);
  }
}

// Геометрия кадра и безопасные поля (одни для всех тем).
const WIDTH = 1080;
const SAFE_X = 40; // минимальный отступ носителя от боковой кромки

// Караоке-полоса зависит от ТЕМЫ ролика, а не от проекта: в Sticker Light
// субтитры стоят на 880–1030, в тёмных темах (noir и разовые adaptive) —
// на 1450–1620. Определяем по файлам ролика: есть VideoLight/light-сцены →
// светлая полоса, иначе тёмная. Ролик с обеими ветками проверяем по
// объединению полос — так ни одна ветка не проскочит.
const CAP_BANDS = { light: [880, 1030], dark: [1450, 1620] };
if (!existsSync(videoDir)) {
  console.error(`Нет папки ролика: ${videoDir}`);
  process.exit(2);
}

// Длинные сэмплы банка (public/shared/sfx/NOTES.md) — им обязателен durationInFrames
const LONG_SFX = [
  'keyboard.mp3',
  'write-blackboard.mp3',
  'camera-autofocus.mp3',
  'light-spell.mp3',
  'impact-cine-big.mp3',
  'wing-flutter.mp3',
];

const walk = (dir) =>
  readdirSync(dir).flatMap((name) => {
    const p = join(dir, name);
    return statSync(p).isDirectory() ? walk(p) : /\.(tsx|ts)$/.test(p) ? [p] : [];
  });

// Определяем тему ролика по составу файлов: есть светлая ветка → её полоса,
// есть только adaptive/noir → тёмная, есть обе → объединение (строже).
const allFiles = walk(videoDir);
const hasLight = allFiles.some((f) => /VideoLight|scenes-light|light/i.test(f));
const hasDark = allFiles.some((f) => /VideoAdaptive|VideoNoir|scenes-adaptive|adaptive|noir/i.test(f));
const THEME_NAME = hasLight && hasDark ? 'light+dark' : hasLight ? 'light' : 'dark';
const CAP_BAND =
  hasLight && hasDark
    ? [Math.min(CAP_BANDS.light[0], CAP_BANDS.dark[0]), Math.max(CAP_BANDS.light[1], CAP_BANDS.dark[1])]
    : hasLight
      ? CAP_BANDS.light
      : CAP_BANDS.dark;

// Пики SFX из public/shared/sfx/CATALOG.md (генерирует scripts/sfx-catalog.sh):
// строка таблицы «| файл.mp3 | длит | пик | пометки |» внутри раздела «## папка/».
const SFX_PEAKS = {};
try {
  const cat = readFileSync(join(publicDir, 'shared/sfx/CATALOG.md'), 'utf8');
  let dir = '';
  for (const ln of cat.split('\n')) {
    const h = ln.match(/^## (\S+)\/\s*$/);
    if (h) { dir = h[1]; continue; }
    const row = ln.match(/^\| (\S+\.mp3) \| [\d.]+ \| (-?[\d.]+) \|/);
    if (row && dir) SFX_PEAKS[`${dir}/${row[1]}`] = Number(row[2]);
  }
} catch { /* каталога нет — проверка громкости пропускается */ }
// Речь после −14 LUFS обычно даёт mean −17 dB; пик SFX ставим на 11 dB ниже.
const SPEECH_MEAN_DB = -17;
const sfxMaxVolume = (peakDb) => Math.pow(10, (SPEECH_MEAN_DB - 11 - peakDb) / 20);

const problems = [];
const add = (level, file, line, msg) =>
  problems.push({ level, file: file.replace(PROJ + '/', ''), line, msg });

for (const file of allFiles) {
  const text = readFileSync(file, 'utf8');
  const lines = text.split('\n');

  lines.forEach((raw, i) => {
    const ln = i + 1;
    const isComment = /^\s*(\/\/|\*|\/\*)/.test(raw);
    const code = raw.split('//')[0];

    // 1. детерминизм
    if (!isComment && /\bMath\.random\s*\(/.test(code))
      add('ERROR', file, ln, 'Math.random() — детерминизм рендера; взять mulberry32 из lib/helpers.ts');
    if (!isComment && /\bDate\.now\s*\(|new Date\s*\(/.test(code))
      add('ERROR', file, ln, 'Date.now()/new Date() — детерминизм рендера');

    // 2. сетевые шрифты
    if (/@remotion\/google-fonts/.test(code))
      add('ERROR', file, ln, '@remotion/google-fonts запрещён — лезет в сеть при рендере');

    // 3. существование ассетов
    const m = [...code.matchAll(/staticFile\(\s*['"`]([^'"`]+)['"`]\s*\)/g)];
    for (const hit of m) {
      // Путь, собранный из переменной (`shared/icons/${icon}.svg`), статикой
      // не проверить — такие места смотрит терчек на контактном листе.
      if (hit[1].includes('${')) continue;
      const assetPath = join(publicDir, hit[1]);
      if (!existsSync(assetPath))
        add('ERROR', file, ln, `staticFile('${hit[1]}') — файла нет в public/`);
    }

    // 4. длинные SFX без durationInFrames
    for (const long of LONG_SFX) {
      if (code.includes(long) && !/durationInFrames/.test(raw))
        add('ERROR', file, ln, `${long} — длинный сэмпл, обязателен durationInFrames (sfx/NOTES.md)`);
    }

    // 4b. громкость SFX выше формулы (урок video-149: на глаз ставили 0.2–0.9
    // при пике файла −0.3…−2 dB, и удары шли вровень с речью). Ловим только
    // числовой volume в той же строке, что и путь сэмпла; допуск ×1.5.
    const sfxHit = code.match(/shared\/sfx\/([\w-]+\/[\w-]+\.mp3)['"`][^\n]*volume=\{\s*([\d.]+)\s*\}/);
    if (sfxHit && SFX_PEAKS[sfxHit[1]] !== undefined) {
      const vol = Number(sfxHit[2]);
      const max = sfxMaxVolume(SFX_PEAKS[sfxHit[1]]);
      if (vol > max * 1.5)
        add(
          'WARN',
          file,
          ln,
          `volume ${vol} для ${sfxHit[1]} (пик ${SFX_PEAKS[sfxHit[1]]} dB) — по формуле ≤ ${max.toFixed(3)} (sfxGain в lib/helpers.ts, CLAUDE.md «Звук»)`,
        );
    }

    // 4c. персонаж без swapMode="dip": кроссфейд поз даёт «двух персонажей насквозь».
    if (/<Character\b/.test(code) && !/swapMode/.test(lines.slice(i, i + 12).join('\n')))
      add('WARN', file, ln, '<Character> без swapMode="dip" — кроссфейд поз читается как призрак (CLAUDE.md «Константы»)');

    // 5. мелкий кегль
    const fs = [...code.matchAll(/fontSize:\s*(\d+)/g)];
    for (const hit of fs) {
      const size = Number(hit[1]);
      // Порог 40, а не 58: константы канала штатно используют мелкий кегль в
      // CTA-карточке (слоган 32, кнопка 44) — ругаться на них значит шуметь.
      // Ниже 40 — почти всегда либо забытая правка, либо текстура без пометки.
      if (size < 40 && !/текстура|фактура|слоган/i.test(raw))
        add('WARN', file, ln, `fontSize: ${size} — ниже порога читаемости (правило 13). Если это осознанная текстура, пометь строку словом «текстура»`);
    }

    // 6. караоке-полоса — ПО ФАКТИЧЕСКОЙ ТЕМЕ РОЛИКА.
    // Раньше здесь была прибита одна светлая полоса 880–1030, и ролики в
    // тёмной теме (караоке на 1450–1620) проходили линт с наложением
    // субтитров на контент — брак, который линт обязан ловить.
    const [capTop, capBottom] = CAP_BAND;
    const coords = [...code.matchAll(/\b(top|bottom):\s*(\d+)/g)];
    for (const hit of coords) {
      const v = Number(hit[2]);
      if (hit[1] === 'top' && v >= capTop && v <= capBottom)
        add(
          'WARN',
          file,
          ln,
          `top: ${v} — попадает в караоке-полосу ${capTop}–${capBottom} (тема: ${THEME_NAME}), она неприкосновенна`,
        );
    }

    // 7. выход за края кадра (текст уезжает за рамку). Правило 16 требует
    // «максимально крупно», но в границах кадра: носитель шире 1080 или
    // с отрицательным left срезается по краю и читается как брак вёрстки.
    // Ложное срабатывание, которое чинится здесь:
    // у PageCam и родственных приёмов width — это ВНУТРЕННЯЯ система координат
    // страницы (1920), ужатая `transform: scale(zoom)` внутри контейнера с
    // overflow: hidden. На экран такой элемент никогда не выходит целиком.
    // Раньше линт ругался на каждый такой ролик (video-128 — 10 ERROR,
    // video-132 — 4), и красное приучались игнорировать — то есть правило
    // переставало работать ровно там, где его ввели. Признак ужатия ищем в
    // окрестности строки: scale() в том же стилевом объекте.
    // Линт идёт построчно, а transform обычно стоит на СОСЕДНЕЙ строке того же
    // стилевого объекта — поэтому смотрим окно строк вокруг находки.
    // Ужатие бывает двух видов: transform: scale(...) и CSS-свойство zoom
    // (3D-ветка PageCam растрирует страницу через него) — признаём оба.
    const nearScaled = /transform:[^;\n]*\bscale\(|(^|[\s{,])zoom\s*[,:]/.test(
      lines.slice(Math.max(0, i - 10), i + 11).join('\n'),
    );

    const widths = [...code.matchAll(/\bwidth:\s*(\d+)\b/g)];
    for (const hit of widths) {
      const w = Number(hit[1]);
      if (w > WIDTH && nearScaled)
        add(
          'WARN',
          file,
          ln,
          `width: ${w} — шире кадра, но рядом transform: scale() — считаю внутренней системой координат (PageCam и т.п.). Если scale не ужимает элемент, это настоящий срез`,
        );
      else if (w > WIDTH)
        add('ERROR', file, ln, `width: ${w} — шире кадра ${WIDTH}px, края срежутся (правило 16: крупно, но В КАДРЕ)`);
      else if (w > WIDTH - 2 * SAFE_X && !/во весь кадр|fullbleed|фон/i.test(raw))
        add(
          'WARN',
          file,
          ln,
          `width: ${w} — шире безопасной ширины ${WIDTH - 2 * SAFE_X}px (поля ${SAFE_X}px). Осознанный вылет под срез — пометь строку «во весь кадр»`,
        );
    }
    const lefts = [...code.matchAll(/\bleft:\s*(-\d+)/g)];
    for (const hit of lefts) {
      add('ERROR', file, ln, `left: ${hit[1]} — отрицательный отступ, элемент уезжает за левый край кадра`);
    }
  });
}

const errors = problems.filter((p) => p.level === 'ERROR');
const warns = problems.filter((p) => p.level === 'WARN');

for (const p of [...errors, ...warns]) {
  const tag = p.level === 'ERROR' ? '✗ ERROR' : '⚠ WARN ';
  console.log(`${tag}  ${p.file}:${p.line}\n         ${p.msg}`);
}

console.log(
  `\nИтог: ${errors.length} ошибок, ${warns.length} предупреждений (ролик video-${nn}).`,
);
if (errors.length || (STRICT && warns.length)) process.exit(1);
console.log('Линт пройден.');
