import { loadFont } from '@remotion/google-fonts/Cinzel';
import { spring, useCurrentFrame, useVideoConfig, interpolate } from 'remotion';
import { COLORS } from '../constants';

const { fontFamily } = loadFont();

type SolennixLogoProps = {
  size?: number;
  animateIn?: boolean;
};

export const SolennixLogo: React.FC<SolennixLogoProps> = ({
  size = 48,
  animateIn = true,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const scale = animateIn
    ? spring({ frame, fps, config: { damping: 200 } })
    : 1;

  const opacity = interpolate(frame, [0, 0.5 * fps], [0, 1], {
    extrapolateRight: 'clamp',
  });

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 16,
        transform: `scale(${scale})`,
        opacity,
      }}
    >
      {/* Simple circle icon representing the Solennix logo */}
      <div
        style={{
          width: size,
          height: size,
          borderRadius: size / 2,
          background: COLORS.accent,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
        }}
      >
        <span
          style={{
            color: COLORS.primary,
            fontSize: size * 0.5,
            fontWeight: 'bold',
            fontFamily,
          }}
        >
          S
        </span>
      </div>
      <span
        style={{
          fontFamily,
          fontSize: size * 0.75,
          fontWeight: 600,
          letterSpacing: '0.05em',
          color: COLORS.primary,
        }}
      >
        Solennix
      </span>
    </div>
  );
};
