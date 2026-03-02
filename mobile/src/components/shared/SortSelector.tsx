import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from "react-native";
import { ArrowUpDown, ChevronDown, ArrowUp, ArrowDown } from "lucide-react-native";
import { useTheme } from "../../hooks/useTheme";
import { colors } from "../../theme/colors";
import { spacing } from "../../theme/spacing";
import { typography } from "../../theme/typography";
import { AppBottomSheet } from "./AppBottomSheet";

export interface SortOption {
  key: string;
  label: string;
}

interface SortSelectorProps {
  options: SortOption[];
  sortKey: string;
  sortOrder: "asc" | "desc";
  onSort: (key: string, order: "asc" | "desc") => void;
}

export function SortSelector({
  options,
  sortKey,
  sortOrder,
  onSort,
}: SortSelectorProps) {
  const [showSheet, setShowSheet] = useState(false);
  const { isDark } = useTheme();
  const palette = isDark ? colors.dark : colors.light;
  const styles = getStyles(palette);

  const currentLabel = options.find((o) => o.key === sortKey)?.label || "";

  const handleSelect = (key: string) => {
    if (key === sortKey) {
      onSort(key, sortOrder === "asc" ? "desc" : "asc");
    } else {
      onSort(key, "asc");
    }
    setShowSheet(false);
  };

  return (
    <>
      <TouchableOpacity
        style={styles.trigger}
        onPress={() => setShowSheet(true)}
        activeOpacity={0.7}
      >
        <ArrowUpDown color={palette.textSecondary} size={14} />
        <Text style={styles.triggerText} numberOfLines={1}>
          {currentLabel}
        </Text>
        {sortOrder === "asc" ? (
          <ArrowUp color={palette.textSecondary} size={12} />
        ) : (
          <ArrowDown color={palette.textSecondary} size={12} />
        )}
      </TouchableOpacity>

      <AppBottomSheet
        visible={showSheet}
        onClose={() => setShowSheet(false)}
        scrollable
      >
        <View style={styles.sheetContent}>
          <Text style={styles.sheetTitle}>Ordenar por</Text>
          {options.map((opt) => {
            const isActive = sortKey === opt.key;
            return (
              <TouchableOpacity
                key={opt.key}
                style={[styles.option, isActive && styles.optionActive]}
                onPress={() => handleSelect(opt.key)}
                activeOpacity={0.7}
              >
                <Text
                  style={[
                    styles.optionText,
                    isActive && styles.optionTextActive,
                  ]}
                >
                  {opt.label}
                </Text>
                {isActive && (
                  sortOrder === "asc" ? (
                    <ArrowUp color={palette.primary} size={16} />
                  ) : (
                    <ArrowDown color={palette.primary} size={16} />
                  )
                )}
              </TouchableOpacity>
            );
          })}
        </View>
      </AppBottomSheet>
    </>
  );
}

const getStyles = (palette: typeof colors.light) =>
  StyleSheet.create({
    trigger: {
      flexDirection: "row",
      alignItems: "center",
      gap: spacing.xs,
      backgroundColor: palette.surface,
      paddingHorizontal: spacing.sm + 2,
      paddingVertical: spacing.xs + 2,
      borderRadius: spacing.borderRadius.full,
    },
    triggerText: {
      ...typography.caption1,
      color: palette.textSecondary,
      fontWeight: "500",
      maxWidth: 120,
    },
    sheetContent: {
      paddingHorizontal: spacing.lg,
      paddingTop: spacing.sm,
      paddingBottom: spacing.lg,
    },
    sheetTitle: {
      ...typography.headline,
      color: palette.text,
      marginBottom: spacing.md,
    },
    option: {
      flexDirection: "row",
      alignItems: "center",
      justifyContent: "space-between",
      paddingVertical: spacing.md,
      paddingHorizontal: spacing.md,
      borderRadius: spacing.borderRadius.md,
      marginBottom: spacing.xxs,
    },
    optionActive: {
      backgroundColor: palette.primaryLight,
    },
    optionText: {
      ...typography.body,
      color: palette.text,
    },
    optionTextActive: {
      color: palette.primary,
      fontWeight: "600",
    },
  });
