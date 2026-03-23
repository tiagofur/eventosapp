import { AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS } from '../constants';
import { MockSidebar } from '../components/MockSidebar';
import { Cursor } from '../components/Cursor';

const { fontFamily } = loadFont();

export const NavigationScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const layoutOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const activeItem = frame >= 50 ? 'Clientes' : 'Dashboard';
  const highlightFrame = 50;

  const headingOpacity = interpolate(frame, [60, 80], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const headingSlide = interpolate(frame, [60, 80], [20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.bg,
        fontFamily,
        opacity: layoutOpacity,
      }}
    >
      <div style={{ display: 'flex', height: '100%' }}>
        <MockSidebar activeItem={activeItem} highlightFrame={highlightFrame} />

        <div
          style={{
            flex: 1,
            margin: 16,
            marginLeft: 0,
            backgroundColor: COLORS.card,
            borderRadius: 48,
            padding: 48,
            display: 'flex',
            flexDirection: 'column',
          }}
        >
          <div
            style={{
              opacity: headingOpacity,
              transform: `translateY(${headingSlide}px)`,
              fontSize: 28,
              fontWeight: 'bold',
              color: COLORS.text,
              fontFamily,
            }}
          >
            Clientes
          </div>
        </div>
      </div>

      <Cursor
        positions={[
          { frame: 30, x: 100, y: 250 },
          { frame: 50, x: 130, y: 370 },
        ]}
        clickAtFrames={[50]}
      />
    </AbsoluteFill>
  );
};
