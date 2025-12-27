# Imagen base de Ubuntu (Linux) para trabajar con Flutter
FROM ubuntu:22.04

# Evitar preguntas interactivas al instalar paquetes
ENV DEBIAN_FRONTEND=noninteractive

# Actualizamos e instalamos dependencias necesarias para Flutter y Java (para Android builds)
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    openjdk-17-jdk \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Clonar el repositorio oficial de Flutter en /opt/flutter
RUN git clone https://github.com/flutter/flutter.git /opt/flutter

# Nos movemos a /opt/flutter y fijamos la versión exacta de tu Flutter actual
# (revision adc9010625 de tu comando `flutter --version`)
WORKDIR /opt/flutter
RUN git checkout adc9010625

# Agregar Flutter (y Dart) al PATH dentro del contenedor
ENV PATH="/opt/flutter/bin:/opt/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Verificar instalación de Flutter
RUN flutter --version

# ============================
# ANDROID SDK PARA COMPILAR APK
# ============================

# Directorio base del SDK de Android
ENV ANDROID_HOME=/opt/android-sdk
ENV ANDROID_SDK_ROOT=/opt/android-sdk

# Crear carpeta base del SDK
RUN mkdir -p /opt/android-sdk/cmdline-tools

# Descargar e instalar las Android Command Line Tools
# (si algún día la URL cambia y falla, me mandas el error y la actualizamos)
RUN curl -o /tmp/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip \
    && unzip -q /tmp/cmdline-tools.zip -d /tmp/cmdline-tools \
    && mv /tmp/cmdline-tools/cmdline-tools /opt/android-sdk/cmdline-tools/latest \
    && rm -rf /tmp/cmdline-tools.zip /tmp/cmdline-tools

# Añadir las herramientas de Android al PATH
ENV PATH="${PATH}:/opt/android-sdk/cmdline-tools/latest/bin:/opt/android-sdk/platform-tools:/opt/android-sdk/emulator"

# Aceptar licencias de Android SDK de forma no interactiva
RUN yes | sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses

# Instalar componentes necesarios para compilar APK
# Puedes ajustar la versión de build-tools / platform si tu proyecto usa otra
RUN sdkmanager --sdk_root=${ANDROID_SDK_ROOT} \
    "platform-tools" \
    "platforms;android-34" \
    "build-tools;34.0.0"

# ============================
# CARPETA DE TRABAJO DEL PROYECTO
# ============================

# Carpeta de trabajo donde montaremos tu proyecto Flutter
WORKDIR /app
