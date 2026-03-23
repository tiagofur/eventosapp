import React, { useCallback, useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { MoreVertical } from "lucide-react";

export interface RowActionMenuItem {
  label: string;
  icon: React.ElementType;
  onClick: () => void;
  variant?: "default" | "destructive";
  href?: string;
}

interface RowActionMenuProps {
  items: RowActionMenuItem[];
}

export const RowActionMenu: React.FC<RowActionMenuProps> = ({ items }) => {
  const [open, setOpen] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  const close = useCallback(() => setOpen(false), []);

  useEffect(() => {
    if (!open) return;
    const handleClickOutside = (e: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(e.target as Node)) {
        close();
      }
    };
    document.addEventListener("click", handleClickOutside, true);
    return () => document.removeEventListener("click", handleClickOutside, true);
  }, [open, close]);

  const firstDestructiveIdx = items.findIndex(
    (item) => item.variant === "destructive",
  );

  return (
    <div className="relative" ref={menuRef}>
      <button
        type="button"
        onClick={(e) => {
          e.stopPropagation();
          setOpen((prev) => !prev);
        }}
        className="p-1.5 text-text-secondary hover:text-primary hover:bg-surface-alt rounded-lg transition-colors inline-block"
        aria-label="Acciones"
        aria-haspopup="true"
        aria-expanded={open}
      >
        <MoreVertical className="h-4 w-4" aria-hidden="true" />
      </button>

      {open && (
        <div
          className="absolute right-0 top-full z-50 mt-1 min-w-[180px] bg-card border border-border rounded-xl shadow-lg py-1 animate-in fade-in duration-150"
          role="menu"
        >
          {items.map((item, idx) => {
            const Icon = item.icon;
            const isDestructive = item.variant === "destructive";
            const showDivider = idx === firstDestructiveIdx && idx > 0;

            const className = `w-full px-3 py-2 text-sm flex items-center gap-2 transition-colors ${
              isDestructive
                ? "text-error hover:bg-error/10"
                : "text-text hover:bg-surface-alt"
            }`;

            return (
              <React.Fragment key={idx}>
                {showDivider && (
                  <div className="border-t border-border my-1" role="separator" />
                )}
                {item.href ? (
                  <Link
                    to={item.href}
                    className={className}
                    role="menuitem"
                    onClick={(e) => {
                      e.stopPropagation();
                      item.onClick();
                      close();
                    }}
                  >
                    <Icon className="h-4 w-4" aria-hidden="true" />
                    {item.label}
                  </Link>
                ) : (
                  <button
                    type="button"
                    className={className}
                    role="menuitem"
                    onClick={(e) => {
                      e.stopPropagation();
                      item.onClick();
                      close();
                    }}
                  >
                    <Icon className="h-4 w-4" aria-hidden="true" />
                    {item.label}
                  </button>
                )}
              </React.Fragment>
            );
          })}
        </div>
      )}
    </div>
  );
};
