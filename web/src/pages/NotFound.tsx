import React from 'react';
import { Link } from 'react-router-dom';
import { AlertTriangle } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export const NotFound: React.FC = () => {
  const { t } = useTranslation(['common']);

  return (
    <div className="min-h-screen bg-surface-alt flex items-center justify-center px-4">
      <div className="max-w-md w-full bg-card border border-border rounded-xl shadow-xs p-8 text-center">
        <div className="mx-auto w-12 h-12 rounded-full bg-primary/10 flex items-center justify-center" aria-hidden="true">
          <AlertTriangle className="w-6 h-6 text-primary" aria-hidden="true" />
        </div>
        <h1 className="mt-6 text-2xl font-bold text-text">{t('common:not_found.title')}</h1>
        <p className="mt-2 text-text-secondary">
          {t('common:not_found.description')}
        </p>
        <div className="mt-8 flex flex-col sm:flex-row gap-3 justify-center">
          <Link
            to="/"
            className="inline-flex items-center justify-center px-4 py-2 rounded-lg bg-card text-text border border-border hover:bg-surface-alt transition-colors"
            aria-label={t('common:not_found.aria_home')}
          >
            {t('common:not_found.go_home')}
          </Link>
          <Link
            to="/dashboard"
            className="inline-flex items-center justify-center px-4 py-2 rounded-lg premium-gradient text-white hover:opacity-90 transition-opacity"
            aria-label={t('common:not_found.aria_dashboard')}
          >
            {t('common:not_found.go_dashboard')}
          </Link>
        </div>
      </div>
    </div>
  );
};

