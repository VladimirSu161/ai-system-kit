import './fonts';
import React from 'react';
import { Composition } from 'remotion';
import { DemoLight, DemoNoir, DEMO_DURATION } from './videos/demo/Demo';
import { DemoFlow, DEMO_FLOW_DURATION, DEMO_FLOW_FPS } from './videos/demo/DemoFlow';

// Ролики собираются на 30 fps. FPS_NEW=60 — только по явной просьбе:
// рендер вдвое дольше, на телефоне разницы нет. Demo-композиции живут
// на 60, их внутренние кадровые константы под это и посчитаны.
const FPS = 30;
const FPS_NEW = 60;
const WIDTH = 1080;
const HEIGHT = 1920;

export const RemotionRoot: React.FC = () => {
  return (
    <>
      {/* DemoLight / DemoNoir — минимальная связка всех кусков движка:
          тема, фон, караоке, персонаж, стикер, Lottie, переход.
          Читать перед вёрсткой первого ролика (engine/README.md). */}
      <Composition
        id="DemoLight"
        component={DemoLight}
        durationInFrames={DEMO_DURATION}
        fps={FPS_NEW}
        width={WIDTH}
        height={HEIGHT}
      />
      <Composition
        id="DemoNoir"
        component={DemoNoir}
        durationInFrames={DEMO_DURATION}
        fps={FPS_NEW}
        width={WIDTH}
        height={HEIGHT}
      />
      {/* DemoFlow — демо FlowNode / DottedLink / MacWindow (правило 24). */}
      <Composition
        id="DemoFlow"
        component={DemoFlow}
        durationInFrames={DEMO_FLOW_DURATION}
        fps={DEMO_FLOW_FPS}
        width={WIDTH}
        height={HEIGHT}
      />

      {/* Новый ролик регистрируется здесь: подробности в engine/README.md,
          раздел «Как завести новый ролик».
          <Composition
            id="Video-NN"
            component={VideoNN}
            durationInFrames={VNN_DURATION}
            fps={FPS}
            width={WIDTH}
            height={HEIGHT}
            defaultProps={{ bgm: true }}
          /> */}
    </>
  );
};
