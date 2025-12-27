Aquí tienes un **DOCUMENTO PROFESIONAL .MD** completo, claro y ordenado, que explica **todo el proceso de dockerización del proyecto Flutter (Cálculo de Fuerzas Eléctricas – C.F.E.)**, incluyendo:

- Docker para compilación Android
- SDK de Flutter + Android SDK dentro del contenedor
- Firma de la app (keystore)
- Instalación en dispositivo físico por USB usando Docker
- Manejo de Firebase en builds dockerizadas

---

# 📘 **Dockerización Completa del Proyecto Flutter C.F.E.**

## _Manual Técnico para Desarrolladores_

Este documento explica paso a paso cómo se configuró y ejecuta la infraestructura necesaria para **compilar, firmar e instalar** la app Flutter **C.F.E.** utilizando **Docker**, sin necesidad de instalar Flutter o Android SDK en el sistema host.

---

---

# 1. 🎯 **Objetivo del Proceso**

El propósito de esta dockerización es:

- Tener un **entorno de build totalmente reproducible**.
- Eliminar problemas de versiones entre desarrolladores.
- Compilar APK **release** dentro de contenedores Docker.
- Conectar dispositivos Android físicos al contenedor para instalar directamente desde Docker.
- Mantener aislado el Android SDK, NDK, y las dependencias del sistema.

De esta forma, cualquier desarrollador puede crear el APK sin configurar manualmente su máquina.

---

---

# 2. 📦 **Dockerfile del entorno Flutter/Android**

Se creó un Dockerfile para construir una imagen llamada:

```
flutter-cfe-android:3.35.7
```

Este Dockerfile incluye:

- Ubuntu 22.04
- Flutter SDK 3.35.7 (misma versión del proyecto)
- Android SDK
- Build-tools 34.0.0
- Platform android-34
- NDK 26.1
- Java 17
- sdkmanager + commandline-tools

### Archivo: `Dockerfile`

```dockerfile
FROM ubuntu:22.04

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa openjdk-17-jdk ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /opt/flutter
WORKDIR /opt/flutter
RUN git checkout adc9010625
RUN flutter --version

# Android SDK
RUN mkdir -p /opt/android-sdk/cmdline-tools
RUN curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /opt/android-sdk/cmdline-tools \
    && rm /tmp/cmdline-tools.zip

RUN yes | /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk --licenses
RUN /opt/android-sdk/cmdline-tools/bin/sdkmanager --sdk_root=/opt/android-sdk \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH="$PATH:/opt/flutter/bin:/opt/android-sdk/platform-tools"

WORKDIR /app
```

---

---

# 3. 🏗 **Construcción de la imagen Docker**

Desde la raíz del proyecto Flutter:

```powershell
docker build -t flutter-cfe-android:3.35.7 .
```

---

---

# 4. 🖥 **Script de PowerShell para ejecutar Flutter dentro del contenedor**

Para simplificar el uso se creó:

### `flutter_cfe_android.ps1`

```powershell
docker run -it --rm `
  -v "${PWD}:/app" `
  -w /app `
  --device /dev/bus/usb:/dev/bus/usb `
  flutter-cfe-android:3.35.7 bash
```

Esto abre una terminal **ya dentro del contenedor**, lista para ejecutar Flutter:

Ejemplo:

```bash
flutter clean
flutter pub get
flutter build apk
```

---

---

# 5. 🔑 **Firma del APK (Release Signing)**

Para publicar apps Android, es obligatorio firmarlas.

## 5.1 Crear la llave `.jks`

Desde:

`android/app`

```powershell
keytool -genkeypair -v -keystore cfe-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias cfe_key
```

---

## 5.2 Archivo `key.properties`

En:

`android/key.properties`

```properties

```

---

## 5.3 Modificar `android/app/build.gradle`

Agregar dentro de `android {}`:

```gradle
signingConfigs {
    release {
        if (keystoreProperties['storeFile']) {
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
        }
    }
}

buildTypes {
    release {
        signingConfig signingConfigs.release
        minifyEnabled false
    }
}
```

---

---

# 6. 📱 **Instalar APK en un dispositivo Android usando Docker**

Flutter dentro de Docker no puede usar ADB directamente.
Hubo que exponer el USB del teléfono dentro del contenedor usando **usbipd-win**.

---

## 6.1 Instalar usbipd-win

```powershell
winget install usbipd
```

---

## 6.2 Listar dispositivos USB

```powershell
usbipd list
```

Ejemplo:

```
1-2  Android ADB Interface  Not shared
```

---

## 6.3 Compartir el dispositivo con WSL/Docker

```powershell
adb kill-server
usbipd bind --force --busid 1-2
usbipd attach --wsl --busid 1-2
```

Verificar:

```powershell
usbipd list
```

Debe mostrar:

```
1-2 Android ADB Interface  Attached
```

---

## 6.4 Ya dentro del contenedor:

```bash
adb devices
```

Si sale "unauthorized", autorizar en el teléfono.

---

## 6.5 Instalar la app desde Docker

```bash
flutter install
```

---

---

# 7. 🔥 **Problema con Google Sign-In en APK Release (corregido)**

En modo debug funcionaba, pero en release (docker) no.

Esto se debió a:

### ✔ SHA-1 / SHA-256 nuevos al firmar la app

Se resolvió al:

1. Obtener el SHA del release dentro del contenedor:

   ```bash
   cd android
   ./gradlew :app:signingReport
   ```

2. Registrar SHA-1 y SHA-256 en Firebase console → Android app.
3. Descargar nuevo `google-services.json`.
4. Copiarlo a:

   ```
   android/app/google-services.json
   ```

Después de esto, Google Sign-In funciona en release.

---

---

# 8. 📦 **Compilar APK Release Final**

Dentro del contenedor:

```bash
flutter clean
flutter pub get
flutter build apk
```

El APK queda en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

---

# 9. 🎉 **Resultado Final**

Con esta infraestructura Docker:

- El proyecto Flutter se puede compilar **sin instalar Android Studio, SDK o Flutter en el host**.
- La firma del build release está completamente automatizada.
- Se puede instalar el APK en dispositivos físicos desde Docker.
- El login con Google funciona correctamente en builds release.

Este flujo permite que cualquier desarrollador nuevo solamente necesite:

```powershell
.\flutter_cfe_android.ps1
```

Y los comandos dentro del contenedor:

```bash
flutter build apk
flutter install
```

---

---

# 10. 📚 **Anexos y recomendaciones**

### A. Actualizar Flutter dentro del contenedor

No recomendado — el contenedor usa versión fija.

### B. Regenerar la imagen si hay cambios en SDK

```powershell
docker build -t flutter-cfe-android:3.35.7 .
```

### C. Regenerar firma (keystore)

⚠️ Guardar siempre el archivo `.jks` y sus contraseñas.
Sin eso no podrás actualizar la app jamás.

---

---

# ✔ ¿Quieres que genere este documento también en PDF o en un README súper bonito para GitHub?

Puedo exportarlo, añadir esquemas, imágenes o diagramas del flujo.
