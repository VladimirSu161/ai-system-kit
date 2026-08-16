#!/usr/bin/env node
/* ══════════════════════════════════════════════════════════════
   Генератор караоке-субтитров из transcript.json (whisper).

   Запуск из корня проекта:
     node scripts/captions-from-transcript.mjs                # transcript.json → captions.generated.js
     node scripts/captions-from-transcript.mjs input.json out.js

   Что делает: превращает word-level транскрипт в готовый JS-массив
   CAP (по одному слову на строку — удобно вычитывать построчно).

   ⚠ ВАЖНО (правило CLAUDE.md): Whisper галлюцинирует
   («задрат»→«затрат», «Sonat»→«Sonnet», «код-код»→«Клод Код»).
   После генерации ОБЯЗАТЕЛЬНО вычитать текст и исправить ошибки
   руками, СОХРАНИВ тайминги. Потом вставить массив в композицию:
     const CAP = [...];  buildCaptions(CAP);
   ══════════════════════════════════════════════════════════════ */

import { readFileSync, writeFileSync } from "node:fs";

const inPath  = process.argv[2] || "transcript.json";
const outPath = process.argv[3] || "captions.generated.js";

let raw;
try {
  raw = JSON.parse(readFileSync(inPath, "utf8"));
} catch (e) {
  console.error(`✗ Не удалось прочитать ${inPath}: ${e.message}`);
  console.error("  Сначала транскрибируй: npx hyperframes transcribe inbox/<файл> --model small --language ru");
  process.exit(1);
}

// transcript.json — плоский массив [{id?, text, start, end}]
const words = Array.isArray(raw) ? raw : raw.words;
if (!Array.isArray(words) || !words.length) {
  console.error("✗ В файле нет массива слов [{text, start, end}]");
  process.exit(1);
}

const bad = words.findIndex(w => typeof w.text !== "string" || typeof w.start !== "number" || typeof w.end !== "number");
if (bad !== -1) {
  console.error(`✗ Слово #${bad} без text/start/end: ${JSON.stringify(words[bad])}`);
  process.exit(1);
}

const lines = words.map(w =>
  `  {text:${JSON.stringify(w.text)}, start:${w.start}, end:${w.end}},`
);

const out = `/* Сгенерировано scripts/captions-from-transcript.mjs из ${inPath}
   (${words.length} слов, ${words[0].start}s – ${words[words.length - 1].end}s)

   ⚠ ПЕРЕД ИСПОЛЬЗОВАНИЕМ: вычитать текст построчно, исправить
   ошибки Whisper (сохранив тайминги!), затем вставить в композицию:
     const CAP = [ ...строки ниже... ];
     buildCaptions(CAP);   // хелпер из shared/helpers.js
*/
const CAP = [
${lines.join("\n")}
];
`;

writeFileSync(outPath, out, "utf8");
console.log(`✓ ${outPath}: ${words.length} слов (${words[0].start}s – ${words[words.length - 1].end}s)`);
console.log("→ Теперь вычитай текст (ошибки Whisper!) и вставь массив в композицию.");
