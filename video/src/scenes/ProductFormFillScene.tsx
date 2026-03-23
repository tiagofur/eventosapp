import React from 'react';
import { AbsoluteFill, useCurrentFrame, interpolate, useVideoConfig } from 'remotion';
import { loadFont } from '@remotion/google-fonts/Inter';
import { COLORS, PREMIUM_GRADIENT } from '../constants';
import { ProductTutorialProps } from '../schema';
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

const CameraIcon: React.FC = () => (
  <svg width="32" height="32" viewBox="0 0 24 24" fill="none">
    <path d="M23 19a2 2 0 01-2 2H3a2 2 0 01-2-2V8a2 2 0 012-2h4l2-3h6l2 3h4a2 2 0 012 2z" stroke={COLORS.textTertiary} strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    <circle cx="12" cy="13" r="4" stroke={COLORS.textTertiary} strokeWidth="1.5" />
  </svg>
);

const SaveIcon: React.FC = () => (
  <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
    <path d="M19 21H5a2 2 0 01-2-2V5a2 2 0 012-2h11l5 5v11a2 2 0 01-2 2z" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    <polyline points="17,21 17,13 7,13 7,21" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
    <polyline points="7,3 7,8 15,8" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" />
  </svg>
);

export const ProductFormFillScene: React.FC<ProductTutorialProps> = ({
  productName,
  productCategory,
  productPrice,
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

  // Focus states — each field gets focus in sequence
  const nameIsFocused = frame >= 40 && frame < 130;
  const categoryIsFocused = frame >= 130 && frame < 220;
  const priceIsFocused = frame >= 220 && frame < 310;
  // Toggle animation
  const toggleFrame = 330;
  const toggleActive = frame >= toggleFrame;

  // Ingredients section reveal
  const ingredientsSectionFrame = 350;
  const ingredientsSectionOpacity = interpolate(frame, [ingredientsSectionFrame, ingredientsSectionFrame + 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const ingredientsSectionSlide = interpolate(frame, [ingredientsSectionFrame, ingredientsSectionFrame + 20], [15, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Ingredient row fill
  const ingredientSelectFocused = frame >= 370 && frame < 420;
  const ingredientQtyFocused = frame >= 420 && frame < 460;

  return (
    <AbsoluteFill style={{ backgroundColor: COLORS.bg, fontFamily }}>
      <div style={{ display: 'flex', height: '100%' }}>
        <MockSidebar activeItem="Productos" />

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
              <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 32 }}>
                <div style={{ padding: 8, borderRadius: 9999, display: 'flex', alignItems: 'center', justifyContent: 'center', color: COLORS.textSecondary }}>
                  <ArrowLeftIcon />
                </div>
                <h1 style={{ fontSize: 24, fontWeight: 700, color: COLORS.text, margin: 0 }}>
                  Nuevo Producto
                </h1>
              </div>

              {/* Form card */}
              <div style={{ backgroundColor: COLORS.card, boxShadow: '0 1px 3px rgba(0,0,0,0.05)', border: `1px solid ${COLORS.border}`, borderRadius: 24, padding: 40 }}>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 24 }}>
                  {/* Photo upload */}
                  <div style={{ display: 'flex', justifyContent: 'center' }}>
                    <div style={{
                      width: 96,
                      height: 96,
                      borderRadius: 20,
                      backgroundColor: COLORS.surfaceAlt,
                      border: `2px solid ${COLORS.border}`,
                      display: 'flex',
                      alignItems: 'center',
                      justifyContent: 'center',
                    }}>
                      <CameraIcon />
                    </div>
                  </div>

                  {/* Form grid */}
                  <div style={{ display: 'grid', gridTemplateColumns: 'repeat(6, 1fr)', gap: 24 }}>
                    {/* Nombre — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Nombre del Producto"
                        value={productName}
                        placeholder="Ej: Pastel de 3 pisos"
                        required
                        typingStartFrame={50}
                        isFocused={nameIsFocused}
                      />
                    </div>

                    {/* Categoría — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Categoría"
                        value={productCategory}
                        placeholder="Ej: Pastelería"
                        required
                        typingStartFrame={140}
                        isFocused={categoryIsFocused}
                      />
                    </div>

                    {/* Precio Base — span 3 */}
                    <div style={{ gridColumn: 'span 3' }}>
                      <MockFormInput
                        label="Precio Base ($)"
                        value={productPrice}
                        placeholder="0.00"
                        required
                        typingStartFrame={230}
                        isFocused={priceIsFocused}
                      />
                    </div>

                    {/* Activo toggle — span 3 */}
                    <div style={{ gridColumn: 'span 3', display: 'flex', alignItems: 'flex-end' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: 12, paddingBottom: 4 }}>
                        {/* Toggle switch */}
                        <div
                          style={{
                            width: 44,
                            height: 24,
                            borderRadius: 12,
                            backgroundColor: toggleActive ? COLORS.success : COLORS.border,
                            position: 'relative',
                            cursor: 'pointer',
                            transition: 'background-color 0.3s',
                          }}
                        >
                          <div style={{
                            width: 20,
                            height: 20,
                            borderRadius: 10,
                            backgroundColor: COLORS.white,
                            position: 'absolute',
                            top: 2,
                            left: toggleActive ? 22 : 2,
                            boxShadow: '0 1px 3px rgba(0,0,0,0.15)',
                            transition: 'left 0.3s',
                          }} />
                        </div>
                        <span style={{ fontSize: 14, fontWeight: 500, color: COLORS.text }}>
                          Producto Activo
                        </span>
                        {toggleActive && (
                          <span style={{
                            fontSize: 11,
                            fontWeight: 600,
                            color: COLORS.success,
                            backgroundColor: `${COLORS.success}15`,
                            padding: '2px 8px',
                            borderRadius: 6,
                          }}>
                            Visible en catálogo
                          </span>
                        )}
                      </div>
                    </div>
                  </div>

                  {/* ── Composición / Insumos Section ── */}
                  <div style={{
                    opacity: ingredientsSectionOpacity,
                    transform: `translateY(${ingredientsSectionSlide}px)`,
                  }}>
                    <div style={{
                      borderTop: `1px solid ${COLORS.border}`,
                      paddingTop: 24,
                    }}>
                      <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 16 }}>
                        <div>
                          <h3 style={{ fontSize: 16, fontWeight: 700, color: COLORS.text, margin: 0 }}>
                            Composición / Insumos
                          </h3>
                          <p style={{ fontSize: 12, color: COLORS.textSecondary, margin: '4px 0 0 0' }}>
                            Ingredientes que generan costo por unidad
                          </p>
                        </div>
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
                          Agregar Insumo
                        </div>
                      </div>

                      {/* Ingredient row */}
                      <div style={{
                        display: 'grid',
                        gridTemplateColumns: '2fr 1fr 1fr auto',
                        gap: 12,
                        alignItems: 'end',
                        padding: '16px',
                        backgroundColor: COLORS.surfaceAlt,
                        borderRadius: 16,
                        border: `1px solid ${COLORS.border}`,
                      }}>
                        {/* Insumo select */}
                        <div style={{ position: 'relative' }}>
                          <label style={{ display: 'block', fontSize: 12, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 6 }}>Insumo</label>
                          <div style={{
                            width: '100%',
                            padding: '10px 14px',
                            borderRadius: 10,
                            border: `1px solid ${ingredientSelectFocused ? COLORS.primary : COLORS.border}`,
                            backgroundColor: COLORS.card,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'space-between',
                            boxShadow: ingredientSelectFocused ? `0 0 0 3px ${COLORS.primary}20` : 'none',
                            height: 40,
                          }}>
                            <span style={{ fontSize: 13, color: frame >= 400 ? COLORS.text : COLORS.textSecondary }}>
                              {frame >= 400 ? 'Harina (kg)' : 'Seleccionar insumo...'}
                            </span>
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none">
                              <path d="M6 9l6 6 6-6" stroke={COLORS.textSecondary} strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" />
                            </svg>
                          </div>

                          {/* Dropdown */}
                          {ingredientSelectFocused && frame >= 380 && frame < 420 && (
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
                              {['Harina (kg)', 'Azúcar (kg)', 'Mantequilla (kg)', 'Huevos (pza)'].map((opt, idx) => (
                                <div key={opt} style={{
                                  padding: '8px 14px',
                                  fontSize: 12,
                                  color: COLORS.text,
                                  backgroundColor: idx === 0 && frame >= 395 ? `${COLORS.primary}12` : 'transparent',
                                  display: 'flex',
                                  alignItems: 'center',
                                  gap: 6,
                                }}>
                                  <div style={{ width: 5, height: 5, borderRadius: 3, backgroundColor: idx === 0 && frame >= 395 ? COLORS.primary : 'transparent' }} />
                                  {opt}
                                </div>
                              ))}
                            </div>
                          )}
                        </div>

                        {/* Cantidad */}
                        <div>
                          <MockFormInput
                            label="Cantidad"
                            value={frame >= 430 ? '0.500' : ''}
                            placeholder="0.000"
                            typingStartFrame={425}
                            isFocused={ingredientQtyFocused}
                          />
                        </div>

                        {/* Costo Estimado (auto-calculated) */}
                        <div>
                          <label style={{ display: 'block', fontSize: 12, fontWeight: 500, color: COLORS.textSecondary, marginBottom: 6 }}>Costo Est.</label>
                          <div style={{
                            padding: '10px 14px',
                            borderRadius: 10,
                            backgroundColor: `${COLORS.primary}08`,
                            border: `1px solid ${COLORS.primary}20`,
                            fontSize: 13,
                            fontWeight: 600,
                            color: COLORS.primary,
                            height: 40,
                            display: 'flex',
                            alignItems: 'center',
                          }}>
                            {frame >= 440 ? '$12.50' : '$0.00'}
                          </div>
                        </div>

                        {/* Llevar al evento checkbox */}
                        <div style={{ display: 'flex', alignItems: 'center', height: 40, gap: 6 }}>
                          <div style={{
                            width: 18,
                            height: 18,
                            borderRadius: 4,
                            border: `2px solid ${frame >= 450 ? COLORS.primary : COLORS.border}`,
                            backgroundColor: frame >= 450 ? COLORS.primary : 'transparent',
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                          }}>
                            {frame >= 450 && (
                              <svg width="12" height="12" viewBox="0 0 24 24" fill="none">
                                <path d="M20 6L9 17l-5-5" stroke={COLORS.white} strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" />
                              </svg>
                            )}
                          </div>
                          <span style={{ fontSize: 11, color: COLORS.textSecondary, whiteSpace: 'nowrap' }}>Llevar</span>
                        </div>
                      </div>
                    </div>
                  </div>

                  {/* Footer */}
                  <div style={{
                    borderTop: `1px solid ${COLORS.border}`,
                    paddingTop: 24,
                    display: 'flex',
                    justifyContent: 'flex-end',
                    gap: 12,
                  }}>
                    <MockButton
                      label="Cancelar"
                      variant="outline"
                      style={{ padding: '10px 24px', borderRadius: 12, fontSize: 14, fontWeight: 500, color: COLORS.textSecondary }}
                    />
                    <MockButton
                      label="Guardar Producto"
                      variant="primary"
                      pressAtFrame={470}
                      icon={<SaveIcon />}
                      style={{ padding: '10px 32px', borderRadius: 12, fontSize: 14, fontWeight: 500 }}
                    />
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Click on toggle */}
      <ClickHighlight x={620} y={565} clickFrame={330} />
      {/* Click on save */}
      <ClickHighlight x={1750} y={820} clickFrame={470} />
    </AbsoluteFill>
  );
};
