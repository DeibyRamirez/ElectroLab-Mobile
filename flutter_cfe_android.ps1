# version con SDK de Flutter para compilar apps Android
# version 1
# docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe-android:3.35.7 bash

# version 2 para acceso a dispositivos USB (ej. para debug en dispositivo real)
# docker run --rm -it `
#   -v "${PWD}:/app" `
#   -w /app `
#   --device /dev/bus/usb:/dev/bus/usb `
#   flutter-cfe-android:3.35.7 bash

# Archivo: flutter_cfe_android.ps1
# Ejecuta un contenedor Docker con Flutter y Android SDK (sin USB por ahora)

docker run --rm -it `
  -v "${PWD}:/app" `
  -w /app `
  flutter-cfe-android:3.35.7 `
  bash


# ¿Qué hace esto?

# --rm → borra el contenedor cuando salgas (la imagen queda, tu código también).

# -it → modo interactivo, para que puedas escribir comandos.

# -v "${PWD}:/app" → monta tu carpeta actual de Windows dentro del contenedor en /app.

# -w /app → pone el directorio de trabajo dentro del contenedor en /app.

# flutter-cfe:3.35.7 → usa la imagen que creamos.

# bash → abre una terminal Linux dentro del contenedor.