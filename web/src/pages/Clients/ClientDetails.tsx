import React, { useEffect, useState } from "react";
import { useParams, Link, useNavigate } from "react-router-dom";
import { clientService } from "../../services/clientService";
import { eventService } from "../../services/eventService";
import { Client, Event } from "../../types/entities";
import {
  ArrowLeft,
  Edit,
  Calendar,
  DollarSign,
  MapPin,
  Phone,
  Mail,
  FileText,
  Clock,
  Trash2,
} from "lucide-react";
import { format } from "date-fns";
import { es } from "date-fns/locale";
import { logError } from "../../lib/errorHandler";
import { useToast } from "../../hooks/useToast";
import { ConfirmDialog } from "../../components/ConfirmDialog";
import clsx from "clsx";

export const ClientDetails: React.FC = () => {
  const { id } = useParams();
  const navigate = useNavigate();
  const [client, setClient] = useState<Client | null>(null);
  const [events, setEvents] = useState<Event[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [confirmDeleteOpen, setConfirmDeleteOpen] = useState(false);
  const { addToast } = useToast();

  useEffect(() => {
    if (id) {
      loadClient(id);
    }
  }, [id]);

  const loadClient = async (clientId: string) => {
    try {
      setLoading(true);
      const [clientData, eventsData] = await Promise.all([
        clientService.getById(clientId),
        eventService.getByClientId(clientId),
      ]);
      setClient(clientData);
      setEvents(eventsData || []);
    } catch (err) {
      logError("Error fetching client details", err);
      setError("Error al cargar los datos del cliente.");
    } finally {
      setLoading(false);
    }
  };

  const handleDeleteClient = async () => {
    if (!id) return;
    try {
      await clientService.delete(id);
      addToast("Cliente eliminado correctamente.", "success");
      navigate("/clients");
    } catch (error) {
      logError("Error deleting client", error);
      addToast("Error al eliminar el cliente.", "error");
    } finally {
      setConfirmDeleteOpen(false);
    }
  };

  if (loading) {
    return (
      <div
        className="flex justify-center items-center h-64 p-8 text-text-secondary"
        role="status"
        aria-live="polite"
      >
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-brand-orange mr-3" aria-hidden="true"></div>
        Cargando detalles...
      </div>
    );
  }

  if (error) {
    return (
      <div className="text-center p-8">
        <p className="text-red-600 dark:text-red-400" role="alert">
          {error}
        </p>
        <button
          type="button"
          onClick={() => navigate("/clients")}
          className="mt-4 text-brand-orange hover:underline"
          aria-label="Volver a la lista de clientes"
        >
          Volver a clientes
        </button>
      </div>
    );
  }

  if (!client) {
    return (
      <div className="text-center p-8 text-text">
        Cliente no encontrado
      </div>
    );
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center">
          <button
            type="button"
            onClick={() => navigate("/clients")}
            className="mr-4 p-2 rounded-full hover:bg-surface-alt text-text-secondary transition-colors"
            aria-label="Volver a la lista de clientes"
          >
            <ArrowLeft className="h-5 w-5" aria-hidden="true" />
          </button>
          <h1 className="text-2xl font-bold text-text">
            {client.name}
          </h1>
        </div>
        <div className="flex items-center space-x-2">
          <Link
            to={`/clients/${client.id}/edit`}
            className="inline-flex items-center px-4 py-2 border border-border rounded-xl shadow-sm text-sm font-medium text-text-secondary bg-card hover:bg-surface-alt transition-colors"
            aria-label="Editar información del cliente"
          >
            <Edit className="h-5 w-5 mr-2" aria-hidden="true" />
            Editar
          </Link>
          <button
            type="button"
            onClick={() => setConfirmDeleteOpen(true)}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-xl text-white bg-red-600 hover:bg-red-700 shadow-sm transition-colors"
            aria-label="Eliminar cliente permanentemente"
          >
            <Trash2 className="h-5 w-5 mr-2" aria-hidden="true" />
            Eliminar
          </button>
        </div>
      </div>

      <div className="bg-card shadow-sm overflow-hidden rounded-3xl border border-border">
        <div className="px-4 py-5 sm:px-6">
          <h3 className="text-lg leading-6 font-medium text-text">
            Información del Cliente
          </h3>
          <p className="mt-1 max-w-2xl text-sm text-text-secondary">
            Detalles personales y de contacto.
          </p>
        </div>
        <div className="border-t border-border px-4 py-5 sm:px-6">
          <dl className="grid grid-cols-1 gap-x-4 gap-y-8 sm:grid-cols-2">
            <div className="sm:col-span-1">
              <dt className="text-sm font-medium text-text-secondary flex items-center">
                <Phone className="h-4 w-4 mr-2" aria-hidden="true" /> Teléfono
              </dt>
              <dd className="mt-1 text-sm text-text">
                {client.phone}
              </dd>
            </div>
            <div className="sm:col-span-1">
              <dt className="text-sm font-medium text-text-secondary flex items-center">
                <Mail className="h-4 w-4 mr-2" aria-hidden="true" /> Email
              </dt>
              <dd className="mt-1 text-sm text-text">
                {client.email || "No registrado"}
              </dd>
            </div>
            <div className="sm:col-span-1">
              <dt className="text-sm font-medium text-text-secondary flex items-center">
                <MapPin className="h-4 w-4 mr-2" aria-hidden="true" /> Dirección
              </dt>
              <dd className="mt-1 text-sm text-text">
                {client.address || "No registrada"}
              </dd>
            </div>
            <div className="sm:col-span-1">
              <dt className="text-sm font-medium text-text-secondary flex items-center">
                <DollarSign className="h-4 w-4 mr-2" aria-hidden="true" /> Total
                Gastado
              </dt>
              <dd className="mt-1 text-sm text-text font-semibold">
                ${(client.total_spent ?? 0).toFixed(2)}
              </dd>
            </div>
            <div className="sm:col-span-2">
              <dt className="text-sm font-medium text-text-secondary flex items-center">
                <FileText className="h-4 w-4 mr-2" aria-hidden="true" /> Notas
              </dt>
              <dd className="mt-1 text-sm text-text">
                {client.notes || "Sin notas adicionales."}
              </dd>
            </div>
          </dl>
        </div>
      </div>

      <div className="bg-card shadow-sm overflow-hidden rounded-3xl border border-border">
        <div className="px-4 py-5 sm:px-6 flex justify-between items-center">
          <div>
            <h3 className="text-lg leading-6 font-medium text-text">
              Historial de Eventos
            </h3>
            <p className="mt-1 max-w-2xl text-sm text-text-secondary">
              Lista de eventos pasados y futuros.
            </p>
          </div>
          <Link
            to={`/events/new?clientId=${client.id}`}
            className="inline-flex items-center px-4 py-2 border border-transparent text-sm font-medium rounded-xl text-white bg-brand-orange hover:bg-orange-600 shadow-sm transition-colors"
          >
            Nuevo Evento
          </Link>
        </div>
        <div className="border-t border-border">
          {events.length === 0 ? (
            <div className="px-4 py-5 sm:p-6 text-center text-text-secondary">
              <Calendar
                className="mx-auto h-12 w-12 text-text-secondary"
                aria-hidden="true"
              />
              <p className="mt-2">
                No hay eventos registrados para este cliente.
              </p>
            </div>
          ) : (
            <ul className="divide-y divide-border">
              {events.map((event) => (
                <li key={event.id}>
                  <Link
                    to={`/events/${event.id}/summary`}
                    className="block hover:bg-surface-alt/50 transition-colors"
                  >
                    <div className="px-4 py-4 sm:px-6">
                      <div className="flex items-center justify-between">
                        <p className="text-sm font-medium text-brand-orange truncate">
                          {event.service_type}
                        </p>
                        <div className="ml-2 shrink-0 flex">
                          <p
                            className={clsx(
                              "px-2.5 py-0.5 inline-flex text-xs leading-5 font-semibold rounded-full border",
                              event.status === "confirmed"
                                ? "bg-brand-green/10 text-brand-green border-brand-green/20"
                                : event.status === "completed"
                                  ? "bg-blue-500/10 text-blue-500 border-blue-500/20"
                                  : event.status === "cancelled"
                                    ? "bg-red-500/10 text-red-500 border-red-500/20"
                                    : "bg-yellow-500/10 text-yellow-500 border-yellow-500/20"
                            )}
                          >
                            {event.status === "quoted"
                              ? "Cotizado"
                              : event.status === "confirmed"
                                ? "Confirmado"
                                : event.status === "completed"
                                  ? "Completado"
                                  : "Cancelado"}
                          </p>
                        </div>
                      </div>
                      <div className="mt-2 sm:flex sm:justify-between">
                        <div className="sm:flex">
                          <p className="flex items-center text-sm text-text-secondary">
                            <Calendar
                              className="shrink-0 mr-1.5 h-5 w-5 text-text-secondary"
                              aria-hidden="true"
                            />
                            {format(
                              new Date(event.event_date),
                              "d 'de' MMMM, yyyy",
                              { locale: es },
                            )}
                          </p>
                          <p className="mt-2 flex items-center text-sm text-text-secondary sm:mt-0 sm:ml-6">
                            <Clock
                              className="shrink-0 mr-1.5 h-5 w-5 text-text-secondary"
                              aria-hidden="true"
                            />
                            {event.num_people} personas
                          </p>
                        </div>
                        <div className="mt-2 flex items-center text-sm text-text-secondary sm:mt-0">
                          <DollarSign
                            className="shrink-0 mr-1.5 h-5 w-5 text-text-secondary"
                            aria-hidden="true"
                          />
                          {(event.total_amount ?? 0).toFixed(2)}
                        </div>
                      </div>
                    </div>
                  </Link>
                </li>
              ))}
            </ul>
          )}
        </div>
      </div>
      <ConfirmDialog
        open={confirmDeleteOpen}
        title="Eliminar Cliente"
        description="¿Estás seguro de que deseas eliminar este cliente? Esta acción no se puede deshacer y se perderán todos los datos asociados (aunque los eventos existentes se mantendrán, ya no estarán vinculados a este cliente)."
        confirmText="Eliminar permanentemente"
        cancelText="Cancelar"
        onConfirm={handleDeleteClient}
        onCancel={() => setConfirmDeleteOpen(false)}
      />
    </div>
  );
};
