import React from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Linking,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import Constants from "expo-constants";
import { ChevronLeft, Heart, Globe, Mail, FileText, Shield } from "lucide-react-native";
import { SvgXml } from "react-native-svg";
import { NativeStackScreenProps } from "@react-navigation/native-stack";
import { SettingsStackParamList } from "../../types/navigation";
import { useTheme } from "../../hooks/useTheme";
import { colors } from "../../theme/colors";
import { spacing } from "../../theme/spacing";
import { typography } from "../../theme/typography";
import { shadows } from "../../theme/shadows";

const solennixLogoXml = `<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <defs>
    <linearGradient id="iconBg" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#2a201b"/>
      <stop offset="50%" stop-color="#120d0b"/>
      <stop offset="100%" stop-color="#0a0504"/>
    </linearGradient>
    <linearGradient id="gold-grad" x1="0" y1="0.5" x2="1" y2="0.5">
      <stop offset="0%" stop-color="#b45309"/>
      <stop offset="30%" stop-color="#f59e0b"/>
      <stop offset="50%" stop-color="#fef3c7"/>
      <stop offset="70%" stop-color="#fbbf24"/>
      <stop offset="100%" stop-color="#b45309"/>
    </linearGradient>
    <linearGradient id="orange-grad" x1="0" y1="0" x2="1" y2="1">
      <stop offset="0%" stop-color="#c2410c"/>
      <stop offset="20%" stop-color="#ea580c"/>
      <stop offset="50%" stop-color="#f97316"/>
      <stop offset="80%" stop-color="#ea580c"/>
      <stop offset="100%" stop-color="#9a3412"/>
    </linearGradient>
    <filter id="drop-shadow">
      <feDropShadow dx="0" dy="5" stdDeviation="3.5" flood-color="#000000" flood-opacity="0.8"/>
    </filter>
    <clipPath id="clipRight">
      <rect x="52" y="44" width="50" height="50" />
    </clipPath>
  </defs>

  <rect x="0" y="0" width="100" height="100" rx="25" ry="25" fill="url(#iconBg)"/>

  <circle cx="41" cy="62" r="20" fill="none" stroke="url(#orange-grad)" stroke-width="11" filter="url(#drop-shadow)"/>
  <circle cx="41" cy="62" r="20" fill="none" stroke="#ffedd5" stroke-width="1.5" opacity="0.6"/>

  <circle cx="53" cy="38" r="20" fill="none" stroke="url(#gold-grad)" stroke-width="11" filter="url(#drop-shadow)"/>
  <circle cx="53" cy="38" r="20" fill="none" stroke="#fff" stroke-width="1.5" opacity="0.8"/>

  <g clip-path="url(#clipRight)">
    <circle cx="41" cy="62" r="20" fill="none" stroke="url(#orange-grad)" stroke-width="11" filter="url(#drop-shadow)"/>
    <circle cx="41" cy="62" r="20" fill="none" stroke="#ffedd5" stroke-width="1.5" opacity="0.6"/>
  </g>
</svg>`;

type Props = NativeStackScreenProps<SettingsStackParamList, "About">;

const APP_VERSION = Constants.expoConfig?.version ?? "1.0.0";

export default function AboutScreen({ navigation }: Props) {
  const { isDark } = useTheme();
  const palette = isDark ? colors.dark : colors.light;
  const styles = getStyles(palette);

  const openURL = (url: string) => {
    Linking.openURL(url);
  };

  return (
    <SafeAreaView style={styles.container} edges={["top", "left", "right"]}>
      <ScrollView contentContainerStyle={styles.content}>
        <TouchableOpacity
          style={styles.backButton}
          onPress={() => navigation.goBack()}
        >
          <ChevronLeft color={palette.text} size={24} />
        </TouchableOpacity>

        <View style={styles.logoContainer}>
          <SvgXml
            xml={solennixLogoXml}
            width={120}
            height={120}
            style={styles.logo}
          />
          <Text style={styles.appName}>Solennix</Text>
          <Text style={styles.version}>Versi&#xF3;n {APP_VERSION}</Text>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Desarrollado por</Text>
          <Text style={styles.developer}>Creapolis.Dev</Text>

          <View style={styles.divider} />

          <TouchableOpacity
            style={styles.infoRow}
            onPress={() => openURL("https://www.creapolis.dev")}
          >
            <Globe color={palette.primary} size={20} />
            <Text style={styles.linkText}>www.creapolis.dev</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.infoRow}
            onPress={() => openURL("mailto:creapolis.mx@gmail.com")}
          >
            <Mail color={palette.primary} size={20} />
            <Text style={styles.linkText}>creapolis.mx@gmail.com</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Legal</Text>

          <TouchableOpacity
            style={styles.infoRow}
            onPress={() => navigation.navigate("Terms")}
          >
            <FileText color={palette.primary} size={20} />
            <Text style={styles.linkText}>T&#xE9;rminos y Condiciones</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.infoRow}
            onPress={() => navigation.navigate("PrivacyPolicy")}
          >
            <Shield color={palette.primary} size={20} />
            <Text style={styles.linkText}>Pol&#xED;tica de Privacidad</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Sobre la app</Text>
          <Text style={styles.description}>
            Solennix es una aplicaci&#xF3;n SaaS dise&#xF1;ada para organizadores de eventos
            de todo tipo. Gestiona clientes, eventos, cat&#xE1;logo de productos,
            inventario, cotizaciones y pagos en un solo lugar.
          </Text>
        </View>

        <View style={styles.footer}>
          <View style={styles.footerContent}>
            <Text style={styles.footerText}>
              Hecho con <Heart color={palette.error} size={14} fill={palette.error} /> por el equipo de Creapolis.Dev
            </Text>
          </View>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const getStyles = (palette: typeof colors.light) => StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: palette.surfaceGrouped,
  },
  content: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xxl,
  },
  backButton: {
    alignSelf: "flex-start",
    padding: spacing.sm,
    marginTop: spacing.sm,
    marginBottom: spacing.md,
  },
  logoContainer: {
    alignItems: "center",
    marginTop: spacing.lg,
    marginBottom: spacing.xl,
  },
  logo: {
    width: 120,
    height: 120,
    borderRadius: 30,
    marginBottom: spacing.md,
    ...shadows.md,
  },
  appName: {
    ...typography.title1,
    color: palette.text,
    fontWeight: "700",
    marginBottom: spacing.xs,
  },
  version: {
    ...typography.body,
    color: palette.textSecondary,
  },
  card: {
    backgroundColor: palette.card,
    borderRadius: spacing.borderRadius.lg,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.sm,
  },
  sectionTitle: {
    ...typography.label,
    color: palette.textSecondary,
    textTransform: "uppercase",
    letterSpacing: 0.5,
    marginBottom: spacing.sm,
  },
  developer: {
    ...typography.h2,
    color: palette.text,
    fontWeight: "700",
  },
  divider: {
    height: 1,
    backgroundColor: palette.separator,
    marginVertical: spacing.md,
  },
  infoRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: spacing.md,
    marginBottom: spacing.sm,
    paddingVertical: spacing.xs,
  },
  linkText: {
    ...typography.body,
    color: palette.primary,
  },
  description: {
    ...typography.body,
    color: palette.textSecondary,
    lineHeight: 24,
  },
  footer: {
    marginTop: spacing.lg,
  },
  footerContent: {
    alignItems: "center",
  },
  footerText: {
    ...typography.caption,
    color: palette.textMuted,
    textAlign: "center",
  },
});
