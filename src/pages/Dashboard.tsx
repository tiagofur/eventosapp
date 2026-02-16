import React, { useEffect, useState } from "react";
import { useAuth } from "../contexts/AuthContext";
import { eventService } from "../services/eventService";
import { Database } from "../types/supabase";
import { startOfMonth, endOfMonth, format } from "date-fns";
import { es } from "date-fns/locale";
import { Link } from "react-router-dom";
import { Calendar, DollarSign, Users, Clock, RefreshCw, AlertTriangle } from "lucide-react";

type Event = Database["public"]["Tables"]["events"]["Row"] & {
  clients?: { name: string } | null;
};

export const Dashboard: React.FC = () => {
  const { profile } = useAuth();
  const [eventsThisMonth, setEventsThisMonth] = useState<Event[]>([]);
  const [upcomingEvents, setUpcomingEvents] = useState<Event[]>([]);
  const [incomeThisMonth, setIncomeThisMonth] = useState(0);
  
  const [loadingMonth, setLoadingMonth] = useState(true);
  const [loadingUpcoming, setLoadingUpcoming] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    loadDashboardData();
  }, []);

  const loadDashboardData = () => {
    setError(null);
    setLoadingMonth(true);
    setLoadingUpcoming(true);
    
    const today = new Date();
    const start = startOfMonth(today).toISOString();
    const end = endOfMonth(today).toISOString();

    // 1. Load Month Events
    eventService.getByDateRange(start, end)
      .then(data => {
        setEventsThisMonth(data || []);
        
        // Calculate confirmed income
        const income = (data || [])
          .filter((e) => e.status !== "cancelled")
          .reduce((sum, event) => sum + (event.total_amount || 0), 0);
        setIncomeThisMonth(income);
      })
      .catch(err => {
        console.error("Error loading month events:", err);
        // Don't set error here to avoid blocking the whole UI if just this fails
      })
      .finally(() => setLoadingMonth(false));

    // 2. Load Upcoming Events
    eventService.getUpcoming(5)
      .then(data => {
        setUpcomingEvents(data || []);
      })
      .catch(err => {
        console.error("Error loading upcoming events:", err);
        setError("Error de conexión o permisos. Verifica tu sesión o intenta más tarde.");
      })
      .finally(() => setLoadingUpcoming(false));
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
            <h1 className="text-2xl font-bold text-gray-900">
            Hola, {profile?.name || "Usuario"}
            </h1>
            <p className="text-sm text-gray-500 first-letter:uppercase">
            {format(new Date(), "EEEE, d 'de' MMMM 'de' yyyy", { locale: es })}
            </p>
        </div>
        <div className="flex space-x-2">
          <button 
            onClick={loadDashboardData}
            className="p-2 text-gray-400 hover:text-brand-orange transition-colors"
            title="Recargar datos"
          >
            <RefreshCw className={`h-5 w-5 ${loadingMonth || loadingUpcoming ? 'animate-spin' : ''}`} />
          </button>
        </div>
      </div>

      {error && (
        <div className="bg-red-50 border-l-4 border-red-400 p-4">
            <div className="flex justify-between items-center">
                <div className="flex">
                    <div className="flex-shrink-0">
                        <AlertTriangle className="h-5 w-5 text-red-400" />
                    </div>
                    <div className="ml-3">
                        <p className="text-sm text-red-700">{error}</p>
                    </div>
                </div>
                <span className="text-sm font-medium text-red-700">
                  Intenta recargar los datos.
                </span>
            </div>
        </div>
      )}

      <div className="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {/* Card Eventos del Mes */}
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-10 w-10 bg-brand-orange/20 rounded-full flex items-center justify-center text-brand-orange">
                  <Calendar className="h-6 w-6" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Eventos este Mes
                  </dt>
                  <dd>
                    <div className="text-lg font-medium text-gray-900">
                        {loadingMonth ? "..." : eventsThisMonth.length}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-gray-50 px-5 py-3">
            <div className="text-sm">
              <Link
                to="/calendar"
                className="font-medium text-brand-orange hover:text-orange-600"
              >
                Ver calendario
              </Link>
            </div>
          </div>
        </div>

        {/* Card Ingresos */}
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-10 w-10 bg-green-100 rounded-full flex items-center justify-center text-green-600">
                  <DollarSign className="h-6 w-6" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Ingresos Estimados (Mes)
                  </dt>
                  <dd>
                    <div className="text-lg font-medium text-gray-900">
                      {loadingMonth ? "..." : (
                          `$${incomeThisMonth.toLocaleString("es-MX", { minimumFractionDigits: 2 })}`
                      )}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-gray-50 px-5 py-3">
            <div className="text-sm">
              <span className="text-gray-500">
                Basado en eventos no cancelados
              </span>
            </div>
          </div>
        </div>

        {/* Card Próximo Evento */}
        <div className="bg-white overflow-hidden shadow rounded-lg">
          <div className="p-5">
            <div className="flex items-center">
              <div className="flex-shrink-0">
                <div className="h-10 w-10 bg-blue-100 rounded-full flex items-center justify-center text-blue-600">
                  <Users className="h-6 w-6" />
                </div>
              </div>
              <div className="ml-5 w-0 flex-1">
                <dl>
                  <dt className="text-sm font-medium text-gray-500 truncate">
                    Próximo Evento
                  </dt>
                  <dd>
                    <div className="text-sm font-medium text-gray-900 truncate">
                        {loadingUpcoming ? "..." : (
                            upcomingEvents.length > 0 ? (
                                <>
                                {format(
                                    new Date(upcomingEvents[0].event_date),
                                    "d MMM",
                                    { locale: es },
                                )}{" "}
                                - {upcomingEvents[0].clients?.name}
                                </>
                            ) : (
                                "Sin eventos próximos"
                            )
                        )}
                    </div>
                  </dd>
                </dl>
              </div>
            </div>
          </div>
          <div className="bg-gray-50 px-5 py-3">
            <div className="text-sm">
              <Link
                to="/events/new"
                className="font-medium text-blue-600 hover:text-blue-500"
              >
                + Crear Nuevo Evento
              </Link>
            </div>
          </div>
        </div>
      </div>

      <div className="bg-white shadow rounded-lg p-6">
        <h3 className="text-lg leading-6 font-medium text-gray-900 mb-4">
          Próximos Eventos
        </h3>
        <div className="flow-root">
            {loadingUpcoming ? (
               <div className="flex justify-center py-4">
                 <Clock className="h-6 w-6 animate-spin text-gray-400" />
               </div>
            ) : upcomingEvents.length > 0 ? (
                <ul className="-my-5 divide-y divide-gray-200">
                    {upcomingEvents.map((event) => (
                        <li key={event.id} className="py-4">
                            <div className="flex items-center space-x-4">
                                <div className="flex-shrink-0">
                                    <div className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center">
                                        <Clock className="h-4 w-4 text-gray-500" />
                                    </div>
                                </div>
                                <div className="flex-1 min-w-0">
                                    <p className="text-sm font-medium text-gray-900 truncate">
                                        {event.clients?.name}
                                    </p>
                                    <p className="text-sm text-gray-500 truncate">
                                        {event.service_type} - {event.num_people} pax
                                    </p>
                                </div>
                                <div className="inline-flex items-center text-sm font-semibold text-gray-900">
                                    {format(new Date(event.event_date), "d 'de' MMMM", { locale: es })}
                                </div>
                                <div>
                                    <Link 
                                        to={`/events/${event.id}/edit`}
                                        className="inline-flex items-center shadow-sm px-2.5 py-0.5 border border-gray-300 text-sm leading-5 font-medium rounded-full text-gray-700 bg-white hover:bg-gray-50"
                                    >
                                        Ver
                                    </Link>
                                </div>
                            </div>
                        </li>
                    ))}
                </ul>
            ) : (
                <div className="text-center py-4">
                    <p className="text-gray-500 text-sm">No hay eventos próximos agendados.</p>
                </div>
            )}
        </div>
      </div>
    </div>
  );
};
