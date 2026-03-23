import { Composition } from 'remotion';
import { ClientTutorial } from './ClientTutorial';
import { ClientTutorialSchema } from './schema';
import { FPS, DURATION_FRAMES } from './constants';

export const RemotionRoot = () => {
  return (
    <Composition
      id="ClientTutorial"
      component={ClientTutorial}
      schema={ClientTutorialSchema}
      durationInFrames={DURATION_FRAMES}
      fps={FPS}
      width={1920}
      height={1080}
      defaultProps={{
        clientName: 'María García López',
        clientPhone: '55 1234 5678',
        clientEmail: 'maria@correo.com',
      }}
    />
  );
};
