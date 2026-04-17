import React from "react";
import { Link2Off, AlertCircle } from "lucide-react";

interface Props {
  reason: "not-found" | "disabled";
}

/**
 * Shown when the `/client/:token` URL points to a token that either
 * never existed (`not-found`) or was revoked/expired by the organizer
 * (`disabled`). Copy nudges the client to contact the organizer rather
 * than the Solennix team — the relationship here is with the organizer.
 */
export const ClientPortalUnavailable: React.FC<Props> = ({ reason }) => {
  const heading =
    reason === "not-found" ? "Enlace no válido" : "Enlace no disponible";
  const description =
    reason === "not-found"
      ? "No encontramos información con este enlace. Revisá el link o pedí al organizador que te lo reenvíe."
      : "El organizador del evento deshabilitó este enlace o ya expiró. Contactalos para que te compartan uno nuevo.";

  return (
    <div className="min-h-screen bg-bg flex items-center justify-center p-4">
      <div className="max-w-md w-full text-center space-y-6">
        <div className="mx-auto w-16 h-16 rounded-2xl bg-warning/10 flex items-center justify-center">
          <Link2Off className="h-8 w-8 text-warning" />
        </div>

        <div className="space-y-2">
          <h1 className="text-2xl font-bold text-text tracking-tight">
            {heading}
          </h1>
          <p className="text-text-secondary text-sm leading-relaxed">
            {description}
          </p>
        </div>

        <div className="bg-surface-alt rounded-xl border border-border p-4 flex items-start gap-3">
          <AlertCircle className="h-5 w-5 text-text-tertiary shrink-0 mt-0.5" />
          <p className="text-xs text-text-secondary text-left">
            Los enlaces del portal del cliente son privados por evento — el
            organizador puede rotarlos en cualquier momento por seguridad.
          </p>
        </div>
      </div>
    </div>
  );
};
