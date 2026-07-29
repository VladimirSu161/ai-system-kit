#!/usr/bin/env node
/**
 * Рендер инфографик для статьи Дзена: HTML → PNG для каждого .infographic.
 *
 * Использование:
 *   node render.js /путь/к/infographics.html
 *
 * Результат: infographic-1.png, infographic-2.png, ... рядом с html.
 * Размер: 1280×720 (Дзен horizontal 16:9).
 */

const path = require('path');
const fs = require('fs');
const { execSync } = require('child_process');

const htmlPath = process.argv[2];
if (!htmlPath || !fs.existsSync(htmlPath)) {
  console.error('Usage: node render.js /path/to/infographics.html');
  process.exit(1);
}

const absHtmlPath = path.resolve(htmlPath);
const outDir = path.dirname(absHtmlPath);

const skillDir = path.resolve(__dirname, '..');
let puppeteer;
try {
  puppeteer = require(path.join(skillDir, 'node_modules', 'puppeteer'));
} catch (e) {
  console.log('Puppeteer not found, installing in skill folder (one-time)...');
  execSync('npm install puppeteer --silent', { cwd: skillDir, stdio: 'inherit' });
  puppeteer = require(path.join(skillDir, 'node_modules', 'puppeteer'));
}

(async () => {
  const browser = await puppeteer.launch({
    headless: 'new',
    args: ['--no-sandbox', '--disable-setuid-sandbox']
  });
  const page = await browser.newPage();

  await page.setViewport({ width: 1280, height: 720, deviceScaleFactor: 2 });
  await page.goto('file://' + absHtmlPath, { waitUntil: 'networkidle0' });
  await page.evaluateHandle('document.fonts.ready');

  const infographics = await page.$$('.infographic');
  if (infographics.length === 0) {
    console.error('No .infographic blocks found in HTML');
    await browser.close();
    process.exit(1);
  }

  console.log(`Found infographics: ${infographics.length}`);

  for (let i = 0; i < infographics.length; i++) {
    const filename = `infographic-${i + 1}.png`;
    const outPath = path.join(outDir, filename);
    await infographics[i].screenshot({ path: outPath, type: 'png', omitBackground: false });
    console.log(`  + ${filename}`);
  }

  await browser.close();
  console.log(`\nDone. PNG files in: ${outDir}`);
})().catch(err => {
  console.error('Render error:', err);
  process.exit(1);
});
