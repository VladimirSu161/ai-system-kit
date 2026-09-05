import { Config } from '@remotion/cli/config';

// Качество кадров и кодека (2026-09-04, по ревью): раньше кадры снимались
// JPEG quality 80 (дефолт Remotion) и жались CRF 18 — тёмный video-150 весил
// 1.5 Мбит/с, Instagram перекодировал его ещё раз и мылил градиенты и мелкий
// текст. Теперь JPEG 95 + CRF 16: битрейт выше, артефактов на краях букв
// нет, рендер медленнее на единицы процентов. Флагами командной строки
// (--jpeg-quality, --crf) эти значения НЕ понижать.
Config.setVideoImageFormat('jpeg');
Config.setJpegQuality(95);
Config.setCrf(16);
Config.setOverwriteOutput(true);
Config.setChromiumOpenGlRenderer('angle');
Config.setConcurrency(4);

// Шрифты грузятся локально (@remotion/fonts, без сети) через delayRender —
// таймаут поднят до 120с с запасом (правило remotion-ecosystem.md п.6:
// google-fonts запрещён, только локальные .woff2).
Config.setDelayRenderTimeoutInMilliseconds(120000);
