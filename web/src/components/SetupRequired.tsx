import React from 'react';
import { AlertTriangle, ExternalLink, FileText } from 'lucide-react';
import { useTranslation } from 'react-i18next';

export const SetupRequired: React.FC = () => {
  const { t } = useTranslation('static');

  return (
    <div className="min-h-screen bg-surface flex items-center justify-center p-4">
      <div className="max-w-2xl w-full bg-card rounded-2xl shadow-lg p-8">
        <div className="flex items-center justify-center mb-6">
          <div className="bg-warning/10 rounded-full p-3" aria-hidden="true">
            <AlertTriangle className="h-12 w-12 text-warning" aria-hidden="true" />
          </div>
        </div>

        <h1 className="text-3xl font-bold text-center mb-4 text-text">
          {t('setup_required.title')}
        </h1>

        <p className="text-center text-text-secondary mb-8">
          {t('setup_required.description')}
        </p>

        <div className="bg-surface-alt rounded-xl p-6 mb-6">
          <h2 className="text-lg font-semibold mb-4 text-text flex items-center">
            <FileText className="h-5 w-5 mr-2" aria-hidden="true" />
            {t('setup_required.steps_title')}
          </h2>

          <ol className="space-y-4 text-text-secondary">
            <li className="flex">
              <span className="font-bold mr-2">1.</span>
              <div>
                <p className="font-medium">{t('setup_required.step_1')}</p>
                <a
                  href="https://supabase.com/dashboard"
                  target="_blank"
                  rel="noopener noreferrer"
                  className="text-brand-orange hover:underline inline-flex items-center mt-1"
                  aria-label={t('setup_required.step_1_aria')}
                >
                  {t('setup_required.step_1_cta')} <ExternalLink className="h-4 w-4 ml-1" aria-hidden="true" />
                </a>
              </div>
            </li>
            
            <li className="flex">
              <span className="font-bold mr-2">2.</span>
              <div>
                <p className="font-medium">{t('setup_required.step_2')}</p>
                <p className="text-sm mt-1">{t('setup_required.step_2_desc')}</p>
                <ul className="list-disc ml-5 mt-2 text-sm">
                  <li>{t('setup_required.step_2_url')}</li>
                  <li>{t('setup_required.step_2_key')}</li>
                </ul>
              </div>
            </li>
            
            <li className="flex">
              <span className="font-bold mr-2">3.</span>
              <div>
                <p className="font-medium">{t('setup_required.step_3')}</p>
                <p className="text-sm mt-1">
                  {t('setup_required.step_3_desc')}<br />
                  <code className="bg-surface-alt px-2 py-1 rounded text-xs font-mono">
                    supabase/migrations/20260215000001_consolidated_schema.sql
                  </code>
                </p>
              </div>
            </li>
            
            <li className="flex">
              <span className="font-bold mr-2">4.</span>
              <div>
                <p className="font-medium">{t('setup_required.step_4')}</p>
                <div className="mt-2">
                  <p className="text-sm font-medium mb-2">{t('setup_required.step_4_local')}</p>
                  <div className="bg-[#1B2A4A] rounded-xl p-3 text-sm font-mono text-white overflow-x-auto">
                    <p className="text-white/50">{t('setup_required.step_4_local_env')}</p>
                    <p>VITE_SUPABASE_URL=tu_project_url</p>
                    <p>VITE_SUPABASE_ANON_KEY=tu_anon_key</p>
                  </div>
                  
                  <p className="text-sm font-medium mt-4 mb-2">{t('setup_required.step_4_vercel')}</p>
                  <p className="text-sm">
                    {t('setup_required.step_4_vercel_desc')}
                  </p>
                </div>
              </div>
            </li>
            
            <li className="flex">
              <span className="font-bold mr-2">5.</span>
              <div>
                <p className="font-medium">{t('setup_required.step_5')}</p>
                <p className="text-sm mt-1">
                  {t('setup_required.step_5_desc')}
                </p>
              </div>
            </li>
          </ol>
        </div>

        <div className="bg-info/10 border border-info/20 rounded-lg p-4">
          <p className="text-sm text-text">
            <strong>{t('setup_required.note')}</strong> {t('setup_required.note_desc')}
          </p>
        </div>
      </div>
    </div>
  );
};
