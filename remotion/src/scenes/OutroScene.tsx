import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS } from '../constants';
import { SolennixLogo } from '../components/SolennixLogo';

const { fontFamily } = loadFont();

export const OutroScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  // Main text springs in with bouncy effect
  const titleScale = frame >= 35
    ? spring({
        frame: frame - 35,
        fps,
        config: { damping: 8 },
      })
    : 0;

  const titleOpacity = interpolate(titleScale, [0, 0.3, 1], [0, 0.5, 1]);

  // Subtitle fades in
  const subtitleOpacity = interpolate(frame, [65, 85], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: COLORS.bg,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        fontFamily,
      }}
    >
      <div
        style={{
          display: 'flex',
          flexDirection: 'column',
          alignItems: 'center',
          gap: 28,
        }}
      >
        <SolennixLogo size={64} animateIn />

        <div
          style={{
            transform: `scale(${titleScale})`,
            opacity: titleOpacity,
            fontSize: 48,
            fontWeight: 'bold',
            color: COLORS.accent,
            fontFamily,
            textAlign: 'center',
          }}
        >
          ¡Así de fácil!
        </div>

        <div
          style={{
            opacity: subtitleOpacity,
            fontSize: 20,
            color: COLORS.textSecondary,
            fontFamily,
            textAlign: 'center',
          }}
        >
          Organizá tus eventos sin complicaciones
        </div>
      </div>
    </AbsoluteFill>
  );
};
