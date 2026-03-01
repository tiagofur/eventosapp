import { NativeModules } from "react-native";

const SENTRY_DSN = process.env.EXPO_PUBLIC_SENTRY_DSN || "";

// Sentry crashes in Expo Go — only load in production standalone builds
let Sentry: any = null;
if (!__DEV__ && SENTRY_DSN && NativeModules.RNSentry) {
  try {
    Sentry = require("@sentry/react-native");
  } catch {
    // no-op
  }
}

export function initSentry(): void {
  if (!SENTRY_DSN || !Sentry) return;

  Sentry.init({
    dsn: SENTRY_DSN,
    debug: __DEV__,
    tracesSampleRate: __DEV__ ? 1.0 : 0.2,
    environment: __DEV__ ? "development" : "production",
  });
}

export function captureException(error: unknown, context?: string): void {
  if (!SENTRY_DSN || !Sentry) return;

  if (context) {
    Sentry.withScope((scope: any) => {
      scope.setTag("context", context);
      Sentry.captureException(error);
    });
  } else {
    Sentry.captureException(error);
  }
}

export const wrapWithSentry = (component: any) => {
  if (SENTRY_DSN && Sentry) return Sentry.wrap(component);
  return component;
};
