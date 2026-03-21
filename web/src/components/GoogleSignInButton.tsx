import React, { useEffect, useRef, useState } from "react";
import { api } from "../lib/api";
import { useAuth } from "../contexts/AuthContext";
import { useNavigate } from "react-router-dom";

const GOOGLE_CLIENT_ID = import.meta.env.VITE_GOOGLE_CLIENT_ID || "";

interface Props {
  onError?: (message: string) => void;
}

export const GoogleSignInButton: React.FC<Props> = ({ onError }) => {
  const buttonRef = useRef<HTMLDivElement>(null);
  const navigate = useNavigate();
  const { checkAuth } = useAuth();
  const [isLoading, setIsLoading] = useState(false);

  useEffect(() => {
    if (!GOOGLE_CLIENT_ID || !buttonRef.current) return;

    // Wait for GSI script to load
    const initializeGsi = () => {
      if (typeof google === "undefined" || !google.accounts?.id) {
        // Retry after script loads
        const timer = setTimeout(initializeGsi, 200);
        return () => clearTimeout(timer);
      }

      google.accounts.id.initialize({
        client_id: GOOGLE_CLIENT_ID,
        callback: handleCredentialResponse,
      });

      if (buttonRef.current) {
        google.accounts.id.renderButton(buttonRef.current, {
          type: "standard",
          theme: "outline",
          size: "large",
          text: "continue_with",
          shape: "rectangular",
          width: buttonRef.current.offsetWidth,
          logo_alignment: "center",
        });
      }
    };

    initializeGsi();
  }, []);

  const handleCredentialResponse = async (
    response: google.accounts.id.CredentialResponse
  ) => {
    setIsLoading(true);
    try {
      const res = await api.post<{
        tokens: { access_token: string; refresh_token: string };
      }>("/auth/google", { id_token: response.credential });

      if (!res.tokens?.access_token) {
        throw new Error("Respuesta del servidor inválida");
      }

      localStorage.setItem("auth_token", res.tokens.access_token);
      if (res.tokens.refresh_token) {
        localStorage.setItem("refresh_token", res.tokens.refresh_token);
      }

      await checkAuth();
      navigate("/dashboard");
    } catch (err: any) {
      onError?.(err.message || "Error al iniciar sesión con Google");
    } finally {
      setIsLoading(false);
    }
  };

  if (!GOOGLE_CLIENT_ID) {
    return null; // Don't render if not configured
  }

  return (
    <div className="w-full">
      {isLoading ? (
        <div className="w-full flex items-center justify-center py-3.5 rounded-xl border border-border bg-card">
          <svg
            className="animate-spin h-5 w-5 text-text-secondary"
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
        </div>
      ) : (
        <div ref={buttonRef} className="w-full [&>div]:!w-full" />
      )}
    </div>
  );
};
