import React from 'react';
import { Plus, Trash2 } from 'lucide-react';

interface SelectedExtra {
  description: string;
  cost: number;
  price: number;
  exclude_utility: boolean;
}

interface EventExtrasProps {
  extras: SelectedExtra[];
  onAddExtra: () => void;
  onRemoveExtra: (index: number) => void;
  onExtraChange: (index: number, field: keyof SelectedExtra, value: any) => void;
}

export const EventExtras: React.FC<EventExtrasProps> = ({
  extras,
  onAddExtra,
  onRemoveExtra,
  onExtraChange,
}) => {
  return (
    <div className="space-y-4">
      <h3 className="text-lg font-medium text-text">Extras (Transporte, Personal, etc.)</h3>

      {extras.map((item, index) => (
        <div key={index} className="bg-surface-alt p-4 rounded-xl relative group mb-3 border border-border shadow-xs">
          <button
            type="button"
            onClick={() => onRemoveExtra(index)}
            className="absolute top-1 right-1 text-gray-400 hover:text-red-500 dark:hover:text-red-400"
            aria-label={`Eliminar extra ${index + 1}`}
          >
            <Trash2 className="h-4 w-4" aria-hidden="true" />
          </button>

          <div className="mb-2 pr-6">
            <label htmlFor={`extra-description-${index}`} className="block text-xs text-text-secondary mb-1">Descripción</label>
            <input
              id={`extra-description-${index}`}
              type="text"
              placeholder="Descripción"
              value={item.description}
              onChange={(e) => onExtraChange(index, 'description', e.target.value)}
              className="block w-full text-sm border-border rounded-xl shadow-xs transition-shadow focus:ring-2 focus:ring-brand-orange/20 bg-card text-text p-2 border"
              aria-label={`Descripción del extra ${index + 1}`}
            />
          </div>

          <div className="flex items-center mb-2">
            <input
              id={`extra-exclude-utility-${index}`}
              type="checkbox"
              checked={item.exclude_utility || false}
              onChange={(e) => onExtraChange(index, 'exclude_utility', e.target.checked)}
              className="h-4 w-4 text-brand-orange focus:ring-brand-orange border-border rounded-sm bg-card"
              aria-describedby={`extra-exclude-utility-label-${index}`}
            />
            <label id={`extra-exclude-utility-label-${index}`} htmlFor={`extra-exclude-utility-${index}`} className="ml-2 text-xs text-text-secondary">
              Solo cobrar costo (Sin utilidad)
            </label>
          </div>

          <div className="flex gap-2">
            <div className="w-1/2">
              <label htmlFor={`extra-cost-${index}`} className="text-xs text-text-secondary">Costo (Gasto)</label>
              <input
                id={`extra-cost-${index}`}
                type="number"
                value={item.cost}
                onChange={(e) => onExtraChange(index, 'cost', Number(e.target.value))}
                className="block w-full text-sm border-border rounded-xl shadow-xs transition-shadow focus:ring-2 focus:ring-brand-orange/20 bg-card text-text p-2 border"
                aria-label={`Costo del extra ${index + 1}`}
              />
            </div>
            <div className="w-1/2">
              <label htmlFor={`extra-price-${index}`} className="text-xs text-text-secondary">Precio (Cobro)</label>
              <input
                id={`extra-price-${index}`}
                type="number"
                value={item.price}
                disabled={item.exclude_utility}
                onChange={(e) => onExtraChange(index, 'price', Number(e.target.value))}
                className={`block w-full text-sm border-border rounded-xl shadow-xs transition-shadow focus:ring-2 focus:ring-brand-orange/20 bg-card text-text p-2 border ${
                  item.exclude_utility ? 'bg-surface-alt' : ''
                }`}
                aria-label={`Precio de cobro del extra ${index + 1}`}
              />
            </div>
          </div>
        </div>
      ))}

      <button
        type="button"
        onClick={onAddExtra}
        className="w-full flex items-center justify-center px-4 py-2 border border-border shadow-xs text-sm font-medium rounded-xl text-text-secondary bg-card hover:bg-surface-alt transition-colors"
        aria-label="Agregar un extra adicional"
      >
        <Plus className="h-4 w-4 mr-2" aria-hidden="true" /> Agregar Extra
      </button>

      <div className="mt-4 text-right">
        <span className="text-sm text-text-secondary mr-2">Subtotal Extras:</span>
        <span className="text-lg font-bold text-text">
          ${extras.reduce((sum, item) => sum + item.price, 0).toFixed(2)}
        </span>
      </div>
    </div>
  );
};
