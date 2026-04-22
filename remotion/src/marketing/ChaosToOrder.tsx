import React from 'react';
import {
  AbsoluteFill,
  useCurrentFrame,
  useVideoConfig,
  spring,
  interpolate,
  Img,
  staticFile,
  Sequence,
} from 'remotion';
import { TransitionSeries, linearTiming } from '@remotion/transitions';
import { fade } from '@remotion/transitions/fade';
import { loadFont as loadCinzel } from '@remotion/google-fonts/Cinzel';
import { loadFont as loadInter } from '@remotion/google-fonts/Inter';
import { SOCIAL_COLORS } from '../constants';
import { SolennixLogoDark } from '../components/SolennixLogoDark';
import type { ChaosToOrderProps } from '../schema';

const { fontFamily: cinzel } = loadCinzel();
const { fontFamily: inter } = loadInter();

const CHAOS_ICONS = [
  { src: 'chaos-icons/excel.png' },
  { src: 'chaos-icons/whatsapp.png' },
  { src: 'chaos-icons/google-calendar.png' },
  { src: 'chaos-icons/notepad.png' },
  { src: 'chaos-icons/folder.png' },
];

const SCREENSHOTS = [
  { src: 'screenshots/01-dashboard.png', label: 'Dashboard' },
  { src: 'screenshots/02-calendario.png', label: 'Calendario' },
  { src: 'screenshots/06-clientes.png', label: 'Clientes' },
  { src: 'screenshots/03-eventos-lista.png', label: 'Eventos' },
];

const ICON_SIZE = 200;
const ICON_POSITIONS = [
  { x: 80, y: 300 },
  { x: 720, y: 250 },
  { x: 40, y: 850 },
  { x: 780, y: 900 },
  { x: 400, y: 1350 },
];

const CENTER_X = 540;
const CENTER_Y = 960;

const SCATTER = [
  { x: 80, y: 250, rotate: -8 },
  { x: 500, y: 400, rotate: 5 },
  { x: 120, y: 650, rotate: -4 },
  { x: 520, y: 800, rotate: 7 },
];

const CARD_WIDTH = 360;

export const ChaosToOrder: React.FC<ChaosToOrderProps> = ({
  tagline = 'Todo tu negocio de eventos.\nUna sola app. Cero caos.',
  url = 'solennix.com',
}) => {
  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
      }}
    >
      <TransitionSeries>
        <TransitionSeries.Sequence durationInFrames={150}>
          <ChaosScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 15 })}
        />

        <TransitionSeries.Sequence durationInFrames={100}>
          <VortexScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 15 })}
        />

        <TransitionSeries.Sequence durationInFrames={150}>
          <LogoRevealScene tagline={tagline} />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 15 })}
        />

        <TransitionSeries.Sequence durationInFrames={260}>
          <ScatterScene />
        </TransitionSeries.Sequence>

        <TransitionSeries.Transition
          presentation={fade()}
          timing={linearTiming({ durationInFrames: 15 })}
        />

        <TransitionSeries.Sequence durationInFrames={370}>
          <CTAScene url={url} />
        </TransitionSeries.Sequence>
      </TransitionSeries>
    </AbsoluteFill>
  );
};

// ── SCENE 1: El Caos ──────────────────────────────────────────────
const ChaosScene: React.FC = () => {
  const frame = useCurrentFrame();

  const titleOpacity = interpolate(frame, [5, 25], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const titleY = interpolate(frame, [5, 25], [40, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const subOpacity = interpolate(frame, [50, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const subY = interpolate(frame, [50, 70], [30, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
      }}
    >
      {/* Title — centered upper third */}
      <div
        style={{
          position: 'absolute',
          top: 600,
          left: 0,
          right: 0,
          height: 460,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          opacity: titleOpacity,
          transform: `translateY(${titleY}px)`,
          paddingLeft: 80,
          paddingRight: 80,
          zIndex: 10,
        }}
      >
        <span
          style={{
            fontFamily: cinzel,
            fontSize: 60,
            fontWeight: 700,
            color: SOCIAL_COLORS.cream,
            textAlign: 'center',
            lineHeight: 1.2,
            letterSpacing: 1,
            textShadow: '0 4px 12px rgba(0,0,0,0.4)',
          }}
        >
          ¿Así gestionas
          <br />
          <span style={{ color: SOCIAL_COLORS.gold }}>tus eventos?</span>
        </span>
      </div>

      {/* Floating icons */}
      {CHAOS_ICONS.map((icon, i) => (
        <FloatingIcon
          key={i}
          src={icon.src}
          baseX={ICON_POSITIONS[i].x}
          baseY={ICON_POSITIONS[i].y}
          index={i}
        />
      ))}

      {/* Subtitle — bottom */}
      <div
        style={{
          position: 'absolute',
          bottom: 130,
          left: 60,
          right: 60,
          display: 'flex',
          justifyContent: 'center',
          opacity: subOpacity,
          transform: `translateY(${subY}px)`,
          zIndex: 10,
        }}
      >
        <span
          style={{
            fontFamily: inter,
            fontSize: 40,
            fontWeight: 400,
            color: '#cbd5e1',
            textAlign: 'center',
            letterSpacing: 0.5,
            lineHeight: 1.5,
            textShadow: '0 2px 8px rgba(0,0,0,0.5)',
          }}
        >
          Excel + WhatsApp + Google Calendar + papel...
        </span>
      </div>
    </AbsoluteFill>
  );
};

const FloatingIcon: React.FC<{
  src: string;
  baseX: number;
  baseY: number;
  index: number;
}> = ({ src, baseX, baseY, index }) => {
  const frame = useCurrentFrame();

  const fadeIn = interpolate(frame, [8 + index * 7, 22 + index * 7], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const speed = 0.04 + index * 0.008;
  const ampX = 30 + index * 6;
  const ampY = 25 + index * 5;
  const phase = index * 1.3;

  const dx = Math.sin(frame * speed + phase) * ampX;
  const dy = Math.cos(frame * speed * 0.7 + phase) * ampY;
  const rotation = Math.sin(frame * 0.035 + index * 0.8) * 10;

  return (
    <div
      style={{
        position: 'absolute',
        left: baseX + dx,
        top: baseY + dy,
        width: ICON_SIZE,
        height: ICON_SIZE,
        opacity: fadeIn,
        transform: `rotate(${rotation}deg)`,
        filter: `drop-shadow(0 12px 32px rgba(0,0,0,0.5))`,
      }}
    >
      <Img
        src={staticFile(src)}
        style={{ width: '100%', height: '100%', objectFit: 'contain' }}
      />
    </div>
  );
};

// ── SCENE 2: El Vortice ───────────────────────────────────────────
const VortexScene: React.FC = () => {
  const frame = useCurrentFrame();

  const glowSize = interpolate(frame, [60, 90], [100, 350], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const glowOpacity = interpolate(frame, [50, 80], [0, 0.6], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
      }}
    >
      {CHAOS_ICONS.map((icon, i) => {
        const progress = interpolate(frame, [0, 75], [0, 1], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });

        const x = interpolate(progress, [0, 1], [ICON_POSITIONS[i].x + ICON_SIZE / 2, CENTER_X]);
        const y = interpolate(progress, [0, 1], [ICON_POSITIONS[i].y + ICON_SIZE / 2, CENTER_Y]);
        const scale = interpolate(progress, [0, 0.5, 1], [1, 0.5, 0]);
        const rot = interpolate(progress, [0, 1], [0, 540 * (i % 2 === 0 ? 1 : -1)]);
        const opacity = interpolate(progress, [0, 0.6, 1], [1, 0.9, 0]);

        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: x - ICON_SIZE / 2,
              top: y - ICON_SIZE / 2,
              width: ICON_SIZE,
              height: ICON_SIZE,
              transform: `scale(${scale}) rotate(${rot}deg)`,
              opacity,
            }}
          >
            <Img
              src={staticFile(icon.src)}
              style={{ width: '100%', height: '100%', objectFit: 'contain' }}
            />
          </div>
        );
      })}

      <div
        style={{
          position: 'absolute',
          left: CENTER_X - glowSize / 2,
          top: CENTER_Y - glowSize / 2,
          width: glowSize,
          height: glowSize,
          borderRadius: '50%',
          background: `radial-gradient(circle, ${SOCIAL_COLORS.gold}55 0%, ${SOCIAL_COLORS.gold}00 70%)`,
          opacity: glowOpacity,
        }}
      />
    </AbsoluteFill>
  );
};

// ── SCENE 3: Logo Reveal ──────────────────────────────────────────
const LogoRevealScene: React.FC<{ tagline: string }> = ({ tagline }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const logoScale = spring({ frame, fps, config: { damping: 10, stiffness: 80 } });

  const lines = tagline.split('\n');

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      <div style={{ transform: `scale(${logoScale})`, marginBottom: 50 }}>
        <SolennixLogoDark size={120} animateIn={false} showWordmark variant="icon-only" />
      </div>

      {/* Text block — fixed width, centered */}
      <div
        style={{
          width: 880,
          textAlign: 'center',
        }}
      >
        {lines.map((line, i) => (
          <Sequence key={i} from={20 + i * 30} layout="none">
            <RevealingLine text={line} delay={0} gold={i === lines.length - 1} />
          </Sequence>
        ))}
      </div>

      <Sequence from={90} layout="none">
        <div
          style={{
            marginTop: 40,
            fontFamily: inter,
            fontSize: 28,
            fontWeight: 300,
            letterSpacing: interpolate(frame, [90, 130], [30, 8], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
            color: SOCIAL_COLORS.gold,
            opacity: interpolate(frame, [90, 110], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
          }}
        >
          CADA DETALLE IMPORTA
        </div>
      </Sequence>
    </AbsoluteFill>
  );
};

const RevealingLine: React.FC<{ text: string; delay: number; gold: boolean }> = ({ text, gold }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const opacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const y = interpolate(frame, [0, 20], [30, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const scale = spring({ frame, fps, config: { damping: 14 } });
  const blur = interpolate(frame, [0, 15], [10, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div
      style={{
        fontFamily: cinzel,
        fontSize: 56,
        fontWeight: 700,
        color: gold ? SOCIAL_COLORS.gold : SOCIAL_COLORS.cream,
        textAlign: 'center',
        lineHeight: 1.4,
        letterSpacing: 0.5,
        opacity,
        filter: `blur(${blur}px)`,
        transform: `translateY(${y}px) scale(${scale})`,
        marginBottom: 8,
        textShadow: gold ? '0 0 40px rgba(196, 162, 101, 0.4)' : '0 2px 10px rgba(0,0,0,0.5)',
      }}
    >
      {text}
    </div>
  );
};

// ── SCENE 4: Scattered Screenshots ────────────────────────────────
const ScatterScene: React.FC = () => {
  const frame = useCurrentFrame();

  const titleOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
      }}
    >
      {/* Title */}
      <div
        style={{
          position: 'absolute',
          top: 100,
          left: 0,
          right: 0,
          display: 'flex',
          justifyContent: 'center',
          opacity: titleOpacity,
        }}
      >
        <span
          style={{
            fontFamily: cinzel,
            fontSize: 50,
            fontWeight: 700,
            color: SOCIAL_COLORS.gold,
            textAlign: 'center',
            letterSpacing: 2,
          }}
        >
          Todo en un solo lugar
        </span>
      </div>

      {/* Scattered phone cards */}
      {SCREENSHOTS.map((ss, i) => (
        <ScatteredCard key={ss.label} src={ss.src} label={ss.label} index={i} />
      ))}

      {/* Bottom label */}
      <Sequence from={140}>
        <div
          style={{
            position: 'absolute',
            bottom: 130,
            left: 60,
            right: 60,
            display: 'flex',
            justifyContent: 'center',
            opacity: interpolate(frame, [140, 160], [0, 1], {
              extrapolateLeft: 'clamp',
              extrapolateRight: 'clamp',
            }),
            zIndex: 10,
          }}
        >
          <span
            style={{
              fontFamily: inter,
              fontSize: 40,
              fontWeight: 400,
              color: '#cbd5e1',
              textAlign: 'center',
              letterSpacing: 0.5,
              lineHeight: 1.5,
              textShadow: '0 2px 4px rgba(0,0,0,0.9)',
              WebkitFontSmoothing: 'antialiased',
              backfaceVisibility: 'hidden',
            }}
          >
            Clientes · Calendario · Presupuesto · Pagos · y mucho más...
          </span>
        </div>
      </Sequence>
    </AbsoluteFill>
  );
};

const ScatteredCard: React.FC<{
  src: string;
  label: string;
  index: number;
}> = ({ src, label, index }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const pos = SCATTER[index];
  const startFrame = 20 + index * 15;

  const entryX = interpolate(frame, [startFrame, startFrame + 20], [index % 2 === 0 ? -600 : 600, pos.x], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const entryOpacity = interpolate(frame, [startFrame, startFrame + 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const entryScale = frame >= startFrame
    ? spring({ frame: frame - startFrame, fps, config: { damping: 14 } })
    : 0;

  const highlightStart = 150 + index * 22;
  const highlightScale = interpolate(
    frame,
    [highlightStart, highlightStart + 8, highlightStart + 18, highlightStart + 26],
    [1, 1.06, 1.06, 1],
    { extrapolateLeft: 'clamp', extrapolateRight: 'clamp' },
  );

  const floatY = frame >= startFrame ? Math.sin((frame - startFrame) * 0.04 + index) * 15 : 0;

  return (
    <div
      style={{
        position: 'absolute',
        left: entryX,
        top: pos.y + floatY,
        width: CARD_WIDTH,
        zIndex: index + 1,
        opacity: entryOpacity,
        transform: `scale(${entryScale * highlightScale}) rotate(${pos.rotate}deg)`,
        transformOrigin: 'center center',
      }}
    >
      <div
        style={{
          borderRadius: 20,
          overflow: 'hidden',
          border: `2px solid rgba(196, 162, 101, ${0.15 + index * 0.05})`,
          boxShadow: `
            0 8px 32px rgba(0,0,0,0.5),
            0 0 0 1px rgba(196, 162, 101, 0.08)
          `,
        }}
      >
        <Img
          src={staticFile(src)}
          style={{ width: '100%', height: 'auto', display: 'block' }}
        />
      </div>

      {/* Floating label */}
      <div
        style={{
          position: 'absolute',
          top: -40,
          left: '50%',
          transform: `translateX(-50%) rotate(${-pos.rotate}deg)`,
          fontFamily: inter,
          fontSize: 32,
          fontWeight: 900, // Even bolder
          color: SOCIAL_COLORS.goldLight, // Brighter gold
          letterSpacing: 4,
          textTransform: 'uppercase',
          whiteSpace: 'nowrap',
          textShadow: '0 2px 4px rgba(0,0,0,0.8), 0 0 20px rgba(0,0,0,0.5)', // Tighter main shadow + soft glow
          opacity: interpolate(frame, [startFrame + 15, startFrame + 30], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          }),
          WebkitFontSmoothing: 'antialiased',
          backfaceVisibility: 'hidden',
          transformStyle: 'preserve-3d',
        }}
      >
        {label}
      </div>
    </div>
  );
};

// ── SCENE 5: CTA Final ────────────────────────────────────────────
const CTAScene: React.FC<{ url: string }> = ({ url }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const bulletPoints = [
    { text: 'Cero caos.', color: SOCIAL_COLORS.gold },
    { text: 'Cero Excel.', color: SOCIAL_COLORS.cream },
    { text: 'Cero papel.', color: SOCIAL_COLORS.cream },
  ];

  return (
    <AbsoluteFill
      style={{
        background: `linear-gradient(180deg, ${SOCIAL_COLORS.navyDark} 0%, ${SOCIAL_COLORS.navy} 100%)`,
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        justifyContent: 'center',
      }}
    >
      {/* Bullet points — upper area */}
      <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 24 }}>
        {bulletPoints.map((item, i) => {
          const start = 15 + i * 22;
          const opacity = interpolate(frame, [start, start + 18], [0, 1], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });
          const y = interpolate(frame, [start, start + 18], [35, 0], {
            extrapolateLeft: 'clamp',
            extrapolateRight: 'clamp',
          });

          return (
            <div
              key={item.text}
              style={{
                fontFamily: cinzel,
                fontSize: 62,
                fontWeight: 700,
                color: item.color,
                opacity,
                transform: `translateY(${y}px) scale(${frame >= start ? spring({ frame: frame - start, fps, config: { damping: 12 } }) : 0})`,
                letterSpacing: 2,
                textShadow: item.color === SOCIAL_COLORS.gold ? '0 0 25px rgba(196, 162, 101, 0.4)' : '0 2px 10px rgba(0,0,0,0.5)',
              }}
            >
              {item.text}
            </div>
          );
        })}
      </div>

      {/* Logo block — lower area */}
      <Sequence from={110} layout="none">
        <div
          style={{
            marginTop: 80,
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: 24,
          }}
        >
          <SolennixLogoDark size={60} animateIn showWordmark />

          <div
            style={{
              fontFamily: inter,
              fontSize: 26,
              fontWeight: 300,
              letterSpacing: 8,
              color: SOCIAL_COLORS.gold,
            }}
          >
            CADA DETALLE IMPORTA
          </div>

          <div
            style={{
              fontFamily: inter,
              fontSize: 44,
              fontWeight: 600,
              letterSpacing: 2,
              background: `linear-gradient(90deg, ${SOCIAL_COLORS.cream}, ${SOCIAL_COLORS.gold})`,
              WebkitBackgroundClip: 'text',
              WebkitTextFillColor: 'transparent',
              paddingBottom: 4,
            }}
          >
            {url}
          </div>

          <Sequence from={35} layout="none">
            <div style={{ display: 'flex', gap: 20 }}>
              <StoreBadge type="appstore" />
              <StoreBadge type="playstore" />
            </div>
          </Sequence>
        </div>
      </Sequence>
    </AbsoluteFill>
  );
};

// ── Store Badge ───────────────────────────────────────────────────
const StoreBadge: React.FC<{ type: 'appstore' | 'playstore' }> = ({ type }) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const badgeScale = spring({ frame, fps, config: { damping: 12 } });

  const label = type === 'appstore' ? 'App Store' : 'Google Play';
  const sublabel = type === 'appstore' ? 'Descarga en' : 'Disponible en';

  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 14,
        backgroundColor: SOCIAL_COLORS.cream,
        padding: '24px 48px', // Increased from 18x32
        borderRadius: 24, // Increased from 16
        transform: `scale(${badgeScale})`,
        boxShadow: '0 8px 32px rgba(0,0,0,0.4)',
      }}
    >
      <svg
        viewBox={type === 'appstore' ? '0 0 814 1000' : '0 0 24 24'}
        style={{ width: type === 'appstore' ? 44 : 48, height: 44, fill: SOCIAL_COLORS.navyDark, flexShrink: 0 }}
      >
        {type === 'appstore' ? (
          <path d="M788.1 340.9c-5.8 4.5-108.2 62.2-108.2 190.5 0 148.4 130.3 200.9 134.2 202.2-.6 3.2-20.7 71.9-68.7 141.9-42.8 61.6-87.5 123.1-155.5 123.1s-85.5-39.5-164-39.5c-76 0-103.7 40.8-165.9 40.8s-105-47.4-148.2-91.6C93.4 747.1 22 592.4 22 440.8c0-248.2 163.2-379.2 323.4-379.2 85.5 0 156.7 56.3 210.5 56.3 51.5 0 132.2-59.8 232.2-59.8 30.4 0 108.2 2.6 159.8 96.8zM546.1 131.4c23.1-27.6 39.8-65.8 39.8-104 0-5.2-.6-10.4-1.3-15.6-37.5 1.3-82.5 25.1-109.4 55.8-21.7 24.4-42.2 62.7-42.2 101.5 0 5.8.6 11.7 1.3 13.6 2.6.6 6.5 1.3 10.4 1.3 34 0 76.9-22.5 101.4-52.6z" />
        ) : (
          <path d="M3 20.5v-17c0-.83.94-1.3 1.6-.8l14 8.5c.6.37.6 1.23 0 1.6l-14 8.5c-.66.5-1.6.03-1.6-.8z" />
        )}
      </svg>
      <div style={{ textAlign: 'left' }}>
        <div
          style={{
            fontFamily: inter,
            fontSize: 20, // Increased from 16
            fontWeight: 400,
            color: SOCIAL_COLORS.navyDark,
            opacity: 0.8,
            lineHeight: 1,
            marginBottom: 6,
          }}
        >
          {sublabel}
        </div>
        <div
          style={{
            fontFamily: inter,
            fontSize: 32, // Increased from 24
            fontWeight: 800,
            color: SOCIAL_COLORS.navyDark,
            lineHeight: 1,
          }}
        >
          {label}
        </div>
      </div>
    </div>
  );
};
