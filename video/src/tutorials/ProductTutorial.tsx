import React from 'react';
import { AbsoluteFill } from 'remotion';
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { SCENE_FRAMES, TRANSITION_FRAMES, COLORS } from '../constants';
import { ProductTutorialProps } from '../schema';
import { IntroScene } from '../scenes/IntroScene';
import { NavigationScene } from '../scenes/NavigationScene';
import { ProductListScene } from '../scenes/ProductListScene';
import { ProductFormFillScene } from '../scenes/ProductFormFillScene';
import { SaveScene } from '../scenes/SaveScene';
import { OutroScene } from '../scenes/OutroScene';

export const ProductTutorial: React.FC<ProductTutorialProps> = (props) => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.intro}>
          <IntroScene title="Cómo crear un producto" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.navigation}>
          <NavigationScene targetItem="Productos" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.clientList}>
          <ProductListScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.formFill}>
          <ProductFormFillScene {...props} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.save}>
          <SaveScene successMessage="¡Producto creado con éxito!" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={SCENE_FRAMES.outro}>
          <OutroScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
