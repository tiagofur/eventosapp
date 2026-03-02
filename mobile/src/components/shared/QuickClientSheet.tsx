import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ActivityIndicator,
} from "react-native";
import { UserPlus } from "lucide-react-native";
import { Client, ClientInsert } from "../../types/entities";
import { clientService } from "../../services/clientService";
import { logError } from "../../lib/errorHandler";
import { useTheme } from "../../hooks/useTheme";
import { colors } from "../../theme/colors";
import { spacing } from "../../theme/spacing";
import { typography } from "../../theme/typography";
import { AppBottomSheet } from "./AppBottomSheet";
import FormInput from "./FormInput";

interface QuickClientSheetProps {
  visible: boolean;
  onClose: () => void;
  onClientCreated: (client: Client) => void;
  userId: string;
}

export function QuickClientSheet({
  visible,
  onClose,
  onClientCreated,
  userId,
}: QuickClientSheetProps) {
  const [name, setName] = useState("");
  const [phone, setPhone] = useState("");
  const [email, setEmail] = useState("");
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState("");
  const [fieldErrors, setFieldErrors] = useState<{
    name?: string;
    phone?: string;
    email?: string;
  }>({});

  const { isDark } = useTheme();
  const palette = isDark ? colors.dark : colors.light;
  const styles = getStyles(palette);

  const resetForm = () => {
    setName("");
    setPhone("");
    setEmail("");
    setError("");
    setFieldErrors({});
    setSaving(false);
  };

  const handleClose = () => {
    resetForm();
    onClose();
  };

  const validate = (): boolean => {
    const errors: typeof fieldErrors = {};

    if (!name.trim() || name.trim().length < 2) {
      errors.name = "El nombre debe tener al menos 2 caracteres";
    }
    if (!phone.trim() || phone.trim().length < 10) {
      errors.phone = "El teléfono debe tener al menos 10 dígitos";
    }
    if (email.trim() && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.trim())) {
      errors.email = "Email inválido";
    }

    setFieldErrors(errors);
    return Object.keys(errors).length === 0;
  };

  const handleSave = async () => {
    if (!validate()) return;

    setSaving(true);
    setError("");

    try {
      const payload: ClientInsert = {
        user_id: userId,
        name: name.trim(),
        phone: phone.trim(),
        email: email.trim() || null,
        address: null,
        city: null,
        notes: null,
        photo_url: null,
        total_events: null,
        total_spent: null,
      };

      const newClient = await clientService.create(payload);
      resetForm();
      onClientCreated(newClient);
    } catch (err) {
      logError("Error creating quick client", err);
      setError("No se pudo crear el cliente. Intenta de nuevo.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <AppBottomSheet
      visible={visible}
      onClose={handleClose}
      enableDynamicSizing={false}
      snapPoints={["65%"]}
      scrollable
    >
      <View style={styles.container}>
        <View style={styles.header}>
          <UserPlus color={palette.primary} size={22} />
          <Text style={styles.title}>Nuevo Cliente Rápido</Text>
        </View>

        {error ? (
          <View style={styles.errorBanner}>
            <Text style={styles.errorBannerText}>{error}</Text>
          </View>
        ) : null}

        <FormInput
          label="Nombre *"
          placeholder="Nombre del cliente"
          value={name}
          onChangeText={setName}
          error={fieldErrors.name}
          autoCapitalize="words"
        />

        <FormInput
          label="Teléfono *"
          placeholder="10 dígitos"
          value={phone}
          onChangeText={setPhone}
          error={fieldErrors.phone}
          keyboardType="phone-pad"
        />

        <FormInput
          label="Email (opcional)"
          placeholder="correo@ejemplo.com"
          value={email}
          onChangeText={setEmail}
          error={fieldErrors.email}
          keyboardType="email-address"
          autoCapitalize="none"
        />

        <View style={styles.actions}>
          <TouchableOpacity
            style={styles.saveBtn}
            onPress={handleSave}
            disabled={saving}
            activeOpacity={0.7}
          >
            {saving ? (
              <ActivityIndicator color={palette.textInverse} size="small" />
            ) : (
              <Text style={styles.saveBtnText}>Guardar Cliente</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.cancelBtn}
            onPress={handleClose}
            disabled={saving}
            activeOpacity={0.7}
          >
            <Text style={styles.cancelBtnText}>Cancelar</Text>
          </TouchableOpacity>
        </View>
      </View>
    </AppBottomSheet>
  );
}

const getStyles = (palette: typeof colors.light) =>
  StyleSheet.create({
    container: {
      paddingHorizontal: spacing.lg,
      paddingTop: spacing.sm,
    },
    header: {
      flexDirection: "row",
      alignItems: "center",
      gap: spacing.sm,
      marginBottom: spacing.lg,
    },
    title: {
      ...typography.headline,
      color: palette.text,
    },
    errorBanner: {
      backgroundColor: palette.errorBg,
      borderRadius: spacing.borderRadius.md,
      padding: spacing.md,
      marginBottom: spacing.md,
    },
    errorBannerText: {
      ...typography.caption1,
      color: palette.error,
    },
    actions: {
      gap: spacing.sm,
      marginTop: spacing.sm,
    },
    saveBtn: {
      backgroundColor: palette.primary,
      borderRadius: spacing.borderRadius.md,
      paddingVertical: spacing.md,
      alignItems: "center",
      justifyContent: "center",
      minHeight: 48,
    },
    saveBtnText: {
      ...typography.body,
      color: palette.textInverse,
      fontWeight: "600",
    },
    cancelBtn: {
      borderRadius: spacing.borderRadius.md,
      paddingVertical: spacing.sm,
      alignItems: "center",
    },
    cancelBtnText: {
      ...typography.body,
      color: palette.textSecondary,
    },
  });
