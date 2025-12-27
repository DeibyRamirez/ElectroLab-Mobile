Aquí tienes un **README.md súper bonito, profesional y perfecto para GitHub**, con secciones claras, badges, emojis, diagramas y una estructura impecable para documentar tu entorno **Dockerizado de Flutter + Android SDK** para el proyecto **C.F.E.**

Listo para copiar y pegar directamente en tu repositorio GitHub.
Si quieres, también puedo generarte la **versión con imágenes**, **badges personalizados**, o incluso un **logo del proyecto**.

---

# 🚀 **C.F.E – Entorno Dockerizado para Flutter + Android SDK**

### _Builds reproducibles · Firma automática · Instalación en dispositivo físico · Firebase listo para producción_

![Flutter](https://img.shields.io/badge/Flutter-3.35.7-blue?logo=flutter)
![Docker](https://img.shields.io/badge/Docker-Containerized-blue?logo=docker)
![Android](https://img.shields.io/badge/Android%20SDK-34-green?logo=android)
![Status](https://img.shields.io/badge/Build-Release%20Ready-brightgreen)
![License](https://img.shields.io/badge/License-MIT-lightgrey)

---

## 🧠 **Descripción general**

Este repositorio incluye toda la infraestructura necesaria para **compilar, probar, firmar e instalar** la aplicación Flutter **C.F.E. (Cálculo de Fuerzas Eléctricas)** dentro de un **entorno Docker**, sin necesidad de instalar:

- Flutter SDK
- Android Studio
- Android SDK
- JDK
- Herramientas de build

Gracias a Docker, cualquier desarrollador puede obtener **builds 100% reproducibles**, evitando problemas de incompatibilidad entre versiones.

---

---

# 🧩 **Características principales**

✔️ Flutter 3.35.7 instalado dentro del contenedor
✔️ Android SDK + NDK + Build Tools instalados
✔️ Firma de APK Release lista para producción
✔️ Compatible con Firebase + Google Sign-In
✔️ Permite instalar la app en un celular físico vía USB
✔️ `flutter_cfe_android.ps1` para entrar al contenedor fácilmente
✔️ Build release con solo:

```bash
flutter build apk
```

---

---

# 📁 **Estructura del proyecto**

```
/
├── android/
│   ├── app/
│   │   ├── google-services.json
│   │   ├── cfe-release-key.jks       <-- Keystore de firma
│   ├── key.properties                <-- Credenciales del keystore
│
├── flutter_cfe_android.ps1           <-- Script para entrar al contenedor
├── Dockerfile                        <-- Imagen con Flutter + Android SDK
└── new_readme_ia.md                  <-- Este archivo
```

---

---

# 🐳 **1. Construcción de la imagen Docker**

Desde la raíz del proyecto:

```powershell
docker build -t flutter-cfe-android:3.35.7 .
```

---

---

# ▶️ **2. Entrar al entorno Docker (comando recomendado)**

Ejecuta el script:

```powershell
.\flutter_cfe_android.ps1
```

Esto abrirá una terminal **dentro del contenedor**, con Flutter listo:

```bash
root@container:/app# flutter --version
```

---

## Contenido del script `.ps1`

```powershell
docker run -it --rm `
  -v "${PWD}:/app" `
  -w /app `
  --device /dev/bus/usb:/dev/bus/usb `
  flutter-cfe-android:3.35.7 bash
```

---

---

# 🔧 **3. Dependencias dentro del contenedor**

Una vez dentro:

```bash
flutter clean
flutter pub get
flutter doctor
```

---

---

# 🔥 **4. Compilar APK Release**

```bash
flutter build apk
```

El APK final queda en:

```
build/app/outputs/flutter-apk/app-release.apk
```

---

---

# 🔐 **5. Firma del APK (Release Signing)**

El keystore (cfe-release-key.jks) se genera con:

```powershell
keytool -genkeypair -v \
  -keystore cfe-release-key.jks \
  -keyalg RSA -keysize 2048 \
  -validity 10000 \
  -alias cfe_key
```

### Archivo `key.properties`

```

```

### En `android/app/build.gradle`:

## Dentro de plugins{

    ```
    def keystoreProperties = new Properties()
    def keystorePropertiesFile = rootProject.file('key.properties')
    if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
    }

}

## Dentro de android{

    ```debajo de kotliñ(17)
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
            shrinkResources false
        }
    }

}

````

---

---

# 📱 **6. Instalación en un dispositivo Android desde Docker**

### 6.1 Instalar usbipd

```powershell
winget install usbipd
````

### 6.2 Listar dispositivos USB

```powershell
usbipd list
```

### 6.3 Adjuntar el dispositivo al contenedor

```powershell
adb kill-server
usbipd bind --force --busid 1-2
usbipd attach --wsl --busid 1-2
```

### 6.4 Dentro del contenedor:

```bash
adb devices
flutter install
```

---

---

# 🔥 **7. Solución: Error de Google Sign-In en APK Release**

El error ocurría porque el APK release tenía un **SHA-1 nuevo** (por el keystore), diferente al SHA-1 debug.

### Se solucionó así:

1. Obtener SHA del release:

   ```bash
   cd android
   ./gradlew :app:signingReport
   ```

2. Agregar **SHA-1** y **SHA-256** en:

   > Firebase Console → Authentication → Métodos de Inicio → Android

3. Descargar nuevo `google-services.json`.

4. Reemplazarlo en:

   ```
   android/app/google-services.json
   ```

✔ Después de esto, Google Sign-In funciona correctamente en release.

---

---

# 🧪 **8. Comandos útiles dentro del contenedor**

| Acción                      | Comando                        |
| --------------------------- | ------------------------------ |
| Limpiar proyecto            | `flutter clean`                |
| Actualizar dependencias     | `flutter pub get`              |
| Listar dispositivos         | `adb devices`                  |
| Instalar APK                | `flutter install`              |
| Ver información del signing | `./gradlew :app:signingReport` |

---

---

# 🧠 **9. Notas importantes para desarrolladores**

- No elimines el archivo **cfe-release-key.jks**; perderlo significa no poder actualizar la app en Play Store.
- La imagen Docker debe reconstruirse solo si se cambia la versión de Flutter o Android SDK.
- Este entorno garantiza builds estables sin depender del sistema operativo del desarrollador.
- Si Flutter se actualiza, debe actualizarse manualmente en el Dockerfile.

---

---

# 🎉 **10. Contribuir**

Las contribuciones son bienvenidas:

1. Fork
2. Crear una rama
3. Commit
4. Pull request

---

---

# 📄 **Licencia**

MIT License. Puedes usar este entorno para tus proyectos libremente.

---

---

# ⭐ ¿Quieres una versión con imágenes, tabla de contenidos automática o badges personalizados?

Puedo generarte una versión aún más profesional para GitHub.
