import React from 'react';
import { AbsoluteFill, useCurrentFrame, useVideoConfig, spring, interpolate } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS, PREMIUM_GRADIENT } from '../constants';
import { MockSidebar } from '../components/MockSidebar';
import { MockTopbar } from '../components/MockTopbar';
import { ClickHighlight } from '../components/ClickHighlight';

const { fontFamily } = loadFont();

const EVENTS = [
  { initials: 'XV', name: 'XV Años - Valentina', client: 'Ana González', date: '28 Mar 2026', status: 'Confirmado', total: '$45,000', statusColor: COLORS.success },
  { initials: 'BD', name: 'Boda García-López', client: 'Carlos Ruiz', date: '15 Abr 2026', status: 'Cotizado', total: '$120,000', statusColor: '#F59E0B' },
  { initials: 'CP', name: 'Cumpleaños Paula', client: 'Laura Pérez', date: '22 Abr 2026', status: 'Confirmado', total: '$18,500', statusColor: COLORS.success },
];

const CalendarIcon: React.FC<{ size?: number }> = ({ size = 14 }) => (
  <svg width={size} height={size} viewBox="0 0 24 24" fill="none">
    <rect x="3" y="4" width="18" height="18" rx="2" stroke={COLORS.textSecondary} strokeWidth="1.5" />
    <path d="M16 2v4M8 2v4M3 10h18" stroke={COLORS.textSecondary} strokeWidth="1.5" strokeLinecap="round" />
  </svg>
);

const PlusIcon: React.FC = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
    <path d="M12 5v14M5 12h14" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
  </svg>
);

const SearchIcon: React.FC = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)' }}>
    <circle cx="11" cy="11" r="7" stroke={COLORS.textSecondary} strokeWidth="2" />
    <path d="M16 16L20 20" stroke={COLORS.textSecondary} strokeWidth="2" strokeLinecap="round" />
  </svg>
);

export const EventListScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const flashOpacity = interpolate(frame, [80, 90, 100, 120], [0, 0.15, 0.15, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg, fontFamily }}>
      <div style={{ display: 'flex', height: '100%' }}>
        <MockSidebar activeItem="Cotización" />

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', padding: '8px 8px 8px 0', overflow: 'hidden' }}>
          <div style={{ flex: 1, backgroundColor: COLORS.surface, borderRadius: 48, border: `1px solid ${COLORS.border}`, boxShadow: '0 20px 25px -5px rgba(0,0,0,0.1)', display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
            <MockTopbar />

            <div style={{ flex: 1, padding: '0 40px 40px', overflow: 'hidden' }}>
              {/* Header */}
              <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 24 }}>
                <h1 style={{ fontSize: 24, fontWeight: 900, color: COLORS.text, letterSpacing: '-0.025em', margin: 0 }}>
                  Eventos
                </h1>
                <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                  <div style={{ display: 'inline-flex', alignItems: 'center', gap: 6, padding: '8px 20px', borderRadius: 12, background: PREMIUM_GRADIENT, color: COLORS.white, fontSize: 14, fontWeight: 700, boxShadow: '0 4px 6px -1px rgba(196, 162, 101, 0.2)' }}>
                    <PlusIcon />
                    Nuevo Evento
                  </div>
                </div>
              </div>

              {/* Search bar */}
              <div style={{ position: 'relative', marginBottom: 16 }}>
                <SearchIcon />
                <div style={{ width: '100%', padding: '8px 12px 8px 36px', borderRadius: 12, border: `1px solid ${COLORS.border}`, backgroundColor: COLORS.card, fontSize: 14, color: COLORS.textSecondary }}>
                  Buscar eventos...
                </div>
              </div>

              {/* Status filter pills */}
              <div style={{ display: 'flex', gap: 8, marginBottom: 24 }}>
                {['Todos', 'Cotizado', 'Confirmado', 'Completado'].map((st, i) => (
                  <div key={st} style={{
                    padding: '4px 14px',
                    borderRadius: 9999,
                    fontSize: 12,
                    fontWeight: 500,
                    backgroundColor: i === 0 ? COLORS.primary : COLORS.surfaceAlt,
                    color: i === 0 ? COLORS.white : COLORS.textSecondary,
                    border: i === 0 ? 'none' : `1px solid ${COLORS.border}`,
                  }}>
                    {st}
                  </div>
                ))}
              </div>

              {/* Table card */}
              <div style={{ backgroundColor: COLORS.card, overflow: 'hidden', borderRadius: 24, border: `1px solid ${COLORS.border}` }}>
                <div style={{ display: 'grid', gridTemplateColumns: '2.5fr 1.5fr 1fr 1fr', backgroundColor: COLORS.surfaceAlt }}>
                  {['EVENTO', 'FECHA', 'ESTADO', 'TOTAL'].map((col) => (
                    <div key={col} style={{ padding: '12px 24px', fontSize: 11, fontWeight: 500, color: COLORS.textSecondary, textTransform: 'uppercase' as const, letterSpacing: '0.05em' }}>
                      {col}
                    </div>
                  ))}
                </div>

                {EVENTS.map((event, i) => {
                  const slideProgress = spring({ frame: Math.max(0, frame - (5 + i * 10)), fps, config: { damping: 15, stiffness: 120 } });
                  const translateX = interpolate(slideProgress, [0, 1], [80, 0]);
                  const rowOpacity = interpolate(slideProgress, [0, 1], [0, 1]);

                  return (
                    <div key={event.name} style={{ display: 'grid', gridTemplateColumns: '2.5fr 1.5fr 1fr 1fr', borderTop: i > 0 ? `1px solid ${COLORS.border}` : undefined, transform: `translateX(${translateX}px)`, opacity: rowOpacity }}>
                      {/* Event name + client */}
                      <div style={{ padding: '16px 24px', display: 'flex', alignItems: 'center', gap: 12 }}>
                        <div style={{ width: 40, height: 40, borderRadius: 12, backgroundColor: `${COLORS.primary}18`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 13, fontWeight: 700, color: COLORS.primary, flexShrink: 0 }}>
                          {event.initials}
                        </div>
                        <div>
                          <div style={{ fontSize: 14, fontWeight: 600, color: COLORS.text }}>{event.name}</div>
                          <div style={{ fontSize: 12, color: COLORS.textSecondary, marginTop: 2 }}>{event.client}</div>
                        </div>
                      </div>

                      {/* Date */}
                      <div style={{ padding: '16px 24px', display: 'flex', alignItems: 'center', gap: 8 }}>
                        <CalendarIcon />
                        <span style={{ fontSize: 14, color: COLORS.text }}>{event.date}</span>
                      </div>

                      {/* Status badge */}
                      <div style={{ padding: '16px 24px', display: 'flex', alignItems: 'center' }}>
                        <span style={{
                          padding: '2px 10px',
                          borderRadius: 9999,
                          backgroundColor: `${event.statusColor}18`,
                          color: event.statusColor,
                          fontSize: 12,
                          fontWeight: 600,
                        }}>
                          {event.status}
                        </span>
                      </div>

                      {/* Total */}
                      <div style={{ padding: '16px 24px', display: 'flex', alignItems: 'center' }}>
                        <span style={{ fontSize: 14, fontWeight: 600, color: COLORS.text }}>{event.total}</span>
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </div>

      <AbsoluteFill style={{ backgroundColor: COLORS.primary, opacity: flashOpacity, pointerEvents: 'none' }} />
      <ClickHighlight x={1782} y={130} clickFrame={65} />
    </AbsoluteFill>
  );
};
