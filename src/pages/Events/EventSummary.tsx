import React, { useEffect, useState } from "react";
import { useParams, useNavigate } from "react-router-dom";
import { eventService } from "../../services/eventService";
import { productService } from "../../services/productService";
import {
  ArrowLeft,
  Printer,
  FileText,
  ShoppingCart,
  FileCheck,
} from "lucide-react";
import { useAuth } from "../../contexts/AuthContext";

type ViewMode = "summary" | "ingredients" | "contract";

export const EventSummary: React.FC = () => {
  const { id } = useParams<{ id: string }>();
  const navigate = useNavigate();
  const { user, profile } = useAuth();
  const [event, setEvent] = useState<any>(null);
  const [products, setProducts] = useState<any[]>([]);
  const [extras, setExtras] = useState<any[]>([]);
  const [ingredients, setIngredients] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [viewMode, setViewMode] = useState<ViewMode>("summary");

  useEffect(() => {
    if (id) {
      loadData(id);
    }
  }, [id]);

  const loadData = async (eventId: string) => {
    try {
      setLoading(true);
      const [eventData, productsData, extrasData] = await Promise.all([
        eventService.getById(eventId),
        eventService.getProducts(eventId),
        eventService.getExtras(eventId),
      ]);

      setEvent(eventData);
      setProducts(productsData || []);
      setExtras(extrasData || []);

      // Calculate aggregated ingredients
      const aggregatedIngredients: any = {};
      const productQuantities = new Map<string, number>();
      (productsData || []).forEach((p: any) => {
        productQuantities.set(p.product_id, p.quantity || 0);
      });

      const productIds = Array.from(productQuantities.keys());
      const prodIngredients = await productService.getIngredientsForProducts(productIds);

      prodIngredients.forEach((ing: any) => {
        const key = ing.inventory_id;
        const quantity = productQuantities.get(ing.product_id) || 0;
        if (!aggregatedIngredients[key]) {
          aggregatedIngredients[key] = {
            name: ing.inventory?.ingredient_name,
            unit: ing.inventory?.unit,
            quantity: 0,
            cost: 0,
          };
        }
        aggregatedIngredients[key].quantity += ing.quantity_required * quantity;
        aggregatedIngredients[key].cost +=
          ing.quantity_required * quantity * (ing.inventory?.unit_cost || 0);
      });

      setIngredients(Object.values(aggregatedIngredients));
    } catch (error) {
      console.error("Error loading summary:", error);
    } finally {
      setLoading(false);
    }
  };

  if (loading) return <div>Cargando resumen...</div>;
  if (!event) return <div>Evento no encontrado</div>;

  const totalProductCost = ingredients.reduce((sum, i) => sum + i.cost, 0);
  const totalExtrasCost = extras.reduce((sum, e) => sum + e.cost, 0);
  const totalCost = totalProductCost + totalExtrasCost;
  const totalRevenue = event.total_amount || 0;
  const taxAmount = event.tax_amount || 0;
  const revenueExTax = totalRevenue - taxAmount;
  const profit = revenueExTax - totalCost;
  const margin = revenueExTax > 0 ? (profit / revenueExTax) * 100 : 0;

  const handlePrint = () => {
    window.print();
  };

  const timeRange = event.start_time || event.end_time
    ? `${event.start_time || ""}${event.start_time && event.end_time ? " - " : ""}${event.end_time || ""}`
    : "";

  return (
    <div className="space-y-6 max-w-4xl mx-auto p-8 bg-white shadow-lg my-8 print:shadow-none print:my-0 print:max-w-none print:p-0">
      <div className="flex flex-col md:flex-row justify-between items-center gap-4 print:hidden mb-6">
        <div className="flex items-center gap-4">
          <button
            onClick={() => navigate(`/events/${id}/edit`)}
            className="flex items-center text-gray-600 hover:text-gray-900"
          >
            <ArrowLeft className="h-4 w-4 mr-2" /> Volver
          </button>

          <div className="flex bg-gray-100 rounded-lg p-1">
            <button
              onClick={() => setViewMode("summary")}
              className={`px-3 py-1.5 rounded-md text-sm font-medium flex items-center ${
                viewMode === "summary"
                  ? "bg-white text-brand-orange shadow-sm"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              <FileText className="h-4 w-4 mr-2" />
              Resumen
            </button>
            <button
              onClick={() => setViewMode("ingredients")}
              className={`px-3 py-1.5 rounded-md text-sm font-medium flex items-center ${
                viewMode === "ingredients"
                  ? "bg-white text-brand-orange shadow-sm"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              <ShoppingCart className="h-4 w-4 mr-2" />
              Compras
            </button>
            <button
              onClick={() => setViewMode("contract")}
              className={`px-3 py-1.5 rounded-md text-sm font-medium flex items-center ${
                viewMode === "contract"
                  ? "bg-white text-brand-orange shadow-sm"
                  : "text-gray-500 hover:text-gray-700"
              }`}
            >
              <FileCheck className="h-4 w-4 mr-2" />
              Contrato
            </button>
          </div>
        </div>

        <button
          onClick={handlePrint}
          className="flex items-center px-4 py-2 bg-brand-orange text-white rounded hover:bg-orange-600 shadow-sm"
        >
          <Printer className="h-4 w-4 mr-2" />
          Imprimir{" "}
          {viewMode === "summary"
            ? "Resumen"
            : viewMode === "ingredients"
              ? "Lista"
              : "Contrato"}
        </button>
      </div>

      {viewMode === "summary" && (
        <div className="space-y-8">
          <div className="border-b pb-6">
            <h1 className="text-3xl font-bold text-gray-900">
              {event.clients?.name} - {event.service_type}
            </h1>
            <div className="grid grid-cols-2 gap-4 mt-4 text-sm text-gray-600">
              <div>
                <p>
                  <span className="font-semibold">Fecha:</span>{" "}
                  {new Date(event.event_date).toLocaleDateString()}
                </p>
                {timeRange && (
                  <p>
                    <span className="font-semibold">Horario:</span> {timeRange}
                  </p>
                )}
                <p>
                  <span className="font-semibold">Personas:</span>{" "}
                  {event.num_people}
                </p>
                {event.location && (
                  <p>
                    <span className="font-semibold">Ubicación:</span>{" "}
                    {event.location}
                  </p>
                )}
              </div>
              <div className="text-right">
                <p>
                  <span className="font-semibold">Estado:</span> {event.status}
                </p>
                <p>
                  <span className="font-semibold">Cliente:</span>{" "}
                  {event.clients?.name}
                </p>
                <p>
                  <span className="font-semibold">Factura:</span>{" "}
                  {event.requires_invoice ? `Sí (IVA ${event.tax_rate || 16}%)` : "No"}
                </p>
                <p>
                  <span className="font-semibold">Teléfono:</span>{" "}
                  {event.clients?.phone}
                </p>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
            <div>
              <h2 className="text-lg font-bold mb-4 border-b pb-2">
                Productos
              </h2>
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-gray-500">
                    <th className="pb-2">Producto</th>
                    <th className="pb-2 text-right">Cant.</th>
                    <th className="pb-2 text-right">Precio Unit.</th>
                    <th className="pb-2 text-right">Total</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {products.map((p, i) => (
                    <tr key={i}>
                      <td className="py-2">{p.products?.name}</td>
                      <td className="py-2 text-right">{p.quantity}</td>
                      <td className="py-2 text-right">
                        ${p.unit_price.toFixed(2)}
                      </td>
                      <td className="py-2 text-right">
                        ${((p.unit_price - ((p as any).discount || 0)) * p.quantity).toFixed(2)}
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>

            <div>
              <h2 className="text-lg font-bold mb-4 border-b pb-2">Extras</h2>
              <table className="w-full text-sm">
                <thead>
                  <tr className="text-left text-gray-500">
                    <th className="pb-2">Descripción</th>
                    <th className="pb-2 text-right">Precio</th>
                  </tr>
                </thead>
                <tbody className="divide-y">
                  {extras.map((e, i) => (
                    <tr key={i}>
                      <td className="py-2">{e.description}</td>
                      <td className="py-2 text-right">${e.price.toFixed(2)}</td>
                    </tr>
                  ))}
                  {extras.length === 0 && (
                    <tr>
                      <td colSpan={2} className="py-2 text-gray-500 italic">
                        Sin extras
                      </td>
                    </tr>
                  )}
                </tbody>
              </table>
            </div>
          </div>

          <div className="mt-8 border-t pt-6 print:hidden">
            <h2 className="text-lg font-bold mb-4">
              Resumen Financiero (Interno)
            </h2>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 bg-gray-100 p-4 rounded">
              <div>
                <p className="text-xs text-gray-500">
                  {event.requires_invoice ? "Ingresos Totales (con IVA)" : "Ingresos Totales"}
                </p>
                <p className="text-xl font-bold text-gray-900">
                  ${totalRevenue.toFixed(2)}
                </p>
              </div>
              {event.requires_invoice && (
                <div>
                  <p className="text-xs text-gray-500">IVA</p>
                  <p className="text-xl font-bold text-gray-900">
                    ${taxAmount.toFixed(2)}
                  </p>
                </div>
              )}
              <div>
                <p className="text-xs text-gray-500">Costos Totales</p>
                <p className="text-xl font-bold text-red-600">
                  ${totalCost.toFixed(2)}
                </p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Utilidad</p>
                <p className="text-xl font-bold text-green-600">
                  ${profit.toFixed(2)}
                </p>
              </div>
              <div>
                <p className="text-xs text-gray-500">Margen</p>
                <p className="text-xl font-bold text-blue-600">
                  {margin.toFixed(1)}%
                </p>
              </div>
            </div>
          </div>
        </div>
      )}

      {viewMode === "ingredients" && (
        <div className="space-y-6">
          <div className="border-b pb-4">
            <h1 className="text-2xl font-bold text-gray-900">
              Lista de Compras e Ingredientes
            </h1>
            <p className="text-gray-600 mt-2">
              Evento: {event.service_type} -{" "}
              {new Date(event.event_date).toLocaleDateString()}
            </p>
          </div>

          <div className="bg-white rounded">
            <table className="w-full text-sm">
              <thead>
                <tr className="text-left text-gray-500 border-b">
                  <th className="pb-3 pt-2">Ingrediente</th>
                  <th className="pb-3 pt-2 text-right">Cantidad Necesaria</th>
                  <th className="pb-3 pt-2 text-right">Unidad</th>
                </tr>
              </thead>
              <tbody className="divide-y">
                {ingredients.map((ing, i) => (
                  <tr key={i}>
                    <td className="py-3 font-medium text-gray-900">
                      {ing.name}
                    </td>
                    <td className="py-3 text-right text-gray-900 font-bold">
                      {ing.quantity.toFixed(2)}
                    </td>
                    <td className="py-3 text-right text-gray-500">
                      {ing.unit}
                    </td>
                  </tr>
                ))}
                {ingredients.length === 0 && (
                  <tr>
                    <td
                      colSpan={3}
                      className="py-4 text-center text-gray-500 italic"
                    >
                      No hay ingredientes calculados para los productos
                      seleccionados.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {viewMode === "contract" && (
        <div className="space-y-8 font-serif text-gray-800 leading-relaxed max-w-3xl mx-auto">
          <div className="text-center mb-12">
            <h1 className="text-2xl font-bold uppercase tracking-widest border-b-2 border-gray-900 pb-2 inline-block">
              Contrato de Servicios
            </h1>
          </div>

          <div className="space-y-4 text-justify">
            <p>
              En la ciudad de{" "}
              <strong>{event.city || "___________________"}</strong>, a los{" "}
              {new Date().getDate()} días del mes de{" "}
              {new Date().toLocaleString("es-ES", { month: "long" })} de{" "}
              {new Date().getFullYear()}, comparecen por una parte{" "}
              <strong>
                {profile?.business_name || profile?.name || user?.email}
              </strong>{" "}
              (en adelante "EL PROVEEDOR"), y por la otra parte{" "}
              <strong>{event.clients?.name}</strong> (en adelante "EL CLIENTE"),
              quienes convienen en celebrar el presente Contrato de Prestación
              de Servicios, sujeto a las siguientes cláusulas:
            </p>

            <h3 className="font-bold text-lg mt-6">PRIMERA: OBJETO</h3>
            <p>
              EL PROVEEDOR se compromete a prestar los servicios de{" "}
              <strong>{event.service_type}</strong> para el evento que se
              llevará a cabo el día{" "}
              <strong>{new Date(event.event_date).toLocaleDateString()}</strong>
              .
            </p>

            <h3 className="font-bold text-lg mt-6">
              SEGUNDA: DETALLES DEL EVENTO
            </h3>
            <ul className="list-disc pl-6 space-y-1">
              <li>
                <strong>Fecha:</strong>{" "}
                {new Date(event.event_date).toLocaleDateString()}
              </li>
              {timeRange && (
                <li>
                  <strong>Horario:</strong> {timeRange}
                </li>
              )}
              <li>
                <strong>Cantidad de Personas:</strong> {event.num_people}
              </li>
              <li>
                <strong>Ubicación:</strong>{" "}
                {event.location || event.clients?.address || "A definir"}
              </li>
              <li>
                <strong>Factura:</strong>{" "}
                {event.requires_invoice ? `Sí (IVA ${event.tax_rate || 16}%)` : "No"}
              </li>
            </ul>

            <h3 className="font-bold text-lg mt-6">
              TERCERA: PRODUCTOS Y SERVICIOS
            </h3>
            <p>El servicio incluye lo siguiente:</p>
            <ul className="list-disc pl-6 space-y-1">
              {products.map((p, i) => (
                <li key={i}>
                  {p.quantity}x {p.products?.name}
                </li>
              ))}
              {extras.map((e, i) => (
                <li key={`e-${i}`}>{e.description}</li>
              ))}
            </ul>

            <h3 className="font-bold text-lg mt-6">
              CUARTA: COSTO Y FORMA DE PAGO
            </h3>
            <p>
              El costo total del servicio es de{" "}
              <strong>${event.total_amount.toFixed(2)}</strong>.
            </p>
            <p>
              EL CLIENTE se compromete a realizar un anticipo del{" "}
              <strong>{event.deposit_percent ?? 50}%</strong> para reservar la
              fecha, y liquidar el saldo restante antes del inicio del evento.
            </p>

            <h3 className="font-bold text-lg mt-6">QUINTA: CANCELACIONES</h3>
            <p>
              En caso de cancelación por parte de EL CLIENTE con menos de{" "}
              <strong>{event.cancellation_days ?? 15}</strong> días de
              anticipación, el anticipo no será reembolsado.
            </p>
            {event.refund_percent > 0 && (
              <p>
                Si la cancelación se realiza con la debida anticipación, se
                reembolsará el <strong>{event.refund_percent}%</strong> del
                anticipo entregado.
              </p>
            )}
          </div>

          <div className="grid grid-cols-2 gap-16 mt-24 pt-12">
            <div className="text-center border-t border-gray-400 pt-4">
              <p className="font-bold">
                {profile?.business_name || profile?.name || "EL PROVEEDOR"}
              </p>
              <p className="text-sm text-gray-500 mt-1">Firma</p>
            </div>
            <div className="text-center border-t border-gray-400 pt-4">
              <p className="font-bold">{event.clients?.name}</p>
              <p className="text-sm text-gray-500 mt-1">Firma de EL CLIENTE</p>
            </div>
          </div>
        </div>
      )}

      <div className="mt-12 text-center text-xs text-gray-400 print:mt-12">
        <p>
          Generado por {profile?.business_name || "EventosApp"} -{" "}
          {new Date().toLocaleString()}
        </p>
      </div>
    </div>
  );
};
