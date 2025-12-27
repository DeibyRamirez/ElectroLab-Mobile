# ⚡ C.F.E – App de Cálculo de Fuerzas Eléctricas

Aplicación móvil desarrollada en **Flutter** para el cálculo, representación y visualización de **fuerzas eléctricas** entre cargas.  
El proyecto integra **cálculo matemático, notación científica, visualización 3D con modelos `.glb`, Realidad Aumentada (AR)** y un **backend en Firebase**.

📌 Proyecto académico del **Semillero GITA** – **Corporación Universitaria Autónoma del Cauca**.

---

## 🎯 Objetivo

Facilitar el aprendizaje y la experimentación en fenómenos eléctricos mediante:

- **Cálculo automático** de fuerzas entre cargas (Ley de Coulomb).
- Expresión de resultados en **notación científica**.
- Representación interactiva de cargas con **modelos 3D `.glb`**.
- Soporte de **Realidad Aumentada (AR)**.
- Conexión a **Firebase** para autenticación y gestión de datos.
- Acceso mediante **Google Sign-In**.

---

## 🔑 Características principales

✔️ Cálculo dinámico de fuerzas eléctricas.  
✔️ Visualización de cargas positivas y negativas.  
✔️ **Vectores animados** en modelos 3D.  
✔️ Representación en notación científica.  
✔️ **Gráfica 3D** para mostrar interacciones.  
✔️ Plano cartesiano para análisis de direcciones de fuerza.  
✔️ Backend con Firebase + Google Sign-In.  
✔️ Compatible con Android (Android 12+).

---

## 🛠️ Tecnologías y entorno de desarrollo

### Lenguajes y Frameworks

- **Flutter 3.24.5 (stable)**
- **Dart 3.5.4 (stable)**
- **Java 17**

### IDEs

- Visual Studio Code 1.103.2
- Android Studio 2025.1.3

### Plugins de IDE

- Kotlin 1.9.22
- Android Gradle Plugin 8.6.0

---

## 📦 Dependencias principales

- **flutter_cube** → renderizado y manipulación de modelos 3D.
- **flutter_3d_controller** → control de animaciones e interacciones en modelos `.glb`.
- **camera** → integración con cámara para funciones AR.
- **firebase_core** → conexión con Firebase.
- **firebase_auth** + **google_sign_in** → autenticación segura con Google.
- **cloud_firestore** → base de datos en la nube.
- **url_launcher** → abrir enlaces externos.
- **video_player** → reproducción de videos locales o en línea.
- **flutter_launcher_icons** → personalización de íconos de la app.
- **flutter_lints** → buenas prácticas y análisis de código.

---

## 📂 Arquitectura del proyecto

📁 **lib/** → Código principal (pantallas, widgets, lógica).  
📁 **android/** → Código nativo Android y configuraciones (Gradle, permisos).  
📁 **ios/** → Código nativo iOS y configuraciones (Info.plist).  
📁 **assets/** → Modelos `.glb`, imágenes, recursos estáticos.  
📁 **test/** → Pruebas unitarias e integración.  
📁 **web/** → (opcional) archivos para Flutter Web.  
📁 **build/** → Archivos compilados automáticamente.  
📜 **pubspec.yaml** → Configuración de dependencias y assets.

---

## 🧪 Pruebas realizadas

- **Unitarias** → comprobar funciones individuales.
- **De aceptación** → validación del sistema completo en distintos escenarios.
- **Pruebas en dispositivos Android** con soporte para AR y modelos 3D.

---

## 🚀 Instalación y despliegue

1. Clonar este repositorio:

   ```bash
   git clone https://github.com/tuusuario/graficos_dinamicos.git

   ```

2. Instalar dependencias:

   flutter pub get

3. Ejecutar en dispositivo o emulador:

   flutter run

4. Compilar APK:

   flutter build apk

📖 Glosario

Fuerza eléctrica → Interacción entre cargas eléctricas.

Ley de Coulomb → Fórmula que describe la fuerza entre dos cargas.

Carga eléctrica → Magnitud de electricidad en un objeto.

Vector → Magnitud física con dirección y sentido.

Notación científica → Representación de números grandes/pequeños.

Prefijos SI → micro (µ), mili (m), nano (n), pico (p), etc.

📚 Referencias

R. A. Serway, J. W. Jewett – Electricidad y Magnetismo, Física para ciencias e ingeniería, tomo 2, 7ma edición, Ed. Cengage, 2005.

Flutter Oficial

Pub.dev

Tutorial Flutter en YouTube

Dart desde Cero para Principiantes

🧑‍💻 Créditos

Desarrollado por:

Deiby Alejandro Ramírez Galvis

David Urrutia Cerón

📌 Proyecto realizado en el marco del Semillero de Investigación GITA
📍 Corporación Universitaria Autónoma del Cauca
