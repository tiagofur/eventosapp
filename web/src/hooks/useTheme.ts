import { useThemeContext } from '../contexts/ThemeContext';

export function useTheme() {
  const { theme, toggleTheme, isDark } = useThemeContext();

  return {
    theme,
    toggleTheme,
    isDark
  };
}