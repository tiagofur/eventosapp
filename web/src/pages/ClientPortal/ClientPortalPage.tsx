import React, { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router-dom";
import {
  Calendar,
  Clock,
  MapPin,
  Users,
  Wallet,
  Loader2,
  CheckCircle2,
  CircleDashed,
  AlertCircle,
} from "lucide-react";
import { ClientPortalUnavailable } from "./components/ClientPortalUnavailable";

// ─────────────────────────────────────────────────────────────────────────
// Types — mirror backend `PublicEventView` from
// handlers/event_public_link_handler.go. We intentionally do NOT import
// the generated OpenAPI types because the public-portal endpoint is not
// yet documented in openapi.yaml; we'll migrate once it lands there.
// ─────────────────────────────────────────────────────────────────────────

interface PortalEvent {
  id: string;
  service_type: string;
  event_date: string; // yyyy-MM-dd
  start_time?: string | null;
  end_time?: string | null;
  location?: string | null;
  city?: string | null;
  num_people: number;
  status: string;
}

interface PortalOrganizer {
  business_name?: string;
  logo_url?: string;
  brand_color?: string;
}

interface PortalClient {
  name: string;
}

interface PortalPayment {
  total: number;
  paid: number;
  remaining: number;
  currency: string;
}

interface PortalData {
  event: PortalEvent;
  organizer: PortalOrganizer;
  client: PortalClient;
  payment: PortalPayment;
}

const API_BASE = import.meta.env.VITE_API_URL || "http://localhost:8080/api";

// Parse `yyyy-MM-dd` as a LOCAL date (new Date("2026-08-15") would be
// interpreted UTC and drift back one day in negative-offset timezones).
function parseLocalDate(dateStr: string): Date {
  const [y, m, d] = dateStr.split("-").map(Number);
  return new Date(y, (m || 1) - 1, d || 1);
}

function formatLongDate(dateStr: string): string {
  try {
    const d = parseLocalDate(dateStr);
    return d.toLocaleDateString("es-MX", {
      weekday: "long",
      day: "numeric",
      month: "long",
      year: "numeric",
    });
  } catch {
    return dateStr;
  }
}

function formatCurrency(value: number, currency: string): string {
  try {
    return value.toLocaleString("es-MX", {
      style: "currency",
      currency,
      maximumFractionDigits: 0,
    });
  } catch {
    return `${currency} ${value}`;
  }
}

function statusLabel(status: string): { label: string; tone: "ok" | "warn" | "info" | "done" } {
  switch (status) {
    case "confirmed":
      return { label: "Confirmado", tone: "ok" };
    case "quoted":
      return { label: "Cotizado", tone: "warn" };
    case "completed":
      return { label: "Realizado", tone: "done" };
    case "cancelled":
      return { label: "Cancelado", tone: "info" };
    default:
      return { label: status, tone: "info" };
  }
}

function daysUntil(dateStr: string): number {
  const target = parseLocalDate(dateStr);
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  target.setHours(0, 0, 0, 0);
  return Math.round((target.getTime() - today.getTime()) / 86400000);
}

// ─────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────

export const ClientPortalPage: React.FC = () => {
  const { token } = useParams<{ token: string }>();
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState<PortalData | null>(null);
  const [error, setError] = useState<"not-found" | "disabled" | null>(null);

  useEffect(() => {
    if (!token) {
      setError("not-found");
      setLoading(false);
      return;
    }
    const controller = new AbortController();

    const fetchPortal = async () => {
      try {
        const res = await fetch(`${API_BASE}/public/events/${token}`, {
          signal: controller.signal,
        });
        if (res.status === 410) {
          setError("disabled");
          return;
        }
        if (!res.ok) {
          setError("not-found");
          return;
        }
        const json: PortalData = await res.json();
        setData(json);
      } catch (err) {
        if ((err as { name?: string })?.name === "AbortError") return;
        setError("not-found");
      } finally {
        if (!controller.signal.aborted) setLoading(false);
      }
    };

    fetchPortal();
    return () => controller.abort();
  }, [token]);

  // Derive a safe brand color — any client-provided string could be
  // invalid, so we validate and fall back to the Solennix gold.
  const brandColor = useMemo(() => {
    const c = data?.organizer.brand_color;
    if (c && /^#[0-9A-Fa-f]{3,8}$/.test(c)) return c;
    return "#C4A265";
  }, [data?.organizer.brand_color]);

  if (loading) {
    return (
      <div className="min-h-screen bg-bg flex items-center justify-center">
        <div
          className="flex items-center gap-3 text-text-secondary"
          role="status"
          aria-live="polite"
        >
          <Loader2 className="h-5 w-5 animate-spin" aria-hidden="true" />
          <span>Cargando el portal…</span>
        </div>
      </div>
    );
  }

  if (error) {
    return <ClientPortalUnavailable reason={error} />;
  }

  if (!data) {
    return <ClientPortalUnavailable reason="not-found" />;
  }

  const { event, organizer, client, payment } = data;
  const days = daysUntil(event.event_date);
  const countdownLabel =
    days > 0
      ? `${days} ${days === 1 ? "día" : "días"} restantes`
      : days === 0
        ? "¡Es hoy!"
        : `Hace ${Math.abs(days)} ${Math.abs(days) === 1 ? "día" : "días"}`;

  const paidPct =
    payment.total > 0 ? Math.min(100, Math.round((payment.paid / payment.total) * 100)) : 0;

  const st = statusLabel(event.status);
  const statusToneClass =
    st.tone === "ok"
      ? "bg-success/10 text-success"
      : st.tone === "warn"
        ? "bg-warning/10 text-warning"
        : st.tone === "done"
          ? "bg-accent/10 text-accent"
          : "bg-surface-alt text-text-secondary";

  return (
    <div className="min-h-screen bg-bg">
      {/* Header strip — uses organizer brand color as an accent bar */}
      <div
        className="h-2 w-full"
        style={{ backgroundColor: brandColor }}
        aria-hidden="true"
      />

      <div className="max-w-3xl mx-auto px-4 sm:px-6 py-10 sm:py-14 space-y-8">
        {/* Organizer identity */}
        <header className="flex flex-col items-center text-center space-y-3">
          {organizer.logo_url ? (
            <img
              src={organizer.logo_url}
              alt={organizer.business_name || "Logo del organizador"}
              className="h-14 w-14 rounded-full object-cover border border-border bg-surface"
            />
          ) : (
            <div
              className="h-14 w-14 rounded-full flex items-center justify-center text-white font-bold text-lg"
              style={{ backgroundColor: brandColor }}
              aria-hidden="true"
            >
              {(organizer.business_name || "S").charAt(0).toUpperCase()}
            </div>
          )}
          <div>
            <p className="text-xs uppercase tracking-widest text-text-tertiary mb-1">
              Organizado por
            </p>
            <h1 className="text-xl sm:text-2xl font-bold text-text">
              {organizer.business_name || "Tu organizador de eventos"}
            </h1>
          </div>
        </header>

        {/* Hero: event type + countdown */}
        <section className="bg-card rounded-2xl border border-border shadow-sm p-6 sm:p-8 text-center">
          <p className="text-sm text-text-secondary mb-2">
            {client.name ? `Hola ${client.name.split(" ")[0]},` : "Hola,"} aquí está el
            detalle de tu evento:
          </p>
          <h2 className="text-3xl sm:text-4xl font-extrabold text-text tracking-tight mb-3">
            {event.service_type}
          </h2>
          <p className="text-base sm:text-lg text-text-secondary capitalize">
            {formatLongDate(event.event_date)}
          </p>
          <div
            className="mt-4 inline-flex items-center gap-2 px-4 py-2 rounded-full text-sm font-semibold"
            style={{ backgroundColor: `${brandColor}22`, color: brandColor }}
          >
            <Calendar className="h-4 w-4" aria-hidden="true" />
            {countdownLabel}
          </div>
          <div className="mt-3">
            <span
              className={`inline-flex items-center gap-1.5 px-3 py-1 rounded-full text-xs font-semibold ${statusToneClass}`}
            >
              {st.tone === "ok" ? (
                <CheckCircle2 className="h-3.5 w-3.5" aria-hidden="true" />
              ) : (
                <CircleDashed className="h-3.5 w-3.5" aria-hidden="true" />
              )}
              {st.label}
            </span>
          </div>
        </section>

        {/* Details grid */}
        <section className="grid sm:grid-cols-2 gap-4">
          {(event.start_time || event.end_time) && (
            <DetailCard icon={<Clock className="h-4 w-4" />} label="Horario">
              {[event.start_time, event.end_time].filter(Boolean).join(" — ") || "—"}
            </DetailCard>
          )}
          {(event.location || event.city) && (
            <DetailCard icon={<MapPin className="h-4 w-4" />} label="Ubicación">
              {[event.location, event.city].filter(Boolean).join(", ")}
            </DetailCard>
          )}
          <DetailCard icon={<Users className="h-4 w-4" />} label="Invitados">
            {event.num_people} personas
          </DetailCard>
        </section>

        {/* Payment summary */}
        <section className="bg-card rounded-2xl border border-border shadow-sm p-6 sm:p-8">
          <div className="flex items-center gap-2 mb-4">
            <Wallet className="h-5 w-5 text-text-secondary" aria-hidden="true" />
            <h3 className="text-lg font-semibold text-text">Estado de pagos</h3>
          </div>

          <div className="flex flex-col sm:flex-row sm:items-end sm:justify-between gap-3 mb-4">
            <div>
              <p className="text-xs uppercase tracking-widest text-text-tertiary mb-1">
                Pagado
              </p>
              <p className="text-2xl sm:text-3xl font-bold text-text">
                {formatCurrency(payment.paid, payment.currency)}
              </p>
            </div>
            <div className="text-right">
              <p className="text-xs uppercase tracking-widest text-text-tertiary mb-1">
                Total del evento
              </p>
              <p className="text-base sm:text-lg text-text-secondary">
                {formatCurrency(payment.total, payment.currency)}
              </p>
            </div>
          </div>

          <div
            className="h-3 w-full rounded-full bg-surface-alt overflow-hidden"
            role="progressbar"
            aria-valuenow={paidPct}
            aria-valuemin={0}
            aria-valuemax={100}
            aria-label={`${paidPct}% pagado`}
          >
            <div
              className="h-full rounded-full transition-all duration-500"
              style={{
                width: `${paidPct}%`,
                backgroundColor: brandColor,
              }}
            />
          </div>
          <p className="mt-2 text-xs text-text-tertiary">
            {paidPct}% pagado · Pendiente{" "}
            <span className="font-semibold text-text-secondary">
              {formatCurrency(payment.remaining, payment.currency)}
            </span>
          </p>

          <div className="mt-5 bg-surface-alt rounded-xl border border-border p-3 flex items-start gap-2">
            <AlertCircle
              className="h-4 w-4 text-text-tertiary shrink-0 mt-0.5"
              aria-hidden="true"
            />
            <p className="text-xs text-text-secondary leading-relaxed">
              Los pagos se actualizan al momento en que el organizador los
              registra. Cualquier duda, contactalos directamente.
            </p>
          </div>
        </section>

        <footer className="text-center text-xs text-text-tertiary pt-4">
          Portal privado del cliente · powered by{" "}
          <span className="font-semibold">Solennix</span>
        </footer>
      </div>
    </div>
  );
};

// Small internal helper — keeps the details grid DRY and consistent.
const DetailCard: React.FC<{
  icon: React.ReactNode;
  label: string;
  children: React.ReactNode;
}> = ({ icon, label, children }) => (
  <div className="bg-card rounded-xl border border-border p-4">
    <div className="flex items-center gap-1.5 text-text-tertiary text-xs uppercase tracking-widest mb-1">
      {icon}
      <span>{label}</span>
    </div>
    <p className="text-sm text-text font-medium capitalize">{children}</p>
  </div>
);
