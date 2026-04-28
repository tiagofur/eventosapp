import React, { useState, useCallback } from "react";
import { api } from "../lib/api";
import { useAuth } from "@/hooks/useAuth";
import { useNavigate } from "react-router-dom";

const APPLE_CLIENT_ID = import.meta.env.VITE_APPLE_CLIENT_ID || "";

interface Props {
  onError?: (message: string) => void;
}

export const AppleSignInButton: React.FC<Props> = ({ onError }) => {
  const navigate = useNavigate();
  const { checkAuth } = useAuth();
  const [isLoading, setIsLoading] = useState(false);
  const [privateRelayNotice, setPrivateRelayNotice] = useState(false);

  const handleAppleSignIn = useCallback(async () => {
    if (isLoading) return;

    setIsLoading(true);
    setPrivateRelayNotice(false);

    try {
      // Ensure Apple JS SDK is loaded
      if (typeof AppleID === "undefined" || !AppleID.auth) {
        onError?.("Apple Sign-In no está disponible. Intenta de nuevo.");
        return;
      }

      // Initialize Apple ID auth
      AppleID.auth.init({
        clientId: APPLE_CLIENT_ID,
        scope: "name email",
        redirectURI: window.location.origin,
        usePopup: true,
      });

      // Trigger the Apple sign-in popup
      const response = await AppleID.auth.signIn();

      const idToken = response.authorization.id_token;
      if (!idToken) {
        onError?.("No se recibió el token de Apple. Intenta de nuevo.");
        return;
      }

      // Build full_name from user info (Apple only sends name on FIRST sign-in)
      let fullName: string | undefined;
      if (response.user?.name) {
        const { firstName, lastName } = response.user.name;
        fullName = [firstName, lastName].filter(Boolean).join(" ") || undefined;
      }

      // Backend sets httpOnly cookies on successful Apple auth — no need to store tokens client-side
      const result = await api.post<{ email_is_private_relay?: boolean }>(
        "/auth/apple",
        {
          identity_token: idToken,
          full_name: fullName,
        }
      );

      // Show notice if email is a private relay
      if (result.email_is_private_relay) {
        setPrivateRelayNotice(true);
      }

      await checkAuth();
      navigate("/dashboard");
    } catch (err: any) {
      // Apple cancellation: user closed the popup — silently ignore
      if (
        err?.error === "popup_closed_by_user" ||
        err?.error === "user_cancelled_authorize"
      ) {
        return;
      }
      onError?.(err.message || "Error al iniciar sesión con Apple");
    } finally {
      setIsLoading(false);
    }
  }, [isLoading, checkAuth, navigate, onError]);

  if (!APPLE_CLIENT_ID) {
    return null; // Don't render if not configured
  }

  return (
    <div className="w-full">
      <button
        type="button"
        onClick={handleAppleSignIn}
        disabled={isLoading}
        className="w-full flex items-center justify-center gap-3 py-3.5 rounded-xl border border-border bg-black text-white text-sm font-medium transition-all hover:bg-gray-900 disabled:opacity-60 disabled:cursor-not-allowed"
        aria-label={
          isLoading ? "Iniciando sesión con Apple..." : "Continuar con Apple"
        }
      >
        {isLoading ? (
          <svg
            className="animate-spin h-5 w-5 text-white"
            viewBox="0 0 24 24"
            fill="none"
          >
            <circle
              className="opacity-25"
              cx="12"
              cy="12"
              r="10"
              stroke="currentColor"
              strokeWidth="4"
            />
            <path
              className="opacity-75"
              fill="currentColor"
              d="M4 12a8 8 0 018-8v8z"
            />
          </svg>
        ) : (
          <>
            {/* Apple logo SVG */}
            <svg
              className="h-5 w-5"
              viewBox="0 0 24 24"
              fill="currentColor"
              xmlns="http://www.w3.org/2000/svg"
            >
              <path d="M17.05 20.28c-.98.95-2.05.88-3.08.4-1.09-.5-2.08-.52-3.23 0-1.44.64-2.2.46-3.06-.4C3.79 16.17 4.36 9.53 8.77 9.28c1.25.07 2.12.72 2.88.77.98-.2 1.92-.75 2.96-.69 1.26.1 2.2.6 2.82 1.5-2.5 1.52-1.9 4.88.32 5.82-.52 1.36-1.19 2.71-2.7 3.6ZM12.03 9.2c-.15-2.34 1.84-4.28 4.05-4.48.3 2.64-2.37 4.64-4.05 4.48Z" />
            </svg>
            Continuar con Apple
          </>
        )}
      </button>

      {/* Private relay email notice */}
      {privateRelayNotice && (
        <p className="mt-2 text-xs text-text-tertiary text-center">
          Tu email de Apple es privado. Algunas notificaciones podrían no
          llegarte directamente.
        </p>
      )}
    </div>
  );
};
