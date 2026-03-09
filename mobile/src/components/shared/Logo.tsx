import React from "react";
import { SvgXml } from "react-native-svg";
import { useTheme } from "../../hooks/useTheme";

interface LogoProps {
  size?: number;
  style?: any;
}

const navyLogoXml = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <defs>
    <linearGradient id="bgI" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#1B2A4A"/>
      <stop offset="100%" stop-color="#0F1A2E"/>
    </linearGradient>
    <linearGradient id="gI" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#D4B87A"/>
      <stop offset="45%" stop-color="#C4A265"/>
      <stop offset="100%" stop-color="#B8965A"/>
    </linearGradient>
    <radialGradient id="glI" cx="50%" cy="38%">
      <stop offset="0%" stop-color="#D4B87A" stop-opacity="0.07"/>
      <stop offset="70%" stop-color="#D4B87A" stop-opacity="0.02"/>
      <stop offset="100%" stop-color="#D4B87A" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="200" height="200" rx="40" fill="url(#bgI)"/>
  <circle cx="100" cy="78" r="65" fill="url(#glI)"/>
  <path d="M66,34 Q58,65 66,88 Q78,116 100,122 Q122,116 134,88 Q142,65 134,34 Q100,42 66,34 Z" fill="url(#gI)"/>
  <path d="M76,38 Q72,58 76,82 Q85,104 100,112 L100,42 Q82,44 76,38 Z" fill="rgba(255,255,255,0.10)"/>
  <ellipse cx="100" cy="124" rx="6" ry="3" fill="url(#gI)"/>
  <path d="M96,124 L96,150 Q96,156 84,159 L72,161 L72,164 A30,8 0 0,0 128,164 L128,161 L116,159 Q104,156 104,150 L104,124 Z" fill="url(#gI)"/>
</svg>`;

const beigeLogoXml = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 200 200">
  <defs>
    <linearGradient id="gIL" x1="0" y1="0" x2="0" y2="1">
      <stop offset="0%" stop-color="#C4A265"/>
      <stop offset="45%" stop-color="#B8965A"/>
      <stop offset="100%" stop-color="#A6874E"/>
    </linearGradient>
    <radialGradient id="glIL" cx="50%" cy="38%">
      <stop offset="0%" stop-color="#C4A265" stop-opacity="0.05"/>
      <stop offset="70%" stop-color="#C4A265" stop-opacity="0.02"/>
      <stop offset="100%" stop-color="#C4A265" stop-opacity="0"/>
    </radialGradient>
  </defs>
  <rect width="200" height="200" rx="40" fill="#F5F0E8"/>
  <circle cx="100" cy="78" r="65" fill="url(#glIL)"/>
  <path d="M66,34 Q58,65 66,88 Q78,116 100,122 Q122,116 134,88 Q142,65 134,34 Q100,42 66,34 Z" fill="url(#gIL)"/>
  <path d="M76,38 Q72,58 76,82 Q85,104 100,112 L100,42 Q82,44 76,38 Z" fill="rgba(255,255,255,0.15)"/>
  <ellipse cx="100" cy="124" rx="6" ry="3" fill="url(#gIL)"/>
  <path d="M96,124 L96,150 Q96,156 84,159 L72,161 L72,164 A30,8 0 0,0 128,164 L128,161 L116,159 Q104,156 104,150 L104,124 Z" fill="url(#gIL)"/>
</svg>`;

export const Logo: React.FC<LogoProps> = ({ size = 120, style }) => {
  const { isDark } = useTheme();

  // User request:
  // Modo claro (isDark false) -> Fondo Navy
  // Modo oscuro (isDark true) -> Fondo Beige
  const logoXml = isDark ? beigeLogoXml : navyLogoXml;

  return <SvgXml xml={logoXml} width={size} height={size} style={style} />;
};
