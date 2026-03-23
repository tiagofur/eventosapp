import { useCurrentFrame, useVideoConfig } from 'remotion';

type TypewriterTextProps = {
  text: string;
  startFrame?: number;
  charFrames?: number;
  showCursor?: boolean;
  style?: React.CSSProperties;
};

export const TypewriterText: React.FC<TypewriterTextProps> = ({
  text,
  startFrame = 0,
  charFrames = 2,
  showCursor = true,
  style = {},
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const localFrame = Math.max(0, frame - startFrame);
  const charsVisible = Math.min(
    text.length,
    Math.floor(localFrame / charFrames),
  );
  const displayText = text.slice(0, charsVisible);

  // Blinking cursor: visible for 0.5s, hidden for 0.5s
  const cursorOpacity = showCursor
    ? Math.floor((localFrame / (fps * 0.5)) % 2) === 0
      ? 1
      : 0
    : 0;

  // Hide cursor after all chars are typed + 1 second
  const allTyped = charsVisible >= text.length;
  const framesAfterTyped = localFrame - text.length * charFrames;
  const hideCursor = allTyped && framesAfterTyped > fps;

  return (
    <span style={style}>
      {displayText}
      {!hideCursor && (
        <span style={{ opacity: cursorOpacity, fontWeight: 'normal' }}>|</span>
      )}
    </span>
  );
};
