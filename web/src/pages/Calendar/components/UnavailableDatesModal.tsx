import React, { useState } from 'react';
import { X, Calendar as CalendarIcon } from 'lucide-react';
import { useToast } from '../../../hooks/useToast';
import { unavailableDatesService, UnavailableDate } from '../../../services/unavailableDatesService';
import clsx from 'clsx';
import { format } from 'date-fns';

interface UnavailableDatesModalProps {
  isOpen: boolean;
  onClose: () => void;
  onSave: (date: UnavailableDate) => void;
}

export const UnavailableDatesModal: React.FC<UnavailableDatesModalProps> = ({
  isOpen,
  onClose,
  onSave,
}) => {
  const { addToast } = useToast();
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({
    start_date: format(new Date(), 'yyyy-MM-dd'),
    end_date: format(new Date(), 'yyyy-MM-dd'),
    reason: '',
  });

  if (!isOpen) return null;

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      setLoading(true);
      const newDate = await unavailableDatesService.addDates(formData);
      addToast('Fechas bloqueadas exitosamente', 'success');
      onSave(newDate);
      onClose();
    } catch (error) {
      console.error(error);
      addToast('Error al bloquear las fechas', 'error');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm fallback-bg">
      <div className="bg-card w-full max-w-md rounded-2xl shadow-xl border border-border overflow-hidden fade-in">
        <div className="flex items-center justify-between p-6 border-b border-border bg-surface-alt/50">
          <h2 className="text-xl font-bold flex items-center text-text">
            <CalendarIcon className="h-6 w-6 mr-3 text-primary" />
            Bloquear Fechas
          </h2>
          <button
            onClick={onClose}
            className="text-text-secondary hover:text-text transition-colors p-2 hover:bg-surface rounded-full"
          >
            <X className="h-5 w-5" />
          </button>
        </div>

        <div className="p-6">
          <form onSubmit={handleSubmit} className="space-y-5">
            <div className="grid grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-text mb-2">
                  Fecha Inicio *
                </label>
                <input
                  type="date"
                  required
                  value={formData.start_date}
                  onChange={(e) =>
                    setFormData({ ...formData, start_date: e.target.value })
                  }
                  className="w-full px-4 py-2.5 bg-surface border border-border rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-text"
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-text mb-2">
                  Fecha Fin *
                </label>
                <input
                  type="date"
                  required
                  min={formData.start_date}
                  value={formData.end_date}
                  onChange={(e) =>
                    setFormData({ ...formData, end_date: e.target.value })
                  }
                  className="w-full px-4 py-2.5 bg-surface border border-border rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-text"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-medium text-text mb-2">
                Motivo (Opcional)
              </label>
              <input
                type="text"
                placeholder="Ej: Vacaciones anuales, Mantenimiento..."
                value={formData.reason}
                onChange={(e) =>
                  setFormData({ ...formData, reason: e.target.value })
                }
                className="w-full px-4 py-2.5 bg-surface border border-border rounded-xl focus:ring-2 focus:ring-primary/20 focus:border-primary transition-all text-text"
              />
            </div>

            <div className="flex justify-end gap-3 pt-4 border-t border-border mt-6">
              <button
                type="button"
                onClick={onClose}
                className="px-5 py-2.5 text-sm font-medium text-text-secondary hover:text-text bg-surface-alt hover:bg-surface border border-border rounded-xl transition-colors"
              >
                Cancelar
              </button>
              <button
                type="submit"
                disabled={loading}
                className={clsx(
                  'px-6 py-2.5 text-sm font-medium text-white rounded-xl transition-all shadow-sm flex items-center',
                  loading
                    ? 'bg-primary/70 cursor-not-allowed'
                    : 'premium-gradient hover:opacity-90 hover:shadow-md'
                )}
              >
                {loading ? 'Guardando...' : 'Guardar y Bloquear'}
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
};
