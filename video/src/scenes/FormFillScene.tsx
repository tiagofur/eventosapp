import { AbsoluteFill, useCurrentFrame, interpolate } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS } from '../constants';
import { ClientTutorialProps } from '../schema';
import { MockSidebar } from '../components/MockSidebar';
import { MockFormInput } from '../components/MockFormInput';
import { MockButton } from '../components/MockButton';
import { Cursor } from '../components/Cursor';

const { fontFamily } = loadFont();

export const FormFillScene: React.FC<ClientTutorialProps> = ({
  clientName,
  clientPhone,
  clientEmail,
}) => {
  const frame = useCurrentFrame();

  const cardOpacity = interpolate(frame, [20, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const cardSlide = interpolate(frame, [20, 30], [20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const addressOpacity = interpolate(frame, [260, 275], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Determine which field is currently focused
  const nameIsFocused = frame >= 40 && frame < 120;
  const phoneIsFocused = frame >= 120 && frame < 190;
  const emailIsFocused = frame >= 190 && frame < 260;

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
            opacity: cardOpacity,
            transform: `translateY(${cardSlide}px)`,
          }}
        >
          {/* Header */}
          <div
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 12,
              marginBottom: 32,
            }}
          >
            <span
              style={{
                fontSize: 24,
                color: COLORS.textSecondary,
                cursor: 'pointer',
              }}
            >
              ←
            </span>
            <span
              style={{
                fontSize: 24,
                fontWeight: 'bold',
                color: COLORS.text,
                fontFamily,
              }}
            >
              Nuevo Cliente
            </span>
          </div>

          {/* Photo upload placeholder */}
          <div
            style={{
              display: 'flex',
              justifyContent: 'center',
              marginBottom: 32,
            }}
          >
            <div
              style={{
                width: 96,
                height: 96,
                borderRadius: 48,
                backgroundColor: COLORS.surfaceAlt,
                border: `2px dashed ${COLORS.border}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontSize: 32,
                color: COLORS.textTertiary,
              }}
            >
              <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
                <rect
                  x="2"
                  y="5"
                  width="20"
                  height="14"
                  rx="3"
                  stroke={COLORS.textTertiary}
                  strokeWidth="1.5"
                />
                <circle
                  cx="12"
                  cy="12"
                  r="3.5"
                  stroke={COLORS.textTertiary}
                  strokeWidth="1.5"
                />
                <circle cx="17" cy="8" r="1" fill={COLORS.textTertiary} />
              </svg>
            </div>
          </div>

          {/* Form fields */}
          <div style={{ maxWidth: 600, alignSelf: 'center', width: '100%' }}>
            <MockFormInput
              label="Nombre Completo"
              value={clientName}
              required
              typingStartFrame={50}
              isFocused={nameIsFocused}
            />

            <MockFormInput
              label="Teléfono"
              value={clientPhone}
              required
              typingStartFrame={130}
              isFocused={phoneIsFocused}
            />

            <MockFormInput
              label="Correo Electrónico"
              value={clientEmail}
              typingStartFrame={200}
              isFocused={emailIsFocused}
            />

            {/* Address and City - pre-filled, fade in */}
            <div style={{ opacity: addressOpacity }}>
              <div style={{ marginBottom: 16 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 14,
                    fontWeight: 500,
                    color: COLORS.textSecondary,
                    marginBottom: 6,
                    fontFamily,
                  }}
                >
                  Dirección
                </label>
                <div
                  style={{
                    padding: '12px 16px',
                    borderRadius: 12,
                    border: `1px solid ${COLORS.border}`,
                    backgroundColor: COLORS.card,
                    fontSize: 16,
                    color: COLORS.text,
                    fontFamily,
                  }}
                >
                  Av. Reforma 234
                </div>
              </div>

              <div style={{ marginBottom: 16 }}>
                <label
                  style={{
                    display: 'block',
                    fontSize: 14,
                    fontWeight: 500,
                    color: COLORS.textSecondary,
                    marginBottom: 6,
                    fontFamily,
                  }}
                >
                  Ciudad
                </label>
                <div
                  style={{
                    padding: '12px 16px',
                    borderRadius: 12,
                    border: `1px solid ${COLORS.border}`,
                    backgroundColor: COLORS.card,
                    fontSize: 16,
                    color: COLORS.text,
                    fontFamily,
                  }}
                >
                  Ciudad de México
                </div>
              </div>
            </div>

            {/* Save button */}
            <div
              style={{
                display: 'flex',
                justifyContent: 'flex-end',
                marginTop: 24,
              }}
            >
              <MockButton
                label="Guardar Cliente"
                variant="primary"
                pressAtFrame={320}
              />
            </div>
          </div>
        </div>
      </div>

      <Cursor
        positions={[
          { frame: 40, x: 700, y: 380 },
          { frame: 50, x: 720, y: 380 },
          { frame: 110, x: 720, y: 460 },
          { frame: 120, x: 720, y: 460 },
          { frame: 180, x: 720, y: 540 },
          { frame: 190, x: 720, y: 540 },
          { frame: 260, x: 720, y: 620 },
          { frame: 300, x: 1050, y: 780 },
          { frame: 320, x: 1050, y: 780 },
        ]}
        clickAtFrames={[50, 130, 200, 320]}
      />
    </AbsoluteFill>
  );
};
