// Локальные шрифты через @remotion/fonts (loadFont) — нулевая зависимость
// от сети (правило remotion-ecosystem.md п.6: @remotion/google-fonts
// ЗАПРЕЩЁН для прод-рендера, он качает файлы с fonts.gstatic.com).
// loadFont() сам вызывает delayRender()/continueRender() внутри; общий
// таймаут поднят до 120000мс в remotion.config.ts
// (Config.setDelayRenderTimeoutInMilliseconds), поэтому здесь его задавать
// негде — loadFont() не принимает свой timeoutInMilliseconds.
import { loadFont } from '@remotion/fonts';

import interRegular from './fonts/inter-v20-cyrillic_latin-regular.woff2';
import interMedium from './fonts/inter-v20-cyrillic_latin-500.woff2';
import interBold from './fonts/inter-v20-cyrillic_latin-700.woff2';
import interExtraBold from './fonts/inter-v20-cyrillic_latin-800.woff2';
import interBlack from './fonts/inter-v20-cyrillic_latin-900.woff2';
import jbMonoRegular from './fonts/jetbrains-mono-v24-cyrillic_latin-regular.woff2';
import jbMonoMedium from './fonts/jetbrains-mono-v24-cyrillic_latin-500.woff2';
import ptSerifRegular from './fonts/pt-serif-v19-cyrillic_latin-regular.woff2';
import ptSerifBold from './fonts/pt-serif-v19-cyrillic_latin-700.woff2';

void loadFont({ family: 'Inter', url: interRegular, weight: '400' });
void loadFont({ family: 'Inter', url: interMedium, weight: '500' });
void loadFont({ family: 'Inter', url: interBold, weight: '700' });
void loadFont({ family: 'Inter', url: interExtraBold, weight: '800' });
void loadFont({ family: 'Inter', url: interBlack, weight: '900' });
void loadFont({ family: 'JetBrains Mono', url: jbMonoRegular, weight: '400' });
void loadFont({ family: 'JetBrains Mono', url: jbMonoMedium, weight: '500' });

// PT Serif (кириллица+латиница) — добавлен для video-147 («редакторская»
// тема: текст статьи на бумаге набирается засечками, как в публикации).
// Скачан локально с gwfh.mranftl.com (Open Font License), сеть при рендере
// не используется.

void loadFont({ family: 'PT Serif', url: ptSerifRegular, weight: '400' });
void loadFont({ family: 'PT Serif', url: ptSerifBold, weight: '700' });
