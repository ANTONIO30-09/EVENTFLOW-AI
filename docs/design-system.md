# EventFlow AI — Sistema de Diseño

## Paleta

| Rol | Hex | Uso |
|-----|-----|-----|
| Azul-noche | `#1B2A3D` | Fondo principal de la app |
| Blanco porcelana | `#FBF9F4` | Tarjetas e inputs |
| Bronce | `#B8863E` | Acentos, títulos, botones principales |
| Verde salvia | `#3E7A5C` | Éxito y confirmaciones |
| Ladrillo apagado | `#A63D40` | Alertas y restricciones |
| Gris cálido | `#6B6459` | Texto secundario |

## Tipografía

- **Marca** — `Fraunces` (serif). Se usa para el título "EventFlow AI".
- **Datos y UI** — `Inter` (sans-serif). Se usa para cuerpo, inputs, botones y textos secundarios.

## Componentes base

### Inputs
- Fondo: `#FBF9F4`.
- Bordes redondeados, sin sombras exageradas.
- Labels en `Inter`, sin mayúsculas, con tono amable ("Usuario", no "USUARIO").
- Placeholder con ejemplo real, no etiqueta repetida.

### Botón principal
- Fondo: bronce sólido (`#B8863E`).
- Texto: oscuro (`#1B2A3D`).
- Sin degradados ni sombras decorativas.

### Errores
- Mensajes en `#A63D40`, breves, en español, sin códigos técnicos cuando sea posible.

## Alcance

Este sistema se aplica por ahora **solo a `login_screen.dart`**. La migración del resto de pantallas se planifica para Semana 10, con validación pantalla por pantalla.
