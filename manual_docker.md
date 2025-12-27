1️⃣ Qué tienes ahora (resumen rápido)

En tu máquina quedaron:

Imágenes Docker

flutter-cfe:3.35.7

Flutter 3.35.7 “congelado”.

Sin Android SDK (útil para análisis, pruebas rápidas, etc.).

flutter-cfe-android:3.35.7

Flutter 3.35.7 “congelado”.

Android SDK 34 + build-tools 34.0.0 (y en runtime instaló NDK 26 + Platform 35 + CMake).

Permite ejecutar: flutter build apk.

Scripts en la raíz del proyecto

En D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica:

flutter_cfe.ps1

docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe:3.35.7 bash

flutter_cfe_android.ps1

docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe-android:3.35.7 bash

2️⃣ Cómo usar esto en el día a día
2.1. Para trabajar normal con el código (sin compilar APK)

Abres Docker Desktop.

En PowerShell:

cd "D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica"
.\flutter_cfe.ps1

Dentro del contenedor:

flutter pub get
flutter analyze
flutter test

Cuando termines: exit.

2.2. Para compilar un APK desde el entorno congelado

Abres Docker Desktop.

En PowerShell:

cd "D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica"
.\flutter_cfe_android.ps1

Dentro del contenedor:

flutter build apk

Al final tendrás el APK en Windows, aquí:

D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica\build\app\outputs\flutter-apk\app-release.apk

Para salir: exit.

Nota: la primera vez tardó mucho porque el contenedor descargó NDK, Platform 35, CMake, etc.
Cada vez que entras a un contenedor nuevo, puede volver a descargar cosas si no quedaron horneadas en la imagen, pero ya viste que funciona.

3️⃣ Esqueleto de manual que puedes usar en tu informe técnico

Te dejo un esquema que puedes copiar y rellenar/ajustar:

3.1. Introducción

Objetivo:
“Dockerizar la aplicación móvil C.F.E (Flutter) para garantizar un entorno estable (Flutter 3.35.7) y reproducible para futuras actualizaciones y compilaciones de APK, independiente de los cambios de versiones en la máquina host.”

3.2. Prerrequisitos

Sistema operativo: Windows 10/11.

Tener instalado:

Docker Desktop (con virtualización habilitada).

Git (opcional en el host, pero útil).

Código fuente del proyecto Flutter C.F.E en una ruta como:
D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica.

3.3. Verificación de instalación de Docker

En PowerShell:

docker version
docker run --rm hello-world

Resultados esperados:

docker version muestra Client y Server.

docker run --rm hello-world imprime Hello from Docker!.

3.4. Creación de la imagen base con Flutter 3.35.7

Ir a la carpeta del proyecto Flutter:

cd "D:\PROYECTOS_FLUTTER\Calculos-de-Fuerza-Electrica"

Crear archivo Dockerfile en la raíz con el contenido que:

Usa ubuntu:22.04.

Instala dependencias (curl, git, openjdk-17, etc.).

Clona el repo de Flutter en /opt/flutter.

Hace git checkout adc9010625 (el commit de Flutter 3.35.7).

Añade Flutter al PATH.

Configura WORKDIR /app.

Construir la imagen base:

docker build -t flutter-cfe:3.35.7 .

Verificar:

docker images flutter-cfe

3.5. Prueba de Flutter dentro del contenedor

Ejecutar el contenedor:

docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe:3.35.7 bash

Dentro del contenedor:

flutter --version
flutter pub get

Confirmar que muestra Flutter 3.35.7 y que las dependencias se descargan correctamente.

3.6. Ampliación de la imagen con Android SDK (para compilar APK)

Editar el mismo Dockerfile para añadir:

Variables ANDROID_HOME y ANDROID_SDK_ROOT (/opt/android-sdk).

Descarga de Android Command Line Tools.

Ejecución de sdkmanager para:

Aceptar licencias.

Instalar:

platform-tools

platforms;android-34

build-tools;34.0.0

Construir la imagen extendida:

docker build -t flutter-cfe-android:3.35.7 .

Verificar:

docker images flutter-cfe-android

3.7. Scripts de ayuda en PowerShell

En la raíz del proyecto se crean:

flutter_cfe.ps1

docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe:3.35.7 bash

flutter_cfe_android.ps1

docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe-android:3.35.7 bash

Permiten entrar al entorno Docker con un solo comando.

3.8. Verificación del entorno con flutter doctor

Dentro del contenedor Android:

.\flutter_cfe_android.ps1

Y dentro:

flutter doctor -v

Verificar:

Android toolchain ✅

Warnings de Chrome, Linux desktop, Android Studio → no afectan la compilación de APK.

3.9. Compilación de APK dentro de Docker

Dentro del contenedor Android:

flutter build apk

Resultado:

Mensaje final:

✓ Built build/app/outputs/flutter-apk/app-release.apk (68.2MB)

El archivo generado se encuentra en:

build/app/outputs/flutter-apk/app-release.apk

(en la carpeta del proyecto en Windows).

3.10. Conclusión

Puedes cerrar con algo como:

“Mediante Docker se encapsuló un entorno de desarrollo y compilación para la aplicación C.F.E, fijando la versión de Flutter (3.35.7) y las herramientas de Android necesarias. Esto garantiza que futuras actualizaciones del sistema operativo, Flutter o las dependencias del host no afecten la capacidad de compilar la aplicación, facilitando la mantenibilidad, reproducibilidad y trazabilidad del software.”
