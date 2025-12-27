@echo off
echo Buscando y conectando TECNO CM5 automaticamente...

:: Busca y attachea por hardware ID (funciona en USB-C o USB-A)
:: Cambia 0e8d:201c por el hardware ID de tu dispositivo si es necesario
usbipd attach --wsl --hardware-id 0e8d:201c

if %errorlevel% == 0 (
    echo.
    echo ¡Exito! El movil esta conectado al contenedor.
    echo Usa: flutter devices / flutter run
) else (
    echo.
    echo Error: Asegura que el movil este enchufado y en modo depuracion USB.
    echo Si no esta "Shared", ejecuta primero: usbipd bind --hardware-id 0e8d:201c (como Admin)
)

echo.
echo Presiona cualquier tecla para salir...
pause >nul

@REM Cómo usarlo:

@REM Crea un acceso directo al .bat en el Escritorio.
@REM Propiedades del acceso directo → Avanzado → "Ejecutar como administrador" (para que funcione el attach).
@REM Cada vez que enchufes el móvil: doble clic en el .bat → se conecta solo (1 segundo).

@REM Para hacerlo aún más automático (opcional: tarea programada)
@REM Si quieres que se ejecute solo al enchufar el móvil (sin doble clic):

@REM Crea el .bat de arriba.
@REM Abre Administrador de Tareas → Crear Tarea Básica:
@REM Nombre: "Auto-Connect TECNO USB".
@REM Trigger: "Al conectar un dispositivo USB" → Selecciona tu TECNO (por VID:PID si aparece).
@REM Acción: "Iniciar un programa" → Apunta al .bat.
@REM Marca "Ejecutar con privilegios más altos".

@REM ¡Listo! Se ejecuta solo al enchufar.