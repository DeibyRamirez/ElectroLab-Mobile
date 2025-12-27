# version sin SDK de Flutter para compilar
docker run --rm -it -v "${PWD}:/app" -w /app flutter-cfe:3.35.7 bash

# ¿Qué hace esto?

# --rm → borra el contenedor cuando salgas (la imagen queda, tu código también).

# -it → modo interactivo, para que puedas escribir comandos.

# -v "${PWD}:/app" → monta tu carpeta actual de Windows dentro del contenedor en /app.

# -w /app → pone el directorio de trabajo dentro del contenedor en /app.

# flutter-cfe:3.35.7 → usa la imagen que creamos.

# bash → abre una terminal Linux dentro del contenedor.