#android #seguridad #release #play-store

# 🔐 Firma y Secretos de Release — Android

> [!warning] Estado actual
> **Bloque A del plan Play Store (Wave Rescate Android)** — en progreso.
> Este documento describe cómo configurar y rotar los secretos de firma y RevenueCat.

---

## Resumen

El build de release de Solennix Android necesita dos secretos que **NO viven en el repo**:

1. **Keystore de firma** (`solennix.jks`) — firma el APK/AAB para Play Store
2. **RevenueCat API key** (`REVENUECAT_API_KEY`) — habilita suscripciones en runtime

Ambos se resuelven en este orden (el primero que exista gana):

| Secreto | Env var (CI) | Archivo local (dev) |
| ------- | ------------ | ------------------- |
| Keystore file | `SOLENNIX_KEYSTORE_FILE` | `android/key.properties` → `storeFile` |
| Keystore password | `SOLENNIX_KEYSTORE_PASSWORD` | `android/key.properties` → `storePassword` |
| Key alias | `SOLENNIX_KEY_ALIAS` | `android/key.properties` → `keyAlias` |
| Key password | `SOLENNIX_KEY_PASSWORD` | `android/key.properties` → `keyPassword` |
| RevenueCat API key | `REVENUECAT_API_KEY` | `~/.gradle/gradle.properties` → `REVENUECAT_API_KEY=...` |

**Fail-fast**: si intentás `./gradlew assembleRelease` o `bundleRelease` sin tener estos secretos, el build falla con error explícito antes de compilar — nunca más APKs sin firmar accidentales.

---

## Qué está gitignored (verificado)

`android/.gitignore` incluye:

- `key.properties` (línea 34)
- `*.jks`, `*.keystore`, `*.p12`, `*.jceks` (líneas 30-33)
- `app/google-services.json` (línea 37)

> [!success] Ninguno de estos archivos está committed en git.
> `git ls-files` y `git log --all` verificados el 2026-04-11.

---

## Setup inicial de un dev nuevo

### 1. Copiar el template

```bash
cd android
cp key.properties.example key.properties
```

### 2. Generar un keystore nuevo (solo si no tenés uno)

> [!tip] Si heredás el proyecto, pedí el `.jks` al dev anterior — NO generes uno nuevo.
> Una vez publicada una versión en Play Store, el upload key no se puede cambiar sin intervención manual de Google Play Support.

```bash
keytool -genkeypair \
  -v \
  -keystore android/solennix.jks \
  -alias upload \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storetype PKCS12
```

Vas a ver prompts:

- **Keystore password**: mínimo 16 caracteres, mixto — **NO usar `asd123` ni nada similar**
- **First and last name**: `Solennix` (o tu nombre)
- **Organizational unit**: `Mobile`
- **Organization**: `Creapolis`
- **City/State/Country**: tus datos reales
- **Key password**: podés darle el mismo que el store, o uno distinto (recomendado)

Anotá ambos passwords en un password manager (1Password, Bitwarden, etc.) — si los perdés, **perdiste la identidad de la app**.

### 3. Editar `android/key.properties`

```properties
storeFile=solennix.jks
keyAlias=upload
storePassword=<el password que elegiste>
keyPassword=<el password del key>
```

### 4. Configurar RevenueCat API key

```bash
# Opción A: en ~/.gradle/gradle.properties (recomendado — sirve para todos los proyectos)
echo "REVENUECAT_API_KEY=goog_xxxxxxxxxxxxxxxxxxxxxxxxx" >> ~/.gradle/gradle.properties

# Opción B: en el environment (si usás direnv o zshenv)
export REVENUECAT_API_KEY=goog_xxxxxxxxxxxxxxxxxxxxxxxxx
```

La key la sacás del [RevenueCat Dashboard](https://app.revenuecat.com/) → **Project Settings → API Keys → Public App-Specific API Keys → Google Play**.

Empieza con `goog_` (Android) o `appl_` (iOS). **No mezclar.**

### 5. Verificar que el build funciona

```bash
cd android
./gradlew :app:assembleRelease
```

Si falla con `Cannot build release: missing required config:` → revisá cuál secreto falta.
Si falla con `Failed to read key upload from store`: el password del key es incorrecto.
Si compila y genera `app/build/outputs/apk/release/app-release.apk` → todo OK.

---

## Rotar el password del keystore existente

Aplica si el password actual es trivial (como `asd123`) y la app **aún no está publicada**.

```bash
# Rotar el store password
keytool -storepasswd \
  -keystore android/solennix.jks \
  -storepass asd123 \
  -new <nuevo-password-fuerte>

# Rotar el key password
keytool -keypasswd \
  -keystore android/solennix.jks \
  -alias upload \
  -storepass <nuevo-password-fuerte> \
  -keypass asd123 \
  -new <nuevo-key-password-fuerte>
```

Después actualizá `android/key.properties` con los nuevos valores.

---

## Rotar el keystore ya publicado en Play Store

Si la app YA está en Play Store con una versión publicada, **no podés simplemente reemplazar el keystore**. Hay dos caminos:

1. **Play App Signing está habilitado** (recomendado, es el default en apps nuevas):
   - Google firma la app final con su propio key
   - Vos solo firmás con un "upload key" que SÍ podés rotar
   - Flujo: Play Console → Setup → App integrity → Upload key certificate → Request upload key reset
   - Google responde por email con los pasos — normalmente 48h

2. **Play App Signing NO está habilitado** (deprecated, apps viejas):
   - No hay forma de rotar. El keystore es la identidad de la app.
   - Tendrías que publicar una app nueva con otro `applicationId`.

> [!tip] Como Solennix tiene `versionCode = 1` y nunca se publicó → rotación libre, sin pedirle nada a Google.

---

## CI (GitHub Actions u otro)

En CI, **no subas el `.jks` al repo**. Opciones:

1. **Base64-encoded secret**:

    ```yaml
    env:
      SOLENNIX_KEYSTORE_FILE: ${{ runner.temp }}/solennix.jks
      SOLENNIX_KEYSTORE_PASSWORD: ${{ secrets.ANDROID_KEYSTORE_PASSWORD }}
      SOLENNIX_KEY_ALIAS: ${{ secrets.ANDROID_KEY_ALIAS }}
      SOLENNIX_KEY_PASSWORD: ${{ secrets.ANDROID_KEY_PASSWORD }}
      REVENUECAT_API_KEY: ${{ secrets.REVENUECAT_API_KEY }}

    steps:
      - uses: actions/checkout@v4
      - name: Decode keystore
        run: |
          echo "${{ secrets.ANDROID_KEYSTORE_BASE64 }}" | base64 -d > ${{ runner.temp }}/solennix.jks
      - name: Build release
        run: ./gradlew :app:bundleRelease
        working-directory: android
    ```

2. **Google Cloud Secret Manager / HashiCorp Vault**: cargar los secretos en env vars antes del build.

---

## Checklist pre-release

Antes de subir una versión a Play Store:

- [ ] `key.properties` existe y tiene passwords fuertes (no `asd123`)
- [ ] `solennix.jks` existe en `android/` o env var `SOLENNIX_KEYSTORE_FILE` apunta a él
- [ ] Passwords del keystore guardados en password manager (no perder)
- [ ] `REVENUECAT_API_KEY` configurado y empieza con `goog_`
- [ ] `./gradlew :app:bundleRelease` genera el AAB sin errores
- [ ] El AAB firmado se valida: `jarsigner -verify -verbose app/build/outputs/bundle/release/app-release.aab`
- [ ] `versionCode` incrementado respecto a la versión anterior publicada

---

## Estado actual (2026-04-11)

> [!warning] Acciones pendientes del usuario
> - [ ] Rotar `asd123` → password fuerte (keytool -storepasswd)
> - [ ] Configurar `REVENUECAT_API_KEY` en `~/.gradle/gradle.properties`
> - [ ] Guardar passwords en password manager
> - [ ] Validar `./gradlew :app:assembleRelease` funciona end-to-end

> [!note] Completado por Claude en este bloque
> - [x] `build.gradle.kts` ahora soporta env vars + file con fail-fast en release
> - [x] `key.properties.example` creado como template
> - [x] Validación de `REVENUECAT_API_KEY` antes de compilar release
> - [x] Warning en debug si RevenueCat key está vacío
> - [x] Docs sincronizados con `11_CURRENT_STATUS.md`

---

## Relaciones

- [[Android MOC]]
- [[Roadmap Android]]
- [[Autenticación]] — donde vive la integración con RevenueCat
- [[Módulo Settings]] — PricingScreen usa la API key
- [[../PRD/11_CURRENT_STATUS|Estado actual del proyecto]]
