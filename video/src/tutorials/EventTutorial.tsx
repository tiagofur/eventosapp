import React from 'react';
import { AbsoluteFill } from 'remotion';
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { EVENT_SCENE_FRAMES, SCENE_FRAMES, TRANSITION_FRAMES, COLORS } from '../constants';
import { EventTutorialProps } from '../schema';
import { IntroScene } from '../scenes/IntroScene';
import { NavigationScene } from '../scenes/NavigationScene';
import { EventListScene } from '../scenes/EventListScene';
import { EventFormFillScene } from '../scenes/EventFormFillScene';
import { SaveScene } from '../scenes/SaveScene';
import { OutroScene } from '../scenes/OutroScene';

export const EventTutorial: React.FC<EventTutorialProps> = (props) => {
  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg }}>
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.intro}>
          <IntroScene title="Cómo crear un evento" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.navigation}>
          <NavigationScene targetItem="Cotización" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.eventList}>
          <EventListScene />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.formFill}>
          <EventFormFillScene {...props} />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.save}>
          <SaveScene successMessage="¡Evento creado con éxito!" />
        </TransitionSeries.Sequence>
        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: TRANSITION_FRAMES })}
        />
        <TransitionSeries.Sequence durationInFrames={EVENT_SCENE_FRAMES.outro}>
          <OutroScene />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};
