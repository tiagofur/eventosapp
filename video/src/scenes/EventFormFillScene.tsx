import React from 'react';
import { AbsoluteFill, useCurrentFrame, interpolate, useVideoConfig, spring } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS, PREMIUM_GRADIENT } from '../constants';
import { EventTutorialProps } from '../schema';
import { MockSidebar } from '../components/MockSidebar';
import { MockTopbar } from '../components/MockTopbar';
import { MockFormInput } from '../components/MockFormInput';
import { MockButton } from '../components/MockButton';
import { ClickHighlight } from '../components/ClickHighlight';

const { fontFamily } = loadFont();

const ArrowLeftIcon: React.FC = () => (
  <svg width="20" height="20" viewBox="0 0 24 24" fill="none">
    <path d="M19 12H5M12 19l-7-7 7-7" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const SaveIcon: React.FC = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
    <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    <polyline points="17,21 17,13 7,13 7,21" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    <polyline points="7,3 7,8 15,8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

const ChevronRightIcon: React.FC = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
    <path d="M9 18l6-6-6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

// Step indicator icons
const StepIcon: React.FC<{ label: string; number: number; active: boolean; completed: boolean }> = ({ label, number, active, completed }) => (
  <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
    <div style={{
      width: 28,
      height: 28,
      borderRadius: 14,
      backgroundColor: completed ? COLORS.success : active ? COLORS.primary : COLORS.surfaceAlt,
      border: active && !completed ? `2px solid ${COLORS.primary}` : completed ? 'none' : `1px solid ${COLORS.border}`,
      display: 'flex',
      alignItems: 'center',
      justifyContent: 'center',
      fontSize: 12,
      fontWeight: 700,
      color: completed || active ? COLORS.white : COLORS.textSecondary,
      flexShrink: 0,
    }}>
      {completed ? (
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
          <path d="M20 6L9 17l-5-5" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
        </svg>
      ) : number}
    </div>
    <span style={{
      fontSize: 12,
      fontWeight: active || completed ? 600 : 400,
      color: active ? COLORS.primary : completed ? COLORS.success : COLORS.textSecondary,
      whiteSpace: 'nowrap',
    }}>
      {label}
    </span>
  </div>
);

const StepDivider: React.FC = () => (
  <div style={{ width: 32, height: 1, backgroundColor: COLORS.border, flexShrink: 0 }} />
);

export const EventFormFillScene: React.FC<EventTutorialProps> = ({
  eventClient,
  eventDate,
  eventStartTime,
  eventServiceType,
  eventNumPeople,
  eventLocation,
  eventProductName,
  eventProductQty,
  eventProductPrice,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const cardOpacity = interpolate(frame, [15, 25], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const cardSlide = interpolate(frame, [15, 25], [20, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // ═══════════════════════════════════════════════════
  // STEP 1: General Info (frames 0–410)
  // ═══════════════════════════════════════════════════
  const isStep1 = frame < 420;
  const isStep2 = frame >= 420;

  // Step 1 field focus states
  const clientFocused = frame >= 35 && frame < 100;
  const dateFocused = frame >= 100 && frame < 155;
  const timeFocused = frame >= 155 && frame < 205;
  const serviceTypeFocused = frame >= 205 && frame < 280;
  const numPeopleFocused = frame >= 280 && frame < 340;
  const locationFocused = frame >= 340 && frame < 400;

  // "Siguiente" button click
  const nextBtnFrame = 410;

  // ═══════════════════════════════════════════════════
  // STEP 2: Products (frames 420–680)
  // ═══════════════════════════════════════════════════
  const step2Opacity = interpolate(frame, [420, 435], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const step2Slide = interpolate(frame, [420, 435], [30, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Product row fields
  const productSelectFocused = frame >= 445 && frame < 510;
  const productQtyFocused = frame >= 510 && frame < 560;
  // Subtotal appears
  const subtotalVisible = frame >= 570;

  // Status dropdown state (Cotizado auto-selected)
  const statusValue = 'Cotizado';

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg, fontFamily }}>
      <div style={{ display: 'flex', height: '100%' }}>
        <MockSidebar activeItem="Cotización" />

        <div style={{ flex: 1, display: 'flex', flexDirection: 'column', minWidth: 0, overflow: 'hidden', padding: '8px 8px 8px 0' }}>
          <div style={{
            flex: 1,
            backgroundColor: COLORS.surface,
            borderRadius: 48,
            border: `1px solid ${COLORS.border}`,
            boxShadow: '0 20px 25px -5px rgba(0,0,0,0.1), 0 8px 10px -6px rgba(0,0,0,0.1)',
            display: 'flex',
            flexDirection: 'column',
            overflow: 'hidden',
            opacity: cardOpacity,
            transform: `translateY(${cardSlide}px)`,
          }}>
            <MockTopbar />

            <div style={{ flex: 1, padding: '0 40px 40px', overflow: 'auto' }}>
              {/* Header */}
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 20 }}>
                <div style={{ padding: 8, borderRadius: 9999, display: 'flex', alignItems: 'center', justifyContent: 'center', color: COLORS.textSecondary }}>
                  <ArrowLeftIcon />
                </div>
                <h1 style={{ fontSize: 24, fontWeight: 700, color: COLORS.text, margin: 0 }}>
                  Nuevo Evento
                </h1>
              </div>

              {/* Step indicator bar */}
              <div style={{
                display: 'flex',
                alignItems: 'center',
                gap: 12,
                marginBottom: 28,
                padding: '12px 20px',
                backgroundColor: COLORS.card,
                borderRadius: 16,
                border: `1px solid ${COLORS.border}`,
              }}>
                <StepIcon label="General" number={1} active={isStep1} completed={isStep2} />
                <StepDivider />
                <StepIcon label="Productos" number={2} active={isStep2} completed={false} />
                <StepDivider />
                <StepIcon label="Extras" number={3} active={false} completed={false} />
                <StepDivider />
                <StepIcon label="Insumos" number={4} active={false} completed={false} />
                <StepDivider />
                <StepIcon label="Finanzas" number={5} active={false} completed={false} />
              </div>

              {/* ═══════════ STEP 1: Información General ═══════════ */}
              {isStep1 && (
                <div style={{ backgroundColor: COLORS.card, boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: `1px solid ${COLORS.border}`, borderRadius: 24, padding: 36 }}>
                  <h2 style={{ fontSize: 17, fontWeight: 700, color: COLORS.text, margin: '0 0 24px 0' }}>
                    Información General
                  </h2>

                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 20 }}>
                    {/* Cliente — span 6, dropdown */}
                    <div style={{ gridColumn: 'span 6', position: 'relative' }}>
                      <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 8 }}>
                        Cliente <span style={{ color: COLORS.error }}>*</span>
                      </label>
                      <div style={{
                        width: '100%',
                        padding: '12px 16px',
                        borderRadius: 12,
                        border: `1px solid ${clientFocused ? COLORS.primary : COLORS.border}`,
                        backgroundColor: COLORS.card,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        boxShadow: clientFocused ? `0 0 0 4px ${COLORS.primary}20` : 'none',
                        height: 45,
                      }}>
                        <span style={{ fontSize: 14, color: frame >= 75 ? COLORS.text : COLORS.textSecondary }}>
                          {frame >= 75 ? eventClient : 'Seleccionar cliente...'}
                        </span>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ color: COLORS.textSecondary }}>
                          <path d="M6 9l6 6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                      </div>

                      {/* Dropdown */}
                      {clientFocused && frame >= 50 && frame < 100 && (
                        <div style={{
                          position: 'absolute',
                          top: '100%',
                          left: 0,
                          right: 0,
                          marginTop: 4,
                          backgroundColor: COLORS.card,
                          border: `1px solid ${COLORS.border}`,
                          borderRadius: 12,
                          boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)',
                          zIndex: 50,
                          overflow: 'hidden',
                        }}>
                          {['Ana González', 'Carlos Ruiz', 'Laura Pérez'].map((opt, idx) => {
                            const isSelected = opt === eventClient;
                            const highlight = frame >= 65 && isSelected;
                            return (
                              <div key={opt} style={{
                                padding: '10px 16px',
                                fontSize: 13,
                                color: COLORS.text,
                                backgroundColor: highlight ? `${COLORS.primary}12` : 'transparent',
                                display: 'flex',
                                alignItems: 'center',
                                gap: 10,
                              }}>
                                <div style={{ width: 28, height: 28, borderRadius: 14, backgroundColor: `${COLORS.primary}15`, display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 11, fontWeight: 700, color: COLORS.primary }}>
                                  {opt.split(' ').map(w => w[0]).join('')}
                                </div>
                                {opt}
                              </div>
                            );
                          })}
                          {/* New client button */}
                          <div style={{
                            borderTop: `1px solid ${COLORS.border}`,
                            padding: '10px 16px',
                            fontSize: 13,
                            fontWeight: 600,
                            color: COLORS.primary,
                            display: 'flex',
                            alignItems: 'center',
                            gap: 6,
                          }}>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                              <path d="M12 5v14M5 12h14" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
                            </svg>
                            Nuevo Cliente
                          </div>
                        </div>
                      )}
                    </div>

                    {/* Fecha del Evento — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 8 }}>
                        Fecha del Evento <span style={{ color: COLORS.error }}>*</span>
                      </label>
                      <div style={{
                        width: '100%',
                        padding: '12px 16px',
                        borderRadius: 12,
                        border: `1px solid ${dateFocused ? COLORS.primary : COLORS.border}`,
                        backgroundColor: COLORS.card,
                        display: 'flex',
                        alignItems: 'center',
                        gap: 10,
                        boxShadow: dateFocused ? `0 0 0 4px ${COLORS.primary}20` : 'none',
                        height: 45,
                      }}>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                          <rect x="3" y="4" width="18" height="18" rx="2" stroke={dateFocused ? COLORS.primary : COLORS.textSecondary} strokeWidth="1.5" />
                          <path d="M16 2v4M8 2v4M3 10h18" stroke={dateFocused ? COLORS.primary : COLORS.textSecondary} strokeWidth="1.5" strokeLinecap="round" />
                        </svg>
                        <span style={{ fontSize: 14, color: frame >= 125 ? COLORS.text : COLORS.textSecondary }}>
                          {frame >= 125 ? eventDate : 'dd/mm/aaaa'}
                        </span>
                      </div>
                    </div>

                    {/* Hora de Inicio — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 8 }}>
                        Hora de Inicio
                      </label>
                      <div style={{
                        width: '100%',
                        padding: '12px 16px',
                        borderRadius: 12,
                        border: `1px solid ${timeFocused ? COLORS.primary : COLORS.border}`,
                        backgroundColor: COLORS.card,
                        display: 'flex',
                        alignItems: 'center',
                        gap: 10,
                        boxShadow: timeFocused ? `0 0 0 4px ${COLORS.primary}20` : 'none',
                        height: 45,
                      }}>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
                          <circle cx="12" cy="12" r="10" stroke={timeFocused ? COLORS.primary : COLORS.textSecondary} strokeWidth="1.5" />
                          <path d="M12 6v6l4 2" stroke={timeFocused ? COLORS.primary : COLORS.textSecondary} strokeWidth="1.5" strokeLinecap="round" />
                        </svg>
                        <span style={{ fontSize: 14, color: frame >= 175 ? COLORS.text : COLORS.textSecondary }}>
                          {frame >= 175 ? eventStartTime : 'HH:MM'}
                        </span>
                      </div>
                    </div>

                    {/* Tipo de Servicio — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Tipo de Servicio"
                        value={eventServiceType}
                        placeholder="Ej: Decoración, Banquete"
                        required
                        typingStartFrame={215}
                        isFocused={serviceTypeFocused}
                      />
                    </div>

                    {/* Número de Personas — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Número de Personas"
                        value={eventNumPeople}
                        placeholder="0"
                        required
                        typingStartFrame={290}
                        isFocused={numPeopleFocused}
                      />
                    </div>

                    {/* Estado — span 3 (auto Cotizado) */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <label style={{ display: 'block', fontSize: 13, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 8 }}>
                        Estado <span style={{ color: COLORS.error }}>*</span>
                      </label>
                      <div style={{
                        width: '100%',
                        padding: '12px 16px',
                        borderRadius: 12,
                        border: `1px solid ${COLORS.border}`,
                        backgroundColor: COLORS.card,
                        display: 'flex',
                        alignItems: 'center',
                        justifyContent: 'space-between',
                        height: 45,
                      }}>
                        <div style={{ display: 'flex', alignItems: 'center', gap: 8 }}>
                          <span style={{
                            width: 8,
                            height: 8,
                            borderRadius: 4,
                            backgroundColor: '#F59E0B',
                          }} />
                          <span style={{ fontSize: 14, color: COLORS.text }}>{statusValue}</span>
                        </div>
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" style={{ color: COLORS.textSecondary }}>
                          <path d="M6 9l6 6 6-6" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                        </svg>
                      </div>
                    </div>

                    {/* Ubicación — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Ubicación del Evento"
                        value={eventLocation}
                        placeholder="Dirección o salón"
                        typingStartFrame={350}
                        isFocused={locationFocused}
                      />
                    </div>
                  </div>

                  {/* Next button */}
                  <div style={{
                    borderTop: `1px solid ${COLORS.border}`,
                    paddingTop: 24,
                    marginTop: 24,
                    display: 'flex',
                    justifyContent: 'flex-end',
                  }}>
                    <MockButton
                      label="Siguiente"
                      variant="primary"
                      pressAtFrame={nextBtnFrame}
                      icon={<ChevronRightIcon />}
                      style={{ padding: '10px 32px', borderRadius: 12, fontSize: 14, fontWeight: 600 }}
                    />
                  </div>
                </div>
              )}

              {/* ═══════════ STEP 2: Productos ═══════════ */}
              {isStep2 && (
                <div style={{
                  opacity: step2Opacity,
                  transform: `translateY(${step2Slide}px)`,
                }}>
                  <div style={{ backgroundColor: COLORS.card, boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: `1px solid ${COLORS.border}`, borderRadius: 24, padding: 36 }}>
                    <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 24 }}>
                      <h2 style={{ fontSize: 17, fontWeight: 700, color: COLORS.text, margin: 0 }}>
                        Productos del Evento
                      </h2>
                      <div style={{
                        display: 'inline-flex',
                        alignItems: 'center',
                        gap: 4,
                        padding: '6px 14px',
                        borderRadius: 10,
                        border: `1px solid ${COLORS.primary}40`,
                        backgroundColor: `${COLORS.primary}08`,
                        color: COLORS.primary,
                        fontSize: 13,
                        fontWeight: 600,
                      }}>
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                          <path d="M12 5v14M5 12h14" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" />
                        </svg>
                        Agregar Producto
                      </div>
                    </div>

                    {/* Product row — table-like header */}
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: '2.5fr 1fr 1.2fr 1fr 1.2fr',
                      gap: 12,
                      padding: '8px 16px',
                      marginBottom: 8,
                    }}>
                      {['Producto', 'Cant.', 'Precio Unit.', 'Desc. Unit.', 'Total'].map((h) => (
                        <div key={h} style={{ fontSize: 11, fontWeight: 500, color: COLORS.textSecondary, textTransform: 'uppercase' as const, letterSpacing: '0.04em' }}>{h}</div>
                      ))}
                    </div>

                    {/* Product row 1 */}
                    <div style={{
                      display: 'grid',
                      gridTemplateColumns: '2.5fr 1fr 1.2fr 1fr 1.2fr',
                      gap: 12,
                      padding: '12px 16px',
                      backgroundColor: COLORS.surfaceAlt,
                      borderRadius: 14,
                      border: `1px solid ${COLORS.border}`,
                      alignItems: 'center',
                    }}>
                      {/* Product select */}
                      <div style={{ position: 'relative' }}>
                        <div style={{
                          width: '100%',
                          padding: '10px 14px',
                          borderRadius: 10,
                          border: `1px solid ${productSelectFocused ? COLORS.primary : COLORS.border}`,
                          backgroundColor: COLORS.card,
                          display: 'flex',
                          alignItems: 'center',
                          justifyContent: 'space-between',
                          boxShadow: productSelectFocused ? `0 0 0 3px ${COLORS.primary}20` : 'none',
                          height: 40,
                        }}>
                          <span style={{ fontSize: 13, color: frame >= 490 ? COLORS.text : COLORS.textSecondary }}>
                            {frame >= 490 ? eventProductName : 'Seleccionar...'}
                          </span>
                          <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                            <path d="M6 9l6 6 6-6" stroke={COLORS.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                          </svg>
                        </div>

                        {/* Product dropdown */}
                        {productSelectFocused && frame >= 460 && frame < 510 && (
                          <div style={{
                            position: 'absolute',
                            top: '100%',
                            left: 0,
                            right: 0,
                            marginTop: 4,
                            backgroundColor: COLORS.card,
                            border: `1px solid ${COLORS.border}`,
                            borderRadius: 10,
                            boxShadow: '0 10px 15px -3px rgba(0,0,0,0.1)',
                            zIndex: 50,
                            overflow: 'hidden',
                          }}>
                            {[
                              { name: 'Pastel 3 Pisos', price: '$2,500' },
                              { name: 'Decoración Completa', price: '$8,000' },
                              { name: 'Banquete 100 pax', price: '$15,000' },
                            ].map((p, idx) => {
                              const isSelected = p.name === eventProductName;
                              const highlight = frame >= 480 && isSelected;
                              return (
                                <div key={p.name} style={{
                                  padding: '8px 14px',
                                  fontSize: 12,
                                  color: COLORS.text,
                                  backgroundColor: highlight ? `${COLORS.primary}12` : 'transparent',
                                  display: 'flex',
                                  alignItems: 'center',
                                  justifyContent: 'space-between',
                                }}>
                                  <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
                                    <div style={{ width: 5, height: 5, borderRadius: 3, backgroundColor: highlight ? COLORS.primary : 'transparent' }} />
                                    {p.name}
                                  </div>
                                  <span style={{ fontSize: 11, color: COLORS.textSecondary }}>{p.price}</span>
                                </div>
                              );
                            })}
                          </div>
                        )}
                      </div>

                      {/* Cantidad */}
                      <div>
                        <div style={{
                          padding: '10px 14px',
                          borderRadius: 10,
                          border: `1px solid ${productQtyFocused ? COLORS.primary : COLORS.border}`,
                          backgroundColor: COLORS.card,
                          fontSize: 13,
                          color: frame >= 530 ? COLORS.text : COLORS.textSecondary,
                          boxShadow: productQtyFocused ? `0 0 0 3px ${COLORS.primary}20` : 'none',
                          height: 40,
                          display: 'flex',
                          alignItems: 'center',
                        }}>
                          {frame >= 530 ? eventProductQty : '0'}
                        </div>
                      </div>

                      {/* Precio Unit (auto) */}
                      <div>
                        <div style={{
                          padding: '10px 14px',
                          borderRadius: 10,
                          backgroundColor: `${COLORS.surfaceAlt}`,
                          border: `1px solid ${COLORS.border}`,
                          fontSize: 13,
                          color: COLORS.textSecondary,
                          height: 40,
                          display: 'flex',
                          alignItems: 'center',
                        }}>
                          {frame >= 500 ? eventProductPrice : '$0.00'}
                        </div>
                      </div>

                      {/* Descuento (leave at 0) */}
                      <div>
                        <div style={{
                          padding: '10px 14px',
                          borderRadius: 10,
                          backgroundColor: COLORS.card,
                          border: `1px solid ${COLORS.border}`,
                          fontSize: 13,
                          color: COLORS.textSecondary,
                          height: 40,
                          display: 'flex',
                          alignItems: 'center',
                        }}>
                          $0.00
                        </div>
                      </div>

                      {/* Total */}
                      <div>
                        <div style={{
                          padding: '10px 14px',
                          borderRadius: 10,
                          backgroundColor: `${COLORS.primary}08`,
                          border: `1px solid ${COLORS.primary}20`,
                          fontSize: 13,
                          fontWeight: 700,
                          color: COLORS.primary,
                          height: 40,
                          display: 'flex',
                          alignItems: 'center',
                        }}>
                          {subtotalVisible ? '$250,000' : '$0.00'}
                        </div>
                      </div>
                    </div>

                    {/* Subtotal bar */}
                    {subtotalVisible && (
                      <div style={{
                        display: 'flex',
                        justifyContent: 'flex-end',
                        alignItems: 'center',
                        gap: 16,
                        marginTop: 16,
                        padding: '12px 20px',
                        backgroundColor: `${COLORS.primary}06`,
                        borderRadius: 12,
                        border: `1px solid ${COLORS.primary}15`,
                      }}>
                        <span style={{ fontSize: 14, fontWeight: 500, color: COLORS.textSecondary }}>Subtotal Productos:</span>
                        <span style={{ fontSize: 18, fontWeight: 800, color: COLORS.primary }}>$250,000.00</span>
                      </div>
                    )}

                    {/* Save button */}
                    <div style={{
                      borderTop: `1px solid ${COLORS.border}`,
                      paddingTop: 24,
                      marginTop: 24,
                      display: 'flex',
                      justifyContent: 'space-between',
                    }}>
                      <MockButton
                        label="Anterior"
                        variant="outline"
                        style={{ padding: '10px 24px', borderRadius: 12, fontSize: 14, fontWeight: 500, color: COLORS.textSecondary }}
                      />
                      <MockButton
                        label="Guardar Evento"
                        variant="primary"
                        pressAtFrame={690}
                        icon={<SaveIcon />}
                        style={{ padding: '10px 32px', borderRadius: 12, fontSize: 14, fontWeight: 600 }}
                      />
                    </div>
                  </div>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>

      {/* Click highlights */}
      {isStep1 && <ClickHighlight x={1720} y={890} clickFrame={nextBtnFrame} />}
      {isStep2 && <ClickHighlight x={1720} y={680} clickFrame={690} />}
    </AbsoluteFill>
  );
};
