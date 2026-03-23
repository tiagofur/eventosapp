import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS } from '../constants';
import { MockSidebar } from '../components/MockSidebar';
import { MockButton } from '../components/MockButton';
import { Cursor } from '../components/Cursor';

const { fontFamily } = loadFont();

const CLIENTS = [
  { initials: 'AG', name: 'Ana González', phone: '55 9876 5432' },
  { initials: 'CR', name: 'Carlos Ruiz', phone: '55 4567 8901' },
  { initials: 'LP', name: 'Laura Pérez', phone: '55 1122 3344' },
];

export const ClientListScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const flashOpacity = interpolate(frame, [80, 90, 100, 120], [0, 0.15, 0.15, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg, fontFamily }}>
      <div style={{ display: 'flex', height: '100%' }}>
        <MockSidebar activeItem="Clientes" />

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
          {/* Header row */}
          <div
            style={{
              display: 'flex',
              justifyContent: 'space-between',
              alignItems: 'center',
              marginBottom: 32,
            }}
          >
            <div
              style={{
                fontSize: 28,
                fontWeight: 'bold',
                color: COLORS.text,
                fontFamily,
              }}
            >
              Clientes
            </div>
            <MockButton
              label="Nuevo Cliente"
              variant="primary"
              pressAtFrame={65}
              icon={
                <span style={{ fontSize: 18, fontWeight: 'bold' }}>+</span>
              }
            />
          </div>

          {/* Mock table */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
            {CLIENTS.map((client, i) => {
              const delay = [5, 15, 25][i];
              const slideProgress = spring({
                frame: Math.max(0, frame - delay),
                fps,
                config: { damping: 15, stiffness: 120 },
              });

              const translateX = interpolate(slideProgress, [0, 1], [80, 0]);
              const rowOpacity = interpolate(slideProgress, [0, 1], [0, 1]);

              return (
                <div
                  key={client.initials}
                  style={{
                    display: 'flex',
                    alignItems: 'center',
                    gap: 16,
                    padding: '16px 20px',
                    borderRadius: 16,
                    backgroundColor: COLORS.surface,
                    transform: `translateX(${translateX}px)`,
                    opacity: rowOpacity,
                  }}
                >
                  {/* Avatar circle */}
                  <div
                    style={{
                      width: 44,
                      height: 44,
                      borderRadius: 22,
                      backgroundColor: COLORS.primaryLight,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                      fontSize: 16,
                      fontWeight: 600,
                      color: COLORS.primaryDark,
                      flexShrink: 0,
                    }}
                  >
                    {client.initials}
                  </div>

                  <div style={{ flex: 1 }}>
                    <div
                      style={{
                        fontSize: 16,
                        fontWeight: 600,
                        color: COLORS.text,
                        fontFamily,
                      }}
                    >
                      {client.name}
                    </div>
                  </div>

                  <div
                    style={{
                      fontSize: 14,
                      color: COLORS.textSecondary,
                      fontFamily,
                    }}
                  >
                    {client.phone}
                  </div>
                </div>
              );
            })}
          </div>
        </div>
      </div>

      {/* Flash overlay on click */}
      <AbsoluteFill
        style={{
          backgroundColor: COLORS.primary,
          opacity: flashOpacity,
          pointerEvents: 'none',
        }}
      />

      <Cursor
        positions={[
          { frame: 30, x: 1500, y: 180 },
          { frame: 50, x: 1700, y: 180 },
        ]}
        clickAtFrames={[65]}
      />
    </AbsoluteFill>
  );
};
