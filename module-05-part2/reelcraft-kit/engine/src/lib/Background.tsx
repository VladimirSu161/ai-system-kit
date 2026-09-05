// Фон — один компонент, две ветки по theme.id (Background рендерится первым,
// под сценами).
//
// light («Sticker Light»):
// --bg + радиальный светлый блик сверху + пол-сетка в перспективе внизу
// кадра, плюс UiScrim (мягкое затемнение низа/правого края, z 45 — над
// персонажем, под караоке).
//
// noir («GitHub noir») — раньше фон был
// голым backgroundColor без общего компонента): --bg сплошной + статичная
// виньетка (радиальное затемнение к краям кадра). Виньетка статична — не
// мигает (правило №7 в reelcraft/CLAUDE.md: полноэкранные стробы запрещены).
import React from 'react';
import { AbsoluteFill } from 'remotion';
import type { Theme } from '../themes/types';

// Тёмная ветка — только для noir (у неё виньетка rgba(0,0,0,0.55) по краям).
// Светлые темы с персонажем обязаны идти в BackgroundLight: иначе кадр
// «серел» по краям.
export const Background: React.FC<{ theme: Theme }> = ({ theme }) =>
  theme.id === 'noir' ? <BackgroundNoir theme={theme} /> : <BackgroundLight theme={theme} />;

const BackgroundLight: React.FC<{ theme: Theme }> = ({ theme }) => (
  <AbsoluteFill style={{ pointerEvents: 'none' }}>
    <AbsoluteFill style={{ background: theme.colors.bg }} />

    {/* Радиальный светлый блик сверху кадра */}
    <AbsoluteFill
      style={{
        background:
          'radial-gradient(ellipse 90% 50% at 50% 8%, rgba(255,255,255,0.9), rgba(255,255,255,0) 60%)',
      }}
    />

    {/* Пол-сетка в перспективе — статичный слой внизу кадра */}
    <div
      style={{
        position: 'absolute',
        left: -200,
        right: -200,
        bottom: 0,
        height: 720,
        overflow: 'hidden',
        maskImage:
          'linear-gradient(to bottom, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 22%, rgba(0,0,0,1) 78%, rgba(0,0,0,0) 100%)',
        WebkitMaskImage:
          'linear-gradient(to bottom, rgba(0,0,0,0) 0%, rgba(0,0,0,1) 22%, rgba(0,0,0,1) 78%, rgba(0,0,0,0) 100%)',
      }}
    >
      <div style={{ position: 'absolute', inset: 0, perspective: 1150 }}>
        <div
          style={{
            position: 'absolute',
            left: 0,
            right: 0,
            bottom: 0,
            height: 1400,
            transform: 'rotateX(58deg)',
            transformOrigin: '50% 100%',
            backgroundImage:
              'repeating-linear-gradient(to top, rgba(16,24,40,0.07) 0px, rgba(16,24,40,0.07) 2px, transparent 2px, transparent 74px)',
          }}
        />
      </div>
    </div>
  </AbsoluteFill>
);

const BackgroundNoir: React.FC<{ theme: Theme }> = ({ theme }) => (
  <AbsoluteFill style={{ pointerEvents: 'none' }}>
    <AbsoluteFill style={{ background: theme.colors.bg }} />

    {/* Статичная виньетка — тёмный GitHub-фон читается объёмнее, не плоско */}
    <AbsoluteFill
      style={{
        background:
          'radial-gradient(ellipse 80% 60% at 50% 42%, rgba(0,0,0,0) 45%, rgba(0,0,0,0.55) 100%)',
      }}
    />
  </AbsoluteFill>
);

/** UiScrim — мягкое затемнение низа/правого края, нужен
 * только в light: там персонаж стоит на кадре, скрим отделяет его от
 * караоке-полосы. В noir не используется (персонажа нет). */
export const UiScrim: React.FC = () => (
  <AbsoluteFill
    style={{
      pointerEvents: 'none',
      zIndex: 45,
      background:
        'radial-gradient(ellipse 30% 42% at 103% 62%, rgba(22,24,29,0.22), rgba(22,24,29,0) 100%), linear-gradient(to top, rgba(22,24,29,0.36) 0%, rgba(22,24,29,0) 22%)',
    }}
  />
);
