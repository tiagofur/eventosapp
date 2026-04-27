import React from 'react';
import { useNavigate } from 'react-router-dom';
import { ArrowLeft, Trash2, Mail } from 'lucide-react';
import { useTranslation, Trans } from 'react-i18next';

export const AccountDeletion: React.FC = () => {
  const navigate = useNavigate();
  const { t } = useTranslation(['static']);

  return (
    <div className="min-h-screen bg-bg">
      <div className="max-w-3xl mx-auto px-4 py-12">
        {/* Back button */}
        <button
          onClick={() => navigate(-1)}
          className="inline-flex items-center gap-2 text-sm font-medium text-text-secondary hover:text-text transition-colors mb-8"
        >
          <ArrowLeft className="h-4 w-4" />
          {t('static:account_deletion.back')}
        </button>

        <h1 className="text-3xl font-black tracking-tight text-text mb-2">
          {t('static:account_deletion.title')}
        </h1>
        <p className="text-sm text-text-secondary mb-10">
          {t('static:account_deletion.subtitle')}
        </p>

        <div className="bg-card border border-border rounded-2xl p-8 mb-6 shadow-sm">
          <div className="flex items-center gap-4 mb-6">
            <div className="h-12 w-12 rounded-full bg-red-500/10 flex items-center justify-center text-red-500">
              <Trash2 className="h-6 w-6" />
            </div>
            <div>
              <h2 className="text-xl font-bold text-text">{t('static:account_deletion.request_title')}</h2>
              <p className="text-sm text-text-secondary">{t('static:account_deletion.request_subtitle')}</p>
            </div>
          </div>

          <div className="space-y-6 text-sm text-text-secondary leading-relaxed">
            <p>
              {t('static:account_deletion.intro')}
            </p>

            <div className="bg-bg/50 rounded-xl p-4 border border-border/50">
              <h3 className="font-semibold text-text mb-2">{t('static:account_deletion.what_happens_title')}</h3>
              <ul className="list-disc list-inside space-y-2">
                {(t('static:account_deletion.what_happens_items', { returnObjects: true }) as string[]).map((item, index) => (
                  <li key={index}>
                    <Trans t={t} i18nKey={`static:account_deletion.what_happens_items.${index}`}>
                      {item}
                    </Trans>
                  </li>
                ))}
              </ul>
            </div>

            <h3 className="text-lg font-bold text-text mt-8 mb-2">{t('static:account_deletion.how_to_request_title')}</h3>
            <p>
              {t('static:account_deletion.how_to_request_desc')}
            </p>

            <a 
              href={`mailto:hola@creapolis.dev?subject=${t('static:account_deletion.email_subject')}`}
              className="flex items-center gap-3 w-full p-4 rounded-xl border border-brand-orange/20 bg-brand-orange/5 text-brand-orange font-semibold hover:bg-brand-orange/10 transition-colors"
            >
              <Mail className="h-5 w-5" />
              {t('static:account_deletion.email_button')}
            </a>

            <p className="text-xs italic mt-4">
              {t('static:account_deletion.footer_note')}
            </p>
          </div>
        </div>

        <div className="bg-card border border-border rounded-2xl p-6 shadow-sm">
          <h2 className="text-lg font-semibold text-text mb-3">
            {t('static:account_deletion.other_queries_title')}
          </h2>
          <p className="text-sm text-text-secondary leading-relaxed">
            <Trans t={t} i18nKey="static:account_deletion.other_queries_desc">
              Si solo deseas corregir información o tienes dudas sobre cómo tratamos tus datos, te invitamos a revisar nuestra{' '}
              <button onClick={() => navigate('/privacy')} className="text-brand-orange hover:underline">
                Política de Privacidad
              </button>.
            </Trans>
          </p>
        </div>
      </div>
    </div>
  );
};
