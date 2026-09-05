// Общий контракт темы. Обе темы (light.ts, noir.ts) реализуют этот тип —
// компоненты src/lib/*.tsx принимают `theme: Theme` пропом и не хардкодят
// цвета/зоны сами, чтобы одна и та же сцена рендерилась в обеих палитрах.

export type ThemeId = 'light' | 'noir';

export type ThemeColors = {
  bg: string;
  ink: string;
  muted: string;
  /** Цвет ещё не произнесённого слова в караоке ("призрак"). */
  ghost: string;
  card: string;
  cardBorder: string;
  cardShadow: string;
  /** Акцент маркера караоке (жёлтый в light, зелёный в noir). */
  mark: string;
  /** Цвет текста поверх плашки-маркера. */
  markText: string;
  blue: string;
  green: string;
  orange: string;
  purple: string;
  red: string;
  /** Пара цветов для стомп-вспышки фона (см. правило №7 в CLAUDE.md —
   * мигание ВСЕГО кадра запрещено, эти цвета — для точечных, не полноэкранных
   * акцентов). */
  flashA: string;
  flashB: string;
};

/** Пояс главного контента и полоса караоке-субтитров (px, кадр 1080×1920). */
export type SafeZones = {
  contentTop: number;
  contentBottom: number;
  capTop: number;
  capBottom: number;
};

/** Зона персонажа — только у тем с персонажем (сейчас — light). */
export type CharZone = {
  left: number;
  bottom: number;
  width: number;
  height: number;
  z: number;
};

/** Стиль пословных субтитров: light — капс на светлой пилюле-подложке,
 * noir — крупный текст прямо на кадре без подложки. */
export type CaptionStyle = {
  usePillBackground: boolean;
  pillBackground?: string;
  fontSize: number;
  textShadow: string;
};

export type Theme = {
  id: ThemeId;
  colors: ThemeColors;
  fontInter: string;
  fontMono: string;
  safe: SafeZones;
  charZone?: CharZone;
  caption: CaptionStyle;
};
