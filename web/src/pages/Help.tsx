import React, { useState, useMemo } from "react";
import { Link, useNavigate } from "react-router-dom";
import { useTranslation } from "react-i18next";
import {
  ChevronDown,
  ChevronUp,
  LifeBuoy,
  BookOpen,
  AlertCircle,
  MessageSquare,
  History,
  CheckCircle,
} from "lucide-react";

type FAQCategory = "all" | "general" | "technical" | "billing" | "changelog";

interface FAQItem {
  id: string;
  question: string;
  category: Exclude<FAQCategory, "all">;
  paragraphs: string[];
  bullets?: string[];
  note?: string;
}

interface GuideItem {
  id: string;
  title: string;
  description: string;
  topics: string[];
}

const GUIDE_ICONS: Record<string, React.ReactNode> = {
  "getting-started": <CheckCircle className="w-6 h-6" />,
  events: <BookOpen className="w-6 h-6" />,
  inventory: <AlertCircle className="w-6 h-6" />,
  clients: <MessageSquare className="w-6 h-6" />,
};

export function Help() {
  const navigate = useNavigate();
  const { t } = useTranslation("static");

  const [expandedFAQ, setExpandedFAQ] = useState<string | null>(null);
  const [selectedCategory, setSelectedCategory] = useState<FAQCategory>("general");

  const guides = useMemo(() => [
    { id: "getting-started", ...t("help.guides.getting_started", { returnObjects: true }) as any },
    { id: "events", ...t("help.guides.events", { returnObjects: true }) as any },
    { id: "inventory", ...t("help.guides.inventory", { returnObjects: true }) as any },
    { id: "clients", ...t("help.guides.clients", { returnObjects: true }) as any },
  ] as GuideItem[], [t]);

  const faqs = useMemo(() => t("help.faqs", { returnObjects: true }) as FAQItem[], [t]);

  const filteredFAQ = faqs.filter(
    (item) => selectedCategory === "all" || item.category === selectedCategory
  );

  const toggleFAQ = (id: string) => {
    setExpandedFAQ(expandedFAQ === id ? null : id);
  };

  return (
    <div className="min-h-screen bg-surface-alt">
      <div className="sticky top-0 z-10 border-b border-border bg-bg/90 backdrop-blur-md">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
          <button
            onClick={() => navigate(-1)}
            className="mb-4 inline-flex items-center gap-2 text-sm font-medium text-text-secondary hover:text-text transition-colors"
          >
            ← {t("about.back")}
          </button>
          <div className="flex items-center gap-3">
            <div className="flex h-12 w-12 items-center justify-center rounded-2xl bg-primary/10 text-primary">
              <LifeBuoy className="w-7 h-7" />
            </div>
            <h1 className="text-3xl font-black tracking-tight text-text">
              {t("help.title")}
            </h1>
          </div>
          <p className="mt-2 text-text-secondary">{t("help.subtitle")}</p>
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <Link
          to="/help/changelog"
          className="block rounded-2xl border border-border bg-card p-4 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md sm:p-6"
        >
          <div className="flex items-start gap-4">
            <div className="mt-1 flex h-11 w-11 shrink-0 items-center justify-center rounded-xl bg-info/10 text-info">
              <History className="w-5 h-5" />
            </div>
            <div className="flex-1">
              <h2 className="text-lg font-semibold text-text">
                {t("help.changelog_title")}
              </h2>
              <p className="mt-1 text-sm text-text-secondary">
                {t("help.changelog_desc")}
              </p>
              <span className="mt-3 inline-flex items-center gap-2 font-medium text-primary hover:underline">
                {t("help.changelog_cta")} →
              </span>
            </div>
          </div>
        </Link>
      </div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-6">
        <h2 className="mb-6 text-2xl font-bold text-text">
          {t("help.guides_title")}
        </h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          {guides.map((guide) => (
            <div
              key={guide.id}
              className="rounded-2xl border border-border bg-card p-4 shadow-sm transition hover:-translate-y-0.5 hover:shadow-md sm:p-6"
            >
              <div className="flex items-start gap-3 mb-3">
                <div className="shrink-0 text-primary">
                  {GUIDE_ICONS[guide.id]}
                </div>
                <div className="flex-1">
                  <h3 className="font-semibold text-text">
                    {guide.title}
                  </h3>
                  <p className="mt-1 text-sm text-text-secondary">
                    {guide.description}
                  </p>
                </div>
              </div>
              <ul className="space-y-2">
                {guide.topics.map((topic) => (
                  <li key={topic} className="text-sm text-text-secondary">
                    • {topic}
                  </li>
                ))}
              </ul>
            </div>
          ))}
        </div>
      </div>

      <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <h2 className="mb-6 text-2xl font-bold text-text">
          {t("help.faq_title")}
        </h2>

        <div className="flex flex-wrap gap-2 mb-6">
          {(["all", "general", "technical", "billing", "changelog"] as FAQCategory[]).map(
            (category) => (
              <button
                key={category}
                onClick={() => setSelectedCategory(category)}
                className={`px-3 py-1 rounded-full text-sm font-medium transition ${
                  selectedCategory === category
                    ? "bg-primary text-white"
                    : "bg-surface-grouped text-text hover:bg-surface-alt"
                }`}
              >
                {t(`help.categories.${category}`)}
              </button>
            )
          )}
        </div>

        <div className="space-y-3">
          {filteredFAQ.map((item) => (
            <div
              key={item.id}
              className="overflow-hidden rounded-2xl border border-border bg-card shadow-sm transition hover:shadow-md"
            >
              <button
                onClick={() => toggleFAQ(item.id)}
                className="flex w-full items-center justify-between px-6 py-4 text-left transition hover:bg-surface-alt"
              >
                <h3 className="text-left font-semibold text-text">
                  {item.question}
                </h3>
                {expandedFAQ === item.id ? (
                  <ChevronUp className="h-5 w-5 shrink-0 text-text-secondary" />
                ) : (
                  <ChevronDown className="h-5 w-5 shrink-0 text-text-secondary" />
                )}
              </button>

              {expandedFAQ === item.id && (
                <div className="space-y-2 border-t border-border bg-surface-alt px-6 py-4 text-sm text-text-secondary">
                  {item.paragraphs.map((p) => (
                    <p key={p}>{p}</p>
                  ))}
                  {item.bullets && (
                    <ul className="list-disc list-inside space-y-1 ml-2">
                      {item.bullets.map((b) => (
                        <li key={b}>{b}</li>
                      ))}
                    </ul>
                  )}
                  {item.note && <p className="text-sm text-text-secondary">{item.note}</p>}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>

      <div className="mt-12 border-t border-border bg-card">
        <div className="max-w-5xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
          <h2 className="mb-4 text-2xl font-bold text-text">
            {t("help.contact_title")}
          </h2>
          <p className="mb-6 text-text-secondary">{t("help.contact_subtitle")}</p>
          <div className="flex flex-col sm:flex-row gap-4">
            <a
              href="mailto:soporte@solennix.com"
              className="inline-flex items-center gap-2 rounded-xl bg-primary px-6 py-3 font-medium text-white transition hover:opacity-90"
            >
              <MessageSquare className="w-5 h-5" />
              {t("help.contact_support")}
            </a>
            <a
              href="https://github.com/tiagofur/solennix/issues"
              className="inline-flex items-center gap-2 rounded-xl border border-border px-6 py-3 font-medium text-text transition hover:bg-surface-alt"
            >
              <BookOpen className="w-5 h-5" />
              {t("help.contact_github")}
            </a>
          </div>
        </div>
      </div>
    </div>
  );
}
