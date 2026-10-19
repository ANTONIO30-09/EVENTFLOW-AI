# 🎉 EventFlow AI

> **Gestión logística de eventos de alta gama.**  
> Proyecto universitario (Unifranz - Cochabamba, Bolivia) que combina Inteligencia Artificial y un diseño elegante para la organización de bodas y fiestas.

---

## 📋 Tabla de Contenidos

1. [Sobre el Proyecto](#-sobre-el-proyecto)
2. [Sistema de Diseño](#-sistema-de-diseño)
3. [Características Principales](#-características-principales)
4. [Stack Tecnológico](#-stack-tecnológico)
5. [Requisitos Previos](#-requisitos-previos)
6. [Instalación y Configuración](#-instalación-y-configuración)
7. [Estructura del Proyecto](#-estructura-del-proyecto)
8. [Despliegue](#-despliegue)
9. [Roadmap](#-roadmap)
10. [Licencia](#-licencia)

---

## 🎯 Sobre el Proyecto

**EventFlow AI** es una aplicación Flutter (Web + Móvil) diseñada para la gestión logística de eventos. Permite a los organizadores y al staff coordinar la distribución de mesas, el control de invitados (check-in) y las reglas de compatibilidad (quién se sienta con quién).

El sistema utiliza Firebase (Firestore + Auth) como backend y ofrece dos roles diferenciados:
- **Organizador:** Control total (generar distribuciones con IA, aprobar mesas, gestionar reglas).
- **Staff:** Solo lectura y check-in de invitados.

> *"Una invitación de evento de alta gama convertida en herramienta de trabajo."*

---

## 🎨 Sistema de Diseño

La identidad visual es estricta y se basa en una paleta cálida y elegante:

| Color | Hex | Uso |
|-------|-----|-----|
| **Azul Noche** | `#1B2A3D` | Fondo principal (Bokeh animado) |
| **Porcelana** | `#FBF9F4` | Superficies, tarjetas, inputs |
| **Bronce** | `#B8863E` | Acentos, botones primarios, títulos |
| **Verde Salvia** | `#3E7A5C` | Estados de éxito (check-in aprobado) |
| **Ladrillo** | `#A63D40` | Alertas, reglas "no sentar juntos" |
| **Gris Cálido** | `#6B6459` | Texto secundario |

- **Tipografía:** `GoogleFonts.fraunces` (títulos) e `GoogleFonts.inter` (cuerpo).
- **Efecto Vidrio:** Widget `GlassCard` (blur 12, fondo porcelana alpha 0.10, borde alpha 0.18).  
  *Regla de rendimiento:* Un solo `GlassCard` por sección grande. En listas largas se usa un "falso vidrio" (Container translúcido) para evitar lag en móviles.

---

## ✨ Características Principales

- **🤖 Distribución Sugerida:** Generación de mesas mediante IA o algoritmo estándar. Los organizadores pueden aprobar, mover invitados y explicar la distribución.
- **👥 Control de Invitados:** Búsqueda en tiempo real (fuera del `StreamBuilder` para evitar pérdida de foco), filtros por estado (Todos/Ingresados/Pendientes) y check-in con animación.
- **📜 Reglas de Compatibilidad:** Creación de reglas "no sentar juntos" o "sentar juntos" mediante dropdowns que filtran invitados reales por `eventId`.
- **📷 Escáner de Inventario:** Escaneo de códigos QR con cámara y entrada manual (ID de texto) con feedback visual en vidrio.
- **👤 Perfil:** Visualización de datos del usuario (nombre, correo, rol) con tarjeta de vidrio y opción de cerrar sesión.
- **🔐 Login:** Autenticación con Firebase Auth, con toggle para mostrar/ocultar contraseña.

---

## 🛠️ Stack Tecnológico

- **Frontend:** Flutter (Dart) - Web y Móvil.
- **Backend:** Firebase (Firestore, Auth).
- **Tipografía:** `google_fonts`.
- **Escaneo QR:** `mobile_scanner`.
- **Control de Versiones:** Git + GitHub.

---

## ⚙️ Requisitos Previos

- Flutter SDK (3.44.8 o superior).
- Cuenta de Firebase con un proyecto configurado (Firestore + Auth).
- Firebase CLI (para despliegue web).
- Editor de código (VS Code o Android Studio).

---

## 🚀 Instalación y Configuración

1. **Clonar el repositorio:**
   ```bash
   git clone https://github.com/ANTONIO30-09/EVENTFLOW-AI.git
   cd EVENTFLOW-AI
   ```

2. **Instalar dependencias:**
   ```bash
   flutter pub get
   ```

3. **Configurar Firebase:**
   - Crea un proyecto en [Firebase Console](https://console.firebase.google.com/).
   - Habilita Firestore y Authentication (Email/Password).
   - Ejecuta `flutterfire configure` para generar el archivo `firebase_options.dart`.

4. **Ejecutar la app (modo desarrollo):**
   ```bash
   flutter run -d chrome
   ```
   (Para móvil: `flutter run` con un emulador o dispositivo físico).

---

## 📁 Estructura del Proyecto

```
lib/
├── core/
│   └── constants/        # Colores globales (AppColors)
├── data/
│   ├── models/           # Modelos (Guest, Event, CompatibilityRule, etc.)
│   └── services/         # Servicios de Firebase (DatabaseService, AuthService, etc.)
├── screens/              # Pantallas agrupadas por funcionalidad
│   ├── admin/            # Panel de administración (UI, no ruta aún)
│   ├── compatibility/    # Reglas de compatibilidad
│   ├── distribution/     # Distribución sugerida
│   ├── guests/           # Control de invitados
│   ├── home/             # Home y detalles de evento
│   ├── inventory/        # Escáner de inventario
│   ├── login/            # Inicio de sesión
│   └── profile/          # Perfil de usuario
├── widgets/              # Widgets reutilizables (GlassCard, NeonBottomNav, etc.)
└── main.dart             # Punto de entrada y rutas
```

---

## 🌐 Despliegue

- **Web:** `flutter build web` y `firebase deploy --only hosting`.
- **Móvil (APK):** `flutter build apk --release`.

---

## 🗺️ Roadmap

- [ ] **Panel de Administración Web:** Proyecto separado (Next.js + Tailwind CSS) para gestión avanzada (eventos, reportes, usuarios). *No se incluirá en el APK móvil por seguridad y rendimiento.*
- [ ] **Paginación de Firestore:** Cargar invitados de 50 en 50 para soportar 500+ invitados sin lag.
- [ ] **Isolate para IA:** Mover el cálculo del algoritmo de distribución a un hilo secundario.
- [ ] **Subida de Foto de Perfil:** Integración con Firebase Storage.
- [ ] **Optimización de Bokeh:** Reducir la carga de GPU en dispositivos de gama baja.

---

## 📄 Licencia

Distribuido bajo la Licencia MIT. Consulta `LICENSE` para más información.

---

## ✒️ Autor

**ANTONIO30-09** - [GitHub](https://github.com/ANTONIO30-09)

> Proyecto desarrollado para la Universidad Privada Franz Tamayo (Unifranz) - Cochabamba, Bolivia.
