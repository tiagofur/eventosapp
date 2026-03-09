import React from "react";
import { useTheme } from "../hooks/useTheme";

interface LogoProps {
  className?: string;
  size?: number;
  showText?: boolean;
  forceLight?: boolean;
}

export const Logo: React.FC<LogoProps> = ({
  className = "",
  size = 32,
  showText = true,
  forceLight = false,
}) => {
  const { isDark } = useTheme();

  // User request:
  // Modo claro (isDark false) -> Fondo Navy
  // Modo oscuro (isDark true) -> Fondo Beige
  const logoSrc = isDark ? "/icon-beige.svg" : "/icon-navy.svg";

  return (
    <div className={`flex items-center gap-3 ${className}`}>
      <img
        src={logoSrc}
        alt="Solennix Logo"
        width={size}
        height={size}
        className="shrink-0 shadow-sm"
        style={{ width: size, height: size }}
      />
      {showText && (
        <span
          className={`text-2xl font-semibold tracking-wide ${forceLight ? "text-white" : "text-primary"}`}
          style={{
            fontFamily:
              "'Cinzel', 'Playfair Display', Didot, 'Bodoni MT', Georgia, serif",
          }}
        >
          Solennix
        </span>
      )}
    </div>
  );
};
