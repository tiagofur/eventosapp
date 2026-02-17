import React, { useEffect, useMemo, useState } from 'react';
import { Link, useSearchParams } from 'react-router-dom';
import { Search, Loader2 } from 'lucide-react';
import { format, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';
import Empty from '../components/Empty';
import { logError } from '../lib/errorHandler';
import { SearchResults, searchService } from '../services/searchService';

const STATUS_LABELS: Record<string, string> = {
  quoted: 'Cotizado',
  confirmed: 'Confirmado',
  completed: 'Completado',
  cancelled: 'Cancelado',
};

const formatEventDate = (value: string) => {
  try {
    return format(parseISO(value), "d MMM yyyy", { locale: es });
  } catch {
    return value;
  }
};

export const SearchPage: React.FC = () => {
  const [searchParams] = useSearchParams();
  const query = (searchParams.get('q') || '').trim();
  const [results, setResults] = useState<SearchResults>({
    clients: [],
    events: [],
    products: [],
    inventory: [],
  });
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let isMounted = true;

    const runSearch = async () => {
      if (!query) {
        setResults({ clients: [], events: [], products: [], inventory: [] });
        return;
      }

      setLoading(true);
      setError(null);

      try {
        const data = await searchService.searchAll(query);
        if (isMounted) setResults(data);
      } catch (err) {
        logError('Error running global search', err);
        if (isMounted) {
          setError('No pudimos completar la busqueda. Intenta de nuevo.');
        }
      } finally {
        if (isMounted) setLoading(false);
      }
    };

    runSearch();

    return () => {
      isMounted = false;
    };
  }, [query]);

  const totalResults = useMemo(() => {
    return (
      results.clients.length +
      results.events.length +
      results.products.length +
      results.inventory.length
    );
  }, [results]);

  if (!query) {
    return (
      <Empty
        title="Busca en toda tu operacion"
        description="Escribe un termino en la barra superior para encontrar clientes, eventos, productos e inventario."
      />
    );
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12 text-gray-500 dark:text-gray-300">
        <Loader2 className="h-5 w-5 animate-spin mr-2" />
        Buscando resultados...
      </div>
    );
  }

  if (error) {
    return (
      <div className="bg-red-50 dark:bg-red-900/20 border border-red-200 dark:border-red-800 rounded-lg p-4 text-sm text-red-700 dark:text-red-200">
        {error}
      </div>
    );
  }

  if (!totalResults) {
    return (
      <Empty
        title="Sin resultados"
        description={`No encontramos coincidencias para "${query}".`}
      />
    );
  }

  return (
    <div className="space-y-8">
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 dark:text-white">Resultados</h1>
          <p className="text-sm text-gray-500 dark:text-gray-400">
            {totalResults} resultado{totalResults === 1 ? '' : 's'} para "{query}"
          </p>
        </div>
        <div className="flex items-center text-sm text-gray-500 dark:text-gray-400">
          <Search className="h-4 w-4 mr-2" />
          Busqueda global
        </div>
      </div>

      {results.clients.length > 0 && (
        <section className="space-y-3">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Clientes</h2>
          <div className="grid gap-3 md:grid-cols-2">
            {results.clients.map((client) => (
              <Link
                key={client.id}
                to={client.href}
                className="group rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4 shadow-sm hover:shadow-md transition"
              >
                <p className="text-sm font-semibold text-gray-900 dark:text-white group-hover:text-brand-orange">
                  {client.title}
                </p>
                {client.subtitle && (
                  <p className="text-xs text-gray-500 dark:text-gray-400">{client.subtitle}</p>
                )}
                {client.meta && (
                  <p className="text-xs text-gray-400 dark:text-gray-500">{client.meta}</p>
                )}
              </Link>
            ))}
          </div>
        </section>
      )}

      {results.events.length > 0 && (
        <section className="space-y-3">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Eventos</h2>
          <div className="grid gap-3 md:grid-cols-2">
            {results.events.map((event) => (
              <Link
                key={event.id}
                to={event.href}
                className="group rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4 shadow-sm hover:shadow-md transition"
              >
                <p className="text-sm font-semibold text-gray-900 dark:text-white group-hover:text-brand-orange">
                  {event.title}
                </p>
                {event.subtitle && (
                  <p className="text-xs text-gray-500 dark:text-gray-400">{event.subtitle}</p>
                )}
                <p className="text-xs text-gray-400 dark:text-gray-500">
                  {event.meta ? formatEventDate(event.meta) : ''}
                  {event.meta && event.status ? ' - ' : ''}
                  {event.status ? STATUS_LABELS[event.status] : ''}
                </p>
              </Link>
            ))}
          </div>
        </section>
      )}

      {results.products.length > 0 && (
        <section className="space-y-3">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Productos</h2>
          <div className="grid gap-3 md:grid-cols-2">
            {results.products.map((product) => (
              <Link
                key={product.id}
                to={product.href}
                className="group rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4 shadow-sm hover:shadow-md transition"
              >
                <p className="text-sm font-semibold text-gray-900 dark:text-white group-hover:text-brand-orange">
                  {product.title}
                </p>
                {product.subtitle && (
                  <p className="text-xs text-gray-500 dark:text-gray-400">{product.subtitle}</p>
                )}
                {product.meta && (
                  <p className="text-xs text-gray-400 dark:text-gray-500">{product.meta}</p>
                )}
              </Link>
            ))}
          </div>
        </section>
      )}

      {results.inventory.length > 0 && (
        <section className="space-y-3">
          <h2 className="text-lg font-semibold text-gray-900 dark:text-white">Inventario</h2>
          <div className="grid gap-3 md:grid-cols-2">
            {results.inventory.map((item) => (
              <Link
                key={item.id}
                to={item.href}
                className="group rounded-lg border border-gray-200 dark:border-gray-700 bg-white dark:bg-gray-800 p-4 shadow-sm hover:shadow-md transition"
              >
                <p className="text-sm font-semibold text-gray-900 dark:text-white group-hover:text-brand-orange">
                  {item.title}
                </p>
                {item.subtitle && (
                  <p className="text-xs text-gray-500 dark:text-gray-400">{item.subtitle}</p>
                )}
                {item.meta && (
                  <p className="text-xs text-gray-400 dark:text-gray-500">{item.meta}</p>
                )}
              </Link>
            ))}
          </div>
        </section>
      )}
    </div>
  );
};
